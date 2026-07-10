# Mochi — Technical Requirements Document (TRD)

**Status:** v2 — full research redo, all open technical questions re-verified against current (2026-07-09) sources
**Author:** Assistant (technical planning session), for Sujal Sharma
**Date:** 2026-07-09 (v1 written earlier same day; v2 is a from-scratch re-verification, not an incremental patch)
**Bridges:** Product spec locked in Session 1 (see `project-mochi-*` memory) → buildable technical spec

---

## What changed from v1 (written a few hours earlier, same day)

v1 was written first; the client asked for a full redo rather than incremental review, so five parallel research agents re-verified every load-bearing claim from scratch. Most of v1 held up. Six things didn't:

1. **Particle effects: reversed back to Core Animation (`CAEmitterLayer`), not SpriteKit.** v1 corrected the original client-provided assumption ("Core Animation preferred") to SpriteKit. Fresh research reverses this again: `SKEmitterNode` requires a full `SKScene`/`SKView` render loop, which is heavyweight for a compact, intermittently-visible keyboard accessory view under a ~30-40MB budget. `CAEmitterLayer` composites directly into the existing UIKit view hierarchy with materially less overhead. See §2.
2. **Memory ceiling tightened further: ~30-40MB dirty memory, ~77MB total footprint, warning fires ~55MB** — not a flat "~40MB." This is a more precise, multi-sourced figure than v1's single number. See §2.
3. **App Check is now a concrete decision, not a flagged gap.** v1 flagged App Check as "wasn't in the original stack list, should be added." Research confirms it's free at Mochi's scale (App Attest on iOS costs nothing) and is Firebase's own explicit recommendation to close the exact hole v1 worried about (scraped API keys hitting Firestore/Functions from a script). See §3, §9 (ADR-011).
4. **A hard, dated Firebase deprecation was missing from v1 entirely: `functions.config()` shuts down.** The underlying Cloud Runtime Configuration API turns off 2025-12-31; `functions.config()` deployments fail outright after March 2027. Since Cloud Functions code is being written *now*, this isn't a future migration — it's a "don't build on this in the first place" instruction. Use `defineSecret()` (Cloud Secret Manager) + `.env` from day one. See §7, §9 (ADR-012).
5. **CI cost trap identified: GitHub Actions macOS runners bill at a 10x multiplier (~$0.062/min).** v1 named GitHub Actions as CI/CD (client-locked) but didn't flag that an un-path-filtered iOS workflow re-triggering on every commit burns minutes at 10x the Android/Functions rate. See §7, §9 (ADR-013).
6. **Age rating corrected: UGC apps should target 17+/18+, not the 13+ figure in v1's ADR-009.** Apple ran a July 2025 age-ratings overhaul (new 13+/16+/18+ bands); UGC-with-unmoderated-user-content apps are conventionally rated in the higher band precisely because content can't be fully pre-vetted. v1's "13+, not Families/4+" was directionally right (avoid the Kids category) but landed on the wrong specific rating. See §8, §9 (ADR-009 revised).

Everything else in v1 — serverless BaaS architecture, no REST/GraphQL, Firestore schema shape, Cloudflare over CloudFront, no Branch.io, RevenueCat cost-free at this scale, two environments not three (refined, see §7), Firebase-never-in-the-extension — was independently re-confirmed by the fresh research, in several cases with better sources than v1 had. Corrected/new figures below reflect the fresh pass.

---

## 0. Constraints this TRD is designed against

These are fixed, not up for debate — every decision below is chosen *because* of these, not despite them:

| Constraint | Value |
|---|---|
| Team size | 1 developer (Sujal), no backend/DevOps specialist |
| Timeline | 3 weeks, iOS first then Android |
| Budget | $425 fixed price (dev fee) — running costs separate, paid by client |
| Client involvement | Hands-off, delegates technical calls |
| Existing locked stack | Swift, Java/Kotlin, Firebase (Firestore/Storage/Auth/FCM), RevenueCat+Stripe, CDN, Google Cloud Vision, GitHub Actions |

**This changes the shape of every "textbook" answer below.** A traditional custom backend (Node/Express + Postgres, or microservices) is not just non-ideal here — it's not buildable by one person in 3 weeks on this budget, and there's nobody to operate it post-launch. That rules out entire categories of "standard" advice before we even get to architecture.

---

## 1. Architecture

### Decision: Serverless BaaS (Firebase-direct) + Cloud Functions for cross-cutting logic. NOT monolith, NOT microservices, NOT modular monolith, NOT Firebase Data Connect.

Reconfirmed by fresh research, including against a new 2025-2026 option that didn't exist when this pattern became conventional wisdom:

- **iOS app** and **Android app** talk **directly to Firestore/Storage/Auth** via the official SDKs, using **Firestore Security Rules** as the authorization layer.
- **Cloud Functions** (Node.js/TypeScript) handle everything that must NOT run on-device: server-authoritative counters, moderation, subscription webhook ingestion, scheduled jobs, account deletion cascades.
- There is no separate "API server" to deploy, scale, or patch. Firebase IS the infrastructure.

**Why not Firebase Data Connect (new option, reached GA April 2025):** Data Connect adds a GraphQL-style schema layer, but it's backed by **Cloud SQL for PostgreSQL, not Firestore** — a second, relational datastore. It requires an **always-on Cloud SQL instance** (no scale-to-zero, ~$9.37/month minimum after a 3-month trial, plus $4/1M operations past a 250k/month free tier). It's the right tool for apps that need deep relational joins and SQL-style analytics. Mochi's actual query patterns — feeds, single-doc reads, simple filters, no deep nested graph traversal — are exactly what Firestore already handles well, and adding a standing Postgres bill for a solo dev on a $425 fixed price is unjustified. **Verdict: skip it. Note it as the future escape hatch if the social graph ever needs real relational analytics.**

**Firebase's own official guidance (Doug Stevenson, Firebase Developer Advocate) still recommends querying the database directly from the client for most cases**, reserving Cloud Functions for: long-running operations, operations needing authorization beyond what Security Rules can express, moderation, and third-party service integration (payments). This maps exactly onto Mochi's Cloud Functions list in §4.

**Risk flagged — reconfirmed and now evidenced, not hypothetical:** A September 2025 security disclosure found roughly 150 Firebase-backed endpoints across top-ranked mobile apps **publicly readable/writable with no authentication** — leaking emails, phone numbers, chat content, and in some cases high-privilege tokens — traced to overly-permissive or leftover test-mode Security Rules. Because clients talk directly to Firestore, **a rules bug is directly internet-exposed with no server tier to catch it.** This is not a hypothetical caveat anymore; it is the documented, current failure mode of this exact architecture. **Budget explicit time in week 1 for Security Rules unit tests using the Firebase Rules emulator/test SDK — do not hand-verify rules by reading them.**

**Additional risk (new, not in v1): denormalization consistency burden.** Firestore has no joins/group-by. The Community feed needs the author's display name and avatar on each theme card without an extra read per card, so `themes/{id}` should carry **denormalized `creatorDisplayName` / `creatorAvatarUrl` fields**, kept in sync by a Cloud Function trigger on the user doc (fan-out on profile edit). This is standard practice but is real ongoing code, not a free lunch — a missed fan-out trigger is a stale-avatar bug, not a crash, so it fails silently. Flagging so it's designed in from the start rather than retrofitted (see updated schema, §3).

### High-level system design

