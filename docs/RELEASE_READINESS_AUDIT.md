# Mochi — Production Readiness Audit & Release Roadmap

**Audit date:** 2026-09-15 (revised same day — see §0)
**Scope:** Mobile architecture, backend, DevOps, QA, security, store release engineering
**Repo:** https://github.com/sujalsharma-24/Mochi, branch `master` @ `7d62142`
**Method:** Direct source inspection of the actual pushed repository (via a disposable git
worktree, not the working copy), plus live GitHub Actions CI results via the public REST API.
Nothing was modified. Every claim below cites a real file/line or a real CI run.

---

## 0. This audit replaces an earlier same-day version — read this first

A first pass of this audit was run earlier today against **only the local working copy on this
machine**, which had never been fetched from GitHub. It was 12 commits and roughly 10,000 files
behind `origin/master` — including, critically, an entire iOS keyboard extension with 140 finished
themes that had just been pushed by a second developer (Tanmay, who built the iOS app; see
`docs/project-memory/project_mochi_ios_state.md`) specifically so this audit could happen.

That first pass's headline finding — *"the keyboard cannot be themed, iOS has no keyboard extension
at all"* — is now **wrong for iOS** and still **right for Android**. This version corrects that and
everything downstream of it. If you read the earlier version, treat it as superseded.

I also want to flag, now that I've seen the real repo: your original briefing ("iOS is ahead, use it
as the reference") was correct all along. My first pass disputed that because it was reading a
stale snapshot. Apologies for the churn — this version reflects what's actually on GitHub.

---

## 1. THE HEADLINE FINDING — REVISED

> **iOS solved the hard problem. Android hasn't started it. Neither is submittable yet, for
> different reasons.**

**iOS**: a real keyboard extension exists (`ios/MochiKeyboard/`), sharing a renderer
(`ios/MochiShared/Render/`) with the in-app live preview — what you preview is what types. It ships
**140 built-in themes** (`ios/MochiShared/Themes/`, ~17,800 lines of theme data) across a 7-material
rendering system with WCAG-contrast-solved text colour, plus 6 Unicode-lookalike "font styles".
Tapping Apply writes to a shared App Group container; the keyboard extension reads it — no Full
Access requested, no network access needed. **This was verified building successfully in CI on the
exact commit that's on GitHub right now** (see §1a below), not just claimed in a commit message.

**Android**: unchanged from before. `MochiInputMethodService.kt:39` still hardcodes
`private val theme = MochiThemes.bubbleTea`, and `ThemeDetailScreen.kt`'s "Apply Theme" button is
still a no-op for any unlocked theme. I also checked the 35 files sitting uncommitted in this local
working copy (the "Bubble Tea" pile mentioned in project memory) in case it already solved this —
it doesn't. It adds a second hand-authored theme's art assets and a nicer 9-slice renderer, but the
theme is still hardcoded at line 42. Nothing switches it at runtime.

So: **the product now works, on one platform.** The other platform is where my original finding
still applies in full.

### 1a. Verifying the iOS claim wasn't just taken on faith

I checked GitHub Actions directly (`api.github.com`, no auth needed — public repo):

| Commit | Workflow | Result |
|---|---|---|
| `7d62142` (current `master` HEAD, pushed today) | iOS Screenshots | ✅ **success**, all 12 steps green, including "Build and run screenshot UI test" (25 min, the step that actually compiles both the app and the keyboard extension and runs them in Simulator) |

This is a real, current, green build — not a stale or historical one. One caveat the handoff doc
itself raises and I can't verify from here: **this was never confirmed on a physical device with the
keyboard's Full Access / memory-pressure behaviour under real typing conditions** — only Simulator.
Simulator has no realistic memory ceiling, and the ~30–48MB dirty-memory limit real keyboard
extensions face on-device is exactly the kind of thing that passes in Simulator and fails on a
phone. `docs/IOS_CURRENT_STATE.md` does separately claim a physical-iPhone install happened
2026-09-15 — I can't verify that claim myself (no device access), so it's **NEEDS EXTERNAL
VERIFICATION**: get Sujal's friend (or whoever has been doing device testing) to confirm the
keyboard behaves correctly after 10+ minutes of continuous typing, not just on install.

