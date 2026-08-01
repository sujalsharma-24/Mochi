# Porting Mochi's iOS SwiftUI UI to Android Compose, screen by screen, verified on-device against Figma

**Date:** 2026-08-01
**Status:** IN PROGRESS
**Bead(s):** none
**Epic:** none
**Chain:** `standalone-a870a4be` seq `1`
**Parent:** `none — first in chain`
**Prior chain:** none — first in chain

---

## Related Handoffs

- `plans/handoffs/HANDOFF_home-screen-figma-parity_2026-07-16.md` — an earlier, much longer session (12 commits, 4.5+ hrs) that did iterative user-critique-driven Figma matching on the Home screen, but on the **old** `com.mochi.app` package and the **old** Home screen architecture (`SlimPillButton`, `aspectRatio(1.55f)`, weight-based rows tuned by hand against `docs/figma/13.png` crops). That package no longer exists — it was renamed to `com.mochi.keyboard` in this session's first commit, and `HomeScreen.kt` was rewritten from scratch this session using a different method (see The Goal / Key Decisions). Treated as a sibling reference, NOT a parent: this session's next-steps are not a continuation of that file's "Where We're Going." Worth skimming for historical color/gradient/font values and the Material-`TextButton`-min-height gotcha, which still applies.

## The Goal

The client (Sujal, first-time freelancer) built the iOS app (SwiftUI) further than Android and said the iOS UI is "almost done and pretty good," while Android's UI is "not that good" — and asked to make Android match iOS **exactly**. Investigation showed iOS has a much more rigorous, pixel-measured design system (real Inter font, colors/gradients sampled directly off `docs/figma/*.png` with documented provenance, hand-drawn vector glyphs for marks no system icon matches, and per-screen `*Metrics.swift` files with exact Figma-pixel-to-point conversions) that Android's `com.mochi.keyboard` package didn't have at all (wrong font family — Baloo2 instead of Inter — and placeholder/approximated colors). The task: port the design system foundation once, then port each of iOS's 7 built screens (Home, Profile, Search, Themes, Fonts, Create, Community) to Compose so they match iOS content, layout, colors, and typography — verified visually against Figma exports, not just "looks plausible." iOS itself only has 3 commits total and no Mac/Simulator to preview on (CI screenshots only); Android has a physical test device connected via adb, which this session used as the verification loop instead of trying to replicate iOS's own coordinate-math approach.

---

## Where We Are

