import Foundation

// Batch 7 -- 20 additional built-in themes, ingested from ~/Downloads/THEMES!!. Same asset
// pipeline as batch 3/4 (background plate + per-key illustrations), authored on the 7-material
// system. Cap luminance is solved by bisecting real contrast against the plate's own post-scrim
// 5th/95th-percentile luminance (see `derive_cap` in scratchpad/gen_b56.py) rather than a fixed
// offset, so caps in this batch separate from their backdrop instead of matching it.

extension BuiltInThemes {

    static let batch7: [MochiKeyboardTheme] = [
        alienPlaytopia, bubblegumCircuit, dreamscapePortal, dreamyControlRoom, enchantedGlassGarden, floatingDreamscape, glitchGarden, holographicDaydream, liquidAurora, miniatureGreenhouse, moonArcadeDreams, neonAquarium, pastelBeyond, pixelPetDreams, pocketCityDreams, pocketCosmos, prismaticJellyDreams, puzzlewoodAdventures, reflectiveDreamworld, ruinsAndRelics
    ]

    static let alienPlaytopia = MochiKeyboardTheme(
        id: "mochi.alien-playtopia",
        name: "Alien Playtopia",
        authorName: "Mochi",
        appearance: .light,
        surface: ThemeSurface(
            baseFill: ThemeFill(stops: [
                    ThemeColor(hex: "#9A8ED8")!,
                    ThemeColor(hex: "#8187D4")!,
                    ThemeColor(hex: "#DABAEC")!
                ]),
            backgroundImage: ThemeBackgroundImage(
                source: .bundled(name: "themebg_alien_playtopia"),
                scalesToFill: true,
                verticalAnchor: 0.5,
                blurRadius: 0.0
            ),
            scrim: ThemeScrim(
                topColor: ThemeColor(hex: "#595479")!.withAlpha(0.18),
                bottomColor: ThemeColor(hex: "#595479")!.withAlpha(0.05)
            )
        ),
        keyStyles: [
            .input: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#FCF0F8")!,
                    ThemeColor(hex: "#F4E9F1")!
                ]),
                labelColor: ThemeColor(hex: "#221C28")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#F0E6ED")!,
                    ThemeColor(hex: "#E8DEE5")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#221C28")!,
                border: ThemeBorder(color: ThemeColor(hex: "#B0A8AE")!.withAlpha(0.40), width: 1.15),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.30, radius: 4.20, offsetY: 3.00),
                topHighlight: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.62),
                cornerRadiusOverride: 19.0,
                glass: KeyGlass(
                    bevelColor: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.00),
                    bevelWidth: 0.00,
                    bevelFalloff: 0.50,
                    innerShadowColor: ThemeColor(hex: "#FFFFFF")!,
                    innerShadowOpacity: 0.34,
                    innerShadowRadius: 3.20
                )
            ),
            .system: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#F4E9F1")!,
                    ThemeColor(hex: "#ECE2E9")!
                ]),
                labelColor: ThemeColor(hex: "#221C28")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#E8DEE5")!,
                    ThemeColor(hex: "#E0D6DD")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#221C28")!,
                border: ThemeBorder(color: ThemeColor(hex: "#ABA3A9")!.withAlpha(0.40), width: 1.15),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.30, radius: 4.20, offsetY: 3.00),
                topHighlight: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.62),
                cornerRadiusOverride: 19.0,
                glass: KeyGlass(
                    bevelColor: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.00),
                    bevelWidth: 0.00,
                    bevelFalloff: 0.50,
                    innerShadowColor: ThemeColor(hex: "#FFFFFF")!,
                    innerShadowOpacity: 0.34,
                    innerShadowRadius: 3.20
                )
            ),
            .action: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#F6F2FB")!,
                    ThemeColor(hex: "#EFEBF3")!
                ]),
                labelColor: ThemeColor(hex: "#221C28")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#EBE7EF")!,
                    ThemeColor(hex: "#E3DFE7")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#221C28")!,
                border: ThemeBorder(color: ThemeColor(hex: "#ACAAB0")!.withAlpha(0.40), width: 1.15),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.30, radius: 4.20, offsetY: 3.00),
                topHighlight: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.62),
                cornerRadiusOverride: 19.0,
                glass: KeyGlass(
                    bevelColor: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.00),
                    bevelWidth: 0.00,
                    bevelFalloff: 0.50,
                    innerShadowColor: ThemeColor(hex: "#FFFFFF")!,
                    innerShadowOpacity: 0.34,
                    innerShadowRadius: 3.20
                )
            ),
            .space: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#FCF0F8")!.withAlpha(0.42),
                    ThemeColor(hex: "#F4E9F1")!.withAlpha(0.42)
                ]),
                labelColor: ThemeColor(hex: "#221C28")!.withAlpha(0.00),
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#F1E7EE")!.withAlpha(0.42),
                    ThemeColor(hex: "#E9DFE6")!.withAlpha(0.42)
                ]),
                border: ThemeBorder(color: ThemeColor(hex: "#FEFCFE")!.withAlpha(0.40), width: 1.15),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.30, radius: 4.20, offsetY: 3.00),
                topHighlight: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.62),
                cornerRadiusOverride: 20.0
            )
        ],
        typography: ThemeTypography(fontFamily: nil, weightRawValue: 0.34, sizeMultiplier: 1.0),
        chrome: ThemeChrome(
            inkColor: ThemeColor(hex: "#000000")!,
            mutedInkColor: ThemeColor(hex: "#000000")!.withAlpha(0.55),
            panelFill: ThemeFill(stops: [
                    ThemeColor(hex: "#FBFBFE")!.withAlpha(0.55)
                ]),
            highlightFill: ThemeFill(stops: [
                    ThemeColor(hex: "#000000")!.withAlpha(0.16)
                ])
        ),
        keyArt: KeyArtSet(
            assetPrefix: "keyart_alp_",
            heightFraction: 0.50,
            bottomInsetFraction: 0.10,
            opacity: 0.90,
            fillKeys: ["space"],
            labelLiftFraction: 0.15
        ),
        effects: ThemeEffects(
            isEnabled: true,
            birthRate: 5.0,
            particleImageName: nil,
            tint: ThemeColor(hex: "#CDB4FF")!
        )
    )

    static let bubblegumCircuit = MochiKeyboardTheme(
        id: "mochi.bubblegum-circuit",
        name: "Bubblegum Circuit",
        authorName: "Mochi",
        appearance: .dark,
        surface: ThemeSurface(
            baseFill: ThemeFill(stops: [
                    ThemeColor(hex: "#9984D9")!,
                    ThemeColor(hex: "#C08AD6")!,
                    ThemeColor(hex: "#FCCCD0")!
                ]),
            backgroundImage: ThemeBackgroundImage(
                source: .bundled(name: "themebg_bubblegum_circuit"),
                scalesToFill: true,
                verticalAnchor: 0.5,
                blurRadius: 0.0
            ),
            scrim: ThemeScrim(
                topColor: ThemeColor(hex: "#755876")!.withAlpha(0.18),
                bottomColor: ThemeColor(hex: "#755876")!.withAlpha(0.05)
            )
        ),
        keyStyles: [
            .input: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#461D36")!,
                    ThemeColor(hex: "#3C193F")!
                ]),
                labelColor: ThemeColor(hex: "#FFFFFF")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#785A6D")!,
                    ThemeColor(hex: "#725975")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#FFFFFF")!,
                border: ThemeBorder(color: ThemeColor(hex: "#CFC5CB")!.withAlpha(0.42), width: 0.95),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.15, radius: 2.20, offsetY: 1.30),
                topHighlight: ThemeColor(hex: "#C8BCC4")!.withAlpha(0.46),
                cornerRadiusOverride: 14.0,
                glass: KeyGlass(
                    bevelColor: ThemeColor(hex: "#CFC5CB")!.withAlpha(0.60),
                    bevelWidth: 0.80,
                    bevelFalloff: 0.18,
                    innerShadowColor: ThemeColor(hex: "#0A080F")!,
                    innerShadowOpacity: 0.12,
                    innerShadowRadius: 2.00
                )
            ),
            .system: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#64435D")!,
                    ThemeColor(hex: "#866D81")!
                ]),
                labelColor: ThemeColor(hex: "#FFFFFF")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#866D81")!,
                    ThemeColor(hex: "#9E8999")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#FFFFFF")!,
                border: ThemeBorder(color: ThemeColor(hex: "#D6CDD4")!.withAlpha(0.42), width: 0.95),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.15, radius: 2.20, offsetY: 1.30),
                topHighlight: ThemeColor(hex: "#CFC5CD")!.withAlpha(0.46),
                cornerRadiusOverride: 14.0,
                glass: KeyGlass(
                    bevelColor: ThemeColor(hex: "#D6CDD4")!.withAlpha(0.60),
                    bevelWidth: 0.80,
                    bevelFalloff: 0.18,
                    innerShadowColor: ThemeColor(hex: "#0A080F")!,
                    innerShadowOpacity: 0.12,
                    innerShadowRadius: 2.00
                )
            ),
            .action: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#382730")!,
                    ThemeColor(hex: "#6C6066")!
                ]),
                labelColor: ThemeColor(hex: "#FFFFFF")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#6C6066")!,
                    ThemeColor(hex: "#8A8085")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#FFFFFF")!,
                border: ThemeBorder(color: ThemeColor(hex: "#CBC6C9")!.withAlpha(0.42), width: 0.95),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.15, radius: 2.20, offsetY: 1.30),
                topHighlight: ThemeColor(hex: "#C4BEC1")!.withAlpha(0.46),
                cornerRadiusOverride: 14.0,
                glass: KeyGlass(
                    bevelColor: ThemeColor(hex: "#CBC6C9")!.withAlpha(0.60),
                    bevelWidth: 0.80,
                    bevelFalloff: 0.18,
                    innerShadowColor: ThemeColor(hex: "#0A080F")!,
                    innerShadowOpacity: 0.12,
                    innerShadowRadius: 2.00
                )
            ),
            .space: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#461D36")!.withAlpha(0.50),
                    ThemeColor(hex: "#3C193F")!.withAlpha(0.50)
                ]),
                labelColor: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.00),
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#715165")!.withAlpha(0.50),
                    ThemeColor(hex: "#6B506E")!.withAlpha(0.50)
                ]),
                border: ThemeBorder(color: ThemeColor(hex: "#C8BCC4")!.withAlpha(0.42), width: 0.95),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.15, radius: 2.20, offsetY: 1.30),
                topHighlight: ThemeColor(hex: "#C8BCC4")!.withAlpha(0.46),
                cornerRadiusOverride: 16.0
            )
        ],
        typography: ThemeTypography(fontFamily: nil, weightRawValue: 0.34, sizeMultiplier: 1.0),
        chrome: ThemeChrome(
            inkColor: ThemeColor(hex: "#000000")!,
            mutedInkColor: ThemeColor(hex: "#000000")!.withAlpha(0.55),
            panelFill: ThemeFill(stops: [
                    ThemeColor(hex: "#FCFBFE")!.withAlpha(0.55)
                ]),
            highlightFill: ThemeFill(stops: [
                    ThemeColor(hex: "#000000")!.withAlpha(0.16)
                ])
        ),
        keyArt: KeyArtSet(
            assetPrefix: "keyart_bgc_",
            heightFraction: 0.48,
            bottomInsetFraction: 0.09,
            opacity: 0.90,
            fillKeys: ["space"],
            labelLiftFraction: 0.14
        ),
        effects: ThemeEffects(
            isEnabled: true,
            birthRate: 5.0,
            particleImageName: nil,
            tint: ThemeColor(hex: "#FFB8E6")!
        )
    )

    static let dreamscapePortal = MochiKeyboardTheme(
        id: "mochi.dreamscape-portal",
        name: "Dreamscape Portal",
        authorName: "Mochi",
        appearance: .light,
        surface: ThemeSurface(
            baseFill: ThemeFill(stops: [
                    ThemeColor(hex: "#615CAD")!,
                    ThemeColor(hex: "#DDA7D1")!,
                    ThemeColor(hex: "#FECAD7")!
                ]),
            backgroundImage: ThemeBackgroundImage(
                source: .bundled(name: "themebg_dreamscape_portal"),
                scalesToFill: true,
                verticalAnchor: 0.5,
                blurRadius: 0.0
            ),
            scrim: ThemeScrim(
                topColor: ThemeColor(hex: "#775D6E")!.withAlpha(0.26),
                bottomColor: ThemeColor(hex: "#775D6E")!.withAlpha(0.16)
            )
        ),
        keyStyles: [
            .input: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#FFF0F2")!.withAlpha(0.73),
                    ThemeColor(hex: "#F9EAEC")!.withAlpha(0.73)
                ]),
                labelColor: ThemeColor(hex: "#221C28")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#F3E5E7")!.withAlpha(0.85),
                    ThemeColor(hex: "#EDDFE1")!.withAlpha(0.85)
                ]),
                pressedLabelColor: ThemeColor(hex: "#221C28")!,
                border: ThemeBorder(color: ThemeColor(hex: "#FFFCFC")!.withAlpha(0.58), width: 1.20),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.17, radius: 1.90, offsetY: 1.10),
                topHighlight: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.58),
                cornerRadiusOverride: 13.0,
                glass: KeyGlass(
                    bevelColor: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.82),
                    bevelWidth: 1.30,
                    bevelFalloff: 0.34,
                    innerShadowColor: ThemeColor(hex: "#0A080F")!,
                    innerShadowOpacity: 0.20,
                    innerShadowRadius: 2.80
                )
            ),
            .system: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#F7E9EB")!.withAlpha(0.79),
                    ThemeColor(hex: "#F1E3E4")!.withAlpha(0.79)
                ]),
                labelColor: ThemeColor(hex: "#221C28")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#EBDDDF")!.withAlpha(0.91),
                    ThemeColor(hex: "#E4D7D9")!.withAlpha(0.91)
                ]),
                pressedLabelColor: ThemeColor(hex: "#221C28")!,
                border: ThemeBorder(color: ThemeColor(hex: "#FEFCFD")!.withAlpha(0.58), width: 1.20),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.17, radius: 1.90, offsetY: 1.10),
                topHighlight: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.58),
                cornerRadiusOverride: 13.0,
                glass: KeyGlass(
                    bevelColor: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.82),
                    bevelWidth: 1.30,
                    bevelFalloff: 0.34,
                    innerShadowColor: ThemeColor(hex: "#0A080F")!,
                    innerShadowOpacity: 0.20,
                    innerShadowRadius: 2.80
                )
            ),
            .action: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#FEF0F2")!.withAlpha(0.79),
                    ThemeColor(hex: "#F7EAEC")!.withAlpha(0.79)
                ]),
                labelColor: ThemeColor(hex: "#221C28")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#F2E6E7")!.withAlpha(0.91),
                    ThemeColor(hex: "#EBDFE1")!.withAlpha(0.91)
                ]),
                pressedLabelColor: ThemeColor(hex: "#221C28")!,
                border: ThemeBorder(color: ThemeColor(hex: "#FFFCFD")!.withAlpha(0.58), width: 1.20),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.17, radius: 1.90, offsetY: 1.10),
                topHighlight: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.58),
                cornerRadiusOverride: 13.0,
                glass: KeyGlass(
                    bevelColor: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.82),
                    bevelWidth: 1.30,
                    bevelFalloff: 0.34,
                    innerShadowColor: ThemeColor(hex: "#0A080F")!,
                    innerShadowOpacity: 0.20,
                    innerShadowRadius: 2.80
                )
            ),
            .space: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#FFF0F2")!.withAlpha(0.42),
                    ThemeColor(hex: "#F9EAEC")!.withAlpha(0.42)
                ]),
                labelColor: ThemeColor(hex: "#221C28")!.withAlpha(0.00),
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#F5E6E8")!.withAlpha(0.42),
                    ThemeColor(hex: "#EEE0E2")!.withAlpha(0.42)
                ]),
                border: ThemeBorder(color: ThemeColor(hex: "#FFFCFC")!.withAlpha(0.58), width: 1.20),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.17, radius: 1.90, offsetY: 1.10),
                topHighlight: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.58),
                cornerRadiusOverride: 15.0
            )
        ],
        typography: ThemeTypography(fontFamily: nil, weightRawValue: 0.34, sizeMultiplier: 1.0),
        chrome: ThemeChrome(
            inkColor: ThemeColor(hex: "#FFFFFF")!,
            mutedInkColor: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.55),
            panelFill: ThemeFill(stops: [
                    ThemeColor(hex: "#59518F")!.withAlpha(0.55)
                ]),
            highlightFill: ThemeFill(stops: [
                    ThemeColor(hex: "#FFFFFF")!.withAlpha(0.16)
                ])
        ),
        keyArt: KeyArtSet(
            assetPrefix: "keyart_dsp_",
            heightFraction: 0.46,
            bottomInsetFraction: 0.09,
            opacity: 0.90,
            fillKeys: ["space"],
            labelLiftFraction: 0.14
        ),
        effects: ThemeEffects(
            isEnabled: true,
            birthRate: 5.0,
            particleImageName: nil,
            tint: ThemeColor(hex: "#FFE8B0")!
        )
    )

    static let dreamyControlRoom = MochiKeyboardTheme(
        id: "mochi.dreamy-control-room",
        name: "Dreamy Control Room",
        authorName: "Mochi",
        appearance: .dark,
        surface: ThemeSurface(
            baseFill: ThemeFill(stops: [
                    ThemeColor(hex: "#7867A4")!,
                    ThemeColor(hex: "#CBABD1")!,
                    ThemeColor(hex: "#E0A691")!
                ]),
            backgroundImage: ThemeBackgroundImage(
                source: .bundled(name: "themebg_dreamy_control_room"),
                scalesToFill: true,
                verticalAnchor: 0.5,
                blurRadius: 0.0
            ),
            scrim: ThemeScrim(
                topColor: ThemeColor(hex: "#937689")!.withAlpha(0.18),
                bottomColor: ThemeColor(hex: "#937689")!.withAlpha(0.05)
            )
        ),
        keyStyles: [
            .input: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#481F25")!,
                    ThemeColor(hex: "#674449")!
                ]),
                labelColor: ThemeColor(hex: "#FFFFFF")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#7A5B60")!,
                    ThemeColor(hex: "#886D72")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#FFFFFF")!,
                border: ThemeBorder(color: ThemeColor(hex: "#401B21")!.withAlpha(0.32), width: 1.35),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.22, radius: 3.60, offsetY: 2.60),
                topHighlight: nil,
                cornerRadiusOverride: 9.0
            ),
            .system: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#674449")!,
                    ThemeColor(hex: "#7A5B60")!
                ]),
                labelColor: ThemeColor(hex: "#FFFFFF")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#886D72")!,
                    ThemeColor(hex: "#957D80")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#FFFFFF")!,
                border: ThemeBorder(color: ThemeColor(hex: "#442D31")!.withAlpha(0.32), width: 1.35),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.22, radius: 3.60, offsetY: 2.60),
                topHighlight: nil,
                cornerRadiusOverride: 9.0
            ),
            .action: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#3C2723")!,
                    ThemeColor(hex: "#5B4946")!
                ]),
                labelColor: ThemeColor(hex: "#FFFFFF")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#6F605D")!,
                    ThemeColor(hex: "#7F716F")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#FFFFFF")!,
                border: ThemeBorder(color: ThemeColor(hex: "#35221F")!.withAlpha(0.32), width: 1.35),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.22, radius: 3.60, offsetY: 2.60),
                topHighlight: nil,
                cornerRadiusOverride: 9.0
            ),
            .space: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#481F25")!.withAlpha(0.50),
                    ThemeColor(hex: "#674449")!.withAlpha(0.50)
                ]),
                labelColor: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.00),
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#735358")!.withAlpha(0.50),
                    ThemeColor(hex: "#83676B")!.withAlpha(0.50)
                ]),
                border: ThemeBorder(color: ThemeColor(hex: "#C9BDBF")!.withAlpha(0.32), width: 1.35),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.22, radius: 3.60, offsetY: 2.60),
                topHighlight: nil,
                cornerRadiusOverride: 11.0
            )
        ],
        typography: ThemeTypography(fontFamily: nil, weightRawValue: 0.34, sizeMultiplier: 1.0),
        chrome: ThemeChrome(
            inkColor: ThemeColor(hex: "#FCFAFF")!,
            mutedInkColor: ThemeColor(hex: "#FCFAFF")!.withAlpha(0.55),
            panelFill: ThemeFill(stops: [
                    ThemeColor(hex: "#5F5280")!.withAlpha(0.55)
                ]),
            highlightFill: ThemeFill(stops: [
                    ThemeColor(hex: "#FFFFFF")!.withAlpha(0.16)
                ])
        ),
        keyArt: KeyArtSet(
            assetPrefix: "keyart_dcr_",
            heightFraction: 0.52,
            bottomInsetFraction: 0.10,
            opacity: 0.90,
            fillKeys: ["space"],
            labelLiftFraction: 0.15
        ),
        effects: .none
    )

    static let enchantedGlassGarden = MochiKeyboardTheme(
        id: "mochi.enchanted-glass-garden",
        name: "Enchanted Glass Garden",
        authorName: "Mochi",
        appearance: .light,
        surface: ThemeSurface(
            baseFill: ThemeFill(stops: [
                    ThemeColor(hex: "#FBCDAC")!,
                    ThemeColor(hex: "#CFBB99")!,
                    ThemeColor(hex: "#E9C28F")!
                ]),
            backgroundImage: ThemeBackgroundImage(
                source: .bundled(name: "themebg_enchanted_glass_garden"),
                scalesToFill: true,
                verticalAnchor: 0.5,
                blurRadius: 0.0
            ),
            scrim: ThemeScrim(
                topColor: ThemeColor(hex: "#665A49")!.withAlpha(0.28),
                bottomColor: ThemeColor(hex: "#665A49")!.withAlpha(0.17)
            )
        ),
        keyStyles: [
            .input: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#FAF3E9")!.withAlpha(0.73),
                    ThemeColor(hex: "#F3EDE3")!.withAlpha(0.73)
                ]),
                labelColor: ThemeColor(hex: "#221C28")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#EEE8DF")!.withAlpha(0.85),
                    ThemeColor(hex: "#E8E1D8")!.withAlpha(0.85)
                ]),
                pressedLabelColor: ThemeColor(hex: "#221C28")!,
                border: ThemeBorder(color: ThemeColor(hex: "#FEFDFB")!.withAlpha(0.58), width: 1.20),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.17, radius: 1.90, offsetY: 1.10),
                topHighlight: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.58),
                cornerRadiusOverride: 13.0,
                glass: KeyGlass(
                    bevelColor: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.82),
                    bevelWidth: 1.30,
                    bevelFalloff: 0.34,
                    innerShadowColor: ThemeColor(hex: "#0A080F")!,
                    innerShadowOpacity: 0.20,
                    innerShadowRadius: 2.80
                )
            ),
            .system: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#F2EBE2")!.withAlpha(0.79),
                    ThemeColor(hex: "#ECE5DC")!.withAlpha(0.79)
                ]),
                labelColor: ThemeColor(hex: "#221C28")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#E6E0D7")!.withAlpha(0.91),
                    ThemeColor(hex: "#DFD9D1")!.withAlpha(0.91)
                ]),
                pressedLabelColor: ThemeColor(hex: "#221C28")!,
                border: ThemeBorder(color: ThemeColor(hex: "#FDFDFC")!.withAlpha(0.58), width: 1.20),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.17, radius: 1.90, offsetY: 1.10),
                topHighlight: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.58),
                cornerRadiusOverride: 13.0,
                glass: KeyGlass(
                    bevelColor: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.82),
                    bevelWidth: 1.30,
                    bevelFalloff: 0.34,
                    innerShadowColor: ThemeColor(hex: "#0A080F")!,
                    innerShadowOpacity: 0.20,
                    innerShadowRadius: 2.80
                )
            ),
            .action: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#F8F3ED")!.withAlpha(0.79),
                    ThemeColor(hex: "#F1EDE7")!.withAlpha(0.79)
                ]),
                labelColor: ThemeColor(hex: "#221C28")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#ECE8E2")!.withAlpha(0.91),
                    ThemeColor(hex: "#E6E1DC")!.withAlpha(0.91)
                ]),
                pressedLabelColor: ThemeColor(hex: "#221C28")!,
                border: ThemeBorder(color: ThemeColor(hex: "#FEFDFB")!.withAlpha(0.58), width: 1.20),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.17, radius: 1.90, offsetY: 1.10),
                topHighlight: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.58),
                cornerRadiusOverride: 13.0,
                glass: KeyGlass(
                    bevelColor: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.82),
                    bevelWidth: 1.30,
                    bevelFalloff: 0.34,
                    innerShadowColor: ThemeColor(hex: "#0A080F")!,
                    innerShadowOpacity: 0.20,
                    innerShadowRadius: 2.80
                )
            ),
            .space: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#FAF3E9")!.withAlpha(0.42),
                    ThemeColor(hex: "#F3EDE3")!.withAlpha(0.42)
                ]),
                labelColor: ThemeColor(hex: "#221C28")!.withAlpha(0.00),
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#F0E9E0")!.withAlpha(0.42),
                    ThemeColor(hex: "#E9E2DA")!.withAlpha(0.42)
                ]),
                border: ThemeBorder(color: ThemeColor(hex: "#FEFDFB")!.withAlpha(0.58), width: 1.20),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.17, radius: 1.90, offsetY: 1.10),
                topHighlight: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.58),
                cornerRadiusOverride: 15.0
            )
        ],
        typography: ThemeTypography(fontFamily: nil, weightRawValue: 0.34, sizeMultiplier: 1.0),
        chrome: ThemeChrome(
            inkColor: ThemeColor(hex: "#221C28")!,
            mutedInkColor: ThemeColor(hex: "#221C28")!.withAlpha(0.55),
            panelFill: ThemeFill(stops: [
                    ThemeColor(hex: "#FCFCFA")!.withAlpha(0.55)
                ]),
            highlightFill: ThemeFill(stops: [
                    ThemeColor(hex: "#000000")!.withAlpha(0.16)
                ])
        ),
        keyArt: KeyArtSet(
            assetPrefix: "keyart_egg_",
            heightFraction: 0.46,
            bottomInsetFraction: 0.09,
            opacity: 0.90,
            fillKeys: ["space"],
            labelLiftFraction: 0.14
        ),
        effects: .none
    )

    static let floatingDreamscape = MochiKeyboardTheme(
        id: "mochi.floating-dreamscape",
        name: "Floating Dreamscape",
        authorName: "Mochi",
        appearance: .dark,
        surface: ThemeSurface(
            baseFill: ThemeFill(stops: [
                    ThemeColor(hex: "#4B4873")!,
                    ThemeColor(hex: "#9881B0")!,
                    ThemeColor(hex: "#C98F96")!
                ]),
            backgroundImage: ThemeBackgroundImage(
                source: .bundled(name: "themebg_floating_dreamscape"),
                scalesToFill: true,
                verticalAnchor: 0.5,
                blurRadius: 0.0
            ),
            scrim: ThemeScrim(
                topColor: ThemeColor(hex: "#5C4B5A")!.withAlpha(0.18),
                bottomColor: ThemeColor(hex: "#5C4B5A")!.withAlpha(0.05)
            )
        ),
        keyStyles: [
            .input: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#3E2150")!,
                    ThemeColor(hex: "#271F50")!
                ]),
                labelColor: ThemeColor(hex: "#FFFFFF")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#715C7F")!,
                    ThemeColor(hex: "#625D80")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#FFFFFF")!,
                border: ThemeBorder(color: ThemeColor(hex: "#CDC5D2")!.withAlpha(0.42), width: 0.95),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.15, radius: 2.20, offsetY: 1.30),
                topHighlight: ThemeColor(hex: "#C6BDCB")!.withAlpha(0.46),
                cornerRadiusOverride: 14.0,
                glass: KeyGlass(
                    bevelColor: ThemeColor(hex: "#CDC5D2")!.withAlpha(0.60),
                    bevelWidth: 0.80,
                    bevelFalloff: 0.18,
                    innerShadowColor: ThemeColor(hex: "#0A080F")!,
                    innerShadowOpacity: 0.12,
                    innerShadowRadius: 2.00
                )
            ),
            .system: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#57466C")!,
                    ThemeColor(hex: "#7C6F8C")!
                ]),
                labelColor: ThemeColor(hex: "#FFFFFF")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#7C6F8C")!,
                    ThemeColor(hex: "#968BA3")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#FFFFFF")!,
                border: ThemeBorder(color: ThemeColor(hex: "#D2CDD8")!.withAlpha(0.42), width: 0.95),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.15, radius: 2.20, offsetY: 1.30),
                topHighlight: ThemeColor(hex: "#CBC6D1")!.withAlpha(0.46),
                cornerRadiusOverride: 14.0,
                glass: KeyGlass(
                    bevelColor: ThemeColor(hex: "#D2CDD8")!.withAlpha(0.60),
                    bevelWidth: 0.80,
                    bevelFalloff: 0.18,
                    innerShadowColor: ThemeColor(hex: "#0A080F")!,
                    innerShadowOpacity: 0.12,
                    innerShadowRadius: 2.00
                )
            ),
            .action: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#38272E")!,
                    ThemeColor(hex: "#6C6065")!
                ]),
                labelColor: ThemeColor(hex: "#FFFFFF")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#6C6065")!,
                    ThemeColor(hex: "#8A8084")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#FFFFFF")!,
                border: ThemeBorder(color: ThemeColor(hex: "#CBC7C8")!.withAlpha(0.42), width: 0.95),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.15, radius: 2.20, offsetY: 1.30),
                topHighlight: ThemeColor(hex: "#C3BEC1")!.withAlpha(0.46),
                cornerRadiusOverride: 14.0,
                glass: KeyGlass(
                    bevelColor: ThemeColor(hex: "#CBC7C8")!.withAlpha(0.60),
                    bevelWidth: 0.80,
                    bevelFalloff: 0.18,
                    innerShadowColor: ThemeColor(hex: "#0A080F")!,
                    innerShadowOpacity: 0.12,
                    innerShadowRadius: 2.00
                )
            ),
            .space: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#3E2150")!.withAlpha(0.50),
                    ThemeColor(hex: "#271F50")!.withAlpha(0.50)
                ]),
                labelColor: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.00),
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#6A5378")!.withAlpha(0.50),
                    ThemeColor(hex: "#5A547A")!.withAlpha(0.50)
                ]),
                border: ThemeBorder(color: ThemeColor(hex: "#C6BDCB")!.withAlpha(0.42), width: 0.95),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.15, radius: 2.20, offsetY: 1.30),
                topHighlight: ThemeColor(hex: "#C6BDCB")!.withAlpha(0.46),
                cornerRadiusOverride: 16.0
            )
        ],
        typography: ThemeTypography(fontFamily: nil, weightRawValue: 0.34, sizeMultiplier: 1.0),
        chrome: ThemeChrome(
            inkColor: ThemeColor(hex: "#F2ECF0")!,
            mutedInkColor: ThemeColor(hex: "#F2ECF0")!.withAlpha(0.55),
            panelFill: ThemeFill(stops: [
                    ThemeColor(hex: "#58557C")!.withAlpha(0.55)
                ]),
            highlightFill: ThemeFill(stops: [
                    ThemeColor(hex: "#FFFFFF")!.withAlpha(0.16)
                ])
        ),
        keyArt: KeyArtSet(
            assetPrefix: "keyart_fld_",
            heightFraction: 0.48,
            bottomInsetFraction: 0.09,
            opacity: 0.90,
            fillKeys: ["space"],
            labelLiftFraction: 0.14
        ),
        effects: .none
    )

    static let glitchGarden = MochiKeyboardTheme(
        id: "mochi.glitch-garden",
        name: "Glitch Garden",
        authorName: "Mochi",
        appearance: .dark,
        surface: ThemeSurface(
            baseFill: ThemeFill(stops: [
                    ThemeColor(hex: "#3A365F")!,
                    ThemeColor(hex: "#3D586A")!,
                    ThemeColor(hex: "#3B4267")!
                ]),
            backgroundImage: ThemeBackgroundImage(
                source: .bundled(name: "themebg_glitch_garden"),
                scalesToFill: true,
                verticalAnchor: 0.5,
                blurRadius: 0.0
            ),
            scrim: ThemeScrim(
                topColor: ThemeColor(hex: "#3B3F54")!.withAlpha(0.21),
                bottomColor: ThemeColor(hex: "#3B3F54")!.withAlpha(0.07)
            )
        ),
        keyStyles: [
            .input: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#10152A")!,
                    ThemeColor(hex: "#2E3244")!
                ]),
                labelColor: ThemeColor(hex: "#FFFFFF")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#585C6A")!,
                    ThemeColor(hex: "#626673")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#FFFFFF")!,
                border: ThemeBorder(color: ThemeColor(hex: "#C4C5CA")!.withAlpha(0.60), width: 1.00),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.32, radius: 2.60, offsetY: 1.60),
                topHighlight: ThemeColor(hex: "#BBBDC3")!.withAlpha(0.28),
                cornerRadiusOverride: 12.0,
                glass: KeyGlass(
                    bevelColor: ThemeColor(hex: "#C4C5CA")!.withAlpha(0.62),
                    bevelWidth: 1.00,
                    bevelFalloff: 0.12,
                    innerShadowColor: ThemeColor(hex: "#0A080F")!,
                    innerShadowOpacity: 0.36,
                    innerShadowRadius: 3.00
                )
            ),
            .system: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#404354")!,
                    ThemeColor(hex: "#4D5160")!
                ]),
                labelColor: ThemeColor(hex: "#FFFFFF")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#6B6E7B")!,
                    ThemeColor(hex: "#737682")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#FFFFFF")!,
                border: ThemeBorder(color: ThemeColor(hex: "#CBCDD1")!.withAlpha(0.60), width: 1.00),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.32, radius: 2.60, offsetY: 1.60),
                topHighlight: ThemeColor(hex: "#C4C5CA")!.withAlpha(0.28),
                cornerRadiusOverride: 12.0,
                glass: KeyGlass(
                    bevelColor: ThemeColor(hex: "#CBCDD1")!.withAlpha(0.62),
                    bevelWidth: 1.00,
                    bevelFalloff: 0.12,
                    innerShadowColor: ThemeColor(hex: "#0A080F")!,
                    innerShadowOpacity: 0.36,
                    innerShadowRadius: 3.00
                )
            ),
            .action: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#1A141B")!,
                    ThemeColor(hex: "#363138")!
                ]),
                labelColor: ThemeColor(hex: "#FFFFFF")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#5F5B60")!,
                    ThemeColor(hex: "#69656A")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#FFFFFF")!,
                border: ThemeBorder(color: ThemeColor(hex: "#C6C4C6")!.withAlpha(0.60), width: 1.00),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.32, radius: 2.60, offsetY: 1.60),
                topHighlight: ThemeColor(hex: "#BEBCBE")!.withAlpha(0.28),
                cornerRadiusOverride: 12.0,
                glass: KeyGlass(
                    bevelColor: ThemeColor(hex: "#C6C4C6")!.withAlpha(0.62),
                    bevelWidth: 1.00,
                    bevelFalloff: 0.12,
                    innerShadowColor: ThemeColor(hex: "#0A080F")!,
                    innerShadowOpacity: 0.36,
                    innerShadowRadius: 3.00
                )
            ),
            .space: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#10152A")!.withAlpha(0.50),
                    ThemeColor(hex: "#2E3244")!.withAlpha(0.50)
                ]),
                labelColor: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.00),
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#505363")!.withAlpha(0.50),
                    ThemeColor(hex: "#5B5E6C")!.withAlpha(0.50)
                ]),
                border: ThemeBorder(color: ThemeColor(hex: "#BBBDC3")!.withAlpha(0.60), width: 1.00),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.32, radius: 2.60, offsetY: 1.60),
                topHighlight: ThemeColor(hex: "#BBBDC3")!.withAlpha(0.28),
                cornerRadiusOverride: 14.0
            )
        ],
        typography: ThemeTypography(fontFamily: nil, weightRawValue: 0.34, sizeMultiplier: 1.0),
        chrome: ThemeChrome(
            inkColor: ThemeColor(hex: "#F2ECF0")!,
            mutedInkColor: ThemeColor(hex: "#F2ECF0")!.withAlpha(0.55),
            panelFill: ThemeFill(stops: [
                    ThemeColor(hex: "#585577")!.withAlpha(0.55)
                ]),
            highlightFill: ThemeFill(stops: [
                    ThemeColor(hex: "#FFFFFF")!.withAlpha(0.16)
                ])
        ),
        keyArt: KeyArtSet(
            assetPrefix: "keyart_glg_",
            heightFraction: 0.44,
            bottomInsetFraction: 0.09,
            opacity: 0.90,
            fillKeys: ["space"],
            labelLiftFraction: 0.14
        ),
        effects: ThemeEffects(
            isEnabled: true,
            birthRate: 6.0,
            particleImageName: nil,
            tint: ThemeColor(hex: "#FF7BD5")!
        )
    )

    static let holographicDaydream = MochiKeyboardTheme(
        id: "mochi.holographic-daydream",
        name: "Holographic Daydream",
        authorName: "Mochi",
        appearance: .dark,
        surface: ThemeSurface(
            baseFill: ThemeFill(stops: [
                    ThemeColor(hex: "#B596DC")!,
                    ThemeColor(hex: "#A2A4E3")!,
                    ThemeColor(hex: "#D8B5E5")!
                ]),
            backgroundImage: ThemeBackgroundImage(
                source: .bundled(name: "themebg_holographic_daydream"),
                scalesToFill: true,
                verticalAnchor: 0.5,
                blurRadius: 0.0
            ),
            scrim: ThemeScrim(
                topColor: ThemeColor(hex: "#625576")!.withAlpha(0.18),
                bottomColor: ThemeColor(hex: "#625576")!.withAlpha(0.05)
            )
        ),
        keyStyles: [
            .input: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#341943")!,
                    ThemeColor(hex: "#28204B")!
                ]),
                labelColor: ThemeColor(hex: "#FFFFFF")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#6D5978")!,
                    ThemeColor(hex: "#635D7C")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#FFFFFF")!,
                border: ThemeBorder(color: ThemeColor(hex: "#CBC4CF")!.withAlpha(0.42), width: 0.95),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.15, radius: 2.20, offsetY: 1.30),
                topHighlight: ThemeColor(hex: "#C4BCC8")!.withAlpha(0.46),
                cornerRadiusOverride: 14.0,
                glass: KeyGlass(
                    bevelColor: ThemeColor(hex: "#CBC4CF")!.withAlpha(0.60),
                    bevelWidth: 0.80,
                    bevelFalloff: 0.18,
                    innerShadowColor: ThemeColor(hex: "#0A080F")!,
                    innerShadowOpacity: 0.12,
                    innerShadowRadius: 2.00
                )
            ),
            .system: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#524364")!,
                    ThemeColor(hex: "#796D86")!
                ]),
                labelColor: ThemeColor(hex: "#FFFFFF")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#796D86")!,
                    ThemeColor(hex: "#93899E")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#FFFFFF")!,
                border: ThemeBorder(color: ThemeColor(hex: "#D1CCD5")!.withAlpha(0.42), width: 0.95),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.15, radius: 2.20, offsetY: 1.30),
                topHighlight: ThemeColor(hex: "#C9C5CF")!.withAlpha(0.46),
                cornerRadiusOverride: 14.0,
                glass: KeyGlass(
                    bevelColor: ThemeColor(hex: "#D1CCD5")!.withAlpha(0.60),
                    bevelWidth: 0.80,
                    bevelFalloff: 0.18,
                    innerShadowColor: ThemeColor(hex: "#0A080F")!,
                    innerShadowOpacity: 0.12,
                    innerShadowRadius: 2.00
                )
            ),
            .action: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#242133")!,
                    ThemeColor(hex: "#615E6C")!
                ]),
                labelColor: ThemeColor(hex: "#FFFFFF")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#615E6C")!,
                    ThemeColor(hex: "#817F8A")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#FFFFFF")!,
                border: ThemeBorder(color: ThemeColor(hex: "#C7C6CA")!.withAlpha(0.42), width: 0.95),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.15, radius: 2.20, offsetY: 1.30),
                topHighlight: ThemeColor(hex: "#BFBEC3")!.withAlpha(0.46),
                cornerRadiusOverride: 14.0,
                glass: KeyGlass(
                    bevelColor: ThemeColor(hex: "#C7C6CA")!.withAlpha(0.60),
                    bevelWidth: 0.80,
                    bevelFalloff: 0.18,
                    innerShadowColor: ThemeColor(hex: "#0A080F")!,
                    innerShadowOpacity: 0.12,
                    innerShadowRadius: 2.00
                )
            ),
            .space: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#341943")!.withAlpha(0.50),
                    ThemeColor(hex: "#28204B")!.withAlpha(0.50)
                ]),
                labelColor: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.00),
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#655171")!.withAlpha(0.50),
                    ThemeColor(hex: "#5B5576")!.withAlpha(0.50)
                ]),
                border: ThemeBorder(color: ThemeColor(hex: "#C4BCC8")!.withAlpha(0.42), width: 0.95),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.15, radius: 2.20, offsetY: 1.30),
                topHighlight: ThemeColor(hex: "#C4BCC8")!.withAlpha(0.46),
                cornerRadiusOverride: 16.0
            )
        ],
        typography: ThemeTypography(fontFamily: nil, weightRawValue: 0.34, sizeMultiplier: 1.0),
        chrome: ThemeChrome(
            inkColor: ThemeColor(hex: "#1F1A25")!,
            mutedInkColor: ThemeColor(hex: "#1F1A25")!.withAlpha(0.55),
            panelFill: ThemeFill(stops: [
                    ThemeColor(hex: "#FCFBFE")!.withAlpha(0.55)
                ]),
            highlightFill: ThemeFill(stops: [
                    ThemeColor(hex: "#000000")!.withAlpha(0.16)
                ])
        ),
        keyArt: KeyArtSet(
            assetPrefix: "keyart_hgd_",
            heightFraction: 0.48,
            bottomInsetFraction: 0.09,
            opacity: 0.90,
            fillKeys: ["space"],
            labelLiftFraction: 0.14
        ),
        effects: .none
    )

    static let liquidAurora = MochiKeyboardTheme(
        id: "mochi.liquid-aurora",
        name: "Liquid Aurora",
        authorName: "Mochi",
        appearance: .dark,
        surface: ThemeSurface(
            baseFill: ThemeFill(stops: [
                    ThemeColor(hex: "#9F8EAE")!,
                    ThemeColor(hex: "#4E505F")!,
                    ThemeColor(hex: "#AFB5D0")!
                ]),
            backgroundImage: ThemeBackgroundImage(
                source: .bundled(name: "themebg_liquid_aurora"),
                scalesToFill: true,
                verticalAnchor: 0.5,
                blurRadius: 0.0
            ),
            scrim: ThemeScrim(
                topColor: ThemeColor(hex: "#46434E")!.withAlpha(0.24),
                bottomColor: ThemeColor(hex: "#46434E")!.withAlpha(0.08)
            )
        ),
        keyStyles: [
            .input: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#161834")!,
                    ThemeColor(hex: "#32334C")!
                ]),
                labelColor: ThemeColor(hex: "#FFFFFF")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#5B5C70")!,
                    ThemeColor(hex: "#656678")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#FFFFFF")!,
                border: ThemeBorder(color: ThemeColor(hex: "#C4C5CC")!.withAlpha(0.60), width: 1.00),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.32, radius: 2.60, offsetY: 1.60),
                topHighlight: ThemeColor(hex: "#BCBDC5")!.withAlpha(0.28),
                cornerRadiusOverride: 12.0,
                glass: KeyGlass(
                    bevelColor: ThemeColor(hex: "#C4C5CC")!.withAlpha(0.62),
                    bevelWidth: 1.00,
                    bevelFalloff: 0.12,
                    innerShadowColor: ThemeColor(hex: "#0A080F")!,
                    innerShadowOpacity: 0.36,
                    innerShadowRadius: 3.00
                )
            ),
            .system: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#43445B")!,
                    ThemeColor(hex: "#505166")!
                ]),
                labelColor: ThemeColor(hex: "#FFFFFF")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#6D6E80")!,
                    ThemeColor(hex: "#757687")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#FFFFFF")!,
                border: ThemeBorder(color: ThemeColor(hex: "#CCCDD3")!.withAlpha(0.60), width: 1.00),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.32, radius: 2.60, offsetY: 1.60),
                topHighlight: ThemeColor(hex: "#C4C5CC")!.withAlpha(0.28),
                cornerRadiusOverride: 12.0,
                glass: KeyGlass(
                    bevelColor: ThemeColor(hex: "#CCCDD3")!.withAlpha(0.62),
                    bevelWidth: 1.00,
                    bevelFalloff: 0.12,
                    innerShadowColor: ThemeColor(hex: "#0A080F")!,
                    innerShadowOpacity: 0.36,
                    innerShadowRadius: 3.00
                )
            ),
            .action: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#1C1A1F")!,
                    ThemeColor(hex: "#363439")!
                ]),
                labelColor: ThemeColor(hex: "#FFFFFF")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#5E5D60")!,
                    ThemeColor(hex: "#68676A")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#FFFFFF")!,
                border: ThemeBorder(color: ThemeColor(hex: "#C6C5C6")!.withAlpha(0.60), width: 1.00),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.32, radius: 2.60, offsetY: 1.60),
                topHighlight: ThemeColor(hex: "#BEBDBE")!.withAlpha(0.28),
                cornerRadiusOverride: 12.0,
                glass: KeyGlass(
                    bevelColor: ThemeColor(hex: "#C6C5C6")!.withAlpha(0.62),
                    bevelWidth: 1.00,
                    bevelFalloff: 0.12,
                    innerShadowColor: ThemeColor(hex: "#0A080F")!,
                    innerShadowOpacity: 0.36,
                    innerShadowRadius: 3.00
                )
            ),
            .space: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#161834")!.withAlpha(0.50),
                    ThemeColor(hex: "#32334C")!.withAlpha(0.50)
                ]),
                labelColor: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.00),
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#525468")!.withAlpha(0.50),
                    ThemeColor(hex: "#5D5E72")!.withAlpha(0.50)
                ]),
                border: ThemeBorder(color: ThemeColor(hex: "#BCBDC5")!.withAlpha(0.60), width: 1.00),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.32, radius: 2.60, offsetY: 1.60),
                topHighlight: ThemeColor(hex: "#BCBDC5")!.withAlpha(0.28),
                cornerRadiusOverride: 14.0
            )
        ],
        typography: ThemeTypography(fontFamily: nil, weightRawValue: 0.34, sizeMultiplier: 1.0),
        chrome: ThemeChrome(
            inkColor: ThemeColor(hex: "#F2ECF0")!,
            mutedInkColor: ThemeColor(hex: "#F2ECF0")!.withAlpha(0.55),
            panelFill: ThemeFill(stops: [
                    ThemeColor(hex: "#575866")!.withAlpha(0.55)
                ]),
            highlightFill: ThemeFill(stops: [
                    ThemeColor(hex: "#FFFFFF")!.withAlpha(0.16)
                ])
        ),
        keyArt: KeyArtSet(
            assetPrefix: "keyart_lqa_",
            heightFraction: 0.44,
            bottomInsetFraction: 0.09,
            opacity: 0.90,
            fillKeys: ["space"],
            labelLiftFraction: 0.14
        ),
        effects: ThemeEffects(
            isEnabled: true,
            birthRate: 6.0,
            particleImageName: nil,
            tint: ThemeColor(hex: "#CFE8FF")!
        )
    )

    static let miniatureGreenhouse = MochiKeyboardTheme(
        id: "mochi.miniature-greenhouse",
        name: "Miniature Greenhouse",
        authorName: "Mochi",
        appearance: .light,
        surface: ThemeSurface(
            baseFill: ThemeFill(stops: [
                    ThemeColor(hex: "#775323")!,
                    ThemeColor(hex: "#354328")!,
                    ThemeColor(hex: "#D58A48")!
                ]),
            backgroundImage: ThemeBackgroundImage(
                source: .bundled(name: "themebg_miniature_greenhouse"),
                scalesToFill: true,
                verticalAnchor: 0.5,
                blurRadius: 0.0
            ),
            scrim: ThemeScrim(
                topColor: ThemeColor(hex: "#292716")!.withAlpha(0.26),
                bottomColor: ThemeColor(hex: "#292716")!.withAlpha(0.16)
            )
        ),
        keyStyles: [
            .input: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#F6C077")!.withAlpha(0.73),
                    ThemeColor(hex: "#ECB872")!.withAlpha(0.73)
                ]),
                labelColor: ThemeColor(hex: "#1D1822")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#E4B26E")!.withAlpha(0.85),
                    ThemeColor(hex: "#D9AA69")!.withAlpha(0.85)
                ]),
                pressedLabelColor: ThemeColor(hex: "#1D1822")!,
                border: ThemeBorder(color: ThemeColor(hex: "#FEF7ED")!.withAlpha(0.58), width: 1.20),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.17, radius: 1.90, offsetY: 1.10),
                topHighlight: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.58),
                cornerRadiusOverride: 13.0,
                glass: KeyGlass(
                    bevelColor: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.82),
                    bevelWidth: 1.30,
                    bevelFalloff: 0.34,
                    innerShadowColor: ThemeColor(hex: "#0A080F")!,
                    innerShadowOpacity: 0.20,
                    innerShadowRadius: 2.80
                )
            ),
            .system: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#EAB771")!.withAlpha(0.79),
                    ThemeColor(hex: "#E0AF6C")!.withAlpha(0.79)
                ]),
                labelColor: ThemeColor(hex: "#1D1822")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#D7A868")!.withAlpha(0.91),
                    ThemeColor(hex: "#CC9F62")!.withAlpha(0.91)
                ]),
                pressedLabelColor: ThemeColor(hex: "#1D1822")!,
                border: ThemeBorder(color: ThemeColor(hex: "#FAEFDF")!.withAlpha(0.58), width: 1.20),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.17, radius: 1.90, offsetY: 1.10),
                topHighlight: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.58),
                cornerRadiusOverride: 13.0,
                glass: KeyGlass(
                    bevelColor: ThemeColor(hex: "#FEFCF9")!.withAlpha(0.82),
                    bevelWidth: 1.30,
                    bevelFalloff: 0.34,
                    innerShadowColor: ThemeColor(hex: "#0A080F")!,
                    innerShadowOpacity: 0.20,
                    innerShadowRadius: 2.80
                )
            ),
            .action: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#EAC38D")!.withAlpha(0.79),
                    ThemeColor(hex: "#E1BB88")!.withAlpha(0.79)
                ]),
                labelColor: ThemeColor(hex: "#1D1822")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#DAB583")!.withAlpha(0.91),
                    ThemeColor(hex: "#CFAC7D")!.withAlpha(0.91)
                ]),
                pressedLabelColor: ThemeColor(hex: "#1D1822")!,
                border: ThemeBorder(color: ThemeColor(hex: "#FCF7F0")!.withAlpha(0.58), width: 1.20),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.17, radius: 1.90, offsetY: 1.10),
                topHighlight: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.58),
                cornerRadiusOverride: 13.0,
                glass: KeyGlass(
                    bevelColor: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.82),
                    bevelWidth: 1.30,
                    bevelFalloff: 0.34,
                    innerShadowColor: ThemeColor(hex: "#0A080F")!,
                    innerShadowOpacity: 0.20,
                    innerShadowRadius: 2.80
                )
            ),
            .space: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#F6C077")!.withAlpha(0.42),
                    ThemeColor(hex: "#ECB872")!.withAlpha(0.42)
                ]),
                labelColor: ThemeColor(hex: "#1D1822")!.withAlpha(0.00),
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#E6B46F")!.withAlpha(0.42),
                    ThemeColor(hex: "#DBAB6A")!.withAlpha(0.42)
                ]),
                border: ThemeBorder(color: ThemeColor(hex: "#FEF7ED")!.withAlpha(0.58), width: 1.20),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.17, radius: 1.90, offsetY: 1.10),
                topHighlight: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.58),
                cornerRadiusOverride: 15.0
            )
        ],
        typography: ThemeTypography(fontFamily: nil, weightRawValue: 0.34, sizeMultiplier: 1.0),
        chrome: ThemeChrome(
            inkColor: ThemeColor(hex: "#F2ECF0")!,
            mutedInkColor: ThemeColor(hex: "#F2ECF0")!.withAlpha(0.55),
            panelFill: ThemeFill(stops: [
                    ThemeColor(hex: "#535C47")!.withAlpha(0.55)
                ]),
            highlightFill: ThemeFill(stops: [
                    ThemeColor(hex: "#FFFFFF")!.withAlpha(0.16)
                ])
        ),
        keyArt: KeyArtSet(
            assetPrefix: "keyart_mng_",
            heightFraction: 0.46,
            bottomInsetFraction: 0.09,
            opacity: 0.90,
            fillKeys: ["space"],
            labelLiftFraction: 0.14
        ),
        effects: ThemeEffects(
            isEnabled: true,
            birthRate: 5.0,
            particleImageName: nil,
            tint: ThemeColor(hex: "#BFE8A8")!
        )
    )

    static let moonArcadeDreams = MochiKeyboardTheme(
        id: "mochi.moon-arcade-dreams",
        name: "Moon Arcade Dreams",
        authorName: "Mochi",
        appearance: .dark,
        surface: ThemeSurface(
            baseFill: ThemeFill(stops: [
                    ThemeColor(hex: "#251C53")!,
                    ThemeColor(hex: "#423178")!,
                    ThemeColor(hex: "#CA71E5")!
                ]),
            backgroundImage: ThemeBackgroundImage(
                source: .bundled(name: "themebg_moon_arcade_dreams"),
                scalesToFill: true,
                verticalAnchor: 0.5,
                blurRadius: 0.0
            ),
            scrim: ThemeScrim(
                topColor: ThemeColor(hex: "#442F54")!.withAlpha(0.23),
                bottomColor: ThemeColor(hex: "#442F54")!.withAlpha(0.08)
            )
        ),
        keyStyles: [
            .input: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#1D0C18")!,
                    ThemeColor(hex: "#3B2D37")!
                ]),
                labelColor: ThemeColor(hex: "#FFFFFF")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#645860")!,
                    ThemeColor(hex: "#6D626A")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#FFFFFF")!,
                border: ThemeBorder(color: ThemeColor(hex: "#C8C4C6")!.withAlpha(0.60), width: 1.00),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.32, radius: 2.60, offsetY: 1.60),
                topHighlight: ThemeColor(hex: "#C0BBBF")!.withAlpha(0.28),
                cornerRadiusOverride: 12.0,
                glass: KeyGlass(
                    bevelColor: ThemeColor(hex: "#C8C4C6")!.withAlpha(0.62),
                    bevelWidth: 1.00,
                    bevelFalloff: 0.12,
                    innerShadowColor: ThemeColor(hex: "#0A080F")!,
                    innerShadowOpacity: 0.36,
                    innerShadowRadius: 3.00
                )
            ),
            .system: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#4C3F48")!,
                    ThemeColor(hex: "#594D55")!
                ]),
                labelColor: ThemeColor(hex: "#FFFFFF")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#756B72")!,
                    ThemeColor(hex: "#7D737A")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#FFFFFF")!,
                border: ThemeBorder(color: ThemeColor(hex: "#CFCBCE")!.withAlpha(0.60), width: 1.00),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.32, radius: 2.60, offsetY: 1.60),
                topHighlight: ThemeColor(hex: "#C8C4C6")!.withAlpha(0.28),
                cornerRadiusOverride: 12.0,
                glass: KeyGlass(
                    bevelColor: ThemeColor(hex: "#CFCBCE")!.withAlpha(0.62),
                    bevelWidth: 1.00,
                    bevelFalloff: 0.12,
                    innerShadowColor: ThemeColor(hex: "#0A080F")!,
                    innerShadowOpacity: 0.36,
                    innerShadowRadius: 3.00
                )
            ),
            .action: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#171012")!,
                    ThemeColor(hex: "#363032")!
                ]),
                labelColor: ThemeColor(hex: "#FFFFFF")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#5F5A5C")!,
                    ThemeColor(hex: "#696466")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#FFFFFF")!,
                border: ThemeBorder(color: ThemeColor(hex: "#C6C4C5")!.withAlpha(0.60), width: 1.00),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.32, radius: 2.60, offsetY: 1.60),
                topHighlight: ThemeColor(hex: "#BEBCBD")!.withAlpha(0.28),
                cornerRadiusOverride: 12.0,
                glass: KeyGlass(
                    bevelColor: ThemeColor(hex: "#C6C4C5")!.withAlpha(0.62),
                    bevelWidth: 1.00,
                    bevelFalloff: 0.12,
                    innerShadowColor: ThemeColor(hex: "#0A080F")!,
                    innerShadowOpacity: 0.36,
                    innerShadowRadius: 3.00
                )
            ),
            .space: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#1D0C18")!.withAlpha(0.50),
                    ThemeColor(hex: "#3B2D37")!.withAlpha(0.50)
                ]),
                labelColor: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.00),
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#5B4F58")!.withAlpha(0.50),
                    ThemeColor(hex: "#665B62")!.withAlpha(0.50)
                ]),
                border: ThemeBorder(color: ThemeColor(hex: "#C0BBBF")!.withAlpha(0.60), width: 1.00),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.32, radius: 2.60, offsetY: 1.60),
                topHighlight: ThemeColor(hex: "#C0BBBF")!.withAlpha(0.28),
                cornerRadiusOverride: 14.0
            )
        ],
        typography: ThemeTypography(fontFamily: nil, weightRawValue: 0.34, sizeMultiplier: 1.0),
        chrome: ThemeChrome(
            inkColor: ThemeColor(hex: "#F2ECF0")!,
            mutedInkColor: ThemeColor(hex: "#F2ECF0")!.withAlpha(0.55),
            panelFill: ThemeFill(stops: [
                    ThemeColor(hex: "#5B547C")!.withAlpha(0.55)
                ]),
            highlightFill: ThemeFill(stops: [
                    ThemeColor(hex: "#FFFFFF")!.withAlpha(0.16)
                ])
        ),
        keyArt: KeyArtSet(
            assetPrefix: "keyart_mad_",
            heightFraction: 0.44,
            bottomInsetFraction: 0.09,
            opacity: 0.90,
            fillKeys: ["space"],
            labelLiftFraction: 0.14
        ),
        effects: ThemeEffects(
            isEnabled: true,
            birthRate: 7.0,
            particleImageName: nil,
            tint: ThemeColor(hex: "#FF6BE0")!
        )
    )

    static let neonAquarium = MochiKeyboardTheme(
        id: "mochi.neon-aquarium",
        name: "Neon Aquarium",
        authorName: "Mochi",
        appearance: .light,
        surface: ThemeSurface(
            baseFill: ThemeFill(stops: [
                    ThemeColor(hex: "#1695D8")!,
                    ThemeColor(hex: "#085397")!,
                    ThemeColor(hex: "#126BE2")!
                ]),
            backgroundImage: ThemeBackgroundImage(
                source: .bundled(name: "themebg_neon_aquarium"),
                scalesToFill: true,
                verticalAnchor: 0.5,
                blurRadius: 0.0
            ),
            scrim: ThemeScrim(
                topColor: ThemeColor(hex: "#0F2B4D")!.withAlpha(0.26),
                bottomColor: ThemeColor(hex: "#0F2B4D")!.withAlpha(0.16)
            )
        ),
        keyStyles: [
            .input: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#F7CCDA")!.withAlpha(0.73),
                    ThemeColor(hex: "#EFC5D2")!.withAlpha(0.73)
                ]),
                labelColor: ThemeColor(hex: "#221C28")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#E8C0CC")!.withAlpha(0.85),
                    ThemeColor(hex: "#DFB8C4")!.withAlpha(0.85)
                ]),
                pressedLabelColor: ThemeColor(hex: "#221C28")!,
                border: ThemeBorder(color: ThemeColor(hex: "#FFFCFD")!.withAlpha(0.58), width: 1.20),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.17, radius: 1.90, offsetY: 1.10),
                topHighlight: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.58),
                cornerRadiusOverride: 13.0,
                glass: KeyGlass(
                    bevelColor: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.82),
                    bevelWidth: 1.30,
                    bevelFalloff: 0.34,
                    innerShadowColor: ThemeColor(hex: "#0A080F")!,
                    innerShadowOpacity: 0.20,
                    innerShadowRadius: 2.80
                )
            ),
            .system: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#EDC4D1")!.withAlpha(0.79),
                    ThemeColor(hex: "#E5BDC9")!.withAlpha(0.79)
                ]),
                labelColor: ThemeColor(hex: "#221C28")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#DDB7C3")!.withAlpha(0.91),
                    ThemeColor(hex: "#D4AFBA")!.withAlpha(0.91)
                ]),
                pressedLabelColor: ThemeColor(hex: "#221C28")!,
                border: ThemeBorder(color: ThemeColor(hex: "#FEFBFC")!.withAlpha(0.58), width: 1.20),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.17, radius: 1.90, offsetY: 1.10),
                topHighlight: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.58),
                cornerRadiusOverride: 13.0,
                glass: KeyGlass(
                    bevelColor: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.82),
                    bevelWidth: 1.30,
                    bevelFalloff: 0.34,
                    innerShadowColor: ThemeColor(hex: "#0A080F")!,
                    innerShadowOpacity: 0.20,
                    innerShadowRadius: 2.80
                )
            ),
            .action: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#D1D7E7")!.withAlpha(0.79),
                    ThemeColor(hex: "#CAD0E0")!.withAlpha(0.79)
                ]),
                labelColor: ThemeColor(hex: "#221C28")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#C4CAD9")!.withAlpha(0.91),
                    ThemeColor(hex: "#BCC2D1")!.withAlpha(0.91)
                ]),
                pressedLabelColor: ThemeColor(hex: "#221C28")!,
                border: ThemeBorder(color: ThemeColor(hex: "#FCFDFE")!.withAlpha(0.58), width: 1.20),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.17, radius: 1.90, offsetY: 1.10),
                topHighlight: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.58),
                cornerRadiusOverride: 13.0,
                glass: KeyGlass(
                    bevelColor: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.82),
                    bevelWidth: 1.30,
                    bevelFalloff: 0.34,
                    innerShadowColor: ThemeColor(hex: "#0A080F")!,
                    innerShadowOpacity: 0.20,
                    innerShadowRadius: 2.80
                )
            ),
            .space: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#F7CCDA")!.withAlpha(0.42),
                    ThemeColor(hex: "#EFC5D2")!.withAlpha(0.42)
                ]),
                labelColor: ThemeColor(hex: "#221C28")!.withAlpha(0.00),
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#EAC1CE")!.withAlpha(0.42),
                    ThemeColor(hex: "#E1BAC6")!.withAlpha(0.42)
                ]),
                border: ThemeBorder(color: ThemeColor(hex: "#FFFCFD")!.withAlpha(0.58), width: 1.20),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.17, radius: 1.90, offsetY: 1.10),
                topHighlight: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.58),
                cornerRadiusOverride: 15.0
            )
        ],
        typography: ThemeTypography(fontFamily: nil, weightRawValue: 0.34, sizeMultiplier: 1.0),
        chrome: ThemeChrome(
            inkColor: ThemeColor(hex: "#F2ECF0")!,
            mutedInkColor: ThemeColor(hex: "#F2ECF0")!.withAlpha(0.55),
            panelFill: ThemeFill(stops: [
                    ThemeColor(hex: "#1E5B95")!.withAlpha(0.55)
                ]),
            highlightFill: ThemeFill(stops: [
                    ThemeColor(hex: "#FFFFFF")!.withAlpha(0.16)
                ])
        ),
        keyArt: KeyArtSet(
            assetPrefix: "keyart_naq_",
            heightFraction: 0.46,
            bottomInsetFraction: 0.09,
            opacity: 0.90,
            fillKeys: ["space"],
            labelLiftFraction: 0.14
        ),
        effects: ThemeEffects(
            isEnabled: true,
            birthRate: 6.0,
            particleImageName: nil,
            tint: ThemeColor(hex: "#5EE8FF")!
        )
    )

    static let pastelBeyond = MochiKeyboardTheme(
        id: "mochi.pastel-beyond",
        name: "Pastel Beyond",
        authorName: "Mochi",
        appearance: .light,
        surface: ThemeSurface(
            baseFill: ThemeFill(stops: [
                    ThemeColor(hex: "#B8ADDA")!,
                    ThemeColor(hex: "#BBA5E6")!,
                    ThemeColor(hex: "#FBCED3")!
                ]),
            backgroundImage: ThemeBackgroundImage(
                source: .bundled(name: "themebg_pastel_beyond"),
                scalesToFill: true,
                verticalAnchor: 0.5,
                blurRadius: 0.0
            ),
            scrim: ThemeScrim(
                topColor: ThemeColor(hex: "#72627A")!.withAlpha(0.18),
                bottomColor: ThemeColor(hex: "#72627A")!.withAlpha(0.05)
            )
        ),
        keyStyles: [
            .input: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#FFF0F1")!,
                    ThemeColor(hex: "#F7E9E9")!
                ]),
                labelColor: ThemeColor(hex: "#221C28")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#F3E5E6")!,
                    ThemeColor(hex: "#EBDEDE")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#221C28")!,
                border: ThemeBorder(color: ThemeColor(hex: "#B3A8A9")!.withAlpha(0.40), width: 1.15),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.30, radius: 4.20, offsetY: 3.00),
                topHighlight: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.62),
                cornerRadiusOverride: 19.0,
                glass: KeyGlass(
                    bevelColor: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.00),
                    bevelWidth: 0.00,
                    bevelFalloff: 0.50,
                    innerShadowColor: ThemeColor(hex: "#FFFFFF")!,
                    innerShadowOpacity: 0.34,
                    innerShadowRadius: 3.20
                )
            ),
            .system: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#F7E9E9")!,
                    ThemeColor(hex: "#EFE1E2")!
                ]),
                labelColor: ThemeColor(hex: "#221C28")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#EBDEDE")!,
                    ThemeColor(hex: "#E3D6D6")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#221C28")!,
                border: ThemeBorder(color: ThemeColor(hex: "#ADA3A3")!.withAlpha(0.40), width: 1.15),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.30, radius: 4.20, offsetY: 3.00),
                topHighlight: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.62),
                cornerRadiusOverride: 19.0,
                glass: KeyGlass(
                    bevelColor: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.00),
                    bevelWidth: 0.00,
                    bevelFalloff: 0.50,
                    innerShadowColor: ThemeColor(hex: "#FFFFFF")!,
                    innerShadowOpacity: 0.34,
                    innerShadowRadius: 3.20
                )
            ),
            .action: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#FDF1F1")!,
                    ThemeColor(hex: "#F6E9EA")!
                ]),
                labelColor: ThemeColor(hex: "#221C28")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#F2E6E6")!,
                    ThemeColor(hex: "#EADEDE")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#221C28")!,
                border: ThemeBorder(color: ThemeColor(hex: "#B1A9A9")!.withAlpha(0.40), width: 1.15),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.30, radius: 4.20, offsetY: 3.00),
                topHighlight: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.62),
                cornerRadiusOverride: 19.0,
                glass: KeyGlass(
                    bevelColor: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.00),
                    bevelWidth: 0.00,
                    bevelFalloff: 0.50,
                    innerShadowColor: ThemeColor(hex: "#FFFFFF")!,
                    innerShadowOpacity: 0.34,
                    innerShadowRadius: 3.20
                )
            ),
            .space: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#FFF0F1")!.withAlpha(0.42),
                    ThemeColor(hex: "#F7E9E9")!.withAlpha(0.42)
                ]),
                labelColor: ThemeColor(hex: "#221C28")!.withAlpha(0.00),
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#F5E6E7")!.withAlpha(0.42),
                    ThemeColor(hex: "#EDDFDF")!.withAlpha(0.42)
                ]),
                border: ThemeBorder(color: ThemeColor(hex: "#FFFCFC")!.withAlpha(0.40), width: 1.15),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.30, radius: 4.20, offsetY: 3.00),
                topHighlight: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.62),
                cornerRadiusOverride: 20.0
            )
        ],
        typography: ThemeTypography(fontFamily: nil, weightRawValue: 0.34, sizeMultiplier: 1.0),
        chrome: ThemeChrome(
            inkColor: ThemeColor(hex: "#221C28")!,
            mutedInkColor: ThemeColor(hex: "#221C28")!.withAlpha(0.55),
            panelFill: ThemeFill(stops: [
                    ThemeColor(hex: "#FCFBFE")!.withAlpha(0.55)
                ]),
            highlightFill: ThemeFill(stops: [
                    ThemeColor(hex: "#000000")!.withAlpha(0.16)
                ])
        ),
        keyArt: KeyArtSet(
            assetPrefix: "keyart_pbd_",
            heightFraction: 0.50,
            bottomInsetFraction: 0.10,
            opacity: 0.90,
            fillKeys: ["space"],
            labelLiftFraction: 0.15
        ),
        effects: .none
    )

    static let pixelPetDreams = MochiKeyboardTheme(
        id: "mochi.pixel-pet-dreams",
        name: "Pixel Pet Dreams",
        authorName: "Mochi",
        appearance: .dark,
        surface: ThemeSurface(
            baseFill: ThemeFill(stops: [
                    ThemeColor(hex: "#514283")!,
                    ThemeColor(hex: "#775799")!,
                    ThemeColor(hex: "#AB669F")!
                ]),
            backgroundImage: ThemeBackgroundImage(
                source: .bundled(name: "themebg_pixel_pet_dreams"),
                scalesToFill: true,
                verticalAnchor: 0.5,
                blurRadius: 0.0
            ),
            scrim: ThemeScrim(
                topColor: ThemeColor(hex: "#4E354F")!.withAlpha(0.18),
                bottomColor: ThemeColor(hex: "#4E354F")!.withAlpha(0.05)
            )
        ),
        keyStyles: [
            .input: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#351731")!,
                    ThemeColor(hex: "#594156")!
                ]),
                labelColor: ThemeColor(hex: "#FFFFFF")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#6F596C")!,
                    ThemeColor(hex: "#7F6C7C")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#FFFFFF")!,
                border: ThemeBorder(color: ThemeColor(hex: "#CCC4CB")!.withAlpha(0.55), width: 1.00),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.26, radius: 1.60, offsetY: 1.60),
                topHighlight: ThemeColor(hex: "#C4BCC3")!.withAlpha(0.34),
                cornerRadiusOverride: 8.0,
                glass: KeyGlass(
                    bevelColor: ThemeColor(hex: "#CCC4CB")!.withAlpha(0.70),
                    bevelWidth: 1.00,
                    bevelFalloff: 0.10,
                    innerShadowColor: ThemeColor(hex: "#0A080F")!,
                    innerShadowOpacity: 0.16,
                    innerShadowRadius: 2.00
                )
            ),
            .system: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#594156")!,
                    ThemeColor(hex: "#6F596C")!
                ]),
                labelColor: ThemeColor(hex: "#FFFFFF")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#7F6C7C")!,
                    ThemeColor(hex: "#8C7B8A")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#FFFFFF")!,
                border: ThemeBorder(color: ThemeColor(hex: "#D3CCD2")!.withAlpha(0.55), width: 1.00),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.26, radius: 1.60, offsetY: 1.60),
                topHighlight: ThemeColor(hex: "#CCC4CB")!.withAlpha(0.34),
                cornerRadiusOverride: 8.0,
                glass: KeyGlass(
                    bevelColor: ThemeColor(hex: "#D3CCD2")!.withAlpha(0.70),
                    bevelWidth: 1.00,
                    bevelFalloff: 0.10,
                    innerShadowColor: ThemeColor(hex: "#0A080F")!,
                    innerShadowOpacity: 0.16,
                    innerShadowRadius: 2.00
                )
            ),
            .action: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#2F1D21")!,
                    ThemeColor(hex: "#544548")!
                ]),
                labelColor: ThemeColor(hex: "#FFFFFF")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#695C60")!,
                    ThemeColor(hex: "#7A6E71")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#FFFFFF")!,
                border: ThemeBorder(color: ThemeColor(hex: "#CAC5C6")!.withAlpha(0.55), width: 1.00),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.26, radius: 1.60, offsetY: 1.60),
                topHighlight: ThemeColor(hex: "#C2BDBE")!.withAlpha(0.34),
                cornerRadiusOverride: 8.0,
                glass: KeyGlass(
                    bevelColor: ThemeColor(hex: "#CAC5C6")!.withAlpha(0.70),
                    bevelWidth: 1.00,
                    bevelFalloff: 0.10,
                    innerShadowColor: ThemeColor(hex: "#0A080F")!,
                    innerShadowOpacity: 0.16,
                    innerShadowRadius: 2.00
                )
            ),
            .space: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#351731")!.withAlpha(0.50),
                    ThemeColor(hex: "#594156")!.withAlpha(0.50)
                ]),
                labelColor: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.00),
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#675064")!.withAlpha(0.50),
                    ThemeColor(hex: "#796576")!.withAlpha(0.50)
                ]),
                border: ThemeBorder(color: ThemeColor(hex: "#C4BCC3")!.withAlpha(0.55), width: 1.00),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.26, radius: 1.60, offsetY: 1.60),
                topHighlight: ThemeColor(hex: "#C4BCC3")!.withAlpha(0.34),
                cornerRadiusOverride: 10.0
            )
        ],
        typography: ThemeTypography(fontFamily: nil, weightRawValue: 0.34, sizeMultiplier: 1.0),
        chrome: ThemeChrome(
            inkColor: ThemeColor(hex: "#F2ECF0")!,
            mutedInkColor: ThemeColor(hex: "#F2ECF0")!.withAlpha(0.55),
            panelFill: ThemeFill(stops: [
                    ThemeColor(hex: "#5E508A")!.withAlpha(0.55)
                ]),
            highlightFill: ThemeFill(stops: [
                    ThemeColor(hex: "#FFFFFF")!.withAlpha(0.16)
                ])
        ),
        keyArt: KeyArtSet(
            assetPrefix: "keyart_ppd_",
            heightFraction: 0.46,
            bottomInsetFraction: 0.09,
            opacity: 0.90,
            fillKeys: ["space"],
            labelLiftFraction: 0.14
        ),
        effects: .none
    )

    static let pocketCityDreams = MochiKeyboardTheme(
        id: "mochi.pocket-city-dreams",
        name: "Pocket City Dreams",
        authorName: "Mochi",
        appearance: .dark,
        surface: ThemeSurface(
            baseFill: ThemeFill(stops: [
                    ThemeColor(hex: "#775377")!,
                    ThemeColor(hex: "#BD7277")!,
                    ThemeColor(hex: "#E89271")!
                ]),
            backgroundImage: ThemeBackgroundImage(
                source: .bundled(name: "themebg_pocket_city_dreams"),
                scalesToFill: true,
                verticalAnchor: 0.5,
                blurRadius: 0.0
            ),
            scrim: ThemeScrim(
                topColor: ThemeColor(hex: "#79504E")!.withAlpha(0.18),
                bottomColor: ThemeColor(hex: "#79504E")!.withAlpha(0.05)
            )
        ),
        keyStyles: [
            .input: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#3A191E")!,
                    ThemeColor(hex: "#5D4246")!
                ]),
                labelColor: ThemeColor(hex: "#FFFFFF")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#725A5D")!,
                    ThemeColor(hex: "#826C6F")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#FFFFFF")!,
                border: ThemeBorder(color: ThemeColor(hex: "#3E1D22")!.withAlpha(0.32), width: 1.35),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.22, radius: 3.60, offsetY: 2.60),
                topHighlight: nil,
                cornerRadiusOverride: 9.0
            ),
            .system: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#5D4246")!,
                    ThemeColor(hex: "#725A5D")!
                ]),
                labelColor: ThemeColor(hex: "#FFFFFF")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#826C6F")!,
                    ThemeColor(hex: "#8F7C7E")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#FFFFFF")!,
                border: ThemeBorder(color: ThemeColor(hex: "#3E2C2E")!.withAlpha(0.32), width: 1.35),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.22, radius: 3.60, offsetY: 2.60),
                topHighlight: nil,
                cornerRadiusOverride: 9.0
            ),
            .action: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#321E18")!,
                    ThemeColor(hex: "#564641")!
                ]),
                labelColor: ThemeColor(hex: "#FFFFFF")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#6B5D59")!,
                    ThemeColor(hex: "#7B6F6B")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#FFFFFF")!,
                border: ThemeBorder(color: ThemeColor(hex: "#35221C")!.withAlpha(0.32), width: 1.35),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.22, radius: 3.60, offsetY: 2.60),
                topHighlight: nil,
                cornerRadiusOverride: 9.0
            ),
            .space: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#3A191E")!.withAlpha(0.50),
                    ThemeColor(hex: "#5D4246")!.withAlpha(0.50)
                ]),
                labelColor: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.00),
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#6A5155")!.withAlpha(0.50),
                    ThemeColor(hex: "#7C6669")!.withAlpha(0.50)
                ]),
                border: ThemeBorder(color: ThemeColor(hex: "#C6BCBD")!.withAlpha(0.32), width: 1.35),
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
                    ThemeColor(hex: "#704E6E")!.withAlpha(0.55)
                ]),
            highlightFill: ThemeFill(stops: [
                    ThemeColor(hex: "#FFFFFF")!.withAlpha(0.16)
                ])
        ),
        keyArt: KeyArtSet(
            assetPrefix: "keyart_pcd_",
            heightFraction: 0.52,
            bottomInsetFraction: 0.10,
            opacity: 0.90,
            fillKeys: ["space"],
            labelLiftFraction: 0.15
        ),
        effects: .none
    )

    static let pocketCosmos = MochiKeyboardTheme(
        id: "mochi.pocket-cosmos",
        name: "Pocket Cosmos",
        authorName: "Mochi",
        appearance: .dark,
        surface: ThemeSurface(
            baseFill: ThemeFill(stops: [
                    ThemeColor(hex: "#604F8C")!,
                    ThemeColor(hex: "#6F66A0")!,
                    ThemeColor(hex: "#E1A9AD")!
                ]),
            backgroundImage: ThemeBackgroundImage(
                source: .bundled(name: "themebg_pocket_cosmos"),
                scalesToFill: true,
                verticalAnchor: 0.5,
                blurRadius: 0.0
            ),
            scrim: ThemeScrim(
                topColor: ThemeColor(hex: "#66536F")!.withAlpha(0.17),
                bottomColor: ThemeColor(hex: "#66536F")!.withAlpha(0.06)
            )
        ),
        keyStyles: [
            .input: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#221D43")!,
                    ThemeColor(hex: "#413C5D")!
                ]),
                labelColor: ThemeColor(hex: "#FFFFFF")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#615C78")!,
                    ThemeColor(hex: "#6D6983")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#FFFFFF")!,
                border: ThemeBorder(color: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.80), width: 1.70),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.00, radius: 0.00, offsetY: 0.00),
                topHighlight: nil,
                cornerRadiusOverride: 6.0
            ),
            .system: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#4A4565")!,
                    ThemeColor(hex: "#5B5673")!
                ]),
                labelColor: ThemeColor(hex: "#FFFFFF")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#726F87")!,
                    ThemeColor(hex: "#7D7990")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#FFFFFF")!,
                border: ThemeBorder(color: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.80), width: 1.70),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.00, radius: 0.00, offsetY: 0.00),
                topHighlight: nil,
                cornerRadiusOverride: 6.0
            ),
            .action: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#292024")!,
                    ThemeColor(hex: "#463E42")!
                ]),
                labelColor: ThemeColor(hex: "#FFFFFF")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#655E61")!,
                    ThemeColor(hex: "#716B6E")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#FFFFFF")!,
                border: ThemeBorder(color: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.80), width: 1.70),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.00, radius: 0.00, offsetY: 0.00),
                topHighlight: nil,
                cornerRadiusOverride: 6.0
            ),
            .space: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#221D43")!.withAlpha(0.50),
                    ThemeColor(hex: "#413C5D")!.withAlpha(0.50)
                ]),
                labelColor: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.00),
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#585471")!.withAlpha(0.50),
                    ThemeColor(hex: "#66627D")!.withAlpha(0.50)
                ]),
                border: ThemeBorder(color: ThemeColor(hex: "#BFBDC8")!.withAlpha(0.80), width: 1.70),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.00, radius: 0.00, offsetY: 0.00),
                topHighlight: nil,
                cornerRadiusOverride: 8.0
            )
        ],
        typography: ThemeTypography(fontFamily: nil, weightRawValue: 0.34, sizeMultiplier: 1.0),
        chrome: ThemeChrome(
            inkColor: ThemeColor(hex: "#F8F5F7")!,
            mutedInkColor: ThemeColor(hex: "#F8F5F7")!.withAlpha(0.55),
            panelFill: ThemeFill(stops: [
                    ThemeColor(hex: "#604F8A")!.withAlpha(0.55)
                ]),
            highlightFill: ThemeFill(stops: [
                    ThemeColor(hex: "#FFFFFF")!.withAlpha(0.16)
                ])
        ),
        keyArt: KeyArtSet(
            assetPrefix: "keyart_pcm_",
            heightFraction: 0.40,
            bottomInsetFraction: 0.09,
            opacity: 0.90,
            fillKeys: ["space"],
            labelLiftFraction: 0.13
        ),
        effects: .none
    )

    static let prismaticJellyDreams = MochiKeyboardTheme(
        id: "mochi.prismatic-jelly-dreams",
        name: "Prismatic Jelly Dreams",
        authorName: "Mochi",
        appearance: .light,
        surface: ThemeSurface(
            baseFill: ThemeFill(stops: [
                    ThemeColor(hex: "#7367A7")!,
                    ThemeColor(hex: "#B98FBF")!,
                    ThemeColor(hex: "#AA7A86")!
                ]),
            backgroundImage: ThemeBackgroundImage(
                source: .bundled(name: "themebg_prismatic_jelly_dreams"),
                scalesToFill: true,
                verticalAnchor: 0.5,
                blurRadius: 0.0
            ),
            scrim: ThemeScrim(
                topColor: ThemeColor(hex: "#705763")!.withAlpha(0.18),
                bottomColor: ThemeColor(hex: "#705763")!.withAlpha(0.05)
            )
        ),
        keyStyles: [
            .input: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#FFF1EB")!,
                    ThemeColor(hex: "#F7EAE4")!
                ]),
                labelColor: ThemeColor(hex: "#221C28")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#F3E6E0")!,
                    ThemeColor(hex: "#EBDED9")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#221C28")!,
                border: ThemeBorder(color: ThemeColor(hex: "#B3A9A4")!.withAlpha(0.40), width: 1.15),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.30, radius: 4.20, offsetY: 3.00),
                topHighlight: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.62),
                cornerRadiusOverride: 19.0,
                glass: KeyGlass(
                    bevelColor: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.00),
                    bevelWidth: 0.00,
                    bevelFalloff: 0.50,
                    innerShadowColor: ThemeColor(hex: "#FFFFFF")!,
                    innerShadowOpacity: 0.34,
                    innerShadowRadius: 3.20
                )
            ),
            .system: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#F7EAE4")!,
                    ThemeColor(hex: "#EFE2DC")!
                ]),
                labelColor: ThemeColor(hex: "#221C28")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#EBDED9")!,
                    ThemeColor(hex: "#E3D6D1")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#221C28")!,
                border: ThemeBorder(color: ThemeColor(hex: "#ADA49F")!.withAlpha(0.40), width: 1.15),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.30, radius: 4.20, offsetY: 3.00),
                topHighlight: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.62),
                cornerRadiusOverride: 19.0,
                glass: KeyGlass(
                    bevelColor: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.00),
                    bevelWidth: 0.00,
                    bevelFalloff: 0.50,
                    innerShadowColor: ThemeColor(hex: "#FFFFFF")!,
                    innerShadowOpacity: 0.34,
                    innerShadowRadius: 3.20
                )
            ),
            .action: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#FDF1EC")!,
                    ThemeColor(hex: "#F6EAE5")!
                ]),
                labelColor: ThemeColor(hex: "#221C28")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#F2E6E1")!,
                    ThemeColor(hex: "#EADFDA")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#221C28")!,
                border: ThemeBorder(color: ThemeColor(hex: "#B1A9A5")!.withAlpha(0.40), width: 1.15),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.30, radius: 4.20, offsetY: 3.00),
                topHighlight: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.62),
                cornerRadiusOverride: 19.0,
                glass: KeyGlass(
                    bevelColor: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.00),
                    bevelWidth: 0.00,
                    bevelFalloff: 0.50,
                    innerShadowColor: ThemeColor(hex: "#FFFFFF")!,
                    innerShadowOpacity: 0.34,
                    innerShadowRadius: 3.20
                )
            ),
            .space: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#FFF1EB")!.withAlpha(0.42),
                    ThemeColor(hex: "#F7EAE4")!.withAlpha(0.42)
                ]),
                labelColor: ThemeColor(hex: "#221C28")!.withAlpha(0.00),
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#F5E7E1")!.withAlpha(0.42),
                    ThemeColor(hex: "#EDDFDA")!.withAlpha(0.42)
                ]),
                border: ThemeBorder(color: ThemeColor(hex: "#FFFCFB")!.withAlpha(0.40), width: 1.15),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.30, radius: 4.20, offsetY: 3.00),
                topHighlight: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.62),
                cornerRadiusOverride: 20.0
            )
        ],
        typography: ThemeTypography(fontFamily: nil, weightRawValue: 0.34, sizeMultiplier: 1.0),
        chrome: ThemeChrome(
            inkColor: ThemeColor(hex: "#FCFAFF")!,
            mutedInkColor: ThemeColor(hex: "#FCFAFF")!.withAlpha(0.55),
            panelFill: ThemeFill(stops: [
                    ThemeColor(hex: "#5C5284")!.withAlpha(0.55)
                ]),
            highlightFill: ThemeFill(stops: [
                    ThemeColor(hex: "#FFFFFF")!.withAlpha(0.16)
                ])
        ),
        keyArt: KeyArtSet(
            assetPrefix: "keyart_pjd_",
            heightFraction: 0.50,
            bottomInsetFraction: 0.10,
            opacity: 0.90,
            fillKeys: ["space"],
            labelLiftFraction: 0.15
        ),
        effects: ThemeEffects(
            isEnabled: true,
            birthRate: 6.0,
            particleImageName: nil,
            tint: ThemeColor(hex: "#B9F3FF")!
        )
    )

    static let puzzlewoodAdventures = MochiKeyboardTheme(
        id: "mochi.puzzlewood-adventures",
        name: "Puzzlewood Adventures",
        authorName: "Mochi",
        appearance: .dark,
        surface: ThemeSurface(
            baseFill: ThemeFill(stops: [
                    ThemeColor(hex: "#7E746D")!,
                    ThemeColor(hex: "#363462")!,
                    ThemeColor(hex: "#8E739E")!
                ]),
            backgroundImage: ThemeBackgroundImage(
                source: .bundled(name: "themebg_puzzlewood_adventures"),
                scalesToFill: true,
                verticalAnchor: 0.5,
                blurRadius: 0.0
            ),
            scrim: ThemeScrim(
                topColor: ThemeColor(hex: "#46384D")!.withAlpha(0.22),
                bottomColor: ThemeColor(hex: "#46384D")!.withAlpha(0.07)
            )
        ),
        keyStyles: [
            .input: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#171433")!,
                    ThemeColor(hex: "#34314C")!
                ]),
                labelColor: ThemeColor(hex: "#FFFFFF")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#5D5B71")!,
                    ThemeColor(hex: "#676479")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#FFFFFF")!,
                border: ThemeBorder(color: ThemeColor(hex: "#C5C4CC")!.withAlpha(0.60), width: 1.00),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.32, radius: 2.60, offsetY: 1.60),
                topHighlight: ThemeColor(hex: "#BDBCC5")!.withAlpha(0.28),
                cornerRadiusOverride: 12.0,
                glass: KeyGlass(
                    bevelColor: ThemeColor(hex: "#C5C4CC")!.withAlpha(0.62),
                    bevelWidth: 1.00,
                    bevelFalloff: 0.12,
                    innerShadowColor: ThemeColor(hex: "#0A080F")!,
                    innerShadowOpacity: 0.36,
                    innerShadowRadius: 3.00
                )
            ),
            .system: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#45425B")!,
                    ThemeColor(hex: "#524F67")!
                ]),
                labelColor: ThemeColor(hex: "#FFFFFF")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#6F6D81")!,
                    ThemeColor(hex: "#777588")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#FFFFFF")!,
                border: ThemeBorder(color: ThemeColor(hex: "#CDCCD3")!.withAlpha(0.60), width: 1.00),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.32, radius: 2.60, offsetY: 1.60),
                topHighlight: ThemeColor(hex: "#C5C4CC")!.withAlpha(0.28),
                cornerRadiusOverride: 12.0,
                glass: KeyGlass(
                    bevelColor: ThemeColor(hex: "#CDCCD3")!.withAlpha(0.62),
                    bevelWidth: 1.00,
                    bevelFalloff: 0.12,
                    innerShadowColor: ThemeColor(hex: "#0A080F")!,
                    innerShadowOpacity: 0.36,
                    innerShadowRadius: 3.00
                )
            ),
            .action: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#1E1617")!,
                    ThemeColor(hex: "#393233")!
                ]),
                labelColor: ThemeColor(hex: "#FFFFFF")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#615C5C")!,
                    ThemeColor(hex: "#6A6566")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#FFFFFF")!,
                border: ThemeBorder(color: ThemeColor(hex: "#C7C5C5")!.withAlpha(0.60), width: 1.00),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.32, radius: 2.60, offsetY: 1.60),
                topHighlight: ThemeColor(hex: "#BFBDBD")!.withAlpha(0.28),
                cornerRadiusOverride: 12.0,
                glass: KeyGlass(
                    bevelColor: ThemeColor(hex: "#C7C5C5")!.withAlpha(0.62),
                    bevelWidth: 1.00,
                    bevelFalloff: 0.12,
                    innerShadowColor: ThemeColor(hex: "#0A080F")!,
                    innerShadowOpacity: 0.36,
                    innerShadowRadius: 3.00
                )
            ),
            .space: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#171433")!.withAlpha(0.50),
                    ThemeColor(hex: "#34314C")!.withAlpha(0.50)
                ]),
                labelColor: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.00),
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#545269")!.withAlpha(0.50),
                    ThemeColor(hex: "#5F5D72")!.withAlpha(0.50)
                ]),
                border: ThemeBorder(color: ThemeColor(hex: "#BDBCC5")!.withAlpha(0.60), width: 1.00),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.32, radius: 2.60, offsetY: 1.60),
                topHighlight: ThemeColor(hex: "#BDBCC5")!.withAlpha(0.28),
                cornerRadiusOverride: 14.0
            )
        ],
        typography: ThemeTypography(fontFamily: nil, weightRawValue: 0.34, sizeMultiplier: 1.0),
        chrome: ThemeChrome(
            inkColor: ThemeColor(hex: "#F2ECF0")!,
            mutedInkColor: ThemeColor(hex: "#F2ECF0")!.withAlpha(0.55),
            panelFill: ThemeFill(stops: [
                    ThemeColor(hex: "#58557A")!.withAlpha(0.55)
                ]),
            highlightFill: ThemeFill(stops: [
                    ThemeColor(hex: "#FFFFFF")!.withAlpha(0.16)
                ])
        ),
        keyArt: KeyArtSet(
            assetPrefix: "keyart_pwa_",
            heightFraction: 0.44,
            bottomInsetFraction: 0.09,
            opacity: 0.90,
            fillKeys: ["space"],
            labelLiftFraction: 0.14
        ),
        effects: ThemeEffects(
            isEnabled: true,
            birthRate: 5.0,
            particleImageName: nil,
            tint: ThemeColor(hex: "#FFD98A")!
        )
    )

    static let reflectiveDreamworld = MochiKeyboardTheme(
        id: "mochi.reflective-dreamworld",
        name: "Reflective Dreamworld",
        authorName: "Mochi",
        appearance: .light,
        surface: ThemeSurface(
            baseFill: ThemeFill(stops: [
                    ThemeColor(hex: "#695088")!,
                    ThemeColor(hex: "#7F67A3")!,
                    ThemeColor(hex: "#BE94BD")!
                ]),
            backgroundImage: ThemeBackgroundImage(
                source: .bundled(name: "themebg_reflective_dreamworld"),
                scalesToFill: true,
                verticalAnchor: 0.5,
                blurRadius: 0.0
            ),
            scrim: ThemeScrim(
                topColor: ThemeColor(hex: "#4E3E5B")!.withAlpha(0.18),
                bottomColor: ThemeColor(hex: "#4E3E5B")!.withAlpha(0.05)
            )
        ),
        keyStyles: [
            .input: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#FBF1F5")!,
                    ThemeColor(hex: "#EEE4EE")!
                ]),
                labelColor: ThemeColor(hex: "#221C28")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#EFE6EA")!,
                    ThemeColor(hex: "#E2D9E1")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#221C28")!,
                border: ThemeBorder(color: ThemeColor(hex: "#FEFCFD")!.withAlpha(0.42), width: 0.95),
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
                    ThemeColor(hex: "#F3EAF0")!,
                    ThemeColor(hex: "#E6DDE3")!
                ]),
                labelColor: ThemeColor(hex: "#221C28")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#E7DEE4")!,
                    ThemeColor(hex: "#D9D1D6")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#221C28")!,
                border: ThemeBorder(color: ThemeColor(hex: "#FEFCFD")!.withAlpha(0.42), width: 0.95),
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
                    ThemeColor(hex: "#F9F2F6")!,
                    ThemeColor(hex: "#ECE5EA")!
                ]),
                labelColor: ThemeColor(hex: "#221C28")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#EDE7EB")!,
                    ThemeColor(hex: "#E0DADE")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#221C28")!,
                border: ThemeBorder(color: ThemeColor(hex: "#FEFCFD")!.withAlpha(0.42), width: 0.95),
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
                    ThemeColor(hex: "#FBF1F5")!.withAlpha(0.42),
                    ThemeColor(hex: "#EEE4EE")!.withAlpha(0.42)
                ]),
                labelColor: ThemeColor(hex: "#221C28")!.withAlpha(0.00),
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#F1E7EC")!.withAlpha(0.42),
                    ThemeColor(hex: "#E3DAE3")!.withAlpha(0.42)
                ]),
                border: ThemeBorder(color: ThemeColor(hex: "#FEFCFD")!.withAlpha(0.42), width: 0.95),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.15, radius: 2.20, offsetY: 1.30),
                topHighlight: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.46),
                cornerRadiusOverride: 16.0
            )
        ],
        typography: ThemeTypography(fontFamily: nil, weightRawValue: 0.34, sizeMultiplier: 1.0),
        chrome: ThemeChrome(
            inkColor: ThemeColor(hex: "#FAF8F9")!,
            mutedInkColor: ThemeColor(hex: "#FAF8F9")!.withAlpha(0.55),
            panelFill: ThemeFill(stops: [
                    ThemeColor(hex: "#664E84")!.withAlpha(0.55)
                ]),
            highlightFill: ThemeFill(stops: [
                    ThemeColor(hex: "#FFFFFF")!.withAlpha(0.16)
                ])
        ),
        keyArt: KeyArtSet(
            assetPrefix: "keyart_rfd_",
            heightFraction: 0.48,
            bottomInsetFraction: 0.09,
            opacity: 0.90,
            fillKeys: ["space"],
            labelLiftFraction: 0.14
        ),
        effects: ThemeEffects(
            isEnabled: true,
            birthRate: 6.0,
            particleImageName: nil,
            tint: ThemeColor(hex: "#D9C4FF")!
        )
    )

    static let ruinsAndRelics = MochiKeyboardTheme(
        id: "mochi.ruins-and-relics",
        name: "Ruins & Relics",
        authorName: "Mochi",
        appearance: .dark,
        surface: ThemeSurface(
            baseFill: ThemeFill(stops: [
                    ThemeColor(hex: "#D78E65")!,
                    ThemeColor(hex: "#AE7A48")!,
                    ThemeColor(hex: "#FFCC80")!
                ]),
            backgroundImage: ThemeBackgroundImage(
                source: .bundled(name: "themebg_ruins_and_relics"),
                scalesToFill: true,
                verticalAnchor: 0.5,
                blurRadius: 0.0
            ),
            scrim: ThemeScrim(
                topColor: ThemeColor(hex: "#95693D")!.withAlpha(0.16),
                bottomColor: ThemeColor(hex: "#95693D")!.withAlpha(0.05)
            )
        ),
        keyStyles: [
            .input: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#482106")!,
                    ThemeColor(hex: "#603E26")!
                ]),
                labelColor: ThemeColor(hex: "#FFFFFF")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#7A5D49")!,
                    ThemeColor(hex: "#846A58")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#FFFFFF")!,
                border: ThemeBorder(color: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.80), width: 1.70),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.00, radius: 0.00, offsetY: 0.00),
                topHighlight: nil,
                cornerRadiusOverride: 6.0
            ),
            .system: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#674630")!,
                    ThemeColor(hex: "#755742")!
                ]),
                labelColor: ThemeColor(hex: "#FFFFFF")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#896F5E")!,
                    ThemeColor(hex: "#917A6A")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#FFFFFF")!,
                border: ThemeBorder(color: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.80), width: 1.70),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.00, radius: 0.00, offsetY: 0.00),
                topHighlight: nil,
                cornerRadiusOverride: 6.0
            ),
            .action: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#3B2815")!,
                    ThemeColor(hex: "#534232")!
                ]),
                labelColor: ThemeColor(hex: "#FFFFFF")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#6F6153")!,
                    ThemeColor(hex: "#7A6D60")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#FFFFFF")!,
                border: ThemeBorder(color: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.80), width: 1.70),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.00, radius: 0.00, offsetY: 0.00),
                topHighlight: nil,
                cornerRadiusOverride: 6.0
            ),
            .space: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#482106")!.withAlpha(0.50),
                    ThemeColor(hex: "#603E26")!.withAlpha(0.50)
                ]),
                labelColor: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.00),
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#735540")!.withAlpha(0.50),
                    ThemeColor(hex: "#7F6350")!.withAlpha(0.50)
                ]),
                border: ThemeBorder(color: ThemeColor(hex: "#C9BEB6")!.withAlpha(0.80), width: 1.70),
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
                    ThemeColor(hex: "#FDFBFA")!.withAlpha(0.55)
                ]),
            highlightFill: ThemeFill(stops: [
                    ThemeColor(hex: "#000000")!.withAlpha(0.16)
                ])
        ),
        keyArt: KeyArtSet(
            assetPrefix: "keyart_rnr_",
            heightFraction: 0.40,
            bottomInsetFraction: 0.09,
            opacity: 0.90,
            fillKeys: ["space"],
            labelLiftFraction: 0.13
        ),
        effects: .none
    )
}