---

## 2. PHASE 1 — ARCHITECTURE AS BUILT (revised)

**Stack:** Serverless BaaS, no REST/GraphQL layer by design (`docs/TRD.md`).

```
ios/
  MochiApp/       container app (SwiftUI) — 15 feature screens, Data/ repositories (dormant), DesignSystem/
  MochiKeyboard/  the keyboard App Extension (UIKit), 136-line KeyboardViewController
  MochiShared/    compiled into BOTH app and extension: Theme/, Themes/ (140 built-ins), Render/,
                  Input/ (SuggestionEngine, accents, shift state), Layout/, Fonts/
  SharedAssets/   236MB of keyboard background plates + per-key art, extension-only (not the app's
                  22MB Assets.xcassets — the extension can't afford that under its memory ceiling)
  Tools/          validate-themes.sh + a Swift CLI that checks contrast/art legibility, no
                  simulator needed, runs in ~1s — this is a genuinely good piece of tooling
  MochiUITests/   6 XCUITest flow suites + screenshot suite
android/    Kotlin + Jetpack Compose, one hardcoded IME theme — unchanged, see §3
functions/  TypeScript, Node 20, Firebase Functions v2 — 11 functions, shared by both platforms
firestore/  Security rules + indexes + storage rules + rules tests
.github/    2 workflows: iOS screenshots (now macOS 26 / Xcode 26), Firestore rules tests
docs/       IOS_CURRENT_STATE.md (current, read this), PRODUCTION_PLAN.md (2026-07-30, historical
            but still useful for its compliance checklist), IOS_FUNCTIONAL_STATUS.md (historical),
            keyboard-theme-system.md, project-memory/
scratchpad/ Python pipeline that generated the 140 themes' assets from source art (local to the
            other developer's machine; not reproducible from this repo alone)
```

**Identity (temporary, must change before release):** app bundle `com.tanmaysingh.mochi`, keyboard
extension `com.tanmaysingh.mochi.keyboard`, App Group `group.com.tanmaysingh.mochi`, signing team
`6338ADN35J` — all a second developer's **personal** Apple ID, because `com.mochi.app` /
`group.com.mochi.app` were already registered to an unrelated team and Apple won't release them.
This is documented in `project.yml`'s own comments, not hidden. **This has to change together**:
bundle ID, App Group ID (in both `project.yml` and `MochiShared/AppGroup.swift`), and the Firebase
iOS app registration all have to agree, or theme sync between app and keyboard silently breaks.

**Auth, Firestore schema, Cloud Functions, security rules:** all unchanged from my first pass —
these live in `functions/` and `firestore/`, shared cross-platform, and this push didn't touch them
except one small correctness fix (`functions/src/reports.ts`: auto-hidden themes now get
`moderationStatus: 'hidden'` instead of reusing `'pending'`, so a future admin can tell "new draft"
apart from "auto-hidden for reports" — a real, small, good fix).

### Screen parity matrix (revised)

All 15 iOS screens named in the product spec now exist as real files, which changes the shape of
this table from "missing" to "built, some still on local/mock data":

| Screen | iOS | Android |
|---|---|---|
| Splash + Onboarding | ✅ | ✅ |
| Home | ✅ real (local-first) | ✅ real (Firestore) |
| Themes | ✅ real, 140 built-in | ✅ real (Firestore, far fewer themes) |
| Theme Detail | ✅ real, **live typable keyboard preview** | ✅ real, Apply button is a no-op |
| Fonts | ✅ real, 6 Unicode styles, keyboard-applying | ➖ fixed catalog, not keyboard-applying |
| Search | ✅ real, concept-relevance engine | ✅ real, substring filter |
| Create & Publish | ✅ real editor + live preview, local publish | ✅ real, writes to Firestore |
| Community | 🟡 top/latest real-ish, Popular Creators mock | ✅ real |
| Profile (own + other) | 🟡 UI done, no ViewModel, mostly mock | ✅ real |
| Wallpapers | ✅ real, 75 bundled, save-to-Photos | ✅ real, Firestore grid |
| Settings | ✅ real (local), sign-out/delete wired | ✅ real (Firestore) |
| Paywall | 🟡 UI done, billing inert (demo unlock) | 🟡 UI done, billing inert (placeholder key) |
| Leaderboard | 🟡 UI done, mock rankings | ✅ real |
| **Keyboard theming** | ✅ **real, 140 themes, live-typable** | 🔴 **1 hardcoded theme, Apply is a no-op** |
| Push (FCM) | 🔴 not started | 🟡 coded, never device-verified |