```
┌─────────────────┐         ┌─────────────────┐
│   iOS App        │         │  Android App     │
│  (SwiftUI)       │         │  (Kotlin/Compose)│
│                  │         │                  │
│  ┌────────────┐  │         │  ┌────────────┐  │
│  │ Keyboard   │  │         │  │ IME Service│  │
│  │ Extension  │  │         │  │ (Keyboard) │  │
│  │ (UIKit +   │  │         │  │ (Kotlin +  │  │
│  │  CAEmitter │  │         │  │  Compose)  │  │
│  │  Layer)    │  │         │  │            │  │
│  └─────┬──────┘  │         │  └─────┬──────┘  │
│        │App Group│         │        │SharedPrefs
│        │+Keychain│         │        │(same pattern)
│        │(no direct         │        │          │
│        │ network)│         │        │          │
└────────┼─────────┘         └────────┼──────────┘
         │                            │
         └──────────┬─────────────────┘
                     │ Firebase SDKs (Auth/Firestore/Storage/FCM)
                     │ HTTPS (TLS 1.2+), JWT ID tokens, App Check tokens
                     ▼
        ┌────────────────────────────────────┐
        │           Firebase / GCP           │
        │                                     │
        │  App Check ── App Attest (iOS) /   │
        │               Play Integrity (Android)
        │  Firestore  ── Security Rules       │
        │  Storage    ── Security Rules       │
        │  Auth       ── Email/Google/Apple/OTP
        │  FCM        ── Push                 │
        │  Cloud Functions (TS, Node 20):     │
        │    - onThemePublish → Vision API    │
        │    - onLikeWrite → counters+leaderboard
        │    - onFollowWrite → counters       │
        │    - onProfileUpdate → fan-out to themes
        │    - onReportThreshold → auto-hide  │
        │    - revenueCatWebhook → entitlements
        │    - onAccountDelete → cascade purge│
        │    - checkUsernameAvailable/reserve │
        └───────┬────────────────┬───────────┘
                │                │
                ▼                ▼
        ┌───────────────┐  ┌──────────────┐
        │ Google Cloud  │  │ Cloudflare   │
        │ Vision API    │  │ (CDN, free   │
        │ (moderation)  │  │  unmetered)  │
        └───────────────┘  └──────────────┘
                     ▲
                     │ webhook (subscription events)
        ┌────────────┴────────────┐
        │ RevenueCat → App Store /│
        │ Google Play billing     │
        └──────────────────────────┘
```

### Module boundaries (client-side — drives folder structure, see §7)

