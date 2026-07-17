---
name: project-mochi-devenv
description: "Dev environment constraints for Mochi: no Mac, Windows-only, and the resulting preview workflow split between iOS and Android"
metadata:
  node_type: memory
  type: project
  originSessionId: f7b11015-d7e5-40a3-9089-fe2f54d48fee
---

# Mochi — Dev Environment & Preview Workflow

Sujal has **no Mac and does not want to pay for one** (ruled out cloud Mac rental, e.g. Scaleway/MacinCloud, explicitly on cost grounds). Windows-only local machine.

## Consequence: split preview workflow per platform

- **iOS:** no local Xcode/Simulator possible at all — not a workaround gap, a hard platform limitation (Apple doesn't ship Xcode for Windows). Preview happens via CI only: `.github/workflows/ios-screenshots.yml` builds on a GitHub-hosted macOS runner and runs `ios/MochiUITests/ScreenshotUITests.swift`, which walks each tab and dumps screenshots as a build artifact (`mochi-ios-screenshots`). Feedback loop is minutes, not instant. GitHub repo: https://github.com/sujalsharma-24/Mochi.
- **Android:** runs natively on Windows for free via Android Studio (JDK + SDK + emulator all bundled, one download). This is now the **primary UI-iteration surface** — Compose `@Preview` gives near-instant feedback with no emulator boot needed. See `android/README.md`.

## Practical build order implication

Because Android can be previewed live and iOS can't, new screens should generally be prototyped/iterated in Compose first (fast feedback), then ported to SwiftUI once the layout is validated — reducing blind iteration on the iOS side. This is a *build-order* convenience, not a reversal of locked decision #12 (iOS ships to the App Store first, then Android) — that's about release order and is unchanged.

## Android now also verified on a real physical device

Beyond Compose `@Preview`, Sujal's physical Android phone (model V2207) has been confirmed working as a real end-to-end test device: USB debugging enabled, `adb`/`gradlew installDebug` install-and-launch flow verified, full click-through navigation confirmed (Splash → Onboarding → Auth → 5-tab app). This is faster and more reliable than setting up an emulator from scratch — an emulator setup attempt the same session (SDK cmdline-tools + system image download) took many minutes and was abandoned in favor of the phone. SDK components for an emulator ARE already installed (`platforms;android-34`, `system-images;android-34;google_apis;x86_64`, `emulator`), just missing an actual AVD — treat the emulator as a fallback-only path if the phone isn't available, not the default.

**Update (Session 8, corrects the paragraph above):** the "defer phone verification" stance did not hold — by Session 8, live-phone verification via a real `gradlew installDebug` + `adb shell screencap` loop became the *primary* iteration method for a full session, not `@Preview`. This machine can run the whole build→install→launch→screenshot cycle directly (see commands below); default to this for Android UI work going forward rather than assuming `@Preview` is preferred. The phone's `adb` connection is flaky and drops often — re-check `adb devices` before each build/install, and always confirm the foreground app via `adb shell dumpsys window | Select-String mCurrentFocus` before screenshotting or sending any tap (a blind coordinate tap once opened WhatsApp instead of the app mid-session — see [[project-mochi-learnings]] Session 8 entry). Useful commands: launch — `adb shell am start -n com.mochi.app/.MainActivity`; screenshot — `adb shell screencap -p /sdcard/s.png && adb pull /sdcard/s.png <local path>`; wake screen — `adb shell input keyevent KEYCODE_WAKEUP`.

## Known friction hit once already

First CI run on the iOS screenshot workflow failed at the `xcodebuild test` step (run: https://github.com/sujalsharma-24/Mochi/actions/runs/29116692710). Not yet diagnosed — deprioritized in favor of standing up the Android preview path, since that unblocks Sujal immediately without needing log access. Revisit next session if not already fixed. Also worth noting: pulling failed-job logs from a private-by-default Actions run needs either `gh` CLI auth or admin API token — neither was set up this session, so log retrieval required asking Sujal to paste output manually.

**Why:** So a future session doesn't re-suggest a cloud Mac (already declined) or re-discover that Android is the faster local loop from scratch.
**How to apply:** Default new-screen work to Android/Compose first when both platforms need the same screen. Keep both design-system token files (`ios/MochiApp/DesignSystem` and `android/app/.../designsystem`) in sync by hand — no shared source yet.
