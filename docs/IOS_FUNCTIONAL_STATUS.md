# Mochi iOS — Functional Build Status

**Last updated:** 2026-08-24
**Scope:** Bringing the iOS app to feature parity with the Android app — real Firebase Auth/
Firestore/Storage data and real Cloud Functions logic behind every screen, screen by screen, in the
same order Android went through (see `docs/ANDROID_FUNCTIONAL_STATUS.md`). The Cloud Functions
backend itself (`functions/`) is shared cross-platform and already built — nothing iOS-specific
needed there.

**Explicitly out of scope for this whole effort:** the actual iOS custom keyboard extension (a
separate App Extension target — typing, live theme rendering, Full Access, App Groups, the
~60-70MB memory ceiling). Confirmed with Sujal (2026-08-24): container-app parity only, same
exclusion Android already has for its own IME. Not tracked here.

**Verification constraint:** there is no Mac/Simulator on the dev machine. Every push to `ios/**`
triggers `.github/workflows/ios-screenshots.yml` (a GitHub-hosted macOS runner that compiles the
app, runs it in the Simulator, and screenshots every screen) — that CI run is the only compile
check this code gets until Sujal's friend tests it on a real device at the end. Checked via
GitHub's public REST API (`api.github.com/repos/.../actions/runs`), not the web UI.

---

## At a glance

| Area | Status |
|---|---|
| Firebase iOS SDK + App Container (dormant until `GoogleService-Info.plist` exists) | ✅ Done |
| Auth (Email, Google, Apple, Phone OTP) | ✅ Code done — CI compile status uncertain, see below |
| Onboarding (Splash + 4-page) | ✅ Done |
| Theme Detail + Theme/Like/Follow repositories | ✅ Code done, not yet wired into navigation |
| Home, Fonts, Themes, Community, Create, Profile, Search (tab UI) | 🔄 Real screens exist, still on `MockData` — not yet wired |
| Settings | ⏳ Not built |
| Paywall | ⏳ Not built |
| Wallpapers | ⏳ Not built |
| Leaderboard | ⏳ Not built |
| Push notifications (FCM) | ⏳ Not started |
| App Store prep | ⏳ Not started |

**CI status note (2026-08-24):** the first two pushes (`ca36b2d`, `73c56cf`) both failed CI
(`exit code 70`, no compiler-level detail available — see Verification constraint above). Found by
hand-review: a real `@ViewBuilder`-on-stored-property mistake and a missing `import UIKit`, both
fixed in `73c56cf`. That push *still* failed, which led to the actual likely root cause: `project.yml`
pinned `firebase-ios-sdk` to `from: 10.29.0`, a version that doesn't exist — checked properly via
each package's `/releases` API this time (not `/tags`, which returned misleadingly-sorted old data
and caused one wrong intermediate guess), giving the real current majors: firebase-ios-sdk 12.18.0,
GoogleSignIn-iOS 9.2.0. Fixed in `37110a2`. **Not yet confirmed green** — polling CI for that push as
this doc is being written; update this note once it resolves either way.

---

## ✅ Completed

### Firebase foundation
`FirebaseEnvironment` (SDK configure, gated — no-ops without a plist so nothing crashes),
`AppContainer` (manual DI, `nil` until configured), Firebase iOS SDK + GoogleSignIn-iOS added via
SPM in `project.yml`, Sign-in-with-Apple entitlement declared. Defaults to the **live** Firebase
project, not the local emulator — unlike Android, there's no way for a real device (no Mac in this
loop) to reach a `127.0.0.1` emulator running on this Windows machine.

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
— keeps CI green with zero special-casing until the plist lands.