**iOS:**
- `MochiApp` — main container app target (SwiftUI). Owns all 10 screens, Firebase SDK calls, RevenueCat SDK, App Check.
- `MochiKeyboard` — keyboard extension target (UIKit + `CAEmitterLayer` for effects, `UIInputViewController`). Rendering + effects engine only. **No Firebase/network SDK calls inside the extension process, confirmed with current sources**: `FirebaseFirestore`/`FirebaseDatabase` depend on a CFStream networking stack Firebase's own docs list as unsupported in constrained targets (the same restriction documented for App Clips applies here), and `firebase-ios-sdk` issue #12992 ("Add Firebase in iOS Custom Keyboard Extension," opened May 2024) confirms `FirebaseApp.configure()` failures inside extension targets with no supported fix. Reads active theme/settings/cached-entitlement state from the shared **App Group container**, and shares auth state via **Keychain Sharing using `Auth.auth().useUserAccessGroup()`** (Firebase's officially supported cross-target auth pattern — note it does **not** sync in real time across processes; the extension must explicitly reload on activation, design for "app writes, extension reads on next activation," not instant propagation).
- `MochiShared` — Swift Package: data models, App Group constants, the theme-rendering engine (used by both the main app's live preview and the real keyboard, so they never visually drift apart).

**Android:**
- `app` — main app module (Kotlin, Jetpack Compose).
- `ime` — `InputMethodService` module (Kotlin + Compose). Android has **no comparable hard memory ceiling** — an IME is bound at foreground priority by the system, giving it normal app-heap headroom (typically 128-512MB+), not iOS's ~30-40MB. Effects and rich theme rendering that are risky on iOS are comfortable here. Compose-in-IME requires explicit lifecycle plumbing (`InputMethodService` must implement `LifecycleOwner` + `SavedStateRegistryOwner`, wire `setViewTreeLifecycleOwner`/`setViewTreeSavedStateRegistryOwner` on the root view) — a known, documented pattern, not a blocker, but get the wiring right or risk window-leak bugs on keyboard recreation.
- `shared` — Kotlin module: models, rendering engine.

**Cloud Functions (`/functions`, TypeScript, Node 20 LTS):** one function per side-effect, listed in §4 API contract.

---

## 2. Tech Stack

| Layer | Choice | Status |
|---|---|---|
| iOS | Swift, **SwiftUI** for main app, **UIKit + `CAEmitterLayer`** for keyboard extension | **Revised from v1** (was UIKit + SpriteKit) — see reasoning below |
| Android | Kotlin (app + IME), Jetpack Compose for UI | Client-locked (Java/Kotlin) — Compose confirmed stable for IME use with correct lifecycle wiring |
| Database | Firebase Firestore | Client-locked, reconfirmed correct fit vs. Data Connect (§1) |
| File storage | Firebase Storage | Client-locked |
| Auth | Firebase Auth (Email/Password, Google, Apple, Phone OTP) | Client-locked — **Phone OTP requires Blaze plan since Sept 2024** (new note, see §3) |
| Push | FCM | Client-locked |
| Backend logic | Cloud Functions (Node.js 20 LTS, TypeScript) | Node version pinned deliberately — see §7 |
| Subscriptions | RevenueCat + App Store/Play billing (+ Stripe via RevenueCat Web Billing if needed) | Reconfirmed free until $2,500 Monthly Tracked Revenue, then 1% of gross tracked revenue |
| CDN | **Cloudflare Free** (not CloudFront) | Reconfirmed — Cloudflare Free's *unmetered* bandwidth beats CloudFront's 1TB-then-metered model for this exact workload (small, static, cacheable, global) |
| Moderation | Google Cloud Vision SafeSearch | Reconfirmed — 1,000 free/month, $1.50/1,000 after; gate uploads to subscribers to cap cost |
| Deep links | Native iOS Universal Links + Android App Links + a static redirect landing page — NOT Branch.io | **Reconfirmed.** Branch.io has had no permanent free tier since ~July 2025 — confirmed still true today, only a time-limited trial on its "Basics" tier, entry pricing not publicly listed but third-party reports place it $199-499/mo. Disqualifying at this budget. |
| CI/CD | GitHub Actions | Client-locked — **but see §7 for a real cost trap**: macOS runners bill at a documented 10x multiplier vs Linux |
| Client security | **Firebase App Check** (App Attest on iOS at launch; Play Integrity on Android later) | **New concrete decision** (was a flagged gap in v1) — free at Mochi's scale, closes the "scraped API key called from a script" hole that Security Rules alone can't close |

### Why Core Animation (`CAEmitterLayer`), not SpriteKit — reversing v1's call

v1 corrected the client's original assumption ("Core Animation preferred") to SpriteKit, citing "production keyboard extensions use SpriteKit as the standard efficient path." The fresh research pass reverses this back, with more specific reasoning than either prior position had:

- `SKEmitterNode` requires hosting an `SKScene` inside an `SKView`, which stands up a continuous Metal/GL-backed render loop and scene graph — designed for full-screen game surfaces, not a compact, intermittently-visible accessory view that must stay under a ~30-40MB dirty-memory budget.
- `CAEmitterLayer` is a `CALayer` subclass. It composites directly into the extension's existing UIKit view hierarchy — no separate scene object, no dedicated render loop, materially lower incremental memory/CPU cost. Direct comparison tests (shooting-star-style effects, built both ways) show `CAEmitterLayer` with less lag than the SpriteKit equivalent in this kind of compact-view context.
- Implementation guidance: use `CAEmitterLayer` with `renderMode = .additive` for glow/sparkle effects, cap `birthRate`/particle counts aggressively, reuse a small set of pre-rendered small PNG particle images rather than many textures, and tear down emitters on `viewDidDisappear`/keyboard dismiss so retained particle buffers don't accumulate across keyboard switches.
- **Honest caveat on confidence:** no source found documents SpriteKit specifically *crashing* inside a keyboard extension target — this is architecture-based reasoning (render-loop overhead) and comparative perf data, not a smoking-gun bug report. If there's ever a reason to prefer SpriteKit (e.g. a specific effect that's much easier to express with `SKEmitterNode`'s built-in physics), prototype it against the real memory budget on-device before committing — don't assume either framework's behavior from documentation alone.

### Memory ceiling — tightened figure

v1 said "~40MB effective ceiling, corrected from the client's original 60-70MB." Fresh research narrows this further with better sourcing: **~30-40MB dirty memory** is the practical crash zone (Apple Developer Forums thread 105815, the canonical long-running thread on this), with a more precise modern accounting from a dated November 2024 production postmortem putting the **hard cap at ~77MB total footprint**, with **iOS firing a memory warning around ~55MB** (~70% of cap) — if allocations continue past 77MB without responding to that warning (e.g., flushing CoreText glyph caches), the extension is killed immediately. That same postmortem is directly relevant to Mochi's custom-font-as-Unicode-lookalikes feature: it documents a real app where rendering ~1,854 emoji via CoreText accumulated ~120-127MB of retained glyph cache (uncleared `NSCache`), and fixing it (flushing caches on the memory-warning callback) took dirty memory from 127.6MB down to 14.9MB. **Design implication: build cache-flushing on the system memory-warning callback into the extension from day one, and test dirty-memory usage on a real device in Instruments during week 1**, not as a fix-it-later item — the emoji/font panel is a specific, foreseeable place this will bite.

**No evidence the ceiling was raised in iOS 17/18** the way some other extension types were (NetworkExtension went from 15MB to 50MB in iOS 15) — Apple hasn't published a keyboard-extension-specific figure at any point, so absence of a documented increase isn't proof there wasn't one, but budget to the conservative ~30MB figure regardless.

### SwiftUI in the extension: avoid it, not just "UIKit preferred"

New evidence sharpens this from a style preference to a documented risk. A dated April 2026 production writeup (using the SwiftUI-based KeyboardKit framework, which hosts SwiftUI via `UIHostingController` inside a `UIInputViewController`) documents a **6-7MB memory leak per keyboard switch**, climbing linearly toward the kill limit and getting the extension terminated — root-caused to retain cycles in closure-based handler properties that required an *extra* explicit `[weak self]` even where the outer closure already captured weakly. Post-fix steady-state was ~20MB vs. initial ~30MB climbing unboundedly. **Recommendation unchanged from v1 (UIKit for the extension) but now backed by a concrete failure mode**: SwiftUI's retain-cycle-prone closure patterns are dangerous specifically because the tiny memory budget amplifies every leak. If SwiftUI is used anywhere in the extension, treat retain cycles as release-blocking and profile dirty memory per keyboard-switch, not just at first launch.

### iOS 15 floor — flag, don't override (locked client decision)

New finding worth surfacing to the client even though it doesn't change the locked decision: `NavigationStack` is iOS 16+ only; iOS 15 requires the deprecated `NavigationView` for the main app's 10-screen navigation, with weaker programmatic/deep-link/path control. Several other SwiftUI conveniences that could be useful for a modern-feeling 10-screen app are also iOS 16+: `Charts`, `ShareLink`, `.presentationDetents` (native bottom sheets), `Grid`/`AnyLayout`. **This is not a recommendation to change the locked iOS 15 minimum** — the client explicitly corrected this from iOS 16 down to iOS 15 during discovery, presumably for device-reach reasons, and that's a product call, not a technical one. But it's worth one line to Sujal: building the main app against iOS 15 costs real SwiftUI convenience, and by mid-2026 iOS 16+ adoption is close to universal — if the client's reasoning for iOS 15 wasn't reach-driven, it may be worth a quick re-confirmation before navigation code is written, since retrofitting `NavigationStack` after `NavigationView` is built is real rework.

### Why Cloud Functions instead of a hand-written REST server
Already covered in §1 — restating the tie-in: this is the "backend framework" decision, and the answer remains "no traditional backend framework at all, and no Data Connect either," which is the correct call given team size = 1.

---

## 3. Data Layer (ERD → Firestore schema)

Firestore is NoSQL/document-based — there's no formal ERD/foreign-key normalization in the relational sense, but every relationship below is deliberate and needs to be fixed now because **schema changes after 250 themes and real user data exist are expensive** (Firestore has no ALTER TABLE — you'd write a migration Cloud Function and hope you didn't miss a document).

### Collections

**`users/{uid}`**
```
uid, email, phoneNumber, displayName, username (unique, lowercase, indexed),
avatarUrl, bio, authProviders: string[],
languagePreference: string,
followerCount: number, followingCount: number,
themeCount: number, likesGivenCount: number, likesReceivedCount: number,
subscriptionStatus: 'free' | 'trial' | 'active' | 'expired',  -- CACHE ONLY, see below
subscriptionExpiresAt: timestamp | null,
settings: { autocorrect: bool, swipeTyping: bool, haptics: bool, keySounds: bool, notifPrefs: {...} },
createdAt, updatedAt,
isDeleted: bool, deletedAt: timestamp | null  -- soft delete, see compliance §8
```
`subscriptionStatus` on the user doc is a **read cache populated by the RevenueCat webhook Cloud Function** — RevenueCat/App Store/Play Store remain the source of truth. **Security Rules pattern (refined from v1): use an allowlist, not a denylist.** `request.resource.data.diff(resource.data).affectedKeys().hasOnly([...client-editable fields only...])` — new sensitive fields (like a future `isVerifiedCreator` flag) are locked out by default because they're simply absent from the allowlist, rather than requiring you to remember to add every new sensitive field to a "don't allow" list. This is the single most important security rule in the app — get it wrong and users grant themselves premium for free. Consider mirroring `subscriptionStatus` into a Firebase Auth **custom claim** as well (also only settable server-side, via Admin SDK) — convenient for gating premium content in Security Rules across multiple collections without an extra doc read.

**`themes/{themeId}`**
```
creatorUid (indexed), creatorDisplayName, creatorAvatarUrl,  -- denormalized, see fan-out note below
name, description, hashtags: string[] (indexed, array-contains),
backgroundType: 'solid'|'gradient'|'image', backgroundConfig: map,
keysConfig: map, fontsConfig: map, effectsConfig: map,
isPremium: bool, isPublished: bool,
moderationStatus: 'pending'|'approved'|'rejected'|'hidden',
likeCount: number (denormalized, updated only by Cloud Function),
downloadCount: number, reportCount: number,
previewImageUrl, createdAt, updatedAt
```
**New vs. v1: `creatorDisplayName`/`creatorAvatarUrl` are now explicitly denormalized onto the theme doc** (v1's schema only had `creatorUid`, which would force an extra per-card user-doc read to render a feed of theme cards — a real N+1 problem at feed scale). A Cloud Function trigger `onProfileUpdate` (Firestore trigger on `users/{uid}` write) fans these out to every theme the user has published when `displayName`/`avatarUrl` changes. This is standard Firestore practice but is genuine ongoing code — a missed or failed fan-out is a silently stale avatar, not a crash, so add basic Cloud Functions error logging (Firebase's default Cloud Logging is sufficient) so drift gets caught rather than discovered by a support ticket.

**`likes/{uid}_{themeId}`** (composite doc ID prevents double-likes without a query)
```
uid, themeId, createdAt
```
Cloud Function `onLikeWrite` (Firestore trigger on create/delete) increments/decrements `themes/{themeId}.likeCount` AND `users/{creatorUid}.likesReceivedCount` AND writes into the current week's leaderboard bucket (below). Client never writes `likeCount` directly. **Confirmed still the right pattern even with Firestore's newer server-side `count()` aggregation queries (reached GA in the interim)** — `count()` has no real-time listener support and no offline support, so it can't back a live-updating like count on a scrolling feed; it's a good fit for admin dashboards and one-off totals, not for a value users see update live. Keep `count()` in your toolkit for anything rarely-read (e.g. an admin "total themes published" stat) to avoid building trigger infrastructure you don't need there.

**`follows/{followerId}_{followeeId}`**
```
followerId, followeeId, createdAt
```
Same denormalized-counter-via-trigger pattern for `followerCount`/`followingCount`.

**`reports/{reportId}`**
```
themeId, reporterUid, reason, createdAt, status: 'open'|'reviewed'
```
Cloud Function `onReportThreshold`: when a theme's `reportCount` crosses a fixed threshold (recommend: 5), auto-set `moderationStatus: 'hidden'` pending manual review. **Threshold of 5 is a placeholder — client should confirm, but do not leave it undefined; ship with 5.**

**`blocks/{blockerUid}_{blockedUid}`** — not in the original locked feature spec; added in the v1 session per Apple Guideline 1.2 (reconfirmed verbatim in this pass — UGC apps must offer both Report AND Block).
```
blockerUid, blockedUid, createdAt
```
V1 implementation unchanged: client reads its own `blockedUids` (denormalized array on the user doc, capped/paginated) and filters blocked creators out of feed queries client-side using Firestore's `not-in` (max 10 values per query — acceptable for V1's expected block volume; beyond 10, filter the remainder client-side after fetch).