- **Foundation (design system + shared components) is fully ported and committed** (`6d287f7`). 7 of 7 shared screens are NOT done — 3 of 7 are (Home, Profile, Search).
- **Real Inter font is now in the app.** Copied `Inter-{Regular,Medium,SemiBold,Bold}.ttf` from `ios/MochiApp/Fonts/` into `android/app/src/main/res/font/` as lowercase-underscore names (`inter_regular.ttf` etc. — Android resource names can't have hyphens/caps), plus `ios/licenses/Inter-OFL.txt` → `android/licenses/Inter-OFL.txt`. `Typography.kt` rewritten: `title`→Inter Bold, `heading`→Inter SemiBold, `itemName`→Inter Medium (new function, didn't exist before), `body`→Inter Regular, `caption`→Inter Medium, `button`→Inter SemiBold. `logo` stays on Fredoka but now dialed to `wght=600` via `FontVariation.weight(600)` (was `fredokaWeight(700)` — iOS uses "Fredoka-Light" instance + `wght=600`, not the heaviest weight).
- **`Theme.kt` fully rewritten** with real hex values hand-converted from iOS's `Color(red:green:blue:)` decimals (see Evidence & Data table for the conversions). `textPrimary` changed from a soft dark grey (`0xFF251B3C`) to pure black (`Color.Black`) — iOS's own comment explains this was sampled directly off `docs/figma/1.png` glyph cores and confirmed exact. Added screen-specific colors that didn't exist on Android at all: `textMuted`, `creatorLink`, `heart`, `outline`, `freeChipText/Background`, `proChipText/Background`, `textGreyWarm`, `badgePink`, `backButtonStart/End`, `downloadGlyph`, `pickerHue`, `editProfileStroke`, `editProfileInk`, `recentSwatches`. Added gradients: `softButton` (3-stop, was previously approximated as a flat 2-color pastel gradient), `fontsAccent`, `themeButton`, `themeCircleButton`, `themeBadge`, `editorPill`, `tagPill`, `keyShapePreview`, `hueSpectrum` (12-stop HSV wheel via `Color.hsv()`).
- **New component files created** (didn't exist on Android before): `CreateGlyphs.kt` (`ColorWheelGlyph`, `HexagonShape`, `FloppyGlyph`, `KeycapGlyph`), `SlidersGlyph.kt` (`SlidersGlyph`, `FunnelGlyph`, `DownloadGlyph`, `PencilGlyph`, `SparkleCluster`, `TripleDot`), `SparkleField.kt` (10 fixed-position ambient background sparkles, 4-point star `Path`). These are hand-drawn `Canvas`/`Path` translations of iOS's SwiftUI `Shape`/`Path` code — mechanical but exact port of the same unit-space coordinate math. `PencilGlyph`, `TripleDot`, `DownloadGlyph` are already consumed by the Profile screen; the rest (`CreateGlyphs`, `SparkleCluster`, `FunnelGlyph`) are NOT yet used by any screen — they exist for the still-unported Create/Fonts/Themes screens.
- **`MochiTabBar.kt` rewritten**: real `NotchedTabBarShape` (continuous-bezier `Path` with `cubicTo`/`quadraticTo`, ported from iOS's `NotchedTabBarShape`) instead of the old approximated `NotchedBarShape`. Fixed the Fonts tab's "Aa" to use a gradient-masked `TextStyle(brush = MochiGradient.fontsAccent)` when selected. Fixed the Themes tab to use a real cropped+tinted image (`icon_tab_themes.png`, copied from iOS's asset catalog — didn't exist on Android before) instead of `Icons.Filled.Palette`, which iOS's own code comments explicitly call out as wrong ("Themes used to fall through to an SF Symbol, whose palette silhouette doesn't match").
- **`ThemeArt.kt`/`ThemeCard.kt` updated**: added the `purpleDark`-tinted drop shadow iOS applies (`shadow(6.dp, ..., alpha=0.14f)` for theme art, `5.dp`/`0.12f` for font art) that Android was missing entirely. `SectionHeader` gained `titleSize`/`actionSize: TextUnit` params (didn't exist — was hardcoded 13sp/heading), switched title from `MochiFont.heading` to `MochiFont.title` (Inter Bold, matching iOS), action label from `caption` to `body`.
- **Home screen (`HomeScreen.kt`) fully rewritten** against `ios/MochiApp/Features/Home/HomeView.swift`, replacing the old hand-tuned Android-only layout from the sibling handoff's session entirely. New `HomeMetrics.kt` ports `HomeMetrics`/`ActionCardTuning` 1:1 (iOS points treated as equal to Compose dp, same convention the rest of this design system uses). **Verified on-device**: screenshotted on the connected phone and compared directly against `docs/figma/1.png` — strong match (wordmark, action cards, gradient pills, theme rows, font collection cards, tab bar all line up). Committed `d8d53a3`.
- **Profile screen (`ProfileScreen.kt`) fully rewritten** against `ios/MochiApp/Features/Profile/ProfileView.swift`. iOS lays this screen out as an absolute canvas keyed to Figma's raw pixel coordinates (`ProfileMetrics`/`ProfileType`, with three separate scale factors `U`=1.155/`T`=1.18/`A`=1.10) because it has no Mac to preview against — deliberately **not** ported verbatim; instead reproduced as an ordinary Compose flow layout (Column/Row) with the same content, order, sizes, and colors, since Android has a working device-screenshot loop. Added `ProfileSummary`/`ProfileCreation`/`ProfileLikedTheme`/`ProfileFollowRow` to `model/KeyboardTheme.kt` and matching `MockData.kt` entries (copied 1:1 from `MockData.swift`, same copy/counts). Copied 8 missing art assets from iOS's asset catalog (see Files Changed). **Verified on-device** against `docs/figma/3.png` — strong match including iOS's own "both pair-cards say 'Liked Themes'" copy-paste quirk in the design, reproduced rather than corrected. Committed `06b0c23`.
- **Search screen (`SearchScreen.kt`) was already ~90% correct** — a prior session (visible in git log as part of `01e3957`, before this session started) had already built it as a close structural port of `SearchView.swift`. This session found and fixed the remaining gaps by diffing the two files directly (see What We Tried #4). Committed `dd64423`.
- **Themes, Fonts, Create, Community are untouched this session** — still on whatever code existed before (built in the `01e3957` "Build out Profile, Search, Themes, Fonts, Create, and Community screens" commit, pre-dating this session, on the OLD `com.mochi.app` naming conventions/design tokens but auto-renamed to `com.mochi.keyboard` by the package restructure commit `e9d86de`). They have NOT been diffed against their iOS counterparts yet and almost certainly have the same class of gaps Home/Profile/Search had (wrong fonts, approximated colors, missing shadows, wrong gradients) since they predate the design-system rewrite in `6d287f7`.
- **Device testing setup, re-confirmed working this session**: phone model `V2207`, serial `10AC8X2BJ2000OF`, adb at `C:\Users\ACER\AppData\Local\Android\Sdk\platform-tools\adb.exe` (not on PATH in the Bash tool's shell — must reference the full path or `cd` won't help). No AVD/emulator exists or was needed. The device disconnected once mid-session (`adb devices` returned empty) and reconnected on its own after `adb kill-server && adb start-server` + a short wait — not investigated further, but worth knowing it can happen.
- **A real Compose bug was found and fixed**: `Modifier.padding()` throws `IllegalArgumentException: Padding must be non-negative` on negative values — SwiftUI's `.padding()` allows negative padding (used deliberately in `HomeMetrics.headerTopPadding = -6`), Compose's does not. This crashed the app on first launch attempt (`FATAL EXCEPTION` in `HomeScreenKt.HomeScreenContent`). Fixed by moving that one value from `.padding(top=...)` to `.offset(y=...)` on the same Column. **This is a generalizable gotcha** — any other iOS `*Metrics.swift` value that's negative (there may be more in `ProfileMetrics`/other files, e.g. `ProfileMetrics.contentTop = -30`) will hit the same crash if ported to `.padding()` instead of `.offset()`. Profile avoided this because it wasn't ported via absolute coordinates at all (see above), so `contentTop`'s -30 was never actually used.
- **All 7 commits this session are on `master`, pushed nowhere yet** (no `git push` was run — only local commits). Working tree also has pre-existing, unrelated uncommitted changes (ios/ SwiftUI files, firestore/tests/, docs/figma/ additions, `uiA.xml`/`uiB.xml` at repo root) that belong to other work streams and were deliberately left untouched — confirmed with the user at session start that these are a separate, loosely-coordinated Mac-based iOS stream (see project memory `project_mochi_devenv.md`).

---

## What We Tried (Chronological)

### 1. Scoping the ask
User's request was vague ("implement iOS UI exactly for Android — how?"). Investigated both codebases before writing any code: found the Android tree had a large **uncommitted** restructure already sitting in the working directory (old `com.mochi.app` package staged as fully deleted, new `com.mochi.keyboard` package untracked, containing IME code + Firebase repositories/ViewModels that didn't exist in the old package). Also found iOS only has 7 of Android's 13 screens built, and Android's own git history showed 10+ commits of prior careful Figma pixel-matching (the sibling handoff's session) — but on a screen that had since been architecturally rewritten. Used `AskUserQuestion` three times before writing code: (1) whether to commit the pending restructure first → **user chose "commit it first"**; (2) scope — port just the 7 iOS has, or also redesign the 6 Android-only screens (Auth/Onboarding/Settings/Paywall/ThemeDetail/Wallpapers) with no iOS reference → **user chose "just the 7 iOS has"**; (3) verification method → **user chose "build + screenshot on device as I go," not just reading source**.

### 2. Checkpoint commit of the pending restructure
Staged only `android/` paths (left `ios/`, `firestore/`, `docs/figma/` uncommitted — unrelated work). Git detected the `com.mochi.app`→`com.mochi.keyboard` renames cleanly (56 files, 1484 insertions / 226 deletions). Commit `e9d86de`.

### Figma export → screen mapping (for reference, confirmed by reading iOS `Ported from docs/figma/N.png` comments and MockData.swift section headers)

| Figma file | Screen | iOS source file |
|---|---|---|
| `docs/figma/1.png` | Home | `Features/Home/HomeView.swift` |
| `docs/figma/2.png` | Community | `Features/Community/CommunityView.swift` |
| `docs/figma/3.png` | Profile | `Features/Profile/ProfileView.swift` |
| `docs/figma/4.png` | Create Custom Theme | `Features/Create/CreateThemeView.swift` |
| `docs/figma/5.png` | Fonts | `Features/Fonts/FontsView.swift` |
| `docs/figma/6.png` | Search | `Features/Search/SearchView.swift` |
| `docs/figma/8.png` | Themes | `Features/Themes/ThemesView.swift` |

`docs/figma/1.png` is itself the 2169×3865px (16:9) full-device export that `HomeMetrics.swift`'s scale comments are measured against (`px * 0.1853 = pt` on a 402pt-wide screen). `ProfileMetrics.swift` uses the same `k = 402/2169` scale constant against `docs/figma/3.png`.

### 3. Design system + shared components port
Read all of iOS's `DesignSystem/` (`Theme.swift`, `Typography.swift`, `HomeMetrics.swift`, `ProfileMetrics.swift`) and `Components/` (`GradientButton.swift`, `MochiTabBar.swift`, `ThemeArt.swift`, `ThemeCard.swift`, `CreateGlyphs.swift`, `SlidersGlyph.swift`, `SparkleField.swift`, `KeyboardPreviewPlaceholder.swift`) in full — roughly 1500 lines of SwiftUI across 12 files. Converted every `Color(red:green:blue:)` to hex by hand (see Evidence & Data). Wrote `Theme.kt`, `Typography.kt` (+ copied 4 Inter TTFs + license), `MochiTabBar.kt`, `ThemeArt.kt`, `ThemeCard.kt`, and 3 brand-new files (`CreateGlyphs.kt`, `SlidersGlyph.kt`, `SparkleField.kt`). Left `Buttons.kt` (`GradientButton`/`OutlineButton`) unchanged — it already matched structurally and just inherits the new `MochiGradient.primaryButton` automatically.
- **Bug found immediately**: `./gradlew :app:compileDebugKotlin` failed with `Syntax error: Unclosed comment` at EOF in `Theme.kt`. Root cause: a KDoc comment contained the literal text `docs/figma/*.png` — the sequence `/*` inside `figma/*.png` opened a **nested** block comment (Kotlin, unlike Java/C, supports nested `/* */`), which then closed on the next `*/` (the intended end of the outer KDoc), leaving the actual outer comment unclosed until EOF. Fixed by rewording the comment to avoid the `/*` sequence. **Generalizable gotcha**: any doc comment mentioning a glob path like `foo/*.ext` will hit this in Kotlin.
- **Second bug found while writing `SlidersGlyph.kt`**: initial draft defined private extension functions `DrawScope.drawLine(...)` and `DrawScope.drawCircle(...)` as thin wrappers, but Compose's `DrawScope` already has member functions with those exact names — Kotlin resolves member functions over extensions unconditionally, so the extensions were silently dead code (not a compile error, just unreachable). Removed the wrapper extensions entirely and called `drawLine`/`drawCircle` directly with named args instead. **Gotcha for future glyph files**: don't name a private extension function the same as an existing member on the receiver type — Kotlin won't warn you, it'll just silently prefer the member.
- Full `./gradlew :app:compileDebugKotlin` passed clean after the fix (all 13 pre-existing screens compiled against the new design system with zero other errors, since the new files are additive and the changed ones kept compatible signatures for the most part). Commit `6d287f7`.

### 4. Home screen port
Read `ios/MochiApp/Features/Home/HomeView.swift` (320 lines) in full. Decided to port `HomeMetrics.swift`/`ActionCardTuning` literally into a new `HomeMetrics.kt` (iOS points = Compose dp, 1:1, matching the convention already established by the design-system port) rather than keep Android's prior hand-tuned-against-a-specific-device-density approach (see sibling handoff — that session computed `42.sp` for the logo by reverse-engineering `adb shell wm density` output for one specific screenshot, which doesn't generalize). Simplified two things relative to a literal port: (1) iOS computes `contentWidth`/`carouselCardWidth`/`actionCardWidth` explicitly from `UIScreen.main.bounds.width` because SwiftUI `HStack` children with different content don't self-equalize widths — Compose's `Modifier.weight(1f)` does this natively, so those explicit calculations were dropped in favor of `weight(1f)` + `aspectRatio()` on each card; (2) iOS's `Spacer(minLength:)` (flexible with a floor, used to absorb the 16:9-design-vs-19.5:9-device leftover height) was reproduced as a small `ColumnScope.FlexGap(min: Dp)` helper (`Spacer(Modifier.weight(1f).heightIn(min = min))`), applied identically since Android devices also vary in aspect ratio.
- **Crash on first device run**: `IllegalArgumentException: Padding must be non-negative` at `HomeScreenKt.HomeScreenContent(HomeScreen.kt:112)`, from `.padding(top = HomeMetrics.headerTopPadding)` where `headerTopPadding = -6.dp`. Fixed by switching that one modifier to `.offset(y = HomeMetrics.headerTopPadding)` (offset doesn't have the non-negative restriction padding does).
- Rebuilt, reinstalled (`adb install -r`), launched (`adb shell am start -W -n com.Adam.Mochi/com.mochi.keyboard.MainActivity`), screenshotted (`adb exec-out screencap -p`), read the PNG back via the `Read` tool, and compared side-by-side against `docs/figma/1.png` (also read via `Read`) — confirmed strong visual match. Commit `d8d53a3`.

### 5. Profile screen port
Read `ProfileView.swift` (675 lines) and `ProfileMetrics.swift` (289 lines) in full. Recognized the absolute-canvas-with-3-scale-factors approach is a workaround for iOS having no live preview loop, not something intrinsically necessary — decided to reproduce the same visual result via ordinary Compose `Column`/`Row` flow instead of porting `place(x:y:)`/`placeTrailing`/the `U`/`T`/`A` scale math literally. Cross-referenced `MockData.swift`'s Profile section (lines ~130-183) for the real data (`ProfileSummary`, `profileCreations`, `profileDownloads`, `profileLikedThemes`, `profileFollowRows`) since Android's old `ProfileScreen.kt` had invented its own inline placeholder data instead of using shared `MockData` — added the missing model types to `model/KeyboardTheme.kt` and mirrored the data into `mockdata/MockData.kt`.
- **Missing assets discovered**: checked 8 asset names iOS's `ProfileView`/`MockData.swift` reference against Android's `drawable-nodpi/` — `profile_art_pastel_rainbow`, `liked_pastel_pink_sky`, `liked_pastel_dream`, `liked_pastel_rainbow`, `icon_verified`, `mascot_mochi_pro`, `icon_crown`, `profile_background` were all missing. Copied all 8 directly from `ios/MochiApp/Assets.xcassets/{name}.imageset/{name}.png` into `android/app/src/main/res/drawable-nodpi/{name}.png`.
- Built a small local `profileArt: Map<String, Int>` lookup inside `ProfileScreen.kt` rather than reusing `ThemeArt`/`FontArtCard` — those components apply a `purpleDark`-tinted card shadow that doesn't match this page (shadow here is `black @ 5%` applied once to the whole card, not per-image).
- Compiled clean first try after fixing the import for `ProfileSummary`. Built, installed, navigated via `adb shell input tap` (Community tab in the bottom bar → the creator avatar circle top-right of Community, which is Profile's actual entry point per `AppNavHost.kt`'s `onProfileClick`), screenshotted, compared against `docs/figma/3.png` — strong match. Commit `06b0c23`.

### 6. Search screen — diff against already-close code
Read `SearchView.swift` (437 lines) and Android's existing `SearchScreen.kt` (371 lines) side by side. Found Android's version was already a close structural port (likely from a prior, unlogged pass — not part of this session's earlier work) — narrowed to 5 concrete gaps rather than a rewrite:
1. 2-column results grid (`chunked(2)`) vs iOS/Figma's 4-column (`chunked(4)`) — iOS's own code comment explicitly flags this exact Android/iOS discrepancy ("Android's SearchScreen.kt (chunked(2)) uses a 2-column results grid, but the Figma export clearly shows 4 columns").
2. Per-result "•••" vs "↓" badge was hardcoded to always show `MoreVert` — iOS ties it to each `SearchResult.showMoreBadge: Bool`. Added that field to Android's `ResultItem` and wired the icon choice to it.
3. Font type-filter chip showed a `TextFields` Material icon; iOS shows literal `"Aa"` text.
4. Asset names `font_shop_typewriter_classic`/`font_shop_bold_strong`/`font_shop_gothic_dark` don't exist as keys in `ThemeArt.kt`'s `knownFontArt` map (only `font_bubble_cute`/`font_handwritten_elegant`/`font_typewriter_classic`/`font_bold_strong` are, matching iOS's own `knownFontArt` set exactly) — so those 3 result cards were silently always falling back to the placeholder box regardless of what the code intended. Fixed to the correct un-suffixed names; `font_gothic_dark` deliberately kept OUT of the map (matches iOS's own intentional omission — Gothic Dark has no delivered art yet).
5. Minor: dropdown chevron was a literal `"⌄"` Text character, swapped for `Icons.Filled.KeyboardArrowDown`; no-results subtitle wasn't center-aligned, added `TextAlign.Center`.
- Built, installed, navigated (Community → search bar tap), screenshotted. **First scroll attempt failed silently** — 3 consecutive `adb shell input swipe` calls with 200-300ms duration produced byte-identical screenshots (confirmed by diffing visible content, not just timestamps). Fixed by using a slower, longer swipe (`input swipe 360 1550 360 300 800` — 800ms duration, longer distance) — worked on the first retry. Screenshotted the results grid, compared against `docs/figma/6.png` — confirmed the row-by-row badge logic (first row all "•••", second row all "↓") matches Figma exactly, 4-column layout matches, Gothic Dark's placeholder fallback matches. Commit `dd64423`.

---

## Key Decisions

- **iOS points == Compose dp, 1:1, no re-derivation.** Every `*Metrics.swift` value (radii, gaps, font sizes, offsets) is carried over as the identical number with a `.dp`/`.sp` suffix, rather than recomputed from device density or Figma pixel math independently. This is a continuation of a convention already visible in the pre-existing design-system files (`MochiRadius`/`MochiSpacing` already matched between platforms before this session). Rejected re-deriving values from Figma crops (the sibling handoff's approach) since it doesn't generalize across devices and the iOS values are already the ground truth the client wants matched.
- **Reproduce iOS's *visual result*, not its *layout technique*, on screens where iOS uses absolute-canvas positioning.** iOS's Profile (and per its own comments, also Create) screens use `place(x:y:)`/`placeTrailing` keyed to raw Figma pixel coordinates with 3 scale factors, specifically because the iOS dev has no Mac/Simulator to preview against and needs every number checkable straight against the PNG export. Android has a working device-screenshot loop instead, so this was **deliberately not ported verbatim** — same content/order/sizes/colors, ordinary Compose `Column`/`Row` flow layout instead. Documented inline in `ProfileScreen.kt`'s class doc so a future session doesn't assume the coordinate math needs to match line-for-line.
- **Compose `weight(1f)` + `aspectRatio()` replaces iOS's explicit `UIScreen.main.bounds.width`-derived card-width math.** SwiftUI `HStack` doesn't equalize sibling widths automatically when content differs (that's *why* iOS computes `contentWidth`/`actionCardWidth` explicitly); Compose `Row` + `weight(1f)` does this natively. Same visual result, simpler code, no `BoxWithConstraints` needed (an earlier draft used `BoxWithConstraints` to replicate iOS's math exactly — abandoned in favor of `weight(1f)` once it became clear the explicit width calculation was working around a SwiftUI-specific limitation that doesn't exist in Compose).
- **`Modifier.offset()` for negative values, `Modifier.padding()` for non-negative.** Compose's `padding()` throws on negative values; SwiftUI's doesn't. Any ported `*Metrics` value that's negative must use `offset()` instead. Only applied so far to `HomeMetrics.headerTopPadding`; other negative values in other Metrics files (e.g. `ProfileMetrics.contentTop = -30`) weren't hit because Profile wasn't ported via the same absolute-offset technique — worth checking explicitly on Themes/Fonts/Create if any of iOS's remaining `*Metrics` values turn out to be negative.
- **Small Profile-page-local asset lookup map instead of reusing `ThemeArt`/`FontArtCard`.** Those shared components apply a purple-tinted card shadow that's specific to Home/Themes/Fonts card treatments; Profile's cards use a flat `black @ 5%` shadow on the whole card container instead, matching iOS's `.shadow(color: .black.opacity(0.05), radius: 4, y: 2)`. Reusing the shared components would have applied the wrong shadow color.
- **iOS's own content "quirks" are reproduced, not corrected.** Two examples ported deliberately as-is: Profile's right-hand pair card is headed "Liked Themes" (same as the left card) even though it lists Followers/Following — iOS's own comment says "almost certainly a copy-paste slip... but it is what the frame draws, so it is reproduced." Search's Sweet Handwriting/Bold Strong/Gothic Dark font result names and counts are copied verbatim from iOS's `SearchResult` array, not Android's own previously-invented `ResultItem` list.
- **Left `Buttons.kt` (`GradientButton`/`OutlineButton`) untouched** during the design-system pass — it already matched iOS's `GradientButton.swift`/`OutlineButton` structurally and automatically inherits the corrected `MochiGradient.primaryButton`; no port needed.
- **Checkpoint-commit the screen-by-screen work incrementally** (one commit per screen/pass) rather than one giant commit at the end — confirmed with the user this was the right call implicitly by them repeatedly choosing to pause/check-in between screens rather than "just keep going for hours."

---

## Evidence & Data

### Color hex conversions (iOS `Color(red:green:blue:)` decimals → Android hex), Theme.kt

| Token | iOS decimal (R,G,B) | Hex | Note |
|---|---|---|---|
| `textPrimary` | pure black | `#000000` | was `#251B3C` before this session |
| `textSecondary` | 0.46, 0.44, 0.50 | `#757080` | was `#6B617F` |
| `pinkLight` | 0.976, 0.716, 0.855 | `#F9B7DA` | was `#F9B6DA` (1-level drift) |
| `textMuted` | 170,170,170 /255 | `#AAAAAA` | new — didn't exist |
| `creatorLink` | 151,80,171 /255 | `#9750AB` | new |
| `heart` | 244,67,54 /255 | `#F44336` | new (Material Red 500) |
| `outline` | 138,79,160 /255 | `#8A4FA0` | new |
| `freeChipText`/`Background` | 119,165,9 / 244,246,210 | `#77A509` / `#F4F6D2` | new, Fonts page |
| `proChipText`/`Background` | 253,152,27 / 253,237,198 | `#FD981B` / `#FDEDC6` | new, Fonts page |
| `textGreyWarm` | 138,133,133 /255 | `#8A8585` | new — used by Profile bio + Fonts page |
| `backButtonStart`/`End` | 227,171,244 / 201,121,224 | `#E3ABF4` / `#C979E0` | new |
| `downloadGlyph` | 169,44,192 /255 | `#A92CC0` | new, Themes page |
| `editProfileStroke`/`Ink` | 98,21,112 / 144,18,167 | `#621570` / `#9012A7` | new, Profile — deliberately 2 different colors, not 1 |

### Gradient stop conversions

| Gradient | iOS stops | Used by |
|---|---|---|
| `softButton` | 0%→`#CE76DB`, 32%→`#E27FCC`, 100%→`#8F7CE9` | Home action-card buttons, selected FONTS/THEMES pill, Profile Upgrade Plan pill, "Go Premium" gradient-masked text |
| `fontsAccent` | 0%→`#DE79D3`, 28%→`#E17FCE`, 100%→`#877FE9` | Fonts page selected pill/Apply buttons/"Aa" chip/selected tab icon — NOT YET consumed by any ported screen |
| `themeButton` | 0%→`#E580C9`, 30%→`#E37FCC`, 55%→`#D078DD`, 100%→`#8F7BE9` | Themes page Apply capsule — NOT YET consumed |
| `themeCircleButton` | `#E280CC`→`#BC79E3` | Profile back button, Themes header discs |

### Commit table (this session)

| Hash | Summary |
|---|---|
| `e9d86de` | Restructure Android package to com.mochi.keyboard, wire up IME + Firebase data layer (checkpoint of pre-existing uncommitted work) |
| `6d287f7` | Match design system + shared components to iOS pixel-fidelity pass |
| `d8d53a3` | Port Home screen to match iOS HomeView pixel-for-pixel |
| `06b0c23` | Port Profile screen to match iOS ProfileView |
| `dd64423` | Fix Search screen results grid to match iOS SearchView |

### Screen port status matrix

| Screen | iOS source lines | Android status before session | Android status now | Verified on-device? |
|---|---|---|---|---|
| Home | 320 (+147 HomeMetrics) | Old architecture, own design tokens | Fully rewritten, new HomeMetrics.kt | ✅ vs `docs/figma/1.png` |
| Profile | 675 (+289 ProfileMetrics) | Invented own placeholder data, wrong colors/fonts | Fully rewritten, flow layout not absolute-canvas | ✅ vs `docs/figma/3.png` |
| Search | 437 | ~90% already correct (undocumented prior pass) | 5 targeted fixes | ✅ vs `docs/figma/6.png` |
| Themes | 596 | Pre-dates design-system rewrite | **untouched** | ❌ |
| Fonts | 861 | Pre-dates design-system rewrite | **untouched** | ❌ |
| Create | 826 | Pre-dates design-system rewrite | **untouched** | ❌ |
| Community | 646 | Pre-dates design-system rewrite | **untouched** | ❌ |

### `ActionCardTuning` values (HomeMetrics.kt) — the two Home action cards deliberately do NOT share these

| Field | `customCreate` | `chooseLibrary` |
|---|---|---|
| `hPad` / `vPad` | 19dp / 9.5dp | 24.5dp / 8.5dp |
| `iconSize` | 52dp | 52dp |
| `iconHOffset` / `iconVOffset` | 0dp / 2.5dp | 0dp / 0.5dp |
| `iconTextGap` | 17.5dp | 12.5dp |
| `titleSize` / `titleVOffset` / `titleGap` | 9.5sp / -9dp / 2dp | 9.5sp / -5.5dp / 2dp |
| `subtitleSize` / `subtitleVOffset` | 8.5sp / -6.5dp | 8.5sp / 0dp |
| `buttonWidth` / `buttonHeight` / `buttonTextSize` | 68dp / 22dp / 10sp | 68dp / 22dp / 10sp (same) |

Both cards share the outer box geometry (`HomeMetrics.actionCardRatio = 1.73f`, `actionCardGap = 10.5dp`, `actionCardRadius = 13dp`) — only per-card icon/text tuning differs, because the two icon PNGs have different transparent-bleed proportions (palette art is 1.21:1, library-stack art is 1.05:1) per iOS's own code comment.

### AskUserQuestion decisions this session

| When | Question | Options offered | User picked |
|---|---|---|---|
| Before any code | How to handle the pending uncommitted Android restructure | Commit it first / Leave uncommitted / "You handle git, I won't touch it" | **Commit it first** |
| Before any code | Which screens to port | Just the 7 iOS has / All 13 Android screens (redesign the 6 iOS-less ones too) | **Just the 7 iOS has** |
| Before any code | How to verify | Read source + Figma refs only / Also build+screenshot on device / User reviews visually themself | **Also build + screenshot** |
| After Home done | Pacing for remaining 6 screens | Keep going through all 6 / One more (Profile) then check in / Pause now | **One more (Profile), then check in** |
| After Profile done | Pacing for remaining 5 | Keep going through all 5 / One more (Search) then check in / Pause now | **One more (Search), then check in** |
| After Search done | Pacing for remaining 4 | Keep going through all 4 / One more (Themes) then check in / Pause now | **Pause here for now** ← session ends here |
| Device disconnected mid-Search-verification | How to handle | Reconnect and wait / Commit now, verify later | **Reconnect and wait** (device came back on its own after `adb kill-server`/`start-server`) |

### Device/adb reference

- Phone: model `V2207`, serial `10AC8X2BJ2000OF`
- `adb` full path (not on Bash tool's PATH): `C:\Users\ACER\AppData\Local\Android\Sdk\platform-tools\adb.exe`
- Launch command: `adb shell am start -W -n com.Adam.Mochi/com.mochi.keyboard.MainActivity` (note: `applicationId` is `com.Adam.Mochi`, but the activity's package is `com.mochi.keyboard` — see `android/app/build.gradle.kts` comment on why they differ)
- Screenshot: `adb exec-out screencap -p > path.png`, then read via the `Read` tool (it renders PNGs)
- Community tab is at approx `(622, 1460)` on this device's 720×1612 screen; Profile's avatar entry point at approx `(640, 78)` when on Community; Search bar at approx `(300, 220)` when on Community
- Reliable scroll: `adb shell input swipe {x} {y1} {x} {y2} 800` — short-duration (200-300ms) swipes were silently no-ops in testing; 800ms worked
- **`adb shell am start` without `-W` races the actual UI transition.** First attempt at launching for the Home screenshot used plain `am start -n ...MainActivity` (no error printed, "Starting: Intent{...}" looked normal) — the screenshot taken 3s later still showed the phone's home launcher, not the app. Tried `monkey -p com.Adam.Mochi -c android.intent.category.LAUNCHER 1` next, `dumpsys window | grep mCurrentFocus` confirmed it genuinely hadn't launched (`mCurrentFocus=null`/showed launcher). Root cause turned out to be the crash described below (padding bug), not adb itself, but the *investigation* pattern worth keeping: `am start -W -n {pkg}/{activity}` blocks until launch completes and prints `Status: ok` / `LaunchState:` / `Complete` — use `-W` every time, and check the printed status before assuming the screenshot will show the app rather than whatever was on screen before.

---

## Code Analysis

- **`HomeMetrics.kt`** (`designsystem/`): `ActionCardTuning` data class with 17 fields (padding/icon/title/subtitle/button geometry, split per-card since `customCreate`/`chooseLibrary` have different art proportions — 1.21:1 vs 1.05:1). `HomeMetrics` object has ~25 constants covering header/carousel/action-card/toggle/section-header/theme-row/font-row/tab-bar geometry. All `Dp`/`TextUnit` typed, values copied verbatim from `HomeMetrics.swift`.
- **`ProfileArtImage`** (private, `ProfileScreen.kt`): `private val profileArt: Map<String, Int>` + a composable wrapper around `painterResource` + `ContentScale.Crop`, no shadow, no placeholder fallback (unlike `ThemeArt`) since every asset used on this page is guaranteed to exist.
- **`MochiFont` signatures** (`Typography.kt`): `logo(size: TextUnit = 34.sp)`, `title()`, `heading()`, `itemName()` (new), `body()`, `caption()`, `button()` — all `(size: TextUnit = default.sp) -> TextStyle`. `itemName` didn't exist before this session; several call sites across Home/Profile now use it for names/labels that are Inter Medium weight (matching iOS's `MochiFont.itemName`).
- **`NotchedTabBarShape`** (private class, `MochiTabBar.kt`): implements `Shape`, takes `cornerRadius`/`notchHalfWidth`/`notchDepth: Dp` (defaults 4/50/26), builds a `Path` via `moveTo`/`quadraticTo`/`cubicTo` — each cubic's control points share their own endpoint's y, same trick iOS uses to force a horizontal tangent at the notch's flat-to-curve and curve-to-curve junctions.
- **`SectionHeader`** (`ThemeCard.kt`) new signature: `SectionHeader(title: String, actionTitle: String? = "see all", modifier: Modifier = Modifier, titleSize: TextUnit = 9.sp, actionSize: TextUnit = 9.sp, onAction: () -> Unit = {})` — the two size params are new; Home passes `HomeMetrics.sectionHeaderSize`/`seeAllSize` (10.5sp/10sp).
- **Profile's new model types** (`model/KeyboardTheme.kt`): `ProfileSummary(displayName, handle, bio, avatarAssetName, isVerified, stats: List<Stat>)`, `ProfileCreation(id, name, kind, imageAssetName, likes, downloads)`, `ProfileLikedTheme(id, name, creatorName, imageAssetName, likes)`, `ProfileFollowRow(id, label, value)` — all data classes, all counts/likes as pre-formatted `String` (matching iOS's own choice, since Figma writes "2.4K" beside a bare "128" — no single formatter produces both).
- **Gradient-filled text pattern, established this session, reusable**: Compose's `Text` composable's `style: TextStyle` accepts a `brush: Brush?` param (Compose 1.4+) — used directly for `MochiTabBar`'s selected "Aa" (`TextStyle(brush = MochiGradient.fontsAccent, ...)`) and via `.copy(brush = ...)` on an existing style for Profile's "Go Premium" banner title. This is simpler than iOS's approach (`.mask { Text(...) }` over an invisible copy, needed there because SwiftUI's direct-brush text-fill API is iOS 17+ and the app ships to 16). No masking trick needed in Compose — same visual result, less code.
- **`Color.hsv(hue, saturation, value)`** (`androidx.compose.ui.graphics.Color`) used for `MochiGradient.hueSpectrum` — 12 stops via `(0..11).map { Color.hsv(hue = it * 30f, saturation = 1f, value = 1f) }`, replacing iOS's `Color(hue:saturation:brightness:)` loop. Not yet consumed by any ported screen (Create screen will need it for its saturation/value picker).
- **`Search`'s `ResultItem` badge/asset corrections** (this session's fix, for exact reference):

| Result name | `isFont` | `showMoreBadge` | Asset name (corrected) | Badge shown |
|---|---|---|---|---|
| Pastel Rainbow | false | true | `theme_pastel_rainbow` | ••• |
| Forest Theme | false | true | `theme_forest` | ••• |
| Pastel Pink Sky | false | true | `theme_pastel_pink_sky` | ••• |
| Sweet Handwriting | true | true | `font_typewriter_classic` (was `font_shop_typewriter_classic`) | ••• |
| Sakura Train | false | false | `theme_sakura_train` | ↓ |
| Space vibe | false | false | `theme_space_vibe` | ↓ |
| Bold Strong | true | false | `font_bold_strong` (was `font_shop_bold_strong`) | ↓ |
| Gothic Dark | true | false | `font_gothic_dark` (was `font_shop_gothic_dark`) — deliberately NOT in `knownFontArt`, falls back to placeholder | ↓ |

---

## Files Changed

### Source code (this session)
- `android/app/src/main/java/com/mochi/keyboard/designsystem/Theme.kt` — full rewrite, real hex colors/gradients
- `android/app/src/main/java/com/mochi/keyboard/designsystem/Typography.kt` — full rewrite, real Inter font
- `android/app/src/main/java/com/mochi/keyboard/designsystem/HomeMetrics.kt` — new file, ported from HomeMetrics.swift
- `android/app/src/main/java/com/mochi/keyboard/components/MochiTabBar.kt` — real NotchedTabBarShape, fixed tab icons
- `android/app/src/main/java/com/mochi/keyboard/components/ThemeArt.kt` — added shadows
- `android/app/src/main/java/com/mochi/keyboard/components/ThemeCard.kt` — SectionHeader size params, crown badge fix
- `android/app/src/main/java/com/mochi/keyboard/components/CreateGlyphs.kt` — new file
- `android/app/src/main/java/com/mochi/keyboard/components/SlidersGlyph.kt` — new file
- `android/app/src/main/java/com/mochi/keyboard/components/SparkleField.kt` — new file
- `android/app/src/main/java/com/mochi/keyboard/features/home/HomeScreen.kt` — full rewrite
- `android/app/src/main/java/com/mochi/keyboard/features/profile/ProfileScreen.kt` — full rewrite
- `android/app/src/main/java/com/mochi/keyboard/features/search/SearchScreen.kt` — 5 targeted fixes
- `android/app/src/main/java/com/mochi/keyboard/model/KeyboardTheme.kt` — added Profile model types
- `android/app/src/main/java/com/mochi/keyboard/mockdata/MockData.kt` — added Profile mock data

### Assets (new, copied from iOS asset catalog)
- `android/app/src/main/res/font/inter_{regular,medium,semibold,bold}.ttf`, `android/licenses/Inter-OFL.txt`
- `android/app/src/main/res/drawable-nodpi/icon_tab_themes.png`
- `android/app/src/main/res/drawable-nodpi/{profile_art_pastel_rainbow,liked_pastel_pink_sky,liked_pastel_dream,liked_pastel_rainbow,icon_verified,mascot_mochi_pro,icon_crown,profile_background}.png`

### Not committed / not touched (pre-existing, other work streams)
- `.gitignore`, `firestore/tests/package{,-lock}.json`, `ios/MochiApp/App/RootView.swift`, `ios/MochiApp/Components/ThemeArt.swift`, `ios/MochiApp/Features/{Search,Themes}/*.swift`, `ios/MochiUITests/ScreenshotUITests.swift`, `ios/README.md`, `docs/figma/{1.1 (2),2.2}.png`, `firestore/tests/seed.mjs`, `uiA.xml`, `uiB.xml` — left exactly as found

---

## User Feedback & Preferences

- "The UI i made for the Android is not that good. I worked on IOS its UI is almost done and its preety good. I want you to implement that For android exactly same as i did for IOS." — the original ask, establishes iOS as ground truth over Figma directly wherever the two differ.
- Chose "Commit it first" when asked how to handle the large pending uncommitted restructure — prefers a clean checkpoint before new work stacks on top.
- Chose "Just the 7 iOS has" over also redesigning the 6 Android-only screens — scope discipline, don't invent UI with no reference.
- Chose "Also build & screenshot Android as I go" for verification — wants visual proof, not just "the code looks like a port."
- After Home screen: chose "One more (Profile), then check in again" rather than either "keep going through all" or "pause now" — establishes a pattern of wanting a checkpoint after each screen rather than a single long unsupervised run, but also not wanting to stop after just one.
- Same choice repeated after Profile ("One more (Search), then check in") and after Search ("Pause here for now") — the checkpoint-after-each-screen cadence held consistently for 3 rounds before the user chose to actually pause, suggesting future sessions should default to this same one-screen-then-ask rhythm rather than assuming permission to do all remaining screens in one unsupervised pass.
- When the device disconnected mid-session, given the choice between "reconnect and verify" vs "commit now, verify later" — chose to wait for reconnection rather than skip verification, reinforcing that on-device confirmation is a hard requirement, not a nice-to-have.

---

## Where We're Going

1. **Port Themes screen** (`ios/MochiApp/Features/Themes/ThemesView.swift`, 596 lines) against `docs/figma/8.png` — next in the client's implied per-screen queue. Likely needs `MochiGradient.themeButton`/`themeCircleButton`/`themeBadge` (already ported into `Theme.kt` but not yet consumed by any screen) and the `DownloadGlyph`/`SlidersGlyph`/`FunnelGlyph` components (already ported, unused so far).
2. **Port Fonts screen** (`FontsView.swift`, 861 lines — the largest) against `docs/figma/5.png`. Likely needs `MochiGradient.fontsAccent` (ported, unused) and the Fonts-page-specific colors (`freeChipText/Background`, `proChipText/Background`, `textGreyWarm`, `badgePink`, `backButtonStart/End` — all ported, unused).
3. **Port Create screen** (`CreateThemeView.swift`, 826 lines) against `docs/figma/4.png`. This is the screen iOS itself lays out via absolute-canvas positioning (like Profile was) — apply the same "reproduce the visual result via flow layout, not the coordinate math" decision. Needs `ColorWheelGlyph`, `HexagonShape`, `FloppyGlyph`, `KeycapGlyph` (all ported in `CreateGlyphs.kt`, unused so far) and `MochiGradient.editorPill`/`tagPill`/`keyShapePreview`/`hueSpectrum`/`pickerHue` (all ported, unused).
4. **Port Community screen** (`CommunityView.swift`, 646 lines) against `docs/figma/2.png`.
5. Each of the above: read the iOS source in full, diff against the current Android file (check whether it's a "close, targeted fixes" case like Search or a "full rewrite" case like Home/Profile — inspect first rather than assuming), port, `./gradlew :app:compileDebugKotlin` then `:app:assembleDebug`, install+launch+screenshot on the phone, compare against the matching `docs/figma/N.png`, commit, then check in with the user before continuing to the next screen (see User Feedback pattern above — don't assume permission for more than one screen at a time unless explicitly told to keep going).
6. Once all 7 screens are done: consider whether the checkpoint-per-screen commits should be pushed to the remote (`git push` was never run this session — everything is local-only on `master` so far). Not yet asked.
7. Not in scope per the user's own scoping choice, but worth flagging when all 7 are done: the 6 Android-only screens (Auth, Onboarding, Settings, Paywall, ThemeDetail, Wallpapers) still use whatever colors/fonts they had before this session's design-system rewrite — they'll now visually clash with the 7 newly-matched screens since they're on old tokens. Ask the user whether/when to reconcile.

---

## Risks & Blockers

- **Themes/Fonts/Create/Community are unverified against the new design system.** They compiled clean as of the last full build (`6d287f7`'s compile check covered all files including these), but "compiles" ≠ "looks right" — they still reference old `MochiColor`/`MochiGradient` members that still exist (nothing was removed, only added/changed), so they'll render with a mix of old approximated colors and the new real ones until each is actually ported.
- **No `git push` this session.** All 5 commits are local-only on `master`. If this is meant to sync to a remote for the client to see, that's an outstanding step.
- **Device disconnection is unexplained.** Happened once, resolved itself after `adb kill-server`/`start-server` + wait — if it recurs and blocks verification, there's no deeper diagnosis to fall back on yet (cable, USB debugging toggle, and phone sleep/lock were not individually ruled out).
- **`app-debug.apk` on the phone right now reflects the `dd64423` (Search-fix) build**, last screen shown was Search's results grid mid-scroll. Next session should expect to reinstall after any further changes, not assume the currently-installed APK is stale-but-representative.
- **All screenshots taken this session live in the session-specific scratchpad** (`C:\Users\ACER\AppData\Local\Temp\claude\...\scratchpad\`) and will **not** persist into a new session — same caveat the sibling handoff already flagged for its own crop PNGs. Re-screenshot from the device if a visual reference is needed again; `docs/figma/*.png` are the only durable image sources.

## Open Questions

- Should the per-screen commits be pushed to the remote now, or batched until all 7 screens are done?
- Once all 7 are ported, does the user want the 6 Android-only screens reconciled to the new design tokens too (a natural follow-on, but explicitly out of scope for this pass per the user's own "just the 7 iOS has" choice)?
- Is there a reason Search was already ~90% ported before this session started (an untracked/unlogged prior pass), and could Themes/Fonts/Create/Community have similarly-undocumented partial progress worth checking for before assuming a full rewrite is needed? (Worth a quick diff-first pass on each, as done for Search, rather than assuming Home/Profile's "full rewrite" pattern by default.)

---

## Quick Start for Next Session

```bash
# Verify current state
cd C:\Users\ACER\Desktop\MOCHI
git log --oneline -6
git status -s          # expect only pre-existing, unrelated dirty files (ios/, firestore/tests/, docs/figma/, uiA.xml/uiB.xml)

# Reference: this session's design system + Home/Profile as worked examples
android/app/src/main/java/com/mochi/keyboard/designsystem/Theme.kt
android/app/src/main/java/com/mochi/keyboard/designsystem/HomeMetrics.kt      # pattern to follow for a *Metrics.kt per screen if needed
android/app/src/main/java/com/mochi/keyboard/features/home/HomeScreen.kt     # "full rewrite" pattern
android/app/src/main/java/com/mochi/keyboard/features/search/SearchScreen.kt # "targeted diff fixes" pattern — check this first for each remaining screen

# Next screen's iOS source (read in full before touching Android code)
ios/MochiApp/Features/Themes/ThemesView.swift
docs/figma/8.png    # the Figma reference to screenshot-compare against

# Build + verify
cd android
./gradlew.bat :app:compileDebugKotlin   # fast correctness check first
./gradlew.bat :app:assembleDebug        # full APK build

# Device (phone: V2207, serial 10AC8X2BJ2000OF)
SDK="/c/Users/ACER/AppData/Local/Android/Sdk"
"$SDK/platform-tools/adb.exe" devices
"$SDK/platform-tools/adb.exe" install -r android/app/build/outputs/apk/debug/app-debug.apk
"$SDK/platform-tools/adb.exe" shell am start -W -n com.Adam.Mochi/com.mochi.keyboard.MainActivity
"$SDK/platform-tools/adb.exe" exec-out screencap -p > /path/to/scratchpad/screenshot.png
# then Read the PNG and docs/figma/N.png side by side to compare

# Next action
# Read ThemesView.swift in full, diff against current ThemesScreen.kt (check if it's a
# Search-style "mostly there, targeted fixes" case or a Home/Profile-style full rewrite
# before assuming). Port, verify on-device, commit, then check in with the user before
# moving to Fonts — the established pattern this session is one screen, then ask.
```
