# Keyboard theme system — architecture

Status: built and verified on simulator (iPhone 16 Pro, iOS 26 SDK). One theme authored, with
artwork, passing both the token validator and the per-pixel art check. Typing behaviour complete
apart from autocorrect, which is deliberately excluded — see §9.

---

## 1. The central idea

**A theme is a token document, never a picture of a keyboard.**

The obvious way to build a keyboard theme app is to let the user pick a photo, draw it behind the
keys, and ship. That approach fails in three specific ways, all of which show up only after
launch:

- Legibility becomes a property of the artwork rather than of the product. Some themes are
  readable, some aren't, and nobody finds out until a review says so.
- One baked image can't be correct on every device width, in both orientations, across the letter
  / number / symbol planes, or at different system text sizes.
- The in-app preview and the real keyboard are built by different code and drift apart. In a
  marketplace, "the theme I previewed is not the theme I got" is the expensive bug.

So `MochiKeyboardTheme` is a `Codable` value type describing *tokens* — surface fill, scrim, per-role
key styles, typography, effects. The renderer composites those tokens live. Background art is one
optional layer inside that, not the theme itself.

## 2. Layer model

Bottom to top, in `KeyboardSurfaceView`:

| # | Layer | Purpose |
|---|---|---|
| 1 | `baseFill` | Always drawn. A gradient, so a theme can be finished with **no art at all** — and so the art-missing state looks deliberate rather than broken. |
| 2 | background art | Optional. Downsampled at decode to the exact drawn size. |
| 3 | **scrim** | Vertical gradient between art and keys. **This is the piece that makes the system not a wallpaper overlay.** |
| 4 | key caps | Fill gradient + optional border + top-edge gloss + drop shadow, per role. |

The scrim is what converts legibility from "depends on the photo" into a property we can *measure
before shipping*. Background art has per-pixel luminance that can't be reduced to one number; the
scrim can, and everything above it is validated against that number.

## 3. Contrast validation is a build gate, not a guideline

`ThemeValidator` flattens every translucent layer with source-over compositing and then measures
WCAG contrast on the colours the user actually sees. Thresholds:

- **4.5:1** for key labels — WCAG AA for normal text, and the ratio Apple's own App Store
  "Sufficient Contrast" accessibility criterion is evaluated against.
- **3:1** for cap-vs-background, unless the cap has a border.
- Both are checked in the **pressed** state too, plus a minimum press luminance delta so a tap
  can't look unresponsive.
- If a theme uses art, it's also validated in the **art-missing** fallback state.

`ios/Tools/validate-themes.sh` runs this on the host with no simulator, project or signing identity
— the theme model is deliberately Foundation-only behind a `canImport(UIKit)` guard.

This already paid for itself. Authoring the first theme, it caught three defects my hand
calculations missed: the return key's pressed label at 3.91:1, the space bar's at 3.18:1, and a
system-key press delta of 0.027 (a tap that barely looks like it registered). It also caught that
8-bit hex storage made `alpha: 0.94` non-round-trippable, which is why `ThemeColor` now quantises
to 8 bits at construction.

### Art-aware checking

`ThemeValidator` ignores background art on purpose — art has per-pixel luminance that can't be
reduced to one number, and ignoring it is what lets a theme be validated before its art exists.
Once art *is* attached, `ArtBackdropCheck` (in the CLI) closes the gap: it reproduces the
renderer's aspect-fill crop, anchor and scrim, then walks every pixel under every solved key frame.

The two criteria differ deliberately:

- **Labels — worst pixel.** If any part of a letter sits on a cap that lost contrast, that letter
  is hard to read. There's no averaging your way out of text.
- **Cap separation — 99% area coverage.** A per-pixel rule is stricter than the property being
  tested: a cap's boundary is also carried by its drop shadow and top highlight, which the pixel
  test doesn't model. Demanding every pixel clear 3:1 over artwork forces a scrim heavy enough to
  flatten the art into a dark rectangle — trading a real design for a number. The worst case is
  still always printed, so the relaxation can't hide a key that's bad across most of its face.

This is what set the reference theme's scrim. The first pass (0.28 top) measured a backdrop
luminance of 0.452 under the top row and pale caps at 1.98:1 — the artwork's lanterns and moon sit
along the top edge, exactly where the top key row lands. Measured sweep:

