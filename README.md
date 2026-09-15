# Mochi

Custom keyboard-theme social app for iOS and Android: themed keyboards, Unicode font styles,
wallpapers, a theme creator and a community feed. Firebase (Auth / Firestore / Storage / Cloud
Functions) backend.

## Start here

- **[`docs/IOS_CURRENT_STATE.md`](docs/IOS_CURRENT_STATE.md)**: where the app stands (as of
  2026-09-15), what's done, what's left, known store blockers, and Android porting guidance.
  **iOS is the reference implementation**; Android is behind it.
- `docs/project-memory/`: product spec, locked decisions, constraints, accounts, TRD summary.
- `docs/keyboard-theme-system.md`: how keyboard themes are modelled, rendered and validated.
- `docs/figma/`: Figma frame exports (the visual ground truth for each screen).

## Layout

| Path | What |
|---|---|
| `ios/` | SwiftUI app + keyboard extension. XcodeGen project, see `ios/README.md` |
| `android/` | Kotlin/Compose app + IME, see `android/README.md` |
| `functions/` | Firebase Cloud Functions (TypeScript), shared by both platforms |
| `firestore/`, `firebase.json` | Firestore rules, indexes and rules tests |
| `scratchpad/` | Python pipeline used to ingest and generate iOS keyboard themes |
| `plans/handoffs/` | Past session handoffs (historical) |

## Build iOS

```bash
brew install xcodegen
cd ios && xcodegen generate && open Mochi.xcodeproj   # scheme: MochiApp
```