**`collections/{collectionId}`** (curated, admin-authored, not user-generated)
```
name, description, themeIds: string[], coverImageUrl, sortOrder
```

**`liveWallpapers/{wallpaperId}`**
```
name, previewUrl, assetUrl, isPremium
```

**`weeklyStats/{weekId}/creators/{uid}`**
```
weekId format: ISO week string, e.g. "2026-W28"
uid, likeCount: number, themeCount: number
```
`onLikeWrite` increments `weeklyStats/{currentWeekId}/creators/{creatorUid}.likeCount`. A new week automatically starts a new (empty) subcollection — no reset job, no cron, no risk of a reset failing to run. Leaderboard query = `weeklyStats/{currentISOWeek}/creators` ordered by `likeCount` desc, limit 50.

**`usernames/{username}`** (new, made explicit — was implied but undocumented in v1)
```
uid  -- reservation doc, username (normalized lowercase) is the document ID itself
```
Enforced via a **transaction** in the `reserveUsername` Cloud Function: create `usernames/{normalizedUsername}` and set `users/{uid}.username` atomically; Security Rules require the reservation doc not already exist. This remains the only pattern for uniqueness in Firestore — **confirmed no built-in unique-constraint feature has been added.** Normalize (lowercase/trim) before using as the key so `Sujal`/`sujal` can't both be claimed; store the display-cased version as a separate field on `users/{uid}`.

### Indexing strategy (must be created before these queries are used)
- `themes`: composite index on (`isPublished`, `moderationStatus`, `isPremium`, `createdAt desc`) — Explore "New" tab.
- `themes`: composite index on (`isPublished`, `moderationStatus`, `likeCount desc`) — "Popular" tab.
- `themes`: array-contains index on `hashtags` + `createdAt desc` — hashtag browsing.
- `weeklyStats/{weekId}/creators`: single-field index on `likeCount desc` (Firestore auto-indexes this, but confirm at scale).
- `usernames`: no index needed — document ID lookup is O(1).

### Expensive-to-change-later flags
1. **`username` uniqueness** — reservation-doc pattern from day one; retrofitting onto an existing user base is painful.
2. **Denormalized counters AND denormalized creator display fields** — both chosen deliberately over live queries/joins, which don't exist in Firestore. Build the Cloud Function triggers (`onLikeWrite`, `onFollowWrite`, `onProfileUpdate`) from the start; retrofitting them onto stale data later requires a one-time backfill script.
3. **Soft delete on `users`** (`isDeleted`/`deletedAt`) instead of hard delete — needed for the account-deletion compliance flow (§8) while preserving referential integrity of `themes.creatorUid`/`creatorDisplayName`. Decide the display behavior now ("Deleted User" placeholder, and what happens to their denormalized name on old theme cards) rather than discovering broken profile links later.
4. **Phone OTP requires the project to be on Blaze** (confirmed current, effective since September 2024) — not a blocker since Blaze is already required for Cloud Functions, but sequence account setup so this isn't discovered late. **Also enable reCAPTCHA SMS defense and set an SMS Region Policy allowlist (target launch geographies only) before enabling Phone OTP in production** — this is the standard, currently-recommended mitigation against SMS-pumping/toll-fraud abuse, which is a real and currently-active attack pattern against apps offering Phone Auth with no guardrails. This is new guidance not present in v1; treat it as a required setup step, not optional hardening.

---

## 4. API Layer

### Decision: No REST, no GraphQL, no Firebase Data Connect. Direct Firestore SDK access (secured by Security Rules + App Check) + a small set of Cloud Functions callables for privileged operations.

Reconfirmed with a sharper reason to reject Data Connect specifically (§1): Mochi's data-fetching patterns are shallow (feeds, single-document reads, simple filters), which is precisely where a relational/GraphQL layer's value proposition (deep nested graph resolution in one round trip) doesn't apply, and where its cost (a standing Postgres instance, schema/migration management) is pure overhead for a solo dev on a fixed $425 price.

### Cloud Functions contract (the only real "API surface")

| Function | Trigger | Input | Output / Effect |
|---|---|---|---|
| `onThemePublish` | Storage/Firestore trigger on theme publish w/ background image | themeId | Calls Vision API SafeSearch; sets `moderationStatus` to `approved` or `rejected` |
| `onLikeWrite` | Firestore trigger, `likes/{id}` create/delete | — | Updates `themes.likeCount`, `users.likesReceivedCount`, `weeklyStats` bucket |
| `onFollowWrite` | Firestore trigger, `follows/{id}` create/delete | — | Updates `followerCount`/`followingCount` |
| `onProfileUpdate` | Firestore trigger, `users/{uid}` update | — | Fans out `displayName`/`avatarUrl` changes to that creator's published `themes` docs — **new function, not in v1** |
| `onReportThreshold` | Firestore trigger, `reports/{id}` create | — | If theme's `reportCount` ≥ 5, sets `moderationStatus: hidden` |
| `revenueCatWebhook` | HTTPS (called by RevenueCat) | RevenueCat event payload | Verifies signature, updates `users/{uid}.subscriptionStatus` (and mirrors to a custom claim) |
| `onAccountDelete` | Callable (from app, user-initiated) | uid (from auth context) | Soft-deletes user doc, anonymizes PII, revokes Firebase Auth account |
| `checkUsernameAvailable` / `reserveUsername` | Callable | username | Transactional reservation against `usernames/{username}` |

**All callable functions and all Firestore/Storage access should be gated by App Check** (App Attest on iOS at launch) — see §9 ADR-011. Secrets these functions need (RevenueCat webhook signing secret, etc.) must be provisioned via `defineSecret()`/Cloud Secret Manager, **not** the deprecated `functions.config()` — see §7.

### Auth strategy: Firebase Auth, JWT ID tokens

- All four login methods (Email/Password, Google, Apple, Phone OTP) issue a standard Firebase ID token (JWT), reconfirmed with no deprecations affecting this choice.
- Every Firestore Security Rule checks `request.auth.uid`; every request additionally carries an App Check token once enforcement is on.
- Cloud Functions callables receive both auth and App Check context automatically via the Firebase SDK.
- **Apple Sign-In is mandatory** the moment Google Sign-In is offered (Apple Guideline 4.8, reconfirmed unchanged) — already correctly scoped.
- **Phone OTP cost/abuse note (new, see §3):** requires Blaze plan; enable reCAPTCHA SMS defense + SMS Region Policy allowlist before shipping this login method to production.
- Firebase Auth free tier covers up to 50,000 MAU — a non-issue at launch scale; Identity Platform's tiered MAU pricing only becomes relevant well beyond that, and Mochi needs none of Identity Platform's enterprise features (SSO, multi-tenancy) so there's no reason to "upgrade" to it.

