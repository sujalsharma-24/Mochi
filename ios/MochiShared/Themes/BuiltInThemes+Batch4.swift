import Foundation

// Batch 4 — 9 additional built-in themes, ingested from ~/Downloads/THE. Same asset pipeline as
// batch 3 (background plate + per-key illustrations), authored on the 7-material system: cap
// colour is derived from each plate, material chosen per theme's mood.

extension BuiltInThemes {

    static let batch4: [MochiKeyboardTheme] = [
        aetherGarden, auroraMoonlitObservatory, cosmicDaydreamStation, starlitCozyVillage, sunsetStorybookJourney, tideboundAtelier, whisperingLakeCottage, whisperingMoonHarbor, willowMoonCottage
    ]

    static let aetherGarden = MochiKeyboardTheme(
        id: "mochi.aether-garden",
        name: "Aether Garden",
        authorName: "Mochi",
        appearance: .light,
        surface: ThemeSurface(
            baseFill: ThemeFill(stops: [
                    ThemeColor(hex: "#A46160")!,
                    ThemeColor(hex: "#F9C571")!,
                    ThemeColor(hex: "#EBAB59")!
                ]),
            backgroundImage: ThemeBackgroundImage(
                source: .bundled(name: "themebg_aether_garden"),
                scalesToFill: true,
                verticalAnchor: 0.5,
                blurRadius: 0.0
            ),
            scrim: ThemeScrim(
                topColor: ThemeColor(hex: "#AF8046")!.withAlpha(0.46),
                bottomColor: ThemeColor(hex: "#AF8046")!.withAlpha(0.34)
            )
        ),
        keyStyles: [
            .input: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#F3BB68")!.withAlpha(0.73),
                    ThemeColor(hex: "#E9B463")!.withAlpha(0.73)
                ]),
                labelColor: ThemeColor(hex: "#221C28")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#E0AD60")!.withAlpha(0.85),
                    ThemeColor(hex: "#D5A55B")!.withAlpha(0.85)
                ]),
                pressedLabelColor: ThemeColor(hex: "#221C28")!,
                border: ThemeBorder(color: ThemeColor(hex: "#FDF3E5")!.withAlpha(0.50), width: 1.05),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.17, radius: 1.90, offsetY: 1.10),
                topHighlight: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.50),
                cornerRadiusOverride: 13.0,
                glass: KeyGlass(
                    bevelColor: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.74),
                    bevelWidth: 1.10,
                    bevelFalloff: 0.40,
                    innerShadowColor: ThemeColor(hex: "#0A080F")!,
                    innerShadowOpacity: 0.18,
                    innerShadowRadius: 2.60
                )
            ),
            .system: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#E7B263")!.withAlpha(0.79),
                    ThemeColor(hex: "#DCAA5E")!.withAlpha(0.79)
                ]),
                labelColor: ThemeColor(hex: "#221C28")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#D3A35A")!.withAlpha(0.91),
                    ThemeColor(hex: "#C79955")!.withAlpha(0.91)
                ]),
                pressedLabelColor: ThemeColor(hex: "#221C28")!,
                border: ThemeBorder(color: ThemeColor(hex: "#F9EBD7")!.withAlpha(0.50), width: 1.05),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.17, radius: 1.90, offsetY: 1.10),
                topHighlight: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.50),
                cornerRadiusOverride: 13.0,
                glass: KeyGlass(
                    bevelColor: ThemeColor(hex: "#FDF8F2")!.withAlpha(0.74),
                    bevelWidth: 1.10,
                    bevelFalloff: 0.40,
                    innerShadowColor: ThemeColor(hex: "#0A080F")!,
                    innerShadowOpacity: 0.18,
                    innerShadowRadius: 2.60
                )
            ),
            .action: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#F3BB68")!.withAlpha(0.79),
                    ThemeColor(hex: "#E9B463")!.withAlpha(0.79)
                ]),
                labelColor: ThemeColor(hex: "#221C28")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#E0AD60")!.withAlpha(0.91),
                    ThemeColor(hex: "#D5A55B")!.withAlpha(0.91)
                ]),
                pressedLabelColor: ThemeColor(hex: "#221C28")!,
                border: ThemeBorder(color: ThemeColor(hex: "#FDF3E5")!.withAlpha(0.50), width: 1.05),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.17, radius: 1.90, offsetY: 1.10),
                topHighlight: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.50),
                cornerRadiusOverride: 13.0,
                glass: KeyGlass(
                    bevelColor: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.74),
                    bevelWidth: 1.10,
                    bevelFalloff: 0.40,
                    innerShadowColor: ThemeColor(hex: "#0A080F")!,
                    innerShadowOpacity: 0.18,
                    innerShadowRadius: 2.60
                )
            ),
            .space: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#F3BB68")!.withAlpha(0.42),
                    ThemeColor(hex: "#E9B463")!.withAlpha(0.42)
                ]),
                labelColor: ThemeColor(hex: "#221C28")!.withAlpha(0.00),
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#E3AF61")!.withAlpha(0.42),
                    ThemeColor(hex: "#D8A65C")!.withAlpha(0.42)
                ]),
                border: ThemeBorder(color: ThemeColor(hex: "#FDF3E5")!.withAlpha(0.50), width: 1.05),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.17, radius: 1.90, offsetY: 1.10),
                topHighlight: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.50),
                cornerRadiusOverride: 15.0
            )
        ],
        typography: ThemeTypography(fontFamily: nil, weightRawValue: 0.34, sizeMultiplier: 1.0),
        chrome: ThemeChrome(
            inkColor: ThemeColor(hex: "#000000")!,
            mutedInkColor: ThemeColor(hex: "#000000")!.withAlpha(0.55),
            panelFill: ThemeFill(stops: [
                    ThemeColor(hex: "#FDFBFB")!.withAlpha(0.55)
                ]),
            highlightFill: ThemeFill(stops: [
                    ThemeColor(hex: "#000000")!.withAlpha(0.16)
                ])
        ),
        keyArt: KeyArtSet(
            assetPrefix: "keyart_atg_",
            heightFraction: 0.46,
            bottomInsetFraction: 0.09,
            opacity: 0.90,
            fillKeys: ["space"],
            labelLiftFraction: 0.14
        ),
        effects: .none
    )

    static let auroraMoonlitObservatory = MochiKeyboardTheme(
        id: "mochi.aurora-moonlit-observatory",
        name: "Aurora Moonlit Observatory",
        authorName: "Mochi",
        appearance: .dark,
        surface: ThemeSurface(
            baseFill: ThemeFill(stops: [
                    ThemeColor(hex: "#0F254B")!,
                    ThemeColor(hex: "#184F70")!,
                    ThemeColor(hex: "#2D2D45")!
                ]),
            backgroundImage: ThemeBackgroundImage(
                source: .bundled(name: "themebg_aurora_moonlit_observatory"),
                scalesToFill: true,
                verticalAnchor: 0.5,
                blurRadius: 0.0
            ),
            scrim: ThemeScrim(
                topColor: ThemeColor(hex: "#182A3C")!.withAlpha(0.46),
                bottomColor: ThemeColor(hex: "#182A3C")!.withAlpha(0.34)
            )
        ),
        keyStyles: [
            .input: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#151D2C")!.withAlpha(0.73),
                    ThemeColor(hex: "#404753")!.withAlpha(0.73)
                ]),
                labelColor: ThemeColor(hex: "#FFFFFF")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#595F69")!.withAlpha(0.85),
                    ThemeColor(hex: "#6B707A")!.withAlpha(0.85)
                ]),
                pressedLabelColor: ThemeColor(hex: "#FFFFFF")!,
                border: ThemeBorder(color: ThemeColor(hex: "#C4C6C9")!.withAlpha(0.50), width: 1.05),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.17, radius: 1.90, offsetY: 1.10),
                topHighlight: ThemeColor(hex: "#BBBEC2")!.withAlpha(0.50),
                cornerRadiusOverride: 13.0,
                glass: KeyGlass(
                    bevelColor: ThemeColor(hex: "#C4C6C9")!.withAlpha(0.74),
                    bevelWidth: 1.10,
                    bevelFalloff: 0.40,
                    innerShadowColor: ThemeColor(hex: "#0A080F")!,
                    innerShadowOpacity: 0.18,
                    innerShadowRadius: 2.60
                )
            ),
            .system: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#404753")!.withAlpha(0.79),
                    ThemeColor(hex: "#595F69")!.withAlpha(0.79)
                ]),
                labelColor: ThemeColor(hex: "#FFFFFF")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#6B707A")!.withAlpha(0.91),
                    ThemeColor(hex: "#7B7F88")!.withAlpha(0.91)
                ]),
                pressedLabelColor: ThemeColor(hex: "#FFFFFF")!,
                border: ThemeBorder(color: ThemeColor(hex: "#CCCDD1")!.withAlpha(0.50), width: 1.05),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.17, radius: 1.90, offsetY: 1.10),
                topHighlight: ThemeColor(hex: "#C4C6C9")!.withAlpha(0.50),
                cornerRadiusOverride: 13.0,
                glass: KeyGlass(
                    bevelColor: ThemeColor(hex: "#CCCDD1")!.withAlpha(0.74),
                    bevelWidth: 1.10,
                    bevelFalloff: 0.40,
                    innerShadowColor: ThemeColor(hex: "#0A080F")!,
                    innerShadowOpacity: 0.18,
                    innerShadowRadius: 2.60
                )
            ),
            .action: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#0E1F2A")!.withAlpha(0.79),
                    ThemeColor(hex: "#3B4852")!.withAlpha(0.79)
                ]),
                labelColor: ThemeColor(hex: "#FFFFFF")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#546068")!.withAlpha(0.91),
                    ThemeColor(hex: "#677279")!.withAlpha(0.91)
                ]),
                pressedLabelColor: ThemeColor(hex: "#FFFFFF")!,
                border: ThemeBorder(color: ThemeColor(hex: "#C2C6C9")!.withAlpha(0.50), width: 1.05),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.17, radius: 1.90, offsetY: 1.10),
                topHighlight: ThemeColor(hex: "#B9BEC2")!.withAlpha(0.50),
                cornerRadiusOverride: 13.0,
                glass: KeyGlass(
                    bevelColor: ThemeColor(hex: "#C2C6C9")!.withAlpha(0.74),
                    bevelWidth: 1.10,
                    bevelFalloff: 0.40,
                    innerShadowColor: ThemeColor(hex: "#0A080F")!,
                    innerShadowOpacity: 0.18,
                    innerShadowRadius: 2.60
                )
            ),
            .space: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#151D2C")!.withAlpha(0.50),
                    ThemeColor(hex: "#404753")!.withAlpha(0.50)
                ]),
                labelColor: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.00),
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#505661")!.withAlpha(0.50),
                    ThemeColor(hex: "#646A73")!.withAlpha(0.50)
                ]),
                border: ThemeBorder(color: ThemeColor(hex: "#BBBEC2")!.withAlpha(0.50), width: 1.05),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.17, radius: 1.90, offsetY: 1.10),
                topHighlight: ThemeColor(hex: "#BBBEC2")!.withAlpha(0.50),
                cornerRadiusOverride: 15.0
            )
        ],
        typography: ThemeTypography(fontFamily: nil, weightRawValue: 0.34, sizeMultiplier: 1.0),
        chrome: ThemeChrome(
            inkColor: ThemeColor(hex: "#F2ECF0")!,
            mutedInkColor: ThemeColor(hex: "#F2ECF0")!.withAlpha(0.55),
            panelFill: ThemeFill(stops: [
                    ThemeColor(hex: "#4A5A72")!.withAlpha(0.55)
                ]),
            highlightFill: ThemeFill(stops: [
                    ThemeColor(hex: "#FFFFFF")!.withAlpha(0.16)
                ])
        ),
        keyArt: KeyArtSet(
            assetPrefix: "keyart_amo_",
            heightFraction: 0.46,
            bottomInsetFraction: 0.09,
            opacity: 0.90,
            fillKeys: ["space"],
            labelLiftFraction: 0.14
        ),
        effects: .none
    )

    static let cosmicDaydreamStation = MochiKeyboardTheme(
        id: "mochi.cosmic-daydream-station",
        name: "Cosmic Daydream Station",
        authorName: "Mochi",
        appearance: .light,
        surface: ThemeSurface(
            baseFill: ThemeFill(stops: [
                    ThemeColor(hex: "#3F3A75")!,
                    ThemeColor(hex: "#8D7BC5")!,
                    ThemeColor(hex: "#EACBE1")!
                ]),
            backgroundImage: ThemeBackgroundImage(
                source: .bundled(name: "themebg_cosmic_daydream_station"),
                scalesToFill: true,
                verticalAnchor: 0.5,
                blurRadius: 0.0
            ),
            scrim: ThemeScrim(
                topColor: ThemeColor(hex: "#73608B")!.withAlpha(0.46),
                bottomColor: ThemeColor(hex: "#73608B")!.withAlpha(0.34)
            )
        ),
        keyStyles: [
            .input: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#CDABC4")!.withAlpha(0.73),
                    ThemeColor(hex: "#C3A2BA")!.withAlpha(0.73)
                ]),
                labelColor: ThemeColor(hex: "#120F16")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#BA9BB2")!.withAlpha(0.85),
                    ThemeColor(hex: "#AE91A7")!.withAlpha(0.85)
                ]),
                pressedLabelColor: ThemeColor(hex: "#120F16")!,
                border: ThemeBorder(color: ThemeColor(hex: "#F0E6ED")!.withAlpha(0.50), width: 1.05),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.17, radius: 1.90, offsetY: 1.10),
                topHighlight: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.50),
                cornerRadiusOverride: 13.0,
                glass: KeyGlass(
                    bevelColor: ThemeColor(hex: "#F8F3F7")!.withAlpha(0.74),
                    bevelWidth: 1.10,
                    bevelFalloff: 0.40,
                    innerShadowColor: ThemeColor(hex: "#0A080F")!,
                    innerShadowOpacity: 0.18,
                    innerShadowRadius: 2.60
                )
            ),
            .system: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#C1A0B8")!.withAlpha(0.79),
                    ThemeColor(hex: "#B697AD")!.withAlpha(0.79)
                ]),
                labelColor: ThemeColor(hex: "#120F16")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#AC8FA4")!.withAlpha(0.91),
                    ThemeColor(hex: "#9F8497")!.withAlpha(0.91)
                ]),
                pressedLabelColor: ThemeColor(hex: "#120F16")!,
                border: ThemeBorder(color: ThemeColor(hex: "#E9DDE6")!.withAlpha(0.50), width: 1.05),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.17, radius: 1.90, offsetY: 1.10),
                topHighlight: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.50),
                cornerRadiusOverride: 13.0,
                glass: KeyGlass(
                    bevelColor: ThemeColor(hex: "#F2ECF1")!.withAlpha(0.74),
                    bevelWidth: 1.10,
                    bevelFalloff: 0.40,
                    innerShadowColor: ThemeColor(hex: "#0A080F")!,
                    innerShadowOpacity: 0.18,
                    innerShadowRadius: 2.60
                )
            ),
            .action: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#C3ADD1")!.withAlpha(0.79),
                    ThemeColor(hex: "#B9A4C6")!.withAlpha(0.79)
                ]),
                labelColor: ThemeColor(hex: "#120F16")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#B19DBD")!.withAlpha(0.91),
                    ThemeColor(hex: "#A593B1")!.withAlpha(0.91)
                ]),
                pressedLabelColor: ThemeColor(hex: "#120F16")!,
                border: ThemeBorder(color: ThemeColor(hex: "#EDE6F1")!.withAlpha(0.50), width: 1.05),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.17, radius: 1.90, offsetY: 1.10),
                topHighlight: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.50),
                cornerRadiusOverride: 13.0,
                glass: KeyGlass(
                    bevelColor: ThemeColor(hex: "#F7F4F9")!.withAlpha(0.74),
                    bevelWidth: 1.10,
                    bevelFalloff: 0.40,
                    innerShadowColor: ThemeColor(hex: "#0A080F")!,
                    innerShadowOpacity: 0.18,
                    innerShadowRadius: 2.60
                )
            ),
            .space: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#CDABC4")!.withAlpha(0.42),
                    ThemeColor(hex: "#C3A2BA")!.withAlpha(0.42)
                ]),
                labelColor: ThemeColor(hex: "#120F16")!.withAlpha(0.00),
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#BC9DB4")!.withAlpha(0.42),
                    ThemeColor(hex: "#B193A9")!.withAlpha(0.42)
                ]),
                border: ThemeBorder(color: ThemeColor(hex: "#F0E6ED")!.withAlpha(0.50), width: 1.05),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.17, radius: 1.90, offsetY: 1.10),
                topHighlight: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.50),
                cornerRadiusOverride: 15.0
            )
        ],
        typography: ThemeTypography(fontFamily: nil, weightRawValue: 0.34, sizeMultiplier: 1.0),
        chrome: ThemeChrome(
            inkColor: ThemeColor(hex: "#F2ECF0")!,
            mutedInkColor: ThemeColor(hex: "#F2ECF0")!.withAlpha(0.55),
            panelFill: ThemeFill(stops: [
                    ThemeColor(hex: "#5B5285")!.withAlpha(0.55)
                ]),
            highlightFill: ThemeFill(stops: [
                    ThemeColor(hex: "#FFFFFF")!.withAlpha(0.16)
                ])
        ),
        keyArt: KeyArtSet(
            assetPrefix: "keyart_cds_",
            heightFraction: 0.46,
            bottomInsetFraction: 0.09,
            opacity: 0.90,
            fillKeys: ["space"],
            labelLiftFraction: 0.14
        ),
        effects: .none
    )

    static let starlitCozyVillage = MochiKeyboardTheme(
        id: "mochi.starlit-cozy-village",
        name: "Starlit Cozy Village",
        authorName: "Mochi",
        appearance: .light,
        surface: ThemeSurface(
            baseFill: ThemeFill(stops: [
                    ThemeColor(hex: "#B67D88")!,
                    ThemeColor(hex: "#E3BFB9")!,
                    ThemeColor(hex: "#F3CEBC")!
                ]),
            backgroundImage: ThemeBackgroundImage(
                source: .bundled(name: "themebg_starlit_cozy_village"),
                scalesToFill: true,
                verticalAnchor: 0.5,
                blurRadius: 0.0
            ),
            scrim: ThemeScrim(
                topColor: ThemeColor(hex: "#A38583")!.withAlpha(0.16),
                bottomColor: ThemeColor(hex: "#A38583")!.withAlpha(0.05)
            )
        ),
        keyStyles: [
            .input: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#D9BAAA")!,
                    ThemeColor(hex: "#D2B4A5")!
                ]),
                labelColor: ThemeColor(hex: "#221C28")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#C8AB9C")!,
                    ThemeColor(hex: "#C0A497")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#221C28")!,
                border: ThemeBorder(color: ThemeColor(hex: "#221C28")!.withAlpha(0.80), width: 1.70),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.00, radius: 0.00, offsetY: 0.00),
                topHighlight: nil,
                cornerRadiusOverride: 6.0
            ),
            .system: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#CEB0A1")!,
                    ThemeColor(hex: "#C7AA9B")!
                ]),
                labelColor: ThemeColor(hex: "#221C28")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#BBA092")!,
                    ThemeColor(hex: "#B3998C")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#221C28")!,
                border: ThemeBorder(color: ThemeColor(hex: "#221C28")!.withAlpha(0.80), width: 1.70),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.00, radius: 0.00, offsetY: 0.00),
                topHighlight: nil,
                cornerRadiusOverride: 6.0
            ),
            .action: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#D9BAAA")!,
                    ThemeColor(hex: "#D2B4A5")!
                ]),
                labelColor: ThemeColor(hex: "#221C28")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#C8AB9C")!,
                    ThemeColor(hex: "#C0A497")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#221C28")!,
                border: ThemeBorder(color: ThemeColor(hex: "#221C28")!.withAlpha(0.80), width: 1.70),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.00, radius: 0.00, offsetY: 0.00),
                topHighlight: nil,
                cornerRadiusOverride: 6.0
            ),
            .space: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#D9BAAA")!.withAlpha(0.42),
                    ThemeColor(hex: "#D2B4A5")!.withAlpha(0.42)
                ]),
                labelColor: ThemeColor(hex: "#221C28")!.withAlpha(0.00),
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#CAAC9E")!.withAlpha(0.42),
                    ThemeColor(hex: "#C2A698")!.withAlpha(0.42)
                ]),
                border: ThemeBorder(color: ThemeColor(hex: "#F6EFEC")!.withAlpha(0.80), width: 1.70),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.00, radius: 0.00, offsetY: 0.00),
                topHighlight: nil,
                cornerRadiusOverride: 8.0
            )
        ],
        typography: ThemeTypography(fontFamily: nil, weightRawValue: 0.34, sizeMultiplier: 1.0),
        chrome: ThemeChrome(
            inkColor: ThemeColor(hex: "#000000")!,
            mutedInkColor: ThemeColor(hex: "#000000")!.withAlpha(0.55),
            panelFill: ThemeFill(stops: [
                    ThemeColor(hex: "#FDFBFC")!.withAlpha(0.55)
                ]),
            highlightFill: ThemeFill(stops: [
                    ThemeColor(hex: "#000000")!.withAlpha(0.16)
                ])
        ),
        keyArt: KeyArtSet(
            assetPrefix: "keyart_scv_",
            heightFraction: 0.40,
            bottomInsetFraction: 0.09,
            opacity: 0.90,
            fillKeys: ["space"],
            labelLiftFraction: 0.13
        ),
        effects: .none
    )

    static let sunsetStorybookJourney = MochiKeyboardTheme(
        id: "mochi.sunset-storybook-journey",
        name: "Sunset Storybook Journey",
        authorName: "Mochi",
        appearance: .light,
        surface: ThemeSurface(
            baseFill: ThemeFill(stops: [
                    ThemeColor(hex: "#FDD688")!,
                    ThemeColor(hex: "#FCD9B1")!,
                    ThemeColor(hex: "#F4BF93")!
                ]),
            backgroundImage: ThemeBackgroundImage(
                source: .bundled(name: "themebg_sunset_storybook_journey"),
                scalesToFill: true,
                verticalAnchor: 0.5,
                blurRadius: 0.0
            ),
            scrim: ThemeScrim(
                topColor: ThemeColor(hex: "#B79478")!.withAlpha(0.18),
                bottomColor: ThemeColor(hex: "#B79478")!.withAlpha(0.05)
            )
        ),
        keyStyles: [
            .input: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#F4DBA6")!,
                    ThemeColor(hex: "#F6B6A5")!
                ]),
                labelColor: ThemeColor(hex: "#221C28")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#E6CF9C")!,
                    ThemeColor(hex: "#E3A998")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#221C28")!,
                border: ThemeBorder(color: ThemeColor(hex: "#FEFDF9")!.withAlpha(0.42), width: 0.95),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.15, radius: 2.20, offsetY: 1.30),
                topHighlight: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.46),
                cornerRadiusOverride: 14.0,
                glass: KeyGlass(
                    bevelColor: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.60),
                    bevelWidth: 0.80,
                    bevelFalloff: 0.18,
                    innerShadowColor: ThemeColor(hex: "#0A080F")!,
                    innerShadowOpacity: 0.12,
                    innerShadowRadius: 2.00
                )
            ),
            .system: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#E8C6A1")!,
                    ThemeColor(hex: "#D6B694")!
                ]),
                labelColor: ThemeColor(hex: "#221C28")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#D8B895")!,
                    ThemeColor(hex: "#C3A687")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#221C28")!,
                border: ThemeBorder(color: ThemeColor(hex: "#FCF9F5")!.withAlpha(0.42), width: 0.95),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.15, radius: 2.20, offsetY: 1.30),
                topHighlight: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.46),
                cornerRadiusOverride: 14.0,
                glass: KeyGlass(
                    bevelColor: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.60),
                    bevelWidth: 0.80,
                    bevelFalloff: 0.18,
                    innerShadowColor: ThemeColor(hex: "#0A080F")!,
                    innerShadowOpacity: 0.12,
                    innerShadowRadius: 2.00
                )
            ),
            .action: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#F2CEA7")!,
                    ThemeColor(hex: "#E1C09C")!
                ]),
                labelColor: ThemeColor(hex: "#221C28")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#E3C19D")!,
                    ThemeColor(hex: "#D0B190")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#221C28")!,
                border: ThemeBorder(color: ThemeColor(hex: "#FEFCFB")!.withAlpha(0.42), width: 0.95),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.15, radius: 2.20, offsetY: 1.30),
                topHighlight: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.46),
                cornerRadiusOverride: 14.0,
                glass: KeyGlass(
                    bevelColor: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.60),
                    bevelWidth: 0.80,
                    bevelFalloff: 0.18,
                    innerShadowColor: ThemeColor(hex: "#0A080F")!,
                    innerShadowOpacity: 0.12,
                    innerShadowRadius: 2.00
                )
            ),
            .space: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#F4DBA6")!.withAlpha(0.42),
                    ThemeColor(hex: "#F6B6A5")!.withAlpha(0.42)
                ]),
                labelColor: ThemeColor(hex: "#221C28")!.withAlpha(0.00),
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#E7D09D")!.withAlpha(0.42),
                    ThemeColor(hex: "#E5AA9A")!.withAlpha(0.42)
                ]),
                border: ThemeBorder(color: ThemeColor(hex: "#FEFDF9")!.withAlpha(0.42), width: 0.95),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.15, radius: 2.20, offsetY: 1.30),
                topHighlight: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.46),
                cornerRadiusOverride: 16.0
            )
        ],
        typography: ThemeTypography(fontFamily: nil, weightRawValue: 0.34, sizeMultiplier: 1.0),
        chrome: ThemeChrome(
            inkColor: ThemeColor(hex: "#221C28")!,
            mutedInkColor: ThemeColor(hex: "#221C28")!.withAlpha(0.55),
            panelFill: ThemeFill(stops: [
                    ThemeColor(hex: "#FEFBF9")!.withAlpha(0.55)
                ]),
            highlightFill: ThemeFill(stops: [
                    ThemeColor(hex: "#000000")!.withAlpha(0.16)
                ])
        ),
        keyArt: KeyArtSet(
            assetPrefix: "keyart_ssj_",
            heightFraction: 0.48,
            bottomInsetFraction: 0.09,
            opacity: 0.90,
            fillKeys: ["space"],
            labelLiftFraction: 0.14
        ),
        effects: .none
    )

    static let tideboundAtelier = MochiKeyboardTheme(
        id: "mochi.tidebound-atelier",
        name: "Tidebound Atelier",
        authorName: "Mochi",
        appearance: .light,
        surface: ThemeSurface(
            baseFill: ThemeFill(stops: [
                    ThemeColor(hex: "#302931")!,
                    ThemeColor(hex: "#93A983")!,
                    ThemeColor(hex: "#DEBF81")!
                ]),
            backgroundImage: ThemeBackgroundImage(
                source: .bundled(name: "themebg_tidebound_atelier"),
                scalesToFill: true,
                verticalAnchor: 0.5,
                blurRadius: 0.0
            ),
            scrim: ThemeScrim(
                topColor: ThemeColor(hex: "#5E6954")!.withAlpha(0.18),
                bottomColor: ThemeColor(hex: "#5E6954")!.withAlpha(0.05)
            )
        ),
        keyStyles: [
            .input: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#D1AF81")!,
                    ThemeColor(hex: "#C7A77B")!
                ]),
                labelColor: ThemeColor(hex: "#120F16")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#BE9F75")!,
                    ThemeColor(hex: "#B2956E")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#120F16")!,
                border: ThemeBorder(color: ThemeColor(hex: "#917A5A")!.withAlpha(0.32), width: 1.35),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.22, radius: 3.60, offsetY: 2.60),
                topHighlight: nil,
                cornerRadiusOverride: 9.0
            ),
            .system: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#C4A579")!,
                    ThemeColor(hex: "#B99B72")!
                ]),
                labelColor: ThemeColor(hex: "#120F16")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#AF936C")!,
                    ThemeColor(hex: "#A28764")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#120F16")!,
                border: ThemeBorder(color: ThemeColor(hex: "#887254")!.withAlpha(0.32), width: 1.35),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.22, radius: 3.60, offsetY: 2.60),
                topHighlight: nil,
                cornerRadiusOverride: 9.0
            ),
            .action: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#D1AF81")!,
                    ThemeColor(hex: "#C7A77B")!
                ]),
                labelColor: ThemeColor(hex: "#120F16")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#BE9F75")!,
                    ThemeColor(hex: "#B2956E")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#120F16")!,
                border: ThemeBorder(color: ThemeColor(hex: "#917A5A")!.withAlpha(0.32), width: 1.35),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.22, radius: 3.60, offsetY: 2.60),
                topHighlight: nil,
                cornerRadiusOverride: 9.0
            ),
            .space: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#D1AF81")!.withAlpha(0.42),
                    ThemeColor(hex: "#C7A77B")!.withAlpha(0.42)
                ]),
                labelColor: ThemeColor(hex: "#120F16")!.withAlpha(0.00),
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#C0A177")!.withAlpha(0.42),
                    ThemeColor(hex: "#B4976F")!.withAlpha(0.42)
                ]),
                border: ThemeBorder(color: ThemeColor(hex: "#F1E7D9")!.withAlpha(0.32), width: 1.35),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.22, radius: 3.60, offsetY: 2.60),
                topHighlight: nil,
                cornerRadiusOverride: 11.0
            )
        ],
        typography: ThemeTypography(fontFamily: nil, weightRawValue: 0.34, sizeMultiplier: 1.0),
        chrome: ThemeChrome(
            inkColor: ThemeColor(hex: "#F2ECF0")!,
            mutedInkColor: ThemeColor(hex: "#F2ECF0")!.withAlpha(0.55),
            panelFill: ThemeFill(stops: [
                    ThemeColor(hex: "#5C585D")!.withAlpha(0.55)
                ]),
            highlightFill: ThemeFill(stops: [
                    ThemeColor(hex: "#FFFFFF")!.withAlpha(0.16)
                ])
        ),
        keyArt: KeyArtSet(
            assetPrefix: "keyart_tba_",
            heightFraction: 0.52,
            bottomInsetFraction: 0.10,
            opacity: 0.90,
            fillKeys: ["space"],
            labelLiftFraction: 0.15
        ),
        effects: .none
    )

    static let whisperingLakeCottage = MochiKeyboardTheme(
        id: "mochi.whispering-lake-cottage",
        name: "Whispering Lake Cottage",
        authorName: "Mochi",
        appearance: .light,
        surface: ThemeSurface(
            baseFill: ThemeFill(stops: [
                    ThemeColor(hex: "#895C61")!,
                    ThemeColor(hex: "#D8B8A9")!,
                    ThemeColor(hex: "#F3D1AE")!
                ]),
            backgroundImage: ThemeBackgroundImage(
                source: .bundled(name: "themebg_whispering_lake_cottage"),
                scalesToFill: true,
                verticalAnchor: 0.5,
                blurRadius: 0.0
            ),
            scrim: ThemeScrim(
                topColor: ThemeColor(hex: "#9D8578")!.withAlpha(0.18),
                bottomColor: ThemeColor(hex: "#9D8578")!.withAlpha(0.05)
            )
        ),
        keyStyles: [
            .input: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#E1C2A6")!,
                    ThemeColor(hex: "#D8BA9F")!
                ]),
                labelColor: ThemeColor(hex: "#221C28")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#D1B49A")!,
                    ThemeColor(hex: "#C7AB92")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#221C28")!,
                border: ThemeBorder(color: ThemeColor(hex: "#9D8774")!.withAlpha(0.32), width: 1.35),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.22, radius: 3.60, offsetY: 2.60),
                topHighlight: nil,
                cornerRadiusOverride: 9.0
            ),
            .system: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#D6B99E")!,
                    ThemeColor(hex: "#CDB097")!
                ]),
                labelColor: ThemeColor(hex: "#221C28")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#C5A991")!,
                    ThemeColor(hex: "#BAA089")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#221C28")!,
                border: ThemeBorder(color: ThemeColor(hex: "#95816E")!.withAlpha(0.32), width: 1.35),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.22, radius: 3.60, offsetY: 2.60),
                topHighlight: nil,
                cornerRadiusOverride: 9.0
            ),
            .action: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#E1C2A6")!,
                    ThemeColor(hex: "#D8BA9F")!
                ]),
                labelColor: ThemeColor(hex: "#221C28")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#D1B49A")!,
                    ThemeColor(hex: "#C7AB92")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#221C28")!,
                border: ThemeBorder(color: ThemeColor(hex: "#9D8774")!.withAlpha(0.32), width: 1.35),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.22, radius: 3.60, offsetY: 2.60),
                topHighlight: nil,
                cornerRadiusOverride: 9.0
            ),
            .space: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#E1C2A6")!.withAlpha(0.42),
                    ThemeColor(hex: "#D8BA9F")!.withAlpha(0.42)
                ]),
                labelColor: ThemeColor(hex: "#221C28")!.withAlpha(0.00),
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#D3B59B")!.withAlpha(0.42),
                    ThemeColor(hex: "#C9AD94")!.withAlpha(0.42)
                ]),
                border: ThemeBorder(color: ThemeColor(hex: "#FAF6F1")!.withAlpha(0.32), width: 1.35),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.22, radius: 3.60, offsetY: 2.60),
                topHighlight: nil,
                cornerRadiusOverride: 11.0
            )
        ],
        typography: ThemeTypography(fontFamily: nil, weightRawValue: 0.34, sizeMultiplier: 1.0),
        chrome: ThemeChrome(
            inkColor: ThemeColor(hex: "#FFFFFF")!,
            mutedInkColor: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.55),
            panelFill: ThemeFill(stops: [
                    ThemeColor(hex: "#744F53")!.withAlpha(0.55)
                ]),
            highlightFill: ThemeFill(stops: [
                    ThemeColor(hex: "#FFFFFF")!.withAlpha(0.16)
                ])
        ),
        keyArt: KeyArtSet(
            assetPrefix: "keyart_wlc_",
            heightFraction: 0.52,
            bottomInsetFraction: 0.10,
            opacity: 0.90,
            fillKeys: ["space"],
            labelLiftFraction: 0.15
        ),
        effects: .none
    )

    static let whisperingMoonHarbor = MochiKeyboardTheme(
        id: "mochi.whispering-moon-harbor",
        name: "Whispering Moon Harbor",
        authorName: "Mochi",
        appearance: .light,
        surface: ThemeSurface(
            baseFill: ThemeFill(stops: [
                    ThemeColor(hex: "#4E4D79")!,
                    ThemeColor(hex: "#CBB2C6")!,
                    ThemeColor(hex: "#EFD8D0")!
                ]),
            backgroundImage: ThemeBackgroundImage(
                source: .bundled(name: "themebg_whispering_moon_harbor"),
                scalesToFill: true,
                verticalAnchor: 0.5,
                blurRadius: 0.0
            ),
            scrim: ThemeScrim(
                topColor: ThemeColor(hex: "#94818D")!.withAlpha(0.18),
                bottomColor: ThemeColor(hex: "#94818D")!.withAlpha(0.05)
            )
        ),
        keyStyles: [
            .input: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#D7C3C0")!,
                    ThemeColor(hex: "#C6AFB7")!
                ]),
                labelColor: ThemeColor(hex: "#221C28")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#C7B5B2")!,
                    ThemeColor(hex: "#B39FA6")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#221C28")!,
                border: ThemeBorder(color: ThemeColor(hex: "#F9F6F5")!.withAlpha(0.42), width: 0.95),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.15, radius: 2.20, offsetY: 1.30),
                topHighlight: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.46),
                cornerRadiusOverride: 14.0,
                glass: KeyGlass(
                    bevelColor: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.60),
                    bevelWidth: 0.80,
                    bevelFalloff: 0.18,
                    innerShadowColor: ThemeColor(hex: "#0A080F")!,
                    innerShadowOpacity: 0.12,
                    innerShadowRadius: 2.00
                )
            ),
            .system: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#CCB7B7")!,
                    ThemeColor(hex: "#B9A5A6")!
                ]),
                labelColor: ThemeColor(hex: "#221C28")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#BBA7A8")!,
                    ThemeColor(hex: "#A49394")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#221C28")!,
                border: ThemeBorder(color: ThemeColor(hex: "#F2ECEC")!.withAlpha(0.42), width: 0.95),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.15, radius: 2.20, offsetY: 1.30),
                topHighlight: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.46),
                cornerRadiusOverride: 14.0,
                glass: KeyGlass(
                    bevelColor: ThemeColor(hex: "#FBF9F9")!.withAlpha(0.60),
                    bevelWidth: 0.80,
                    bevelFalloff: 0.18,
                    innerShadowColor: ThemeColor(hex: "#0A080F")!,
                    innerShadowOpacity: 0.12,
                    innerShadowRadius: 2.00
                )
            ),
            .action: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#D7C0C1")!,
                    ThemeColor(hex: "#C4B0B1")!
                ]),
                labelColor: ThemeColor(hex: "#221C28")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#C6B2B2")!,
                    ThemeColor(hex: "#B2A0A0")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#221C28")!,
                border: ThemeBorder(color: ThemeColor(hex: "#F8F4F4")!.withAlpha(0.42), width: 0.95),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.15, radius: 2.20, offsetY: 1.30),
                topHighlight: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.46),
                cornerRadiusOverride: 14.0,
                glass: KeyGlass(
                    bevelColor: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.60),
                    bevelWidth: 0.80,
                    bevelFalloff: 0.18,
                    innerShadowColor: ThemeColor(hex: "#0A080F")!,
                    innerShadowOpacity: 0.12,
                    innerShadowRadius: 2.00
                )
            ),
            .space: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#D7C3C0")!.withAlpha(0.42),
                    ThemeColor(hex: "#C6AFB7")!.withAlpha(0.42)
                ]),
                labelColor: ThemeColor(hex: "#221C28")!.withAlpha(0.00),
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#C9B6B3")!.withAlpha(0.42),
                    ThemeColor(hex: "#B5A1A8")!.withAlpha(0.42)
                ]),
                border: ThemeBorder(color: ThemeColor(hex: "#F9F6F5")!.withAlpha(0.42), width: 0.95),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.15, radius: 2.20, offsetY: 1.30),
                topHighlight: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.46),
                cornerRadiusOverride: 16.0
            )
        ],
        typography: ThemeTypography(fontFamily: nil, weightRawValue: 0.34, sizeMultiplier: 1.0),
        chrome: ThemeChrome(
            inkColor: ThemeColor(hex: "#F2ECF0")!,
            mutedInkColor: ThemeColor(hex: "#F2ECF0")!.withAlpha(0.55),
            panelFill: ThemeFill(stops: [
                    ThemeColor(hex: "#57557E")!.withAlpha(0.55)
                ]),
            highlightFill: ThemeFill(stops: [
                    ThemeColor(hex: "#FFFFFF")!.withAlpha(0.16)
                ])
        ),
        keyArt: KeyArtSet(
            assetPrefix: "keyart_wmh_",
            heightFraction: 0.48,
            bottomInsetFraction: 0.09,
            opacity: 0.90,
            fillKeys: ["space"],
            labelLiftFraction: 0.14
        ),
        effects: .none
    )

    static let willowMoonCottage = MochiKeyboardTheme(
        id: "mochi.willow-moon-cottage",
        name: "Willow Moon Cottage",
        authorName: "Mochi",
        appearance: .light,
        surface: ThemeSurface(
            baseFill: ThemeFill(stops: [
                    ThemeColor(hex: "#736553")!,
                    ThemeColor(hex: "#C9BD8F")!,
                    ThemeColor(hex: "#DCB783")!
                ]),
            backgroundImage: ThemeBackgroundImage(
                source: .bundled(name: "themebg_willow_moon_cottage"),
                scalesToFill: true,
                verticalAnchor: 0.5,
                blurRadius: 0.0
            ),
            scrim: ThemeScrim(
                topColor: ThemeColor(hex: "#938662")!.withAlpha(0.16),
                bottomColor: ThemeColor(hex: "#938662")!.withAlpha(0.05)
            )
        ),
        keyStyles: [
            .input: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#CBBA91")!,
                    ThemeColor(hex: "#C4B58D")!
                ]),
                labelColor: ThemeColor(hex: "#221C28")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#B9AB85")!,
                    ThemeColor(hex: "#B2A480")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#221C28")!,
                border: ThemeBorder(color: ThemeColor(hex: "#221C28")!.withAlpha(0.80), width: 1.70),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.00, radius: 0.00, offsetY: 0.00),
                topHighlight: nil,
                cornerRadiusOverride: 6.0
            ),
            .system: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#BFB089")!,
                    ThemeColor(hex: "#B8AA84")!
                ]),
                labelColor: ThemeColor(hex: "#221C28")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#AD9F7C")!,
                    ThemeColor(hex: "#A59776")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#221C28")!,
                border: ThemeBorder(color: ThemeColor(hex: "#221C28")!.withAlpha(0.80), width: 1.70),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.00, radius: 0.00, offsetY: 0.00),
                topHighlight: nil,
                cornerRadiusOverride: 6.0
            ),
            .action: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#CBBA91")!,
                    ThemeColor(hex: "#C4B58D")!
                ]),
                labelColor: ThemeColor(hex: "#221C28")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#B9AB85")!,
                    ThemeColor(hex: "#B2A480")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#221C28")!,
                border: ThemeBorder(color: ThemeColor(hex: "#221C28")!.withAlpha(0.80), width: 1.70),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.00, radius: 0.00, offsetY: 0.00),
                topHighlight: nil,
                cornerRadiusOverride: 6.0
            ),
            .space: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#CBBA91")!.withAlpha(0.42),
                    ThemeColor(hex: "#C4B58D")!.withAlpha(0.42)
                ]),
                labelColor: ThemeColor(hex: "#221C28")!.withAlpha(0.00),
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#BBAC86")!.withAlpha(0.42),
                    ThemeColor(hex: "#B4A681")!.withAlpha(0.42)
                ]),
                border: ThemeBorder(color: ThemeColor(hex: "#F1EDE3")!.withAlpha(0.80), width: 1.70),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.00, radius: 0.00, offsetY: 0.00),
                topHighlight: nil,
                cornerRadiusOverride: 8.0
            )
        ],
        typography: ThemeTypography(fontFamily: nil, weightRawValue: 0.34, sizeMultiplier: 1.0),
        chrome: ThemeChrome(
            inkColor: ThemeColor(hex: "#FFFFFF")!,
            mutedInkColor: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.55),
            panelFill: ThemeFill(stops: [
                    ThemeColor(hex: "#635747")!.withAlpha(0.55)
                ]),
            highlightFill: ThemeFill(stops: [
                    ThemeColor(hex: "#FFFFFF")!.withAlpha(0.16)
                ])
        ),
        keyArt: KeyArtSet(
            assetPrefix: "keyart_wmc_",
            heightFraction: 0.40,
            bottomInsetFraction: 0.09,
            opacity: 0.90,
            fillKeys: ["space"],
            labelLiftFraction: 0.13
        ),
        effects: .none
    )
}
