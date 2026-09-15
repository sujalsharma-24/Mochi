import Foundation

// Batch 5 -- 19 additional built-in themes, ingested from ~/Downloads/THH. Same asset
// pipeline as batch 3/4 (background plate + per-key illustrations), authored on the 7-material
// system. Cap luminance is solved by bisecting real contrast against the plate's own post-scrim
// 5th/95th-percentile luminance (see `derive_cap` in scratchpad/gen_b56.py) rather than a fixed
// offset, so caps in this batch separate from their backdrop instead of matching it.

extension BuiltInThemes {

    static let batch5: [MochiKeyboardTheme] = [
        botanicalWorkshop, candyBakery, cosmicAstronaut, cozyCat, cozyNightKeyboard, cozyTerrarium, dreamyGarden, kawaiiCosmicStudy, kawaiiOceanNight, neonRacingGarage, pastelLakesideCarnival, pastelUnderwater, prehistoricFossilExplorer, retroArcade, sakuraNightKawaiiLandscape, seasidePostcard, sunsetMusicStudio, whimsicalWorld, witchyPotionShop
    ]

    static let botanicalWorkshop = MochiKeyboardTheme(
        id: "mochi.botanical-workshop",
        name: "Botanical Workshop",
        authorName: "Mochi",
        appearance: .dark,
        surface: ThemeSurface(
            baseFill: ThemeFill(stops: [
                    ThemeColor(hex: "#DFA172")!,
                    ThemeColor(hex: "#D1CA96")!,
                    ThemeColor(hex: "#C09779")!
                ]),
            backgroundImage: ThemeBackgroundImage(
                source: .bundled(name: "themebg_botanical_workshop"),
                scalesToFill: true,
                verticalAnchor: 0.5,
                blurRadius: 0.0
            ),
            scrim: ThemeScrim(
                topColor: ThemeColor(hex: "#988C63")!.withAlpha(0.20),
                bottomColor: ThemeColor(hex: "#988C63")!.withAlpha(0.06)
            )
        ),
        keyStyles: [
            .input: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#372A0E")!,
                    ThemeColor(hex: "#584C35")!
                ]),
                labelColor: ThemeColor(hex: "#FFFFFF")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#6C624E")!,
                    ThemeColor(hex: "#7C7361")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#FFFFFF")!,
                border: ThemeBorder(color: ThemeColor(hex: "#31250C")!.withAlpha(0.32), width: 1.35),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.22, radius: 3.60, offsetY: 2.60),
                topHighlight: nil,
                cornerRadiusOverride: 9.0
            ),
            .system: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#584C35")!,
                    ThemeColor(hex: "#6C624E")!
                ]),
                labelColor: ThemeColor(hex: "#FFFFFF")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#7C7361")!,
                    ThemeColor(hex: "#8A8271")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#FFFFFF")!,
                border: ThemeBorder(color: ThemeColor(hex: "#3A3323")!.withAlpha(0.32), width: 1.35),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.22, radius: 3.60, offsetY: 2.60),
                topHighlight: nil,
                cornerRadiusOverride: 9.0
            ),
            .action: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#312B1E")!,
                    ThemeColor(hex: "#524D42")!
                ]),
                labelColor: ThemeColor(hex: "#FFFFFF")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#676359")!,
                    ThemeColor(hex: "#78746B")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#FFFFFF")!,
                border: ThemeBorder(color: ThemeColor(hex: "#2B261B")!.withAlpha(0.32), width: 1.35),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.22, radius: 3.60, offsetY: 2.60),
                topHighlight: nil,
                cornerRadiusOverride: 9.0
            ),
            .space: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#372A0E")!.withAlpha(0.50),
                    ThemeColor(hex: "#584C35")!.withAlpha(0.50)
                ]),
                labelColor: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.00),
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#655A44")!.withAlpha(0.50),
                    ThemeColor(hex: "#766D5A")!.withAlpha(0.50)
                ]),
                border: ThemeBorder(color: ThemeColor(hex: "#C3BFB7")!.withAlpha(0.32), width: 1.35),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.22, radius: 3.60, offsetY: 2.60),
                topHighlight: nil,
                cornerRadiusOverride: 11.0
            )
        ],
        typography: ThemeTypography(fontFamily: nil, weightRawValue: 0.34, sizeMultiplier: 1.0),
        chrome: ThemeChrome(
            inkColor: ThemeColor(hex: "#1D1822")!,
            mutedInkColor: ThemeColor(hex: "#1D1822")!.withAlpha(0.55),
            panelFill: ThemeFill(stops: [
                    ThemeColor(hex: "#FDFBFA")!.withAlpha(0.55)
                ]),
            highlightFill: ThemeFill(stops: [
                    ThemeColor(hex: "#000000")!.withAlpha(0.16)
                ])
        ),
        keyArt: KeyArtSet(
            assetPrefix: "keyart_btw_",
            heightFraction: 0.52,
            bottomInsetFraction: 0.10,
            opacity: 0.90,
            fillKeys: ["space"],
            labelLiftFraction: 0.15
        ),
        effects: .none
    )

    static let candyBakery = MochiKeyboardTheme(
        id: "mochi.candy-bakery",
        name: "Candy Bakery",
        authorName: "Mochi",
        appearance: .light,
        surface: ThemeSurface(
            baseFill: ThemeFill(stops: [
                    ThemeColor(hex: "#BAA1A7")!,
                    ThemeColor(hex: "#DFA997")!,
                    ThemeColor(hex: "#FACFB4")!
                ]),
            backgroundImage: ThemeBackgroundImage(
                source: .bundled(name: "themebg_candy_bakery"),
                scalesToFill: true,
                verticalAnchor: 0.5,
                blurRadius: 0.0
            ),
            scrim: ThemeScrim(
                topColor: ThemeColor(hex: "#806257")!.withAlpha(0.18),
                bottomColor: ThemeColor(hex: "#806257")!.withAlpha(0.05)
            )
        ),
        keyStyles: [
            .input: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#FFF1E8")!,
                    ThemeColor(hex: "#F7EAE1")!
                ]),
                labelColor: ThemeColor(hex: "#221C28")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#F3E6DE")!,
                    ThemeColor(hex: "#EBDED6")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#221C28")!,
                border: ThemeBorder(color: ThemeColor(hex: "#B3A9A3")!.withAlpha(0.40), width: 1.15),
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
                    ThemeColor(hex: "#F7EAE1")!,
                    ThemeColor(hex: "#EFE2DA")!
                ]),
                labelColor: ThemeColor(hex: "#221C28")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#EBDED6")!,
                    ThemeColor(hex: "#E3D6CE")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#221C28")!,
                border: ThemeBorder(color: ThemeColor(hex: "#ADA49E")!.withAlpha(0.40), width: 1.15),
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
                    ThemeColor(hex: "#FDF1EA")!,
                    ThemeColor(hex: "#F6EAE3")!
                ]),
                labelColor: ThemeColor(hex: "#221C28")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#F2E6DF")!,
                    ThemeColor(hex: "#EADFD8")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#221C28")!,
                border: ThemeBorder(color: ThemeColor(hex: "#B1A9A4")!.withAlpha(0.40), width: 1.15),
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
                    ThemeColor(hex: "#FFF1E8")!.withAlpha(0.42),
                    ThemeColor(hex: "#F7EAE1")!.withAlpha(0.42)
                ]),
                labelColor: ThemeColor(hex: "#221C28")!.withAlpha(0.00),
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#F5E7DF")!.withAlpha(0.42),
                    ThemeColor(hex: "#EDE0D7")!.withAlpha(0.42)
                ]),
                border: ThemeBorder(color: ThemeColor(hex: "#FFFCFB")!.withAlpha(0.40), width: 1.15),
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
                    ThemeColor(hex: "#FCFBFC")!.withAlpha(0.55)
                ]),
            highlightFill: ThemeFill(stops: [
                    ThemeColor(hex: "#000000")!.withAlpha(0.16)
                ])
        ),
        keyArt: KeyArtSet(
            assetPrefix: "keyart_cdb_",
            heightFraction: 0.50,
            bottomInsetFraction: 0.10,
            opacity: 0.90,
            fillKeys: ["space"],
            labelLiftFraction: 0.15
        ),
        effects: .none
    )

    static let cosmicAstronaut = MochiKeyboardTheme(
        id: "mochi.cosmic-astronaut",
        name: "Cosmic Astronaut",
        authorName: "Mochi",
        appearance: .dark,
        surface: ThemeSurface(
            baseFill: ThemeFill(stops: [
                    ThemeColor(hex: "#3A4F94")!,
                    ThemeColor(hex: "#959FC1")!,
                    ThemeColor(hex: "#584853")!
                ]),
            backgroundImage: ThemeBackgroundImage(
                source: .bundled(name: "themebg_cosmic_astronaut"),
                scalesToFill: true,
                verticalAnchor: 0.5,
                blurRadius: 0.0
            ),
            scrim: ThemeScrim(
                topColor: ThemeColor(hex: "#5B5A66")!.withAlpha(0.22),
                bottomColor: ThemeColor(hex: "#5B5A66")!.withAlpha(0.07)
            )
        ),
        keyStyles: [
            .input: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#242252")!,
                    ThemeColor(hex: "#18273D")!
                ]),
                labelColor: ThemeColor(hex: "#FFFFFF")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#605E81")!,
                    ThemeColor(hex: "#576272")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#FFFFFF")!,
                border: ThemeBorder(color: ThemeColor(hex: "#C7C6D2")!.withAlpha(0.42), width: 0.95),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.15, radius: 2.20, offsetY: 1.30),
                topHighlight: ThemeColor(hex: "#BFBECC")!.withAlpha(0.46),
                cornerRadiusOverride: 14.0,
                glass: KeyGlass(
                    bevelColor: ThemeColor(hex: "#C7C6D2")!.withAlpha(0.60),
                    bevelWidth: 0.80,
                    bevelFalloff: 0.18,
                    innerShadowColor: ThemeColor(hex: "#0A080F")!,
                    innerShadowOpacity: 0.12,
                    innerShadowRadius: 2.00
                )
            ),
            .system: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#474B6D")!,
                    ThemeColor(hex: "#6F728D")!
                ]),
                labelColor: ThemeColor(hex: "#FFFFFF")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#6F728D")!,
                    ThemeColor(hex: "#8B8EA3")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#FFFFFF")!,
                border: ThemeBorder(color: ThemeColor(hex: "#CDCFD8")!.withAlpha(0.42), width: 0.95),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.15, radius: 2.20, offsetY: 1.30),
                topHighlight: ThemeColor(hex: "#C6C7D2")!.withAlpha(0.46),
                cornerRadiusOverride: 14.0,
                glass: KeyGlass(
                    bevelColor: ThemeColor(hex: "#CDCFD8")!.withAlpha(0.60),
                    bevelWidth: 0.80,
                    bevelFalloff: 0.18,
                    innerShadowColor: ThemeColor(hex: "#0A080F")!,
                    innerShadowOpacity: 0.12,
                    innerShadowRadius: 2.00
                )
            ),
            .action: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#2D2A2F")!,
                    ThemeColor(hex: "#646266")!
                ]),
                labelColor: ThemeColor(hex: "#FFFFFF")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#646266")!,
                    ThemeColor(hex: "#838285")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#FFFFFF")!,
                border: ThemeBorder(color: ThemeColor(hex: "#C8C7C9")!.withAlpha(0.42), width: 0.95),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.15, radius: 2.20, offsetY: 1.30),
                topHighlight: ThemeColor(hex: "#C0BFC1")!.withAlpha(0.46),
                cornerRadiusOverride: 14.0,
                glass: KeyGlass(
                    bevelColor: ThemeColor(hex: "#C8C7C9")!.withAlpha(0.60),
                    bevelWidth: 0.80,
                    bevelFalloff: 0.18,
                    innerShadowColor: ThemeColor(hex: "#0A080F")!,
                    innerShadowOpacity: 0.12,
                    innerShadowRadius: 2.00
                )
            ),
            .space: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#242252")!.withAlpha(0.50),
                    ThemeColor(hex: "#18273D")!.withAlpha(0.50)
                ]),
                labelColor: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.00),
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#58567B")!.withAlpha(0.50),
                    ThemeColor(hex: "#4E5A6B")!.withAlpha(0.50)
                ]),
                border: ThemeBorder(color: ThemeColor(hex: "#BFBECC")!.withAlpha(0.42), width: 0.95),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.15, radius: 2.20, offsetY: 1.30),
                topHighlight: ThemeColor(hex: "#BFBECC")!.withAlpha(0.46),
                cornerRadiusOverride: 16.0
            )
        ],
        typography: ThemeTypography(fontFamily: nil, weightRawValue: 0.34, sizeMultiplier: 1.0),
        chrome: ThemeChrome(
            inkColor: ThemeColor(hex: "#F2ECF0")!,
            mutedInkColor: ThemeColor(hex: "#F2ECF0")!.withAlpha(0.55),
            panelFill: ThemeFill(stops: [
                    ThemeColor(hex: "#63555F")!.withAlpha(0.55)
                ]),
            highlightFill: ThemeFill(stops: [
                    ThemeColor(hex: "#FFFFFF")!.withAlpha(0.16)
                ])
        ),
        keyArt: KeyArtSet(
            assetPrefix: "keyart_csa_",
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
            tint: ThemeColor(hex: "#B7C6FF")!
        )
    )

    static let cozyCat = MochiKeyboardTheme(
        id: "mochi.cozy-cat",
        name: "Cozy Cat",
        authorName: "Mochi",
        appearance: .dark,
        surface: ThemeSurface(
            baseFill: ThemeFill(stops: [
                    ThemeColor(hex: "#754C65")!,
                    ThemeColor(hex: "#C49C9D")!,
                    ThemeColor(hex: "#F8B672")!
                ]),
            backgroundImage: ThemeBackgroundImage(
                source: .bundled(name: "themebg_cozy_cat"),
                scalesToFill: true,
                verticalAnchor: 0.5,
                blurRadius: 0.0
            ),
            scrim: ThemeScrim(
                topColor: ThemeColor(hex: "#95736A")!.withAlpha(0.19),
                bottomColor: ThemeColor(hex: "#95736A")!.withAlpha(0.05)
            )
        ),
        keyStyles: [
            .input: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#432415")!,
                    ThemeColor(hex: "#62483B")!
                ]),
                labelColor: ThemeColor(hex: "#FFFFFF")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#755E54")!,
                    ThemeColor(hex: "#847066")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#FFFFFF")!,
                border: ThemeBorder(color: ThemeColor(hex: "#3B2013")!.withAlpha(0.32), width: 1.35),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.22, radius: 3.60, offsetY: 2.60),
                topHighlight: nil,
                cornerRadiusOverride: 9.0
            ),
            .system: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#62483B")!,
                    ThemeColor(hex: "#755E54")!
                ]),
                labelColor: ThemeColor(hex: "#FFFFFF")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#847066")!,
                    ThemeColor(hex: "#917F76")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#FFFFFF")!,
                border: ThemeBorder(color: ThemeColor(hex: "#413028")!.withAlpha(0.32), width: 1.35),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.22, radius: 3.60, offsetY: 2.60),
                topHighlight: nil,
                cornerRadiusOverride: 9.0
            ),
            .action: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#362922")!,
                    ThemeColor(hex: "#564B45")!
                ]),
                labelColor: ThemeColor(hex: "#FFFFFF")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#6B615C")!,
                    ThemeColor(hex: "#7B736E")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#FFFFFF")!,
                border: ThemeBorder(color: ThemeColor(hex: "#2F241E")!.withAlpha(0.32), width: 1.35),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.22, radius: 3.60, offsetY: 2.60),
                topHighlight: nil,
                cornerRadiusOverride: 9.0
            ),
            .space: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#432415")!.withAlpha(0.50),
                    ThemeColor(hex: "#62483B")!.withAlpha(0.50)
                ]),
                labelColor: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.00),
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#6E564B")!.withAlpha(0.50),
                    ThemeColor(hex: "#7E695F")!.withAlpha(0.50)
                ]),
                border: ThemeBorder(color: ThemeColor(hex: "#C7BEBA")!.withAlpha(0.32), width: 1.35),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.22, radius: 3.60, offsetY: 2.60),
                topHighlight: nil,
                cornerRadiusOverride: 11.0
            )
        ],
        typography: ThemeTypography(fontFamily: nil, weightRawValue: 0.34, sizeMultiplier: 1.0),
        chrome: ThemeChrome(
            inkColor: ThemeColor(hex: "#FAF8FA")!,
            mutedInkColor: ThemeColor(hex: "#FAF8FA")!.withAlpha(0.55),
            panelFill: ThemeFill(stops: [
                    ThemeColor(hex: "#754D64")!.withAlpha(0.55)
                ]),
            highlightFill: ThemeFill(stops: [
                    ThemeColor(hex: "#FFFFFF")!.withAlpha(0.16)
                ])
        ),
        keyArt: KeyArtSet(
            assetPrefix: "keyart_czc_",
            heightFraction: 0.52,
            bottomInsetFraction: 0.10,
            opacity: 0.90,
            fillKeys: ["space"],
            labelLiftFraction: 0.15
        ),
        effects: .none
    )

    static let cozyNightKeyboard = MochiKeyboardTheme(
        id: "mochi.cozy-night-keyboard",
        name: "Cozy Night Keyboard",
        authorName: "Mochi",
        appearance: .dark,
        surface: ThemeSurface(
            baseFill: ThemeFill(stops: [
                    ThemeColor(hex: "#5E3848")!,
                    ThemeColor(hex: "#A5818F")!,
                    ThemeColor(hex: "#BA7072")!
                ]),
            backgroundImage: ThemeBackgroundImage(
                source: .bundled(name: "themebg_cozy_night_keyboard"),
                scalesToFill: true,
                verticalAnchor: 0.5,
                blurRadius: 0.0
            ),
            scrim: ThemeScrim(
                topColor: ThemeColor(hex: "#806163")!.withAlpha(0.21),
                bottomColor: ThemeColor(hex: "#806163")!.withAlpha(0.07)
            )
        ),
        keyStyles: [
            .input: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#421C2A")!,
                    ThemeColor(hex: "#55333F")!
                ]),
                labelColor: ThemeColor(hex: "#FFFFFF")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#765B64")!,
                    ThemeColor(hex: "#7E646D")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#FFFFFF")!,
                border: ThemeBorder(color: ThemeColor(hex: "#CFC5C8")!.withAlpha(0.60), width: 1.00),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.32, radius: 2.60, offsetY: 1.60),
                topHighlight: ThemeColor(hex: "#C8BCC0")!.withAlpha(0.28),
                cornerRadiusOverride: 12.0,
                glass: KeyGlass(
                    bevelColor: ThemeColor(hex: "#CFC5C8")!.withAlpha(0.62),
                    bevelWidth: 1.00,
                    bevelFalloff: 0.12,
                    innerShadowColor: ThemeColor(hex: "#0A080F")!,
                    innerShadowOpacity: 0.36,
                    innerShadowRadius: 3.00
                )
            ),
            .system: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#62434E")!,
                    ThemeColor(hex: "#6D505A")!
                ]),
                labelColor: ThemeColor(hex: "#FFFFFF")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#856D75")!,
                    ThemeColor(hex: "#8C757D")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#FFFFFF")!,
                border: ThemeBorder(color: ThemeColor(hex: "#D5CDD0")!.withAlpha(0.60), width: 1.00),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.32, radius: 2.60, offsetY: 1.60),
                topHighlight: ThemeColor(hex: "#CFC5C8")!.withAlpha(0.28),
                cornerRadiusOverride: 12.0,
                glass: KeyGlass(
                    bevelColor: ThemeColor(hex: "#D5CDD0")!.withAlpha(0.62),
                    bevelWidth: 1.00,
                    bevelFalloff: 0.12,
                    innerShadowColor: ThemeColor(hex: "#0A080F")!,
                    innerShadowOpacity: 0.36,
                    innerShadowRadius: 3.00
                )
            ),
            .action: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#342523")!,
                    ThemeColor(hex: "#483A38")!
                ]),
                labelColor: ThemeColor(hex: "#FFFFFF")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#6B5F5E")!,
                    ThemeColor(hex: "#736967")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#FFFFFF")!,
                border: ThemeBorder(color: ThemeColor(hex: "#CAC6C6")!.withAlpha(0.60), width: 1.00),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.32, radius: 2.60, offsetY: 1.60),
                topHighlight: ThemeColor(hex: "#C3BEBE")!.withAlpha(0.28),
                cornerRadiusOverride: 12.0,
                glass: KeyGlass(
                    bevelColor: ThemeColor(hex: "#CAC6C6")!.withAlpha(0.62),
                    bevelWidth: 1.00,
                    bevelFalloff: 0.12,
                    innerShadowColor: ThemeColor(hex: "#0A080F")!,
                    innerShadowOpacity: 0.36,
                    innerShadowRadius: 3.00
                )
            ),
            .space: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#421C2A")!.withAlpha(0.50),
                    ThemeColor(hex: "#55333F")!.withAlpha(0.50)
                ]),
                labelColor: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.00),
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#6F525C")!.withAlpha(0.50),
                    ThemeColor(hex: "#785D66")!.withAlpha(0.50)
                ]),
                border: ThemeBorder(color: ThemeColor(hex: "#C8BCC0")!.withAlpha(0.60), width: 1.00),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.32, radius: 2.60, offsetY: 1.60),
                topHighlight: ThemeColor(hex: "#C8BCC0")!.withAlpha(0.28),
                cornerRadiusOverride: 14.0
            )
        ],
        typography: ThemeTypography(fontFamily: nil, weightRawValue: 0.34, sizeMultiplier: 1.0),
        chrome: ThemeChrome(
            inkColor: ThemeColor(hex: "#F2ECF0")!,
            mutedInkColor: ThemeColor(hex: "#F2ECF0")!.withAlpha(0.55),
            panelFill: ThemeFill(stops: [
                    ThemeColor(hex: "#71505D")!.withAlpha(0.55)
                ]),
            highlightFill: ThemeFill(stops: [
                    ThemeColor(hex: "#FFFFFF")!.withAlpha(0.16)
                ])
        ),
        keyArt: KeyArtSet(
            assetPrefix: "keyart_cnk_",
            heightFraction: 0.44,
            bottomInsetFraction: 0.09,
            opacity: 0.90,
            fillKeys: ["space"],
            labelLiftFraction: 0.14
        ),
        effects: .none
    )

    static let cozyTerrarium = MochiKeyboardTheme(
        id: "mochi.cozy-terrarium",
        name: "Cozy Terrarium",
        authorName: "Mochi",
        appearance: .light,
        surface: ThemeSurface(
            baseFill: ThemeFill(stops: [
                    ThemeColor(hex: "#2F361C")!,
                    ThemeColor(hex: "#CDBE87")!,
                    ThemeColor(hex: "#987841")!
                ]),
            backgroundImage: ThemeBackgroundImage(
                source: .bundled(name: "themebg_cozy_terrarium"),
                scalesToFill: true,
                verticalAnchor: 0.5,
                blurRadius: 0.0
            ),
            scrim: ThemeScrim(
                topColor: ThemeColor(hex: "#716549")!.withAlpha(0.27),
                bottomColor: ThemeColor(hex: "#716549")!.withAlpha(0.17)
            )
        ),
        keyStyles: [
            .input: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#FFF2DA")!.withAlpha(0.73),
                    ThemeColor(hex: "#F8ECD4")!.withAlpha(0.73)
                ]),
                labelColor: ThemeColor(hex: "#221C28")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#F3E7D0")!.withAlpha(0.85),
                    ThemeColor(hex: "#ECE1CA")!.withAlpha(0.85)
                ]),
                pressedLabelColor: ThemeColor(hex: "#221C28")!,
                border: ThemeBorder(color: ThemeColor(hex: "#FFFDF8")!.withAlpha(0.58), width: 1.20),
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
                    ThemeColor(hex: "#F7EBD3")!.withAlpha(0.79),
                    ThemeColor(hex: "#F0E5CE")!.withAlpha(0.79)
                ]),
                labelColor: ThemeColor(hex: "#221C28")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#EBE0C9")!.withAlpha(0.91),
                    ThemeColor(hex: "#E4D9C3")!.withAlpha(0.91)
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
            .action: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#FAF3E4")!.withAlpha(0.79),
                    ThemeColor(hex: "#F4EDDE")!.withAlpha(0.79)
                ]),
                labelColor: ThemeColor(hex: "#221C28")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#EFE8D9")!.withAlpha(0.91),
                    ThemeColor(hex: "#E8E1D3")!.withAlpha(0.91)
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
            .space: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#FFF2DA")!.withAlpha(0.42),
                    ThemeColor(hex: "#F8ECD4")!.withAlpha(0.42)
                ]),
                labelColor: ThemeColor(hex: "#221C28")!.withAlpha(0.00),
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#F4E9D1")!.withAlpha(0.42),
                    ThemeColor(hex: "#EEE2CB")!.withAlpha(0.42)
                ]),
                border: ThemeBorder(color: ThemeColor(hex: "#FFFDF8")!.withAlpha(0.58), width: 1.20),
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
                    ThemeColor(hex: "#585B45")!.withAlpha(0.55)
                ]),
            highlightFill: ThemeFill(stops: [
                    ThemeColor(hex: "#FFFFFF")!.withAlpha(0.16)
                ])
        ),
        keyArt: KeyArtSet(
            assetPrefix: "keyart_czt_",
            heightFraction: 0.46,
            bottomInsetFraction: 0.09,
            opacity: 0.90,
            fillKeys: ["space"],
            labelLiftFraction: 0.14
        ),
        effects: .none
    )

    static let dreamyGarden = MochiKeyboardTheme(
        id: "mochi.dreamy-garden",
        name: "Dreamy Garden",
        authorName: "Mochi",
        appearance: .dark,
        surface: ThemeSurface(
            baseFill: ThemeFill(stops: [
                    ThemeColor(hex: "#876C59")!,
                    ThemeColor(hex: "#C8BC84")!,
                    ThemeColor(hex: "#A4653E")!
                ]),
            backgroundImage: ThemeBackgroundImage(
                source: .bundled(name: "themebg_dreamy_garden"),
                scalesToFill: true,
                verticalAnchor: 0.5,
                blurRadius: 0.0
            ),
            scrim: ThemeScrim(
                topColor: ThemeColor(hex: "#6A5F43")!.withAlpha(0.21),
                bottomColor: ThemeColor(hex: "#6A5F43")!.withAlpha(0.07)
            )
        ),
        keyStyles: [
            .input: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#34280D")!,
                    ThemeColor(hex: "#3D1F16")!
                ]),
                labelColor: ThemeColor(hex: "#FFFFFF")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#6A614E")!,
                    ThemeColor(hex: "#725C56")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#FFFFFF")!,
                border: ThemeBorder(color: ThemeColor(hex: "#CAC7C0")!.withAlpha(0.42), width: 0.95),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.15, radius: 2.20, offsetY: 1.30),
                topHighlight: ThemeColor(hex: "#C3BFB7")!.withAlpha(0.46),
                cornerRadiusOverride: 14.0,
                glass: KeyGlass(
                    bevelColor: ThemeColor(hex: "#CAC7C0")!.withAlpha(0.60),
                    bevelWidth: 0.80,
                    bevelFalloff: 0.18,
                    innerShadowColor: ThemeColor(hex: "#0A080F")!,
                    innerShadowOpacity: 0.12,
                    innerShadowRadius: 2.00
                )
            ),
            .system: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#564837")!,
                    ThemeColor(hex: "#7B7064")!
                ]),
                labelColor: ThemeColor(hex: "#FFFFFF")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#7B7064")!,
                    ThemeColor(hex: "#958C82")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#FFFFFF")!,
                border: ThemeBorder(color: ThemeColor(hex: "#D1CEC9")!.withAlpha(0.42), width: 0.95),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.15, radius: 2.20, offsetY: 1.30),
                topHighlight: ThemeColor(hex: "#CAC6C1")!.withAlpha(0.46),
                cornerRadiusOverride: 14.0,
                glass: KeyGlass(
                    bevelColor: ThemeColor(hex: "#D1CEC9")!.withAlpha(0.60),
                    bevelWidth: 0.80,
                    bevelFalloff: 0.18,
                    innerShadowColor: ThemeColor(hex: "#0A080F")!,
                    innerShadowOpacity: 0.12,
                    innerShadowRadius: 2.00
                )
            ),
            .action: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#2A2419")!,
                    ThemeColor(hex: "#656058")!
                ]),
                labelColor: ThemeColor(hex: "#FFFFFF")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#656058")!,
                    ThemeColor(hex: "#84807A")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#FFFFFF")!,
                border: ThemeBorder(color: ThemeColor(hex: "#C8C6C4")!.withAlpha(0.42), width: 0.95),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.15, radius: 2.20, offsetY: 1.30),
                topHighlight: ThemeColor(hex: "#C0BEBB")!.withAlpha(0.46),
                cornerRadiusOverride: 14.0,
                glass: KeyGlass(
                    bevelColor: ThemeColor(hex: "#C8C6C4")!.withAlpha(0.60),
                    bevelWidth: 0.80,
                    bevelFalloff: 0.18,
                    innerShadowColor: ThemeColor(hex: "#0A080F")!,
                    innerShadowOpacity: 0.12,
                    innerShadowRadius: 2.00
                )
            ),
            .space: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#34280D")!.withAlpha(0.50),
                    ThemeColor(hex: "#3D1F16")!.withAlpha(0.50)
                ]),
                labelColor: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.00),
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#625945")!.withAlpha(0.50),
                    ThemeColor(hex: "#6B544D")!.withAlpha(0.50)
                ]),
                border: ThemeBorder(color: ThemeColor(hex: "#C3BFB7")!.withAlpha(0.42), width: 0.95),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.15, radius: 2.20, offsetY: 1.30),
                topHighlight: ThemeColor(hex: "#C3BFB7")!.withAlpha(0.46),
                cornerRadiusOverride: 16.0
            )
        ],
        typography: ThemeTypography(fontFamily: nil, weightRawValue: 0.34, sizeMultiplier: 1.0),
        chrome: ThemeChrome(
            inkColor: ThemeColor(hex: "#FCFAFF")!,
            mutedInkColor: ThemeColor(hex: "#FCFAFF")!.withAlpha(0.55),
            panelFill: ThemeFill(stops: [
                    ThemeColor(hex: "#6A5546")!.withAlpha(0.55)
                ]),
            highlightFill: ThemeFill(stops: [
                    ThemeColor(hex: "#FFFFFF")!.withAlpha(0.16)
                ])
        ),
        keyArt: KeyArtSet(
            assetPrefix: "keyart_dmg_",
            heightFraction: 0.48,
            bottomInsetFraction: 0.09,
            opacity: 0.90,
            fillKeys: ["space"],
            labelLiftFraction: 0.14
        ),
        effects: .none
    )

    static let kawaiiCosmicStudy = MochiKeyboardTheme(
        id: "mochi.kawaii-cosmic-study",
        name: "Kawaii Cosmic Study",
        authorName: "Mochi",
        appearance: .light,
        surface: ThemeSurface(
            baseFill: ThemeFill(stops: [
                    ThemeColor(hex: "#342D59")!,
                    ThemeColor(hex: "#B299C7")!,
                    ThemeColor(hex: "#FBDFB0")!
                ]),
            backgroundImage: ThemeBackgroundImage(
                source: .bundled(name: "themebg_kawaii_cosmic_study"),
                scalesToFill: true,
                verticalAnchor: 0.5,
                blurRadius: 0.0
            ),
            scrim: ThemeScrim(
                topColor: ThemeColor(hex: "#65515C")!.withAlpha(0.22),
                bottomColor: ThemeColor(hex: "#65515C")!.withAlpha(0.07)
            )
        ),
        keyStyles: [
            .input: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#FFEDE4")!,
                    ThemeColor(hex: "#F7E5DD")!
                ]),
                labelColor: ThemeColor(hex: "#221C28")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#F3E2DA")!,
                    ThemeColor(hex: "#EBDAD2")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#221C28")!,
                border: ThemeBorder(color: ThemeColor(hex: "#B3A6A0")!.withAlpha(0.40), width: 1.15),
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
                    ThemeColor(hex: "#F7E5DD")!,
                    ThemeColor(hex: "#EFDED6")!
                ]),
                labelColor: ThemeColor(hex: "#221C28")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#EBDAD2")!,
                    ThemeColor(hex: "#E2D2CA")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#221C28")!,
                border: ThemeBorder(color: ThemeColor(hex: "#ADA19B")!.withAlpha(0.40), width: 1.15),
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
                    ThemeColor(hex: "#FBEEE8")!,
                    ThemeColor(hex: "#F3E6E0")!
                ]),
                labelColor: ThemeColor(hex: "#221C28")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#EFE2DD")!,
                    ThemeColor(hex: "#E7DBD5")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#221C28")!,
                border: ThemeBorder(color: ThemeColor(hex: "#B0A6A2")!.withAlpha(0.40), width: 1.15),
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
                    ThemeColor(hex: "#FFEDE4")!.withAlpha(0.42),
                    ThemeColor(hex: "#F7E5DD")!.withAlpha(0.42)
                ]),
                labelColor: ThemeColor(hex: "#221C28")!.withAlpha(0.00),
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#F4E3DB")!.withAlpha(0.42),
                    ThemeColor(hex: "#ECDBD3")!.withAlpha(0.42)
                ]),
                border: ThemeBorder(color: ThemeColor(hex: "#FFFCFB")!.withAlpha(0.40), width: 1.15),
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
                    ThemeColor(hex: "#5B5577")!.withAlpha(0.55)
                ]),
            highlightFill: ThemeFill(stops: [
                    ThemeColor(hex: "#FFFFFF")!.withAlpha(0.16)
                ])
        ),
        keyArt: KeyArtSet(
            assetPrefix: "keyart_kcs_",
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
            tint: ThemeColor(hex: "#FFD9EC")!
        )
    )

    static let kawaiiOceanNight = MochiKeyboardTheme(
        id: "mochi.kawaii-ocean-night",
        name: "Kawaii Ocean Night",
        authorName: "Mochi",
        appearance: .light,
        surface: ThemeSurface(
            baseFill: ThemeFill(stops: [
                    ThemeColor(hex: "#8F74B7")!,
                    ThemeColor(hex: "#9183BF")!,
                    ThemeColor(hex: "#F2CACD")!
                ]),
            backgroundImage: ThemeBackgroundImage(
                source: .bundled(name: "themebg_kawaii_ocean_night"),
                scalesToFill: true,
                verticalAnchor: 0.5,
                blurRadius: 0.0
            ),
            scrim: ThemeScrim(
                topColor: ThemeColor(hex: "#5D5067")!.withAlpha(0.28),
                bottomColor: ThemeColor(hex: "#5D5067")!.withAlpha(0.11)
            )
        ),
        keyStyles: [
            .input: KeyStyle(
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
                border: ThemeBorder(color: ThemeColor(hex: "#B2A9A9")!.withAlpha(0.40), width: 1.15),
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
                    ThemeColor(hex: "#F6E9EA")!,
                    ThemeColor(hex: "#EEE2E2")!
                ]),
                labelColor: ThemeColor(hex: "#221C28")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#EADEDE")!,
                    ThemeColor(hex: "#E1D6D6")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#221C28")!,
                border: ThemeBorder(color: ThemeColor(hex: "#ACA3A4")!.withAlpha(0.40), width: 1.15),
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
                    ThemeColor(hex: "#FBF1F2")!,
                    ThemeColor(hex: "#F4EAEA")!
                ]),
                labelColor: ThemeColor(hex: "#221C28")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#F0E6E7")!,
                    ThemeColor(hex: "#E8DFDF")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#221C28")!,
                border: ThemeBorder(color: ThemeColor(hex: "#B0A9A9")!.withAlpha(0.40), width: 1.15),
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
                    ThemeColor(hex: "#FDF1F1")!.withAlpha(0.42),
                    ThemeColor(hex: "#F6E9EA")!.withAlpha(0.42)
                ]),
                labelColor: ThemeColor(hex: "#221C28")!.withAlpha(0.00),
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#F3E7E7")!.withAlpha(0.42),
                    ThemeColor(hex: "#EBDFE0")!.withAlpha(0.42)
                ]),
                border: ThemeBorder(color: ThemeColor(hex: "#FFFCFC")!.withAlpha(0.40), width: 1.15),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.30, radius: 4.20, offsetY: 3.00),
                topHighlight: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.62),
                cornerRadiusOverride: 20.0
            )
        ],
        typography: ThemeTypography(fontFamily: nil, weightRawValue: 0.34, sizeMultiplier: 1.0),
        chrome: ThemeChrome(
            inkColor: ThemeColor(hex: "#08050D")!,
            mutedInkColor: ThemeColor(hex: "#08050D")!.withAlpha(0.55),
            panelFill: ThemeFill(stops: [
                    ThemeColor(hex: "#FCFBFD")!.withAlpha(0.55)
                ]),
            highlightFill: ThemeFill(stops: [
                    ThemeColor(hex: "#000000")!.withAlpha(0.16)
                ])
        ),
        keyArt: KeyArtSet(
            assetPrefix: "keyart_kon_",
            heightFraction: 0.50,
            bottomInsetFraction: 0.10,
            opacity: 0.90,
            fillKeys: ["space"],
            labelLiftFraction: 0.15
        ),
        effects: .none
    )

    static let neonRacingGarage = MochiKeyboardTheme(
        id: "mochi.neon-racing-garage",
        name: "Neon Racing Garage",
        authorName: "Mochi",
        appearance: .dark,
        surface: ThemeSurface(
            baseFill: ThemeFill(stops: [
                    ThemeColor(hex: "#E83C38")!,
                    ThemeColor(hex: "#2D1515")!,
                    ThemeColor(hex: "#2C2120")!
                ]),
            backgroundImage: ThemeBackgroundImage(
                source: .bundled(name: "themebg_neon_racing_garage"),
                scalesToFill: true,
                verticalAnchor: 0.5,
                blurRadius: 0.0
            ),
            scrim: ThemeScrim(
                topColor: ThemeColor(hex: "#362121")!.withAlpha(0.20),
                bottomColor: ThemeColor(hex: "#362121")!.withAlpha(0.06)
            )
        ),
        keyStyles: [
            .input: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#180909")!,
                    ThemeColor(hex: "#392D2C")!
                ]),
                labelColor: ThemeColor(hex: "#FFFFFF")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#635958")!,
                    ThemeColor(hex: "#6C6262")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#FFFFFF")!,
                border: ThemeBorder(color: ThemeColor(hex: "#C7C4C3")!.withAlpha(0.60), width: 1.00),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.32, radius: 2.60, offsetY: 1.60),
                topHighlight: ThemeColor(hex: "#BFBBBB")!.withAlpha(0.28),
                cornerRadiusOverride: 12.0,
                glass: KeyGlass(
                    bevelColor: ThemeColor(hex: "#C7C4C3")!.withAlpha(0.62),
                    bevelWidth: 1.00,
                    bevelFalloff: 0.12,
                    innerShadowColor: ThemeColor(hex: "#0A080F")!,
                    innerShadowOpacity: 0.36,
                    innerShadowRadius: 3.00
                )
            ),
            .system: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#4B3F3F")!,
                    ThemeColor(hex: "#584D4D")!
                ]),
                labelColor: ThemeColor(hex: "#FFFFFF")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#746B6B")!,
                    ThemeColor(hex: "#7C7373")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#FFFFFF")!,
                border: ThemeBorder(color: ThemeColor(hex: "#CECBCB")!.withAlpha(0.60), width: 1.00),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.32, radius: 2.60, offsetY: 1.60),
                topHighlight: ThemeColor(hex: "#C7C4C3")!.withAlpha(0.28),
                cornerRadiusOverride: 12.0,
                glass: KeyGlass(
                    bevelColor: ThemeColor(hex: "#CECBCB")!.withAlpha(0.62),
                    bevelWidth: 1.00,
                    bevelFalloff: 0.12,
                    innerShadowColor: ThemeColor(hex: "#0A080F")!,
                    innerShadowOpacity: 0.36,
                    innerShadowRadius: 3.00
                )
            ),
            .action: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#150A09")!,
                    ThemeColor(hex: "#362E2D")!
                ]),
                labelColor: ThemeColor(hex: "#FFFFFF")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#605958")!,
                    ThemeColor(hex: "#6A6362")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#FFFFFF")!,
                border: ThemeBorder(color: ThemeColor(hex: "#C6C4C4")!.withAlpha(0.60), width: 1.00),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.32, radius: 2.60, offsetY: 1.60),
                topHighlight: ThemeColor(hex: "#BEBCBB")!.withAlpha(0.28),
                cornerRadiusOverride: 12.0,
                glass: KeyGlass(
                    bevelColor: ThemeColor(hex: "#C6C4C4")!.withAlpha(0.62),
                    bevelWidth: 1.00,
                    bevelFalloff: 0.12,
                    innerShadowColor: ThemeColor(hex: "#0A080F")!,
                    innerShadowOpacity: 0.36,
                    innerShadowRadius: 3.00
                )
            ),
            .space: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#180909")!.withAlpha(0.50),
                    ThemeColor(hex: "#392D2C")!.withAlpha(0.50)
                ]),
                labelColor: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.00),
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#5A4F4F")!.withAlpha(0.50),
                    ThemeColor(hex: "#655B5A")!.withAlpha(0.50)
                ]),
                border: ThemeBorder(color: ThemeColor(hex: "#BFBBBB")!.withAlpha(0.60), width: 1.00),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.32, radius: 2.60, offsetY: 1.60),
                topHighlight: ThemeColor(hex: "#BFBBBB")!.withAlpha(0.28),
                cornerRadiusOverride: 14.0
            )
        ],
        typography: ThemeTypography(fontFamily: nil, weightRawValue: 0.34, sizeMultiplier: 1.0),
        chrome: ThemeChrome(
            inkColor: ThemeColor(hex: "#F2ECF0")!,
            mutedInkColor: ThemeColor(hex: "#F2ECF0")!.withAlpha(0.55),
            panelFill: ThemeFill(stops: [
                    ThemeColor(hex: "#665555")!.withAlpha(0.55)
                ]),
            highlightFill: ThemeFill(stops: [
                    ThemeColor(hex: "#FFFFFF")!.withAlpha(0.16)
                ])
        ),
        keyArt: KeyArtSet(
            assetPrefix: "keyart_nrg_",
            heightFraction: 0.44,
            bottomInsetFraction: 0.09,
            opacity: 0.90,
            fillKeys: ["space"],
            labelLiftFraction: 0.14
        ),
        effects: .none
    )

    static let pastelLakesideCarnival = MochiKeyboardTheme(
        id: "mochi.pastel-lakeside-carnival",
        name: "Pastel Lakeside Carnival",
        authorName: "Mochi",
        appearance: .dark,
        surface: ThemeSurface(
            baseFill: ThemeFill(stops: [
                    ThemeColor(hex: "#846182")!,
                    ThemeColor(hex: "#C28FAE")!,
                    ThemeColor(hex: "#876189")!
                ]),
            backgroundImage: ThemeBackgroundImage(
                source: .bundled(name: "themebg_pastel_lakeside_carnival"),
                scalesToFill: true,
                verticalAnchor: 0.5,
                blurRadius: 0.0
            ),
            scrim: ThemeScrim(
                topColor: ThemeColor(hex: "#6F525E")!.withAlpha(0.18),
                bottomColor: ThemeColor(hex: "#6F525E")!.withAlpha(0.05)
            )
        ),
        keyStyles: [
            .input: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#471E33")!,
                    ThemeColor(hex: "#654455")!
                ]),
                labelColor: ThemeColor(hex: "#FFFFFF")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#785B6A")!,
                    ThemeColor(hex: "#876D7A")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#FFFFFF")!,
                border: ThemeBorder(color: ThemeColor(hex: "#CFC5CA")!.withAlpha(0.55), width: 1.00),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.26, radius: 1.60, offsetY: 1.60),
                topHighlight: ThemeColor(hex: "#C9BDC3")!.withAlpha(0.34),
                cornerRadiusOverride: 8.0,
                glass: KeyGlass(
                    bevelColor: ThemeColor(hex: "#CFC5CA")!.withAlpha(0.70),
                    bevelWidth: 1.00,
                    bevelFalloff: 0.10,
                    innerShadowColor: ThemeColor(hex: "#0A080F")!,
                    innerShadowOpacity: 0.16,
                    innerShadowRadius: 2.00
                )
            ),
            .system: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#654455")!,
                    ThemeColor(hex: "#785B6A")!
                ]),
                labelColor: ThemeColor(hex: "#FFFFFF")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#876D7A")!,
                    ThemeColor(hex: "#947C88")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#FFFFFF")!,
                border: ThemeBorder(color: ThemeColor(hex: "#D6CDD1")!.withAlpha(0.55), width: 1.00),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.26, radius: 1.60, offsetY: 1.60),
                topHighlight: ThemeColor(hex: "#CFC5CA")!.withAlpha(0.34),
                cornerRadiusOverride: 8.0,
                glass: KeyGlass(
                    bevelColor: ThemeColor(hex: "#D6CDD1")!.withAlpha(0.70),
                    bevelWidth: 1.00,
                    bevelFalloff: 0.10,
                    innerShadowColor: ThemeColor(hex: "#0A080F")!,
                    innerShadowOpacity: 0.16,
                    innerShadowRadius: 2.00
                )
            ),
            .action: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#39272C")!,
                    ThemeColor(hex: "#594A4E")!
                ]),
                labelColor: ThemeColor(hex: "#FFFFFF")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#6D6063")!,
                    ThemeColor(hex: "#7D7174")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#FFFFFF")!,
                border: ThemeBorder(color: ThemeColor(hex: "#CBC7C8")!.withAlpha(0.55), width: 1.00),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.26, radius: 1.60, offsetY: 1.60),
                topHighlight: ThemeColor(hex: "#C4BEC0")!.withAlpha(0.34),
                cornerRadiusOverride: 8.0,
                glass: KeyGlass(
                    bevelColor: ThemeColor(hex: "#CBC7C8")!.withAlpha(0.70),
                    bevelWidth: 1.00,
                    bevelFalloff: 0.10,
                    innerShadowColor: ThemeColor(hex: "#0A080F")!,
                    innerShadowOpacity: 0.16,
                    innerShadowRadius: 2.00
                )
            ),
            .space: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#471E33")!.withAlpha(0.50),
                    ThemeColor(hex: "#654455")!.withAlpha(0.50)
                ]),
                labelColor: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.00),
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#715262")!.withAlpha(0.50),
                    ThemeColor(hex: "#826674")!.withAlpha(0.50)
                ]),
                border: ThemeBorder(color: ThemeColor(hex: "#C9BDC3")!.withAlpha(0.55), width: 1.00),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.26, radius: 1.60, offsetY: 1.60),
                topHighlight: ThemeColor(hex: "#C9BDC3")!.withAlpha(0.34),
                cornerRadiusOverride: 10.0
            )
        ],
        typography: ThemeTypography(fontFamily: nil, weightRawValue: 0.34, sizeMultiplier: 1.0),
        chrome: ThemeChrome(
            inkColor: ThemeColor(hex: "#FCFAFF")!,
            mutedInkColor: ThemeColor(hex: "#FCFAFF")!.withAlpha(0.55),
            panelFill: ThemeFill(stops: [
                    ThemeColor(hex: "#6D506A")!.withAlpha(0.55)
                ]),
            highlightFill: ThemeFill(stops: [
                    ThemeColor(hex: "#FFFFFF")!.withAlpha(0.16)
                ])
        ),
        keyArt: KeyArtSet(
            assetPrefix: "keyart_plc_",
            heightFraction: 0.46,
            bottomInsetFraction: 0.09,
            opacity: 0.90,
            fillKeys: ["space"],
            labelLiftFraction: 0.14
        ),
        effects: .none
    )

    static let pastelUnderwater = MochiKeyboardTheme(
        id: "mochi.pastel-underwater",
        name: "Pastel Underwater",
        authorName: "Mochi",
        appearance: .light,
        surface: ThemeSurface(
            baseFill: ThemeFill(stops: [
                    ThemeColor(hex: "#57A3AF")!,
                    ThemeColor(hex: "#60B9BD")!,
                    ThemeColor(hex: "#C2DDD6")!
                ]),
            backgroundImage: ThemeBackgroundImage(
                source: .bundled(name: "themebg_pastel_underwater"),
                scalesToFill: true,
                verticalAnchor: 0.5,
                blurRadius: 0.0
            ),
            scrim: ThemeScrim(
                topColor: ThemeColor(hex: "#3F6869")!.withAlpha(0.26),
                bottomColor: ThemeColor(hex: "#3F6869")!.withAlpha(0.16)
            )
        ),
        keyStyles: [
            .input: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#F6F4EA")!.withAlpha(0.73),
                    ThemeColor(hex: "#F0EDE4")!.withAlpha(0.73)
                ]),
                labelColor: ThemeColor(hex: "#221C28")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#EBE8E0")!.withAlpha(0.85),
                    ThemeColor(hex: "#E4E2D9")!.withAlpha(0.85)
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
            .system: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#EFECE3")!.withAlpha(0.79),
                    ThemeColor(hex: "#E8E6DD")!.withAlpha(0.79)
                ]),
                labelColor: ThemeColor(hex: "#221C28")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#E3E1D8")!.withAlpha(0.91),
                    ThemeColor(hex: "#DCDAD2")!.withAlpha(0.91)
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
                    ThemeColor(hex: "#ECF5F5")!.withAlpha(0.79),
                    ThemeColor(hex: "#E6EFEF")!.withAlpha(0.79)
                ]),
                labelColor: ThemeColor(hex: "#221C28")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#E1EAEA")!.withAlpha(0.91),
                    ThemeColor(hex: "#DBE4E3")!.withAlpha(0.91)
                ]),
                pressedLabelColor: ThemeColor(hex: "#221C28")!,
                border: ThemeBorder(color: ThemeColor(hex: "#FBFDFD")!.withAlpha(0.58), width: 1.20),
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
                    ThemeColor(hex: "#F6F4EA")!.withAlpha(0.42),
                    ThemeColor(hex: "#F0EDE4")!.withAlpha(0.42)
                ]),
                labelColor: ThemeColor(hex: "#221C28")!.withAlpha(0.00),
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#ECEAE1")!.withAlpha(0.42),
                    ThemeColor(hex: "#E6E3DB")!.withAlpha(0.42)
                ]),
                border: ThemeBorder(color: ThemeColor(hex: "#FDFDFB")!.withAlpha(0.58), width: 1.20),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.17, radius: 1.90, offsetY: 1.10),
                topHighlight: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.58),
                cornerRadiusOverride: 15.0
            )
        ],
        typography: ThemeTypography(fontFamily: nil, weightRawValue: 0.34, sizeMultiplier: 1.0),
        chrome: ThemeChrome(
            inkColor: ThemeColor(hex: "#000000")!,
            mutedInkColor: ThemeColor(hex: "#000000")!.withAlpha(0.55),
            panelFill: ThemeFill(stops: [
                    ThemeColor(hex: "#FAFCFC")!.withAlpha(0.55)
                ]),
            highlightFill: ThemeFill(stops: [
                    ThemeColor(hex: "#000000")!.withAlpha(0.16)
                ])
        ),
        keyArt: KeyArtSet(
            assetPrefix: "keyart_ptu_",
            heightFraction: 0.46,
            bottomInsetFraction: 0.09,
            opacity: 0.90,
            fillKeys: ["space"],
            labelLiftFraction: 0.14
        ),
        effects: .none
    )

    static let prehistoricFossilExplorer = MochiKeyboardTheme(
        id: "mochi.prehistoric-fossil-explorer",
        name: "Prehistoric Fossil Explorer",
        authorName: "Mochi",
        appearance: .dark,
        surface: ThemeSurface(
            baseFill: ThemeFill(stops: [
                    ThemeColor(hex: "#CAAD83")!,
                    ThemeColor(hex: "#B09B66")!,
                    ThemeColor(hex: "#FFD99B")!
                ]),
            backgroundImage: ThemeBackgroundImage(
                source: .bundled(name: "themebg_prehistoric_fossil_explorer"),
                scalesToFill: true,
                verticalAnchor: 0.5,
                blurRadius: 0.0
            ),
            scrim: ThemeScrim(
                topColor: ThemeColor(hex: "#84704A")!.withAlpha(0.16),
                bottomColor: ThemeColor(hex: "#84704A")!.withAlpha(0.05)
            )
        ),
        keyStyles: [
            .input: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#2F1D0A")!,
                    ThemeColor(hex: "#4C3D2C")!
                ]),
                labelColor: ThemeColor(hex: "#FFFFFF")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#6A5D50")!,
                    ThemeColor(hex: "#766A5E")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#FFFFFF")!,
                border: ThemeBorder(color: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.80), width: 1.70),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.00, radius: 0.00, offsetY: 0.00),
                topHighlight: nil,
                cornerRadiusOverride: 6.0
            ),
            .system: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#544636")!,
                    ThemeColor(hex: "#645749")!
                ]),
                labelColor: ThemeColor(hex: "#FFFFFF")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#7B6F63")!,
                    ThemeColor(hex: "#847A6F")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#FFFFFF")!,
                border: ThemeBorder(color: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.80), width: 1.70),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.00, radius: 0.00, offsetY: 0.00),
                topHighlight: nil,
                cornerRadiusOverride: 6.0
            ),
            .action: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#272015")!,
                    ThemeColor(hex: "#453E35")!
                ]),
                labelColor: ThemeColor(hex: "#FFFFFF")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#645F57")!,
                    ThemeColor(hex: "#706B64")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#FFFFFF")!,
                border: ThemeBorder(color: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.80), width: 1.70),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.00, radius: 0.00, offsetY: 0.00),
                topHighlight: nil,
                cornerRadiusOverride: 6.0
            ),
            .space: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#2F1D0A")!.withAlpha(0.50),
                    ThemeColor(hex: "#4C3D2C")!.withAlpha(0.50)
                ]),
                labelColor: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.00),
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#625546")!.withAlpha(0.50),
                    ThemeColor(hex: "#6F6356")!.withAlpha(0.50)
                ]),
                border: ThemeBorder(color: ThemeColor(hex: "#C2BDB8")!.withAlpha(0.80), width: 1.70),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.00, radius: 0.00, offsetY: 0.00),
                topHighlight: nil,
                cornerRadiusOverride: 8.0
            )
        ],
        typography: ThemeTypography(fontFamily: nil, weightRawValue: 0.34, sizeMultiplier: 1.0),
        chrome: ThemeChrome(
            inkColor: ThemeColor(hex: "#18141D")!,
            mutedInkColor: ThemeColor(hex: "#18141D")!.withAlpha(0.55),
            panelFill: ThemeFill(stops: [
                    ThemeColor(hex: "#FCFCFA")!.withAlpha(0.55)
                ]),
            highlightFill: ThemeFill(stops: [
                    ThemeColor(hex: "#000000")!.withAlpha(0.16)
                ])
        ),
        keyArt: KeyArtSet(
            assetPrefix: "keyart_pfe_",
            heightFraction: 0.40,
            bottomInsetFraction: 0.09,
            opacity: 0.90,
            fillKeys: ["space"],
            labelLiftFraction: 0.13
        ),
        effects: .none
    )

    static let retroArcade = MochiKeyboardTheme(
        id: "mochi.retro-arcade",
        name: "Retro Arcade",
        authorName: "Mochi",
        appearance: .dark,
        surface: ThemeSurface(
            baseFill: ThemeFill(stops: [
                    ThemeColor(hex: "#7A4371")!,
                    ThemeColor(hex: "#57331D")!,
                    ThemeColor(hex: "#764826")!
                ]),
            backgroundImage: ThemeBackgroundImage(
                source: .bundled(name: "themebg_retro_arcade"),
                scalesToFill: true,
                verticalAnchor: 0.5,
                blurRadius: 0.0
            ),
            scrim: ThemeScrim(
                topColor: ThemeColor(hex: "#392112")!.withAlpha(0.18),
                bottomColor: ThemeColor(hex: "#392112")!.withAlpha(0.05)
            )
        ),
        keyStyles: [
            .input: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#1C0C04")!,
                    ThemeColor(hex: "#4D4039")!
                ]),
                labelColor: ThemeColor(hex: "#FFFFFF")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#645953")!,
                    ThemeColor(hex: "#766C67")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#FFFFFF")!,
                border: ThemeBorder(color: ThemeColor(hex: "#C8C4C2")!.withAlpha(0.55), width: 1.00),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.26, radius: 1.60, offsetY: 1.60),
                topHighlight: ThemeColor(hex: "#C0BCB9")!.withAlpha(0.34),
                cornerRadiusOverride: 8.0,
                glass: KeyGlass(
                    bevelColor: ThemeColor(hex: "#C8C4C2")!.withAlpha(0.70),
                    bevelWidth: 1.00,
                    bevelFalloff: 0.10,
                    innerShadowColor: ThemeColor(hex: "#0A080F")!,
                    innerShadowOpacity: 0.16,
                    innerShadowRadius: 2.00
                )
            ),
            .system: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#4D4039")!,
                    ThemeColor(hex: "#645953")!
                ]),
                labelColor: ThemeColor(hex: "#FFFFFF")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#766C67")!,
                    ThemeColor(hex: "#847B77")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#FFFFFF")!,
                border: ThemeBorder(color: ThemeColor(hex: "#CFCCCA")!.withAlpha(0.55), width: 1.00),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.26, radius: 1.60, offsetY: 1.60),
                topHighlight: ThemeColor(hex: "#C8C4C2")!.withAlpha(0.34),
                cornerRadiusOverride: 8.0,
                glass: KeyGlass(
                    bevelColor: ThemeColor(hex: "#CFCCCA")!.withAlpha(0.70),
                    bevelWidth: 1.00,
                    bevelFalloff: 0.10,
                    innerShadowColor: ThemeColor(hex: "#0A080F")!,
                    innerShadowOpacity: 0.16,
                    innerShadowRadius: 2.00
                )
            ),
            .action: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#160F07")!,
                    ThemeColor(hex: "#47423B")!
                ]),
                labelColor: ThemeColor(hex: "#FFFFFF")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#5F5B55")!,
                    ThemeColor(hex: "#716D68")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#FFFFFF")!,
                border: ThemeBorder(color: ThemeColor(hex: "#C6C4C2")!.withAlpha(0.55), width: 1.00),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.26, radius: 1.60, offsetY: 1.60),
                topHighlight: ThemeColor(hex: "#BEBCBA")!.withAlpha(0.34),
                cornerRadiusOverride: 8.0,
                glass: KeyGlass(
                    bevelColor: ThemeColor(hex: "#C6C4C2")!.withAlpha(0.70),
                    bevelWidth: 1.00,
                    bevelFalloff: 0.10,
                    innerShadowColor: ThemeColor(hex: "#0A080F")!,
                    innerShadowOpacity: 0.16,
                    innerShadowRadius: 2.00
                )
            ),
            .space: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#1C0C04")!.withAlpha(0.50),
                    ThemeColor(hex: "#4D4039")!.withAlpha(0.50)
                ]),
                labelColor: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.00),
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#5C504A")!.withAlpha(0.50),
                    ThemeColor(hex: "#6F6560")!.withAlpha(0.50)
                ]),
                border: ThemeBorder(color: ThemeColor(hex: "#C0BCB9")!.withAlpha(0.55), width: 1.00),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.26, radius: 1.60, offsetY: 1.60),
                topHighlight: ThemeColor(hex: "#C0BCB9")!.withAlpha(0.34),
                cornerRadiusOverride: 10.0
            )
        ],
        typography: ThemeTypography(fontFamily: nil, weightRawValue: 0.34, sizeMultiplier: 1.0),
        chrome: ThemeChrome(
            inkColor: ThemeColor(hex: "#F2ECF0")!,
            mutedInkColor: ThemeColor(hex: "#F2ECF0")!.withAlpha(0.55),
            panelFill: ThemeFill(stops: [
                    ThemeColor(hex: "#705341")!.withAlpha(0.55)
                ]),
            highlightFill: ThemeFill(stops: [
                    ThemeColor(hex: "#FFFFFF")!.withAlpha(0.16)
                ])
        ),
        keyArt: KeyArtSet(
            assetPrefix: "keyart_rta_",
            heightFraction: 0.46,
            bottomInsetFraction: 0.09,
            opacity: 0.90,
            fillKeys: ["space"],
            labelLiftFraction: 0.14
        ),
        effects: .none
    )

    static let sakuraNightKawaiiLandscape = MochiKeyboardTheme(
        id: "mochi.sakura-night-kawaii-landscape",
        name: "Sakura Night Kawaii Landscape",
        authorName: "Mochi",
        appearance: .dark,
        surface: ThemeSurface(
            baseFill: ThemeFill(stops: [
                    ThemeColor(hex: "#3E2843")!,
                    ThemeColor(hex: "#CF8EA2")!,
                    ThemeColor(hex: "#E9B0BB")!
                ]),
            backgroundImage: ThemeBackgroundImage(
                source: .bundled(name: "themebg_sakura_night_kawaii_landscape"),
                scalesToFill: true,
                verticalAnchor: 0.5,
                blurRadius: 0.0
            ),
            scrim: ThemeScrim(
                topColor: ThemeColor(hex: "#77525B")!.withAlpha(0.18),
                bottomColor: ThemeColor(hex: "#77525B")!.withAlpha(0.05)
            )
        ),
        keyStyles: [
            .input: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#461912")!,
                    ThemeColor(hex: "#481325")!
                ]),
                labelColor: ThemeColor(hex: "#FFFFFF")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#7A5A55")!,
                    ThemeColor(hex: "#7D5763")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#FFFFFF")!,
                border: ThemeBorder(color: ThemeColor(hex: "#D0C5C3")!.withAlpha(0.42), width: 0.95),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.15, radius: 2.20, offsetY: 1.30),
                topHighlight: ThemeColor(hex: "#C9BCBA")!.withAlpha(0.46),
                cornerRadiusOverride: 14.0,
                glass: KeyGlass(
                    bevelColor: ThemeColor(hex: "#D0C5C3")!.withAlpha(0.60),
                    bevelWidth: 0.80,
                    bevelFalloff: 0.18,
                    innerShadowColor: ThemeColor(hex: "#0A080F")!,
                    innerShadowOpacity: 0.12,
                    innerShadowRadius: 2.00
                )
            ),
            .system: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#673F40")!,
                    ThemeColor(hex: "#896A6B")!
                ]),
                labelColor: ThemeColor(hex: "#FFFFFF")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#896A6B")!,
                    ThemeColor(hex: "#A08888")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#FFFFFF")!,
                border: ThemeBorder(color: ThemeColor(hex: "#D6CCCC")!.withAlpha(0.42), width: 0.95),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.15, radius: 2.20, offsetY: 1.30),
                topHighlight: ThemeColor(hex: "#D0C4C4")!.withAlpha(0.46),
                cornerRadiusOverride: 14.0,
                glass: KeyGlass(
                    bevelColor: ThemeColor(hex: "#D6CCCC")!.withAlpha(0.60),
                    bevelWidth: 0.80,
                    bevelFalloff: 0.18,
                    innerShadowColor: ThemeColor(hex: "#0A080F")!,
                    innerShadowOpacity: 0.12,
                    innerShadowRadius: 2.00
                )
            ),
            .action: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#321F21")!,
                    ThemeColor(hex: "#6B5D5F")!
                ]),
                labelColor: ThemeColor(hex: "#FFFFFF")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#6B5D5F")!,
                    ThemeColor(hex: "#897E7F")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#FFFFFF")!,
                border: ThemeBorder(color: ThemeColor(hex: "#CAC5C6")!.withAlpha(0.42), width: 0.95),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.15, radius: 2.20, offsetY: 1.30),
                topHighlight: ThemeColor(hex: "#C3BDBE")!.withAlpha(0.46),
                cornerRadiusOverride: 14.0,
                glass: KeyGlass(
                    bevelColor: ThemeColor(hex: "#CAC5C6")!.withAlpha(0.60),
                    bevelWidth: 0.80,
                    bevelFalloff: 0.18,
                    innerShadowColor: ThemeColor(hex: "#0A080F")!,
                    innerShadowOpacity: 0.12,
                    innerShadowRadius: 2.00
                )
            ),
            .space: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#461912")!.withAlpha(0.50),
                    ThemeColor(hex: "#481325")!.withAlpha(0.50)
                ]),
                labelColor: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.00),
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#73514C")!.withAlpha(0.50),
                    ThemeColor(hex: "#764E5B")!.withAlpha(0.50)
                ]),
                border: ThemeBorder(color: ThemeColor(hex: "#C9BCBA")!.withAlpha(0.42), width: 0.95),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.15, radius: 2.20, offsetY: 1.30),
                topHighlight: ThemeColor(hex: "#C9BCBA")!.withAlpha(0.46),
                cornerRadiusOverride: 16.0
            )
        ],
        typography: ThemeTypography(fontFamily: nil, weightRawValue: 0.34, sizeMultiplier: 1.0),
        chrome: ThemeChrome(
            inkColor: ThemeColor(hex: "#F2ECF0")!,
            mutedInkColor: ThemeColor(hex: "#F2ECF0")!.withAlpha(0.55),
            panelFill: ThemeFill(stops: [
                    ThemeColor(hex: "#655368")!.withAlpha(0.55)
                ]),
            highlightFill: ThemeFill(stops: [
                    ThemeColor(hex: "#FFFFFF")!.withAlpha(0.16)
                ])
        ),
        keyArt: KeyArtSet(
            assetPrefix: "keyart_snk_",
            heightFraction: 0.48,
            bottomInsetFraction: 0.09,
            opacity: 0.90,
            fillKeys: ["space"],
            labelLiftFraction: 0.14
        ),
        effects: .none
    )

    static let seasidePostcard = MochiKeyboardTheme(
        id: "mochi.seaside-postcard",
        name: "Seaside Postcard",
        authorName: "Mochi",
        appearance: .dark,
        surface: ThemeSurface(
            baseFill: ThemeFill(stops: [
                    ThemeColor(hex: "#5BA0D8")!,
                    ThemeColor(hex: "#BDDBE9")!,
                    ThemeColor(hex: "#C4DFE9")!
                ]),
            backgroundImage: ThemeBackgroundImage(
                source: .bundled(name: "themebg_seaside_postcard"),
                scalesToFill: true,
                verticalAnchor: 0.5,
                blurRadius: 0.0
            ),
            scrim: ThemeScrim(
                topColor: ThemeColor(hex: "#95A1A4")!.withAlpha(0.26),
                bottomColor: ThemeColor(hex: "#95A1A4")!.withAlpha(0.11)
            )
        ),
        keyStyles: [
            .input: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#3D2713")!,
                    ThemeColor(hex: "#554230")!
                ]),
                labelColor: ThemeColor(hex: "#FFFFFF")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#706052")!,
                    ThemeColor(hex: "#7C6D5F")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#FFFFFF")!,
                border: ThemeBorder(color: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.80), width: 1.70),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.00, radius: 0.00, offsetY: 0.00),
                topHighlight: nil,
                cornerRadiusOverride: 6.0
            ),
            .system: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#5C4A39")!,
                    ThemeColor(hex: "#6B5A4B")!
                ]),
                labelColor: ThemeColor(hex: "#FFFFFF")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#807265")!,
                    ThemeColor(hex: "#897C70")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#FFFFFF")!,
                border: ThemeBorder(color: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.80), width: 1.70),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.00, radius: 0.00, offsetY: 0.00),
                topHighlight: nil,
                cornerRadiusOverride: 6.0
            ),
            .action: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#282D2E")!,
                    ThemeColor(hex: "#424647")!
                ]),
                labelColor: ThemeColor(hex: "#FFFFFF")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#606465")!,
                    ThemeColor(hex: "#6D7071")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#FFFFFF")!,
                border: ThemeBorder(color: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.80), width: 1.70),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.00, radius: 0.00, offsetY: 0.00),
                topHighlight: nil,
                cornerRadiusOverride: 6.0
            ),
            .space: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#3D2713")!.withAlpha(0.50),
                    ThemeColor(hex: "#554230")!.withAlpha(0.50)
                ]),
                labelColor: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.00),
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#695849")!.withAlpha(0.50),
                    ThemeColor(hex: "#756658")!.withAlpha(0.50)
                ]),
                border: ThemeBorder(color: ThemeColor(hex: "#C5BFB9")!.withAlpha(0.80), width: 1.70),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.00, radius: 0.00, offsetY: 0.00),
                topHighlight: nil,
                cornerRadiusOverride: 8.0
            )
        ],
        typography: ThemeTypography(fontFamily: nil, weightRawValue: 0.34, sizeMultiplier: 1.0),
        chrome: ThemeChrome(
            inkColor: ThemeColor(hex: "#18131C")!,
            mutedInkColor: ThemeColor(hex: "#18131C")!.withAlpha(0.55),
            panelFill: ThemeFill(stops: [
                    ThemeColor(hex: "#FAFCFE")!.withAlpha(0.55)
                ]),
            highlightFill: ThemeFill(stops: [
                    ThemeColor(hex: "#000000")!.withAlpha(0.16)
                ])
        ),
        keyArt: KeyArtSet(
            assetPrefix: "keyart_ssp_",
            heightFraction: 0.40,
            bottomInsetFraction: 0.09,
            opacity: 0.90,
            fillKeys: ["space"],
            labelLiftFraction: 0.13
        ),
        effects: .none
    )

    static let sunsetMusicStudio = MochiKeyboardTheme(
        id: "mochi.sunset-music-studio",
        name: "Sunset Music Studio",
        authorName: "Mochi",
        appearance: .dark,
        surface: ThemeSurface(
            baseFill: ThemeFill(stops: [
                    ThemeColor(hex: "#704A61")!,
                    ThemeColor(hex: "#CD8B73")!,
                    ThemeColor(hex: "#F8BF88")!
                ]),
            backgroundImage: ThemeBackgroundImage(
                source: .bundled(name: "themebg_sunset_music_studio"),
                scalesToFill: true,
                verticalAnchor: 0.5,
                blurRadius: 0.0
            ),
            scrim: ThemeScrim(
                topColor: ThemeColor(hex: "#745141")!.withAlpha(0.19),
                bottomColor: ThemeColor(hex: "#745141")!.withAlpha(0.06)
            )
        ),
        keyStyles: [
            .input: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#351E08")!,
                    ThemeColor(hex: "#441A18")!
                ]),
                labelColor: ThemeColor(hex: "#FFFFFF")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#6D5D4D")!,
                    ThemeColor(hex: "#785A59")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#FFFFFF")!,
                border: ThemeBorder(color: ThemeColor(hex: "#CBC6C0")!.withAlpha(0.42), width: 0.95),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.15, radius: 2.20, offsetY: 1.30),
                topHighlight: ThemeColor(hex: "#C4BDB7")!.withAlpha(0.46),
                cornerRadiusOverride: 14.0,
                glass: KeyGlass(
                    bevelColor: ThemeColor(hex: "#CBC6C0")!.withAlpha(0.60),
                    bevelWidth: 0.80,
                    bevelFalloff: 0.18,
                    innerShadowColor: ThemeColor(hex: "#0A080F")!,
                    innerShadowOpacity: 0.12,
                    innerShadowRadius: 2.00
                )
            ),
            .system: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#594237")!,
                    ThemeColor(hex: "#7F6D64")!
                ]),
                labelColor: ThemeColor(hex: "#FFFFFF")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#7F6D64")!,
                    ThemeColor(hex: "#988A82")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#FFFFFF")!,
                border: ThemeBorder(color: ThemeColor(hex: "#D3CCC9")!.withAlpha(0.42), width: 0.95),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.15, radius: 2.20, offsetY: 1.30),
                topHighlight: ThemeColor(hex: "#CCC5C1")!.withAlpha(0.46),
                cornerRadiusOverride: 14.0,
                glass: KeyGlass(
                    bevelColor: ThemeColor(hex: "#D3CCC9")!.withAlpha(0.60),
                    bevelWidth: 0.80,
                    bevelFalloff: 0.18,
                    innerShadowColor: ThemeColor(hex: "#0A080F")!,
                    innerShadowOpacity: 0.12,
                    innerShadowRadius: 2.00
                )
            ),
            .action: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#281D15")!,
                    ThemeColor(hex: "#655D58")!
                ]),
                labelColor: ThemeColor(hex: "#FFFFFF")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#655D58")!,
                    ThemeColor(hex: "#857E7A")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#FFFFFF")!,
                border: ThemeBorder(color: ThemeColor(hex: "#C8C5C3")!.withAlpha(0.42), width: 0.95),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.15, radius: 2.20, offsetY: 1.30),
                topHighlight: ThemeColor(hex: "#C0BDBB")!.withAlpha(0.46),
                cornerRadiusOverride: 14.0,
                glass: KeyGlass(
                    bevelColor: ThemeColor(hex: "#C8C5C3")!.withAlpha(0.60),
                    bevelWidth: 0.80,
                    bevelFalloff: 0.18,
                    innerShadowColor: ThemeColor(hex: "#0A080F")!,
                    innerShadowOpacity: 0.12,
                    innerShadowRadius: 2.00
                )
            ),
            .space: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#351E08")!.withAlpha(0.50),
                    ThemeColor(hex: "#441A18")!.withAlpha(0.50)
                ]),
                labelColor: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.00),
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#665544")!.withAlpha(0.50),
                    ThemeColor(hex: "#715150")!.withAlpha(0.50)
                ]),
                border: ThemeBorder(color: ThemeColor(hex: "#C4BDB7")!.withAlpha(0.42), width: 0.95),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.15, radius: 2.20, offsetY: 1.30),
                topHighlight: ThemeColor(hex: "#C4BDB7")!.withAlpha(0.46),
                cornerRadiusOverride: 16.0
            )
        ],
        typography: ThemeTypography(fontFamily: nil, weightRawValue: 0.34, sizeMultiplier: 1.0),
        chrome: ThemeChrome(
            inkColor: ThemeColor(hex: "#F4EFF3")!,
            mutedInkColor: ThemeColor(hex: "#F4EFF3")!.withAlpha(0.55),
            panelFill: ThemeFill(stops: [
                    ThemeColor(hex: "#734E62")!.withAlpha(0.55)
                ]),
            highlightFill: ThemeFill(stops: [
                    ThemeColor(hex: "#FFFFFF")!.withAlpha(0.16)
                ])
        ),
        keyArt: KeyArtSet(
            assetPrefix: "keyart_sms_",
            heightFraction: 0.48,
            bottomInsetFraction: 0.09,
            opacity: 0.90,
            fillKeys: ["space"],
            labelLiftFraction: 0.14
        ),
        effects: .none
    )

    static let whimsicalWorld = MochiKeyboardTheme(
        id: "mochi.whimsical-world",
        name: "Whimsical World",
        authorName: "Mochi",
        appearance: .dark,
        surface: ThemeSurface(
            baseFill: ThemeFill(stops: [
                    ThemeColor(hex: "#C79665")!,
                    ThemeColor(hex: "#C5C5A1")!,
                    ThemeColor(hex: "#FFECC2")!
                ]),
            backgroundImage: ThemeBackgroundImage(
                source: .bundled(name: "themebg_whimsical_world"),
                scalesToFill: true,
                verticalAnchor: 0.5,
                blurRadius: 0.0
            ),
            scrim: ThemeScrim(
                topColor: ThemeColor(hex: "#908B74")!.withAlpha(0.20),
                bottomColor: ThemeColor(hex: "#908B74")!.withAlpha(0.06)
            )
        ),
        keyStyles: [
            .input: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#3A2910")!,
                    ThemeColor(hex: "#5A4B37")!
                ]),
                labelColor: ThemeColor(hex: "#FFFFFF")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#6E614F")!,
                    ThemeColor(hex: "#7E7362")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#FFFFFF")!,
                border: ThemeBorder(color: ThemeColor(hex: "#33240E")!.withAlpha(0.32), width: 1.35),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.22, radius: 3.60, offsetY: 2.60),
                topHighlight: nil,
                cornerRadiusOverride: 9.0
            ),
            .system: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#5A4B37")!,
                    ThemeColor(hex: "#6E614F")!
                ]),
                labelColor: ThemeColor(hex: "#FFFFFF")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#7E7362")!,
                    ThemeColor(hex: "#8B8173")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#FFFFFF")!,
                border: ThemeBorder(color: ThemeColor(hex: "#3C3224")!.withAlpha(0.32), width: 1.35),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.22, radius: 3.60, offsetY: 2.60),
                topHighlight: nil,
                cornerRadiusOverride: 9.0
            ),
            .action: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#302B22")!,
                    ThemeColor(hex: "#514D45")!
                ]),
                labelColor: ThemeColor(hex: "#FFFFFF")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#66635C")!,
                    ThemeColor(hex: "#77746D")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#FFFFFF")!,
                border: ThemeBorder(color: ThemeColor(hex: "#2B261E")!.withAlpha(0.32), width: 1.35),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.22, radius: 3.60, offsetY: 2.60),
                topHighlight: nil,
                cornerRadiusOverride: 9.0
            ),
            .space: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#3A2910")!.withAlpha(0.50),
                    ThemeColor(hex: "#5A4B37")!.withAlpha(0.50)
                ]),
                labelColor: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.00),
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#675946")!.withAlpha(0.50),
                    ThemeColor(hex: "#786C5B")!.withAlpha(0.50)
                ]),
                border: ThemeBorder(color: ThemeColor(hex: "#C4BFB8")!.withAlpha(0.32), width: 1.35),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.22, radius: 3.60, offsetY: 2.60),
                topHighlight: nil,
                cornerRadiusOverride: 11.0
            )
        ],
        typography: ThemeTypography(fontFamily: nil, weightRawValue: 0.34, sizeMultiplier: 1.0),
        chrome: ThemeChrome(
            inkColor: ThemeColor(hex: "#1D1822")!,
            mutedInkColor: ThemeColor(hex: "#1D1822")!.withAlpha(0.55),
            panelFill: ThemeFill(stops: [
                    ThemeColor(hex: "#FDFBFA")!.withAlpha(0.55)
                ]),
            highlightFill: ThemeFill(stops: [
                    ThemeColor(hex: "#000000")!.withAlpha(0.16)
                ])
        ),
        keyArt: KeyArtSet(
            assetPrefix: "keyart_whw_",
            heightFraction: 0.52,
            bottomInsetFraction: 0.10,
            opacity: 0.90,
            fillKeys: ["space"],
            labelLiftFraction: 0.15
        ),
        effects: .none
    )

    static let witchyPotionShop = MochiKeyboardTheme(
        id: "mochi.witchy-potion-shop",
        name: "Witchy Potion Shop",
        authorName: "Mochi",
        appearance: .light,
        surface: ThemeSurface(
            baseFill: ThemeFill(stops: [
                    ThemeColor(hex: "#683C66")!,
                    ThemeColor(hex: "#B9A2CF")!,
                    ThemeColor(hex: "#825C6C")!
                ]),
            backgroundImage: ThemeBackgroundImage(
                source: .bundled(name: "themebg_witchy_potion_shop"),
                scalesToFill: true,
                verticalAnchor: 0.5,
                blurRadius: 0.0
            ),
            scrim: ThemeScrim(
                topColor: ThemeColor(hex: "#6F5D68")!.withAlpha(0.27),
                bottomColor: ThemeColor(hex: "#6F5D68")!.withAlpha(0.17)
            )
        ),
        keyStyles: [
            .input: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#FBF1F4")!.withAlpha(0.73),
                    ThemeColor(hex: "#F5EBEE")!.withAlpha(0.73)
                ]),
                labelColor: ThemeColor(hex: "#221C28")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#EFE6E9")!.withAlpha(0.85),
                    ThemeColor(hex: "#E9E0E2")!.withAlpha(0.85)
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
            .system: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#F3EAEC")!.withAlpha(0.79),
                    ThemeColor(hex: "#EDE4E6")!.withAlpha(0.79)
                ]),
                labelColor: ThemeColor(hex: "#221C28")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#E7DFE1")!.withAlpha(0.91),
                    ThemeColor(hex: "#E0D8DA")!.withAlpha(0.91)
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
                    ThemeColor(hex: "#FAF2ED")!.withAlpha(0.79),
                    ThemeColor(hex: "#F4ECE7")!.withAlpha(0.79)
                ]),
                labelColor: ThemeColor(hex: "#221C28")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#EFE7E2")!.withAlpha(0.91),
                    ThemeColor(hex: "#E8E1DC")!.withAlpha(0.91)
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
            .space: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#FBF1F4")!.withAlpha(0.42),
                    ThemeColor(hex: "#F5EBEE")!.withAlpha(0.42)
                ]),
                labelColor: ThemeColor(hex: "#221C28")!.withAlpha(0.00),
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#F1E7EA")!.withAlpha(0.42),
                    ThemeColor(hex: "#EAE1E3")!.withAlpha(0.42)
                ]),
                border: ThemeBorder(color: ThemeColor(hex: "#FEFCFD")!.withAlpha(0.58), width: 1.20),
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
                    ThemeColor(hex: "#724D6F")!.withAlpha(0.55)
                ]),
            highlightFill: ThemeFill(stops: [
                    ThemeColor(hex: "#FFFFFF")!.withAlpha(0.16)
                ])
        ),
        keyArt: KeyArtSet(
            assetPrefix: "keyart_wps_",
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
            tint: ThemeColor(hex: "#C9A8FF")!
        )
    )
}