---

## 5. Non-Functional Requirements

### Scalability & Latency
- Firestore scales automatically; manual work is indexing (§3) and avoiding hot-document writes (denormalized counters via triggers, not direct client increments — a single Firestore document has a hard ~1 write/second sustained limit; if a theme ever needs to absorb likes faster than that, migrate to a sharded/distributed counter subcollection, which is a drop-in extension of the existing pattern, not a redesign).
- CDN (Cloudflare, free tier — see §6) in front of Storage for theme preview images — required to hit the "<3s theme download on 4G" target; without a CDN, cold Storage reads from a single region will not consistently meet this for users far from the bucket's region.
- Real-time Firestore listeners on the Community feed: use paginated one-shot queries with a "load more," not a live `onSnapshot` listener on an unbounded feed query — an unbounded listener re-fires (and re-bills reads) on every like/publish from any user.

### Uptime & Security
- Firebase's published SLA (~99.95% for Firestore) is the practical ceiling — do not promise the client higher uptime than the platform provides.
- TLS 1.2+ is automatic for all Firebase SDK traffic.
- **App Check — now a firm decision, not a flagged gap (see §9 ADR-011).** Enable on Firestore, Storage, and all callable Cloud Functions from launch. Security Rules verify *who* the user is; App Check verifies the request comes from your genuine app binary, not a script replaying a leaked API key + valid token. Firebase's own security checklist explicitly recommends enabling it "for every service that supports it." Cost is $0 at Mochi's scale — App Attest (iOS) has no meaningful quota concern at this volume; Play Integrity (Android, needed once the Android build ships) has a free 10,000 calls/day tier. **Caveat, stated explicitly by Firebase:** App Check "prevents some, but not all, abuse vectors" — it's a real, free layer to add, not a silver bullet; keep Security Rules rigorous regardless.
- **Security Rules must be treated as tier-1 engineering, written and unit-tested with the Firebase Rules emulator from week 1** — reconfirmed with a concrete, dated citation (§1) that misconfigured rules are the actual, current, documented cause of Firebase data breaches at exactly this kind of app's scale.

### Compliance — see §8 for full detail
### Cost model — see §6 for full detail

---

## 6. Third-Party Integration Cost & Risk

### Realistic monthly running cost (paid by client, per locked decision #14)

