# Mochi iOS — Functional Build Status

**Last updated:** 2026-08-24 (end of this session)
**Scope:** Bringing the iOS app to feature parity with the Android app — real Firebase Auth/
Firestore/Storage data and real Cloud Functions logic behind every screen, screen by screen, in the
same order Android went through (see `docs/ANDROID_FUNCTIONAL_STATUS.md`). The Cloud Functions
backend itself (`functions/`) is shared cross-platform and already built — nothing iOS-specific
needed there.

**Explicitly out of scope for this whole effort:** the actual iOS custom keyboard extension (a
separate App Extension target — typing, live theme rendering, Full Access, App Groups, the
~60-70MB memory ceiling). Confirmed with Sujal (2026-08-24): container-app parity only, same
exclusion Android already has for its own IME. Not tracked here.

**Verification constraint:** there is no Mac/Simulator on the dev machine, and Sujal isn't able to
check GitHub's UI himself. Every push to `ios/**` (or the workflow file) triggers
`.github/workflows/ios-screenshots.yml` (a GitHub-hosted macOS runner that compiles the app, runs it
in the Simulator, and screenshots every screen) — that CI run is the only compile/runtime check this
code gets until Sujal's friend tests it on a real device at the end. Checked entirely via GitHub's
public REST API (`api.github.com/repos/sujalsharma-24/Mochi/...`), not the web UI, not `gh` (not
installed in this environment). **A future session should keep doing this** — the repo is public, so
`actions/runs`, `actions/jobs`, and `check-runs`/`annotations` endpoints are all readable without a
token; only raw log/artifact *downloads* need auth ("Must have admin rights to Repository").

---

## At a glance

| Area | Status |
|---|---|
| Firebase iOS SDK + App Container (dormant until `GoogleService-Info.plist` exists) | ✅ Code done |
| Auth (Email, Google, Apple, Phone OTP) | ✅ Code done |
| Onboarding (Splash + 4-page) | ✅ Code done |
| Theme Detail + Theme/Like/Follow repositories, wired to Home | ✅ Code done |
| Fonts, Themes, Community, Create, Profile, Search (tab UI) | 🔄 Real screens exist, still on `MockData` — not yet wired |
| Settings | ⏳ Not built |
| Paywall | ⏳ Not built |
| Wallpapers | ⏳ Not built |
| Leaderboard | ⏳ Not built |
| Push notifications (FCM) | ⏳ Not started |
| App Store prep | ⏳ Not started |
| **CI (`ios-screenshots.yml`)** | 🔴 **Still red as of this session's last push (`724a39f`) — unresolved, see below** |

---

## CI debugging — read this first next session

This ate most of this session. Full trail, so the next session doesn't re-derive it:

1. **First discovery: CI was already broken before this session touched anything.** The last iOS
   commit before this session (`01e3957`, 2026-07-28) was independently confirmed failing with the
   exact same signature (`exit code 70`) this session's own first attempts hit. **This was not
   introduced by the Auth/Theme Detail work** — it's a pre-existing environment issue.
2. Two real Swift bugs were found and fixed by hand-review (no Mac to compile locally, no way to
   download real xcodebuild logs — see the note above): `@ViewBuilder` illegally applied to a stored
   property in `AuthView.swift`'s `AuthTextField`, and a missing `import UIKit` in
   `AuthViewModel.swift`. Fixed in `73c56cf`. Still failed (expected, given point 1).
3. `project.yml` pinned `firebase-ios-sdk` to `from: 10.29.0` — checked against the package's real
   GitHub Releases (not `/tags`, which returns old/prerelease-branch tags in a misleading order and
   caused one wrong intermediate guess at `from: 8.0.0`) — actual current major is **12.18.0**.
   GoogleSignIn-iOS corrected to `from: 9.0.0` (real latest: 9.2.0). Fixed in `37110a2`. Still failed.
4. **Root cause of the original pre-existing failure, found by comparing against the CI's own
   xcresult artifact size** (tiny, ~16.8KB, identical across every failing run regardless of code
   changes — a strong "fails at the same early point every time" signal): the `Pick an available
   iPhone simulator` step matched a simulator **by name only**
   (`xcrun simctl list devices available | grep ...`). Once a runner image ships more than one iOS
   runtime, two simulators can share the exact same name (e.g. two "iPhone 16 Pro" under different
   iOS versions), which makes `xcodebuild -destination "...,name=X"` ambiguous and fails immediately
   — before any real build/test work happens. Fixed in `01be6dd`: picks and matches by **UDID**
   instead (see `.github/workflows/ios-screenshots.yml`). **This is very likely the real fix for the
   pre-existing problem** — the run for `01be6dd` got dramatically further (exit code changed
   **70 → 65**, log grew from ~200 lines to 13,000+, xcresult grew from 17KB to 282KB) before hitting
   a *new*, later-stage failure.
