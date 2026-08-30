# Mochi — Path to a Live App Store App

**Written:** 2026-07-30
**Purpose:** Translate "make it functional" into a concrete, ordered, complete list of everything left to build, with the reasoning behind each item.
**Audience:** Non-technical read, technically complete underneath.

---

## Part 1 — The honest picture of where we are

### The film-set analogy

Right now Mochi is a **beautiful film set**. Walk through it and every room looks exactly like the architect's drawing. But:

- The **doors are painted on** — screens don't actually lead anywhere.
- The **fridge is a prop** — every name, number, avatar and theme on screen is hardcoded text sitting in one file (`MockData.swift`), not information coming from anywhere.
- **There is no plumbing** — nothing is connected to a server. The word "Firebase" appears in exactly two places in the whole iOS codebase, and both are comments saying "this will be Firebase later."
- And critically: **the house has no kitchen.** Mochi is a keyboard app. The keyboard does not exist yet. Not "is incomplete" — the file doesn't exist. What you see labelled "keyboard preview" in the app is a static PNG image.

None of this is a criticism of the work done. The frontend work is genuinely high quality — the Figma parity is careful, the Firestore security rules are properly written *and* unit-tested (most solo projects never do that), and the architectural document (TRD) is unusually thorough. But the honest split is:

> **What's built is roughly the "showroom." What's left is the machine.**

### Concretely, what exists today

| Area | Status |
|---|---|
| iOS screens (7 of them) | Built, pixel-matched, ~5,000 lines |
| iOS navigation between screens | **None** — zero `NavigationStack`, zero sheets, zero links. Tab switching only |
| iOS data | 100% hardcoded mock data |
| iOS Firebase connection | **None** |
| iOS keyboard extension | **Does not exist** |
| Firestore security rules | Written + unit-tested ✅ |
| Firestore indexes | Written ✅ |
| Storage rules | Written ✅ |
| Cloud Functions (server logic) | **None — the `/functions` folder doesn't exist.** All 8 planned functions unwritten |
| Login / signup | **Doesn't exist** |
| Onboarding / splash | **Doesn't exist** |
| Theme Detail screen | **Doesn't exist** |
| Settings screen | **Doesn't exist** |
| Paywall / subscriptions | **Doesn't exist** |
| Search screen | Built but **orphaned** — not reachable from anywhere in the app |
| Leaderboard | **Doesn't exist** |
| Live Wallpapers section | **Doesn't exist** |
| App icon | **Missing** (deliberately disabled in build config) |
| Android | Skeleton mirror, well behind iOS |
| Signing / provisioning | Not configured (`DEVELOPMENT_TEAM` is empty) |
| Push notifications | **None** |
| Analytics / crash reporting | **None** |
| Loading / error / empty states | **None anywhere** — mock data never fails, so no screen knows how to say "loading…" or "no internet" |
| Localization | **None** — every string is hardcoded English, and the spec calls for 4 languages incl. Thai |

### The three different kinds of "not functional"

It helps to separate them, because they're solved by different work:

1. **Screens don't connect.** Tapping a theme card does nothing. Tapping a creator name does nothing. This is *navigation* work — moderate, mostly mechanical.
2. **Screens show fake data.** This is *data layer* work — and it's bigger than it looks, because the data containers themselves need rebuilding (explained in §W5).
3. **The product doesn't exist.** The keyboard. This is the single largest remaining piece and it's genuinely hard engineering, not glue code.

---

## Part 2 — The one decision that must come first

Before any of the workstreams below, there is a single design decision that everything else hangs off:

### The theme format ("what is a theme, as data?")

A theme is currently a picture. In the real app, a theme is a **recipe** — a small blob of settings that says: background is this gradient, keys are pill-shaped with this colour and a 1pt border, font is "Bubble Cute" at 90% size, key-press effect is sparkles at this density.

That recipe format is written by the **Create screen**, stored in **Firestore**, rendered by the **in-app preview**, and rendered again by the **real keyboard** — four things. If the format is wrong or incomplete, all four get rewritten.

**So: define that format precisely, first, before writing any of the four.** In the TRD it's sketched as four loose fields (`backgroundConfig`, `keysConfig`, `fontsConfig`, `effectsConfig`) with type "map", i.e. "some settings go here." That's not specific enough to build against. It needs to be nailed down to exact fields and exact allowed values.