```
scrim top/bottom   worst caps
0.45 / 0.42        Q 97.3%, W 96.4%   fail
0.55 / 0.46        Q 98.7%, W 98.3%   fail
0.62 / 0.50        Q 99.3%, W 99.5%   pass  ← shipped
```

### The scrim can lift as well as darken — and which one is right is a property of the art

Fantasy Castle Night shipped its first pass with caps that read as pale rectangles pasted onto a
photo. The instinct is to blame the caps. Measuring says otherwise:

| | Marketing render (the target) | Our first pass |
|---|---|---|
| Sky between caps | `#7C70F3` L 0.223 | `#442AA8` L 0.057 |
| Cap interior | `#A591FB` L 0.35 | `#B4A4E8` L 0.42 |
| **Cap ÷ backdrop** | **1.5:1** | **5.3:1** |

The delivered background plate is a far deeper night than the render it reproduces — three to five
times darker in the band the keys sit on. Against a near-black sky, caps light enough to carry this
theme's near-black ink *cannot* avoid separating hard from their backdrop, and hard separation is
exactly what "sticker pasted on a photo" is. In the reference, caps are barely lighter than the sky
behind them and it is the **rim**, not the fill, that says "key".

So this theme's scrim is a light violet that raises the plate rather than lowering it. That is not a
special case; it is the general rule the reference theme also follows, stated properly:

> A scrim moves the backdrop **toward the caps' luminance until the caps stop competing with the
> art, and no further**. Which direction that is depends on where the art sits relative to the ink,
> not on any convention about scrims being dark.

Cozy Sakura Café has near-white ink over bright art, so its scrim pushes down. Fantasy Castle Night
has near-black ink over dark art, so its scrim pushes up. Both land their caps at roughly 1.5:1
against their backdrop.

Two things fell out of it that are worth recording, because neither was predictable:

- **Translucency is not what makes a cap look like glass.** Raising cap opacity from 0.80 to 0.86
  made these caps look *more* glassy, because glassiness here comes from sitting close to the sky in
  colour, not from letting a dark plate show through. Transparency over a dark plate reads as mud.
- **Lifting a scrim inverts the press direction.** With the backdrop raised, the caps land at
  mid-luminance, and darkening them on press ran the near-black ink to 3.15–3.67:1 at every step
  tried. Presses now **lighten** — ΔL 0.138 with the ink *rising* to 7.55:1 — which also reads
  correctly for the material.

The flat profile is deliberate too. A top-weighted lift was tried first and measured worse twice
over: it flattened the plate's own modelling, and it raised the strip behind the suggestion bar
enough to put `chrome.inkColor` at 4.08:1, under AA. Flat leaves that strip at L 0.103 and the
chrome ink at 5.95:1. **A scrim change is never local to the keys** — it moves every surface the
chrome tokens are measured against.

### Cozy Sakura Café's floor

0.62 is a measured floor, not a conservative guess. The `return` key needed a warm 1pt
rim on top of that: mid-luminance caps have far less latitude than pale ones, and lightening the
rose enough to fix it by fill alone would have cost the accent its warmth. The resulting rule is
coherent rather than ad hoc — **pale caps carry no rim, mid and dark caps do.**

Current state of the reference theme — every state passes AA:

```
input   label 9.48:1   cap 10.71:1   pressed-label 6.30:1   ΔL 0.218
system  label 5.98:1   cap  2.58:1*  pressed-label 9.78:1   ΔL 0.061
action  label 5.46:1   cap  5.88:1   pressed-label 4.85:1   ΔL 0.161
space   label 5.54:1   cap  8.45:1   pressed-label 5.09:1   ΔL 0.164
* below 3:1 by design — these caps carry a 1pt rim, which is load-bearing, not decorative
```

## 4. Geometry is fitted to the system keyboard

Typing accuracy on a phone is muscle memory against a remembered grid. A themed keyboard that
shifts that grid a few points feels broken in a way users report as typos, not as layout.

`KeyboardMetrics` derives everything from available width using a linear fit to measured system
keyboard values (39pt key height @320, 43 @375, 46 @414 — the anchor tables in `zoul/ios-keyboards`
and `normnorm/norm-keyboard` agree independently). One fit reproduces all three within a tenth of a
point, so no per-device table is needed.

