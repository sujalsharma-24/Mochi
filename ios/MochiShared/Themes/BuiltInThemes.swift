import Foundation

/// Themes compiled into the app and the extension.
///
/// At least one of these must always render correctly with no App Group, no network, and no user
/// data — it is what the keyboard falls back to on a fresh install, on a failed sync, and on a
/// theme document it cannot read.
enum BuiltInThemes {
    static let `default` = cozySakuraCafe

    static let all: [MochiKeyboardTheme] = [cozySakuraCafe, fantasyCastleNight]

    // MARK: - Cozy Sakura Café

    /// The reference theme. Every value here is deliberate; several are the result of the
    /// validator rejecting a nicer-looking first choice.
    ///
    /// **On the background art.** The art is a commissioned background *plate* — sky, lanterns and
    /// a café storefront, with no keys, letters or UI painted into it. That distinction is the
    /// whole system: the older `theme_cozy_sakura_cafe` asset in the app catalogue is a marketing
    /// render of a complete keyboard, and using it here would put a second, misaligned set of
    /// ghost keys behind the real ones. `docs/keyboard-theme-assets.md` is the spec it was made to.
    ///
    /// The three-stop night gradient below is **not** a leftover from before the art arrived. It
    /// is the fallback the validator checks the theme against for the art-missing case, and it is
    /// what shows through the 6–14% of translucency every key cap carries.
    static let cozySakuraCafe = MochiKeyboardTheme(
        id: "mochi.cozy-sakura-cafe",
        name: "Cozy Sakura Café",
        authorName: "Mochi",
        appearance: .dark,
        surface: ThemeSurface(
            // Deep night at the top warming toward lantern-lit violet at the bottom, which is
            // where the user's thumbs are and where the design's warmth should sit.
            baseFill: ThemeFill(stops: [
                ThemeColor(hex: "#221342")!,
                ThemeColor(hex: "#35205E")!,
                ThemeColor(hex: "#4E2C68")!
            ]),
            backgroundImage: ThemeBackgroundImage(
                source: .bundled(name: "themebg_cozy_sakura_cafe"),
                scalesToFill: true,
                // The keyboard is a 1.74:1 window onto 1.29:1 art, so ~26% of the art's height is
                // cropped. Anchored slightly below centre: that keeps the café storefront and its
                // warm lamps in frame along the bottom edge — the part of the scene the theme is
                // named for — and gives up the outermost blossom tips at the very top, which read
                // as texture rather than subject.
                verticalAnchor: 0.56,
                blurRadius: 0
            ),
            // Not optional once art is present. Tuning a scrim *after* dropping in artwork is how
            // themes ship with unreadable keys; this one was authored first and the art was
            // commissioned to sit under it. It also deepens the gradient's top end, which is why
            // the top row reads as clearly as the bottom.
            //
            // The top is the *stronger* end, which is the opposite of the intuitive reading. It
            // is measured, not guessed: the art's brightest content — lantern cores, the moon,
            // blossom highlights — sits along the top edge, and the top key row lands directly on
            // it. At the first pass (0.28 top) the brightest backdrop under a cap measured L 0.452
            // and pale caps dropped to 1.98:1 separation. These values put the worst pixel at
            // L 0.225 and cut the over-threshold area from 1.4% to 0.1%.
            scrim: ThemeScrim(
                topColor: ThemeColor(hex: "#1A0E30")!.withAlpha(0.62),
                bottomColor: ThemeColor(hex: "#140A28")!.withAlpha(0.50)
            )
        ),
        keyStyles: [
            // MARK: Input caps
            //
            // Pale lavender at 94% opacity. Not fully opaque: the 6% lets the night gradient bleed
            // through just enough that the caps read as sitting *in* the scene rather than pasted
            // on it, which is the whole trick. Any more and the labels start losing contrast
            // against whatever is behind them.
            .input: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#EFE9FA")!.withAlpha(0.94),
                    ThemeColor(hex: "#DCD2F0")!.withAlpha(0.94)
                ]),
                labelColor: ThemeColor(hex: "#2B1B4F")!,
                // Authored rather than derived. The automatic derivation moves a cap toward
                // whichever of black/white it is further from, which would darken letter caps and
                // *lighten* the space bar — two keys pressed in the same sentence flashing in
                // opposite directions. Every pressed state here moves toward the night background
                // instead, so the whole keyboard presses the same way.
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#C4BCD4")!.withAlpha(0.94),
                    ThemeColor(hex: "#B5AACC")!.withAlpha(0.94)
                ]),
                shadow: ThemeShadow(
                    color: ThemeColor(hex: "#150A2E")!,
                    opacity: 0.32,
                    radius: 2.5,
                    offsetY: 1.5
                ),
                topHighlight: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.55),
                glass: KeyGlass(
                    bevelColor: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.55),
                    bevelWidth: 1,
                    bevelFalloff: 0.4,
                    innerShadowColor: ThemeColor(hex: "#2E1B52")!,
                    innerShadowOpacity: 0.22,
                    innerShadowRadius: 2.5
                )
            ),

            // MARK: System keys
            //
            // Darker than the input caps, matching the system keyboard's own hierarchy — the keys
            // that modify rather than type recede. That darkness costs cap-versus-background
            // separation (it measures under 3:1), so the 1pt rim is load-bearing, not decorative:
            // it is what keeps shift and backspace reading as keys against the night gradient.
            .system: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#7C6AA8")!.withAlpha(0.92),
                    ThemeColor(hex: "#685894")!.withAlpha(0.92)
                ]),
                labelColor: ThemeColor(hex: "#F5F0FF")!,
                // Pressed a long way down rather than a little.
                //
                // Three passes here, all of them measured. Nudging these caps darker gave a press
                // ΔL of 0.027 — a tap that barely looks like it registered. Lightening them
                // instead, the way the system keyboard treats its dark keys, gave good movement
                // but dropped the white label to 3.88:1, because a mid-luminance cap is too dark
                // for dark ink and too light for white. There is no ink that works at that
                // luminance, so the cap has to leave it: pressing drops these well below their
                // resting value, which gets ΔL to 0.09 *and* pushes the white label past 10:1.
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#52447E")!.withAlpha(0.92),
                    ThemeColor(hex: "#443868")!.withAlpha(0.92)
                ]),
                border: ThemeBorder(color: ThemeColor(hex: "#CBBEEA")!.withAlpha(0.42), width: 1),
                shadow: ThemeShadow(
                    color: ThemeColor(hex: "#150A2E")!,
                    opacity: 0.28,
                    radius: 2.5,
                    offsetY: 1.5
                ),
                topHighlight: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.26)
            ),

            // MARK: Return
            //
            // The one warm key on the keyboard — the lantern colour from the café. It is the only
            // key that commits an action rather than editing a character, and giving it the
            // accent is how the eye finds it without reading it.
            .action: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#F0A0C4")!.withAlpha(0.95),
                    ThemeColor(hex: "#E07FAC")!.withAlpha(0.95)
                ]),
                labelColor: ThemeColor(hex: "#3A1230")!,
                // Return is the one key whose ink changes on press. Deepening the rose the way
                // every other key deepens would have dropped its dark plum label to 3.9:1 — the
                // validator caught it — so the pressed state flips the ink to near-white instead.
                // The result reads as the key lighting up rather than merely dimming, which suits
                // the only key on the board that commits rather than edits.
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#B8628F")!.withAlpha(0.95),
                    ThemeColor(hex: "#A85280")!.withAlpha(0.95)
                ]),
                pressedLabelColor: ThemeColor(hex: "#FFF0F7")!,
                // A warm rim, added for the same reason the system keys have a cool one. Measured
                // against the real artwork, this cap separated from its backdrop on only 94% of
                // its area — it sits bottom-right, over the brightest blossoms in the plate, and
                // a mid-luminance cap has nowhere near the latitude a pale one does. Lightening
                // the rose enough to fix it by fill alone would have cost the accent its warmth.
                //
                // The resulting rule across the theme is coherent rather than ad hoc: pale caps
                // separate on their own and carry no rim, mid and dark caps get one.
                border: ThemeBorder(color: ThemeColor(hex: "#FFD9EA")!.withAlpha(0.45), width: 1),
                shadow: ThemeShadow(
                    color: ThemeColor(hex: "#2E0A22")!,
                    opacity: 0.30,
                    radius: 2.5,
                    offsetY: 1.5
                ),
                topHighlight: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.45)
            ),

            // MARK: Space
            //
            // Slightly more transparent than a letter cap (86% against 94%). The space bar is by
            // far the largest surface on the keyboard, and at full opacity it flattens the
            // background into two disconnected halves; letting more of the gradient through keeps
            // the scene continuous. Its label is set in a muted indigo rather than the letters'
            // near-black because "space" is a hint, not something anyone reads twice.
            .space: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#E4DCF4")!.withAlpha(0.86),
                    ThemeColor(hex: "#D5CAEC")!.withAlpha(0.86)
                ]),
                labelColor: ThemeColor(hex: "#3E3266")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#BBB2D0")!.withAlpha(0.86),
                    ThemeColor(hex: "#AFA4C9")!.withAlpha(0.86)
                ]),
                // The space bar's translucency means its pressed cap lands darker than any other
                // key's, which pulled the muted label under AA. It takes the letter caps' ink on
                // press rather than a lighter one: white measured *worse* here, because the
                // pressed cap sits mid-luminance and is closer to white than to the ink.
                pressedLabelColor: ThemeColor(hex: "#2B1B4F")!,
                shadow: ThemeShadow(
                    color: ThemeColor(hex: "#150A2E")!,
                    opacity: 0.26,
                    radius: 2.5,
                    offsetY: 1.5
                ),
                topHighlight: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.40)
            )
        ],
        // System face, medium weight. Mochi's brand faces (Baloo 2, Fredoka) are display types —
        // they are excellent at 32pt on a marketing card and noticeably slower to read at 24pt on
        // a key the user is glancing at forty times a minute. iOS 26's own keyboard moved *up* in
        // weight for the same legibility reason, which is what `medium` (0.23) matches here.
        // Brand expression on this surface belongs to the background and the accent, not the ink.
        typography: ThemeTypography(fontFamily: nil, weightRawValue: 0.23, sizeMultiplier: 1.0),
        effects: .none
    )

    // MARK: - Fantasy Castle Night

    /// Rebuilt from the marketing render already in the app catalogue
    /// (`theme_fantasy_castle_night`), which is a picture of a keyboard rather than a keyboard.
    /// Every colour below was sampled off that render; every illustration is a separate
    /// transparent asset the renderer composites into the cap, so the art stays aligned at any
    /// device width instead of being frozen at one.
    ///
    /// The distinguishing feature against Cozy Sakura Café is `keyArt`: this theme puts a distinct
    /// illustration on all 26 letters and every function key. Those live under the `keyart_fcn_`
    /// prefix in `SharedAssets/KeyboardArt.xcassets` and are addressed by
    /// `KeyDefinition.artIdentity`, so a missing one degrades to a plain cap rather than a crash.
    static let fantasyCastleNight = MochiKeyboardTheme(
        id: "mochi.fantasy-castle-night",
        name: "Fantasy Castle Night",
        authorName: "Mochi",
        appearance: .dark,
        surface: ThemeSurface(
            // Sampled top-to-bottom off the reference: deep indigo overhead, warming to orchid at
            // the horizon behind the bottom row.
            baseFill: ThemeFill(stops: [
                ThemeColor(hex: "#221F97")!,
                ThemeColor(hex: "#765ADC")!,
                ThemeColor(hex: "#A771ED")!
            ]),
            backgroundImage: ThemeBackgroundImage(
                source: .bundled(name: "themebg_fantasy_castle_night"),
                scalesToFill: true,
                // Anchored high, unlike Cozy Sakura Café. The crescent moon sits in the plate's
                // top-left corner and is the first thing anyone recognises about this theme; a
                // centred anchor sliced it in half. The keyboard is a 1.48:1 window onto 1.29:1
                // art, so ~13% of the height is lost — taken off the bottom, where the lake simply
                // ends a little sooner.
                verticalAnchor: 0.10,
                blurRadius: 0
            ),
            // **This scrim lifts the plate rather than darkening it, and that is the whole theme.**
            //
            // Scrim polarity is per-theme, not a constant — but this goes further than Cozy Sakura
            // Café's weaker darkening, and inverts it. The reason is measured. The delivered plate
            // is a far deeper night than the marketing render it reproduces: its sky under the four
            // key rows sits at L 0.035 / 0.062 / 0.092 / 0.060, against the reference render's
            // L 0.212 / 0.269 / 0.148 / 0.090 — three to five times darker.
            //
            // That gap, not the caps, was the defect behind "the keys don't match the theme".
            // Against a near-black sky, caps light enough to carry this theme's near-black ink
            // separate from their backdrop at **5.3:1** and read as pale rectangles pasted onto a
            // photo. In the reference the same caps measure **1.5:1** against their sky: they are
            // barely lighter than what sits behind them, and it is the rim, not the fill, that says
            // "key". Darkening the plate can only widen that gap. Lifting it is what closes it.
            //
            // **Near-flat on purpose**, which is the opposite of Cozy Sakura Café's strong top-to-
            // bottom ramp. That theme needs the ramp because its art is brightest exactly where its
            // top key row lands. This plate already has the shape the reference has — dark sky at
            // the top, brightening toward the horizon glow behind the third row, dark again at the
            // bottom — so it needs a uniform lift, not a re-shaping. A top-weighted lift was tried
            // first and measured worse in two places at once: it flattened the plate's own
            // modelling, and it lifted the strip behind the suggestion bar to L 0.17, which put the
            // near-white `chrome.inkColor` at 4.08:1 and under AA. Flat leaves that strip at L 0.103
            // and the chrome ink at 5.95:1.
            //
            // Measured at the four key rows after this change: L 0.136 / 0.167 / 0.207 / 0.146,
            // against the reference's 0.212 / 0.269 / 0.148 / 0.090. Same range, same mean (0.18).
            // What matters most is the ratio it produces: caps now separate from their backdrop at
            // **1.45–1.57:1**, against the reference's measured 1.5:1 and the 5.3:1 this theme had
            // before.
            //
            // The cost is real and accepted: a ~0.53 wash halves the plate's local contrast, so the
            // flanking castles read hazier. That is also what the reference looks like — the scene
            // behind its keys is almost entirely flat sky, with the castles faded off at the
            // extreme edges.
            scrim: ThemeScrim(
                topColor: ThemeColor(hex: "#9184F3")!.withAlpha(0.54),
                bottomColor: ThemeColor(hex: "#8C7BF0")!.withAlpha(0.52)
            )
        ),
        keyStyles: [
            .input: KeyStyle(
                // Solved, not sampled. The reference's cap composites to #C1A5FA at the top edge
                // and #8776F8 at the bottom; these are the fill stops that reproduce exactly that
                // once the lifted backdrop shows through at 14%. The earlier #CFBFFF/#AE9CF8 was
                // sampled off the reference directly and so double-counted the sky already mixed
                // into the sample — over our much darker plate it composited to #B4A4E8, a
                // desaturated blue-grey that belonged to no part of this scene.
                //
                // 0.86, up from 0.80. Counter-intuitive, and it is the second half of the same
                // finding: the reference's caps are *not* especially transparent. Their glassiness
                // comes from sitting close in luminance to the sky and from the rim. Transparency
                // over a dark plate does not make a cap glassy, it makes it muddy.
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#CDB0FE")!.withAlpha(0.86),
                    ThemeColor(hex: "#897AFC")!.withAlpha(0.86)
                ]),
                labelColor: ThemeColor(hex: "#08094E")!,
                // Presses **lighten**, where the previous pass darkened.
                //
                // Forced by the retune, and measured. This cap's bottom stop now sits at L 0.249 —
                // mid-luminance — and the ink is near-black, so darkening ran straight into the
                // wall recorded across this theme's history: scaling the fill down by 20/24/28%
                // measured 3.67 / 3.40 / 3.15:1 and fails AA at every step. Lightening leaves that
                // zone in the safe direction instead: ΔL 0.138, unmistakable, with the ink *rising*
                // to 7.55:1. It also reads correctly for the material — a pane of glass with light
                // behind it should light up when pressed, not dim.
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#DBC6FE")!.withAlpha(0.94),
                    ThemeColor(hex: "#AA9FFD")!.withAlpha(0.94)
                ]),
                // Glass, not paint. The reference's own caps measure 5.59:1 against their ink —
                // comfortably AA but far from opaque — and an earlier pass here pushed them to
                // 7.58:1, which read as pale rectangles pasted over the scene rather than panes
                // set into it. These sit close to the reference's measured value, which is what
                // lets the stars and castle silhouettes show through the way they should.
                //
                // The rim is this theme's signature, and now it is load-bearing rather than
                // decorative. Once the cap sits only 1.3:1 above its backdrop, the rim is the only
                // thing left drawing the key's boundary. Measured off the reference at 1px on a
                // 634px-wide render: composite L 0.60–0.64, which #E4D2FE at 0.88 over this cap
                // reproduces at L 0.66. The old #DDC8FB@0.75 was tuned to merely outline a cap that
                // was already separating on its own.
                border: ThemeBorder(color: ThemeColor(hex: "#E4D2FE")!.withAlpha(0.88), width: 1),
                shadow: ThemeShadow(
                    color: ThemeColor(hex: "#140A33")!,
                    opacity: 0.34,
                    radius: 3,
                    offsetY: 1.5
                ),
                topHighlight: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.34),
                glass: KeyGlass(
                    bevelColor: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.90),
                    bevelWidth: 1.2,
                    bevelFalloff: 0.45,
                    innerShadowColor: ThemeColor(hex: "#2A1E6E")!,
                    innerShadowOpacity: 0.45,
                    innerShadowRadius: 3.5
                )
            ),
            // One step down from the input caps in both lightness and opacity, so the keys that
            // modify rather than type recede — the same hierarchy the system keyboard uses. It has
            // less room than the letters do: at 0.82 its bottom stop measures 4.61:1 against the
            // ink, which clears AA but not by much, so this is the one role here that should not be
            // nudged darker without re-running the validator.
            .system: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#BEA2F6")!.withAlpha(0.82),
                    ThemeColor(hex: "#8A7AF0")!.withAlpha(0.82)
                ]),
                labelColor: ThemeColor(hex: "#08094E")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#D2BEF9")!.withAlpha(0.92),
                    ThemeColor(hex: "#A89CF3")!.withAlpha(0.92)
                ]),
                border: ThemeBorder(color: ThemeColor(hex: "#E4D2FE")!.withAlpha(0.72), width: 1),
                shadow: ThemeShadow(
                    color: ThemeColor(hex: "#140A33")!,
                    opacity: 0.30,
                    radius: 3,
                    offsetY: 1.5
                ),
                topHighlight: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.26),
                glass: KeyGlass(
                    bevelColor: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.82),
                    bevelWidth: 1.2,
                    bevelFalloff: 0.45,
                    innerShadowColor: ThemeColor(hex: "#2A1E6E")!,
                    innerShadowOpacity: 0.42,
                    innerShadowRadius: 3.5
                )
            ),
            // The reference gives return no accent colour at all — it is the same glass as every
            // other key, distinguished only by the arrow. Reproduced rather than "improved": the
            // restraint is what makes this theme read as a single sheet of glass over a painting.
            .action: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#CDB0FE")!.withAlpha(0.86),
                    ThemeColor(hex: "#897AFC")!.withAlpha(0.86)
                ]),
                labelColor: ThemeColor(hex: "#08094E")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#DBC6FE")!.withAlpha(0.94),
                    ThemeColor(hex: "#AA9FFD")!.withAlpha(0.94)
                ]),
                border: ThemeBorder(color: ThemeColor(hex: "#E4D2FE")!.withAlpha(0.88), width: 1),
                shadow: ThemeShadow(
                    color: ThemeColor(hex: "#140A33")!,
                    opacity: 0.34,
                    radius: 3,
                    offsetY: 1.5
                ),
                topHighlight: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.34),
                glass: KeyGlass(
                    bevelColor: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.90),
                    bevelWidth: 1.2,
                    bevelFalloff: 0.45,
                    innerShadowColor: ThemeColor(hex: "#2A1E6E")!,
                    innerShadowOpacity: 0.45,
                    innerShadowRadius: 3.5
                )
            ),
            // Much more transparent than the letters so the panorama inside it reads as the scene
            // continuing through the key rather than as a picture stuck on a button. Raised 0.30 →
            // 0.42 alongside the scrim change: at 0.30 over a *lifted* backdrop the cap all but
            // vanished and the space bar read as a gap in the keyboard rather than a key.
            .space: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#C6B5FF")!.withAlpha(0.42),
                    ThemeColor(hex: "#A390F6")!.withAlpha(0.42)
                ]),
                labelColor: ThemeColor(hex: "#08094E")!.withAlpha(0),
                // Free to darken hard, and the one key here that still presses *downward*: the space
                // bar has no visible label, so nothing constrains this but the need for the press to
                // be seen. Flat rather than a gradient — at 70% over a backdrop this light, a ramp
                // is invisible and only costs a stop. Measured ΔL 0.145.
                //
                // Translucency makes press feedback non-obvious to reason about and it has to be
                // measured every time this cap changes: an earlier pass measured ΔL 0.002, because
                // a low-opacity resting cap over this backdrop happened to land at almost exactly
                // the luminance of a darker, more opaque pressed one.
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#3A2C90")!.withAlpha(0.70),
                    ThemeColor(hex: "#3A2C90")!.withAlpha(0.70)
                ]),
                border: ThemeBorder(color: ThemeColor(hex: "#E4D2FE")!.withAlpha(0.88), width: 1),
                shadow: ThemeShadow(
                    color: ThemeColor(hex: "#140A33")!,
                    opacity: 0.30,
                    radius: 3,
                    offsetY: 1.5
                ),
                topHighlight: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.30),
                // The space bar is the largest pane, so its bevel reads longest down the sides.
                glass: KeyGlass(
                    bevelColor: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.85),
                    bevelWidth: 1.2,
                    bevelFalloff: 0.7,
                    innerShadowColor: ThemeColor(hex: "#2A1E6E")!,
                    innerShadowOpacity: 0.40,
                    innerShadowRadius: 4
                )
            )
        ],
        typography: ThemeTypography(fontFamily: nil, weightRawValue: 0.4, sizeMultiplier: 0.94),
        chrome: ThemeChrome(
            inkColor: ThemeColor(hex: "#F3ECFF")!,
            mutedInkColor: ThemeColor(hex: "#F3ECFF")!.withAlpha(0.6),
            panelFill: ThemeFill(ThemeColor(hex: "#1A1152")!.withAlpha(0.62)),
            highlightFill: ThemeFill(ThemeColor(hex: "#FFFFFF")!.withAlpha(0.18))
        ),
        keyArt: KeyArtSet(
            assetPrefix: "keyart_fcn_",
            // Measured against the reference render rather than picked: illustrations there
            // occupy roughly the bottom 45% of the cap with clear air between them and the letter.
            // The first pass at 0.52 put the taller motifs — the lit tower on D, the light column
            // on U — up behind the ink.
            heightFraction: 0.50,
            bottomInsetFraction: 0.0,
            // Slightly under full strength so the cap gradient still reads through the artwork,
            // which is what keeps 33 separate pictures looking like one keyboard.
            opacity: 0.92,
            fillKeys: ["space"],
            labelLiftFraction: 0.07,
            // Placed by eye in the DEBUG art tweak lab (`./ios/Tools/run-art-tweak.sh`) and pasted
            // back verbatim. These are judgements, not measurements — the values above frame most
            // of the set correctly, and this is the 28 that disagreed.
            //
            // The pattern in them is worth reading: motifs with a clear subject and empty margins
            // (the sparkles on F and R, the lantern on K, the comet on M) needed shrinking to
            // roughly half size and pushing off-centre, because at full band width their padding
            // was doing the framing rather than the art. The composites that fill their frame — the
            // castles on A, D, W, the mountain on N — kept their scale and moved sideways instead,
            // clearing the letter rather than backing away from it.
            placements: [
                "123": KeyArtPlacement(offsetX: 0.023, offsetY: 0.125, scale: 1.000),
                "a": KeyArtPlacement(offsetX: -0.318, offsetY: -0.132, scale: 1.000),
                "b": KeyArtPlacement(offsetX: -0.021, offsetY: -0.318, scale: 0.933),
                "backspace": KeyArtPlacement(offsetX: 0.000, offsetY: 0.110, scale: 0.877),
                "c": KeyArtPlacement(offsetX: 0.159, offsetY: 0.047, scale: 1.134),
                "d": KeyArtPlacement(offsetX: -0.338, offsetY: -0.136, scale: 1.000),
                "f": KeyArtPlacement(offsetX: -0.423, offsetY: -0.032, scale: 0.699),
                "g": KeyArtPlacement(offsetX: -0.204, offsetY: 0.047, scale: 0.816),
                "globe": KeyArtPlacement(offsetX: -0.295, offsetY: 0.093, scale: 1.000),
                // Opacity 0 rather than an entry removed from the set: H's illustration is
                // deliberately not drawn, and saying so here keeps it obvious that the asset exists
                // and was rejected, rather than looking like one that was never delivered.
                "h": KeyArtPlacement(offsetX: 0.000, offsetY: 0.000, scale: 1.000, opacity: 0.00),
                "i": KeyArtPlacement(offsetX: 0.297, offsetY: -0.500, scale: 0.424),
                "j": KeyArtPlacement(offsetX: 0.333, offsetY: -0.096, scale: 1.078),
                "k": KeyArtPlacement(offsetX: -0.261, offsetY: 0.072, scale: 0.648),
                "l": KeyArtPlacement(offsetX: 0.229, offsetY: 0.023, scale: 0.531),
                "m": KeyArtPlacement(offsetX: 0.223, offsetY: 0.011, scale: 0.555),
                "n": KeyArtPlacement(offsetX: -0.350, offsetY: -0.004, scale: 1.928),
                "o": KeyArtPlacement(offsetX: -0.367, offsetY: -0.025, scale: 0.896),
                "p": KeyArtPlacement(offsetX: -0.214, offsetY: 0.068, scale: 0.662),
                "r": KeyArtPlacement(offsetX: 0.217, offsetY: 0.076, scale: 0.466),
                "s": KeyArtPlacement(offsetX: 0.217, offsetY: 0.062, scale: 0.559),
                "shift": KeyArtPlacement(offsetX: 0.000, offsetY: 0.091, scale: 0.723),
                "space": KeyArtPlacement(offsetX: 0.030, offsetY: 0.000, scale: 1.000),
                "u": KeyArtPlacement(offsetX: 0.000, offsetY: 0.136, scale: 1.000),
                "v": KeyArtPlacement(offsetX: 0.000, offsetY: 0.119, scale: 0.639),
                "w": KeyArtPlacement(offsetX: -0.412, offsetY: -0.170, scale: 0.989, opacity: 1.00),
                "x": KeyArtPlacement(offsetX: 0.295, offsetY: -0.500, scale: 0.480),
                "y": KeyArtPlacement(offsetX: 0.153, offsetY: 0.072, scale: 0.956, opacity: 1.00),
                "z": KeyArtPlacement(offsetX: 0.136, offsetY: 0.076, scale: 0.746)
            ]
        ),
        effects: .none
    )
}