This is the highest-leverage hour of work in the entire remaining project.

---

## Part 3 — The workstreams

Fifteen workstreams. Ordered roughly by dependency, not by size.

---

### W0 — Foundation: accounts, IDs and project setup
**Size: small (days), but blocks nearly everything.**

Nothing real can be built until these exist, because the app literally cannot talk to a server without a config file, and the keyboard cannot share data with the app without an ID that has to be decided before the keyboard is created.

- [ ] Firebase project created — **two** of them: `mochi-dev` and `mochi-prod`. Download `GoogleService-Info.plist` for each.
- [ ] Firebase upgraded to **Blaze** (pay-as-you-go). Required for Cloud Functions at all, and required for Phone OTP login since Sept 2024.
- [ ] Set a **budget alert** on the Google Cloud billing account. Blaze has no spending cap by default; a bug or an abuse spike can run up a bill. This is a five-minute task that prevents a very bad day.
- [ ] Apple Developer Program membership active ($99/yr, 1–2 days to approve).
- [ ] Bundle IDs registered: `com.mochi.app` and `com.mochi.app.keyboard`.
- [ ] **App Group** created (`group.com.mochi.app`) — this is the shared folder the app and keyboard use to pass information to each other. Must be enabled on both.
- [ ] **Keychain Sharing** enabled on both targets — this is how the keyboard learns "this user is logged in and has premium" without talking to the network.
- [ ] Signing configured (`DEVELOPMENT_TEAM` is currently blank), App Store Connect API key (.p8) for automated uploads.
- [ ] App Store Connect app record created; subscription products created ($2.99/mo, $19.99/yr, both with 3-day trial).
- [ ] RevenueCat account, linked to App Store Connect, products mapped, one "premium" entitlement defined.
- [ ] Cloudflare set up in front of Firebase Storage (this is what keeps the bandwidth bill near zero — see TRD §6, it's the single biggest cost driver).
- [ ] Google Cloud Vision API enabled (for moderating uploaded images).
- [ ] **App icon designed and added.** Currently the build config explicitly turns off the icon requirement because no icon asset exists. Apple will reject without one.
- [ ] Resolve the iOS version discrepancy: build config says iOS 16.0, the docs say the client locked iOS 15. These disagree. iOS 16 is much nicer to build against (modern navigation, native bottom sheets). Recommend confirming 16 and updating the docs.

---

### W1 — The keyboard extension
**Size: very large. Realistically 30–40% of all remaining work. This is the product.**

A new target in the Xcode project, `MochiKeyboard`, written in UIKit (not SwiftUI — see below). Everything else in this plan is a support system for this.

**Plain-English framing:** iOS hands your keyboard a tiny box at the bottom of the screen and a very small amount of memory, and says "draw something, and when the user taps, tell me what character to type." Everything a keyboard does — the letters, shift, backspace, autocorrect, emoji, swipe typing — you build from nothing. There is no "keyboard component" Apple gives you.

**1a. The typing engine (non-negotiable, Apple requires it to work)**
- [ ] Key layouts: letters (QWERTY), numbers row, symbols/special-characters row.
- [ ] Shift with three states (off / on / caps-lock via double-tap), backspace with hold-to-repeat-delete, space, return.
- [ ] The **globe key** to switch to the next keyboard — Apple Guideline 4.4.1 *requires* this; rejection if missing.
- [ ] Auto-capitalisation after sentence ends, smart double-space-to-period.
- [ ] Long-press for accented characters (é, ñ, ü…).
- [ ] Correct return-key label per context ("Search" / "Send" / "Go" / "Done").
- [ ] **Must work fully with no network and without Full Access permission.** Also an Apple requirement.

**1b. Autocorrect and predictive text**
- [ ] Autocorrect using Apple's built-in `UITextChecker` (it's available in extensions), plus a suggestion strip above the keys.
- [ ] Learn-as-you-type user dictionary, stored locally in the App Group.
- **Honest flag:** "good enough" autocorrect is a few days. "Feels like Apple's" is months. Set expectations here.