Net read: **iOS is ahead on the product's core mechanic and on breadth of content (140 themes vs.
Android's handful). Android is ahead on being connected to a live, shared backend and on Community/
Profile/Leaderboard being real instead of mock.** Neither is a strict superset of the other — this
is a genuine two-way port, not a one-directional "bring X up to Y."

---

## 3. WHAT'S STILL WRONG — UPDATED P0 LIST

Going through my original 16 blockers against what's actually pushed:

### 3.1 ✅ RESOLVED — iOS keyboard extension
Was: "iOS has no keyboard extension target." Now exists, CI-verified building (§1a).

### 3.2 ✅ RESOLVED — App icon
Was: "no app icon on either platform." iOS now has one:
`ios/MochiApp/Assets.xcassets/AppIcon.appiconset/AppIcon-1024.png`, wired via
`ASSETCATALOG_COMPILER_APPICON_NAME: "AppIcon"`. **Android still has none** — `find` for
`*launcher*`/`*mipmap*` in `android/app/src` still returns nothing, and this push didn't touch
`android/` at all. Still a P0 for Android specifically.

### 3.3 ✅ RESOLVED — iOS account deletion reachable
Was: "iOS account deletion unreachable, no Settings screen" (Apple 5.1.1(v) blocker). A real
Settings screen now exists (`ios/MochiApp/Features/Settings/SettingsView.swift`), with a confirm
dialog wired to `AuthRepository.deleteAccount()` → the same `onAccountDelete` Cloud Function
Android uses. **Genuinely fixed.**

### 3.4 🔴 STILL OPEN — Privacy Policy / Terms of Service links are dead on both platforms
Checked again on the new code: `SettingsView.swift` renders both rows through a `row(...)` helper
whose `onTap` parameter defaults to `nil`, and neither call site passes one. Same defect pattern as
Android's `SettingsScreen.kt`. **No privacy policy or ToS document exists anywhere in the repo on
either platform**, still.

### 3.5 🔴 STILL OPEN — iOS Firebase is dormant; Android points at a local emulator
No `GoogleService-Info.plist` in the repo (confirmed again). Every iOS repository is written but
inert; the whole app runs local-first. On Android, `MochiApplication.kt:83` still hardcodes
`USE_LOCAL_EMULATOR = true` with no `buildTypes` to override it in a release build — unchanged,
this push didn't touch `android/`.

### 3.6 🔴 STILL OPEN — Cloud Functions never deployed
`functions/` is unchanged except the one-line `reports.ts` fix. Still emulator-only, per
`docs/ANDROID_FUNCTIONAL_STATUS.md`. Needs Blaze billing + budget alert, then a real deploy.

### 3.7 🔴 STILL OPEN — Payments non-functional on both platforms
Android: `BillingRepository.kt`'s `apiKey` is still the literal placeholder string. iOS: confirmed
`BillingRepository.swift:19` — `let isConfigured = false`, hardcoded, no RevenueCat SDK in
`project.yml`'s packages at all. iOS's Paywall screen has an **"Unlock anyway (demo)"** button that
just flips a local flag — fine for development, would be a serious problem if it ever shipped by
accident.

### 3.8 🔴 STILL OPEN, PLUS A NEW SPECIFIC ITEM — Privacy manifest
No `PrivacyInfo.xcprivacy` exists for either iOS target (confirmed on the new code too). The
2026-07-30 planning doc (`docs/PRODUCTION_PLAN.md`) flags something specific worth carrying
forward: Apple's **"Active Keyboard" Required Reason API** declaration is specific to keyboard
extensions and easy to miss even when a general privacy manifest gets added. Flagging by name so
it isn't rediscovered the hard way during review.

### 3.9 🔴 STILL OPEN — Android identity
`applicationId = "com.Adam.Mochi"` in `android/app/build.gradle.kts` — unchanged, this push never
touched Android. Still immutable-after-publish, still needs fixing before any Play upload.

