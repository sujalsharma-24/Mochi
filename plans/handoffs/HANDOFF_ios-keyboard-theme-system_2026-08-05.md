# iOS keyboard theme system — token architecture, contrast validation, and two built-in themes

**Date:** 2026-08-05
**Status:** IN PROGRESS
**Bead(s):** none
**Epic:** none
**Chain:** `standalone-05c7153e` seq `1`
**Parent:** `none — first in chain`
**Prior chain:** none — first in chain

---

## Related Handoffs

- `plans/handoffs/HANDOFF_home-screen-figma-parity_2026-07-16.md` — Android Home screen Figma parity
  (chain `standalone-ef2fd53b`). **Separate work stream**, not a parent. Different platform, different
  surface, no overlap with the keyboard extension.

## Reference Documents

- `docs/keyboard-theme-system.md` (288 lines) — **the architecture doc written this session.** Read first.
- `docs/keyboard-theme-assets.md` (125 lines) — generic asset spec for future themes.
- `docs/theme-fantasy-castle-night-assets.md` (898 lines) — per-asset generation prompts for FCN.
- `docs/TRD.md` — pre-existing. ADR-002 (UIKit + CAEmitterLayer, not SwiftUI/SpriteKit in the
  extension) and ADR-006 (no Firebase in the extension process) are both load-bearing here and were
  independently re-confirmed by this session's research.
- `docs/PRODUCTION_PLAN.md` — pre-existing, untracked. Frames the keyboard extension as W1, "30-40%
  of remaining effort".
- `~/.claude/projects/-Users-Tanmay-Desktop-Projects-Mochi/memory/` — `MEMORY.md` index plus
  `mochi_ios_technical_notes.md` (updated this session with three new gotchas).

## The Goal

Build a production-quality iOS keyboard theme system for Mochi — explicitly **not** a wallpaper
overlay. The user asked for keys, backgrounds, spacing, materials and contrast that all feel
intentional and readable, architected to scale to many themes but with one theme perfected first.
Mid-session the scope extended: make the keyboard actually *functional* as a keyboard, then rebuild
"Fantasy Castle Night" — an existing marketing render in the app catalogue — as a real theme with
per-key illustrations. The user's standing instruction throughout: prioritise accuracy,
maintainability and production quality over speed, and if an implementation path isn't working,
explain why, compare alternatives, and switch rather than force it.

## Where We Are

- **5,135 lines of new Swift/shell** across `ios/MochiShared/`, `ios/MochiKeyboard/`, `ios/Tools/`,
  and three new files in `ios/MochiApp/`. Nothing committed yet — all untracked or modified.
- **`MochiKeyboard` extension target now exists** and is embedded in `MochiApp.app/PlugIns/`
  (3.2 MB). It did not exist at session start — `project.yml` had only `MochiApp` and `MochiUITests`.
- **Both built-in themes pass the validator**, including per-pixel checks against real artwork.
  Build is clean: **0 errors, 0 warnings** (`xcodebuild ... -destination 'generic/platform=iOS Simulator'`).
- `MochiShared/Theme/MochiKeyboardTheme.swift` — the theme document. `Codable`, versioned
  (`currentSchemaVersion = 1`), lenient decoding, `keyStyles: [KeyRole: KeyStyle]`.
- `MochiShared/Theme/ThemeTokens.swift` (528 lines) — `ThemeFill`, `ThemeBorder`, `ThemeShadow`,
  `KeyRole`, `KeyStyle`, `KeyGlass`, `ThemeSurface`, `ThemeBackgroundImage`, `ThemeScrim`,
  `ThemeTypography`, `ThemeChrome`, `KeyArtSet`, `ThemeEffects`.
- `MochiShared/Theme/ThemeColor.swift` — sRGB colour + WCAG luminance/contrast maths.
  **Foundation-only behind `#if canImport(UIKit)`**, which is what lets the host-side validator run.
- `MochiShared/Theme/ThemeValidator.swift` — the legibility gate. 4.5:1 labels, 3:1 caps,
  pressed-state checks, press-ΔL check, art-missing fallback check, chrome-ink check.
- `MochiShared/Theme/ThemeStore.swift` — App Group read/write. App writes, extension reads.
  `appGroupIdentifier = "group.com.mochi.app"`. Falls back to `BuiltInThemes.default` when the
  container is nil (which is the current state — no entitlement provisioned).
- `MochiShared/Layout/KeyboardMetrics.swift` — device-adaptive metrics fitted to the *system*
  keyboard. `keyHeight = 0.0727 * width + 15.727` (portrait), landscape pinned to 33pt.
- `MochiShared/Layout/KeyboardLayout.swift` (355 lines) — `KeyAction`, `KeyboardPlane` (letters /
  numbers / symbols / emoji), `KeyWidth`, `KeyDefinition`, `KeyRow`, `KeyboardLayoutSolver`.
  `KeyDefinition.artIdentity` maps action → illustration asset key.
- `MochiShared/Render/KeyboardSurfaceView.swift` (516 lines) — **the single shared renderer** used by
  both the extension and the in-app preview/test bench.
