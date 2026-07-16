# Mochi Android Home screen — iterative Figma pixel-parity pass (device testing + Home screen rebuild)

**Date:** 2026-07-16
**Status:** IN PROGRESS
**Bead(s):** none
**Epic:** none
**Chain:** `standalone-ef2fd53b` seq `1`
**Parent:** `none — first in chain`
**Prior chain:** none — first in chain

---

## The Goal

Mochi is a keyboard-customization Android/iOS app being built for a client from a Figma export (`docs/figma/1.png`–`13.png`, primarily `13.png` — a full-device mock at 2299×3865px including status bar and bottom nav). All 13+ screens exist as Jetpack Compose composables with `@Preview` functions; the client (Sujal, first-time freelancer, communicates in a mix of English and Hinglish) reviews each screen's preview in Android Studio and gives iterative feedback until it's pixel-close to the Figma reference. This session covered two distinct efforts: (1) getting the actual compiled app running and click-through-able on a physical Android phone (not just static previews), and (2) an extremely long iterative refinement loop on the **Home screen** (`HomeScreen.kt`) specifically, which the client repeatedly flagged as not matching Figma closely enough — spanning roughly 12 commits and 4.5+ hours of back-and-forth (14:20–18:44 on 2026-07-16). The user's explicit standing goal is **pixel-perfect** parity: exact sizes, spacing, aspect ratios, colors, and typography, not "close enough."

---

## Where We Are

- **Navigation is fully wired.** `ui/RootScreen.kt` hosts all 5 bottom-tab screens (Keyboard/Fonts/Themes/Community/Create) plus callback params (`onThemeClick`, `onProfileClick`, `onSearchClick`, `onLeaderboardClick`, `onWallpapersClick`) threading into Theme Detail, Profile, Search, Leaderboard, and Wallpaper Explore. This was already done by the time this session's visible context begins (confirmed by reading the file, not built fresh here).
- **App runs on a physical device.** Phone: model `V2207`, serial `10AC8X2BJ2000OF`, connected via USB with debugging enabled. `adb` at `C:\Users\ACER\AppData\Local\Android\Sdk\platform-tools\adb.exe`. Full click-through verified: Splash → Onboarding (4 pages) → Auth → 5-tab app, all screens reachable by tapping.
- **A real onboarding navigation bug was found and fixed** (see What We Tried) — commit `7851e9e`.
- **Android emulator setup was started but abandoned in favor of the physical phone.** SDK cmdline-tools were downloaded and extracted to `C:\Users\ACER\AppData\Local\Android\Sdk\cmdline-tools\latest\`; `platforms;android-34`, `system-images;android-34;google_apis;x86_64`, and `emulator` were installed via a background `sdkmanager` task (completed successfully, task id `bgwu6klbm`). **No AVD was ever created.** User said "better leave it we will download it later" — the SDK components are in place but unused; creating an AVD (`avdmanager create avd ...`) is the only remaining step if the emulator path is needed later (e.g., phone unavailable).
- **`HomeScreen.kt` has been rebuilt extensively this session** (see Evidence & Data for the full 12-commit table). Current architecture: `Box(fillMaxSize, gradient bg)` → sparkles drawn first (behind content) → `Column(fillMaxSize, windowInsetsPadding(statusBars), horizontal padding 16dp, top padding 8dp, bottom padding 84dp)` containing, in order: `Header`, `RecentlyAppliedRow` (weight 1f — the only remaining weight-flexible row), `QuickActionCards` (intrinsic height via `aspectRatio(1.55f)` per card), `LibraryToggle`, `SectionHeader("Popular Themes")`, `ThemesRow` (horizontally-scrollable, fixed 138dp cards), `SectionHeader("Font Collection")`, `FontsRow` (horizontally-scrollable, fixed 90dp cards), then a trailing `Spacer(Modifier.weight(1f))` to absorb any leftover vertical space so the whole screen still fits without an outer scroll container.
- **`MochiFont.logo()` now uses a newly-added Fredoka font** (Google Fonts, OFL) instead of Baloo 2, specifically because Baloo 2 even at max weight has pointed letter peaks that don't match Figma's much rounder "Mochi" wordmark. Every other `MochiFont` style (title/heading/body/caption/button) is unchanged, still Baloo 2.
- **A latent, app-wide bug was found and fixed in `components/ThemeCard.kt`'s `SectionHeader`**: the "see all" link used Material's `TextButton`, which carries an invisible ~40dp minimum touch-target height, silently padding out every section header (and the content below it) on **every screen that uses `SectionHeader`**, not just Home. Fixed by swapping to a plain `Text(...).clickable{}`. This fix has NOT been individually re-verified on the other screens that use `SectionHeader` (Community, Profile, Themes, etc.) — only Home has been re-screenshotted since.
- **`components/Buttons.kt`'s `GradientButton`** gained two new optional parameters this session: `fillMaxWidth: Boolean = true` and `compact: Boolean = false` (round 4, commit `0ba647e`), and later `gradient: Brush = MochiGradient.primaryButton` (round 6, commit `cf445a4`). All defaults preserve prior behavior for its ~20+ other call sites across the app (Fonts, Themes, Community, Create, Profile, Settings, etc.) — none of those were touched.
- **The most recent fix (commit `bc3235e`) has NOT been visually confirmed by the user yet.** The last two user messages after that commit were stale re-deliveries of an already-completed "check build task X" instruction, not a fresh screenshot. See Where We're Going.
- **`MockData.kt` gained a new list**: `homePopularThemes` (3 entries pulled from the existing `shopThemes` list: `cozy-sakura-cafe-shop`, `sakura-train`, `pastel-rainbow`) — fixes a data-wiring bug where Home's "Popular Themes" row was showing the exact same themes as "Recently Applied" above it.
- **iOS SwiftUI mirroring and the iOS CI screenshot pipeline are both still untouched** — not part of this session, still outstanding from earlier work (see `docs`/prior memory).
- Only the **Home screen** has had this intense Figma-matching treatment this session. The other 12 screens (Fonts, Themes, Community, Create, Profile, Settings, Search, Leaderboard, Wallpapers, Onboarding, Auth, ThemeDetail, Paywall) were built in earlier sessions and have not been re-compared against Figma with this level of rigor — though the `SectionHeader` fix benefits all of them automatically.
- **`RootScreen.kt`'s current signature**: `RootScreen(modifier: Modifier = Modifier, onThemeClick: (KeyboardTheme) -> Unit = {}, onProfileClick: () -> Unit = {}, onSearchClick: () -> Unit = {}, onLeaderboardClick: () -> Unit = {}, onWallpapersClick: () -> Unit = {})`. Internally holds `var selected by remember { mutableStateOf(MochiTab.KEYBOARD) }` and a `when(selected)` dispatch to `HomeScreen`/`FontsScreen`/`ThemesScreen`/`CommunityScreen`/`CreateThemeScreen`, each wired with the subset of callbacks it needs; `MochiTabBar` is layered on top via `Box` + `Modifier.align(Alignment.BottomCenter).windowInsetsPadding(WindowInsets.navigationBars)`.
- **`components/MochiTabBar.kt`** uses a custom `NotchedBarShape` (a hand-drawn `Path` with a cradle cutout for the Create FAB) — this was built in an earlier, pre-this-session pass and was confirmed (not modified) to already match Figma's bottom-nav styling: selected Keyboard tab shows a small rounded-square gradient badge behind its icon; Fonts tab renders literal "Aa" text instead of an icon; the Create tab is a floating circular gradient button offset upward into the bar's notch; Themes/Community use plain palette/people icons when unselected.
- **`android/app/src/main/res/drawable-nodpi/`** holds all the real (non-vector, photographic/illustrated) art assets referenced by asset-name string lookups in `components/ThemeArt.kt`'s `knownThemeArt`/`knownFontArt`/`knownAvatarArt` maps — `icon_palette.png` and `icon_library.png` (the two most recently touched, this session) are user-provided real Figma-cropped icon art, not generated placeholders.
- **Build performance this session**: `./gradlew.bat assembleDebug` ranged from as fast as ~8–20 seconds (incremental, most tasks `UP-TO-DATE`) up to ~2–11 minutes (cold Gradle daemon after being idle, or when new resources like the Fredoka font triggered fuller resource-processing passes). Several builds were run with `run_in_background: true` and polled via `ScheduleWakeup`/task-notifications because they exceeded the default foreground timeout.
- **Git remote**: `https://github.com/sujalsharma-24/Mochi.git`, branch `master`. Every commit this session was pushed immediately after a successful local build — the established, consistent workflow: edit → `assembleDebug` → commit with a detailed message (explaining root cause, not just "fixed X") → `git push` → report to user with the specific `@Preview` function name to check.
- One `git push` this session hit a transient network failure (`Failed to connect to github.com port 443`) — resolved by simply retrying `git push` immediately after, which succeeded. Worth remembering if it recurs: it's not a code/auth problem, just retry.