### 3.10 🔴 STILL OPEN — No crash reporting anywhere
Re-checked against the new code (Crashlytics/Sentry grep across both platforms, zero hits). Same
finding as before, now confirmed against current `ios/`.

### 3.11 🔴 STILL OPEN — No Android release build configuration
`android/app/build.gradle.kts` still has no `buildTypes` block, no signing config, no R8. Unchanged
— this push was iOS-only.

### 3.12 🟡 NEW — iOS has no Block capability
Android has `BlockRepository`; iOS does not (checked `ios/MochiApp/Data/` — no block-related file).
Apple 1.2 (UGC) generally expects both Report and Block. Community's report flow exists on iOS;
blocking a user doesn't.

### 3.13 🟡 NEW — CI checkout cost
`SharedAssets/` alone is 236MB. The iOS CI workflow's own handoff doc admits *"the extra ~300MB of
assets will slow checkout"* — worth watching; if this grows further it risks CI minutes/cost and
checkout timeouts. Not urgent, but flagging before it becomes one.

### 3.14 ℹ️ Scope decision, not a defect — Autocorrect and swipe typing
`SuggestionEngine.swift`'s own doc comment is explicit: it's real `UITextChecker`/`UILexicon`-backed
word completion, deliberately **not** autocorrect (no silent replacement), and there is no swipe
typing anywhere in the codebase. This matches `docs/PRODUCTION_PLAN.md`'s own recommendation from
July ("a half-built autocorrect is worse than none; treat swipe-typing as a cut candidate for v1")
— it looks like that advice was followed rather than the original locked spec. **Worth a one-line
confirmation with the client** that this is an accepted v1 scope cut and not a forgotten feature,
since the original feature list did include both.

### Everything else from my original 16-item list
Unaffected either way (legal docs, Android signing, functions deployment, crash reporting,
payments, store assets) because this push didn't touch the areas they live in. They're carried
forward unchanged above rather than re-derived from scratch.

---

## 4. WHAT'S GENUINELY GOOD HERE — DO NOT REBUILD (expanded)

Everything from the first pass still holds (`firestore.rules`, `functions/src/billing.ts`,
`functions/src/otp.ts`, the Android repository layer). Add to that list, now that I've seen it:

- **The theme rendering architecture** (`MochiShared/Theme/`, `Render/`). One `MochiKeyboardTheme`
  token document drives both the in-app preview and the real keyboard through the literal same
  renderer — the "what you preview is what types" property is exactly right and is the thing most
  keyboard-theme apps get wrong.
- **`Tools/validate-themes.sh`** — a headless Swift CLI that checks every theme's contrast and art
  legibility in about a second, no simulator, runs in CI. This is real engineering discipline for
  what could easily have been "eyeball it and hope."