Verified by measuring our own render on iPhone 16 Pro (402pt) at the pixel level:

| | Intended | Measured |
|---|---|---|
| Key width | 34.0pt | 34.0pt |
| Column gap | 6pt | 6pt |
| Key height | 46pt | 46pt |
| Side inset | 4pt | 4pt |
| Home row indent | 20pt | 20pt |
| Shift↔Z flanking gap | 14.8pt | 14.8pt |

That last one matters: the system keyboard leaves a wider gap either side of shift and backspace
(~14.25pt measured at 375pt). It's reproduced with invisible `.fill` spacer keys rather than
special-cased, so it stays correct at every width.

The one deliberate departure is **corner radius** (~9.7pt against the system's ~5–6pt). Unlike key
*position*, radius costs nothing in typing accuracy, and it's where the product's identity lives.
Themes can override it per role.

Touch targets extend half a column gap and half a row gap beyond the visible cap, so a thumb in the
gutter still hits the intended key — the system does the same and it's a large part of why it
feels accurate.

## 5. How a theme reaches the extension — and why no Full Access

A custom keyboard's sandbox can **read** the shared App Group container but cannot **write** to it
without Full Access. Rather than work around that, the design leans on it:

```
MochiApp  ──writes active-theme.json (atomic)──▶  App Group container
                                                        │
MochiKeyboard  ◀──reads on every viewWillAppear──────────┘
```

`RequestsOpenAccess` is `false`. That's a deliberate, and I'd argue commercially significant,
decision:

- App Review guideline **4.4.1** requires a keyboard to be fully functional *without* Full Access.
- The Full Access sheet warns the user that the keyboard may transmit everything they type. It is
  the single biggest drop-off point in keyboard onboarding.
- The only things it would buy are key click sounds (`playInputClick`) and haptics.

**Propagation is not instant.** There's no push channel into an extension. The keyboard picks up a
new theme on its next activation — i.e. the next time the user taps a text field. Design for that,
don't fight it.

## 6. Deliberate iOS 26 handling

On iOS 26, a host app that adopts Liquid Glass wraps the keyboard in a system rounded glass
container and insets our content inside it. An opaque background on the input view paints over
that container and appears as the grey bar/box widely reported during the betas. `viewDidLoad`
clears `view.backgroundColor` and `inputView?.backgroundColor` unconditionally — there's no API to
ask whether the host adopted Liquid Glass, and it's harmless on older hosts because the theme's own
base layer paints the surface anyway.

Also worth recording: **a keyboard extension cannot blur host app content.** The extension draws
into a separate remote window with no access to the host's hierarchy, so `UIVisualEffectView`
has nothing to sample. The "frosted glass over the app" look is simply unavailable. The system's
sanctioned equivalent is `UIInputView.Style.keyboard`. Where we want a frosted look, we blur *our
own* art once at decode instead — same visual result, fixed cost, no per-frame resampling.

## 7. Memory

The extension runs under a dirty-memory ceiling in the ~30–48 MB range (the TRD budgets to 30 MB;
reports put the hard kill nearer 48–77 MB depending on iOS version). It is killed **silently, with
no crash log**, when exceeded.

- Background art is decoded with `CGImageSourceCreateThumbnailAtIndex` straight to the drawn size,
  so the full-size bitmap never exists. This is different from decode-then-resize, which briefly
  allocates the full bitmap — exactly the spike that kills the extension. A 2000×1500 background is
  ~12 MB decoded; the same art drawn into a 402×231pt window costs a fraction of that.
- `kCGImageSourceShouldCache: false` stops ImageIO retaining the full bitmap in its own cache.
- `didReceiveMemoryWarning` drops decoded art, which regenerates on the next layout pass.
- UIKit, not SwiftUI, per TRD ADR-002 — `UIHostingController` inside `UIInputViewController` has a
  documented multi-MB-per-keyboard-switch leak, and under this ceiling that's fatal in a few text
  fields rather than eventually.

## 8. Scaling to many themes

- **Roles, not keys.** Four roles (`input` / `system` / `action` / `space`) mean a theme authored
  today still renders correctly against a layout it's never seen — a new plane, a locale with an
  extra key. Per-key styling would not survive that.
- **Lenient decoding.** Unknown role keys are skipped, not fatal; `schemaVersion` only bumps on
  breaking changes; a document from a *newer* major version is refused rather than rendered wrong.
- **Fallback chain.** `style(for:)` → authored role → `.input` → a last-resort legible style. The
  renderer can never fail to draw a key.
- **One renderer.** `KeyboardSurfaceView` is used by both the extension and the in-app preview
  (`KeyboardThemePreview`, a `UIViewRepresentable`). They cannot drift.
- **Adding a theme** is one `MochiKeyboardTheme` literal plus `./ios/Tools/validate-themes.sh`.

### Per-key illustration placement

`KeyArtSet` carries set-wide framing (`heightFraction`, `opacity`, `labelLiftFraction`). That is
right for most keys and wrong for a few: thirty-three illustrations produced by different passes of
an image model do not share a margin, a subject scale, or a centre of mass, and no single
`heightFraction` frames a crescent moon and a castle tower equally well.

`KeyArtSet.placements: [String: KeyArtPlacement]` is the escape hatch — `offsetX`, `offsetY`,
`scale`, `opacity`, keyed by `artIdentity`. It is deliberately the *second* per-key concept in the
theme, alongside `artIdentity` itself, and for the same justification: this is the one part of a
theme where per-key genuinely is the point. Every field is a delta from the default, `.identity` is
the no-op, and identity entries are dropped at construction — so the dictionary only ever contains
the illustrations someone actually had to move, and reading it tells you which motifs disagreed with
the set-wide values.

Offsets are fractions of the **cap's** size, not points and not fractions of the art band. Points
would break across device widths; fractions of the band would make the same nudge mean different
things on a letter key and on the space bar, whose bands differ by a factor of four.

### Placing them: the art tweak lab

Illustration placement is the one thing in this system that cannot be derived. Contrast is measured,
geometry is fitted to the system keyboard, but whether the tower on `D` sits too high is a judgement
— and the loop for making it was: edit a number, rebuild, look, describe the difference in prose,
repeat. Thirty-three illustrations at a minute a round trip is most of a day, and the person who can
see the answer is not the one editing the file.

`./ios/Tools/run-art-tweak.sh` inverts that. Tap a key to select its illustration, drag X / Y / Size
/ Opacity, press **Copy**, and paste the emitted `KeyArtPlacement` literals into `BuiltInThemes`.
"Apply to all" pushes one key's placement onto every key with art, which is the common case — a set
comes out of one generation pass and tends to be uniformly too large or too bright.

It runs on the **production** `KeyboardSurfaceView` with a single `isArtTweakMode` flag, for the same
reason the typing bench runs the production input engine: a second renderer built for tweaking would
drift, and "the placement I dialled in is not the placement that shipped" is the same class of bug as
"the theme I previewed is not the theme I got".

## 9. Typing behaviour

All of it lives in `KeyboardInputEngine`, which holds no views and talks to a `TextDocumentAdapter`
rather than to `UITextDocumentProxy` directly. Two adapters exist: one over the real host document,
one over a plain string. That is what lets the in-app test bench run the **production** input logic
— so shift, caps lock and the double-space period cannot behave differently in the app and the
extension, and neither can drift without the other noticing.

| Behaviour | Notes |
|---|---|
| Shift / caps lock | A three-case `ShiftState`, not a `Bool` plus a flag — the two-flag version has a reachable "locked *and* one-shot" state whose symptom is caps lock silently releasing after one letter. Double-tap within 300 ms locks; the glyph changes to `capslock.fill` so the two states are distinguishable. |
| Auto-capitalisation | Start of document, and after `. ! ?` + space. Respects the host field's `autocapitalizationType`. Caps lock outranks it. |
| Backspace repeat | 0.45 s before the first repeat, 0.09 s thereafter, accelerating to 0.04 s after ~1 s. Fires on touch-down and suppresses the touch-up, so a tap deletes exactly one character. |
| Double-space period | Only when the character before the two spaces is a letter or digit, so `?  ` is left alone. |
| Long-press accents | `AccentMap`, in the system's order — users reach these by muscle memory. Offered in the current case, so shift + hold `e` gives `É`. |
| Emoji plane | ~350 curated emoji in 9 categories. |
| Completions | `UITextChecker` + `UILexicon`. Not autocorrect — see below. |

**On the accent callout and the top row.** Apple's docs state a custom keyboard cannot draw above
the top edge of its primary view, so a callout anchored above `Q` would simply be clipped.
`KeyCalloutView` opens downward when there is no room above and clamps horizontally. That is a real
behavioural difference from the system keyboard, and it is the honest one — the alternative is a
picker that silently does nothing on the row people use most.

**On completions vs autocorrect.** The bar never silently replaces what the user typed; candidates
apply only when tapped, and the verbatim text is always offered first in full-strength ink so a
name or deliberate slang can be defended. Real autocorrect needs an n-gram language model plus a
touch model of which keys neighbour which. A half-built one that changes words without being asked
is materially worse than none — it is the single most complained-about behaviour in any keyboard.

**On the emoji catalogue being curated.** The full Unicode set is ~3,800 emoji, and rendering that
many through CoreText is a documented way to kill an extension — the TRD cites a postmortem
measuring ~120 MB of retained glyph cache from exactly this. Cell reuse bounds the live view count,
but every distinct glyph rasterised still enters a cache. Growing the catalogue is a deliberate act
that should come with an on-device dirty-memory measurement, not a paste.

## 10. What is deliberately not built

Called out so nobody assumes otherwise:

- **Autocorrect** — see above. Deliberate, not deferred.
- Long-press on the space bar for cursor movement; drag-to-type; a number row.
- Particle effects — the `ThemeEffects` token exists and is defaulted off, so adding it later
  isn't a stored-format migration. TRD ADR-002 fixes the implementation as `CAEmitterLayer`.
- Haptics and key click sounds. Both need Full Access, which §5 explains we are not requesting.
- **The app → keyboard apply flow.** The extension reads whatever theme is in the App Group, but
  nothing in the app writes one yet, so it always renders the built-in. App Group entitlements
  need a signing team, which is not configured. `ThemeStore` handles the `nil` container by
  falling back to the built-in theme, so everything works today.

## 11. Files

```
ios/MochiShared/                     compiled into BOTH targets (see its README for why not SPM)
  Theme/ThemeColor.swift             sRGB colour + WCAG contrast maths, Foundation-only
  Theme/ThemeTokens.swift            fills, borders, shadows, roles, surface, typography, effects
  Theme/MochiKeyboardTheme.swift     the document + versioned lenient Codable
  Theme/ThemeValidator.swift         legibility gate
  Theme/ThemeStore.swift             App Group read/write, one-directional
  Layout/KeyboardMetrics.swift       device-adaptive metrics fitted to the system keyboard
  Layout/KeyboardLayout.swift        key definitions, planes, pure frame solver
  Input/KeyboardInputEngine.swift    all typing behaviour, view-free + adapter-driven
  Input/ShiftState.swift             three-case shift, not a Bool + flag
  Input/AccentMap.swift              long-press alternates, in the system's order
  Input/SuggestionEngine.swift       UITextChecker + UILexicon completions
  Input/EmojiCatalog.swift           ~350 curated emoji, 9 categories
  Render/ThemeImageLoader.swift      downsampling + one-shot blur
  Render/KeyCalloutView.swift        accent picker, flips below on the top row
  Render/SuggestionBarView.swift     three-slot completions strip
  Render/EmojiPlaneView.swift        reuse-backed emoji grid
  Tools/ThemeValidationCLI/ArtBackdropCheck.swift   per-pixel legibility against real artwork
  Render/KeyView.swift               one themed cap
  Render/KeyboardSurfaceView.swift   the shared renderer
  Themes/BuiltInThemes.swift         Cozy Sakura Café

ios/SharedAssets/KeyboardArt.xcassets    background plates, in BOTH targets
ios/MochiKeyboard/                   the extension target
ios/MochiApp/Components/KeyboardThemePreview.swift   inert preview
ios/MochiApp/Components/KeyboardTestBench.swift      INTERACTIVE, runs the production engine
ios/MochiApp/Components/ArtTweakLab.swift             DEBUG-only per-key placement lab
ios/MochiApp/App/ThemeLabHarness.swift   DEBUG-only; launch with -MochiThemeLab 1
ios/Tools/validate-themes.sh         host-side legibility + round-trip check
ios/Tools/run-theme-lab.sh           typing bench in the Simulator
ios/Tools/run-art-tweak.sh           illustration placement lab in the Simulator
```