5. Working hypothesis for that new failure (exit 65, i.e. build-or-test failure, not a tooling
   crash): `FirebaseMessaging` installs `UIApplicationDelegate` method-swizzling hooks automatically
   at launch to catch APNs registration. This app has no explicit `AppDelegate` (pure SwiftUI `App`
   lifecycle) and, until `GoogleService-Info.plist` exists, `FirebaseApp.configure()` is never called
   at all — exactly the combination Firebase's own docs warn can crash ("The default Firebase app has
   not been configured"). Disabled via `FirebaseAppDelegateProxyEnabled: false` (`project.yml` +
   `Info.plist`) in `724a39f`. **Result not yet confirmed** — this session ended while that run was
   still in progress (last checked: past step 7, simulator picked successfully, step 8 running).

**Next session: check `https://api.github.com/repos/sujalsharma-24/Mochi/actions/runs?per_page=1&branch=master`
first, get that run's `id`, then `.../actions/runs/{id}/jobs` for step-by-step status.** If step 8
("Build and run screenshot UI test") still fails, compare the new failure's exit code / log line
count / artifact size against this session's numbers (70→65, 200→13,204 lines, 17KB→282KB) to judge
whether it's the *same* failure repeating or a *new* one further downstream — that comparison is what
actually worked this session, not any single guess. **Important lesson learned the hard way**: the
`check-runs` API endpoint got stuck returning a stale cached `in_progress` response for 40+ minutes
at one point this session (WebFetch's own cache, apparently not reliably busted by query params) —
prefer the `actions/runs/{id}/jobs` endpoint for polling, which gave verifiably fresh, incrementing
timestamps every time it was checked, and always double check `completed_at` is non-null before
trusting a "done" reading either way.

---

## ✅ Completed (code-complete; CI not yet green — see above)

### Firebase foundation
`FirebaseEnvironment` (SDK configure, gated — no-ops without a plist so nothing crashes),
`AppContainer` (manual DI, `nil` until configured — holds `authRepository`, `userRepository`,
`themeRepository`, `likeRepository`, `followRepository`), Firebase iOS SDK 12.x + GoogleSignIn-iOS
9.x added via SPM in `project.yml`. Defaults to the **live** Firebase project, not the local
emulator — unlike Android, there's no way for a real device (no Mac in this loop) to reach a
`127.0.0.1` emulator running on this Windows machine. Sign-in-with-Apple entitlement exists on disk
(`MochiApp.entitlements`) but is deliberately **not wired into `project.yml`** yet — needs a real
Apple Developer Team to provision even for Simulator builds, which neither this dev machine nor CI
has. `FirebaseAppDelegateProxyEnabled` is set to `false` (see CI section above).

### Auth
`AuthRepository` + `AuthViewModel` + `AuthView`, matching `android/.../data/AuthRepository.kt`'s
exact backend contract:
- Email/password sign up + sign in + password reset
- Google Sign-In (GoogleSignIn-iOS + Firebase credential)
- **Real Sign in with Apple** (`AppleSignInCoordinator`) — Android only stubs this with a notice
  since it's an iOS-only App Store requirement; iOS builds it for real
- Phone OTP via the existing `sendPhoneOtp`/`verifyPhoneOtp` Cloud Functions callables (same Twilio
  backend Android uses, no separate iOS backend work)
- `onAccountDelete` callable wired (not yet reachable from UI — needs Settings)

### Onboarding
`SplashView` + 4-page `OnboardingView`, ported from `android/.../features/onboarding/
OnboardingScreen.kt` (no Figma source exists for this screen on either platform — Android designed
it first). Reuses Android's real client-delivered onboarding artwork (copied into the iOS asset
catalog) rather than the 3 mismatched placeholder images that were already sitting in
`Assets.xcassets` unused.

