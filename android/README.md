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

## Backend (Firebase Local Emulator Suite)

The real Firebase project exists now (`android/app/google-services.json`, project `mochi-940bd`,
applicationId `com.Adam.Mochi` — a placeholder package name from whoever first registered the app
in Firebase Console; see `app/build.gradle.kts` for why `namespace` and `applicationId` differ).
`MochiApplication.kt`'s `USE_LOCAL_EMULATOR` flag still routes Auth/Firestore to the Firebase Local
Emulator Suite for day-to-day dev (flip to `false` to hit the live project directly). To test
Auth/Firestore-backed screens end-to-end against the emulator:

1. From the repo root: `firebase emulators:start --project mochi-940bd` (uses the root
   `firebase.json`; the project id must match `google-services.json` because the emulator suite
   runs in `singleProjectMode`). Leave this running; the emulator UI is at `http://localhost:4000`.
2. One-time per install, with the phone connected: `adb reverse tcp:9099 tcp:9099` and
   `adb reverse tcp:8080 tcp:8080` — this lets the phone reach the emulator on your machine via
   `127.0.0.1`. (An AVD emulator wouldn't need this — it would use `10.0.2.2` instead — but the
   phone is the primary test device for this project, see `docs/project-memory/project_mochi_devenv.md`.)
   Reconnecting the phone (or restarting adb) drops the reverse tunnel — redo this step whenever
   `adb devices` had to be reset.
3. Seed some real theme data so Home isn't empty: `cd firestore/tests && npm install && npm run seed`
   (only needs to be run once per emulator session — data disappears when the emulator stops unless
   `--import`/`--export-on-exit` flags are added later).
4. `gradlew installDebug`, launch the app, sign up a real test account through the Auth screen —
   Home should now show the seeded themes instead of `MockData`.

Email/Password, Google, and Phone OTP are all wired to real Firebase Auth now. Apple stays a stub —
it's an iOS-only App Store requirement, not applicable on Android.

- **Phone OTP** works against the emulator with no extra setup — no real SMS, no billing plan
  needed. Send a code to any number, then look up the code the emulator generated via the Auth
  Emulator UI (`http://127.0.0.1:4000/auth`) to complete verification.
- **Google Sign-In** needs one manual step before it'll do anything besides show a clear "not
  configured yet" message: `android/app/src/main/java/com/mochi/keyboard/data/AuthRepository.kt`
  has a `googleWebClientId` placeholder near the top. Enable the Google provider in Firebase
  Console (Authentication → Sign-in method → Google → Enable) — this auto-creates the required Web
  Client ID — then paste it in (or re-download `google-services.json`, which will then contain a
  `"client_type": 3` entry with the same value, and pull the ID from there instead).

## Keeping this in sync with iOS

There's no shared token/model source yet (see TRD's planned `shared` Kotlin module, not scaffolded
here) — for now, when a design token or piece of mock data changes on one platform, mirror it on
the other by hand. Worth automating once both platforms have more screens built out.