- **The Full-Access-free architecture.** The extension only ever reads its own App Group container;
  the app writes to it. `RequestsOpenAccess: false` is set and explained in the Info.plist comments.
  This avoids both the scariest permission prompt in keyboard onboarding and a chunk of App Review
  scrutiny — a correct, deliberate tradeoff (it costs them `playInputClick` haptics/sounds, which
  they explicitly decided isn't worth it).
- **The suggestion engine's restraint** — see §3.14. Choosing not to ship silent autocorrect rather
  than shipping a bad one is the right call for a first release.
- **The Unicode-lookalike font approach** with an explicit `normalize()` step so autocap/suggestions
  keep working on styled text, and an honest doc comment that screen readers will read it poorly.
  That's a real, disclosed tradeoff, not a hidden gotcha.

---

## 5. UPDATED OWNERSHIP SPLIT (deltas only — full lists still in §5 of the original scope)

**Developer, now unblocked / changed:**
- ~~Build iOS keyboard extension~~ → done. Remaining iOS keyboard work: swap the identity
  (bundle ID / App Group / team) to the client's own once B1/B9 land, add the Active-Keyboard
  privacy manifest entry, add a Block repository, get real-device (not just Simulator) memory/
  battery verification under sustained typing.
- **Android now needs the mirror of what iOS just built**: real theme switching in
  `MochiInputMethodService` (persist selection, load at runtime, wire "Apply Theme"), ideally
  porting the same theme *data* — the handoff doc itself says the token format is platform-neutral
  and the color/contrast math has a Python mirror (`scratchpad/theme_color.py`) already, so this
  doesn't have to be redesigned from scratch, just ported.
- Wire Privacy Policy / ToS rows on **both** platforms now (was Android-only before).
- Build a `BlockRepository` for iOS.

**Client, unchanged:** Apple enrolment, Play account, Blaze billing, privacy policy + ToS content
and hosting, account-deletion web page, RevenueCat account, final bundle ID / App Group decision,
the autocorrect/swipe-typing scope-cut confirmation (§3.14), and — new — approving which developer
account the final iOS signing identity moves to (the app currently builds under a second
developer's personal Apple ID, same category of issue as Android's placeholder `applicationId`).

---

## 6. REVISED DASHBOARD

```
PROJECT STATUS:            NOT RELEASE READY (materially closer on iOS than this morning)

RELEASE BLOCKERS (P0):     13  (was 16; 3 resolved by this push, 0 new P0s, 2 new P1s)
```

**Resolved since the first pass:** iOS keyboard extension now exists and CI-builds · iOS app icon
now exists · iOS account deletion now reachable in-app.

**Still open, unchanged:** No release build config or signing on Android · Android
`applicationId` still a placeholder · Android has no app icon · Cloud Functions never deployed ·
No privacy policy/ToS on either platform (links dead on both) · No crash reporting on either
platform · Payments non-functional on both (Android: placeholder key; iOS: no SDK, demo unlock) ·
iOS Firebase still dormant · Android's keyboard still can't switch themes (Apply Theme still a
no-op) · No iOS privacy manifest (incl. the keyboard-specific Active Keyboard declaration) · No
Android CI · Zero Android unit tests.

**New since this push:** iOS has no Block capability (P1) · iOS's 236MB asset payload is a CI-cost
watch item, not yet a blocker (P2).

```
APPLE APP STORE:      🟡 Improved. Blocked on: developer account being the client's own (not a
                          personal ID), privacy policy/ToS, privacy manifest, screenshots,
                          RevenueCat product setup. The functional/UX blocker (no keyboard) is gone.
GOOGLE PLAY:          🔴 Unchanged. No console account, no signing config, no release build,
                          placeholder applicationId, no icon, no legal docs, AND the keyboard
                          itself still can't be themed — this is now the platform further behind.
BACKEND/INFRA:        🟡 Unchanged — well-architected, fully undeployed.
PAYMENTS:             🔴 Unchanged on both platforms.
SECURITY:             🟡 Unchanged — same three real gaps (client-side premium gating, OTP volume
                          limits, App Check effectively off in release), still nothing leaked.
QA:                   🟡 Slightly better — iOS CI is green and real (verified via the API, not
                          just trusted). Still no Android tests/CI, still no real-device iOS
                          verification under sustained use.
STORE ASSETS:         🔴 iOS has an icon now. Everything else — screenshots, listing copy,
                          Data Safety / Privacy Nutrition Label — still doesn't exist on either
                          platform.
```

---

## 7. WHAT THIS CHANGES ABOUT THE ROADMAP

The shape of the plan doesn't change — the same 10 phases, the same client actions (B1–B18), the
same external waits (Apple enrolment, Play's closed-testing period) still gate the calendar exactly
as before. What changes is **where the developer effort goes**:

- **Remove** from the critical path: building an iOS keyboard extension from scratch (was
  estimated as the single largest item, ~days 6–8 in the original plan). That's done.
- **Add** to the critical path, roughly matching size-for-size: porting real theme-switching to the
  Android keyboard, using the now-existing iOS theme data/renderer as the spec instead of designing
  it from zero.
- **Everything else** — build config, signing, legal docs, crash reporting, functions deployment,
  store assets, QA — is unchanged in scope and still has to happen on both platforms regardless of
  which one leads on the keyboard.

I'd suggest the next step is either (a) I do a full re-run of the day-by-day plan (§11 of the
original scope) against this corrected picture, or (b) we just proceed straight into the Android
theme-switching port, since that's now the single highest-leverage piece of remaining product work
on either platform. Your call — happy to do either without more back-and-forth.