### App-level flow gate
`AppRootView`: Splash → Onboarding → Auth → Main, mirroring `android/.../ui/AppNavHost.kt`. Skips
straight to the existing tab UI (today's behavior, unchanged) whenever `AppContainer.shared` is nil
— keeps the app (and CI) behaving exactly as before with zero special-casing until the plist lands.

### Theme Detail + Theme/Like/Follow repositories — now wired to Home
`ThemeDetailView` + `ThemeDetailViewModel`, porting `android/.../features/themedetail/
ThemeDetailScreen.kt` (no Figma source exists for this screen on either platform). New
`ThemeDocument` (Firestore schema mirror), `ThemeRepository`, `LikeRepository`, `FollowRepository` —
same query shapes and document contracts as their Android equivalents. `KeyboardTheme` gained
`description`/`creatorUid`/`downloadCount` fields (defaulted, so every existing `MockData` call site
kept compiling unchanged). `isUserPremium` is hardcoded `false` (no Paywall/RevenueCat SDK on iOS
yet) — a documented gap, matching how Android's own Theme Detail shipped before its Paywall slice.

**Home is now real and wired end-to-end**: new `HomeViewModel` (Loading/Data/Empty/Error, same
MockData-fallback convention as Android's `HomeViewModel.kt` — Loading/Error silently show MockData
since no spinner/error UI exists anywhere in Home's Figma export; only genuine emptiness shows a real
empty row), tapping any Home theme card now pushes the real `ThemeDetailView` (`RootView` gained a
`selectedTheme` overlay state, same pattern `showProfile` already used, tab bar hides while it's up).

**`RootView.swift` note**: this file already had unrelated, pre-existing *uncommitted* work sitting
in it before this session started (Search-screen navigation wiring — not this effort's work). To
avoid entangling the two, `RootView.swift` was reconstructed by hand as "HEAD plus only this
session's Theme Detail diff" before committing, so that pre-existing Search work (also present in
`ThemesView.swift`, `SearchView.swift`, `Components/ThemeArt.swift`, `MochiUITests/
ScreenshotUITests.swift`) is **still sitting untouched and uncommitted**, exactly as found. A future
session touching any of these files again will need to make a real call about whether to keep
excluding that work indefinitely (increasingly impractical — every future RootView.swift edit will
re-hit this same entanglement) or fold it in; not decided this session.

---

## ⏳ Pending, in planned order

1. **Get CI green** — see debugging section above. Blocks confidently trusting any further code
   without hand-review-only verification.
2. **Themes, Fonts, Community, Search, Profile, Create & Publish** — real screens exist, still 100%
   `MockData`. Each needs its own ViewModel wired to the repositories that now exist
   (`ThemeRepository`/`LikeRepository`/`FollowRepository`) plus new ones as needed
   (`CreateRepository`, `StorageRepository`, `UserRepository` extensions, etc., mirrored from
   `android/.../data/`), one screen at a time. Wiring each screen's theme cards to navigate into the
   now-built Theme Detail is part of this step, not separate (Home already did this as the template).
3. **Settings** — doesn't exist on iOS yet. Needed for: sign-out, delete-account (repository call
   already exists), notification toggle, keyboard-preference toggles (persist only, no IME to
   enforce them — matches Android's own documented scope limit).
4. **Paywall** — doesn't exist on iOS yet. Needs the RevenueCat iOS SDK (not yet added) +
   entitlement gating on Theme Detail / Profile, same pattern as Android's `BillingRepository`.
5. **Wallpapers** — doesn't exist on iOS yet.
6. **Leaderboard** — doesn't exist on iOS yet (Android-only screen currently; port if/when the rest
   of Community is real).
7. **Push notifications (FCM)** — `FirebaseMessaging` SPM product already added (proxy disabled, see
   CI section — manual APNs token forwarding will be needed here); no notification handling,
   permission request, or token-capture-on-launch built yet (only sign-in-time token sync exists so
   far, in `AuthRepository.syncFcmToken`).
8. **App Store prep** — not started; real device verification (Sujal's friend) comes before any
   store submission concern.

---

## Known blockers (need Sujal)

| Blocker | Blocks |
|---|---|
| Register an iOS app for `mochi-940bd` in Firebase Console (bundle ID `com.mochi.app`) and send `GoogleService-Info.plist` | Every real backend feature — the whole app runs on `MockData` until this exists |
| Enable Google Sign-In for the iOS platform in Firebase Console, then copy the resulting `REVERSED_CLIENT_ID` into `project.yml` + `MochiApp/App/Info.plist` (search `REPLACE_WITH_IOS_REVERSED_CLIENT_ID`) | Google Sign-In's OAuth redirect (everything else works without this) |
| Apple Developer Program enrollment + provisioning | Sign in with Apple actually authenticating on a real device (harmless on Simulator/CI either way); also needed before re-adding the entitlement to `project.yml` |
| RevenueCat iOS API key | Real Paywall purchases (same blocker Android has) |

## Other outstanding items

- **Pre-existing uncommitted Search-navigation work** (not part of this effort) is sitting in
  `ios/MochiApp/App/RootView.swift`, `Components/ThemeArt.swift`, `Features/Search/SearchView.swift`,
  `Features/Themes/ThemesView.swift`, `MochiUITests/ScreenshotUITests.swift` since before this
  effort started. Left untouched per Sujal's instruction (2026-08-24) — see the RootView.swift note
  above for why this is getting harder to keep doing indefinitely.
- `ScreenshotUITests.swift` has no way to skip past the new Auth gate yet — not needed until
  `AppContainer.shared` is actually non-nil (the plist exists), since until then `AppRootView` skips
  straight past it anyway.
- The 3 old unused onboarding image assets (`onboarding_community`, `onboarding_customize`,
  `onboarding_welcome`) are still sitting in `Assets.xcassets`, superseded by the 4 real ones now in
  use. Left in place rather than deleted — not this effort's call to make.