- `MochiShared/Render/KeyView.swift` (390 lines) — one themed cap: `capLayer` (gradient + border),
  `glossLayer`, `artClipView`/`artView`, `innerShadowLayer`, `bevelLayer`, label, icon.
- `MochiShared/Input/KeyboardInputEngine.swift` (212 lines) — all typing behaviour, view-free,
  driven through a `TextDocumentAdapter` protocol. Two adapters: `ProxyTextDocument` (real host) and
  `BufferTextDocument` (plain string, for the in-app bench).
- `MochiShared/Themes/BuiltInThemes.swift` (426 lines) — `cozySakuraCafe` and `fantasyCastleNight`.
- `ios/Tools/validate-themes.sh` — compiles + runs the host validator. ~1 second, no simulator,
  no Xcode project, no signing identity.
- `ios/Tools/run-theme-lab.sh` — build + install + launch the DEBUG Theme Lab in the simulator.
- `ios/SharedAssets/KeyboardArt.xcassets` — 32 imagesets, 1.5 MB total, included in **both** targets.
- **Typing works**: insert, backspace with accelerating repeat, shift/caps-lock, auto-capitalisation,
  double-space period, long-press accents, plane switching, emoji panel, completions bar.
- **4 key illustrations still missing**: `q`, `e`, `t`, `return` (see Evidence).
- Simulator used throughout: **iPhone 16 Pro, UDID `FA5DF16D-851C-453B-B9D2-963B4361154A`**, Xcode 26.6,
  iOS 26 SDK, deployment target iOS 16.0.

## What We Tried (Chronological)

