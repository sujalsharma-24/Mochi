import Foundation

// Batch 8 -- Kawaii Boba Tea, Pastel Pink Sky and Sakura Train, ingested from
// ~/Downloads/All Themes /Assest (see scratchpad/ingest_b8.py and gen_b8.py). These three had been
// shown around the app as picture-only cards with no real keyboard behind them; they are now full
// themes on the same material system as the rest of the catalogue.

extension BuiltInThemes {

    static let batch8: [MochiKeyboardTheme] = [
        kawaiiBobaTea, pastelPinkSky, sakuraTrain
    ]

    // MARK: - Kawaii Boba Tea

    /// Milk-tea watercolour with tapioca pearls and leafy corners. **Clay**: opaque, matte
    /// milk-tea caps with a soft brown rim and a gentle ambient shadow — no gloss, like a ceramic cup.
    /// Return is a caramel pearl accent. The plate is already a pale cream (mean L 0.81), so there is no
    /// scrim to speak of; the caps separate by their warm shadow and rim instead.
    static let kawaiiBobaTea = MochiKeyboardTheme(
        id: "mochi.kawaii-boba-tea",
        name: "Kawaii Boba Tea",
        authorName: "Mochi",
        appearance: .light,
        surface: ThemeSurface(
            baseFill: ThemeFill(stops: [
                ThemeColor(hex: "#F9E1B9")!,
                ThemeColor(hex: "#FBEAC9")!,
                ThemeColor(hex: "#FAE3BB")!
            ]),
            backgroundImage: ThemeBackgroundImage(
                source: .bundled(name: "themebg_kawaii_boba_tea"),
                scalesToFill: true,
                verticalAnchor: 0.5,
                blurRadius: 0
            ),
            scrim: ThemeScrim(
                topColor: ThemeColor(hex: "#FFF6E6")!.withAlpha(0.10),
                bottomColor: ThemeColor(hex: "#FFF6E6")!.withAlpha(0.04)
            )
        ),
        keyStyles: [
            .input: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#FFFAF1")!,
                    ThemeColor(hex: "#F8EBD6")!
                ]),
                labelColor: ThemeColor(hex: "#5A3820")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#F0DEC2")!,
                    ThemeColor(hex: "#E6D0AE")!
                ]),
                border: ThemeBorder(color: ThemeColor(hex: "#C9A27A")!.withAlpha(0.55), width: 1),
                shadow: ThemeShadow(color: ThemeColor(hex: "#6B4424")!, opacity: 0.22, radius: 3.0, offsetY: 2.0),
                topHighlight: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.40),
                cornerRadiusOverride: 12
            ),
            .system: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#F3E1C6")!,
                    ThemeColor(hex: "#EAD2AE")!
                ]),
                labelColor: ThemeColor(hex: "#5A3820")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#E2CCA8")!,
                    ThemeColor(hex: "#D8BC94")!
                ]),
                border: ThemeBorder(color: ThemeColor(hex: "#C09670")!.withAlpha(0.55), width: 1),
                shadow: ThemeShadow(color: ThemeColor(hex: "#6B4424")!, opacity: 0.22, radius: 3.0, offsetY: 2.0),
                topHighlight: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.35),
                cornerRadiusOverride: 12
            ),
            .action: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#F0C99E")!,
                    ThemeColor(hex: "#E2AE7C")!
                ]),
                labelColor: ThemeColor(hex: "#3E2210")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#E0B488")!,
                    ThemeColor(hex: "#D29C68")!
                ]),
                border: ThemeBorder(color: ThemeColor(hex: "#B07A4C")!.withAlpha(0.55), width: 1),
                shadow: ThemeShadow(color: ThemeColor(hex: "#6B4424")!, opacity: 0.24, radius: 3.0, offsetY: 2.0),
                topHighlight: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.35),
                cornerRadiusOverride: 12
            ),
            .space: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#FFF6EA")!.withAlpha(0.55),
                    ThemeColor(hex: "#F4E4CC")!.withAlpha(0.55)
                ]),
                labelColor: ThemeColor(hex: "#000000")!.withAlpha(0.00),
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#C9A27A")!.withAlpha(0.72),
                    ThemeColor(hex: "#C9A27A")!.withAlpha(0.72)
                ]),
                border: ThemeBorder(color: ThemeColor(hex: "#C9A27A")!.withAlpha(0.80), width: 1),
                shadow: ThemeShadow(color: ThemeColor(hex: "#6B4424")!, opacity: 0.20, radius: 3.0, offsetY: 2.0),
                topHighlight: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.35),
                cornerRadiusOverride: 13
            )
        ],
        typography: ThemeTypography(fontFamily: nil, weightRawValue: 0.34, sizeMultiplier: 1.0),
        chrome: ThemeChrome(
            inkColor: ThemeColor(hex: "#4A2E18")!,
            mutedInkColor: ThemeColor(hex: "#4A2E18")!.withAlpha(0.60),
            panelFill: ThemeFill(ThemeColor(hex: "#FFF6E8")!.withAlpha(0.60)),
            highlightFill: ThemeFill(ThemeColor(hex: "#6B4424")!.withAlpha(0.18))
        ),
        keyArt: KeyArtSet(
            assetPrefix: "keyart_kb_",
            heightFraction: 0.54,
            bottomInsetFraction: 0.07,
            opacity: 1.0,
            fillKeys: ["space"],
            labelLiftFraction: 0.15
        ),
        effects: .none
    )

    // MARK: - Pastel Pink Sky

    /// A candy-floss sunset sky ringed with golden-edged clouds. **Jelly glass**: translucent
    /// blush-white caps with a bright white rim, a puffy top highlight and a soft inner glow, so the pink
    /// sky warms every key. Return is a peach sun accent. The sky is mid-light (mean L 0.48): a faint white
    /// lift at the top keeps the upper cloud band from out-shouting the top row.
    static let pastelPinkSky = MochiKeyboardTheme(
        id: "mochi.pastel-pink-sky",
        name: "Pastel Pink Sky",
        authorName: "Mochi",
        appearance: .light,
        surface: ThemeSurface(
            baseFill: ThemeFill(stops: [
                ThemeColor(hex: "#E792A8")!,
                ThemeColor(hex: "#FAA7B3")!,
                ThemeColor(hex: "#FAA7AC")!
            ]),
            backgroundImage: ThemeBackgroundImage(
                source: .bundled(name: "themebg_pastel_pink_sky"),
                scalesToFill: true,
                verticalAnchor: 0.5,
                blurRadius: 0
            ),
            scrim: ThemeScrim(
                topColor: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.10),
                bottomColor: ThemeColor(hex: "#FFE6EE")!.withAlpha(0.04)
            )
        ),
        keyStyles: [
            .input: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#FFF8FB")!.withAlpha(0.86),
                    ThemeColor(hex: "#FFE4EE")!.withAlpha(0.86)
                ]),
                labelColor: ThemeColor(hex: "#6A2644")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#F8D6E4")!.withAlpha(0.92),
                    ThemeColor(hex: "#F2C4D6")!.withAlpha(0.92)
                ]),
                border: ThemeBorder(color: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.80), width: 1),
                shadow: ThemeShadow(color: ThemeColor(hex: "#8A3A5A")!, opacity: 0.24, radius: 3.5, offsetY: 2.0),
                topHighlight: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.65),
                cornerRadiusOverride: 16,
                glass: KeyGlass(
                    bevelColor: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.00),
                    bevelWidth: 0.0,
                    bevelFalloff: 0.5,
                    innerShadowColor: ThemeColor(hex: "#FFFFFF")!,
                    innerShadowOpacity: 0.45,
                    innerShadowRadius: 3.5
                )
            ),
            .system: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#FDE0EB")!.withAlpha(0.88),
                    ThemeColor(hex: "#F8C8DA")!.withAlpha(0.88)
                ]),
                labelColor: ThemeColor(hex: "#6A2644")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#F2C8D8")!.withAlpha(0.94),
                    ThemeColor(hex: "#EAB2C8")!.withAlpha(0.94)
                ]),
                border: ThemeBorder(color: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.75), width: 1),
                shadow: ThemeShadow(color: ThemeColor(hex: "#8A3A5A")!, opacity: 0.24, radius: 3.5, offsetY: 2.0),
                topHighlight: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.60),
                cornerRadiusOverride: 16,
                glass: KeyGlass(
                    bevelColor: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.00),
                    bevelWidth: 0.0,
                    bevelFalloff: 0.5,
                    innerShadowColor: ThemeColor(hex: "#FFFFFF")!,
                    innerShadowOpacity: 0.40,
                    innerShadowRadius: 3.5
                )
            ),
            .action: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#FFE6D6")!.withAlpha(0.92),
                    ThemeColor(hex: "#FFC4A4")!.withAlpha(0.92)
                ]),
                labelColor: ThemeColor(hex: "#5A2418")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#F8D0B8")!.withAlpha(0.96),
                    ThemeColor(hex: "#F4B08C")!.withAlpha(0.96)
                ]),
                border: ThemeBorder(color: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.80), width: 1),
                shadow: ThemeShadow(color: ThemeColor(hex: "#8A3A3A")!, opacity: 0.24, radius: 3.5, offsetY: 2.0),
                topHighlight: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.65),
                cornerRadiusOverride: 16,
                glass: KeyGlass(
                    bevelColor: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.00),
                    bevelWidth: 0.0,
                    bevelFalloff: 0.5,
                    innerShadowColor: ThemeColor(hex: "#FFFFFF")!,
                    innerShadowOpacity: 0.45,
                    innerShadowRadius: 3.5
                )
            ),
            .space: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#FFF2F6")!.withAlpha(0.45),
                    ThemeColor(hex: "#FFDCE8")!.withAlpha(0.45)
                ]),
                labelColor: ThemeColor(hex: "#000000")!.withAlpha(0.00),
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#C06080")!.withAlpha(0.72),
                    ThemeColor(hex: "#C06080")!.withAlpha(0.72)
                ]),
                border: ThemeBorder(color: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.80), width: 1),
                shadow: ThemeShadow(color: ThemeColor(hex: "#8A3A5A")!, opacity: 0.22, radius: 3.5, offsetY: 2.0),
                topHighlight: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.35),
                cornerRadiusOverride: 17
            )
        ],
        typography: ThemeTypography(fontFamily: nil, weightRawValue: 0.32, sizeMultiplier: 1.0),
        chrome: ThemeChrome(
            inkColor: ThemeColor(hex: "#5A2038")!,
            mutedInkColor: ThemeColor(hex: "#5A2038")!.withAlpha(0.60),
            panelFill: ThemeFill(ThemeColor(hex: "#FFF0F5")!.withAlpha(0.55)),
            highlightFill: ThemeFill(ThemeColor(hex: "#8A3A5A")!.withAlpha(0.18))
        ),
        keyArt: KeyArtSet(
            assetPrefix: "keyart_pps_",
            heightFraction: 0.54,
            bottomInsetFraction: 0.07,
            opacity: 1.0,
            fillKeys: ["space"],
            labelLiftFraction: 0.15
        ),
        effects: ThemeEffects(isEnabled: true, birthRate: 3.0, particleImageName: nil, tint: ThemeColor(hex: "#FFE0B0")!)
    )

    // MARK: - Sakura Train

    /// A violet spring night framed by cherry blossoms and a paper lantern. **Pearl glass**:
    /// lavender-white caps with a white rim and a narrow bevel glint, near-opaque so the letters stay crisp
    /// over busy blossom edges, with a sakura-pink return. The plate is a mid-dark violet (mean L 0.24), so
    /// the scrim just steadies the brightest blossoms along the top.
    static let sakuraTrain = MochiKeyboardTheme(
        id: "mochi.sakura-train",
        name: "Sakura Train",
        authorName: "Mochi",
        appearance: .dark,
        surface: ThemeSurface(
            baseFill: ThemeFill(stops: [
                ThemeColor(hex: "#8A53C1")!,
                ThemeColor(hex: "#B46FD9")!,
                ThemeColor(hex: "#BF72D9")!
            ]),
            backgroundImage: ThemeBackgroundImage(
                source: .bundled(name: "themebg_sakura_train"),
                scalesToFill: true,
                verticalAnchor: 0.5,
                blurRadius: 0
            ),
            scrim: ThemeScrim(
                topColor: ThemeColor(hex: "#3A1E6A")!.withAlpha(0.14),
                bottomColor: ThemeColor(hex: "#3A1E6A")!.withAlpha(0.06)
            )
        ),
        keyStyles: [
            .input: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#FDF8FF")!.withAlpha(0.92),
                    ThemeColor(hex: "#EDDFFB")!.withAlpha(0.92)
                ]),
                labelColor: ThemeColor(hex: "#35195A")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#E4D2F6")!.withAlpha(0.98),
                    ThemeColor(hex: "#D3BDEE")!.withAlpha(0.98)
                ]),
                border: ThemeBorder(color: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.72), width: 1),
                shadow: ThemeShadow(color: ThemeColor(hex: "#24104A")!, opacity: 0.30, radius: 3.5, offsetY: 2.0),
                topHighlight: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.55),
                cornerRadiusOverride: 14,
                glass: KeyGlass(
                    bevelColor: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.85),
                    bevelWidth: 1.2,
                    bevelFalloff: 0.5,
                    innerShadowColor: ThemeColor(hex: "#6A40A0")!,
                    innerShadowOpacity: 0.30,
                    innerShadowRadius: 3.0
                )
            ),
            .system: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#EADAFA")!.withAlpha(0.92),
                    ThemeColor(hex: "#D8C2F2")!.withAlpha(0.92)
                ]),
                labelColor: ThemeColor(hex: "#35195A")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#D6C0EE")!.withAlpha(0.98),
                    ThemeColor(hex: "#C4AAE6")!.withAlpha(0.98)
                ]),
                border: ThemeBorder(color: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.72), width: 1),
                shadow: ThemeShadow(color: ThemeColor(hex: "#24104A")!, opacity: 0.30, radius: 3.5, offsetY: 2.0),
                topHighlight: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.48),
                cornerRadiusOverride: 14,
                glass: KeyGlass(
                    bevelColor: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.85),
                    bevelWidth: 1.2,
                    bevelFalloff: 0.5,
                    innerShadowColor: ThemeColor(hex: "#6A40A0")!,
                    innerShadowOpacity: 0.30,
                    innerShadowRadius: 3.0
                )
            ),
            .action: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#FFE4F2")!.withAlpha(0.94),
                    ThemeColor(hex: "#F8BCDA")!.withAlpha(0.94)
                ]),
                labelColor: ThemeColor(hex: "#4A1840")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#F2CCE0")!.withAlpha(0.98),
                    ThemeColor(hex: "#EAA6C8")!.withAlpha(0.98)
                ]),
                border: ThemeBorder(color: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.72), width: 1),
                shadow: ThemeShadow(color: ThemeColor(hex: "#2E0A2A")!, opacity: 0.30, radius: 3.5, offsetY: 2.0),
                topHighlight: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.55),
                cornerRadiusOverride: 14,
                glass: KeyGlass(
                    bevelColor: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.85),
                    bevelWidth: 1.2,
                    bevelFalloff: 0.5,
                    innerShadowColor: ThemeColor(hex: "#8A3070")!,
                    innerShadowOpacity: 0.30,
                    innerShadowRadius: 3.0
                )
            ),
            .space: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#F8EEFF")!.withAlpha(0.45),
                    ThemeColor(hex: "#E4D0F8")!.withAlpha(0.45)
                ]),
                labelColor: ThemeColor(hex: "#000000")!.withAlpha(0.00),
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#3A1E6A")!.withAlpha(0.72),
                    ThemeColor(hex: "#3A1E6A")!.withAlpha(0.72)
                ]),
                border: ThemeBorder(color: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.80), width: 1),
                shadow: ThemeShadow(color: ThemeColor(hex: "#24104A")!, opacity: 0.28, radius: 3.5, offsetY: 2.0),
                topHighlight: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.35),
                cornerRadiusOverride: 15
            )
        ],
        typography: ThemeTypography(fontFamily: nil, weightRawValue: 0.32, sizeMultiplier: 1.0),
        chrome: ThemeChrome(
            inkColor: ThemeColor(hex: "#FFFFFF")!,
            mutedInkColor: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.60),
            panelFill: ThemeFill(ThemeColor(hex: "#2A1450")!.withAlpha(0.55)),
            highlightFill: ThemeFill(ThemeColor(hex: "#FFFFFF")!.withAlpha(0.18))
        ),
        keyArt: KeyArtSet(
            assetPrefix: "keyart_st_",
            heightFraction: 0.54,
            bottomInsetFraction: 0.07,
            opacity: 0.98,
            fillKeys: ["space"],
            labelLiftFraction: 0.15
        ),
        effects: ThemeEffects(isEnabled: true, birthRate: 4.0, particleImageName: nil, tint: ThemeColor(hex: "#FFC6E6")!)
    )
}
