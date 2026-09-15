import Foundation

// Batch 6 -- 25 additional built-in themes, ingested from ~/Downloads/Theses10. Same asset
// pipeline as batch 3/4 (background plate + per-key illustrations), authored on the 7-material
// system. Cap luminance is solved by bisecting real contrast against the plate's own post-scrim
// 5th/95th-percentile luminance (see `derive_cap` in scratchpad/gen_b56.py) rather than a fixed
// offset, so caps in this batch separate from their backdrop instead of matching it.

extension BuiltInThemes {

    static let batch6: [MochiKeyboardTheme] = [
        abyssalNeonHaven, adventureAwaits, alienMoonlift, bloomingGardenia, clockworkHorizon, cosmicLittleVisitors, cosmicObservatory, cozyYarnHaven, dragonlightValley, fireworkDreamFestival, forgottenRuins, frostedCrystalCavern, jurassicSunsetPark, kiteboundSunset, meadowMorning, moonlitPotionLab, mysteryAtDusk, neonCodeHaven, neuralDreamscape, oceanicDreamscape, sakuraSerenity, skywardExplorer, skywardReverie, starlitOrbit, wanderlightLoft
    ]

    static let abyssalNeonHaven = MochiKeyboardTheme(
        id: "mochi.abyssal-neon-haven",
        name: "Abyssal Neon Haven",
        authorName: "Mochi",
        appearance: .dark,
        surface: ThemeSurface(
            baseFill: ThemeFill(stops: [
                    ThemeColor(hex: "#488CA1")!,
                    ThemeColor(hex: "#629EA5")!,
                    ThemeColor(hex: "#FBDBA4")!
                ]),
            backgroundImage: ThemeBackgroundImage(
                source: .bundled(name: "themebg_abyssal_neon_haven"),
                scalesToFill: true,
                verticalAnchor: 0.5,
                blurRadius: 0.0
            ),
            scrim: ThemeScrim(
                topColor: ThemeColor(hex: "#617874")!.withAlpha(0.22),
                bottomColor: ThemeColor(hex: "#617874")!.withAlpha(0.07)
            )
        ),
        keyStyles: [
            .input: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#342816")!,
                    ThemeColor(hex: "#483C2D")!
                ]),
                labelColor: ThemeColor(hex: "#FFFFFF")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#6A6154")!,
                    ThemeColor(hex: "#736A5E")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#FFFFFF")!,
                border: ThemeBorder(color: ThemeColor(hex: "#CAC7C2")!.withAlpha(0.60), width: 1.00),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.32, radius: 2.60, offsetY: 1.60),
                topHighlight: ThemeColor(hex: "#C3BFBA")!.withAlpha(0.28),
                cornerRadiusOverride: 12.0,
                glass: KeyGlass(
                    bevelColor: ThemeColor(hex: "#CAC7C2")!.withAlpha(0.62),
                    bevelWidth: 1.00,
                    bevelFalloff: 0.12,
                    innerShadowColor: ThemeColor(hex: "#0A080F")!,
                    innerShadowOpacity: 0.36,
                    innerShadowRadius: 3.00
                )
            ),
            .system: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#554B3C")!,
                    ThemeColor(hex: "#615749")!
                ]),
                labelColor: ThemeColor(hex: "#FFFFFF")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#7B7267")!,
                    ThemeColor(hex: "#827A6F")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#FFFFFF")!,
                border: ThemeBorder(color: ThemeColor(hex: "#D1CFCB")!.withAlpha(0.60), width: 1.00),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.32, radius: 2.60, offsetY: 1.60),
                topHighlight: ThemeColor(hex: "#CAC7C2")!.withAlpha(0.28),
                cornerRadiusOverride: 12.0,
                glass: KeyGlass(
                    bevelColor: ThemeColor(hex: "#D1CFCB")!.withAlpha(0.62),
                    bevelWidth: 1.00,
                    bevelFalloff: 0.12,
                    innerShadowColor: ThemeColor(hex: "#0A080F")!,
                    innerShadowOpacity: 0.36,
                    innerShadowRadius: 3.00
                )
            ),
            .action: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#2E2A21")!,
                    ThemeColor(hex: "#413E35")!
                ]),
                labelColor: ThemeColor(hex: "#FFFFFF")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#65625C")!,
                    ThemeColor(hex: "#6E6B65")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#FFFFFF")!,
                border: ThemeBorder(color: ThemeColor(hex: "#C8C7C5")!.withAlpha(0.60), width: 1.00),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.32, radius: 2.60, offsetY: 1.60),
                topHighlight: ThemeColor(hex: "#C0BFBD")!.withAlpha(0.28),
                cornerRadiusOverride: 12.0,
                glass: KeyGlass(
                    bevelColor: ThemeColor(hex: "#C8C7C5")!.withAlpha(0.62),
                    bevelWidth: 1.00,
                    bevelFalloff: 0.12,
                    innerShadowColor: ThemeColor(hex: "#0A080F")!,
                    innerShadowOpacity: 0.36,
                    innerShadowRadius: 3.00
                )
            ),
            .space: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#342816")!.withAlpha(0.50),
                    ThemeColor(hex: "#483C2D")!.withAlpha(0.50)
                ]),
                labelColor: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.00),
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#63594C")!.withAlpha(0.50),
                    ThemeColor(hex: "#6C6356")!.withAlpha(0.50)
                ]),
                border: ThemeBorder(color: ThemeColor(hex: "#C3BFBA")!.withAlpha(0.60), width: 1.00),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.32, radius: 2.60, offsetY: 1.60),
                topHighlight: ThemeColor(hex: "#C3BFBA")!.withAlpha(0.28),
                cornerRadiusOverride: 14.0
            )
        ],
        typography: ThemeTypography(fontFamily: nil, weightRawValue: 0.34, sizeMultiplier: 1.0),
        chrome: ThemeChrome(
            inkColor: ThemeColor(hex: "#08050D")!,
            mutedInkColor: ThemeColor(hex: "#08050D")!.withAlpha(0.55),
            panelFill: ThemeFill(stops: [
                    ThemeColor(hex: "#FAFCFC")!.withAlpha(0.55)
                ]),
            highlightFill: ThemeFill(stops: [
                    ThemeColor(hex: "#000000")!.withAlpha(0.16)
                ])
        ),
        keyArt: KeyArtSet(
            assetPrefix: "keyart_anh_",
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
            tint: ThemeColor(hex: "#37E3C9")!
        )
    )

    static let adventureAwaits = MochiKeyboardTheme(
        id: "mochi.adventure-awaits",
        name: "Adventure Awaits",
        authorName: "Mochi",
        appearance: .dark,
        surface: ThemeSurface(
            baseFill: ThemeFill(stops: [
                    ThemeColor(hex: "#98B9CB")!,
                    ThemeColor(hex: "#C1C396")!,
                    ThemeColor(hex: "#ECB069")!
                ]),
            backgroundImage: ThemeBackgroundImage(
                source: .bundled(name: "themebg_adventure_awaits"),
                scalesToFill: true,
                verticalAnchor: 0.5,
                blurRadius: 0.0
            ),
            scrim: ThemeScrim(
                topColor: ThemeColor(hex: "#999471")!.withAlpha(0.16),
                bottomColor: ThemeColor(hex: "#999471")!.withAlpha(0.05)
            )
        ),
        keyStyles: [
            .input: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#392910")!,
                    ThemeColor(hex: "#52432D")!
                ]),
                labelColor: ThemeColor(hex: "#FFFFFF")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#6E624F")!,
                    ThemeColor(hex: "#796E5D")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#FFFFFF")!,
                border: ThemeBorder(color: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.80), width: 1.70),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.00, radius: 0.00, offsetY: 0.00),
                topHighlight: nil,
                cornerRadiusOverride: 6.0
            ),
            .system: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#594B36")!,
                    ThemeColor(hex: "#685C48")!
                ]),
                labelColor: ThemeColor(hex: "#FFFFFF")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#7E7362")!,
                    ThemeColor(hex: "#877D6E")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#FFFFFF")!,
                border: ThemeBorder(color: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.80), width: 1.70),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.00, radius: 0.00, offsetY: 0.00),
                topHighlight: nil,
                cornerRadiusOverride: 6.0
            ),
            .action: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#312B1F")!,
                    ThemeColor(hex: "#4A453A")!
                ]),
                labelColor: ThemeColor(hex: "#FFFFFF")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#67635A")!,
                    ThemeColor(hex: "#736F67")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#FFFFFF")!,
                border: ThemeBorder(color: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.80), width: 1.70),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.00, radius: 0.00, offsetY: 0.00),
                topHighlight: nil,
                cornerRadiusOverride: 6.0
            ),
            .space: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#392910")!.withAlpha(0.50),
                    ThemeColor(hex: "#52432D")!.withAlpha(0.50)
                ]),
                labelColor: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.00),
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#665946")!.withAlpha(0.50),
                    ThemeColor(hex: "#736755")!.withAlpha(0.50)
                ]),
                border: ThemeBorder(color: ThemeColor(hex: "#C4BFB8")!.withAlpha(0.80), width: 1.70),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.00, radius: 0.00, offsetY: 0.00),
                topHighlight: nil,
                cornerRadiusOverride: 8.0
            )
        ],
        typography: ThemeTypography(fontFamily: nil, weightRawValue: 0.34, sizeMultiplier: 1.0),
        chrome: ThemeChrome(
            inkColor: ThemeColor(hex: "#221C28")!,
            mutedInkColor: ThemeColor(hex: "#221C28")!.withAlpha(0.55),
            panelFill: ThemeFill(stops: [
                    ThemeColor(hex: "#FAFCFD")!.withAlpha(0.55)
                ]),
            highlightFill: ThemeFill(stops: [
                    ThemeColor(hex: "#000000")!.withAlpha(0.16)
                ])
        ),
        keyArt: KeyArtSet(
            assetPrefix: "keyart_adv_",
            heightFraction: 0.40,
            bottomInsetFraction: 0.09,
            opacity: 0.90,
            fillKeys: ["space"],
            labelLiftFraction: 0.13
        ),
        effects: .none
    )

    static let alienMoonlift = MochiKeyboardTheme(
        id: "mochi.alien-moonlift",
        name: "Alien Moonlift",
        authorName: "Mochi",
        appearance: .light,
        surface: ThemeSurface(
            baseFill: ThemeFill(stops: [
                    ThemeColor(hex: "#142537")!,
                    ThemeColor(hex: "#1B3044")!,
                    ThemeColor(hex: "#282D35")!
                ]),
            backgroundImage: ThemeBackgroundImage(
                source: .bundled(name: "themebg_alien_moonlift"),
                scalesToFill: true,
                verticalAnchor: 0.5,
                blurRadius: 0.0
            ),
            scrim: ThemeScrim(
                topColor: ThemeColor(hex: "#1F282F")!.withAlpha(0.18),
                bottomColor: ThemeColor(hex: "#1F282F")!.withAlpha(0.05)
            )
        ),
        keyStyles: [
            .input: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#F1BB87")!,
                    ThemeColor(hex: "#E8B381")!
                ]),
                labelColor: ThemeColor(hex: "#17131B")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#DFAD7D")!,
                    ThemeColor(hex: "#D4A476")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#17131B")!,
                border: ThemeBorder(color: ThemeColor(hex: "#FDF3EA")!.withAlpha(0.55), width: 1.00),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.26, radius: 1.60, offsetY: 1.60),
                topHighlight: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.34),
                cornerRadiusOverride: 8.0,
                glass: KeyGlass(
                    bevelColor: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.70),
                    bevelWidth: 1.00,
                    bevelFalloff: 0.10,
                    innerShadowColor: ThemeColor(hex: "#0A080F")!,
                    innerShadowOpacity: 0.16,
                    innerShadowRadius: 2.00
                )
            ),
            .system: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#E6B280")!,
                    ThemeColor(hex: "#DBAA7A")!
                ]),
                labelColor: ThemeColor(hex: "#17131B")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#D2A375")!,
                    ThemeColor(hex: "#C6996F")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#17131B")!,
                border: ThemeBorder(color: ThemeColor(hex: "#F9ECDF")!.withAlpha(0.55), width: 1.00),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.26, radius: 1.60, offsetY: 1.60),
                topHighlight: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.34),
                cornerRadiusOverride: 8.0,
                glass: KeyGlass(
                    bevelColor: ThemeColor(hex: "#FDF9F5")!.withAlpha(0.70),
                    bevelWidth: 1.00,
                    bevelFalloff: 0.10,
                    innerShadowColor: ThemeColor(hex: "#0A080F")!,
                    innerShadowOpacity: 0.16,
                    innerShadowRadius: 2.00
                )
            ),
            .action: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#E7BE97")!,
                    ThemeColor(hex: "#DEB691")!
                ]),
                labelColor: ThemeColor(hex: "#17131B")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#D6B08B")!,
                    ThemeColor(hex: "#CBA784")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#17131B")!,
                border: ThemeBorder(color: ThemeColor(hex: "#FBF4ED")!.withAlpha(0.55), width: 1.00),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.26, radius: 1.60, offsetY: 1.60),
                topHighlight: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.34),
                cornerRadiusOverride: 8.0,
                glass: KeyGlass(
                    bevelColor: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.70),
                    bevelWidth: 1.00,
                    bevelFalloff: 0.10,
                    innerShadowColor: ThemeColor(hex: "#0A080F")!,
                    innerShadowOpacity: 0.16,
                    innerShadowRadius: 2.00
                )
            ),
            .space: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#F1BB87")!.withAlpha(0.42),
                    ThemeColor(hex: "#E8B381")!.withAlpha(0.42)
                ]),
                labelColor: ThemeColor(hex: "#17131B")!.withAlpha(0.00),
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#E1AF7E")!.withAlpha(0.42),
                    ThemeColor(hex: "#D7A678")!.withAlpha(0.42)
                ]),
                border: ThemeBorder(color: ThemeColor(hex: "#FDF3EA")!.withAlpha(0.55), width: 1.00),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.26, radius: 1.60, offsetY: 1.60),
                topHighlight: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.34),
                cornerRadiusOverride: 10.0
            )
        ],
        typography: ThemeTypography(fontFamily: nil, weightRawValue: 0.34, sizeMultiplier: 1.0),
        chrome: ThemeChrome(
            inkColor: ThemeColor(hex: "#F2ECF0")!,
            mutedInkColor: ThemeColor(hex: "#F2ECF0")!.withAlpha(0.55),
            panelFill: ThemeFill(stops: [
                    ThemeColor(hex: "#4E5A68")!.withAlpha(0.55)
                ]),
            highlightFill: ThemeFill(stops: [
                    ThemeColor(hex: "#FFFFFF")!.withAlpha(0.16)
                ])
        ),
        keyArt: KeyArtSet(
            assetPrefix: "keyart_alm_",
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
            tint: ThemeColor(hex: "#9CFFB0")!
        )
    )

    static let bloomingGardenia = MochiKeyboardTheme(
        id: "mochi.blooming-gardenia",
        name: "Blooming Gardenia",
        authorName: "Mochi",
        appearance: .dark,
        surface: ThemeSurface(
            baseFill: ThemeFill(stops: [
                    ThemeColor(hex: "#C5B292")!,
                    ThemeColor(hex: "#B0B17D")!,
                    ThemeColor(hex: "#59452D")!
                ]),
            backgroundImage: ThemeBackgroundImage(
                source: .bundled(name: "themebg_blooming_gardenia"),
                scalesToFill: true,
                verticalAnchor: 0.5,
                blurRadius: 0.0
            ),
            scrim: ThemeScrim(
                topColor: ThemeColor(hex: "#676348")!.withAlpha(0.19),
                bottomColor: ThemeColor(hex: "#676348")!.withAlpha(0.06)
            )
        ),
        keyStyles: [
            .input: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#342C11")!,
                    ThemeColor(hex: "#3A2015")!
                ]),
                labelColor: ThemeColor(hex: "#FFFFFF")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#69634F")!,
                    ThemeColor(hex: "#705D55")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#FFFFFF")!,
                border: ThemeBorder(color: ThemeColor(hex: "#CAC8C1")!.withAlpha(0.42), width: 0.95),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.15, radius: 2.20, offsetY: 1.30),
                topHighlight: ThemeColor(hex: "#C2C0B8")!.withAlpha(0.46),
                cornerRadiusOverride: 14.0,
                glass: KeyGlass(
                    bevelColor: ThemeColor(hex: "#CAC8C1")!.withAlpha(0.60),
                    bevelWidth: 0.80,
                    bevelFalloff: 0.18,
                    innerShadowColor: ThemeColor(hex: "#0A080F")!,
                    innerShadowOpacity: 0.12,
                    innerShadowRadius: 2.00
                )
            ),
            .system: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#554A39")!,
                    ThemeColor(hex: "#7B7265")!
                ]),
                labelColor: ThemeColor(hex: "#FFFFFF")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#7B7265")!,
                    ThemeColor(hex: "#958D83")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#FFFFFF")!,
                border: ThemeBorder(color: ThemeColor(hex: "#D1CECA")!.withAlpha(0.42), width: 0.95),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.15, radius: 2.20, offsetY: 1.30),
                topHighlight: ThemeColor(hex: "#CAC7C1")!.withAlpha(0.46),
                cornerRadiusOverride: 14.0,
                glass: KeyGlass(
                    bevelColor: ThemeColor(hex: "#D1CECA")!.withAlpha(0.60),
                    bevelWidth: 0.80,
                    bevelFalloff: 0.18,
                    innerShadowColor: ThemeColor(hex: "#0A080F")!,
                    innerShadowOpacity: 0.12,
                    innerShadowRadius: 2.00
                )
            ),
            .action: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#2D281D")!,
                    ThemeColor(hex: "#65615A")!
                ]),
                labelColor: ThemeColor(hex: "#FFFFFF")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#65615A")!,
                    ThemeColor(hex: "#84817B")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#FFFFFF")!,
                border: ThemeBorder(color: ThemeColor(hex: "#C8C7C4")!.withAlpha(0.42), width: 0.95),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.15, radius: 2.20, offsetY: 1.30),
                topHighlight: ThemeColor(hex: "#C0BFBC")!.withAlpha(0.46),
                cornerRadiusOverride: 14.0,
                glass: KeyGlass(
                    bevelColor: ThemeColor(hex: "#C8C7C4")!.withAlpha(0.60),
                    bevelWidth: 0.80,
                    bevelFalloff: 0.18,
                    innerShadowColor: ThemeColor(hex: "#0A080F")!,
                    innerShadowOpacity: 0.12,
                    innerShadowRadius: 2.00
                )
            ),
            .space: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#342C11")!.withAlpha(0.50),
                    ThemeColor(hex: "#3A2015")!.withAlpha(0.50)
                ]),
                labelColor: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.00),
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#625B46")!.withAlpha(0.50),
                    ThemeColor(hex: "#69554C")!.withAlpha(0.50)
                ]),
                border: ThemeBorder(color: ThemeColor(hex: "#C2C0B8")!.withAlpha(0.42), width: 0.95),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.15, radius: 2.20, offsetY: 1.30),
                topHighlight: ThemeColor(hex: "#C2C0B8")!.withAlpha(0.46),
                cornerRadiusOverride: 16.0
            )
        ],
        typography: ThemeTypography(fontFamily: nil, weightRawValue: 0.34, sizeMultiplier: 1.0),
        chrome: ThemeChrome(
            inkColor: ThemeColor(hex: "#F2ECF0")!,
            mutedInkColor: ThemeColor(hex: "#F2ECF0")!.withAlpha(0.55),
            panelFill: ThemeFill(stops: [
                    ThemeColor(hex: "#685640")!.withAlpha(0.55)
                ]),
            highlightFill: ThemeFill(stops: [
                    ThemeColor(hex: "#FFFFFF")!.withAlpha(0.16)
                ])
        ),
        keyArt: KeyArtSet(
            assetPrefix: "keyart_blg_",
            heightFraction: 0.48,
            bottomInsetFraction: 0.09,
            opacity: 0.90,
            fillKeys: ["space"],
            labelLiftFraction: 0.14
        ),
        effects: .none
    )

    static let clockworkHorizon = MochiKeyboardTheme(
        id: "mochi.clockwork-horizon",
        name: "Clockwork Horizon",
        authorName: "Mochi",
        appearance: .dark,
        surface: ThemeSurface(
            baseFill: ThemeFill(stops: [
                    ThemeColor(hex: "#F4B055")!,
                    ThemeColor(hex: "#362110")!,
                    ThemeColor(hex: "#E59F5B")!
                ]),
            backgroundImage: ThemeBackgroundImage(
                source: .bundled(name: "themebg_clockwork_horizon"),
                scalesToFill: true,
                verticalAnchor: 0.5,
                blurRadius: 0.0
            ),
            scrim: ThemeScrim(
                topColor: ThemeColor(hex: "#392310")!.withAlpha(0.16),
                bottomColor: ThemeColor(hex: "#392310")!.withAlpha(0.05)
            )
        ),
        keyStyles: [
            .input: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#160B02")!,
                    ThemeColor(hex: "#3F362F")!
                ]),
                labelColor: ThemeColor(hex: "#FFFFFF")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#615954")!,
                    ThemeColor(hex: "#6E6762")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#FFFFFF")!,
                border: ThemeBorder(color: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.80), width: 1.70),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.00, radius: 0.00, offsetY: 0.00),
                topHighlight: nil,
                cornerRadiusOverride: 6.0
            ),
            .system: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#494039")!,
                    ThemeColor(hex: "#5B534D")!
                ]),
                labelColor: ThemeColor(hex: "#FFFFFF")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#736C67")!,
                    ThemeColor(hex: "#7E7773")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#FFFFFF")!,
                border: ThemeBorder(color: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.80), width: 1.70),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.00, radius: 0.00, offsetY: 0.00),
                topHighlight: nil,
                cornerRadiusOverride: 6.0
            ),
            .action: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#140B04")!,
                    ThemeColor(hex: "#3D3631")!
                ]),
                labelColor: ThemeColor(hex: "#FFFFFF")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#5F5A55")!,
                    ThemeColor(hex: "#6D6763")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#FFFFFF")!,
                border: ThemeBorder(color: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.80), width: 1.70),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.00, radius: 0.00, offsetY: 0.00),
                topHighlight: nil,
                cornerRadiusOverride: 6.0
            ),
            .space: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#160B02")!.withAlpha(0.50),
                    ThemeColor(hex: "#3F362F")!.withAlpha(0.50)
                ]),
                labelColor: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.00),
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#58504A")!.withAlpha(0.50),
                    ThemeColor(hex: "#67605A")!.withAlpha(0.50)
                ]),
                border: ThemeBorder(color: ThemeColor(hex: "#BFBCB9")!.withAlpha(0.80), width: 1.70),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.00, radius: 0.00, offsetY: 0.00),
                topHighlight: nil,
                cornerRadiusOverride: 8.0
            )
        ],
        typography: ThemeTypography(fontFamily: nil, weightRawValue: 0.34, sizeMultiplier: 1.0),
        chrome: ThemeChrome(
            inkColor: ThemeColor(hex: "#F2ECF0")!,
            mutedInkColor: ThemeColor(hex: "#F2ECF0")!.withAlpha(0.55),
            panelFill: ThemeFill(stops: [
                    ThemeColor(hex: "#665649")!.withAlpha(0.55)
                ]),
            highlightFill: ThemeFill(stops: [
                    ThemeColor(hex: "#FFFFFF")!.withAlpha(0.16)
                ])
        ),
        keyArt: KeyArtSet(
            assetPrefix: "keyart_ckh_",
            heightFraction: 0.40,
            bottomInsetFraction: 0.09,
            opacity: 0.90,
            fillKeys: ["space"],
            labelLiftFraction: 0.13
        ),
        effects: .none
    )

    static let cosmicLittleVisitors = MochiKeyboardTheme(
        id: "mochi.cosmic-little-visitors",
        name: "Cosmic Little Visitors",
        authorName: "Mochi",
        appearance: .light,
        surface: ThemeSurface(
            baseFill: ThemeFill(stops: [
                    ThemeColor(hex: "#383074")!,
                    ThemeColor(hex: "#433778")!,
                    ThemeColor(hex: "#EABFA4")!
                ]),
            backgroundImage: ThemeBackgroundImage(
                source: .bundled(name: "themebg_cosmic_little_visitors"),
                scalesToFill: true,
                verticalAnchor: 0.5,
                blurRadius: 0.0
            ),
            scrim: ThemeScrim(
                topColor: ThemeColor(hex: "#372B49")!.withAlpha(0.20),
                bottomColor: ThemeColor(hex: "#372B49")!.withAlpha(0.06)
            )
        ),
        keyStyles: [
            .input: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#F9E6E5")!,
                    ThemeColor(hex: "#F1DFDD")!
                ]),
                labelColor: ThemeColor(hex: "#221C28")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#ECDBDA")!,
                    ThemeColor(hex: "#E4D2D1")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#221C28")!,
                border: ThemeBorder(color: ThemeColor(hex: "#AEA1A0")!.withAlpha(0.40), width: 1.15),
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
                    ThemeColor(hex: "#F1DFDD")!,
                    ThemeColor(hex: "#E8D7D6")!
                ]),
                labelColor: ThemeColor(hex: "#221C28")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#E4D2D1")!,
                    ThemeColor(hex: "#DACAC9")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#221C28")!,
                border: ThemeBorder(color: ThemeColor(hex: "#A89C9B")!.withAlpha(0.40), width: 1.15),
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
                    ThemeColor(hex: "#F6E7E6")!,
                    ThemeColor(hex: "#EDDFDF")!
                ]),
                labelColor: ThemeColor(hex: "#221C28")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#E9DCDB")!,
                    ThemeColor(hex: "#E1D3D3")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#221C28")!,
                border: ThemeBorder(color: ThemeColor(hex: "#ACA2A1")!.withAlpha(0.40), width: 1.15),
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
                    ThemeColor(hex: "#F9E6E5")!.withAlpha(0.42),
                    ThemeColor(hex: "#F1DFDD")!.withAlpha(0.42)
                ]),
                labelColor: ThemeColor(hex: "#221C28")!.withAlpha(0.00),
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#EEDCDB")!.withAlpha(0.42),
                    ThemeColor(hex: "#E5D4D3")!.withAlpha(0.42)
                ]),
                border: ThemeBorder(color: ThemeColor(hex: "#FEFCFC")!.withAlpha(0.40), width: 1.15),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.30, radius: 4.20, offsetY: 3.00),
                topHighlight: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.62),
                cornerRadiusOverride: 20.0
            )
        ],
        typography: ThemeTypography(fontFamily: nil, weightRawValue: 0.34, sizeMultiplier: 1.0),
        chrome: ThemeChrome(
            inkColor: ThemeColor(hex: "#F2ECF0")!,
            mutedInkColor: ThemeColor(hex: "#F2ECF0")!.withAlpha(0.55),
            panelFill: ThemeFill(stops: [
                    ThemeColor(hex: "#595289")!.withAlpha(0.55)
                ]),
            highlightFill: ThemeFill(stops: [
                    ThemeColor(hex: "#FFFFFF")!.withAlpha(0.16)
                ])
        ),
        keyArt: KeyArtSet(
            assetPrefix: "keyart_clv_",
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
            tint: ThemeColor(hex: "#FFE38A")!
        )
    )

    static let cosmicObservatory = MochiKeyboardTheme(
        id: "mochi.cosmic-observatory",
        name: "Cosmic Observatory",
        authorName: "Mochi",
        appearance: .dark,
        surface: ThemeSurface(
            baseFill: ThemeFill(stops: [
                    ThemeColor(hex: "#311D53")!,
                    ThemeColor(hex: "#17122F")!,
                    ThemeColor(hex: "#F2A362")!
                ]),
            backgroundImage: ThemeBackgroundImage(
                source: .bundled(name: "themebg_cosmic_observatory"),
                scalesToFill: true,
                verticalAnchor: 0.5,
                blurRadius: 0.0
            ),
            scrim: ThemeScrim(
                topColor: ThemeColor(hex: "#2E213B")!.withAlpha(0.22),
                bottomColor: ThemeColor(hex: "#2E213B")!.withAlpha(0.07)
            )
        ),
        keyStyles: [
            .input: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#0E0727")!,
                    ThemeColor(hex: "#322C46")!
                ]),
                labelColor: ThemeColor(hex: "#FFFFFF")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#5D586D")!,
                    ThemeColor(hex: "#666276")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#FFFFFF")!,
                border: ThemeBorder(color: ThemeColor(hex: "#C5C3CB")!.withAlpha(0.60), width: 1.00),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.32, radius: 2.60, offsetY: 1.60),
                topHighlight: ThemeColor(hex: "#BDBBC4")!.withAlpha(0.28),
                cornerRadiusOverride: 12.0,
                glass: KeyGlass(
                    bevelColor: ThemeColor(hex: "#C5C3CB")!.withAlpha(0.62),
                    bevelWidth: 1.00,
                    bevelFalloff: 0.12,
                    innerShadowColor: ThemeColor(hex: "#0A080F")!,
                    innerShadowOpacity: 0.36,
                    innerShadowRadius: 3.00
                )
            ),
            .system: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#443E57")!,
                    ThemeColor(hex: "#514C63")!
                ]),
                labelColor: ThemeColor(hex: "#FFFFFF")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#6F6B7E")!,
                    ThemeColor(hex: "#777385")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#FFFFFF")!,
                border: ThemeBorder(color: ThemeColor(hex: "#CDCBD2")!.withAlpha(0.60), width: 1.00),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.32, radius: 2.60, offsetY: 1.60),
                topHighlight: ThemeColor(hex: "#C5C3CB")!.withAlpha(0.28),
                cornerRadiusOverride: 12.0,
                glass: KeyGlass(
                    bevelColor: ThemeColor(hex: "#CDCBD2")!.withAlpha(0.62),
                    bevelWidth: 1.00,
                    bevelFalloff: 0.12,
                    innerShadowColor: ThemeColor(hex: "#0A080F")!,
                    innerShadowOpacity: 0.36,
                    innerShadowRadius: 3.00
                )
            ),
            .action: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#100C0D")!,
                    ThemeColor(hex: "#322F30")!
                ]),
                labelColor: ThemeColor(hex: "#FFFFFF")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#5D5A5B")!,
                    ThemeColor(hex: "#676465")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#FFFFFF")!,
                border: ThemeBorder(color: ThemeColor(hex: "#C5C4C4")!.withAlpha(0.60), width: 1.00),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.32, radius: 2.60, offsetY: 1.60),
                topHighlight: ThemeColor(hex: "#BDBCBC")!.withAlpha(0.28),
                cornerRadiusOverride: 12.0,
                glass: KeyGlass(
                    bevelColor: ThemeColor(hex: "#C5C4C4")!.withAlpha(0.62),
                    bevelWidth: 1.00,
                    bevelFalloff: 0.12,
                    innerShadowColor: ThemeColor(hex: "#0A080F")!,
                    innerShadowOpacity: 0.36,
                    innerShadowRadius: 3.00
                )
            ),
            .space: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#0E0727")!.withAlpha(0.50),
                    ThemeColor(hex: "#322C46")!.withAlpha(0.50)
                ]),
                labelColor: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.00),
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#544F65")!.withAlpha(0.50),
                    ThemeColor(hex: "#5F5A6F")!.withAlpha(0.50)
                ]),
                border: ThemeBorder(color: ThemeColor(hex: "#BDBBC4")!.withAlpha(0.60), width: 1.00),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.32, radius: 2.60, offsetY: 1.60),
                topHighlight: ThemeColor(hex: "#BDBBC4")!.withAlpha(0.28),
                cornerRadiusOverride: 14.0
            )
        ],
        typography: ThemeTypography(fontFamily: nil, weightRawValue: 0.34, sizeMultiplier: 1.0),
        chrome: ThemeChrome(
            inkColor: ThemeColor(hex: "#F2ECF0")!,
            mutedInkColor: ThemeColor(hex: "#F2ECF0")!.withAlpha(0.55),
            panelFill: ThemeFill(stops: [
                    ThemeColor(hex: "#5B576B")!.withAlpha(0.55)
                ]),
            highlightFill: ThemeFill(stops: [
                    ThemeColor(hex: "#FFFFFF")!.withAlpha(0.16)
                ])
        ),
        keyArt: KeyArtSet(
            assetPrefix: "keyart_cob_",
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
            tint: ThemeColor(hex: "#8FB4FF")!
        )
    )

    static let cozyYarnHaven = MochiKeyboardTheme(
        id: "mochi.cozy-yarn-haven",
        name: "Cozy Yarn Haven",
        authorName: "Mochi",
        appearance: .dark,
        surface: ThemeSurface(
            baseFill: ThemeFill(stops: [
                    ThemeColor(hex: "#E4998A")!,
                    ThemeColor(hex: "#C28171")!,
                    ThemeColor(hex: "#EF9582")!
                ]),
            backgroundImage: ThemeBackgroundImage(
                source: .bundled(name: "themebg_cozy_yarn_haven"),
                scalesToFill: true,
                verticalAnchor: 0.5,
                blurRadius: 0.0
            ),
            scrim: ThemeScrim(
                topColor: ThemeColor(hex: "#946253")!.withAlpha(0.19),
                bottomColor: ThemeColor(hex: "#946253")!.withAlpha(0.05)
            )
        ),
        keyStyles: [
            .input: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#471D14")!,
                    ThemeColor(hex: "#66443C")!
                ]),
                labelColor: ThemeColor(hex: "#FFFFFF")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#795B55")!,
                    ThemeColor(hex: "#886D68")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#FFFFFF")!,
                border: ThemeBorder(color: ThemeColor(hex: "#421B13")!.withAlpha(0.32), width: 1.35),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.22, radius: 3.60, offsetY: 2.60),
                topHighlight: nil,
                cornerRadiusOverride: 9.0
            ),
            .system: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#66443C")!,
                    ThemeColor(hex: "#795B55")!
                ]),
                labelColor: ThemeColor(hex: "#FFFFFF")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#886D68")!,
                    ThemeColor(hex: "#957D78")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#FFFFFF")!,
                border: ThemeBorder(color: ThemeColor(hex: "#442D28")!.withAlpha(0.32), width: 1.35),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.22, radius: 3.60, offsetY: 2.60),
                topHighlight: nil,
                cornerRadiusOverride: 9.0
            ),
            .action: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#37251E")!,
                    ThemeColor(hex: "#584943")!
                ]),
                labelColor: ThemeColor(hex: "#FFFFFF")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#6D605A")!,
                    ThemeColor(hex: "#7D716C")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#FFFFFF")!,
                border: ThemeBorder(color: ThemeColor(hex: "#34231C")!.withAlpha(0.32), width: 1.35),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.22, radius: 3.60, offsetY: 2.60),
                topHighlight: nil,
                cornerRadiusOverride: 9.0
            ),
            .space: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#471D14")!.withAlpha(0.50),
                    ThemeColor(hex: "#66443C")!.withAlpha(0.50)
                ]),
                labelColor: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.00),
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#72534C")!.withAlpha(0.50),
                    ThemeColor(hex: "#836761")!.withAlpha(0.50)
                ]),
                border: ThemeBorder(color: ThemeColor(hex: "#C9BDBA")!.withAlpha(0.32), width: 1.35),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.22, radius: 3.60, offsetY: 2.60),
                topHighlight: nil,
                cornerRadiusOverride: 11.0
            )
        ],
        typography: ThemeTypography(fontFamily: nil, weightRawValue: 0.34, sizeMultiplier: 1.0),
        chrome: ThemeChrome(
            inkColor: ThemeColor(hex: "#000001")!,
            mutedInkColor: ThemeColor(hex: "#000001")!.withAlpha(0.55),
            panelFill: ThemeFill(stops: [
                    ThemeColor(hex: "#FDFBFB")!.withAlpha(0.55)
                ]),
            highlightFill: ThemeFill(stops: [
                    ThemeColor(hex: "#000000")!.withAlpha(0.16)
                ])
        ),
        keyArt: KeyArtSet(
            assetPrefix: "keyart_cyh_",
            heightFraction: 0.52,
            bottomInsetFraction: 0.10,
            opacity: 0.90,
            fillKeys: ["space"],
            labelLiftFraction: 0.15
        ),
        effects: .none
    )

    static let dragonlightValley = MochiKeyboardTheme(
        id: "mochi.dragonlight-valley",
        name: "Dragonlight Valley",
        authorName: "Mochi",
        appearance: .dark,
        surface: ThemeSurface(
            baseFill: ThemeFill(stops: [
                    ThemeColor(hex: "#78607B")!,
                    ThemeColor(hex: "#A67E5D")!,
                    ThemeColor(hex: "#F3CA94")!
                ]),
            backgroundImage: ThemeBackgroundImage(
                source: .bundled(name: "themebg_dragonlight_valley"),
                scalesToFill: true,
                verticalAnchor: 0.5,
                blurRadius: 0.0
            ),
            scrim: ThemeScrim(
                topColor: ThemeColor(hex: "#594535")!.withAlpha(0.19),
                bottomColor: ThemeColor(hex: "#594535")!.withAlpha(0.06)
            )
        ),
        keyStyles: [
            .input: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#352616")!,
                    ThemeColor(hex: "#3C1E1C")!
                ]),
                labelColor: ThemeColor(hex: "#FFFFFF")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#6B6054")!,
                    ThemeColor(hex: "#725C5B")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#FFFFFF")!,
                border: ThemeBorder(color: ThemeColor(hex: "#CBC7C2")!.withAlpha(0.42), width: 0.95),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.15, radius: 2.20, offsetY: 1.30),
                topHighlight: ThemeColor(hex: "#C3BFBA")!.withAlpha(0.46),
                cornerRadiusOverride: 14.0,
                glass: KeyGlass(
                    bevelColor: ThemeColor(hex: "#CBC7C2")!.withAlpha(0.60),
                    bevelWidth: 0.80,
                    bevelFalloff: 0.18,
                    innerShadowColor: ThemeColor(hex: "#0A080F")!,
                    innerShadowOpacity: 0.12,
                    innerShadowRadius: 2.00
                )
            ),
            .system: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#57473E")!,
                    ThemeColor(hex: "#7C7069")!
                ]),
                labelColor: ThemeColor(hex: "#FFFFFF")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#7C7069")!,
                    ThemeColor(hex: "#968C86")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#FFFFFF")!,
                border: ThemeBorder(color: ThemeColor(hex: "#D2CECB")!.withAlpha(0.42), width: 0.95),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.15, radius: 2.20, offsetY: 1.30),
                topHighlight: ThemeColor(hex: "#CBC6C3")!.withAlpha(0.46),
                cornerRadiusOverride: 14.0,
                glass: KeyGlass(
                    bevelColor: ThemeColor(hex: "#D2CECB")!.withAlpha(0.60),
                    bevelWidth: 0.80,
                    bevelFalloff: 0.18,
                    innerShadowColor: ThemeColor(hex: "#0A080F")!,
                    innerShadowOpacity: 0.12,
                    innerShadowRadius: 2.00
                )
            ),
            .action: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#2E241A")!,
                    ThemeColor(hex: "#676058")!
                ]),
                labelColor: ThemeColor(hex: "#FFFFFF")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#676058")!,
                    ThemeColor(hex: "#86807A")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#FFFFFF")!,
                border: ThemeBorder(color: ThemeColor(hex: "#C9C6C4")!.withAlpha(0.42), width: 0.95),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.15, radius: 2.20, offsetY: 1.30),
                topHighlight: ThemeColor(hex: "#C1BEBB")!.withAlpha(0.46),
                cornerRadiusOverride: 14.0,
                glass: KeyGlass(
                    bevelColor: ThemeColor(hex: "#C9C6C4")!.withAlpha(0.60),
                    bevelWidth: 0.80,
                    bevelFalloff: 0.18,
                    innerShadowColor: ThemeColor(hex: "#0A080F")!,
                    innerShadowOpacity: 0.12,
                    innerShadowRadius: 2.00
                )
            ),
            .space: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#352616")!.withAlpha(0.50),
                    ThemeColor(hex: "#3C1E1C")!.withAlpha(0.50)
                ]),
                labelColor: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.00),
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#64584B")!.withAlpha(0.50),
                    ThemeColor(hex: "#6B5452")!.withAlpha(0.50)
                ]),
                border: ThemeBorder(color: ThemeColor(hex: "#C3BFBA")!.withAlpha(0.42), width: 0.95),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.15, radius: 2.20, offsetY: 1.30),
                topHighlight: ThemeColor(hex: "#C3BFBA")!.withAlpha(0.46),
                cornerRadiusOverride: 16.0
            )
        ],
        typography: ThemeTypography(fontFamily: nil, weightRawValue: 0.34, sizeMultiplier: 1.0),
        chrome: ThemeChrome(
            inkColor: ThemeColor(hex: "#FFFFFF")!,
            mutedInkColor: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.55),
            panelFill: ThemeFill(stops: [
                    ThemeColor(hex: "#675268")!.withAlpha(0.55)
                ]),
            highlightFill: ThemeFill(stops: [
                    ThemeColor(hex: "#FFFFFF")!.withAlpha(0.16)
                ])
        ),
        keyArt: KeyArtSet(
            assetPrefix: "keyart_dlv_",
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
            tint: ThemeColor(hex: "#FF9E5E")!
        )
    )

    static let fireworkDreamFestival = MochiKeyboardTheme(
        id: "mochi.firework-dream-festival",
        name: "Firework Dream Festival",
        authorName: "Mochi",
        appearance: .light,
        surface: ThemeSurface(
            baseFill: ThemeFill(stops: [
                    ThemeColor(hex: "#583E74")!,
                    ThemeColor(hex: "#4B3463")!,
                    ThemeColor(hex: "#523C6B")!
                ]),
            backgroundImage: ThemeBackgroundImage(
                source: .bundled(name: "themebg_firework_dream_festival"),
                scalesToFill: true,
                verticalAnchor: 0.5,
                blurRadius: 0.0
            ),
            scrim: ThemeScrim(
                topColor: ThemeColor(hex: "#382436")!.withAlpha(0.18),
                bottomColor: ThemeColor(hex: "#382436")!.withAlpha(0.05)
            )
        ),
        keyStyles: [
            .input: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#F8D9D9")!,
                    ThemeColor(hex: "#EFD1D1")!
                ]),
                labelColor: ThemeColor(hex: "#221C28")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#EACDCD")!,
                    ThemeColor(hex: "#E0C4C4")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#221C28")!,
                border: ThemeBorder(color: ThemeColor(hex: "#AD9798")!.withAlpha(0.40), width: 1.15),
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
                    ThemeColor(hex: "#EFD1D1")!,
                    ThemeColor(hex: "#E5C8C8")!
                ]),
                labelColor: ThemeColor(hex: "#221C28")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#E0C4C4")!,
                    ThemeColor(hex: "#D6BBBB")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#221C28")!,
                border: ThemeBorder(color: ThemeColor(hex: "#A79292")!.withAlpha(0.40), width: 1.15),
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
                    ThemeColor(hex: "#F3DADA")!,
                    ThemeColor(hex: "#EAD2D2")!
                ]),
                labelColor: ThemeColor(hex: "#221C28")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#E5CECE")!,
                    ThemeColor(hex: "#DBC5C6")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#221C28")!,
                border: ThemeBorder(color: ThemeColor(hex: "#AA9999")!.withAlpha(0.40), width: 1.15),
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
                    ThemeColor(hex: "#F8D9D9")!.withAlpha(0.42),
                    ThemeColor(hex: "#EFD1D1")!.withAlpha(0.42)
                ]),
                labelColor: ThemeColor(hex: "#221C28")!.withAlpha(0.00),
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#ECCECE")!.withAlpha(0.42),
                    ThemeColor(hex: "#E2C5C6")!.withAlpha(0.42)
                ]),
                border: ThemeBorder(color: ThemeColor(hex: "#FEFCFC")!.withAlpha(0.40), width: 1.15),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.30, radius: 4.20, offsetY: 3.00),
                topHighlight: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.62),
                cornerRadiusOverride: 20.0
            )
        ],
        typography: ThemeTypography(fontFamily: nil, weightRawValue: 0.34, sizeMultiplier: 1.0),
        chrome: ThemeChrome(
            inkColor: ThemeColor(hex: "#F2ECF0")!,
            mutedInkColor: ThemeColor(hex: "#F2ECF0")!.withAlpha(0.55),
            panelFill: ThemeFill(stops: [
                    ThemeColor(hex: "#655178")!.withAlpha(0.55)
                ]),
            highlightFill: ThemeFill(stops: [
                    ThemeColor(hex: "#FFFFFF")!.withAlpha(0.16)
                ])
        ),
        keyArt: KeyArtSet(
            assetPrefix: "keyart_fdf_",
            heightFraction: 0.50,
            bottomInsetFraction: 0.10,
            opacity: 0.90,
            fillKeys: ["space"],
            labelLiftFraction: 0.15
        ),
        effects: ThemeEffects(
            isEnabled: true,
            birthRate: 8.0,
            particleImageName: nil,
            tint: ThemeColor(hex: "#FFD24C")!
        )
    )

    static let forgottenRuins = MochiKeyboardTheme(
        id: "mochi.forgotten-ruins",
        name: "Forgotten Ruins",
        authorName: "Mochi",
        appearance: .dark,
        surface: ThemeSurface(
            baseFill: ThemeFill(stops: [
                    ThemeColor(hex: "#926E4A")!,
                    ThemeColor(hex: "#2A3622")!,
                    ThemeColor(hex: "#D78937")!
                ]),
            backgroundImage: ThemeBackgroundImage(
                source: .bundled(name: "themebg_forgotten_ruins"),
                scalesToFill: true,
                verticalAnchor: 0.5,
                blurRadius: 0.0
            ),
            scrim: ThemeScrim(
                topColor: ThemeColor(hex: "#32311C")!.withAlpha(0.16),
                bottomColor: ThemeColor(hex: "#32311C")!.withAlpha(0.05)
            )
        ),
        keyStyles: [
            .input: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#100D02")!,
                    ThemeColor(hex: "#3A382E")!
                ]),
                labelColor: ThemeColor(hex: "#FFFFFF")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#5D5B53")!,
                    ThemeColor(hex: "#6A6861")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#FFFFFF")!,
                border: ThemeBorder(color: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.80), width: 1.70),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.00, radius: 0.00, offsetY: 0.00),
                topHighlight: nil,
                cornerRadiusOverride: 6.0
            ),
            .system: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#444239")!,
                    ThemeColor(hex: "#57544C")!
                ]),
                labelColor: ThemeColor(hex: "#FFFFFF")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#6F6D67")!,
                    ThemeColor(hex: "#7A7872")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#FFFFFF")!,
                border: ThemeBorder(color: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.80), width: 1.70),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.00, radius: 0.00, offsetY: 0.00),
                topHighlight: nil,
                cornerRadiusOverride: 6.0
            ),
            .action: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#100D04")!,
                    ThemeColor(hex: "#3A3830")!
                ]),
                labelColor: ThemeColor(hex: "#FFFFFF")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#5D5B55")!,
                    ThemeColor(hex: "#6A6863")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#FFFFFF")!,
                border: ThemeBorder(color: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.80), width: 1.70),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.00, radius: 0.00, offsetY: 0.00),
                topHighlight: nil,
                cornerRadiusOverride: 6.0
            ),
            .space: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#100D02")!.withAlpha(0.50),
                    ThemeColor(hex: "#3A382E")!.withAlpha(0.50)
                ]),
                labelColor: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.00),
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#54524A")!.withAlpha(0.50),
                    ThemeColor(hex: "#636159")!.withAlpha(0.50)
                ]),
                border: ThemeBorder(color: ThemeColor(hex: "#BDBCB9")!.withAlpha(0.80), width: 1.70),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.00, radius: 0.00, offsetY: 0.00),
                topHighlight: nil,
                cornerRadiusOverride: 8.0
            )
        ],
        typography: ThemeTypography(fontFamily: nil, weightRawValue: 0.34, sizeMultiplier: 1.0),
        chrome: ThemeChrome(
            inkColor: ThemeColor(hex: "#F2ECF0")!,
            mutedInkColor: ThemeColor(hex: "#F2ECF0")!.withAlpha(0.55),
            panelFill: ThemeFill(stops: [
                    ThemeColor(hex: "#535C4C")!.withAlpha(0.55)
                ]),
            highlightFill: ThemeFill(stops: [
                    ThemeColor(hex: "#FFFFFF")!.withAlpha(0.16)
                ])
        ),
        keyArt: KeyArtSet(
            assetPrefix: "keyart_fgr_",
            heightFraction: 0.40,
            bottomInsetFraction: 0.09,
            opacity: 0.90,
            fillKeys: ["space"],
            labelLiftFraction: 0.13
        ),
        effects: .none
    )

    static let frostedCrystalCavern = MochiKeyboardTheme(
        id: "mochi.frosted-crystal-cavern",
        name: "Frosted Crystal Cavern",
        authorName: "Mochi",
        appearance: .light,
        surface: ThemeSurface(
            baseFill: ThemeFill(stops: [
                    ThemeColor(hex: "#1A3F74")!,
                    ThemeColor(hex: "#214D73")!,
                    ThemeColor(hex: "#73B6E3")!
                ]),
            backgroundImage: ThemeBackgroundImage(
                source: .bundled(name: "themebg_frosted_crystal_cavern"),
                scalesToFill: true,
                verticalAnchor: 0.5,
                blurRadius: 0.0
            ),
            scrim: ThemeScrim(
                topColor: ThemeColor(hex: "#20354A")!.withAlpha(0.29),
                bottomColor: ThemeColor(hex: "#20354A")!.withAlpha(0.18)
            )
        ),
        keyStyles: [
            .input: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#D3E6F5")!.withAlpha(0.73),
                    ThemeColor(hex: "#CDDFEE")!.withAlpha(0.73)
                ]),
                labelColor: ThemeColor(hex: "#221C28")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#C8D9E8")!.withAlpha(0.85),
                    ThemeColor(hex: "#C1D2E1")!.withAlpha(0.85)
                ]),
                pressedLabelColor: ThemeColor(hex: "#221C28")!,
                border: ThemeBorder(color: ThemeColor(hex: "#FBFDFE")!.withAlpha(0.58), width: 1.20),
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
                    ThemeColor(hex: "#CCDEED")!.withAlpha(0.79),
                    ThemeColor(hex: "#C5D7E5")!.withAlpha(0.79)
                ]),
                labelColor: ThemeColor(hex: "#221C28")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#C0D1DF")!.withAlpha(0.91),
                    ThemeColor(hex: "#B9C9D7")!.withAlpha(0.91)
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
            .action: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#DDE4EB")!.withAlpha(0.79),
                    ThemeColor(hex: "#D6DEE4")!.withAlpha(0.79)
                ]),
                labelColor: ThemeColor(hex: "#221C28")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#D1D8DF")!.withAlpha(0.91),
                    ThemeColor(hex: "#CAD1D7")!.withAlpha(0.91)
                ]),
                pressedLabelColor: ThemeColor(hex: "#221C28")!,
                border: ThemeBorder(color: ThemeColor(hex: "#FCFDFD")!.withAlpha(0.58), width: 1.20),
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
                    ThemeColor(hex: "#D3E6F5")!.withAlpha(0.42),
                    ThemeColor(hex: "#CDDFEE")!.withAlpha(0.42)
                ]),
                labelColor: ThemeColor(hex: "#221C28")!.withAlpha(0.00),
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#C9DBEA")!.withAlpha(0.42),
                    ThemeColor(hex: "#C3D4E2")!.withAlpha(0.42)
                ]),
                border: ThemeBorder(color: ThemeColor(hex: "#FBFDFE")!.withAlpha(0.58), width: 1.20),
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
                    ThemeColor(hex: "#3D5A82")!.withAlpha(0.55)
                ]),
            highlightFill: ThemeFill(stops: [
                    ThemeColor(hex: "#FFFFFF")!.withAlpha(0.16)
                ])
        ),
        keyArt: KeyArtSet(
            assetPrefix: "keyart_fcc_",
            heightFraction: 0.46,
            bottomInsetFraction: 0.09,
            opacity: 0.90,
            fillKeys: ["space"],
            labelLiftFraction: 0.14
        ),
        effects: ThemeEffects(
            isEnabled: true,
            birthRate: 7.0,
            particleImageName: nil,
            tint: ThemeColor(hex: "#CFF3FF")!
        )
    )

    static let jurassicSunsetPark = MochiKeyboardTheme(
        id: "mochi.jurassic-sunset-park",
        name: "Jurassic Sunset Park",
        authorName: "Mochi",
        appearance: .light,
        surface: ThemeSurface(
            baseFill: ThemeFill(stops: [
                    ThemeColor(hex: "#5F4525")!,
                    ThemeColor(hex: "#222C11")!,
                    ThemeColor(hex: "#857226")!
                ]),
            backgroundImage: ThemeBackgroundImage(
                source: .bundled(name: "themebg_jurassic_sunset_park"),
                scalesToFill: true,
                verticalAnchor: 0.5,
                blurRadius: 0.0
            ),
            scrim: ThemeScrim(
                topColor: ThemeColor(hex: "#2A270F")!.withAlpha(0.18),
                bottomColor: ThemeColor(hex: "#2A270F")!.withAlpha(0.05)
            )
        ),
        keyStyles: [
            .input: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#F6C178")!,
                    ThemeColor(hex: "#EDBA74")!
                ]),
                labelColor: ThemeColor(hex: "#1F1A25")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#E5B470")!,
                    ThemeColor(hex: "#DAAB6B")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#1F1A25")!,
                border: ThemeBorder(color: ThemeColor(hex: "#FEF8EF")!.withAlpha(0.55), width: 1.00),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.26, radius: 1.60, offsetY: 1.60),
                topHighlight: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.34),
                cornerRadiusOverride: 8.0,
                glass: KeyGlass(
                    bevelColor: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.70),
                    bevelWidth: 1.00,
                    bevelFalloff: 0.10,
                    innerShadowColor: ThemeColor(hex: "#0A080F")!,
                    innerShadowOpacity: 0.16,
                    innerShadowRadius: 2.00
                )
            ),
            .system: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#EBB873")!,
                    ThemeColor(hex: "#E1B06E")!
                ]),
                labelColor: ThemeColor(hex: "#1F1A25")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#D8AA6A")!,
                    ThemeColor(hex: "#CDA164")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#1F1A25")!,
                border: ThemeBorder(color: ThemeColor(hex: "#FBF0E1")!.withAlpha(0.55), width: 1.00),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.26, radius: 1.60, offsetY: 1.60),
                topHighlight: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.34),
                cornerRadiusOverride: 8.0,
                glass: KeyGlass(
                    bevelColor: ThemeColor(hex: "#FEFDFB")!.withAlpha(0.70),
                    bevelWidth: 1.00,
                    bevelFalloff: 0.10,
                    innerShadowColor: ThemeColor(hex: "#0A080F")!,
                    innerShadowOpacity: 0.16,
                    innerShadowRadius: 2.00
                )
            ),
            .action: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#D7C8B3")!,
                    ThemeColor(hex: "#CFC1AC")!
                ]),
                labelColor: ThemeColor(hex: "#1F1A25")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#C8BAA6")!,
                    ThemeColor(hex: "#BFB29F")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#1F1A25")!,
                border: ThemeBorder(color: ThemeColor(hex: "#FAF8F6")!.withAlpha(0.55), width: 1.00),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.26, radius: 1.60, offsetY: 1.60),
                topHighlight: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.34),
                cornerRadiusOverride: 8.0,
                glass: KeyGlass(
                    bevelColor: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.70),
                    bevelWidth: 1.00,
                    bevelFalloff: 0.10,
                    innerShadowColor: ThemeColor(hex: "#0A080F")!,
                    innerShadowOpacity: 0.16,
                    innerShadowRadius: 2.00
                )
            ),
            .space: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#F6C178")!.withAlpha(0.42),
                    ThemeColor(hex: "#EDBA74")!.withAlpha(0.42)
                ]),
                labelColor: ThemeColor(hex: "#1F1A25")!.withAlpha(0.00),
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#E7B571")!.withAlpha(0.42),
                    ThemeColor(hex: "#DCAD6C")!.withAlpha(0.42)
                ]),
                border: ThemeBorder(color: ThemeColor(hex: "#FEF8EF")!.withAlpha(0.55), width: 1.00),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.26, radius: 1.60, offsetY: 1.60),
                topHighlight: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.34),
                cornerRadiusOverride: 10.0
            )
        ],
        typography: ThemeTypography(fontFamily: nil, weightRawValue: 0.34, sizeMultiplier: 1.0),
        chrome: ThemeChrome(
            inkColor: ThemeColor(hex: "#F2ECF0")!,
            mutedInkColor: ThemeColor(hex: "#F2ECF0")!.withAlpha(0.55),
            panelFill: ThemeFill(stops: [
                    ThemeColor(hex: "#555C47")!.withAlpha(0.55)
                ]),
            highlightFill: ThemeFill(stops: [
                    ThemeColor(hex: "#FFFFFF")!.withAlpha(0.16)
                ])
        ),
        keyArt: KeyArtSet(
            assetPrefix: "keyart_jsp_",
            heightFraction: 0.46,
            bottomInsetFraction: 0.09,
            opacity: 0.90,
            fillKeys: ["space"],
            labelLiftFraction: 0.14
        ),
        effects: .none
    )

    static let kiteboundSunset = MochiKeyboardTheme(
        id: "mochi.kitebound-sunset",
        name: "Kitebound Sunset",
        authorName: "Mochi",
        appearance: .light,
        surface: ThemeSurface(
            baseFill: ThemeFill(stops: [
                    ThemeColor(hex: "#7F5062")!,
                    ThemeColor(hex: "#E2824A")!,
                    ThemeColor(hex: "#78442D")!
                ]),
            backgroundImage: ThemeBackgroundImage(
                source: .bundled(name: "themebg_kitebound_sunset"),
                scalesToFill: true,
                verticalAnchor: 0.5,
                blurRadius: 0.0
            ),
            scrim: ThemeScrim(
                topColor: ThemeColor(hex: "#6D3E27")!.withAlpha(0.18),
                bottomColor: ThemeColor(hex: "#6D3E27")!.withAlpha(0.05)
            )
        ),
        keyStyles: [
            .input: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#FFF5E7")!,
                    ThemeColor(hex: "#F7E3E0")!
                ]),
                labelColor: ThemeColor(hex: "#221C28")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#F4EADD")!,
                    ThemeColor(hex: "#EBD7D4")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#221C28")!,
                border: ThemeBorder(color: ThemeColor(hex: "#FFFCF9")!.withAlpha(0.42), width: 0.95),
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
                    ThemeColor(hex: "#F7EAE0")!,
                    ThemeColor(hex: "#EADDD4")!
                ]),
                labelColor: ThemeColor(hex: "#221C28")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#EBDED5")!,
                    ThemeColor(hex: "#DDD1C8")!
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
            .action: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#FEF1E8")!,
                    ThemeColor(hex: "#F1E5DC")!
                ]),
                labelColor: ThemeColor(hex: "#221C28")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#F3E6DD")!,
                    ThemeColor(hex: "#E5D9D1")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#221C28")!,
                border: ThemeBorder(color: ThemeColor(hex: "#FFFCFB")!.withAlpha(0.42), width: 0.95),
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
                    ThemeColor(hex: "#FFF5E7")!.withAlpha(0.42),
                    ThemeColor(hex: "#F7E3E0")!.withAlpha(0.42)
                ]),
                labelColor: ThemeColor(hex: "#221C28")!.withAlpha(0.00),
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#F5ECDE")!.withAlpha(0.42),
                    ThemeColor(hex: "#ECD8D6")!.withAlpha(0.42)
                ]),
                border: ThemeBorder(color: ThemeColor(hex: "#FFFCF9")!.withAlpha(0.42), width: 0.95),
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
                    ThemeColor(hex: "#7E4D37")!.withAlpha(0.55)
                ]),
            highlightFill: ThemeFill(stops: [
                    ThemeColor(hex: "#FFFFFF")!.withAlpha(0.16)
                ])
        ),
        keyArt: KeyArtSet(
            assetPrefix: "keyart_kbs_",
            heightFraction: 0.48,
            bottomInsetFraction: 0.09,
            opacity: 0.90,
            fillKeys: ["space"],
            labelLiftFraction: 0.14
        ),
        effects: .none
    )

    static let meadowMorning = MochiKeyboardTheme(
        id: "mochi.meadow-morning",
        name: "Meadow Morning",
        authorName: "Mochi",
        appearance: .dark,
        surface: ThemeSurface(
            baseFill: ThemeFill(stops: [
                    ThemeColor(hex: "#7D8C61")!,
                    ThemeColor(hex: "#CCC68A")!,
                    ThemeColor(hex: "#896545")!
                ]),
            backgroundImage: ThemeBackgroundImage(
                source: .bundled(name: "themebg_meadow_morning"),
                scalesToFill: true,
                verticalAnchor: 0.5,
                blurRadius: 0.0
            ),
            scrim: ThemeScrim(
                topColor: ThemeColor(hex: "#938A5D")!.withAlpha(0.41),
                bottomColor: ThemeColor(hex: "#938A5D")!.withAlpha(0.19)
            )
        ),
        keyStyles: [
            .input: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#382A13")!,
                    ThemeColor(hex: "#584C39")!
                ]),
                labelColor: ThemeColor(hex: "#FFFFFF")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#6C6251")!,
                    ThemeColor(hex: "#7C7364")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#FFFFFF")!,
                border: ThemeBorder(color: ThemeColor(hex: "#312511")!.withAlpha(0.32), width: 1.35),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.22, radius: 3.60, offsetY: 2.60),
                topHighlight: nil,
                cornerRadiusOverride: 9.0
            ),
            .system: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#584C39")!,
                    ThemeColor(hex: "#6C6251")!
                ]),
                labelColor: ThemeColor(hex: "#FFFFFF")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#7C7364")!,
                    ThemeColor(hex: "#8A8274")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#FFFFFF")!,
                border: ThemeBorder(color: ThemeColor(hex: "#3A3326")!.withAlpha(0.32), width: 1.35),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.22, radius: 3.60, offsetY: 2.60),
                topHighlight: nil,
                cornerRadiusOverride: 9.0
            ),
            .action: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#302B20")!,
                    ThemeColor(hex: "#514D43")!
                ]),
                labelColor: ThemeColor(hex: "#FFFFFF")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#67635A")!,
                    ThemeColor(hex: "#77746C")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#FFFFFF")!,
                border: ThemeBorder(color: ThemeColor(hex: "#2B261C")!.withAlpha(0.32), width: 1.35),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.22, radius: 3.60, offsetY: 2.60),
                topHighlight: nil,
                cornerRadiusOverride: 9.0
            ),
            .space: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#382A13")!.withAlpha(0.50),
                    ThemeColor(hex: "#584C39")!.withAlpha(0.50)
                ]),
                labelColor: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.00),
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#655A48")!.withAlpha(0.50),
                    ThemeColor(hex: "#766D5D")!.withAlpha(0.50)
                ]),
                border: ThemeBorder(color: ThemeColor(hex: "#C3BFB8")!.withAlpha(0.32), width: 1.35),
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
                    ThemeColor(hex: "#6D553A")!.withAlpha(0.55)
                ]),
            highlightFill: ThemeFill(stops: [
                    ThemeColor(hex: "#FFFFFF")!.withAlpha(0.16)
                ])
        ),
        keyArt: KeyArtSet(
            assetPrefix: "keyart_mdm_",
            heightFraction: 0.52,
            bottomInsetFraction: 0.10,
            opacity: 0.90,
            fillKeys: ["space"],
            labelLiftFraction: 0.15
        ),
        effects: .none
    )

    static let moonlitPotionLab = MochiKeyboardTheme(
        id: "mochi.moonlit-potion-lab",
        name: "Moonlit Potion Lab",
        authorName: "Mochi",
        appearance: .light,
        surface: ThemeSurface(
            baseFill: ThemeFill(stops: [
                    ThemeColor(hex: "#3E347F")!,
                    ThemeColor(hex: "#4E3474")!,
                    ThemeColor(hex: "#512F30")!
                ]),
            backgroundImage: ThemeBackgroundImage(
                source: .bundled(name: "themebg_moonlit_potion_lab"),
                scalesToFill: true,
                verticalAnchor: 0.5,
                blurRadius: 0.0
            ),
            scrim: ThemeScrim(
                topColor: ThemeColor(hex: "#322039")!.withAlpha(0.18),
                bottomColor: ThemeColor(hex: "#322039")!.withAlpha(0.05)
            )
        ),
        keyStyles: [
            .input: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#E8BDB0")!,
                    ThemeColor(hex: "#DCB4A8")!
                ]),
                labelColor: ThemeColor(hex: "#16121A")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#D7AFA3")!,
                    ThemeColor(hex: "#CAA59A")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#16121A")!,
                border: ThemeBorder(color: ThemeColor(hex: "#A2847B")!.withAlpha(0.40), width: 1.15),
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
                    ThemeColor(hex: "#DCB4A8")!,
                    ThemeColor(hex: "#D0AA9F")!
                ]),
                labelColor: ThemeColor(hex: "#16121A")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#CAA59A")!,
                    ThemeColor(hex: "#BC9A8F")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#16121A")!,
                border: ThemeBorder(color: ThemeColor(hex: "#997D75")!.withAlpha(0.40), width: 1.15),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.30, radius: 4.20, offsetY: 3.00),
                topHighlight: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.62),
                cornerRadiusOverride: 19.0,
                glass: KeyGlass(
                    bevelColor: ThemeColor(hex: "#FDFAF9")!.withAlpha(0.00),
                    bevelWidth: 0.00,
                    bevelFalloff: 0.50,
                    innerShadowColor: ThemeColor(hex: "#FFFFFF")!,
                    innerShadowOpacity: 0.34,
                    innerShadowRadius: 3.20
                )
            ),
            .action: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#D2C2CE")!,
                    ThemeColor(hex: "#C8B9C4")!
                ]),
                labelColor: ThemeColor(hex: "#16121A")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#C2B4BF")!,
                    ThemeColor(hex: "#B7A9B3")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#16121A")!,
                border: ThemeBorder(color: ThemeColor(hex: "#92878F")!.withAlpha(0.40), width: 1.15),
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
                    ThemeColor(hex: "#E8BDB0")!.withAlpha(0.42),
                    ThemeColor(hex: "#DCB4A8")!.withAlpha(0.42)
                ]),
                labelColor: ThemeColor(hex: "#16121A")!.withAlpha(0.00),
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#D9B1A5")!.withAlpha(0.42),
                    ThemeColor(hex: "#CCA79B")!.withAlpha(0.42)
                ]),
                border: ThemeBorder(color: ThemeColor(hex: "#FBF4F2")!.withAlpha(0.40), width: 1.15),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.30, radius: 4.20, offsetY: 3.00),
                topHighlight: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.62),
                cornerRadiusOverride: 20.0
            )
        ],
        typography: ThemeTypography(fontFamily: nil, weightRawValue: 0.34, sizeMultiplier: 1.0),
        chrome: ThemeChrome(
            inkColor: ThemeColor(hex: "#F2ECF0")!,
            mutedInkColor: ThemeColor(hex: "#F2ECF0")!.withAlpha(0.55),
            panelFill: ThemeFill(stops: [
                    ThemeColor(hex: "#6E5254")!.withAlpha(0.55)
                ]),
            highlightFill: ThemeFill(stops: [
                    ThemeColor(hex: "#FFFFFF")!.withAlpha(0.16)
                ])
        ),
        keyArt: KeyArtSet(
            assetPrefix: "keyart_mpl_",
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
            tint: ThemeColor(hex: "#B48CFF")!
        )
    )

    static let mysteryAtDusk = MochiKeyboardTheme(
        id: "mochi.mystery-at-dusk",
        name: "Mystery at Dusk",
        authorName: "Mochi",
        appearance: .dark,
        surface: ThemeSurface(
            baseFill: ThemeFill(stops: [
                    ThemeColor(hex: "#53322B")!,
                    ThemeColor(hex: "#9B693C")!,
                    ThemeColor(hex: "#B97A4F")!
                ]),
            backgroundImage: ThemeBackgroundImage(
                source: .bundled(name: "themebg_mystery_at_dusk"),
                scalesToFill: true,
                verticalAnchor: 0.5,
                blurRadius: 0.0
            ),
            scrim: ThemeScrim(
                topColor: ThemeColor(hex: "#764F2E")!.withAlpha(0.22),
                bottomColor: ThemeColor(hex: "#764F2E")!.withAlpha(0.07)
            )
        ),
        keyStyles: [
            .input: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#2C1203")!,
                    ThemeColor(hex: "#462F22")!
                ]),
                labelColor: ThemeColor(hex: "#FFFFFF")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#6C5A4F")!,
                    ThemeColor(hex: "#75635A")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#FFFFFF")!,
                border: ThemeBorder(color: ThemeColor(hex: "#CBC4C0")!.withAlpha(0.60), width: 1.00),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.32, radius: 2.60, offsetY: 1.60),
                topHighlight: ThemeColor(hex: "#C3BCB8")!.withAlpha(0.28),
                cornerRadiusOverride: 12.0,
                glass: KeyGlass(
                    bevelColor: ThemeColor(hex: "#CBC4C0")!.withAlpha(0.62),
                    bevelWidth: 1.00,
                    bevelFalloff: 0.12,
                    innerShadowColor: ThemeColor(hex: "#0A080F")!,
                    innerShadowOpacity: 0.36,
                    innerShadowRadius: 3.00
                )
            ),
            .system: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#564135")!,
                    ThemeColor(hex: "#624E43")!
                ]),
                labelColor: ThemeColor(hex: "#FFFFFF")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#7C6C63")!,
                    ThemeColor(hex: "#83746C")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#FFFFFF")!,
                border: ThemeBorder(color: ThemeColor(hex: "#D2CCC9")!.withAlpha(0.60), width: 1.00),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.32, radius: 2.60, offsetY: 1.60),
                topHighlight: ThemeColor(hex: "#CBC4C0")!.withAlpha(0.28),
                cornerRadiusOverride: 12.0,
                glass: KeyGlass(
                    bevelColor: ThemeColor(hex: "#D2CCC9")!.withAlpha(0.62),
                    bevelWidth: 1.00,
                    bevelFalloff: 0.12,
                    innerShadowColor: ThemeColor(hex: "#0A080F")!,
                    innerShadowOpacity: 0.36,
                    innerShadowRadius: 3.00
                )
            ),
            .action: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#22170D")!,
                    ThemeColor(hex: "#3D332A")!
                ]),
                labelColor: ThemeColor(hex: "#FFFFFF")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#645C55")!,
                    ThemeColor(hex: "#6D665F")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#FFFFFF")!,
                border: ThemeBorder(color: ThemeColor(hex: "#C8C5C2")!.withAlpha(0.60), width: 1.00),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.32, radius: 2.60, offsetY: 1.60),
                topHighlight: ThemeColor(hex: "#C0BDBA")!.withAlpha(0.28),
                cornerRadiusOverride: 12.0,
                glass: KeyGlass(
                    bevelColor: ThemeColor(hex: "#C8C5C2")!.withAlpha(0.62),
                    bevelWidth: 1.00,
                    bevelFalloff: 0.12,
                    innerShadowColor: ThemeColor(hex: "#0A080F")!,
                    innerShadowOpacity: 0.36,
                    innerShadowRadius: 3.00
                )
            ),
            .space: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#2C1203")!.withAlpha(0.50),
                    ThemeColor(hex: "#462F22")!.withAlpha(0.50)
                ]),
                labelColor: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.00),
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#645146")!.withAlpha(0.50),
                    ThemeColor(hex: "#6E5C51")!.withAlpha(0.50)
                ]),
                border: ThemeBorder(color: ThemeColor(hex: "#C3BCB8")!.withAlpha(0.60), width: 1.00),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.32, radius: 2.60, offsetY: 1.60),
                topHighlight: ThemeColor(hex: "#C3BCB8")!.withAlpha(0.28),
                cornerRadiusOverride: 14.0
            )
        ],
        typography: ThemeTypography(fontFamily: nil, weightRawValue: 0.34, sizeMultiplier: 1.0),
        chrome: ThemeChrome(
            inkColor: ThemeColor(hex: "#F2ECF0")!,
            mutedInkColor: ThemeColor(hex: "#F2ECF0")!.withAlpha(0.55),
            panelFill: ThemeFill(stops: [
                    ThemeColor(hex: "#6F534B")!.withAlpha(0.55)
                ]),
            highlightFill: ThemeFill(stops: [
                    ThemeColor(hex: "#FFFFFF")!.withAlpha(0.16)
                ])
        ),
        keyArt: KeyArtSet(
            assetPrefix: "keyart_myd_",
            heightFraction: 0.44,
            bottomInsetFraction: 0.09,
            opacity: 0.90,
            fillKeys: ["space"],
            labelLiftFraction: 0.14
        ),
        effects: .none
    )

    static let neonCodeHaven = MochiKeyboardTheme(
        id: "mochi.neon-code-haven",
        name: "Neon Code Haven",
        authorName: "Mochi",
        appearance: .light,
        surface: ThemeSurface(
            baseFill: ThemeFill(stops: [
                    ThemeColor(hex: "#24328B")!,
                    ThemeColor(hex: "#151740")!,
                    ThemeColor(hex: "#313491")!
                ]),
            backgroundImage: ThemeBackgroundImage(
                source: .bundled(name: "themebg_neon_code_haven"),
                scalesToFill: true,
                verticalAnchor: 0.5,
                blurRadius: 0.0
            ),
            scrim: ThemeScrim(
                topColor: ThemeColor(hex: "#262247")!.withAlpha(0.18),
                bottomColor: ThemeColor(hex: "#262247")!.withAlpha(0.05)
            )
        ),
        keyStyles: [
            .input: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#FB9268")!,
                    ThemeColor(hex: "#ED8A62")!
                ]),
                labelColor: ThemeColor(hex: "#000000")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#E1835E")!,
                    ThemeColor(hex: "#D17A57")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#000000")!,
                border: ThemeBorder(color: ThemeColor(hex: "#FEDDCF")!.withAlpha(0.55), width: 1.00),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.26, radius: 1.60, offsetY: 1.60),
                topHighlight: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.34),
                cornerRadiusOverride: 8.0,
                glass: KeyGlass(
                    bevelColor: ThemeColor(hex: "#FEECE5")!.withAlpha(0.70),
                    bevelWidth: 1.00,
                    bevelFalloff: 0.10,
                    innerShadowColor: ThemeColor(hex: "#0A080F")!,
                    innerShadowOpacity: 0.16,
                    innerShadowRadius: 2.00
                )
            ),
            .system: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#EA8861")!,
                    ThemeColor(hex: "#DB7F5B")!
                ]),
                labelColor: ThemeColor(hex: "#000000")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#CD7855")!,
                    ThemeColor(hex: "#BB6D4E")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#000000")!,
                border: ThemeBorder(color: ThemeColor(hex: "#F7D4C6")!.withAlpha(0.55), width: 1.00),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.26, radius: 1.60, offsetY: 1.60),
                topHighlight: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.34),
                cornerRadiusOverride: 8.0,
                glass: KeyGlass(
                    bevelColor: ThemeColor(hex: "#FAE4DB")!.withAlpha(0.70),
                    bevelWidth: 1.00,
                    bevelFalloff: 0.10,
                    innerShadowColor: ThemeColor(hex: "#0A080F")!,
                    innerShadowOpacity: 0.16,
                    innerShadowRadius: 2.00
                )
            ),
            .action: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#E59C7F")!,
                    ThemeColor(hex: "#D89478")!
                ]),
                labelColor: ThemeColor(hex: "#000000")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#CD8C72")!,
                    ThemeColor(hex: "#BE826A")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#000000")!,
                border: ThemeBorder(color: ThemeColor(hex: "#F6DFD5")!.withAlpha(0.55), width: 1.00),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.26, radius: 1.60, offsetY: 1.60),
                topHighlight: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.34),
                cornerRadiusOverride: 8.0,
                glass: KeyGlass(
                    bevelColor: ThemeColor(hex: "#FAEDE8")!.withAlpha(0.70),
                    bevelWidth: 1.00,
                    bevelFalloff: 0.10,
                    innerShadowColor: ThemeColor(hex: "#0A080F")!,
                    innerShadowOpacity: 0.16,
                    innerShadowRadius: 2.00
                )
            ),
            .space: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#FB9268")!.withAlpha(0.42),
                    ThemeColor(hex: "#ED8A62")!.withAlpha(0.42)
                ]),
                labelColor: ThemeColor(hex: "#000000")!.withAlpha(0.00),
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#E4855F")!.withAlpha(0.42),
                    ThemeColor(hex: "#D47C58")!.withAlpha(0.42)
                ]),
                border: ThemeBorder(color: ThemeColor(hex: "#FEDDCF")!.withAlpha(0.55), width: 1.00),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.26, radius: 1.60, offsetY: 1.60),
                topHighlight: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.34),
                cornerRadiusOverride: 10.0
            )
        ],
        typography: ThemeTypography(fontFamily: nil, weightRawValue: 0.34, sizeMultiplier: 1.0),
        chrome: ThemeChrome(
            inkColor: ThemeColor(hex: "#F2ECF0")!,
            mutedInkColor: ThemeColor(hex: "#F2ECF0")!.withAlpha(0.55),
            panelFill: ThemeFill(stops: [
                    ThemeColor(hex: "#565774")!.withAlpha(0.55)
                ]),
            highlightFill: ThemeFill(stops: [
                    ThemeColor(hex: "#FFFFFF")!.withAlpha(0.16)
                ])
        ),
        keyArt: KeyArtSet(
            assetPrefix: "keyart_nch_",
            heightFraction: 0.46,
            bottomInsetFraction: 0.09,
            opacity: 0.90,
            fillKeys: ["space"],
            labelLiftFraction: 0.14
        ),
        effects: .none
    )

    static let neuralDreamscape = MochiKeyboardTheme(
        id: "mochi.neural-dreamscape",
        name: "Neural Dreamscape",
        authorName: "Mochi",
        appearance: .light,
        surface: ThemeSurface(
            baseFill: ThemeFill(stops: [
                    ThemeColor(hex: "#F588B8")!,
                    ThemeColor(hex: "#1B1232")!,
                    ThemeColor(hex: "#964C4B")!
                ]),
            backgroundImage: ThemeBackgroundImage(
                source: .bundled(name: "themebg_neural_dreamscape"),
                scalesToFill: true,
                verticalAnchor: 0.5,
                blurRadius: 0.0
            ),
            scrim: ThemeScrim(
                topColor: ThemeColor(hex: "#311F3D")!.withAlpha(0.40),
                bottomColor: ThemeColor(hex: "#311F3D")!.withAlpha(0.25)
            )
        ),
        keyStyles: [
            .input: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#F897C2")!.withAlpha(0.73),
                    ThemeColor(hex: "#EC8FB8")!.withAlpha(0.73)
                ]),
                labelColor: ThemeColor(hex: "#000000")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#E189B0")!.withAlpha(0.85),
                    ThemeColor(hex: "#D380A5")!.withAlpha(0.85)
                ]),
                pressedLabelColor: ThemeColor(hex: "#000000")!,
                border: ThemeBorder(color: ThemeColor(hex: "#FDE1EE")!.withAlpha(0.58), width: 1.20),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.17, radius: 1.90, offsetY: 1.10),
                topHighlight: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.58),
                cornerRadiusOverride: 13.0,
                glass: KeyGlass(
                    bevelColor: ThemeColor(hex: "#FEF1F7")!.withAlpha(0.82),
                    bevelWidth: 1.30,
                    bevelFalloff: 0.34,
                    innerShadowColor: ThemeColor(hex: "#0A080F")!,
                    innerShadowOpacity: 0.20,
                    innerShadowRadius: 2.80
                )
            ),
            .system: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#E98EB6")!.withAlpha(0.79),
                    ThemeColor(hex: "#DC85AC")!.withAlpha(0.79)
                ]),
                labelColor: ThemeColor(hex: "#000000")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#D07EA2")!.withAlpha(0.91),
                    ThemeColor(hex: "#C07596")!.withAlpha(0.91)
                ]),
                pressedLabelColor: ThemeColor(hex: "#000000")!,
                border: ThemeBorder(color: ThemeColor(hex: "#F8D9E6")!.withAlpha(0.58), width: 1.20),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.17, radius: 1.90, offsetY: 1.10),
                topHighlight: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.58),
                cornerRadiusOverride: 13.0,
                glass: KeyGlass(
                    bevelColor: ThemeColor(hex: "#FBE9F1")!.withAlpha(0.82),
                    bevelWidth: 1.30,
                    bevelFalloff: 0.34,
                    innerShadowColor: ThemeColor(hex: "#0A080F")!,
                    innerShadowOpacity: 0.20,
                    innerShadowRadius: 2.80
                )
            ),
            .action: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#EE9CC1")!.withAlpha(0.79),
                    ThemeColor(hex: "#E294B7")!.withAlpha(0.79)
                ]),
                labelColor: ThemeColor(hex: "#000000")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#D88EAF")!.withAlpha(0.91),
                    ThemeColor(hex: "#CA85A4")!.withAlpha(0.91)
                ]),
                pressedLabelColor: ThemeColor(hex: "#000000")!,
                border: ThemeBorder(color: ThemeColor(hex: "#FAE2ED")!.withAlpha(0.58), width: 1.20),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.17, radius: 1.90, offsetY: 1.10),
                topHighlight: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.58),
                cornerRadiusOverride: 13.0,
                glass: KeyGlass(
                    bevelColor: ThemeColor(hex: "#FDF2F7")!.withAlpha(0.82),
                    bevelWidth: 1.30,
                    bevelFalloff: 0.34,
                    innerShadowColor: ThemeColor(hex: "#0A080F")!,
                    innerShadowOpacity: 0.20,
                    innerShadowRadius: 2.80
                )
            ),
            .space: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#F897C2")!.withAlpha(0.42),
                    ThemeColor(hex: "#EC8FB8")!.withAlpha(0.42)
                ]),
                labelColor: ThemeColor(hex: "#000000")!.withAlpha(0.00),
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#E48AB2")!.withAlpha(0.42),
                    ThemeColor(hex: "#D682A7")!.withAlpha(0.42)
                ]),
                border: ThemeBorder(color: ThemeColor(hex: "#FDE1EE")!.withAlpha(0.58), width: 1.20),
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
                    ThemeColor(hex: "#5E556C")!.withAlpha(0.55)
                ]),
            highlightFill: ThemeFill(stops: [
                    ThemeColor(hex: "#FFFFFF")!.withAlpha(0.16)
                ])
        ),
        keyArt: KeyArtSet(
            assetPrefix: "keyart_nrd_",
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
            tint: ThemeColor(hex: "#5EF2FF")!
        )
    )

    static let oceanicDreamscape = MochiKeyboardTheme(
        id: "mochi.oceanic-dreamscape",
        name: "Oceanic Dreamscape",
        authorName: "Mochi",
        appearance: .light,
        surface: ThemeSurface(
            baseFill: ThemeFill(stops: [
                    ThemeColor(hex: "#487EBB")!,
                    ThemeColor(hex: "#95C4BA")!,
                    ThemeColor(hex: "#EFE7C3")!
                ]),
            backgroundImage: ThemeBackgroundImage(
                source: .bundled(name: "themebg_oceanic_dreamscape"),
                scalesToFill: true,
                verticalAnchor: 0.5,
                blurRadius: 0.0
            ),
            scrim: ThemeScrim(
                topColor: ThemeColor(hex: "#5A6B63")!.withAlpha(0.28),
                bottomColor: ThemeColor(hex: "#5A6B63")!.withAlpha(0.17)
            )
        ),
        keyStyles: [
            .input: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#F8F3E6")!.withAlpha(0.73),
                    ThemeColor(hex: "#F2EDE0")!.withAlpha(0.73)
                ]),
                labelColor: ThemeColor(hex: "#221C28")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#EDE8DB")!.withAlpha(0.85),
                    ThemeColor(hex: "#E6E2D5")!.withAlpha(0.85)
                ]),
                pressedLabelColor: ThemeColor(hex: "#221C28")!,
                border: ThemeBorder(color: ThemeColor(hex: "#FEFDFA")!.withAlpha(0.58), width: 1.20),
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
                    ThemeColor(hex: "#F1ECDF")!.withAlpha(0.79),
                    ThemeColor(hex: "#EAE6D9")!.withAlpha(0.79)
                ]),
                labelColor: ThemeColor(hex: "#221C28")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#E5E1D4")!.withAlpha(0.91),
                    ThemeColor(hex: "#DEDACE")!.withAlpha(0.91)
                ]),
                pressedLabelColor: ThemeColor(hex: "#221C28")!,
                border: ThemeBorder(color: ThemeColor(hex: "#FDFDFB")!.withAlpha(0.58), width: 1.20),
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
                    ThemeColor(hex: "#F6F3EB")!.withAlpha(0.79),
                    ThemeColor(hex: "#F0EDE5")!.withAlpha(0.79)
                ]),
                labelColor: ThemeColor(hex: "#221C28")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#EBE8E0")!.withAlpha(0.91),
                    ThemeColor(hex: "#E5E2DA")!.withAlpha(0.91)
                ]),
                pressedLabelColor: ThemeColor(hex: "#221C28")!,
                border: ThemeBorder(color: ThemeColor(hex: "#FDFDFB")!.withAlpha(0.58), width: 1.20),
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
                    ThemeColor(hex: "#F8F3E6")!.withAlpha(0.42),
                    ThemeColor(hex: "#F2EDE0")!.withAlpha(0.42)
                ]),
                labelColor: ThemeColor(hex: "#221C28")!.withAlpha(0.00),
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#EEEADD")!.withAlpha(0.42),
                    ThemeColor(hex: "#E7E3D7")!.withAlpha(0.42)
                ]),
                border: ThemeBorder(color: ThemeColor(hex: "#FEFDFA")!.withAlpha(0.58), width: 1.20),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.17, radius: 1.90, offsetY: 1.10),
                topHighlight: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.58),
                cornerRadiusOverride: 15.0
            )
        ],
        typography: ThemeTypography(fontFamily: nil, weightRawValue: 0.34, sizeMultiplier: 1.0),
        chrome: ThemeChrome(
            inkColor: ThemeColor(hex: "#08050D")!,
            mutedInkColor: ThemeColor(hex: "#08050D")!.withAlpha(0.55),
            panelFill: ThemeFill(stops: [
                    ThemeColor(hex: "#FBFCFD")!.withAlpha(0.55)
                ]),
            highlightFill: ThemeFill(stops: [
                    ThemeColor(hex: "#000000")!.withAlpha(0.16)
                ])
        ),
        keyArt: KeyArtSet(
            assetPrefix: "keyart_ocd_",
            heightFraction: 0.46,
            bottomInsetFraction: 0.09,
            opacity: 0.90,
            fillKeys: ["space"],
            labelLiftFraction: 0.14
        ),
        effects: .none
    )

    static let sakuraSerenity = MochiKeyboardTheme(
        id: "mochi.sakura-serenity",
        name: "Sakura Serenity",
        authorName: "Mochi",
        appearance: .light,
        surface: ThemeSurface(
            baseFill: ThemeFill(stops: [
                    ThemeColor(hex: "#75684E")!,
                    ThemeColor(hex: "#F8D1B2")!,
                    ThemeColor(hex: "#864F30")!
                ]),
            backgroundImage: ThemeBackgroundImage(
                source: .bundled(name: "themebg_sakura_serenity"),
                scalesToFill: true,
                verticalAnchor: 0.5,
                blurRadius: 0.0
            ),
            scrim: ThemeScrim(
                topColor: ThemeColor(hex: "#816856")!.withAlpha(0.19),
                bottomColor: ThemeColor(hex: "#816856")!.withAlpha(0.06)
            )
        ),
        keyStyles: [
            .input: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#FFF1E7")!,
                    ThemeColor(hex: "#F7EAE0")!
                ]),
                labelColor: ThemeColor(hex: "#221C28")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#F3E6DC")!,
                    ThemeColor(hex: "#EBDED5")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#221C28")!,
                border: ThemeBorder(color: ThemeColor(hex: "#B3A9A2")!.withAlpha(0.40), width: 1.15),
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
                    ThemeColor(hex: "#F7EAE0")!,
                    ThemeColor(hex: "#EFE2D9")!
                ]),
                labelColor: ThemeColor(hex: "#221C28")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#EBDED5")!,
                    ThemeColor(hex: "#E3D6CD")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#221C28")!,
                border: ThemeBorder(color: ThemeColor(hex: "#ADA49D")!.withAlpha(0.40), width: 1.15),
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
                    ThemeColor(hex: "#FDF2E9")!,
                    ThemeColor(hex: "#F5EAE2")!
                ]),
                labelColor: ThemeColor(hex: "#221C28")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#F1E7DF")!,
                    ThemeColor(hex: "#E9DFD7")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#221C28")!,
                border: ThemeBorder(color: ThemeColor(hex: "#B1A9A3")!.withAlpha(0.40), width: 1.15),
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
                    ThemeColor(hex: "#FFF1E7")!.withAlpha(0.42),
                    ThemeColor(hex: "#F7EAE0")!.withAlpha(0.42)
                ]),
                labelColor: ThemeColor(hex: "#221C28")!.withAlpha(0.00),
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#F5E7DD")!.withAlpha(0.42),
                    ThemeColor(hex: "#EDE0D6")!.withAlpha(0.42)
                ]),
                border: ThemeBorder(color: ThemeColor(hex: "#FFFCFA")!.withAlpha(0.40), width: 1.15),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.30, radius: 4.20, offsetY: 3.00),
                topHighlight: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.62),
                cornerRadiusOverride: 20.0
            )
        ],
        typography: ThemeTypography(fontFamily: nil, weightRawValue: 0.34, sizeMultiplier: 1.0),
        chrome: ThemeChrome(
            inkColor: ThemeColor(hex: "#FFFEFE")!,
            mutedInkColor: ThemeColor(hex: "#FFFEFE")!.withAlpha(0.55),
            panelFill: ThemeFill(stops: [
                    ThemeColor(hex: "#7F4D30")!.withAlpha(0.55)
                ]),
            highlightFill: ThemeFill(stops: [
                    ThemeColor(hex: "#FFFFFF")!.withAlpha(0.16)
                ])
        ),
        keyArt: KeyArtSet(
            assetPrefix: "keyart_sks_",
            heightFraction: 0.50,
            bottomInsetFraction: 0.10,
            opacity: 0.90,
            fillKeys: ["space"],
            labelLiftFraction: 0.15
        ),
        effects: .none
    )

    static let skywardExplorer = MochiKeyboardTheme(
        id: "mochi.skyward-explorer",
        name: "Skyward Explorer",
        authorName: "Mochi",
        appearance: .dark,
        surface: ThemeSurface(
            baseFill: ThemeFill(stops: [
                    ThemeColor(hex: "#F6CB96")!,
                    ThemeColor(hex: "#BEBB88")!,
                    ThemeColor(hex: "#F8DB91")!
                ]),
            backgroundImage: ThemeBackgroundImage(
                source: .bundled(name: "themebg_skyward_explorer"),
                scalesToFill: true,
                verticalAnchor: 0.5,
                blurRadius: 0.0
            ),
            scrim: ThemeScrim(
                topColor: ThemeColor(hex: "#897D59")!.withAlpha(0.24),
                bottomColor: ThemeColor(hex: "#897D59")!.withAlpha(0.08)
            )
        ),
        keyStyles: [
            .input: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#2F1C08")!,
                    ThemeColor(hex: "#554534")!
                ]),
                labelColor: ThemeColor(hex: "#FFFFFF")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#6A5D4E")!,
                    ThemeColor(hex: "#7B6F62")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#FFFFFF")!,
                border: ThemeBorder(color: ThemeColor(hex: "#35230F")!.withAlpha(0.32), width: 1.35),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.22, radius: 3.60, offsetY: 2.60),
                topHighlight: nil,
                cornerRadiusOverride: 9.0
            ),
            .system: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#554534")!,
                    ThemeColor(hex: "#6A5D4E")!
                ]),
                labelColor: ThemeColor(hex: "#FFFFFF")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#7B6F62")!,
                    ThemeColor(hex: "#897E72")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#FFFFFF")!,
                border: ThemeBorder(color: ThemeColor(hex: "#382E23")!.withAlpha(0.32), width: 1.35),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.22, radius: 3.60, offsetY: 2.60),
                topHighlight: nil,
                cornerRadiusOverride: 9.0
            ),
            .action: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#252015")!,
                    ThemeColor(hex: "#4C483F")!
                ]),
                labelColor: ThemeColor(hex: "#FFFFFF")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#625F57")!,
                    ThemeColor(hex: "#74716A")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#FFFFFF")!,
                border: ThemeBorder(color: ThemeColor(hex: "#2B261C")!.withAlpha(0.32), width: 1.35),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.22, radius: 3.60, offsetY: 2.60),
                topHighlight: nil,
                cornerRadiusOverride: 9.0
            ),
            .space: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#2F1C08")!.withAlpha(0.50),
                    ThemeColor(hex: "#554534")!.withAlpha(0.50)
                ]),
                labelColor: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.00),
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#625445")!.withAlpha(0.50),
                    ThemeColor(hex: "#75685A")!.withAlpha(0.50)
                ]),
                border: ThemeBorder(color: ThemeColor(hex: "#C3BDB7")!.withAlpha(0.32), width: 1.35),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.22, radius: 3.60, offsetY: 2.60),
                topHighlight: nil,
                cornerRadiusOverride: 11.0
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
            assetPrefix: "keyart_ske_",
            heightFraction: 0.52,
            bottomInsetFraction: 0.10,
            opacity: 0.90,
            fillKeys: ["space"],
            labelLiftFraction: 0.15
        ),
        effects: .none
    )

    static let skywardReverie = MochiKeyboardTheme(
        id: "mochi.skyward-reverie",
        name: "Skyward Reverie",
        authorName: "Mochi",
        appearance: .dark,
        surface: ThemeSurface(
            baseFill: ThemeFill(stops: [
                    ThemeColor(hex: "#CE7B90")!,
                    ThemeColor(hex: "#7A639C")!,
                    ThemeColor(hex: "#C58DAA")!
                ]),
            backgroundImage: ThemeBackgroundImage(
                source: .bundled(name: "themebg_skyward_reverie"),
                scalesToFill: true,
                verticalAnchor: 0.5,
                blurRadius: 0.0
            ),
            scrim: ThemeScrim(
                topColor: ThemeColor(hex: "#4F3D54")!.withAlpha(0.18),
                bottomColor: ThemeColor(hex: "#4F3D54")!.withAlpha(0.05)
            )
        ),
        keyStyles: [
            .input: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#392253")!,
                    ThemeColor(hex: "#212053")!
                ]),
                labelColor: ThemeColor(hex: "#FFFFFF")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#6E5D81")!,
                    ThemeColor(hex: "#5E5E83")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#FFFFFF")!,
                border: ThemeBorder(color: ThemeColor(hex: "#CCC6D2")!.withAlpha(0.42), width: 0.95),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.15, radius: 2.20, offsetY: 1.30),
                topHighlight: ThemeColor(hex: "#C4BDCC")!.withAlpha(0.46),
                cornerRadiusOverride: 14.0,
                glass: KeyGlass(
                    bevelColor: ThemeColor(hex: "#CCC6D2")!.withAlpha(0.60),
                    bevelWidth: 0.80,
                    bevelFalloff: 0.18,
                    innerShadowColor: ThemeColor(hex: "#0A080F")!,
                    innerShadowOpacity: 0.12,
                    innerShadowRadius: 2.00
                )
            ),
            .system: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#53476E")!,
                    ThemeColor(hex: "#79708E")!
                ]),
                labelColor: ThemeColor(hex: "#FFFFFF")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#79708E")!,
                    ThemeColor(hex: "#938BA4")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#FFFFFF")!,
                border: ThemeBorder(color: ThemeColor(hex: "#D1CED8")!.withAlpha(0.42), width: 0.95),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.15, radius: 2.20, offsetY: 1.30),
                topHighlight: ThemeColor(hex: "#CAC6D2")!.withAlpha(0.46),
                cornerRadiusOverride: 14.0,
                glass: KeyGlass(
                    bevelColor: ThemeColor(hex: "#D1CED8")!.withAlpha(0.60),
                    bevelWidth: 0.80,
                    bevelFalloff: 0.18,
                    innerShadowColor: ThemeColor(hex: "#0A080F")!,
                    innerShadowOpacity: 0.12,
                    innerShadowRadius: 2.00
                )
            ),
            .action: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#372830")!,
                    ThemeColor(hex: "#6B6066")!
                ]),
                labelColor: ThemeColor(hex: "#FFFFFF")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#6B6066")!,
                    ThemeColor(hex: "#898085")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#FFFFFF")!,
                border: ThemeBorder(color: ThemeColor(hex: "#CBC7C9")!.withAlpha(0.42), width: 0.95),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.15, radius: 2.20, offsetY: 1.30),
                topHighlight: ThemeColor(hex: "#C3BEC1")!.withAlpha(0.46),
                cornerRadiusOverride: 14.0,
                glass: KeyGlass(
                    bevelColor: ThemeColor(hex: "#CBC7C9")!.withAlpha(0.60),
                    bevelWidth: 0.80,
                    bevelFalloff: 0.18,
                    innerShadowColor: ThemeColor(hex: "#0A080F")!,
                    innerShadowOpacity: 0.12,
                    innerShadowRadius: 2.00
                )
            ),
            .space: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#392253")!.withAlpha(0.50),
                    ThemeColor(hex: "#212053")!.withAlpha(0.50)
                ]),
                labelColor: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.00),
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#66547A")!.withAlpha(0.50),
                    ThemeColor(hex: "#56557C")!.withAlpha(0.50)
                ]),
                border: ThemeBorder(color: ThemeColor(hex: "#C4BDCC")!.withAlpha(0.42), width: 0.95),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.15, radius: 2.20, offsetY: 1.30),
                topHighlight: ThemeColor(hex: "#C4BDCC")!.withAlpha(0.46),
                cornerRadiusOverride: 16.0
            )
        ],
        typography: ThemeTypography(fontFamily: nil, weightRawValue: 0.34, sizeMultiplier: 1.0),
        chrome: ThemeChrome(
            inkColor: ThemeColor(hex: "#FCFAFF")!,
            mutedInkColor: ThemeColor(hex: "#FCFAFF")!.withAlpha(0.55),
            panelFill: ThemeFill(stops: [
                    ThemeColor(hex: "#63517E")!.withAlpha(0.55)
                ]),
            highlightFill: ThemeFill(stops: [
                    ThemeColor(hex: "#FFFFFF")!.withAlpha(0.16)
                ])
        ),
        keyArt: KeyArtSet(
            assetPrefix: "keyart_skr_",
            heightFraction: 0.48,
            bottomInsetFraction: 0.09,
            opacity: 0.90,
            fillKeys: ["space"],
            labelLiftFraction: 0.14
        ),
        effects: .none
    )

    static let starlitOrbit = MochiKeyboardTheme(
        id: "mochi.starlit-orbit",
        name: "Starlit Orbit",
        authorName: "Mochi",
        appearance: .light,
        surface: ThemeSurface(
            baseFill: ThemeFill(stops: [
                    ThemeColor(hex: "#375685")!,
                    ThemeColor(hex: "#998AA7")!,
                    ThemeColor(hex: "#504765")!
                ]),
            backgroundImage: ThemeBackgroundImage(
                source: .bundled(name: "themebg_starlit_orbit"),
                scalesToFill: true,
                verticalAnchor: 0.5,
                blurRadius: 0.0
            ),
            scrim: ThemeScrim(
                topColor: ThemeColor(hex: "#5C505A")!.withAlpha(0.27),
                bottomColor: ThemeColor(hex: "#5C505A")!.withAlpha(0.17)
            )
        ),
        keyStyles: [
            .input: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#FCF2ED")!.withAlpha(0.73),
                    ThemeColor(hex: "#F5ECE7")!.withAlpha(0.73)
                ]),
                labelColor: ThemeColor(hex: "#221C28")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#F0E7E2")!.withAlpha(0.85),
                    ThemeColor(hex: "#EAE0DC")!.withAlpha(0.85)
                ]),
                pressedLabelColor: ThemeColor(hex: "#221C28")!,
                border: ThemeBorder(color: ThemeColor(hex: "#FEFCFB")!.withAlpha(0.58), width: 1.20),
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
                    ThemeColor(hex: "#F4EAE6")!.withAlpha(0.79),
                    ThemeColor(hex: "#EEE4DF")!.withAlpha(0.79)
                ]),
                labelColor: ThemeColor(hex: "#221C28")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#E8DFDA")!.withAlpha(0.91),
                    ThemeColor(hex: "#E1D8D4")!.withAlpha(0.91)
                ]),
                pressedLabelColor: ThemeColor(hex: "#221C28")!,
                border: ThemeBorder(color: ThemeColor(hex: "#FEFDFC")!.withAlpha(0.58), width: 1.20),
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
                    ThemeColor(hex: "#F9F2EF")!.withAlpha(0.79),
                    ThemeColor(hex: "#F3ECE9")!.withAlpha(0.79)
                ]),
                labelColor: ThemeColor(hex: "#221C28")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#EEE7E4")!.withAlpha(0.91),
                    ThemeColor(hex: "#E7E1DD")!.withAlpha(0.91)
                ]),
                pressedLabelColor: ThemeColor(hex: "#221C28")!,
                border: ThemeBorder(color: ThemeColor(hex: "#FEFCFC")!.withAlpha(0.58), width: 1.20),
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
                    ThemeColor(hex: "#FCF2ED")!.withAlpha(0.42),
                    ThemeColor(hex: "#F5ECE7")!.withAlpha(0.42)
                ]),
                labelColor: ThemeColor(hex: "#221C28")!.withAlpha(0.00),
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#F2E8E3")!.withAlpha(0.42),
                    ThemeColor(hex: "#EBE2DD")!.withAlpha(0.42)
                ]),
                border: ThemeBorder(color: ThemeColor(hex: "#FEFCFB")!.withAlpha(0.58), width: 1.20),
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
                    ThemeColor(hex: "#5E556E")!.withAlpha(0.55)
                ]),
            highlightFill: ThemeFill(stops: [
                    ThemeColor(hex: "#FFFFFF")!.withAlpha(0.16)
                ])
        ),
        keyArt: KeyArtSet(
            assetPrefix: "keyart_sto_",
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
            tint: ThemeColor(hex: "#E6D8FF")!
        )
    )

    static let wanderlightLoft = MochiKeyboardTheme(
        id: "mochi.wanderlight-loft",
        name: "Wanderlight Loft",
        authorName: "Mochi",
        appearance: .dark,
        surface: ThemeSurface(
            baseFill: ThemeFill(stops: [
                    ThemeColor(hex: "#966D8D")!,
                    ThemeColor(hex: "#C59EAB")!,
                    ThemeColor(hex: "#602D1C")!
                ]),
            backgroundImage: ThemeBackgroundImage(
                source: .bundled(name: "themebg_wanderlight_loft"),
                scalesToFill: true,
                verticalAnchor: 0.5,
                blurRadius: 0.0
            ),
            scrim: ThemeScrim(
                topColor: ThemeColor(hex: "#997571")!.withAlpha(0.39),
                bottomColor: ThemeColor(hex: "#997571")!.withAlpha(0.18)
            )
        ),
        keyStyles: [
            .input: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#47220F")!,
                    ThemeColor(hex: "#664637")!
                ]),
                labelColor: ThemeColor(hex: "#FFFFFF")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#795D50")!,
                    ThemeColor(hex: "#886F63")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#FFFFFF")!,
                border: ThemeBorder(color: ThemeColor(hex: "#3F1E0D")!.withAlpha(0.32), width: 1.35),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.22, radius: 3.60, offsetY: 2.60),
                topHighlight: nil,
                cornerRadiusOverride: 9.0
            ),
            .system: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#664637")!,
                    ThemeColor(hex: "#795D50")!
                ]),
                labelColor: ThemeColor(hex: "#FFFFFF")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#886F63")!,
                    ThemeColor(hex: "#947E73")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#FFFFFF")!,
                border: ThemeBorder(color: ThemeColor(hex: "#442F25")!.withAlpha(0.32), width: 1.35),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.22, radius: 3.60, offsetY: 2.60),
                topHighlight: nil,
                cornerRadiusOverride: 9.0
            ),
            .action: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#382921")!,
                    ThemeColor(hex: "#584B45")!
                ]),
                labelColor: ThemeColor(hex: "#FFFFFF")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#6C615B")!,
                    ThemeColor(hex: "#7C726D")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#FFFFFF")!,
                border: ThemeBorder(color: ThemeColor(hex: "#31241D")!.withAlpha(0.32), width: 1.35),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.22, radius: 3.60, offsetY: 2.60),
                topHighlight: nil,
                cornerRadiusOverride: 9.0
            ),
            .space: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#47220F")!.withAlpha(0.50),
                    ThemeColor(hex: "#664637")!.withAlpha(0.50)
                ]),
                labelColor: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.00),
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#725547")!.withAlpha(0.50),
                    ThemeColor(hex: "#82685C")!.withAlpha(0.50)
                ]),
                border: ThemeBorder(color: ThemeColor(hex: "#C9BEB8")!.withAlpha(0.32), width: 1.35),
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
                    ThemeColor(hex: "#7A4E41")!.withAlpha(0.55)
                ]),
            highlightFill: ThemeFill(stops: [
                    ThemeColor(hex: "#FFFFFF")!.withAlpha(0.16)
                ])
        ),
        keyArt: KeyArtSet(
            assetPrefix: "keyart_wnl_",
            heightFraction: 0.52,
            bottomInsetFraction: 0.10,
            opacity: 0.90,
            fillKeys: ["space"],
            labelLiftFraction: 0.15
        ),
        effects: .none
    )
}
