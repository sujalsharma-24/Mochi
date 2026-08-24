# Mochi iOS — Dev Setup

This project was authored without Xcode (Windows dev machine), so there's no committed `.xcodeproj` —
`project.yml` (XcodeGen spec) generates it instead. One-time setup on your Mac:

```
brew install xcodegen
cd ios
xcodegen generate
open Mochi.xcodeproj
```

Re-run `xcodegen generate` any time `project.yml` changes or a new file is added outside Xcode.

## Previewing without a Mac

No Mac is available on the dev side, so there's no local Xcode/Simulator preview loop. Instead,
`.github/workflows/ios-screenshots.yml` builds the app on a GitHub-hosted macOS runner on every push to
`ios/**`, runs `MochiUITests/ScreenshotUITests.swift` (walks each tab, screenshots it), and uploads the
PNGs as a build artifact called `mochi-ios-screenshots` — download it from the workflow run's Summary page
to see what changed. Takes a few minutes per push, not instant. Add a screenshot call for any new screen
in that test file so it shows up automatically.

## What's here

- `MochiApp/App` — app entry point (`MochiApp.swift`, configures Firebase at launch),
  `AppRootView` (Splash → Onboarding → Auth → Main flow gate), root tab container, tab enum
- `MochiApp/DesignSystem` — colors, gradients, typography tokens (pulled from the Figma export)
- `MochiApp/Components` — reusable views: tab bar, theme card, buttons, keyboard preview placeholder
- `MochiApp/Assets.xcassets` — real per-theme artwork, font previews, avatars, screen backgrounds, tab
  icons, onboarding illustrations, and rank badges delivered by the client
- `MochiApp/Models` + `MochiApp/MockData` — mock data standing in for Firestore on any screen not yet
  wired to the real backend
- `MochiApp/Data` — the real backend layer: `FirebaseEnvironment` (SDK configure + emulator/live
  routing), `AppContainer` (manual DI, `nil` until a real `GoogleService-Info.plist` exists — see
  below), `AuthRepository`/`UserRepository`, mirroring android/.../data/'s equivalents against the
  same Cloud Functions backend (`functions/`, shared cross-platform, nothing iOS-specific to build
  there)
- `MochiApp/Features/{Home,Fonts,Themes,Community,Create,Profile,Search,Auth,Onboarding}` — Auth
  (Email/Google/Apple/Phone-OTP) and Onboarding are real and wired to `AppContainer`; the rest are
  still on `MockData` pending their own slice, same order Android went through (see
  [[project-mochi-android-functional-plan]] for that precedent)
- Not yet built: standalone Theme Detail, Settings, Paywall, Wallpapers, Leaderboard, push
  notifications — same screens Android added after its own Auth slice

## Turning on the real backend

Auth/Onboarding compile and are wired for real, but stay dormant (the app behaves exactly as before —
straight into the tab UI on mock data) until **`ios/MochiApp/GoogleService-Info.plist` exists in this
repo**, the iOS equivalent of `android/app/google-services.json`. To produce it:

1. In the Firebase console for project `mochi-940bd`, add an iOS app with bundle ID `com.mochi.app`
   (matches `project.yml`'s current placeholder — swap both together later if the client's real bundle
   ID differs).
2. Enable the Google Sign-In provider for iOS (Authentication → Sign-in method) if not already on;
   this mints a distinct iOS OAuth client from Android's.
3. Download `GoogleService-Info.plist` and add it at `ios/MochiApp/GoogleService-Info.plist`.
4. Copy that file's `REVERSED_CLIENT_ID` value into `project.yml`'s
   `CFBundleURLTypes.CFBundleURLSchemes` entry (search `REPLACE_WITH_IOS_REVERSED_CLIENT_ID`) and into
   the same placeholder in the committed `MochiApp/App/Info.plist` — Google Sign-In's OAuth redirect
   silently dead-ends in Safari without this, everything else still works.
5. Sign in with Apple additionally needs the Apple Developer Program capability actually provisioned
   (the entitlement is already declared in `project.yml`/`MochiApp.entitlements`) — harmless on the
   Simulator/CI build either way, but won't authenticate on a real device until that's set up.

Once the plist lands, `ScreenshotUITests.swift` will also need a way to skip past the new Auth gate
(there's no scripted way to complete real sign-in from a UI test) — not done yet since there was
nothing to skip past before this.

## Known placeholders

- Theme/font preview art now comes from `Assets.xcassets` for the themes and fonts the client has
  delivered art for. `KeyboardPreviewPlaceholder` (a generated vector placeholder) is only a fallback for
  themes still missing from that catalog — see `knownThemeArt` in `Components/ThemeArt.swift`. Add a
  theme's asset name to that set once its art lands in the catalog.
- Paywall (not yet built) will use `$2.99/mo` · `$19.99/yr` · 3-day trial via RevenueCat + native
  StoreKit/Play Billing UI — **not** the $199/$999/$1999 + custom UPI/card form shown in the Figma paywall
  frames, which conflicts with the locked pricing decision and would violate Apple's IAP rules (Guideline 3.1.1).
- Bundle ID (`com.mochi.app`) is a placeholder — swap for the client's real reverse-DNS ID before archiving.