---

## What We Tried (Chronological)

All times/dates 2026-07-16 unless noted.

### 1. (23:38 07-15, pre-visible-context) Navigation wiring
- `RootScreen.kt` was wired with callback params for cross-screen navigation.
- Confirmed present when read this session, not rebuilt from scratch here.
- Commit `82202f1`.

### 2. (00:17) Physical-device testing setup — emulator path
- No AVD/system image existed locally at session start.
- Investigated `sdkmanager`/`avdmanager`; found `cmdline-tools` wasn't installed at all under the SDK root.
- Downloaded `cmdline-tools.zip` in the background, extracted it to `C:\Users\ACER\AppData\Local\Android\Sdk\cmdline-tools\latest\`.
- Ran `sdkmanager --licenses` (accepted all).
- Began installing `platforms;android-34` + `system-images;android-34;google_apis;x86_64` + `emulator` as a background task (id `bgwu6klbm`).
- Progress checked twice — very slow: ~15% of the largest system-image file after ~10 minutes of download.
- Used `AskUserQuestion` to offer: keep waiting / switch to phone / use phone directly.
- User chose "switch to my phone instead."
- User then separately clarified: "better leave it we will download it later" — i.e. don't cancel the background download, just stop blocking on it.
- **Result: the background download DID complete successfully** (confirmed via a later task-notification), so `platforms;android-34`, the x86_64 system image, and `emulator` are all installed — but **no AVD was ever created** from them. Emulator path is parked, not finished.

### 3. (00:17) Physical phone setup
- Walked the user through enabling Developer Options (tap Build Number 7×) and USB debugging, per standard Android instructions.
- First `adb devices` showed the phone as `unauthorized` — guided the user to accept the on-device "Allow USB debugging?" popup.
- Second check showed `device` (authorized): model `V2207`, serial `10AC8X2BJ2000OF`.
- Ran `./gradlew installDebug` → `BUILD SUCCESSFUL`, "Installed on 'V2207 - 14'".
- Launched via `adb shell am start -n com.mochi.app/.MainActivity`.
- Took a screenshot via `adb exec-out screencap -p > file.png` to verify visually — this is the verification pattern used throughout for phone-based checks.

### 4. (00:17) Onboarding navigation bug — found via the phone screenshot
- The screenshot showed the **Auth screen** immediately on launch — should have required tapping through 4 onboarding pages first.
- **Root cause**: `OnboardingScreen.kt`'s Next/Get-Started button had `title = if (isLastPage) "Get Started" else "Next"`, but the `onClick` lambda unconditionally called `onFinished()` regardless of `isLastPage` — only the button *label* was conditional, not the *behavior*. Tapping "Next" on page 1 immediately jumped to Auth, skipping the rest of onboarding entirely.
- **Fix**: added `val coroutineScope = rememberCoroutineScope()`; on non-last pages the click now does `coroutineScope.launch { pagerState.animateScrollToPage(pagerState.currentPage + 1) }`; `onFinished()` is called only when `isLastPage` is true.
- Added imports: `androidx.compose.runtime.rememberCoroutineScope`, `kotlinx.coroutines.launch`.
- Rebuilt, reinstalled, relaunched, reverified via a fresh screenshot showing the pager correctly advancing page-by-page.
- Commit `7851e9e`.
- After this fix, full click-through was confirmed working end to end: Splash → Onboarding (all 4 pages) → Auth → the 5-tab app, with Search, Settings, Profile, Leaderboard, Wallpapers, Theme Detail, and Paywall all reachable by tapping.

### 5. (01:08–01:19) Earlier Home-screen pass (not captured live in this window)
- Commits `99e7df8` ("Fix Home screen layout to match Figma measurements, tab bar nav-inset bug") and `22e8deb` ("Add taller Home preview so Font Collection isn't cut off") exist in the log with these timestamps, but the granular back-and-forth that produced them happened in a part of the conversation that had already been summarized away before this session's visible context began. Their effects were visible when files were read later (e.g. `RootScreen.kt` already had `windowInsetsPadding(WindowInsets.navigationBars)` on the tab bar), but the process isn't independently documented here.

### 6. (14:20) Round 1 — "fixed, non-scrolling" rebuild
- User's core complaint (long paragraph, paraphrased): Font Collection row looked missing, no visible navigation bar, too much gap after the "Mochi" heading, Recently-Applied row should show exactly 3 themes, Custom Create/Choose from Library sizing wrong, too much gap after "Popular Themes" heading, that row should show "2 and a half" themes.
- The "Font Collection missing" part turned out to be a static-`@Preview`-height clipping artifact (the preview canvas was shorter than the actual content), not a real bug — but the user's separate, explicit ask for a genuinely non-scrolling fixed layout meant the fix needed to go further than just enlarging the preview canvas.
- **Measured via Python PIL pixel-scanning of `docs/figma/13.png`**: the 3 Recently-Applied cards fit edge-to-edge with left/right margins ≈76–81px, card widths ≈641–778px, inter-card gaps ≈42–44px — confirmed this is genuinely a 3-card-no-scroll design in Figma, not a horizontally-scrolling row that happens to show 3.
- **Result**: removed `verticalScroll` entirely from `HomeScreen.kt`; converted every section to `weight()`-based flexible sizing inside a single `fillMaxSize()` `Column` so the whole screen always exactly fills the viewport with no scrollbar; added `.windowInsetsPadding(WindowInsets.statusBars)` so content doesn't sit under the status bar; swapped in real `icon_palette.png`/`icon_library.png` PNGs the user had placed directly into `drawable-nodpi/` (replacing earlier placeholder crops); removed the now-unnecessary `HomeScreenFullLengthPreview` function (added in an earlier, now-summarized turn specifically to work around static-preview clipping — no longer needed once the screen was truly non-scrolling, since there's nothing below the fold anymore).
- Commit `fb90fc1`.

### 7. (14:51) Round 2 — compactness + sparkles
- User: action cards are "so combact [in Figma]... but ours looks ugly"; FONTS/THEMES toggle buttons aren't as bold as Figma's; Popular Themes names look "attached" to the art directly below with no gap; small decorative sparkle/star accents visible in Figma's background aren't present in the build.
- **Fix**: reworked `ActionCard`'s internal spacing to be tighter; uppercased and enlarged `ToggleButton`'s text; increased the gap between the theme-art image and the name `Text` in `ThemesRow`; added a new `SparkleDecorations` composable rendering two small "✦" `Text` glyphs at low opacity.
- Commit `8da7e2c`.

### 8. (15:13) Immediate bug-fix round — two bugs shipped in round 2
- **Bug A**: the `GradientButton` call in `ActionCard` had `Modifier.height(34.dp)` explicitly set, but the button's own internal `contentPadding` (14dp top + 14dp bottom = 28dp total) plus the text's own line-height left less than zero room inside that 34dp box — the text collapsed to invisible (rendered but effectively zero-height/clipped).
- **Bug B**: the sparkles from round 2 were drawn *on top of* all page content (called after the `Column` in the `Box`), positioned at hardcoded `padding(top=300.dp)`/`330.dp` offsets — these coordinates happened to land exactly on top of the "Choose" button in this specific layout, so a sparkle glyph visibly overlapped the button text.
- **Fix A**: removed the bad `.height(34.dp)` override entirely, letting `GradientButton` size itself naturally from its content + padding.
- **Fix B**: reordered so `SparkleDecorations()` is called *before* the content `Column` inside the `Box` (so any opaque card/button drawn later visually covers a sparkle underneath it wherever they'd overlap) and moved the sparkle positions closer to the header (`top=90.dp`/`110.dp` instead of `300.dp`/`330.dp`).
- Commit `b542515`.

### 9. (15:34) Round 3 — structural layout diff via side-by-side crop comparison
- Cropped `docs/figma/13.png` into labeled sections (`crop_actioncards.png`, `crop_popularthemes.png`, `crop_fontcollection.png`, `crop_navbar.png`) and compared each directly against the equivalent area of the current build, rather than comparing whole-screen screenshots.
- **Found**: Figma's action cards use a **left-icon / right-text** layout (icon spans most of the card's height on the left; title + description stacked to its right), not the top-icon/text-below stack the build had.
- **Found**: Figma's action cards have a **visible thin purple border outline**, not a plain shadowed white box.
- **Found**: the unselected "THEMES" toggle pill has a **border outline** in Figma that the build's white pill lacked (making it blend into the page background).
- **Found**: Popular Theme cards on the Home screen show **only the theme name**, no "by {creator}" byline underneath — that extra detail belongs to the Explore/Shop screen's cards, not Home's.
- **Fix**: restructured `ActionCard`'s internals to `Row(Image(icon), Column(Text(title), Text(subtitle)))`; added `.border(1.dp, MochiColor.purple.copy(alpha=0.3f), RoundedCornerShape(MochiRadius.card))` to the action-card container; applied the same border pattern to `ToggleButton`'s unselected-state branch; removed the "by {creator}" `Text` composable call from `ThemesRow`'s card content.
- Commit `22167ab`.

### 10. (16:14) Round 4 — mismatched card heights, oversized buttons, theme-card "white border," square font cards
- User: Custom Create and Choose from Library render at visibly different heights; the Create/Choose buttons inside them are too big, not the same size as Figma's; Popular Themes theme names have a "white border" look that Figma doesn't; Font Collection cards aren't the rectangular shape Figma shows.
- **Diagnosis (height mismatch)**: "Custom Create" (1-line title) and "Choose from Library" (2-line title, since it's longer) were each sizing to their own intrinsic content height independently inside `QuickActionCards`' `Row` — with no shared height constraint, the 2-line card was simply taller.
- **Diagnosis ("white border")**: not a literal border — the entire card was a white `Column` wrapping both the theme-art image and the name text together, giving the impression of a boxed/bordered look around the text; Figma instead shows the name directly on the transparent page-gradient background below the art, exactly like `RecentlyAppliedRow`'s own treatment already did.
- **Fix (height)**: `QuickActionCards`'s `Row` gained `.height(IntrinsicSize.Min)`; each `ActionCard` call gained `Modifier.weight(1f).fillMaxHeight()` — first attempt at equalizing height, via content-matching to whichever card is tallest (later superseded by a fixed `aspectRatio` approach in round 8, which is more robust since it doesn't depend on content at all).
- **Fix (buttons)**: added two new optional parameters to `GradientButton` — `fillMaxWidth: Boolean = true` and `compact: Boolean = false` — with defaults chosen so every one of the component's ~20 other call sites across the app is completely unaffected; `ActionCard` passes `fillMaxWidth=false, compact=true` for a content-sized pill instead of a full-width-stretched button.
- **Fix (white border)**: removed the white `background(Color.White)` wrapper `Column` from `ThemesRow`'s per-card composable entirely, leaving just the image + transparent-background name text.
- **Fix (font cards)**: `FontsRow` switched from pure `weight()`-driven height (which let whatever vertical space the row got determine the card's height, producing a near-square shape) to `Modifier.weight(1f).aspectRatio(1.23f)` — first landscape-ratio attempt this session, measured via a tight-crop + column pixel-scan of one font card (found content roughly spanning y≈3020 to y≈3396 in the original Figma image).
- Commit `0ba647e`.

### 11. (17:07) Self-driven fix — Popular Themes data-reuse bug
- Not a direct new user complaint this round — found via the user's own earlier standing instruction to "compare yourself if anything left."
- **Found**: Home's "Popular Themes" row (`ThemesRow`) was wired to `MockData.popularThemes` — the exact same list already used by `RecentlyAppliedRow` above it — so both rows displayed identical content ("Fantasy Castle Night / Space vibe / Dreamy Castle") instead of Figma's actual distinct trio for that section ("Cozy Sakura Café / Sakura Train / Pastel Rainbow").
- **Fix**: added a new `MockData.homePopularThemes` list, built from 3 entries that already existed in the pre-existing `shopThemes` list and whose names match Figma exactly: `cozy-sakura-cafe-shop`, `sakura-train`, `pastel-rainbow`. `HomeScreen`'s call to `ThemesRow` switched from `MockData.popularThemes` to `MockData.homePopularThemes`.
- Commit `d5c379f`.

### 12. (17:29) Round 5 — detailed CSS/web-flavored specification from the user
- User sent a long, explicit, web-development-styled instruction (using terms like `flex: 1`, `grid-template-columns: 1fr 1fr`, `align-items: stretch`, `justify-content: space-between`, a `.card-icon` shared class, and named components `KeyboardPreviewCard`/`ActionCard`/`PillButton`/`FontCard`) demanding: (1) the two action cards be exactly 50% width each with equal height regardless of text length; (2) icon-left/text-right internal layout with the button pinned to the bottom-left; (3) Create/Choose buttons be a single shared component guaranteed identical (same padding/min-width/radius/gradient, NOT sized to their own text); (4) both card icons share one fixed size, bigger than before; (5) FONTS/THEMES be two equal-width pills; (6) the three Popular Themes cards be identical fixed-width/height children in a horizontal-scroll container, sized to match the featured row; (7) extract all of the above into genuinely shared/reused components.
- Translated each CSS concept to its Compose equivalent: `flex: 1` → `Modifier.weight(1f)`; `align-items: stretch` → `IntrinsicSize.Min` + `fillMaxHeight()`; `justify-content: space-between` → `Arrangement.SpaceBetween`.
- **Fix**: extracted a genuinely shared `KeyboardPreviewCard(theme: KeyboardTheme, onTap: () -> Unit, modifier: Modifier = Modifier)` composable, used by BOTH `RecentlyAppliedRow` and `ThemesRow` — this guarantees pixel-identical sizing/styling *by construction* (same code path), rather than two independently-tuned card blocks that could drift apart again, which is exactly what had been happening round after round.
- `ActionCard`'s outer `Column` switched `verticalArrangement` to `Arrangement.SpaceBetween`, so the button pins to the bottom of the card regardless of whether the title above it wraps to 1 or 2 lines.
- Both action-card buttons given a shared fixed `ActionButtonMinWidth = 96.dp` constant (later reduced further in subsequent rounds — see the ActionCard dimension table below).
- Icons bumped from 48dp to 56dp this round.
- Commit `017b68d`.

### 13. (17:58) Round 6 — 5 precise numbered asks against the reference screenshot
1. Toggle active state was reversed — FONTS should be the default-active pill, THEMES the inactive one (it was the other way around).
2. Icon and text should align so the text starts on the *same top line* as the icon, not vertically centered against it.
3. The Create/Choose buttons should use a visibly softer pink→purple gradient — user described the current look as "solid magenta," not a smooth gradient.
4. Popular Themes preview cards need a landscape aspect ratio matching the featured (Recently Applied) row above — currently too square/zoomed, cropping the mini keyboard scene.
5. The *top* featured row (Recently Applied) should get that same landscape ratio too, for consistency between the two rows.
- **Fix (1)**: `LibraryToggle`'s `mutableStateOf` initial value flipped from `LibraryTab.THEMES` to `LibraryTab.FONTS`.
- **Fix (2)**: `ActionCard`'s icon+text `Row` changed `verticalAlignment` from `Alignment.CenterVertically` to `Alignment.Top`; the text `Column` was given an explicit `horizontalAlignment = Alignment.Start`.
- **Fix (3)**: added a new design token `MochiGradient.softButton = Brush.horizontalGradient(listOf(Color(0xFFF48FB1), Color(0xFFAB8CE8)))` (a pastel-shifted pink/purple pair) and a new `gradient: Brush = MochiGradient.primaryButton` parameter on `GradientButton` (default unchanged for every other call site) — `ActionCard` passes `gradient = MochiGradient.softButton`.
- **Fix (4 & 5)**: `KeyboardPreviewCard`'s `ThemeArt` modifier switched from `.weight(1f)` (crop-to-fill whatever height a weighted row happened to allocate — the root cause of the "too square/zoomed" look) to a fixed `.aspectRatio(1.35f)`, measured from the Recently-Applied card's actual art dimensions (641px wide / 480px tall ≈ 1.335, rounded to 1.35). Because the SAME shared `KeyboardPreviewCard` is used by both rows, this single change fixed both (4) and (5) simultaneously.
- **Side effect**: since both preview rows became aspect-ratio-driven (intrinsic height determined by width, not weight-flexible height from the parent), `HomeScreen`'s `Column` call sites for `RecentlyAppliedRow`/`ThemesRow` dropped their `Modifier.weight(1f)` passthrough, and a new trailing `Spacer(Modifier.weight(1f))` was added at the very end of the `Column` to absorb any leftover vertical space — this preserves the "everything fits in one viewport, no scroll" property from round 1 even though two of the rows are no longer weight-driven.
- Commit `cf445a4`.

### 14. (18:15) Round 7 — first Hinglish-language critique round
- User (paraphrased from Hinglish): "Mochi" heading's font is wrong vs Figma; action-card icons are too small; the text inside doesn't match Figma; Create/Choose buttons should be smaller/slimmer and centered; FONTS/THEMES toggle buttons are too thick; Popular Themes cards' size should increase so ~2.5 are visible; a bottom navigation bar should be added.
- **Investigation**: tightly cropped just the "Mochi" wordmark from `docs/figma/13.png` (`crop_mochi_logo_tight.png`) and inspected it closely — found Figma's font has fully-rounded "M" peaks and very uniform, thick strokes, visibly rounder/bubblier than Baloo 2 even at its heaviest available weight (800), which still has more pointed letterforms.
- **Fix (font)**: downloaded the Fredoka variable font directly from Google's official `google/fonts` GitHub repository via `curl` — URL `https://github.com/google/fonts/raw/main/ofl/fredoka/Fredoka%5Bwdth%2Cwght%5D.ttf` — saved to `android/app/src/main/res/font/fredoka.ttf` (159,184 bytes). Verified it's a genuine valid font file via the `file` command and a hex dump (showed `GDEF`/`GPOS`/`GSUB`/`HVAR` table tags and internal names like "FredokaWeightWidthLightRegularMediumSemiBoldBold"). Also downloaded the matching OFL license text from `https://raw.githubusercontent.com/google/fonts/main/ofl/fredoka/OFL.txt` to `android/licenses/Fredoka-OFL.txt`, mirroring how the pre-existing Baloo 2 font's license was already documented.
- `Typography.kt` gained a `fredokaWeight(weight: Int)` private helper function mirroring the existing `balooWeight()` pattern; `MochiFont.logo()` switched from `balooWeight(800)` to `fredokaWeight(700)` (Fredoka's variable-weight axis tops out at 700/Bold — there's no 800 or 900 weight available in this family, unlike Baloo 2). Every other `MochiFont` function (`title`, `heading`, `body`, `caption`, `button`) was left untouched on Baloo 2.
- **Fix (icons)**: bumped from 56dp to 64dp this round.
- **Fix (buttons centered)**: wrapped the `GradientButton` call in `ActionCard` with a `Box(modifier = Modifier.fillMaxWidth(), contentAlignment = Alignment.Center)`.
- **Fix (Popular Themes size)**: `ThemesRow` switched from `weight(1f)` (3 cards, filling the full row width exactly, no scroll — the round-1 "fixed non-scrolling" treatment) to `.horizontalScroll(rememberScrollState())` on the `Row`, with each `KeyboardPreviewCard` given a fixed `Modifier.width(148.dp)` instead of a weight — the first reintroduction of horizontally-scrolling "peek" behavior for this specific row (deliberately scoped to Popular Themes only; Recently Applied stayed non-scrolling/3-equal-cards, since Figma genuinely shows that row differently).
- **Fix (nav bar)**: explained to the user that the bottom tab bar is already correct and present in `RootScreen.kt`/`components/MochiTabBar.kt` (gradient badge on the selected Keyboard icon, "Aa" glyph for Fonts, a circular gradient Create FAB nested in the bar's notch, palette icon for Themes, people icon for Community) — it's intentionally excluded from `HomeScreenPreview` specifically because `HomeScreen` is a reusable content-only composable (used standalone elsewhere too), and pointed the user to `RootScreenPreview` in `RootScreen.kt` to see Home rendered together with the real nav bar. No code changes were needed for this item.
- Commit `b82f603`.

### 15. (18:35) Round 8 — rigorous pixel-measurement pass (most precise round of the session)
- User (Hinglish, paraphrased): why are the cards square-shaped, they should be rectangular like Figma; there's too much gap between the lines of text inside the cards; the buttons still look thick; FONTS/THEMES still aren't slim like Figma; reduce the gap between "POPULAR THEMES" heading and the cards below it; the visible "peek" of the 3rd Popular Themes card is less than half, it should be exactly half; increase Font Collection card size a little, so the 4th card pokes out slightly like it does in Figma.
- **This round, instead of eyeballing crops, actual pixel measurement was done**: isolated a single action card via a tight crop of `docs/figma/13.png` at coordinates `(60,1090)`–`(1070,1650)`, saved as `card1_isolated.png` (1010×560px) — a clean, nearly-exact-bounds image of just that one card.
- Measured the card's own border bounds precisely within that crop: approximately 995px wide × 545px tall → **aspect ratio ≈1.826:1**, encoded in code as `1.83f`.
- Measured the icon within the card: approximately 285×230px → **≈28.6% of the card's width**.
- Measured the button: left edge ≈330px, right edge ≈685px (width ≈355px); top ≈400px, bottom ≈505px (height ≈105px) → **≈35.7% of card width, ≈19.3% of card height**. Button's horizontal center (≈507.5px) closely matches the card's horizontal center (≈502.5px) → **confirmed the button genuinely is centered** in Figma, not left-aligned as an earlier round had assumed.
- **Root-caused the persistent "gap below Popular Themes heading" complaint** (which had survived multiple earlier "reduce the spacer" attempts): `SectionHeader`'s (in `components/ThemeCard.kt`) "see all" link used Material3's `TextButton`, which carries an *invisible* minimum touch-target height of roughly 40dp baked into its internals via `Modifier.defaultMinSize()` — far taller than the actual "see all" text itself (~18dp). This was silently padding out the entire `SectionHeader` row (and therefore everything below it) on **every screen in the app that uses this shared component**, not just Home. Fixed by replacing the `TextButton` with a plain `Text(text = actionTitle, ...).clickable(onClick = onAction)` — the same "no forced Material sizing" pattern the file's own `ThemeCard` composable already used elsewhere for its own tap targets.
- **Solved the "half theme" peek requirement algebraically** rather than by trial and error: Home's content width = 393dp preview width − 32dp total horizontal padding (16dp each side) = 361dp. For the 3rd card to show exactly half: `361dp = 2×cardWidth + 2×8dp(gap) + 0.5×cardWidth` → `345dp = 2.5×cardWidth` → `cardWidth = 138dp`. The previous round's 148dp value was checked against this same formula and found to leave only `361 - 2×148 - 16 = 49px` visible of the 3rd card, i.e. `49/148 ≈ 33%` — confirming the user's "less than half" observation exactly, and explaining WHY: counter-intuitively, *smaller* cards leave a *larger* leftover fraction visible, since the fixed 361dp budget divides differently.
- `FontsRow` (Font Collection) cards enlarged from the previous ~84dp (four cards dividing 361dp minus 3 gaps equally) to a fixed `Modifier.width(90.dp)` with `horizontalScroll` enabled — computed to leave `361 - 3×90 - 24 = 67px` of the 4th card visible, i.e. `67/90 ≈ 74%` visibility, a reasonable reading of "thora sa bahar" (a little bit sticking out).
- `ActionCard` rebuilt around a fixed `Modifier.aspectRatio(1.83f)` on the outer `Column`, REPLACING the round-4/round-5 `IntrinsicSize.Min` + `fillMaxHeight()` approach — a fixed aspect ratio guarantees both cards render at literally identical dimensions by construction, which is strictly more robust than matching to whichever sibling happens to be tallest. Icon set to 48dp (≈28.6% of the ≈172dp card width, per the measurement above). Button given an explicit `Modifier.width(68.dp).height(24.dp)` on the existing `GradientButton(compact=true, fillMaxWidth=false, ...)` call — **this height override turned out not to actually work, discovered next round.**
- `ToggleButton` padding/font reduced further: vertical padding 9dp→5dp, font size 16sp→14sp.
- Commit `2bb9f22`.

### 16. (18:44) Round 9 — overflow bug discovery (most recent substantive fix, NOT yet user-confirmed)
- User sent a fresh cropped screenshot showing "Choose from Library"'s subtitle text ("Pick a created keyboard") visibly **clipped/cut off** at the card's bottom edge, and the Create/Choose buttons still rendering noticeably thick despite round 8's explicit `.height(24.dp)`.
- **Root cause, fully diagnosed**: `GradientButton` wraps Material3's `TextButton`, which internally applies `Modifier.defaultMinSize(minHeight = ButtonDefaults.MinHeight)` (≈40dp) to its content — this **silently wins over an externally-supplied exact `Modifier.height(24.dp)`** passed in from the caller. The button that was supposed to be 24dp tall was actually rendering at ≈40dp.
- Recomputed the full vertical budget to confirm this explains the visible clipping: card height ≈94dp (172dp width ÷ 1.83 aspect ratio); minus 16dp of card padding (8dp top + 8dp bottom); the "Choose from Library" card's text block (2-line title + 2-line subtitle) measures ≈51.8dp tall, which is actually *taller* than the 48dp icon beside it in this specific card, so the icon-row height is driven by the text, not the icon; that leaves `94 - 16 - 51.8 ≈ 26.2dp` remaining for the button. A genuinely-24dp button would have just barely fit inside that remaining space; the Material-enforced ~40dp version overflows by roughly 14dp and gets clipped at the card's own `.clip(RoundedCornerShape(...))` boundary — exactly matching the screenshot's symptom.
- **Fix**: built a brand-new private composable, `SlimPillButton(title: String, modifier: Modifier = Modifier, onClick: () -> Unit)`, using the same plain `Box + Modifier.clickable + Modifier.background + Text` pattern that the pre-existing `ToggleButton` composable already used (i.e., deliberately NOT `TextButton`/any Material `Button` variant, so there's no internal minimum size to fight). Sized genuinely `width(72.dp).height(22.dp)`. `ActionCard` now calls `SlimPillButton(title = buttonTitle, onClick = onButtonClick)` instead of `GradientButton(...)`.
- The `GradientButton` import was removed from `HomeScreen.kt` entirely, since nothing in that file calls it anymore — `GradientButton` itself (the shared component in `components/Buttons.kt`) is completely untouched and still used by its ~20 other call sites across the rest of the app.
- Loosened the card's `aspectRatio` from the round-8 measured value `1.83f` down to `1.55f` — a deliberate, disclosed departure from the raw Figma measurement, made because this round's *other* request ("icons ka size increase karo" — increase icon size again) pushed the icon from 48dp to 56dp, and the combination of a bigger icon plus 2-line title/subtitle text didn't fit inside the stricter 1.83:1 ratio without re-triggering the same overflow/clipping problem being fixed.
- Title text: 12sp→13sp with an explicit `lineHeight = 15.sp`. Subtitle text: 9sp→10sp with an explicit `lineHeight = 11.sp`. The gap between the title and subtitle rows was set to `0.dp` (relying entirely on the now-tightened explicit line-heights rather than an additional spacer) — this addresses the "line spacing kam karo" (reduce the gap between lines) part of the feedback.
- Commit `bc3235e`.
- **This fix has NOT yet been visually re-confirmed by the user.** The two user turns immediately following this commit were both stale, duplicate re-deliveries of an already-completed "check build task X and report" instruction (the underlying build/commit/push had already happened before either message arrived) — not fresh feedback on the actual visual result. See "Where We're Going" below.

---

## Key Decisions

- **Non-scrolling, single-viewport Home screen** (round 1): explicit user requirement, not a design guess — "i want it in the same way not like scrolling it make a fixed homescreen that fits everything." Rejected keeping `verticalScroll` even though it would have been simpler and safer against overflow.
- **Shared `KeyboardPreviewCard` composable** (round 5) over two independently-styled card blocks: guarantees Recently-Applied and Popular-Themes rows render pixel-identically *by construction*, directly satisfying the user's explicit "extract shared components... this is what guarantees consistent sizing" instruction. Rejected keeping them separate even after they'd converged in appearance, since drift was the whole problem being solved.
- **Fixed `aspectRatio` over `IntrinsicSize.Min` content-matching** for `ActionCard` (round 8): a fixed ratio guarantees identical card dimensions regardless of text content, which is more robust than matching-to-tallest-sibling (round 4's approach, which still left both cards' *height* determined by content rather than a real Figma-measured proportion).
- **Custom `SlimPillButton` over fighting `GradientButton`/Material `TextButton`** (round 9): after `Modifier.height(24.dp)` was silently overridden by Material's ~40dp minimum touch target, the decision was to build a Material-free button (same pattern as the pre-existing `ToggleButton`) rather than continue trying to force Material's `TextButton` smaller. Rejected further `Modifier.heightIn()`/padding tricks on `GradientButton` — those would still be fighting the same internal `defaultMinSize()`.
- **`aspectRatio(1.55f)` instead of the measured `1.83f`** (round 9): a deliberate, disclosed deviation from the raw Figma pixel measurement, made because the *combination* of a bigger 56dp icon (explicitly requested that same round) and 2-line title/subtitle text didn't fit within the stricter 1.83:1 ratio without re-triggering the overflow/clipping bug. Documented in the code comment so a future session knows this is intentional, not an unmeasured guess.
- **`gradient`/`fillMaxWidth`/`compact` as optional params on `GradientButton`** rather than a new parallel component (until round 9 forced a full replacement for this one case): kept the shared component's default behavior identical for ~20 other call sites across the app while allowing Home's specific customization.
- **Fredoka font scoped to `MochiFont.logo()` only**, not a wholesale font swap: the mismatch was specifically in the "Mochi" wordmark's letterforms; every other text style (title/heading/body/caption/button) was never flagged as wrong, so Baloo 2 was left untouched there to avoid unnecessary broad risk.
- **`SectionHeader`'s `TextButton`→`Text` fix applied globally**, not scoped to Home only: since the bug (invisible ~40dp Material minimum height) affects the shared component used by every screen, fixing it in `ThemeCard.kt` benefits all of them — but this means the fix has NOT been individually re-verified against Figma on those other screens, only Home.
- **Emulator setup left incomplete, not cleaned up**: per explicit user instruction ("better leave it we will download it later") — the downloaded SDK components remain in place for future use rather than being removed.

---

## Evidence & Data

### Commit table (this session, 2026-07-15 23:38 → 2026-07-16 18:44)

| Hash | Time | Summary |
|---|---|---|
| `82202f1` | 07-15 23:38 | Wire up real end-to-end navigation across all screens |
| `7851e9e` | 00:17 | Fix onboarding Next button skipping straight to auth |
| `99e7df8` | 01:08 | Fix Home screen layout to match Figma measurements, tab bar nav-inset bug |
| `22e8deb` | 01:19 | Add taller Home preview so Font Collection isn't cut off |
| `fb90fc1` | 14:20 | Rebuild Home screen as a fixed single-viewport layout, use real icons |
| `8da7e2c` | 14:51 | Polish Home screen: compact action cards, bold toggle, sparkles |
| `b542515` | 15:13 | Fix invisible action-card button text and sparkle overlapping button |
| `22167ab` | 15:34 | Fix Home screen gaps vs Figma: action card layout, borders, byline |
| `0ba647e` | 16:14 | Fix action-card size mismatch, oversized buttons, theme card style, font aspect |
| `d5c379f` | 17:07 | Fix Home Popular Themes reusing Recently Applied's theme data |
| `017b68d` | 17:29 | Extract shared KeyboardPreviewCard, pin action buttons to fixed width/bottom |
| `cf445a4` | 17:58 | Fix toggle default, action-card text alignment, button gradient, card aspect |
| `b82f603` | 18:15 | Add Fredoka font for logo, slim/center action buttons, bigger scrollable theme cards |
| `2bb9f22` | 18:35 | Pixel-measure action cards, slim toggle/buttons, fix header padding bug |
| `bc3235e` | 18:44 | Fix action-card overflow: custom slim pill button instead of Material's |

### ActionCard dimension iteration history

| Round | Icon size | Card sizing method | Button | Aspect/height source |
|---|---|---|---|---|
| 2 (8da7e2c) | 48dp | content-intrinsic | GradientButton, no override | none |
| 4 (0ba647e) | 48dp | `IntrinsicSize.Min` + `fillMaxHeight` | `compact=true, fillMaxWidth=false` | matched to taller sibling |
| 5 (017b68d) | 56dp | same (`IntrinsicSize.Min`) | fixed width 96dp | matched to taller sibling |
| 8 (2bb9f22) | 48dp | **fixed `aspectRatio(1.83f)`** (measured) | explicit `width(68dp).height(24dp)` (broken — see below) | measured 995×545px card crop |
| 9 (bc3235e) | **56dp** | **fixed `aspectRatio(1.55f)`** (loosened) | **custom `SlimPillButton`, 72×22dp** | measured, then deliberately loosened |

### Root-cause bugs found and fixed this session

| Symptom | Root cause | Fix | Commit |
|---|---|---|---|
| Onboarding "Next" jumps straight to Auth | `onClick` always called `onFinished()` regardless of `isLastPage`; only the button *label* was conditional | `coroutineScope.launch { pagerState.animateScrollToPage(...) }` for non-last pages | `7851e9e` |
| Action-card button text invisible | `Modifier.height(34.dp)` smaller than button's own 28dp content padding | Removed the height override | `b542515` |
| Sparkle floating over "Choose" button | Sparkles drawn after (on top of) content, at hardcoded offsets that coincided with the button's position | Draw sparkles before content in the `Box` (so cards cover them); moved near header | `b542515` |
| "White border" on Popular Themes names | Not actually a border — the *entire card* had a white `Column` background wrapping image+text, unlike Figma's transparent-background treatment | Removed the white background wrapper | `0ba647e` |
| Popular Themes shows same content as Recently Applied | Both rows wired to the same `MockData.popularThemes` list | Added `MockData.homePopularThemes` from matching `shopThemes` entries | `d5c379f` |
| Persistent "gap below Popular Themes heading" across multiple rounds | `SectionHeader`'s "see all" used Material `TextButton`, carrying an invisible ~40dp minimum touch height, app-wide | Replaced with plain `Text(...).clickable{}` in `ThemeCard.kt` | `2bb9f22` |
| Explicit `.height(24.dp)` on the button silently became ~40dp, overflowing the card and clipping the subtitle | Material's `TextButton` internal `defaultMinSize()` wins over an externally-passed exact height | Built `SlimPillButton`, a Material-free `Box`-based pill (same pattern as `ToggleButton`) | `bc3235e` |

### Precise Figma pixel measurements (source: `docs/figma/13.png`, 2299×3865px)

| Element | Measurement | Derived value used in code |
|---|---|---|
| Recently-Applied card | width ≈641–778px, margins ≈76–81px, gaps ≈42–44px, spans full width, no scroll | 3 equal-`weight(1f)` cards, `RecentlyAppliedRow` |
| Recently-Applied card art aspect | 641px / 480px ≈ 1.335 | `aspectRatio(1.35f)` |
| Action card (isolated crop `card1_isolated.png`, 1010×560) | border bounds ≈995×545px | `aspectRatio(1.83f)`, later loosened to `1.55f` |
| Action card icon | ≈285×230px within 995px-wide card | ≈28.6% of card width → 48dp, later 56dp |
| Action card button | left≈330/right≈685 (w≈355px), top≈400/bottom≈505 (h≈105px); center 507.5 vs card center 502.5 | ≈35.7% width / ≈19.3% height, confirmed centered |
| Font card 1 (tight crop) | top y≈3020, subtitle visible to y≈3396 | `aspectRatio(1.23f)` |
| Popular Themes peek — algebra | `361dp content width = 2×cardWidth + 2×8dp gap + 0.5×cardWidth` | solved: `cardWidth = 138dp` for exact 50% peek (148dp only gave 33%) |
| Font Collection peek | `361 - 3×90 - 24 = 67px visible / 90px card` | ≈74% visibility of 4th card at 90dp width |
| "Mochi" wordmark | tight crop `crop_mochi_logo_tight.png` — very round "M" peaks, uniform thick strokes | switched to Fredoka(700), not Baloo2(800) |

All intermediate crop PNGs (`card1_isolated.png`, `crop_actioncards.png`, `crop_popularthemes.png`, `crop_fontcollection.png`, `crop_mochi_logo_tight.png`, `crop_navbar.png`, etc.) live in the **session-specific scratchpad** at `C:\Users\ACER\AppData\Local\Temp\claude\c--Users-ACER-Desktop-Mochi\4de921bd-5b5a-4d36-87fd-109486157853\scratchpad\` and will **not** persist into a new session — re-crop from `docs/figma/13.png` (the only durable source) if further precision measurement is needed. The Python one-liner pattern used throughout: `python << 'EOF' ... Image.open(r"...docs\figma\13.png").crop((x0,y0,x1,y1)).save(...) ... EOF` (note: `python`, not `python3` — the WindowsApps `python3` alias triggers a Microsoft Store prompt and fails with exit code 49).

### Fredoka font asset details

- Source: `https://github.com/google/fonts/raw/main/ofl/fredoka/Fredoka%5Bwdth%2Cwght%5D.ttf` (variable font, weight+width axes)
- Saved to: `android/app/src/main/res/font/fredoka.ttf` (159,184 bytes)
- License: `https://raw.githubusercontent.com/google/fonts/main/ofl/fredoka/OFL.txt` → `android/licenses/Fredoka-OFL.txt`
- Verified valid via `file` command: "TrueType Font data, 19 tables... names ... FredokaWeightWidthLightRegularMediumSemiBoldBoldFredoka-..."
- Available weights: Light(300)/Regular(400)/Medium(500)/SemiBold(600)/Bold(700) — no 800/900, so `MochiFont.logo()` uses `fredokaWeight(700)`, the max available (vs Baloo2's 800 used elsewhere).

---

## Code Analysis

- **`GradientButton`** (`components/Buttons.kt`) signature as of `bc3235e`: `GradientButton(title: String, modifier: Modifier = Modifier, icon: ImageVector? = null, fillMaxWidth: Boolean = true, compact: Boolean = false, gradient: Brush = MochiGradient.primaryButton, onClick: () -> Unit)`. Internally wraps Material3 `TextButton` — **any attempt to force it below Material's ~40dp minimum touch height via `Modifier.height()` will silently fail.** Use a plain `Box`-based pattern (see `ToggleButton` or the new `SlimPillButton` in `HomeScreen.kt`) for anything that needs to go smaller.
- **`MochiGradient.softButton`** (`designsystem/Theme.kt`): `Brush.horizontalGradient([Color(0xFFF48FB1), Color(0xFFAB8CE8)])` — pastel-shifted pink/purple, used only by Home's action-card buttons. `MochiGradient.primaryButton` (the original, more saturated `[MochiColor.pink, MochiColor.purple]`) is unchanged and still used everywhere else.
- **`KeyboardPreviewCard`** (`HomeScreen.kt`, private): `KeyboardPreviewCard(theme: KeyboardTheme, onTap: () -> Unit, modifier: Modifier = Modifier)` — renders `ThemeArt(...).aspectRatio(1.35f)` + a centered/start-aligned `Text` name below, no background box. Shared by `RecentlyAppliedRow` (called with `Modifier.weight(1f)`, no scroll) and `ThemesRow` (called with `Modifier.width(138.dp)`, inside `horizontalScroll`).
- **`SlimPillButton`** (`HomeScreen.kt`, private, new in `bc3235e`): `SlimPillButton(title: String, modifier: Modifier = Modifier, onClick: () -> Unit)` — plain `Box().width(72.dp).height(22.dp).clip(CircleShape).background(MochiGradient.softButton).clickable(onClick)`, `Text` at `MochiFont.button(11.sp)`. No Material `Button`/`TextButton` involved.
- **`SectionHeader`** (`components/ThemeCard.kt`): `SectionHeader(title: String, actionTitle: String? = "see all", modifier: Modifier = Modifier, onAction: () -> Unit = {})` — "see all" is now `Text(...).clickable(onClick=onAction)`, not `TextButton`. This is a shared component; the fix is global.
- **`HomeScreen`'s top-level `Column` padding**: `.windowInsetsPadding(WindowInsets.statusBars).padding(horizontal = MochiSpacing.md /*16dp*/).padding(top = MochiSpacing.sm /*8dp*/, bottom = 84.dp /*tab bar clearance*/)`. Content width available for rows = 393dp (preview width) − 32dp = **361dp** — this number is load-bearing for all the peek-percentage algebra above; if `MochiSpacing.md` or the preview width ever changes, those derived card widths (138dp, 90dp) need recomputing.
- **`MockData.homePopularThemes`**: `listOf(shopThemes.first{it.id=="cozy-sakura-cafe-shop"}, shopThemes.first{it.id=="sakura-train"}, shopThemes.first{it.id=="pastel-rainbow"})` in `mockdata/MockData.kt`.
- **`ActionCard`** (`HomeScreen.kt`, private, current signature as of `bc3235e`): `ActionCard(iconResId: Int, title: String, subtitle: String, buttonTitle: String, modifier: Modifier = Modifier, onButtonClick: () -> Unit = {})`. Outer `Column`: `modifier.aspectRatio(1.55f).clip(RoundedCornerShape(MochiRadius.card)).background(Color.White).border(1.dp, MochiColor.purple.copy(alpha=0.3f), RoundedCornerShape(MochiRadius.card)).padding(MochiSpacing.sm)`, `verticalArrangement = Arrangement.SpaceBetween`. Icon `Modifier.size(56.dp)`. Title `MochiFont.heading(13.sp).copy(lineHeight=15.sp)`. Subtitle `MochiFont.caption(10.sp).copy(lineHeight=11.sp)`, `maxLines=2`.
- **`QuickActionCards`** (`HomeScreen.kt`, private): `Row(modifier.fillMaxWidth(), horizontalArrangement=Arrangement.spacedBy(MochiSpacing.md))` containing two `ActionCard`s each with `Modifier.weight(1f)` — no `IntrinsicSize.Min`/`fillMaxHeight()` anymore as of round 8, since the fixed `aspectRatio` on each `ActionCard` now handles equal-sizing on its own.
- **`ThemesRow`** (`HomeScreen.kt`, private, current): `Row(modifier.horizontalScroll(rememberScrollState()), horizontalArrangement=Arrangement.spacedBy(MochiSpacing.sm))`, each `KeyboardPreviewCard` called with `Modifier.width(138.dp)`.
- **`FontsRow`** (`HomeScreen.kt`, private, current): `Row(modifier.horizontalScroll(rememberScrollState()), horizontalArrangement=Arrangement.spacedBy(MochiSpacing.sm))`, each `FontArtCard` called with `Modifier.width(90.dp).aspectRatio(1.23f)`.
- **`RecentlyAppliedRow`** (`HomeScreen.kt`, private, unchanged since round 6): `Row(modifier.fillMaxWidth(), horizontalArrangement=Arrangement.spacedBy(MochiSpacing.sm))`, each `KeyboardPreviewCard` called with `Modifier.weight(1f)` (no scroll — genuinely 3 equal cards filling the full row width, per the round-1 Figma measurement that this specific row has no scroll affordance in the design).
- **Top-level `HomeScreen` composable order** (current, top to bottom): `Header` → `Spacer(8dp)` → `RecentlyAppliedRow` → `Spacer(8dp)` → `QuickActionCards` → `Spacer(8dp)` → `LibraryToggle` → `Spacer(8dp)` → `SectionHeader("Popular Themes")` → `Spacer(4dp)` → `ThemesRow` → `Spacer(8dp)` → `SectionHeader("Font Collection")` → `Spacer(4dp)` → `FontsRow` → `Spacer(Modifier.weight(1f))`. `SparkleDecorations()` is called once, separately, before this `Column` inside the enclosing `Box`.
- **`OnboardingScreen.kt`'s pager button** (post-fix): `GradientButton(title = if (isLastPage) "Get Started" else "Next") { if (isLastPage) onFinished() else coroutineScope.launch { pagerState.animateScrollToPage(pagerState.currentPage + 1) } }` — this exact pattern (conditional label AND conditional behavior, not just label) is the template to check against if similar "label says X but behavior always does Y" bugs are suspected elsewhere in the app.

---

## Files Changed

### Source code (this session)
- `android/app/src/main/java/com/mochi/app/features/home/HomeScreen.kt` — the primary file, rebuilt/edited across ~10 commits this session (see What We Tried for the full history). Currently: non-scrolling single-viewport layout, shared `KeyboardPreviewCard`, custom `SlimPillButton`, `SparkleDecorations`.
- `android/app/src/main/java/com/mochi/app/components/Buttons.kt` — `GradientButton` gained `fillMaxWidth`, `compact`, `gradient` optional params (all default-preserving).
- `android/app/src/main/java/com/mochi/app/components/ThemeCard.kt` — `SectionHeader`'s "see all" switched from `TextButton` to plain clickable `Text` (app-wide fix).
- `android/app/src/main/java/com/mochi/app/designsystem/Theme.kt` — added `MochiGradient.softButton`.
- `android/app/src/main/java/com/mochi/app/designsystem/Typography.kt` — added `fredokaWeight()` helper; `MochiFont.logo()` switched to Fredoka(700).
- `android/app/src/main/java/com/mochi/app/mockdata/MockData.kt` — added `homePopularThemes`.
- `android/app/src/main/java/com/mochi/app/features/onboarding/OnboardingScreen.kt` — fixed the Next-button navigation bug (added `rememberCoroutineScope`, `kotlinx.coroutines.launch` import).

### Assets (new)
- `android/app/src/main/res/font/fredoka.ttf` — Fredoka variable font (159,184 bytes), Google Fonts OFL.
- `android/licenses/Fredoka-OFL.txt` — matching license text.
- `android/app/src/main/res/drawable-nodpi/icon_palette.png`, `icon_library.png` — replaced with user-provided real icon art (round 1).

### Config / infra
- `C:\Users\ACER\AppData\Local\Android\Sdk\cmdline-tools\latest\` — Android SDK command-line tools, installed this session.
- SDK components installed via background `sdkmanager` task: `platforms;android-34`, `system-images;android-34;google_apis;x86_64`, `emulator` — no AVD created from them yet.

---

## User Feedback & Preferences (verbatim/close paraphrase, chronological)

- "is there any way to stimulate the UI... i want to run it click the buttons and see it open that screen... so that i can see the overall working of app?" — wants the real compiled app, not just static previews.
- "better leave it we will download it later" — re: the slow emulator system-image download; don't cancel it, just stop waiting on it.
- "yes i used it and i think our UI is still not up to the level of the figma design lets improve UI on each screens one by one will guide you about what things to improve in each screen" — establishes the iterative per-screen refinement mode for the rest of the session.
- "first i want to know the numbers of the screen from figma design you choose for each of the screens you create" — wanted the `docs/figma/N.png` → screen mapping (answered via grep of "Ported from docs/figma" comments; Home notably has NO such numbered comment, it references `ios/MochiApp/Features/Home/HomeView.swift` instead — worth fixing/clarifying later).
- Long Home-screen critique #1 (round 1 trigger): gap sizing, missing-looking Font Collection, action-card sizing, "2 and a half" Popular Themes cards, real icon PNGs offered.
- "where is the font bar here?" — after a preview screenshot appeared cut off; explained as a static-`@Preview` height-clipping artifact, not a real bug (though the screen was still made non-scrolling per the next request).
- "i want it in the same way not like scrolling it make a fixed homescreen that fits everything and i have provided the icon to you access that and use it in the homescreen and renbnuild it" — the explicit "no scrolling, single fixed viewport" requirement that shaped the whole architecture from round 1 onward.
- "this is the theme you created compare it will the figma design yourself and tell me do you think its exact same as the figma design ?" — explicitly asked for self-critique rather than just waiting for more complaints; this is where the Popular Themes data-reuse bug was self-discovered.
- Detailed CSS-flavored spec (round 5) — see What We Tried #12 for the full numbered list; process feedback embedded in it: "Extract repeated pieces into shared components/classes... This is what guarantees consistent sizing."
- 5-point English list (round 6) — precise, numbered, each addressed 1:1.
- Switch to Hinglish begins around round 7 — user explicitly said "I am continuing in hinglish," and subsequent replies from the assistant have matched that tone; **this should continue in future sessions** unless the user switches back.
- "abhi bhi bilkul same nhi bana h muje bilkul same chaiye figma design jesa" (round 8) — reiterated the pixel-perfect standard explicitly, prompted the shift to rigorous PIL measurement instead of eyeballing.
- "tumne rectangular toh krdiya but andar ki chize bhi toh sizes k hisab se fix karo" (round 9, most recent) — acknowledges progress on the outer shape but flags the *internal* content (icon size, line spacing, button thinness/centering) as still wrong; this is the round that surfaced the Material-button-height bug.
- Recurring workflow pattern (established in an earlier, pre-this-session context per memory, and still honored here): push every change so the user can preview it in Android Studio; user has explicitly deferred *phone*-based re-verification until "after completing all the screens" — for now, Android Studio's static `@Preview` panel is the user's actual review surface, even though the app is also confirmed working live on the phone.
- "i will provide you the icon but for now push what have you made so that i can preview it in android studio. And after completing all the screens we can use in phone" — the direct source of the phone-deferral preference above; also establishes that the user sometimes interleaves a promise of future assets (icons, etc.) with an instruction to keep moving now rather than block waiting for them.
- "Abhi bhi yeh bilkul same nhi bana h muje bilkul same chaiye figma design jesa" appears as a recurring refrain across multiple rounds (paraphrased each time slightly differently) — the user does not soften this standard as rounds accumulate; each new screenshot is judged against Figma directly, not against the previous round's build. Treat every "still not matching" message as a fresh, independent comparison request, not evidence that earlier fixes were wasted.
- The user reliably attaches a *new* cropped screenshot of the current build (not just re-sending the Figma reference) with each critique round, which is what makes precise pixel-comparison possible — when a session lacks such a screenshot, the correct move (established this session) is to ask for one or to generate a fresh one via `HomeScreenPreview` rather than guess from memory of an earlier round's appearance.
- The user tolerates long/slow background builds patiently as long as they're informed of progress (e.g. "build running in background, checking back shortly") — no frustration expressed about build times themselves, only about visual mismatches.

---

## Where We're Going

1. **Get the user's confirmation on commit `bc3235e`** (the `SlimPillButton` overflow fix) — this is the single most important next step. The last two user turns were stale/duplicate wakeup-instruction re-deliveries, not real feedback; there is no confirmation yet that the subtitle-clipping bug is actually resolved or that the button now reads as sufficiently thin/centered per the user's taste.
2. Continue the per-element pixel-measurement discipline (isolate-crop-then-PIL-measure) for any further Home screen mismatches the user reports — this approach was significantly more reliable than eyeballing and should be the default going forward, not a special case.
3. Once Home screen is confirmed pixel-close, the user is expected to move to another screen for the same treatment ("will guide you about what things to improve in each screen" — implies a per-screen queue, Home was just first).
4. Re-verify the `SectionHeader` fix (`TextButton`→`Text`) on a couple of the OTHER screens that use it (Community, Profile, Themes/Explore) — it was a global fix but has only been visually re-checked on Home.
5. Longer-term, still-outstanding from before this session: mirror validated Compose screens to SwiftUI (iOS side is behind), fix the iOS CI screenshot pipeline.
6. If the physical phone becomes unavailable, the emulator path can be resumed by creating an AVD from the already-installed `system-images;android-34;google_apis;x86_64` (no further download needed).

---

## Risks & Blockers

- **No independent confirmation loop on Compose Preview vs. real device rendering.** All of this session's fine-grained sizing work has been verified via Android Studio's static `@Preview` (screenshots the user pastes in), not the live phone — there's a real chance some of these fixes (especially the Material-button-height-override discovery) render subtly differently on-device vs. in the IDE preview. Low risk, but worth a phone re-check once the user resumes phone testing.
- **`aspectRatio(1.55f)` is a disclosed deviation from the measured `1.83f`**, not the "true" Figma number — if the user re-measures independently and finds the deviation objectionable, expect another round of back-and-forth on this specific value.
- **The `SectionHeader` global fix is unverified on non-Home screens** — small risk that removing `TextButton`'s built-in touch-target padding makes "see all" links elsewhere feel cramped or harder to tap, even though it wasn't flagged as a problem there.

## Open Questions

- Is the `bc3235e` fix actually correct? (Awaiting user's next screenshot.)
- Should Home screen gain an explicit `Ported from docs/figma/N.png` comment like every other screen has? Currently it references the iOS SwiftUI source file instead, which is inconsistent with the rest of the codebase and was flagged as a minor gap during the screen-numbering Q&A.
- Does the user want the emulator AVD created at some point, or is the physical phone now the permanent testing device?

---

## Quick Start for Next Session

```bash
# Verify current state
cd C:\Users\ACER\Desktop\Mochi
git log --oneline -5
git status -s

# Key files to read first
android/app/src/main/java/com/mochi/app/features/home/HomeScreen.kt
android/app/src/main/java/com/mochi/app/components/Buttons.kt   # GradientButton — note the Material TextButton min-height gotcha
android/app/src/main/java/com/mochi/app/components/ThemeCard.kt # SectionHeader

# Reference image (the ONLY durable Figma source — scratchpad crops don't persist)
docs/figma/13.png   # 2299x3865px, full device mock incl. status bar + bottom nav
docs/figma/1.png    # alt/earlier reference

# Re-crop pattern for pixel measurement (use `python`, NOT `python3` — WindowsApps alias fails)
python << 'EOF'
from PIL import Image
img = Image.open(r"C:\Users\ACER\Desktop\Mochi\docs\figma\13.png").convert("RGB")
img.crop((x0, y0, x1, y1)).save(r"...\scratchpad\some_crop.png")
EOF

# Build + verify
cd android
./gradlew.bat assembleDebug   # takes 20s-4min depending on cache state; run in background if it exceeds ~5min

# Phone (if available — model V2207, serial 10AC8X2BJ2000OF)
C:\Users\ACER\AppData\Local\Android\Sdk\platform-tools\adb.exe devices
./gradlew.bat installDebug
C:\Users\ACER\AppData\Local\Android\Sdk\platform-tools\adb.exe shell am start -n com.mochi.app/.MainActivity

# Next action
# Wait for / ask for the user's confirmation on commit bc3235e (HomeScreenPreview screenshot).
# If confirmed good: ask which screen to review next.
# If still off: repeat the isolate-crop-then-PIL-measure discipline from round 8/9 rather than eyeballing.
```
