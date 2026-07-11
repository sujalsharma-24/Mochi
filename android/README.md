# Mochi Android — Dev Setup

Unlike iOS, Android tooling runs natively on Windows for free — this is now the primary surface
for previewing UI while building, since there's no Mac available (see `ios/README.md` for the
iOS side, which relies on CI screenshots instead).

## One-time setup

1. Install [Android Studio](https://developer.android.com/studio) (free). This bundles the JDK,
   Android SDK, and emulator — nothing else to install separately.
2. Open Android Studio → **Open** → select the `android/` folder in this repo.
3. Let Gradle sync run (first sync downloads SDK platform 35 + build tools — takes a few minutes,
   one-time cost). If it prompts to create a Gradle wrapper, accept — the wrapper jar isn't
   committed to this repo, only `gradle-wrapper.properties` (pins the Gradle version), so Android
   Studio regenerates it locally.

## Previewing UI — two ways, both free

- **Compose Preview (fastest, no emulator needed):** open any file with an `@Preview` composable
  (e.g. `HomeScreen.kt`) and use the **Split** or **Design** view in the editor. Renders in
  seconds, updates as you type. This is the main iteration loop — every screen should have at
  least one `@Preview` function.
- **Emulator (for real interaction — typing, scrolling, tapping):** Android Studio → **Device
  Manager** → create a virtual device (any recent Pixel + latest system image) → hit Run. Slower
  to boot than Preview but gives a real running app.

## What's here (v1 pass — ported from the iOS SwiftUI build, kept in sync manually for now)

- `app/src/main/java/com/mochi/app/designsystem` — colors, gradients, typography tokens (mirrors
  `ios/MochiApp/DesignSystem`)
- `app/src/main/java/com/mochi/app/components` — reusable composables: tab bar, theme card,
  buttons, keyboard preview placeholder
- `app/src/main/java/com/mochi/app/model` + `mockdata` — same placeholder data as iOS, standing in
  for Firestore
- `app/src/main/java/com/mochi/app/features/home` — Home/Keyboard tab, fully ported with a
  `@Preview`
- `app/src/main/java/com/mochi/app/ui/RootScreen.kt` — tab container; Fonts/Themes/Community/Create
  tabs are still placeholder screens ("coming soon") — not yet ported

## Known placeholders

- Same as iOS: `KeyboardPreviewPlaceholder` is a generated gradient/grid, not real theme art.
- Typography falls back to the system font — iOS uses SF Rounded, Compose has no rounded family
  built in. Swap in a Google Fonts rounded family (Baloo 2 / Fredoka) later to match Figma's look.
- Design tokens (hex colors) were converted from the iOS RGB values by hand — expect ~1-value
  rounding drift per channel, not visible in practice but worth a pixel-check against Figma later.

## Keeping this in sync with iOS

There's no shared token/model source yet (see TRD's planned `shared` Kotlin module, not scaffolded
here) — for now, when a design token or piece of mock data changes on one platform, mirror it on
the other by hand. Worth automating once both platforms have more screens built out.