**1c. Swipe / gesture typing**
- [ ] Trace a finger path across keys, resolve it to the most likely word.
- **Honest flag:** this is a research-grade feature. Real implementations use a shape-matching algorithm against a scored dictionary. This is genuinely the hardest single item in the project, and it is on the locked feature list. **Recommend treating this as a candidate to cut from v1 or to buy** (there are commercial SDKs). A bad swipe-typing implementation is worse than none — it makes the keyboard feel broken.

**1d. The theme renderer**
- [ ] Reads the theme recipe (from W2's shared package) and draws the background, key shapes, borders, shadows, and colours.
- [ ] Must be pixel-identical to the in-app preview — which is why it lives in a shared package rather than being written twice.

**1e. Custom fonts as Unicode lookalikes**
- [ ] Real font files cannot be loaded into a keyboard extension. So "Bubble Cute font" means mapping each typed letter to a lookalike Unicode character (`a` → `𝓪`, `b` → `𝓫`). You build a mapping table per font style.
- [ ] Important caveat worth knowing now: these characters are *not* real formatting — they're separate Unicode symbols. They'll look right in most apps, may break in some, and screen readers will read them poorly. This is inherent to the approach, not a bug.

**1f. Effects (CAEmitterLayer particles)**
- [ ] Key-press effects: sparkles, hearts, ripple, neon glow.
- [ ] Ambient background effects: falling stars, floating bubbles, glowing particles.
- [ ] Swipe-trail glow.
- [ ] Aggressive discipline: cap particle counts, reuse a small set of pre-rendered particle images, tear emitters down when the keyboard is dismissed.

**1g. Emoji and stickers panel**
- [ ] Full Unicode emoji keyboard, categorised, with recents and search.
- [ ] Sticker packs, categorised, with search.
- **Blocked:** the source of the stickers has been an open question since the very first planning session. It's now a compliance blocker too — Apple's Sticker Guidelines apply, and they require original or properly-licensed artwork. This needs a decision before the panel is built.

**1h. Memory survival**
This deserves its own line because it is the #1 way keyboard apps fail in production.
- [ ] The extension has roughly a **30–40MB** budget. Exceed it and iOS silently kills your keyboard mid-sentence — the user sees it vanish.
- [ ] Implement cache flushing on the system low-memory warning from day one. The TRD documents a real production case where rendering a large emoji grid accumulated 127MB of hidden glyph cache; flushing on the warning took it to 15MB.
- [ ] Profile actual memory on a real device in Instruments early, not at the end.
- [ ] Use UIKit, not SwiftUI, inside the extension — the TRD cites a documented case of a 6–7MB leak *per keyboard switch* from SwiftUI's closure patterns, which in a 30MB budget kills you within a few switches.

**1i. State sharing with the app**
- [ ] Active theme, keyboard settings (autocorrect/swipe/haptics/sounds), and cached premium status are written by the app into the App Group and read by the keyboard **on each activation** (not live — the two are separate processes and don't sync instantly).
- [ ] No Firebase inside the extension, ever. It doesn't work there and the TRD documents why.

**1j. Full Access**
- [ ] Detect whether the user granted it; degrade gracefully if not.
- [ ] Write the justification text for App Review. Apple scrutinises keyboards heavily — the honest answer is "Full Access is used only to sync themes and check subscription status; we never read or transmit what you type," and the code must actually match that claim.

---

### W2 — The shared rendering package (`MochiShared`)
**Size: medium.**

**Why it exists:** the theme preview in the Create screen and the real keyboard must look identical. If you write the drawing code twice, they will drift apart within a week — someone changes a corner radius in one place and the preview lies to the user about what they're buying. So the models, the App Group constants, and the drawing engine live in one Swift package that both the app and the keyboard import.

- [ ] Create the Swift package, add as a dependency to both targets.
- [ ] Move the theme recipe types into it.
- [ ] Write the renderer once, use it in both places.
- [ ] A snapshot test that fails if the app preview and keyboard render differ.

---

### W3 — The missing screens
**Size: large.**

Five screens from the locked 10-screen spec don't exist, plus several sections inside existing screens.

**W3a. Splash + Onboarding**
- [ ] Animated Mochi logo splash.
- [ ] 3–4 onboarding slides (themes / community / effects).
- [ ] **Keyboard setup instructions** — a guided "Settings → General → Keyboard → Keyboards → Add New Keyboard → Mochi" walkthrough. This is high-stakes: it's where most keyboard apps lose users, because iOS makes enabling a keyboard genuinely confusing.
- [ ] Full Access explainer screen.
- [ ] **Age gate** (neutral date-of-birth entry) — required by Apple Guideline 1.2.1 for apps with user-generated content.
- [ ] No guest mode, per spec — login is required to get past this.

**W3b. Authentication**
- [ ] Email + password sign-up and sign-in.
- [ ] Google Sign-In.
- [ ] Apple Sign-In (**mandatory** the moment Google is offered — Guideline 4.8).
- [ ] Phone number + OTP. Also needs reCAPTCHA SMS defence and an SMS region allowlist turned on *before* launch — otherwise you are exposed to SMS-pumping fraud, which is an active, real attack that can cost thousands.
- [ ] Forgot password / reset email.
- [ ] Terms of Service acceptance checkbox on register.
- [ ] Username selection with live availability check (uses the `reserveUsername` Cloud Function).
- [ ] The first-time profile creation write.

**W3c. Theme Detail**
- [ ] A **live, typable keyboard preview** — the user taps keys and sees the theme react. This depends on W2 being done.
- [ ] Name, description, tappable hashtags, tappable creator credit.
- [ ] Like button with live count.
- [ ] Download / Apply button (this is what actually sets the active theme).
- [ ] Premium badge → opens paywall if locked.
- [ ] Share button (deep link).
- [ ] Report button.

**W3d. Settings**
- [ ] Account: change email, change password, **delete account** (legally required, and it must actually work — calls `onAccountDelete`).
- [ ] Subscription: current plan, upgrade/cancel, **Restore Purchases** (Apple requires this).
- [ ] Keyboard toggles: autocorrect, swipe typing, haptics, key sounds — these write to the App Group so the keyboard picks them up.
- [ ] Notification preferences per category.
- [ ] Language picker (4 languages).
- [ ] Privacy/data preferences.
- [ ] About: version, Terms, Privacy Policy, open-source licences.
- [ ] Logout.

**W3e. Paywall**
- [ ] $2.99/mo and $19.99/yr with "Most Popular" badge, 3-day trial both.
- [ ] Feature list of what premium unlocks.
- [ ] Restore Purchases.
- [ ] Correct legal disclosure of price, renewal terms and trial (Apple rejects paywalls that hide these).
- [ ] Triggered from every locked item across the app.

**W3f. Sections missing inside existing screens**
- [ ] **Wire up the orphaned Search screen** — it's fully built and unreachable. Cheapest win available.
- [ ] Search filters panel (colour, style, category, price) and sort (Popular / New / Top Rated).
- [ ] Weekly **Leaderboard** in Community — doesn't exist in code at all.
- [ ] **Live Wallpapers** section (5 wallpapers) — doesn't exist in code at all.
- [ ] **Curated Collections** browsing — doesn't exist in code at all.
- [ ] **Notifications inbox** — the bell icon in the header has nothing behind it.
- [ ] **Other-user profile variant** — currently there's one Profile screen for "me." Viewing another creator needs Follow/Unfollow, Block, and no edit controls.
- [ ] Report and Block flows with confirmation UI (both are Apple requirements, not nice-to-haves).

---

### W4 — Navigation architecture
**Size: medium.**

There is currently no navigation system whatsoever — no `NavigationStack`, no sheets, no links. The whole app is five screens swapped by a tab bar, plus one boolean for Profile.

- [ ] Introduce a proper navigation stack per tab, and a router so any screen can push any other.
- [ ] **Auth-gated routing**: splash → (first launch? onboarding) → (logged out? auth) → main app. This is a startup state machine, not just a screen order.
- [ ] Modal presentation for Paywall and Theme Detail.
- [ ] **Deep links** — Universal Links so a shared theme URL opens the app directly on that theme, with an App Store fallback web page for people who don't have the app. Requires an `apple-app-site-association` file hosted on a real domain.
- [ ] Notification tap → route to the right screen.
- [ ] Back navigation, state restoration.

---

### W5 — The data layer: replacing mock data with real data
**Size: large, and larger than it appears.**

This is not "swap the array for a query." There are three distinct problems.

**W5a. The models need rebuilding, not connecting.**

The current data containers were designed to feed pixels, not to hold data. Concretely:
- Counts are stored as **pre-formatted text** — `likes: "2.4K"` as a string, because Figma showed "2.4K" next to a bare "128". Real data holds the number `2400` and formats it when drawing. As-is, you can't sort by likes, can't increment a like, can't compare.
- Images are **bundled asset names** (`"theme_forest"`) — pictures shipped inside the app. Real themes have image *URLs* that download from Storage/CDN and need caching, placeholders and failure handling.
- There are **five near-duplicate theme types** (`KeyboardTheme`, `CommunityPost`, `ProfileCreation`, `ProfileLikedTheme`, `CommunityCreator`) that exist because each screen displays a slightly different slice. Against one real `themes` collection, these should collapse into one model plus per-screen view logic.
- The models have **none** of the fields the real schema needs — no `creatorUid`, no `moderationStatus`, no `isPublished`, no timestamps, no config maps, no `Codable` for reading/writing JSON.

So this is a genuine refactor that touches every screen. Worth doing deliberately and early rather than patching around.

**W5b. The plumbing.**
- [ ] Firebase SDK added (Auth, Firestore, Storage, Messaging, App Check).
- [ ] A repository layer per collection — one place that knows how to read/write themes, users, likes, follows. Screens talk to repositories, never to Firestore directly.
- [ ] Paginated feed queries with "load more" — deliberately **not** live listeners on the feed, because an unbounded live listener re-bills you every time any user anywhere likes anything (TRD §6).
- [ ] Live listeners only for small personal state (your own like on the theme you're viewing).
- [ ] Optimistic UI: the heart fills instantly, and rolls back if the write fails.
- [ ] Image caching (Kingfisher or similar) so each device downloads each image roughly once. Combined with Cloudflare and long cache headers, this is what keeps the monthly bill in single digits instead of hundreds.
- [ ] Thumbnail vs full-resolution split — grid cards load ~30–50KB thumbnails, only Theme Detail loads full-res.
- [ ] Firestore offline persistence enabled so the app opens with content on a bad connection.
- [ ] App Check turned on (App Attest) so only your genuine app binary can hit your database, not a script with a scraped key.

**W5c. The content itself — someone has to actually make it.**

The spec says **250 themes at launch** (30% free / 70% premium), 5 live wallpapers, a set of custom fonts, and curated collections. Right now there are roughly 25 theme images in the asset catalogue.

This is not engineering work but it is *blocking launch* work, and it's easy to under-plan:
- [ ] Decide who authors 250 theme recipes and their preview images.
- [ ] Build a seeding script that uploads them to Firestore + Storage (do not hand-enter 250 documents).
- [ ] Author the curated collections.
- [ ] Source the 5 live wallpapers — and note the docs flag that **live wallpapers on an iOS keyboard are technically limited and the approach was never decided**. That's an open technical question, not just an asset question.
- [ ] Resolve the sticker source (see W1g).

---

### W6 — Cloud Functions (the server-side brain)
**Size: medium-large. Currently: zero lines written.**

The `/functions` folder does not exist. These eight functions are the difference between a database and an application, because they do the things a phone must not be trusted to do.

**Why they're necessary, in plain terms:** the phone app can't be trusted to update its own like counts or its own premium status — a modified app could just say "I have premium." So those values are written *only* by server code that the user can't touch. The security rules currently in the repo already assume these functions exist; they block the client from writing those fields. Which means **right now, nothing can update a like count at all.**

- [ ] `onLikeWrite` — when someone likes a theme, update the theme's like count, the creator's total-likes-received, and the current week's leaderboard bucket.
- [ ] `onFollowWrite` — keep follower/following counts correct.
- [ ] `onProfileUpdate` — when someone changes their display name or avatar, copy the new value onto all their published themes. (Theme cards store the creator's name and avatar directly so a feed of 20 cards is 1 read instead of 21. The cost is this sync job. A missed sync is a silently stale avatar, not a crash — so it needs logging or it fails invisibly.)
- [ ] `onThemePublish` — send uploaded background images to Google Vision SafeSearch and approve or reject. This is what makes UGC moderation an actual requirement satisfied rather than a claim.
- [ ] `onReportThreshold` — when a theme hits 5 reports, auto-hide it pending human review.
- [ ] `revenueCatWebhook` — the single most important function. RevenueCat calls it when someone subscribes, renews, cancels or refunds; it verifies the signature and updates that user's premium status. If this is wrong, people either pay and get nothing, or get premium free.
- [ ] `onAccountDelete` — soft-delete the user, anonymise their personal data, revoke their login. Legally required (GDPR + Apple).
- [ ] `checkUsernameAvailable` / `reserveUsername` — Firestore has no "unique column," so uniqueness is enforced by transactionally claiming a document named after the username.
- [ ] **All secrets via `defineSecret()` / Secret Manager, never `functions.config()`** — the old mechanism's backing API is already shut down and deployments using it fail outright after March 2027. Building on it now would mean rewriting under pressure later.
- [ ] Error logging on every function so silent drift gets noticed.
- [ ] Emulator tests for at least the like/follow counters and the RevenueCat webhook.

---

### W7 — Monetization and entitlements
**Size: medium. High risk of subtle bugs.**

- [ ] RevenueCat SDK integrated; identify users by their Firebase UID so purchases follow the account.
- [ ] Products and the "premium" entitlement configured; paywall wired.
- [ ] 3-day free trial handling, including trial-eligibility checks.
- [ ] **Entitlement gating everywhere**: 70% of themes, premium effects, premium fonts, stickers, all 5 live wallpapers, premium key shapes. Free users get 1–2 basic effects only. This is dozens of small checks scattered across every screen — easy to miss one, and each miss is either lost revenue or a confusing lock.
- [ ] Restore Purchases (Apple requirement).
- [ ] Handle expiry / cancellation / refund / billing-retry states in the UI, not just "active vs not."
- [ ] Cache entitlement into the App Group so the **keyboard** knows whether to allow premium effects while offline. The keyboard can't ask the network.
- [ ] Decide the grace behaviour: if someone's subscription lapses while a premium theme is active, does the keyboard fall back to a free theme or keep working? Undecided, and users will hit it.
- [ ] Sandbox testing of the full purchase, renewal, cancel and refund cycle before submission.

---

### W8 — Push notifications
**Size: small-medium.**

- [ ] APNs key uploaded to Firebase; FCM configured; device tokens stored per user.
- [ ] Permission prompt asked at a sensible moment (not on first launch — that's how you get denied).
- [ ] The four notification types from spec: new theme from a followed creator, weekly leaderboard result, feature announcements, pre-trial-end subscription reminder.
- [ ] The first and last need Cloud Functions triggers; the leaderboard one needs a **scheduled** weekly function.
- [ ] Per-category preferences actually respected server-side (a toggle that doesn't work is worse than no toggle).
- [ ] Tapping a notification deep-links to the right place.

---

### W9 — The things that make it feel like a real app
**Size: medium, spread thin, and consistently underestimated.**

Mock data never fails. Real data is slow, absent, or broken — and right now **not a single screen in the app knows how to say "loading," "nothing here yet," or "no connection."** Every screen needs all three.

- [ ] Loading states — skeleton placeholders, not spinners on a blank page.
- [ ] Empty states — "You haven't created any themes yet" with a call to action, for every list.
- [ ] Error states with retry — network failure, permission denied, image failed to load.
- [ ] Pull-to-refresh on feeds.
- [ ] Offline behaviour: cached content readable, writes queued or clearly blocked.
- [ ] **Accessibility** — Dynamic Type support (your text sizes are currently fixed numbers, so a user with large text set will see clipped labels), VoiceOver labels on every icon button, contrast checks, reduce-motion respected for the particle effects. Apple does check this, and it's also just correct.
- [ ] **Localization** — 4 languages including Thai. Every string in the app is currently a hardcoded English literal. They all need extracting into string files, and layouts need to survive longer translations. Thai script in a keyboard extension is specifically flagged in the docs as non-trivial. **The 4 languages have never been confirmed by the client** — this is an open blocker for this workstream specifically.
- [ ] Crashlytics + Firebase Analytics, with a defined set of events so you can tell what users actually do.
- [ ] Hit the stated performance targets: <2s launch, <3s theme download on 4G, no perceptible lag in the live preview.
- [ ] Haptics and sound assets for key presses.

---

### W10 — Moderation and admin tooling
**Size: small-medium. Almost always forgotten until App Review asks.**

Apple's UGC rules don't just require a Report button — they require that reports get *acted on*, with a documented takedown process (the enforcement expectation is ~24 hours).

- [ ] Somebody, every day, needs to see reported themes and approve/reject them. The Firebase console can technically do this but it's painful and error-prone.
- [ ] Minimum viable version: a small password-protected admin web page (Firebase Hosting) listing reported and pending themes with approve/reject buttons.
- [ ] Curate the featured collections and the "For You" selection — that's also an ongoing human job unless it's algorithmic.
- [ ] Write down the takedown process, because Apple may ask.
- [ ] Publish contact information (in-app and on the App Store listing) — a §1.2 requirement.

---

### W11 — Compliance and store submission
**Size: medium. Non-negotiable, and the usual cause of multi-week rejection loops.**

- [ ] App icon (see W0).
- [ ] `PrivacyInfo.xcprivacy` privacy manifest, including the **"Active Keyboard" Required Reason API** declaration — specific to keyboard apps and easy to miss.
- [ ] Privacy Policy and Terms of Service, written and hosted at real URLs. Must state plainly that **keystrokes are not collected**, and must list every third party (Firebase, Apple, RevenueCat, Google Vision, Cloudflare) and cross-border data transfer.
- [ ] Apple Privacy Nutrition Label + Google Play Data Safety form, matching the policy exactly — a mismatch is itself a violation.
- [ ] **Age rating: the 17+/18+ band, not 13+.** Apple overhauled ratings in July 2025; open-publish UGC apps sit in the higher band because content isn't pre-vetted. Getting this wrong costs a resubmission cycle.
- [ ] Stay out of the Kids category despite the cute branding — and expect extra child-appeal scrutiny because of it.
- [ ] Report **and** Block both shipped (§1.2 requires both).
- [ ] Full Access justification text for the reviewer.
- [ ] Apple's Sticker Guidelines compliance (blocked on the sticker-source decision).
- [ ] App Store screenshots for every required device size, description, keywords, subtitle, promotional text.
- [ ] Demo account credentials for the reviewer (there's no guest mode, so review *will* get stuck at login without this — a very common rejection).
- [ ] Export compliance declaration (encryption question).
- [ ] TestFlight beta round with real people on real devices before submitting.

---

### W12 — CI/CD and release engineering
**Size: small.**

- [ ] Path-filtered GitHub Actions workflows (`ios-build`, `android-build`, `functions-deploy`). **Not cosmetic** — GitHub's macOS runners bill at ~10× Linux, so an unfiltered setup burns 10× cost minutes on every Android-only commit.
- [ ] Fastlane for build/sign/upload; pin the version.
- [ ] Archive and upload to TestFlight only on release tags, not every commit.
- [ ] Workload Identity Federation for deploying Functions rather than a stored service-account key.
- [ ] Automated rules tests and Functions tests on every relevant push (the rules tests already exist — keep them running).
- [ ] A documented release checklist.

---

### W13 — Android parity
**Size: large — roughly a second project.**

Android currently has a partial skeleton mirroring some iOS screens. Everything above has an Android equivalent: the IME service (Android's keyboard), all screens, Firebase wiring, Play Billing via RevenueCat, Play Integrity for App Check, and a separate Play Store submission with its own content-rating and data-safety forms.

One piece of good news: Android has no comparable memory ceiling for keyboards, so effects and rich rendering that are risky on iOS are comfortable there.

**Recommendation: ship iOS first, completely, then port.** The spec already says iOS-first.

---

### W14 — Testing
**Size: medium, ongoing.**

Currently: security rules tests (good) and one screenshot UI test. Nothing else.

- [ ] Unit tests for the theme recipe encode/decode round-trip (if this breaks, saved themes corrupt).
- [ ] Unit tests for entitlement logic (if this breaks, you leak premium or block paying users).
- [ ] Cloud Functions tests against the emulator, especially the counters and the RevenueCat webhook.
- [ ] Snapshot test that the in-app preview and the keyboard render identically.
- [ ] Manual test matrix for the keyboard across host apps — Messages, Safari, Notes, WhatsApp, a password field, a search field. Keyboards break in app-specific ways and only real testing finds it.
- [ ] Memory profiling of the keyboard under sustained use and repeated switching.
- [ ] Full purchase-lifecycle testing in sandbox.

---

## Part 4 — Suggested order of work

The ordering matters more than the list, because several items are cheap now and expensive later.

**Phase 0 — Unblock (days)**
W0 in full, plus the theme-recipe format from Part 2. Nothing real can start before this.

**Phase 1 — Make it a real app shell (1–2 weeks)**
Firebase SDK in. Navigation system (W4). Splash/onboarding/auth (W3a, W3b). Auth-gated startup routing.
*Why first:* every security rule in the repo keys off "who is the logged-in user." Until login is real, nothing else can be real.

**Phase 2 — Server brain + real data (2–3 weeks)**
Cloud Functions (W6). Model refactor and repositories (W5a, W5b). Convert screens off mock data one at a time, adding loading/empty/error states as you go rather than in a later sweep.
*Why here:* the rules already forbid clients from writing counters, so the functions must exist before likes/follows can work at all.

**Phase 3 — The keyboard (3–5 weeks, the big one)**
Shared package (W2), then the keyboard extension (W1). Can partly overlap Phase 2 since it doesn't depend on Firestore — only on the theme recipe format and the App Group.
*Do the memory profiling in week 1 of this phase, not at the end.*

**Phase 4 — Money (1 week)**
RevenueCat, paywall, entitlement gating everywhere (W7, W3e).

**Phase 5 — Complete the surface (1–2 weeks)**
Theme Detail, Settings, Leaderboard, Live Wallpapers, Collections, notifications inbox, search filters, other-user profile, report/block flows (W3c, W3d, W3f).

**Phase 6 — Notifications + admin (1 week)**
W8, W10.

**Phase 7 — Content (parallel, but must finish)**
The 250 themes, wallpapers, fonts, collections, stickers, and the seeding script (W5c).

**Phase 8 — Harden (1–2 weeks)**
Offline, accessibility, localization, analytics, crash reporting, performance, testing (W9, W14).

**Phase 9 — Ship iOS (1–2 weeks + review time)**
Compliance artifacts, CI/CD, TestFlight beta, submission (W11, W12). Budget for at least one rejection round; keyboard apps get scrutinised.

**Phase 10 — Android (separate project)**
W13.

---

## Part 5 — Honest flags and open decisions

Things that need a human decision, or that the existing plan under-weights.

### Needs a decision before the relevant work starts
1. **Sticker source** — open since session 1, now a compliance blocker. Original art / licensed packs / user-uploaded all have very different legal work attached. Blocks W1g.
2. **The 4 languages** — never confirmed. Blocks W9's localization.
3. **Swipe typing: build, buy, or cut?** Genuinely the hardest item in the project. My recommendation: cut from v1 or license an SDK.
4. **Live wallpapers on an iOS keyboard** — the docs themselves say the technical approach was never determined. Needs a spike before it's promised.
5. **iOS 15 vs 16** — the build config and the docs disagree. Recommend 16.
6. **Who creates 250 themes?** — this is a content project of its own and it gates launch.
7. **Subscription-lapse behaviour** — what happens to an active premium theme when someone's subscription expires?
8. **Who does daily moderation, post-launch?** — an operational commitment, not a code task.

### Scope reality
The original frame in the docs was 3 weeks / $425 / one developer. Based on what's actually left — a keyboard from scratch, eight server functions, five missing screens, a data-layer refactor, and full store compliance — **that frame doesn't fit the remaining work.** My honest read is 10–16 focused weeks for iOS alone, with swipe typing and the 250-theme content set as the two biggest swing factors. That's not a reason to change anything about the plan; it's just worth knowing before commitments get made on the old numbers.

### Things worth doing early because they're cheap now
- Nail the theme recipe format (Part 2) — saves rewriting four things.
- Refactor the models before adding more screens — every screen you add on the old models is a screen you refactor twice.
- Add loading/error states as you convert each screen, not in a sweep at the end.
- Set the Firebase budget alert on day one.
- Wire up the orphaned Search screen — it's already built.
- Turn on App Check before you have data worth stealing.
- Get the Apple Developer account approved now; it takes 1–2 days and blocks everything downstream.