### Theme Detail + Theme/Like/Follow repositories
`ThemeDetailView` + `ThemeDetailViewModel`, porting `android/.../features/themedetail/
ThemeDetailScreen.kt` (no Figma source exists for this screen on either platform — Android designed
it from the locked feature spec, this follows Android's version rather than inventing a second one).
New `ThemeDocument` (Firestore schema mirror), `ThemeRepository`, `LikeRepository`,
`FollowRepository` — same query shapes and document contracts as their Android equivalents.
`KeyboardTheme` gained `description`/`creatorUid`/`downloadCount` fields (defaulted, so every
existing `MockData` call site kept compiling unchanged). **Not yet wired into navigation** — tapping
a theme card anywhere still does nothing; that wiring is bundled into whichever screen's own slice
needs it next (Home/Themes), not built in isolation. `isUserPremium` is hardcoded `false` (no
Paywall/RevenueCat SDK on iOS yet) — a documented gap, not an oversight, matching how Android's own
Theme Detail shipped before its Paywall slice existed.

---

## 🔄 In progress / next up

Nothing actively in progress between sessions — the next slice (not yet started) is whichever
screen comes next in the queue below.

---

## ⏳ Pending, in planned order

Same screen order Android's `WA4` went through, adjusted for what already exists as UI-only on iOS:

1. **Themes, Home, Community, Search, Profile, Create & Publish** — real screens exist, still 100%
   `MockData`. Each needs its own ViewModel wired to the repositories that now exist
   (`ThemeRepository`/`LikeRepository`/`FollowRepository`) plus new ones as needed
   (`CreateRepository`, `StorageRepository`, `UserRepository` extensions, etc., mirrored from
   `android/.../data/`), one screen at a time, verified against CI each time. Wiring a screen's theme
   cards to actually navigate into the now-built Theme Detail is part of this step, not separate.
2. **Settings** — doesn't exist on iOS yet. Needed for: sign-out, delete-account (repository call
   already exists), notification toggle, keyboard-preference toggles (persist only, no IME to
   enforce them — matches Android's own documented scope limit).
3. **Paywall** — doesn't exist on iOS yet. Needs the RevenueCat iOS SDK (not yet added) +
   entitlement gating on Theme Detail / Profile, same pattern as Android's `BillingRepository`.
4. **Wallpapers** — doesn't exist on iOS yet.
5. **Leaderboard** — doesn't exist on iOS yet (Android-only screen currently; port if/when the rest
   of Community is real).
6. **Push notifications (FCM)** — `FirebaseMessaging` SPM product already added; no notification
   handling, permission request, or token-capture-on-launch built yet (only sign-in-time token sync
   exists so far, in `AuthRepository.syncFcmToken`).
7. **App Store prep** — not started; lower priority since this is the platform the client cares
   about shipping to, but real device verification (Sujal's friend) comes before any store
   submission concern.

---

## Known blockers (need Sujal)

| Blocker | Blocks |
|---|---|
| Register an iOS app for `mochi-940bd` in Firebase Console (bundle ID `com.mochi.app`) and send `GoogleService-Info.plist` | Every real backend feature — the whole app runs on `MockData` until this exists |
| Enable Google Sign-In for the iOS platform in Firebase Console, then copy the resulting `REVERSED_CLIENT_ID` into `project.yml` + `MochiApp/App/Info.plist` (search `REPLACE_WITH_IOS_REVERSED_CLIENT_ID`) | Google Sign-In's OAuth redirect (everything else works without this) |
| Apple Developer Program enrollment + provisioning | Sign in with Apple actually authenticating on a real device (harmless on Simulator/CI either way) |
| RevenueCat iOS API key | Real Paywall purchases (same blocker Android has) |

## Other outstanding items

- **Pre-existing uncommitted Search-navigation work** (not part of this effort) is sitting in
  `ios/MochiApp/App/RootView.swift`, `Components/ThemeArt.swift`, `Features/Search/SearchView.swift`,
  `Features/Themes/ThemesView.swift`, `MochiUITests/ScreenshotUITests.swift` since before this
  effort started. Left untouched per Sujal's instruction (2026-08-24).
- `ScreenshotUITests.swift` has no way to skip past the new Auth gate yet — not needed until
  `AppContainer.shared` is actually non-nil (the plist exists), since until then `AppRootView` skips
  straight past it anyway.
- The 3 old unused onboarding image assets (`onboarding_community`, `onboarding_customize`,
  `onboarding_welcome`) are still sitting in `Assets.xcassets`, superseded by the 4 real ones now in
  use. Left in place rather than deleted — not this effort's call to make.
