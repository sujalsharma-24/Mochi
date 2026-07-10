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

## What's here (V1 pass, main app UI only — no backend wiring yet)

- `MochiApp/App` — app entry point, root tab container, tab enum
- `MochiApp/DesignSystem` — colors, gradients, typography tokens (pulled from the Figma export)
- `MochiApp/Components` — reusable views: tab bar, theme card, buttons, keyboard preview placeholder
- `MochiApp/Models` + `MochiApp/MockData` — mock data standing in for Firestore until the data layer is wired up
- `MochiApp/Features/{Home,Fonts,Themes,Community,Create}` — the 5 main tabs, built from Figma screens 1-9
- Not yet built: Splash/Onboarding, Auth, standalone Theme Detail, Profile, Settings, Paywall

## Known placeholders

- Theme preview art is a generated vector placeholder (`KeyboardPreviewPlaceholder`), not real art — the
  Figma export didn't include isolated per-theme background assets, only full-screen crops. Swap in real
  images once the client delivers theme art.
- Paywall (not yet built) will use `$2.99/mo` · `$19.99/yr` · 3-day trial via RevenueCat + native
  StoreKit/Play Billing UI — **not** the $199/$999/$1999 + custom UPI/card form shown in the Figma paywall
  frames, which conflicts with the locked pricing decision and would violate Apple's IAP rules (Guideline 3.1.1).
- Bundle ID (`com.mochi.app`) is a placeholder — swap for the client's real reverse-DNS ID before archiving.