**Verified/corrected Firebase Blaze pricing** (accessed 2026-07-09, [firebase.google.com/pricing](https://firebase.google.com/pricing), [cloud.google.com/firestore/pricing](https://cloud.google.com/firestore/pricing)):

| Item | Free quota | Overage |
|---|---|---|
| Firestore reads | 50,000/day | **$0.06 / 100k** — *correction from v1, which had reads at $0.18/100k; that figure is actually the write price* |
| Firestore writes | 20,000/day | $0.18 / 100k |
| Firestore deletes | 20,000/day | $0.02 / 100k |
| Firestore storage | 1 GiB | $0.18 / GiB/mo |
| Cloud Storage stored | **5 GB** (updated — newer default buckets have a larger free tier than v1's figure) | ~$0.026 / GB/mo |
| Cloud Storage download/egress | **100 GB/month** (updated, same reason) | ~$0.12 / GB |
| Cloud Functions invocations | 2M/month | $0.40 / million |
| Vision SafeSearch | 1,000/month | $1.50 / 1,000 (drops to $1.00/1,000 past 5M/mo) |

The corrected/larger free tiers push the low end of the cost model down slightly from v1; the dominant cost driver conclusion is unchanged and, if anything, more true:

| Scale | With CDN caching (Cloudflare) |
|---|---|
| 1,000 MAU | **~$0-3/mo** |
| 10,000 MAU | **~$60-70/mo** |
| 100,000 MAU | **~$800-830/mo** |

**The dominant cost driver by far is Storage download bandwidth for preview images — not Firestore reads (especially now confirmed cheaper than modeled), not Vision moderation.** Since there are only 250 unique theme assets at launch, proper caching collapses bandwidth cost several-fold:

1. Long `Cache-Control` headers on Storage objects (theme preview images, fonts, live wallpaper assets).
2. Caching image loader on both platforms (SDWebImage/Kingfisher on iOS, Coil on Android) so each device fetches each asset roughly once.
3. Resized thumbnails (~30-50KB) for feed/grid cards; full-resolution previews only on the Theme Detail screen.
4. **Cloudflare over CloudFront — reconfirmed, with a sharper reason.** Cloudflare's Free plan includes **unmetered bandwidth**, i.e. flat $0 for this workload regardless of scale (appropriate use is web assets like images/fonts, which this is). CloudFront's "always free" tier is capped at 1TB egress + 10M requests/month and then meters at region-dependent per-GB rates (~$0.085/GB North America/Europe, higher in Asia-Pacific/Australia) — cost-predictable at Mochi's asset-set size, but Cloudflare is simply cheaper and flatter for a small, static, highly-cacheable set of ~250 assets.

### Scaling traps flagged (beyond bandwidth)
- **Real-time `onSnapshot` listeners on the Community feed** — use paginated one-shot `get()` queries with "load more" instead; reserve live listeners for small personal data only (e.g. the user's own like state on the theme they're viewing).
- **RevenueCat: reconfirmed free until $2,500 Monthly Tracked Revenue, then 1% of gross tracked revenue** (calculated pre-store-commission, so effective rate on net proceeds is closer to ~1.4%). At ~840 active monthly subscribers needed to cross the free threshold at $2.99/mo pricing, this won't bind for a long time post-launch.
- **Vision API cost is trivial relative to browsing volume** — do not over-engineer the moderation pipeline; gating photo-background uploads to subscribers only (a reasonable product choice, confirm with client) further caps this.
- **Branch.io — reconfirmed disqualified.** No permanent free tier since ~July 2025, current pricing not publicly listed, third-party reports place entry pricing $199-499/mo. Native Universal Links/App Links + a static redirect page remains correct at this budget; the trade-off accepted (no deferred-deep-link attribution analytics) is unchanged from v1 and still acceptable — Mochi doesn't need growth-marketing attribution for V1.

## Sources
[Firebase Pricing](https://firebase.google.com/pricing) · [Firestore Pricing](https://cloud.google.com/firestore/pricing) · [Cloud Vision Pricing](https://cloud.google.com/vision/pricing) · [RevenueCat Pricing](https://www.revenuecat.com/pricing) · [Branch.io Pricing](https://www.branch.io/pricing/) · [Cloudflare Plans](https://www.cloudflare.com/plans/) · [AWS CloudFront Pricing](https://aws.amazon.com/cloudfront/pricing/)

---

## 7. Engineering Conventions

### Repo structure (single monorepo — reconfirmed appropriate for 1 developer)

```
/mochi
  /ios
    /MochiApp/            # SwiftUI main app target
    /MochiKeyboard/       # UIKit + CAEmitterLayer keyboard extension target
    /MochiShared/         # Swift Package: models, App Group, render engine
  /android
    /app/                 # Kotlin + Compose main app module
    /ime/                 # InputMethodService module (Compose, with explicit LifecycleOwner wiring)
    /shared/               # Kotlin module: models, render engine
  /functions
    /src/
      onThemePublish.ts
      onLikeWrite.ts
      onFollowWrite.ts
      onProfileUpdate.ts   # new — fan-out for denormalized creator fields
      onReportThreshold.ts
      revenueCatWebhook.ts
      onAccountDelete.ts
      username.ts
  /firestore
    firestore.rules
    firestore.indexes.json
    storage.rules
  /docs
    TRD.md                 # this document
    /adr/                  # one file per decision, ADR-001... etc.
  /.github/workflows/
    ios-build.yml           # path-filtered to ios/** — see cost note below
    android-build.yml       # path-filtered to android/**
    functions-deploy.yml    # path-filtered to functions/**
```

**New, load-bearing addition vs. v1: every workflow must be path-filtered** (`on.push.paths` / `paths-ignore`, or the `dorny/paths-filter` action) so an Android-only commit doesn't trigger the iOS workflow and vice versa. This isn't a style nicety — see the cost note immediately below.

### GitHub Actions cost trap — new finding, not in v1

**GitHub-hosted macOS runners bill at a documented ~10x multiplier vs. Linux runners** (2026 rate: ~$0.062/min macOS vs. ~$0.006/min Linux). Free-tier included minutes are also consumed at this same multiplier, so a private-repo free allotment drains roughly 10x faster on macOS jobs than Linux ones. Without path filtering, every commit — including pure-Android or pure-Functions changes — would re-trigger the iOS build/archive job at 10x cost for no reason. **Mitigations to build in from week 1, not retrofit later:**
- Path-filter every workflow (above).
- Cache Swift Package Manager/DerivedData and Ruby gems between iOS runs.
- Don't run the macOS job on draft PRs.
- Archive/upload to TestFlight only on tags or merges to a release branch, not every commit.
- A self-hosted Mac mini remains a zero-marginal-cost escape hatch if this ever becomes the actual bottleneck — GitHub's proposed platform fee for self-hosted runners was announced then **postponed indefinitely** as of December 2025, so this option is currently unencumbered.

### iOS CI: Fastlane, with a maintenance-history caveat worth knowing

**Fastlane remains the standard tool** (`scan` for tests, `gym`/`build_app` for archive, `match` for signing, `setup_ci` for the runner keychain) — reconfirmed as still the least-brittle option vs. hand-rolling `xcodebuild` + manual App Store Connect API auth. The Keyboard Extension is just a second bundle ID; `match`'s `app_identifier` should be an array covering both the app and extension bundle IDs, and `gym` archives/embeds the extension automatically via the shared scheme. Use **App Store Connect API keys (.p8)**, not Apple-ID app-specific passwords.

**Worth flagging to the client/in project notes:** Fastlane's maintenance lapsed after Google stopped sponsoring it (disclosed Feb 2023, actually ended 2021) and it stagnated through most of 2025 under the Mobile Native Foundation before **a new maintainer took over in November 2025** and shipped a release in December 2025. It's the right practical choice for a 3-week build — just pin the version rather than tracking `latest`, given the history.

### Android + Functions CI: standard, with one hard deadline to build around

Android build/test on `ubuntu-latest` (1x cost) via `actions/setup-java` + Gradle, nothing unusual. For Functions deploy:
- **Use Node 20 LTS** for both the GitHub Actions runner and the Functions runtime (`firebase-tools` v13/v14 require Node 18, 20, or 22; Node 18 is EOL, so 20 is the safe pin).
- **Auth: prefer Workload Identity Federation (OIDC) via `google-github-actions/auth`** over storing a long-lived Firebase service-account JSON key as a GitHub secret. This is Google's own explicitly recommended pattern as of 2025-2026 — no key to rotate or leak, trust scoped to the specific repo. Legacy `firebase login:ci` token auth is being deprecated; don't build on it.
- **Hard deadline, must be designed around from day one, not migrated later: `functions.config()` is deprecated. The underlying Cloud Runtime Configuration API shuts down 2025-12-31, and `functions.config()` deployments fail outright after March 2027.** Since Functions code is being written in mid-2026, **do not use `functions.config()` at all** — use `defineSecret()` (Cloud Secret Manager) for sensitive values (RevenueCat webhook signing secret, any private key) and plain `.env`/`process.env` for non-sensitive config. This was entirely absent from v1 and is the single most time-sensitive correction in this redo.

### Secrets management
- iOS signing: Fastlane Match (encrypted certs/profiles in a private repo or cloud storage) + App Store Connect API key as a GitHub secret.
- Android signing: base64-encoded keystore as a GitHub secret, decoded at build time; no Match-equivalent tool exists for Android, this manual pattern is standard.
- Google Cloud/Firebase auth (Functions deploy, Vision API calls from within Functions): Workload Identity Federation preferred over stored keys, per above. If a Cloud Function calls Vision API, it uses the Function's own runtime service account automatically — never embed a Vision API key in the client apps.
- RevenueCat secret key and any non-Google secret: GitHub encrypted secrets (WIF doesn't apply outside GCP).

### Environment strategy: refined from v1

v1 recommended two Firebase projects (`mochi-dev`, `mochi-prod`), no staging. Fresh research refines rather than reverses this: **use the Firebase Emulator Suite as the primary local-dev environment** (Firestore, Auth, Functions, Storage all run locally — free, fast, zero risk to real data, and lets Security Rules and Functions be unit-tested before any deploy) for day-to-day development, and **keep a real `mochi-dev` cloud project only for the specific things the emulator can't cover** — FCM push notification testing and RevenueCat webhook testing are the concrete examples here, since both require real external services to round-trip against. Promote straight from emulator/dev testing to `mochi-prod`; still no separate staging tier — that remains correctly out of scope for a 1-developer, 3-week build, cheap to add later if the client wants one post-launch.

### Naming conventions
- Firestore collections: lowercase, plural (`users`, `themes`, `likes`, `follows`, `reports`, `blocks`, `collections`, `usernames`), camelCase for multi-word (`liveWallpapers`, `weeklyStats`).
- Swift: PascalCase types, camelCase members/functions — standard Swift API Design Guidelines.
- Kotlin: PascalCase classes, camelCase functions/properties — standard Kotlin conventions.
- Cloud Functions: one exported function per file, camelCase filename matching function name.

---

## 8. Compliance

This app's risk profile is genuinely elevated on two specific axes, reconfirmed by this pass: **(a)** it's a keyboard extension, which Apple treats as inherently sensitive (it *could* log everything a user types), and **(b)** its kawaii/cute branding with stickers and emoji is exactly the profile Apple/Google scrutinize for child-appeal even without a Kids-category listing. Two new/sharpened items this pass: the **Sticker Guidelines** apply directly (ties to the still-deferred stickers-source decision), and the **age rating should be 17+/18+, not 13+.**

### 8.1 Apple App Store — keyboard-specific (Guideline 4.4.1) — reconfirmed verbatim
Current live guideline text confirms: keyboards must (a) provide keyboard input functionality, (b) **follow the Sticker Guidelines if the keyboard includes images/emoji — directly applicable to Mochi, which ships both**, (c) provide a way to switch to the next keyboard, (d) **remain functional without full network access and without requiring Full Access**, and (e) collect user activity only to enhance on-device functionality. Must not launch other apps or repurpose keys for other behavior. **Design implication reconfirmed: the keyboard must never log/transmit typed content, and must work fully offline/without Full Access for core typing** — Full Access is requested/justified only for theme sync and entitlement checks.

**New, directly relevant: Apple's Sticker Guidelines now apply as a named, separate compliance surface** because Mochi ships stickers/emoji in the keyboard panel. This connects to the still-open "stickers source" decision (deferred since Session 1 — options were: client-provided artwork, licensed packs, or user-uploaded). Sticker Guidelines require either original artwork or properly-licensed/rights-cleared content — **this is a concrete reason to close the stickers-source decision before the sticker panel is built**, since option B (licensed packs) and especially option C (user-uploaded) carry direct IP/rights compliance obligations under this guideline that option A (client-provided original art) doesn't. Recommend flagging this to Sujal as a reason to push the client for a decision now rather than deferring further.

### 8.2 UGC requirements (Guideline 1.2 / 1.2.1) — reconfirmed, with 1.2.1 clarified
§1.2 (verbatim, confirmed live) requires: a method for filtering objectionable material, a report mechanism with timely response, **the ability to block abusive users**, and published contact information. Already addressed in the locked spec via Report + the v1-added Block feature (§3 `blocks` collection); remaining gaps to close: **publish contact info** (in-app + App Store listing) and **a documented ≤24-hour takedown process** (not a verbatim number in the guideline text, but Apple's consistent enforcement expectation — build to it).

**§1.2.1 is titled "Creator Content" in the current guidelines** (a clarification vs. v1's framing of it as a standalone age-gate rule) — it requires "a way for users to identify content that exceeds the app's age rating, and an age restriction mechanism based on verified or declared age to limit access by underage users." This still supports the age-gate decision made in v1 (ADR-009), just with more precise sourcing of *why* it's required.

Apple revised UGC-related guideline language twice already in 2026 (February: clarified anonymous/random chat falls under 1.2; June: expanded the objectionable-content list) — neither weakens the four core §1.2 requirements above.

### 8.3 Child-appeal scrutiny (Guideline 1.3, 5.1.4) + Google Play Families — reconfirmed, age rating corrected
Kawaii branding + stickers/emoji is a documented reviewer trigger for child-appeal scrutiny even without a Kids-category listing. Mitigations reconfirmed: stay out of the Kids category, no behavioral ads/tracking SDKs (already true — subscription-only monetization), add the age-gate (already planned per ADR-009).

**Correction to v1's ADR-009: the age rating itself should not be "13+."** Apple ran a major age-ratings overhaul in **July 2025** (new 13+/16+/18+ bands replacing the old 12+/17+ system; developers had to re-answer the new ratings questionnaire by **January 31, 2026** to keep shipping updates — already past as of today, so this affects the initial submission questionnaire directly). **UGC apps with unmoderated-until-reported user content are conventionally rated in the higher band (17+/18+ equivalent under the new system) specifically because content can't be fully pre-vetted before it's live** — this is standard practice for any app with an open publish-then-moderate UGC model, not specific to Mochi. v1's instinct (avoid 4+/Families) was right; the specific target ("13+") was wrong. **Corrected recommendation: target the new system's highest non-mature band appropriate for a UGC social app (equivalent to the old 17+), not 13+, and set Google Play's target audience/content rating consistently.** This doesn't change any V1 feature — it's a store-listing metadata correction, but it's the kind of thing that causes a resubmission if set wrong initially.

### 8.4 Subscriptions (Guideline 3.1.1/3.1.2) — reconfirmed, no change
Premium themes transact through Apple/Google IAP via RevenueCat, no external payment links. Auto-renewable subscriptions ≥7 days (both plans qualify). Standard RevenueCat paywall templates handle price/renewal/trial disclosure — no custom risk here.

### 8.5 Sign in with Apple (Guideline 4.8) — reconfirmed, no change
Confirmed still mandatory alongside Google Sign-In. Already correctly scoped.

### 8.6 Privacy manifest / Required Reason APIs — reconfirmed, one new specific
`PrivacyInfo.xcprivacy` reconfirmed required since May 2024, no change to that. **New, specific to a keyboard app: the "Active Keyboard" Required Reason API category applies directly and must be declared** with its permitted reason — this is a specific, foreseeable line item worth calling out explicitly rather than leaving as "declare Required Reason APIs" generically. Firebase SDK modules ship their own manifests (confirmed current: `FirebaseCore`, `FirebaseFirestore`, `FirebaseAuth` etc. each carry one in the SDK repo) — but the **app target's own manifest, plus manifests for RevenueCat/Stripe/any other third-party SDK**, remain the developer's responsibility. Use Xcode's Archive → Validate → Generate Privacy Report step to check aggregate coverage before submission.

### 8.7 Privacy policy content (Australian Privacy Act / APPs, GDPR, Apple/Google data-safety labels) — reconfirmed with a sharper timeline
The Australian small-business exemption (≤AU$3M turnover) still technically exists today, but **is legislated/agreed for removal, expected around end of 2026** — the government's 2023 Privacy Act Review response agreed in principle to remove it, and a targeted expansion already took effect **1 July 2026** pulling specific data-handling activities under the Act regardless of business size. **v1 said the exemption "doesn't matter in practice" because GDPR/store requirements bind regardless — this pass confirms that's still true, and adds that the exemption is disappearing anyway, so there's no scenario where deferring a compliant privacy policy is the right call.** Minimum content, unchanged from v1:
- What's collected: email, phone number, display name/username, bio, avatar, published theme content, photos used as keyboard backgrounds, purchase/subscription status.
- **What is explicitly NOT collected: keystrokes/typed text** — state this plainly.
- Third parties data is shared with: Firebase/Google Cloud, Apple, RevenueCat, Google Cloud Vision, Cloudflare.
- Cross-border disclosure (Australian Privacy Principle 8): data processed on Google/Firebase servers, likely in the US — name the likely destination countries.
- Right to deletion — already designed as `onAccountDelete` (§3/§4): soft-delete + PII anonymization + Firebase Auth account revocation.
- How to revoke consent / manage data.

Apple Privacy Nutrition Label and Google Play Data Safety declarations should mirror the above exactly — mismatched declarations are themselves a rejection/policy-violation risk independent of underlying practice.

### 8.8 Open item — genuinely not resolvable without the client
The exact list of the 4 supported languages remains unconfirmed. Doesn't block architecture, blocks localization work specifically.

### 8.9 New open item surfaced by this pass — recommend resolving soon, not deferring further
**Stickers source (deferred since Session 1) now has a concrete compliance reason to resolve before the sticker panel is built** — see §8.1. Recommend Sujal raise this with the client this week rather than at "when the sticker screen is reached," since option choice affects whether extra moderation/licensing work needs to be scoped.

---

## 9. Architecture Decision Records (ADRs)

**ADR-001 — Serverless BaaS architecture, not monolith/microservices/Data Connect**
*Decision:* Clients talk directly to Firestore/Storage/Auth via SDK, secured by Firestore Security Rules + App Check; Cloud Functions handle only privileged/cross-cutting logic. Firebase Data Connect (GA April 2025) evaluated and rejected — it's Postgres-backed, adds an always-on paid instance, and solves a relational-joins problem Mochi doesn't have.
*Why:* One developer, 3-week timeline, $425 budget. Reconfirmed by fresh research including Firebase's own official client-direct-access guidance.
*Risk:* Security Rules are the entire authorization layer — reconfirmed via a dated September 2025 disclosure of ~150 leaky Firebase apps traced to rules misconfiguration. Must be written and unit-tested in week 1, not verified by inspection.

**ADR-002 — UIKit + Core Animation (`CAEmitterLayer`) for the keyboard extension, not SpriteKit [REVISED from v1]**
*Decision:* Main iOS app in SwiftUI; keyboard extension in UIKit with **`CAEmitterLayer`** (not SpriteKit) for particle effects.
*Why:* This reverses v1's ADR-002, which had corrected the client's original "Core Animation preferred" assumption to SpriteKit. Fresh research reverses it back: `SKEmitterNode` requires a full `SKScene`/`SKView` render loop, heavyweight for a compact, intermittently-visible accessory view under a ~30-40MB budget; `CAEmitterLayer` composites directly into the existing view hierarchy with materially less overhead, and direct comparison tests favor it for this kind of compact effect. See §2 for implementation detail (additive blend mode, capped birth rate, teardown on dismiss).
*Risk:* No source documents SpriteKit specifically crashing inside a keyboard extension — this is reasoning from render-loop overhead plus comparative perf data, not a proven bug report. Prototype either framework's actual dirty-memory behavior on-device before fully committing; don't take either recommendation (this one, or v1's) purely on documentation.

**ADR-003 — No REST/GraphQL/Data Connect API layer**
*Decision:* Firestore SDK + Security Rules is the client-facing "API"; Cloud Functions callables are the only RPC-style surface, gated by App Check.
*Why:* Data-fetching needs are shallow — reconfirmed, and now explicitly checked against Data Connect as the new alternative and found not to fit (§1, §4).
*Risk:* None significant beyond the rules-testing burden already captured in ADR-001.

**ADR-004 — Weekly leaderboard via per-week subcollection, not a reset job**
*Decision:* `weeklyStats/{ISOWeekId}/creators/{uid}` incremented by the same trigger that maintains like counters.
*Why:* Unchanged, reconfirmed — no reset job that can fail to run.
*Risk:* None.

**ADR-005 — Native Universal Links + App Links, not Branch.io**
*Decision:* Platform-native deep linking plus a small static redirect landing page.
*Why:* Reconfirmed — Branch.io still has no permanent free tier as of today's research pass (checked independently, ~July 2025 change confirmed still in effect); entry pricing $199-499/mo per third-party reports, still disqualifying at this budget.
*Risk:* No deferred deep-link attribution analytics — unchanged, acceptable trade-off.

**ADR-006 — No Firebase SDK inside the keyboard extension process**
*Decision:* All Firebase/network calls happen in the main app; the extension reads cached state from an App Group container and shares auth via Keychain (`useUserAccessGroup`).
*Why:* Reconfirmed with sharper sourcing — Firebase's own docs list Firestore/Database as unsupported in constrained targets (CFStream dependency, same restriction documented for App Clips); GitHub issue #12992 (opened May 2024) documents `FirebaseApp.configure()` failures in extension targets with no supported fix.
*Risk:* Keychain-shared auth state does not sync in real time across processes — design for "app writes, extension reads on next activation," not instant propagation (new nuance from this pass, not in v1).

**ADR-007 — Two environments (dev, prod), Emulator Suite for local dev [REFINED from v1]**
*Decision:* Firebase Emulator Suite as the primary local-dev environment; a real `mochi-dev` cloud project retained only for testing FCM push and RevenueCat webhooks, which the emulator can't cover; `mochi-prod` for release. Still no staging tier.
*Why:* v1 said "two cloud projects, no staging." This pass finds the Emulator Suite is now the better-practiced default for local iteration (faster, free, zero risk to real data, lets Security Rules be tested pre-deploy) — refining rather than replacing the two-environment call.
*Risk:* None at this scale.

**ADR-008 — Denormalized counters via Cloud Function triggers, not live aggregation queries**
*Decision:* `likeCount`, `followerCount`, etc. are stored fields updated only by Firestore-triggered Cloud Functions, never written directly by clients.
*Why:* Reconfirmed even against Firestore's newer `count()` aggregation queries (reached GA in the interim) — `count()` has no real-time listener support, so it can't back a live-updating count on a feed; it's additive for admin/rare totals, not a replacement.
*Risk:* Denormalized data can drift if a trigger fails silently — add basic Cloud Functions error logging so drift is caught, not discovered by a user complaint. **New same-pattern addition: `creatorDisplayName`/`creatorAvatarUrl` are now also denormalized onto theme docs (§3), maintained by a new `onProfileUpdate` fan-out trigger** — same risk/mitigation applies.

**ADR-009 — Age-gate onboarding + honest age rating, no behavioral ads [RATING CORRECTED from v1]**
*Decision:* Add a neutral date-of-birth/age step to onboarding (unchanged); set App Store age rating and Google Play target audience to the **17+/18+-equivalent band under Apple's new 2025 rating system**, not "13+" as v1 stated, and not "Families"/4+.
*Why:* v1 correctly avoided the Kids-category trap but landed on the wrong specific number. This pass finds Apple overhauled age ratings in July 2025 (new 13+/16+/18+ bands, questionnaire re-answer deadline Jan 31 2026) and that UGC apps with unmoderated-until-reported content conventionally sit in the higher band — this is standard for open-publish UGC apps generally, not a Mochi-specific problem.
*Risk:* None — this is a store-metadata correction with no feature-scope impact, but wrong initial submission risks a resubmission cycle.

**ADR-010 — Block-user feature added to locked feature spec**
*Decision:* `blocks` collection and Block action on user profiles, alongside Report.
*Why:* Reconfirmed — Apple Guideline 1.2 text verified verbatim live, requires both.
*Risk:* Unchanged, small addition, already scoped.

**ADR-011 — Firebase App Check enabled from launch [NEW]**
*Decision:* Enable Firebase App Check (App Attest on iOS at launch, Play Integrity on Android when that build ships) on Firestore, Storage, and all callable Cloud Functions.
*Why:* v1 flagged this as "a gap, should be added" without committing to specifics. This pass confirms it's free at Mochi's scale and is Firebase's own explicit recommendation to close the exact threat v1 named (a scraped API key + valid auth token replayed from a script, which Security Rules alone can't distinguish from a real app request).
*Risk:* Firebase states App Check "prevents some, but not all, abuse vectors" — additive to Security Rules, not a replacement for rigor there.

**ADR-012 — Cloud Functions secrets via Secret Manager (`defineSecret`), never `functions.config()` [NEW]**
*Decision:* All Cloud Functions configuration/secrets use `defineSecret()` (Cloud Secret Manager) for sensitive values and `.env`/`process.env` for non-sensitive config, from the first line of Functions code written.
*Why:* Entirely new finding this pass, not present in v1 at all. `functions.config()`'s underlying Cloud Runtime Configuration API shuts down 2025-12-31; deployments using it fail outright after March 2027. Since Functions code is being written now (mid-2026), building on `functions.config()` would mean writing code against a mechanism already scheduled for shutdown before the project's own likely maintenance lifetime.
*Risk:* None if followed from day one; retrofitting later (if ignored) means rewriting every Function's config access under time pressure.

**ADR-013 — Path-filtered GitHub Actions workflows, macOS jobs minimized [NEW]**
*Decision:* Every GitHub Actions workflow (`ios-build.yml`, `android-build.yml`, `functions-deploy.yml`) is path-filtered to its own directory; iOS archive/TestFlight upload runs only on tags/release-branch merges, not every commit.
*Why:* New finding this pass: GitHub-hosted macOS runners bill at a documented ~10x multiplier vs. Linux (~$0.062/min vs ~$0.006/min in 2026), and free-tier minutes drain at the same multiplier. An un-filtered monorepo CI setup would burn 10x-cost minutes on every Android-only or Functions-only commit for no reason.
*Risk:* None — pure cost hygiene, cheap to build correctly from the first workflow file rather than retrofit.

**ADR-014 — Denormalized creator fields on theme docs, with explicit fan-out trigger [NEW]**
*Decision:* `themes/{id}` carries `creatorDisplayName`/`creatorAvatarUrl` in addition to `creatorUid`; a new `onProfileUpdate` Cloud Function trigger fans out changes when a user edits their display name or avatar.
*Why:* v1's schema only stored `creatorUid`, which would force an extra per-card user-doc read to render theme cards in a feed — a real N+1 read problem at feed scale that wasn't caught in the first pass. This pass's architecture research specifically flagged Firestore's lack of joins as requiring this denormalization pattern for exactly this kind of feed.
*Risk:* Same as ADR-008 — a failed/missed fan-out is a silently stale avatar, not a crash. Basic Cloud Functions error logging is the mitigation, not extra client-side complexity.

---

## Research provenance note

This v2 was produced by five parallel research agents (architecture patterns, iOS/Android keyboard-extension specifics, Firestore data/API layer, cost/security/compliance verification, engineering conventions/CI-CD), each independently sourcing and cross-checking claims against official docs, GitHub issues, and dated 2025-2026 sources, then synthesized directly into this document rather than run through the deep-research skill's default item-comparison template (which fits comparing N independent options, not one interdependent system design — noted in project memory from the v1 session and reconfirmed here). Confidence levels and explicit uncertainty flags are preserved inline throughout rather than smoothed over; where this pass found genuinely low-confidence or conflicting data (e.g. exact CloudFront regional egress rates, Fastlane's long-term maintenance trajectory), that's stated rather than presented as settled.
