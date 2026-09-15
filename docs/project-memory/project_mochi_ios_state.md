---
name: project-mochi-ios-state
description: "Where the iOS app stands at the 2026-09-15 handover: iOS is the reference implementation, local-first (Firebase dormant), 140 keyboard themes, all 15 screens built"
metadata:
  type: project
---

# Mochi iOS — state at handover (2026-09-15)

Full detail: `docs/IOS_CURRENT_STATE.md`. This note is the memory-index summary.

**Who did what.** Sujal built the Android app and the shared Firebase backend first. From
~2026-07-25 Tanmay took over iOS: Figma pixel-parity UI, the keyboard extension + theme system, and
Android-parity screens. On 2026-09-15 everything was pushed so a friend could audit the project
and take over the remaining launch work (App Store + Play Store).

**Why:** iOS is now further along than Android on the product itself (keyboard themes, font
styles, live preview, search, editor, wallpapers), so it is the reference and Android gets
ported up to it.

**How to apply:**
- Treat `docs/IOS_CURRENT_STATE.md` as the current truth. `docs/IOS_FUNCTIONAL_STATUS.md`,
  `plans/handoffs/*` and the session log below are historical.
- iOS runs **local-first**: no `GoogleService-Info.plist`, so `AppContainer.shared == nil` and all
  repositories are dormant. Likes, downloads, drafts, applied theme and font persist on device.
- Bundle IDs / App Group are `com.tanmaysingh.mochi*` and the team is Tanmay's personal one,
  because Apple refused `com.mochi.app` (taken by another team). They must be replaced with the
  client's own before release; change `ios/project.yml` and `ios/MochiShared/AppGroup.swift`
  together.
- Keyboard: 140 built-in themes (batches 1–8), 7-material system, validator
  `ios/Tools/validate-themes.sh`. Fonts are 6 Unicode lookalike styles, not typefaces.
- Billing is an inert stub (demo unlock). Pricing stays locked at $2.99/mo · $19.99/yr · 3-day trial.

Related: [[project-mochi-decisions]] · [[project-mochi-constraints]] · [[project-mochi-accounts]]