1. **Research pass — Apple archive + measurement tables.** Fetched the archived App Extension
   Programming Guide (custom keyboard chapter), `configuring-a-custom-keyboard-interface`, KeyboardKit,
   and the `zoul/ios-keyboards` + `normnorm/norm-keyboard` measurement tables. Modern HIG pages are
   JS-rendered and returned only titles — used the docs JSON API and the archive instead rather than
   quoting unverifiable snippets. Result: constraints list (no mic, no secure fields, no drawing above
   the input view's top edge) plus three measured key-height anchors.

2. **Assumed `UIVisualEffectView` would give frosted-glass keys — OVERTURNED.** A keyboard extension
   draws into a separate remote window with no access to the host app's hierarchy, so a blur view has
   nothing to sample. The "frosted over the app" look is simply unavailable. Switched to blurring
   *our own* art once at decode (`ThemeImageLoader.blurred`). This changed the architecture before any
   code was written.

3. **Hand-computed the first theme's contrast — WRONG, built a validator instead.** My arithmetic
   passed the reference theme; the validator immediately found three real failures (return pressed
   label 3.91:1, space pressed 3.18:1, system press ΔL 0.027). Every subsequent colour decision was
   measured, not reasoned.

4. **Hex storage broke JSON round-trip.** `alpha: 0.94` became `0.9412` after encode/decode, so
   document equality failed. Fixed by quantising every `ThemeColor` channel to 8 bits at construction —
   displays are 8-bit anyway, and it makes every colour exactly representable in its own storage format.

5. **Press-state direction — three passes.** (a) Uniform darkening for consistency → system keys
   measured ΔL 0.027, a tap that barely looks like it registered. (b) Lightening, the way the system
   keyboard treats dark keys → white label dropped to 3.88:1, because a mid-luminance cap is too dark
   for dark ink and too light for white. (c) Darken *harder*, leaving the mid-luminance zone entirely →
   ΔL 0.061 and label past 9.7:1. Conclusion recorded in code: there is no ink that works at
   mid-luminance, so the cap has to leave it.

6. **Tried to screenshot the system keyboard beside ours for grid comparison — FAILED, switched.**
   The simulator suppresses the software keyboard while a hardware keyboard is connected;
   `defaults write com.apple.iphonesimulator ConnectHardwareKeyboard -bool false` did not take on an
   already-booted device, and SwiftUI `@FocusState` set in a bare `onAppear` is dropped (needs an
   `asyncAfter` delay). Rather than keep forcing it, switched to measuring **our own render** at the
   pixel level and comparing against the published anchor tables. That verified the part under our
   control and is recorded in `docs/keyboard-theme-system.md` §4.

7. **SF Symbol point size was a no-op.** Shift/backspace/globe rendered at full cap height regardless
   of `UIImage.SymbolConfiguration(pointSize:)`, because `UIImageView.contentMode = .scaleAspectFit`
   *upscales* to the view's bounds. `.center` is what makes point size an actual control.

8. **Cozy Sakura Café scrim — measured sweep, not a guess.** First pass at 0.28 top measured backdrop
   luminance 0.452 under the top row and pale caps at 1.98:1. Swept three values (table below);
   0.62/0.50 is a measured floor. Counter-intuitively the scrim is *stronger at the top*, because that
   plate's bright content (lanterns, moon) sits along the top edge where the top key row lands.

9. **Built `ArtBackdropCheck`** — per-pixel legibility against the real artwork, reproducing the
   renderer's aspect-fill crop, vertical anchor and scrim, then walking every pixel under every solved
   key frame. Labels judged worst-case; caps judged by **99% area coverage** (documented and
   deliberately relaxed, see Key Decisions).

10. **Fantasy Castle Night — sampled colours double-counted the darkening.** Pulled `#BBA1FB`/`#8B78F9`
    off the reference render, but those samples *already included* the background showing through.
    Using them as a fill and compositing over the plate again dropped near-black ink to 3.9–4.4:1.
    Corrected by lightening — but then over-corrected to 7.58:1, which read as pale rectangles pasted
    over the scene. Measured the *reference's own* caps at 5.59:1 and landed at 5.94:1.

11. **Illustrations looked small and floating — root cause was aspect-fit.** A tall motif (the lit
    tower on D) got scaled down until it fitted the band's height, leaving dead space either side.
    Switched to aspect-**fill** inside a rounded clip container flush to the cap's bottom edge, so art
    spans the full width and bleeds off both sides before being trimmed to the cap shape.

12. **Tried to recover baked-in checkerboard alpha mathematically — ABANDONED.** Four delivered assets
    had the transparency checkerboard painted as pixels. The checker is a known regular pattern so alpha
    is solvable in principle (modulation-amplitude approach against a synthetic sign map), but period
    detection would not lock on (returned 4 instead of 58/45) and reconstructed alpha fringes badly on
    soft cloud edges, which is most of what those four contain. Switched to requesting regeneration.

13. **Space bar rescued rather than regenerated.** Re-examined and found the checkerboard confined to
    the left ~10% of columns; cropped it off and the panorama is now in use. This reduced the
    regeneration ask from 5 files to 4.

14. **Background anchor cropped the moon.** `verticalAnchor: 0.58` sliced the crescent moon, which is
    the theme's most recognisable element. Moved to 0.10; the ~13% lost to the aspect crop now comes
    off the bottom where the lake just ends sooner.

15. **Caps read "plain" — added a `KeyGlass` treatment.** A gradient fill plus one flat border is a
    coloured box regardless of colour tuning. Added an **inner bevel** (gradient masked by a stroked
    inset rounded rect) and an **inner shadow** (even-odd path filled outside the cap, masked away,
    keeping only the shadow cast inward — Core Animation has no inner-shadow property). Both drawn
    *above* the key artwork, because a pane's edge is in front of what's inside it.

16. **A `cd ios && python3 …` heredoc silently no-op'd.** The `cd` failed (already in `ios/`), `&&`
    short-circuited, python never ran — but the *next* line's build succeeded, so it looked fine. The
    first glass render came back visually unchanged. Caught by grepping for `bevelLayer` and finding
    zero matches. **Verify edits landed, don't infer from a green build.**

## Key Decisions

- **A theme is a token document, never a picture of a keyboard.** Everything follows from this. A baked
  image cannot be correct across device widths, orientations, key planes and text sizes, and it makes
  legibility a property of the artwork rather than of the product.
- **`RequestsOpenAccess: false` — Full Access is never requested.** The sandbox lets an extension *read*
  the App Group but not *write* it, so the design leans on that: app writes, extension reads. Rejected
  alternative: request Full Access for convenience — it shows a sheet warning the user the keyboard may
  transmit everything they type (the biggest onboarding drop-off), and App Review 4.4.1 requires the
  keyboard to work fully without it anyway. The only things it buys are `playInputClick` and haptics.
- **`MochiShared` compiled into both targets as plain sources, not an SPM package or framework.**
  Deviates from TRD's "Swift Package" wording, deliberately: a dynamic framework costs a `dyld` load on
  every keyboard activation (every text-field tap). Folder is kept package-ready so promotion is a
  `project.yml` change plus `public` annotations.
- **Four `KeyRole`s, not per-key styling** — a theme must survive being applied to layouts it was never
  authored against. Per-key *illustrations* are a separate concern (`KeyArtSet`, addressed by
  `artIdentity`), which is the one place per-key genuinely is the point.
- **Cap-vs-backdrop over artwork uses 99% area coverage, not worst pixel.** Rejected the stricter rule
  explicitly: a cap's boundary is also carried by its drop shadow and top highlight, which the pixel
  test doesn't model, and demanding every pixel clear 3:1 forces a scrim heavy enough to flatten the art
  into a dark rectangle. **Labels stayed worst-case-strict** — there's no averaging your way out of text.
- **No autocorrect.** The bar offers candidates but never silently replaces typed text; verbatim input
  is always offered first in full-strength ink. Real autocorrect needs an n-gram model plus a touch
  model; a half-built one that changes words unasked is worse than none.
- **Emoji catalogue curated (~350) rather than exhaustive (~3,800).** TRD cites a postmortem measuring
  ~120 MB of retained CoreText glyph cache from rendering the full set, against a ~30–48 MB ceiling.
- **Separate `KeyboardArt.xcassets` for the extension**, not the app's 22 MB `Assets.xcassets`. The two
  are separate bundles and the extension can't afford the app catalogue.
- **The mic key became the emoji key.** Apple gives custom keyboards no microphone access, so it would
  be a dead key, and App Review 4.4.1 forbids repurposing a key for other behaviour.
- **Scrim polarity is per-theme, not a constant.** Cozy Sakura Café has near-white ink so its scrim
  pushes the backdrop *down* (0.62/0.50); Fantasy Castle Night has near-black ink so every point of
  darkening costs contrast, and its scrim only tames the brightest spots (0.26/0.18).
- **Input logic extracted to `KeyboardInputEngine` behind `TextDocumentAdapter`** so the in-app test
  bench runs *production* code. Rejected alternative: a SwiftUI mock keyboard for previewing — it
  guarantees drift, and "the theme I previewed isn't the theme I got" is the expensive bug in a
  marketplace.

## Evidence & Data

### Final validator output (both themes PASS)

| Theme | Role | Label | Cap | Pressed label | Press ΔL |
|---|---|---|---|---|---|
| Cozy Sakura Café | input | 9.48:1 | 10.71:1 | 6.30:1 | 0.218 |
| Cozy Sakura Café | system | 5.98:1 | 2.58:1* | 9.78:1 | 0.061 |
| Cozy Sakura Café | action | 5.46:1 | 5.88:1 | 4.85:1 | 0.161 |
| Cozy Sakura Café | space | 5.54:1 | 8.45:1 | 5.09:1 | 0.164 |
| Fantasy Castle Night | input | 5.94:1 | 4.09:1 | 4.95:1 | 0.055 |
| Fantasy Castle Night | system | 5.66:1 | 3.90:1 | 4.83:1 | 0.046 |
| Fantasy Castle Night | action | 5.94:1 | 4.09:1 | 4.95:1 | 0.055 |
| Fantasy Castle Night | space | hidden ink | 1.62:1* | hidden ink | 0.058 |

`*` below 3:1 by design — these caps carry a border, which the validator treats as satisfying
separation. Fantasy Castle Night's caps *all* have rims, which is why its art-check coverage numbers
are 0–65% and still pass.

### Cozy Sakura Café scrim sweep (measured against real art)

| Scrim top/bottom | Worst caps | Verdict |
|---|---|---|
| 0.28 / 0.45 | pale caps 1.98:1, backdrop L 0.452, 1.4% of key area over threshold | fail |
| 0.45 / 0.42 | Q 97.3%, W 96.4% coverage | fail |
| 0.55 / 0.46 | Q 98.7%, W 98.3% coverage | fail |
| **0.62 / 0.50** | **Q 99.3%, W 99.5%** | **shipped** |
| 0.78 / 0.60 | 0.0% over threshold, art visibly flattened | rejected — over-corrects |

### Geometry verification — iPhone 16 Pro (402pt), measured from our own render

| Metric | Intended | Measured |
|---|---|---|
| Key width | 34.0pt | 34.0pt |
| Column gap | 6pt | 6pt |
| Key height | 46pt | 46pt |
| Side inset | 4pt | 4pt |
| Home row indent | 20pt | 20pt |
| Shift↔Z flanking gap | 14.8pt | 14.8pt |
| Total height (no bar) | 231pt | 227pt band measured |

System-keyboard anchors the fit was built from: 39pt @320, 43pt @375, 46pt @414 — one linear fit
reproduces all three within a tenth of a point.

### Fantasy Castle Night asset delivery — 30 of 34 accepted

| File | Status |
|---|---|
| `themebg_fantasy_castle_night` | accepted — 1424×1105 delivered, cropped/resampled to 1320×1020, HEIC q90, 416 KB |
| 23 letter illustrations | accepted |
| `shift` `backspace` `123` `globe` `emoji` | accepted (1024×1024 delivered) |
| `space` | **rescued** — checkerboard confined to left 10%, cropped, now 620×175 PNG, 132 KB |
| `keyart_fcn_q` | **MISSING — never delivered** |
| `keyart_fcn_e` `_t` `_return` | **checkerboard painted in as pixels, fully opaque** |

Two files arrived with a leading space in the filename (` keyart_fcn_k.png`, ` keyart_fcn_z.png`) —
renamed during ingest.

### Fantasy Castle Night press-state iteration

| Pressed fill | Press ΔL | Pressed label | Verdict |
|---|---|---|---|
| `#B5A6EE`/`#9384DA` @0.94 | 0.025 | 5.48:1 | too subtle |
| `#9E8DDF`/`#8271CB` @0.94 | 0.087 | 4.37:1 | ink fails AA |
| **`#A897E6`/`#8C7BD4` @0.94** | **0.055** | **4.95:1** | **shipped** |

Space bar needed its own pass: at the letters' values it measured **ΔL 0.002**, because a 30%-opacity
resting cap over this backdrop lands at almost exactly the luminance of a darker, *more opaque* pressed
one. Translucency makes press feedback non-obvious to reason about — it has to be measured.

### Sampled colours — Fantasy Castle Night reference render

| Role | Hex |
|---|---|
| Cap fill top | `#BBA1FB` |
| Cap fill bottom | `#8B78F9` |
| Rim highlight | `#DDC8FB` |
| Letter ink (darkest core) | `#020344` |
| Sky top | `#221F97` |
| Sky behind keys | `#765ADC` |
| Sky bottom | `#A771ED` |

Reference caps measure **5.59:1** against their own ink — the ceiling this theme was tuned toward.

### New source inventory (5,135 lines)

| Area | Lines |
|---|---:|
| `MochiShared/Theme/` | 1,182 |
| `MochiShared/Render/` | 1,668 |
| `MochiShared/Layout/` | 468 |
| `MochiShared/Input/` | 509 |
| `MochiShared/Themes/` | 426 |
| `MochiKeyboard/` | 123 |
| `MochiApp/` (bench, preview, harness) | 272 |
| `Tools/` | 487 |
| Docs (3 files) | 1,311 |

### Research sources and what each one settled

| Source | What it settled |
|---|---|
| [App Extension Programming Guide — Custom Keyboard](https://developer.apple.com/library/archive/documentation/General/Conceptual/ExtensibilityPG/CustomKeyboard.html) (archived) | The constraint list. Still the only place Apple states the sandbox rules plainly. |
| [Configuring a custom keyboard interface](https://developer.apple.com/documentation/uikit/configuring-a-custom-keyboard-interface) | Current API contract: height via Auto Layout, width fixed by system, `needsInputModeSwitchKey`, trait handling. |
| `zoul/ios-keyboards` + `normnorm/norm-keyboard` Dimensions.md | Two **independent** measurement tables of the system keyboard that agree — the anchors the metric fit is built on. |
| [KeyboardKit](https://github.com/KeyboardKit/KeyboardKit) | Structural reference for a theme→style-service architecture. Not a dependency. |
| [KeyboardKit — Liquid Glass post](https://keyboardkit.com/blog/2025/07/28/custom-ios-keyboard-extensions-and-liquid-glass) | iOS 26 moved key labels *up* in weight; informed typography weight 0.23–0.4. |
| [Apple Developer Forums thread 793686](https://developer.apple.com/forums/thread/793686) | The iOS 26 "grey bar above the keyboard" reports → transparent input view fix. |
| `UIInputView.Style.keyboard` + extension windowing threads | **Overturned an assumption**: a keyboard extension cannot blur host-app content. |
| Apple App Store "Sufficient Contrast" criteria | Apple evaluates against the WCAG formula → validator uses that exact formula. |

Medium/TikTok results were deliberately skipped per the user's "skip low-quality blogs" instruction.

### Apple platform constraints the design had to absorb

| Constraint | Consequence in this codebase |
|---|---|
| No microphone access | The reference render's mic key became the emoji key |
| Cannot draw above the input view's top edge | `KeyCalloutView` flips **below** the key on the top row |
| Cannot type into secure text fields | System keyboard takes over; nothing to implement |
| Ineligible for `.phonePad` / `.namePhonePad` | Same |
| No App Group **write** without Full Access | One-directional `ThemeStore`: app writes, extension reads |
| `playInputClick` needs Full Access | No key click sounds; no haptics |
| Guideline 4.4.1 | Must work fully without Full Access; globe key mandatory |
| iOS 26 Liquid Glass hosts wrap the keyboard | `view.backgroundColor = .clear` **and** `inputView?.backgroundColor = .clear`, unconditionally — there is no API to ask whether the host adopted Liquid Glass |

### Typing behaviour — implemented vs deliberately not

| Behaviour | State | Detail |
|---|---|---|
| Insert / delete | done | — |
| Backspace repeat | done | 0.45s → 0.09s → 0.04s after 11 ticks |
| Shift / caps lock | done | 3-case `ShiftState`; double-tap within 300ms locks; glyph → `capslock.fill` |
| Auto-capitalisation | done | Doc start + after `. ! ?`; respects host `autocapitalizationType`; caps lock outranks |
| Double-space period | done | Only when prior char is letter/digit, so `?  ` is left alone |
| Long-press accents | done | `AccentMap`, system order, cased to current shift state |
| Plane switching | done | letters / numbers / symbols / emoji |
| Emoji panel | done | 9 categories, ~350 emoji, `UICollectionView` reuse |
| Completions bar | done | `UITextChecker` + `UILexicon`, 3 slots, group-centred |
| **Autocorrect** | **deliberately not** | Would need n-gram + touch model; half-built is worse than none |
| Space-bar cursor drag | not built | — |
| Number row | not built | — |
| Haptics / key click | blocked | Requires Full Access |
| Particle effects | tokenised, off | `ThemeEffects.isEnabled = false`; TRD ADR-002 fixes impl as `CAEmitterLayer` |

### `KeyGlass` values in use

| Theme / role | Bevel colour | Width | Falloff | Inner shadow | Opacity | Radius |
|---|---|---:|---:|---|---:|---:|
| FCN input/action | `#FFFFFF` @0.85 | 1.2 | 0.50 | `#2A1E6E` | 0.45 | 3.5 |
| FCN system | `#FFFFFF` @0.78 | 1.2 | 0.50 | `#2A1E6E` | 0.42 | 3.5 |
| FCN space | `#FFFFFF` @0.80 | 1.2 | 0.70 | `#2A1E6E` | 0.40 | 4.0 |
| Cozy Sakura input | `#FFFFFF` @0.55 | 1.0 | 0.40 | `#2E1B52` | 0.22 | 2.5 |

Cozy Sakura is dialled back on purpose — its caps are near-opaque pastel, not glass, and a heavy bevel
there reads as a mistake rather than a material.

### Cozy Sakura Café — theme summary (the reference/default theme)

- Art-free identity is intact: three-stop night gradient `#221342` → `#35205E` → `#4E2C68` is the
  art-missing fallback the validator checks against, and shows through the 6–14% cap translucency.
- Background plate delivered earlier in the session: ChatGPT Landscape 4:3, cropped to 1320×1020,
  HEIC q90, **360 KB**.
- Caps: `#EFE9FA`/`#DCD2F0` @0.94, ink `#2B1B4F`. System caps darker with a load-bearing 1pt rim
  (they measure 2.58:1 on fill alone). Return is the one warm key — lantern rose `#F0A0C4`/`#E07FAC`
  — and gained a warm rim after measuring 94% cap coverage against the art.
- `verticalAnchor: 0.56`, `blurRadius: 0`, scrim `#1A0E30`@0.62 → `#140A28`@0.50.

### Fantasy Castle Night — illustration inventory

33 distinct motifs, read off zoomed crops of `theme_fantasy_castle_night.png` (634×474), **not
guessed**. Full per-key table with generation prompts lives in
`docs/theme-fantasy-castle-night-assets.md`. Distribution:

| Motif family | Keys |
|---|---|
| Castles / towers | W A J N D (+ O, 123, globe as composites) |
| Clouds | R P S L V K, shift, backspace, return |
| Sparkles / stars | E T I F H X, emoji |
| Moons | Q G O |
| Landscape | Y (mountain) C (crag) U (lake) |
| Lanterns | B (two), K (one, with cloud) |
| Nature | Z (leaf sprig) |
| Comet | M |
| Panorama | space |

## Code Analysis

- `KeyboardMetrics.init(availableWidth:isLandscape:)` — portrait `keyHeight = 0.0727*w + 15.727`,
  rounded to even. `rowGap = keyHeight * 0.24`. `keyCornerRadius = keyHeight * 0.21` (a **deliberate**
  departure from the system's ~5–6pt; radius costs nothing in typing accuracy).
  `inputLabelPointSize = keyHeight * 0.55`, `systemLabelPointSize = keyHeight * 0.38`,
  `suggestionBarHeight = 44` portrait / 34 landscape.
- `KeyboardMetrics.forView(_:)` is wrapped in `#if canImport(UIKit)` so the layout solver compiles on
  macOS for the CLI validator.
- `ThemeColor.init` quantises to 1/255 steps. `relativeLuminance` is WCAG 2.1;
  `composited(over:)` is source-over and every contrast check runs on its output.
- `ThemeFill.contrastRepresentative` returns the **minimum-luminance** stop — worst case for dark ink.
- `KeyStyle.resolvedPressedFill` derives a pressed state when unauthored by blending 0.18 toward
  black/white depending on cap luminance. Both shipped themes author pressed fills explicitly instead.
- `ThemeValidator.minimumLabelContrast = 4.5`, `minimumCapContrast = 3.0`,
  `ArtBackdropCheck.requiredCapCoverage = 0.99`.
- Zero-alpha labels are skipped by every contrast check — the FCN space bar hides its "space" text and
  would otherwise measure 1.00:1 and block the theme permanently.
- `ThemeImageLoader` uses `CGImageSourceCreateThumbnailAtIndex` with
  `kCGImageSourceShouldCache: false` — decodes straight to target size so the full bitmap never exists.
  Bundled assets can't use this path (asset catalogue isn't ImageIO-addressable) and are
  decode-then-redraw, which is acceptable only because key illustrations are small (~140px).
- `KeyArtStore` — `NSCache` with `totalCostLimit = 6 MB`, keyed by `asset@WxH@scale`, purged by
  `releaseAll()` on memory warning alongside the background plate.
- `KeyView` layer stack bottom→top: `capLayer` (gradient/border/radius) → `glossLayer` →
  `artClipView`/`artView` → `innerShadowLayer` → `bevelLayer` → label/icon.
- Backspace repeat: 0.45s initial delay → 0.09s → accelerates to 0.04s after 11 ticks. Fires on
  touch-down with touch-up suppressed, so a tap deletes exactly one character.
- Touch targets expand by half a column gap and half a row gap (`KeyView.point(inside:with:)`).

## Files Changed

### New — shared engine (`ios/MochiShared/`)
- `README.md` — why source inclusion over SPM/framework.
- `Theme/ThemeColor.swift`, `ThemeTokens.swift`, `MochiKeyboardTheme.swift`, `ThemeValidator.swift`,
  `ThemeStore.swift`
- `Layout/KeyboardMetrics.swift`, `KeyboardLayout.swift`
- `Input/ShiftState.swift`, `AccentMap.swift`, `SuggestionEngine.swift`, `EmojiCatalog.swift`,
  `KeyboardInputEngine.swift`
- `Render/ThemeImageLoader.swift`, `KeyView.swift`, `KeyboardSurfaceView.swift`, `KeyCalloutView.swift`,
  `SuggestionBarView.swift`, `EmojiPlaneView.swift`, `KeyArtStore.swift`
- `Themes/BuiltInThemes.swift`

### New — extension
- `ios/MochiKeyboard/KeyboardViewController.swift`
- `ios/MochiKeyboard/Info.plist` — **generated by XcodeGen from `info.properties`; do not hand-edit.**

### New — app-side
- `ios/MochiApp/Components/KeyboardThemePreview.swift` — inert preview
- `ios/MochiApp/Components/KeyboardTestBench.swift` — interactive, runs the production engine
- `ios/MochiApp/App/ThemeLabHarness.swift` — DEBUG-only harness

### New — tooling
- `ios/Tools/validate-themes.sh`, `ios/Tools/run-theme-lab.sh`
- `ios/Tools/ThemeValidationCLI/main.swift`, `ArtBackdropCheck.swift`

### New — assets
- `ios/SharedAssets/KeyboardArt.xcassets/` — 32 imagesets, 1.5 MB

### Modified
- `ios/project.yml` — added `MochiKeyboard` target, `MochiShared` + `SharedAssets` in both targets,
  extension `info.properties`, `ASSETCATALOG_COMPILER_APPICON_NAME: ""` on the extension.
- `ios/MochiApp/App/MochiApp.swift` — DEBUG branch to `ThemeLabHarness`.

### Docs
- `docs/keyboard-theme-system.md`, `docs/keyboard-theme-assets.md`,
  `docs/theme-fantasy-castle-night-assets.md`

## User Feedback & Preferences (REQUIRED — never omit)

- **"prioritise accuracy, maintainability, and a production-quality design over speed."** Standing
  instruction from the opening message.
- **"If you need assets from me, specify exactly what you need. For example, preferred format,
  resolution, aspect ratio."** Drove the per-asset spec docs.
- **"if one implementation path isn't working, don't force it. Explain why, compare alternatives, and
  switch."** Invoked twice — the system-keyboard screenshot comparison and the checkerboard alpha
  recovery.
- **"Architect the theme system so it's scalable, but start by perfecting one theme."**
- **"mai ye dekhu kaise, test kaise karu?"** — needed a way to *see* and *test* it. Produced
  `run-theme-lab.sh` and later the interactive test bench.
- On "make it functional", chose **"Keyboard typing completeness"** over the app→keyboard apply flow.
- On advanced-theme capabilities: **"let me send you something we can decide from there"** — deferred,
  do not build speculatively.
- **"The client wants keyboards that are there in the app also… let's go with the fantasy castle
  night."**
- **"I want each key to be exactly like it's in the app"** — rejected the ~14-motif shortcut in favour
  of all 33 illustrations.
- **"Don't hallucinate anything. You should know what you are capable of, what you can do and what you
  will need from my side."**
- **"prompt image generation ke hisab se hona chahiye starting with 'generate'"** — every asset prompt
  must be a self-contained generation prompt starting with "Generate", with size/ratio/format inside it.
- **"category mai baat ke uske andar ke elements + prompt + name to save"** — structure the asset doc by
  motif category.
- **"keys background se match nahi kar rahi"** — caps too opaque, didn't sit in the scene.
- **"illustrations sab bohot ajeeb and chote lag rahe natural nahi as border se shuru hone chahiye"** —
  art must bleed from the cap borders, not float.
- **"space bar ka pura alag hai maine tumko png di thi par tumne lagai nahi"** — direct correction; I
  had skipped the delivered space asset. Rescued it rather than asking for a regeneration.
- **"keys i want them to be in middle alignment"** — read as letters vertically centred; flagged the
  alternative reading (whole keyboard block inset) and offered to change it. **Still unconfirmed.**
- **"theme ka bg cropped hai moon pura nahi dikh raha"** — background anchor was cutting the moon.
- **"keys aur achi ho sakti hai style wise bohot plain look hai"** — drove the `KeyGlass` bevel +
  inner-shadow work.

## Where We're Going

1. **Regenerate 4 assets** — `keyart_fcn_q` (missing), `_e`, `_t`, `_return` (checkerboard baked in).
   Prompts are in `docs/theme-fantasy-castle-night-assets.md`; add the explicit "do NOT draw a grey and
   white checkerboard" line documented in that file's status block. Ingest with the same script pattern
   used for the others (trim to alpha bbox, cap width at 140/180/360 px, write imageset).
2. **Confirm the "middle alignment" reading** with the user before doing anything else visual — letters
   centred (done) vs whole keyboard block inset from screen edges (not done, and would move every key
   away from where thumbs expect it).
3. **Decide whether to push cap styling further.** Offered but not started: frosted-glass caps (blur a
   crop of the background behind each key), outer glow, specular corner sweep.
4. **App → keyboard apply flow.** Needs `DEVELOPMENT_TEAM` in `project.yml` (currently empty) so App
   Group entitlements can be added to both targets. `ThemeStore` already handles the nil-container case.
5. **Device testing.** The simulator has no jetsam limit — memory behaviour is unverified. Profile
   dirty memory per keyboard activation in Instruments.
6. **Commit.** Nothing from this session is committed.

## Risks & Blockers

- **Memory is completely unverified on device.** The whole design is built around a ~30–48 MB ceiling
  but the simulator cannot demonstrate it. A keyboard that would be killed on device looks healthy in
  every screenshot in this session.
- **App Group entitlement is blocked on a Team ID.** Theme sync cannot be tested until then; everything
  currently renders the built-in default.
- **Fantasy Castle Night caps are at their translucency floor.** At the reference's exact transparency
  the near-black ink measures 4.0–4.3:1 over dark regions of the plate — under AA. Going glassier means
  accepting AA-failing keys; that is the user's call, not to be made silently.
- **`ios/MochiApp/Assets.xcassets/q8.py`** is an untracked dev script sitting in the asset catalogue —
  previously flagged as deliberately excluded from commits. Don't let it into a commit.
- **XcodeGen regenerates `MochiKeyboard/Info.plist`.** Hand edits are destroyed on the next
  `xcodegen generate`; everything must live in `project.yml` under `info.properties`.

## Open Questions

- Does "middle alignment" mean letter centring (implemented) or insetting the whole keyboard block?
- Letter font: currently the system face at weight 0.4. The reference uses a bold geometric sans — user
  hasn't named it.
- Should the suggestion bar stay? The FCN reference design has none; ours adds 44pt at the top.
- Which advanced-theme capabilities to build (per-key styling, keyboard-wide gradient across caps,
  frosted caps, key icons + particles) — user is sending a reference first.
- The friend's assets mentioned earlier never materialised on this machine; still outstanding.

## Quick Start for Next Session

```bash
cd /Users/Tanmay/Desktop/Projects/Mochi

# 1. Read the architecture first — it explains every non-obvious decision
#    docs/keyboard-theme-system.md          (288 lines, start here)
#    docs/theme-fantasy-castle-night-assets.md  (status block at top = what's outstanding)

# 2. Project memory
#    ~/.claude/projects/-Users-Tanmay-Desktop-Projects-Mochi/memory/MEMORY.md
#    ...  /mochi_ios_technical_notes.md   (XcodeGen plist, simulator keyboard, SF Symbol traps)

# 3. Verify current state — ~1 second, no simulator or signing needed
./ios/Tools/validate-themes.sh          # expect: PASSED, both themes

# 4. See it / type on it
./ios/Tools/run-theme-lab.sh            # Cozy Sakura Café
#   add: -MochiThemeLabTheme fantasy-castle-night   (via simctl launch) for FCN
#   -MochiThemeLabPlane emoji  to screenshot the emoji panel
#   Simulator: I/O > Keyboard > Connect Hardware Keyboard must be OFF (Cmd-Shift-K)

# 5. Full build
cd ios && xcodegen generate && \
  xcodebuild -project Mochi.xcodeproj -scheme MochiApp \
  -destination 'generic/platform=iOS Simulator' -configuration Debug build

# Key files to read first
#   ios/MochiShared/Themes/BuiltInThemes.swift      — both themes, every value commented with why
#   ios/MochiShared/Theme/ThemeTokens.swift          — the token vocabulary
#   ios/MochiShared/Render/KeyView.swift             — cap rendering incl. KeyGlass
#   ios/MochiShared/Render/KeyboardSurfaceView.swift — the shared renderer
#   ios/Tools/ThemeValidationCLI/ArtBackdropCheck.swift — per-pixel art validation

# Simulator in use
#   iPhone 16 Pro — FA5DF16D-851C-453B-B9D2-963B4361154A

# NEXT ACTION
#   Ask the user to regenerate keyart_fcn_q / _e / _t / _return with the anti-checkerboard
#   line, AND confirm the "middle alignment" reading. Both block further visual work on
#   Fantasy Castle Night. Do not start frosted-glass caps until #2 is answered.
```

## Session Closed
**Closed at:** 2026-08-06
**Commit:** none — closed without committing, at the user's instruction ("abhi kuch push
vagera nahi karna since bana nahi hai" — nothing to be pushed yet, the work isn't finished).
**Session status:** Handed off to next session
**Working tree:** DIRTY. All 5,135 lines of this session's work are uncommitted — `ios/MochiShared/`,
`ios/MochiKeyboard/`, `ios/SharedAssets/`, `ios/Tools/`, three new `ios/MochiApp/` files, plus
modifications to `ios/project.yml` and `ios/MochiApp/App/MochiApp.swift`, and four new `docs/` files.
Do not `git stash` or `git checkout .` — that would destroy the session's output.
