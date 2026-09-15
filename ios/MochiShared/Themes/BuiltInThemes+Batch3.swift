import Foundation

// Batch 3 — 40 additional built-in themes, ingested from the theme design sets in
// ~/Downloads/{THEMESSSSSSS,THemeeeee,Theme7}. Same asset pipeline as batch 2 (background plate
// + 33 per-key illustrations), but keys are authored on the 7-material system (Inkwell / Pane /
// Jelly / Clay / Letterpress / Keycap / Pearl): cap colour is derived from each plate, and the
// material is chosen per theme's mood so no two keyboards read the same. `verticalAnchor` is 0.5
// for every theme pending a per-theme framing pass.

extension BuiltInThemes {

    static let batch3: [MochiKeyboardTheme] = [
        auroraFrontier, auroraTimberLodge, azureSummerEscape, beyondTheHorizon, bionovaNexus, botanicalCafe, canvasAndCoffee, capturedMoments, cozyGardenCottage, creativeWorkspace, deepSeaExplorer, dreamsInRewind, emberwatchObservatory, goldenMidway, ironAndEmberLoft, japaneseZen, midnightCarnival, midnightVoyage, neonRollerNights, parisianMorning, theWanderersCabin, toymakersMemories, velvetReelReverie, whispersOfTheSewingHearth, enchantedMidnightLibrary, moonlitMeowCafe, mysticOceanAtelier, neonDreamDistrict, sweetdreamCarnival, wanderlustScrapbook, whisperingMushroomCottage, astralGearworks, egyptThroughTime, galaxyMart, midnightRacingGarage, moonlitHydrangea, pirateTreasureNight, starlit90sHaven, starlitDiscoReverie, sunsetMirage
    ]

    static let auroraFrontier = MochiKeyboardTheme(
        id: "mochi.aurora-frontier",
        name: "Aurora Frontier",
        authorName: "Mochi",
        appearance: .dark,
        surface: ThemeSurface(
            baseFill: ThemeFill(stops: [
                    ThemeColor(hex: "#20445C")!,
                    ThemeColor(hex: "#17283A")!,
                    ThemeColor(hex: "#3D5675")!
                ]),
            backgroundImage: ThemeBackgroundImage(
                source: .bundled(name: "themebg_aurora_frontier"),
                scalesToFill: true,
                verticalAnchor: 0.5,
                blurRadius: 0.0
            ),
            scrim: ThemeScrim(
                topColor: ThemeColor(hex: "#182839")!.withAlpha(0.20),
                bottomColor: ThemeColor(hex: "#182839")!.withAlpha(0.06)
            )
        ),
        keyStyles: [
            .input: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#081220")!,
                    ThemeColor(hex: "#29323E")!
                ]),
                labelColor: ThemeColor(hex: "#FFFFFF")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#555C65")!,
                    ThemeColor(hex: "#5F666F")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#FFFFFF")!,
                border: ThemeBorder(color: ThemeColor(hex: "#C2C5C8")!.withAlpha(0.60), width: 1.00),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.32, radius: 2.60, offsetY: 1.60),
                topHighlight: ThemeColor(hex: "#BABDC1")!.withAlpha(0.28),
                cornerRadiusOverride: 12.0,
                glass: KeyGlass(
                    bevelColor: ThemeColor(hex: "#C2C5C8")!.withAlpha(0.62),
                    bevelWidth: 1.00,
                    bevelFalloff: 0.12,
                    innerShadowColor: ThemeColor(hex: "#0A080F")!,
                    innerShadowOpacity: 0.36,
                    innerShadowRadius: 3.00
                )
            ),
            .system: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#3B444E")!,
                    ThemeColor(hex: "#49515B")!
                ]),
                labelColor: ThemeColor(hex: "#FFFFFF")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#686F77")!,
                    ThemeColor(hex: "#71777E")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#FFFFFF")!,
                border: ThemeBorder(color: ThemeColor(hex: "#CACDCF")!.withAlpha(0.60), width: 1.00),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.32, radius: 2.60, offsetY: 1.60),
                topHighlight: ThemeColor(hex: "#C2C5C8")!.withAlpha(0.28),
                cornerRadiusOverride: 12.0,
                glass: KeyGlass(
                    bevelColor: ThemeColor(hex: "#CACDCF")!.withAlpha(0.62),
                    bevelWidth: 1.00,
                    bevelFalloff: 0.12,
                    innerShadowColor: ThemeColor(hex: "#0A080F")!,
                    innerShadowOpacity: 0.36,
                    innerShadowRadius: 3.00
                )
            ),
            .action: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#081220")!,
                    ThemeColor(hex: "#29323E")!
                ]),
                labelColor: ThemeColor(hex: "#FFFFFF")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#555C65")!,
                    ThemeColor(hex: "#5F666F")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#FFFFFF")!,
                border: ThemeBorder(color: ThemeColor(hex: "#C2C5C8")!.withAlpha(0.60), width: 1.00),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.32, radius: 2.60, offsetY: 1.60),
                topHighlight: ThemeColor(hex: "#BABDC1")!.withAlpha(0.28),
                cornerRadiusOverride: 12.0,
                glass: KeyGlass(
                    bevelColor: ThemeColor(hex: "#C2C5C8")!.withAlpha(0.62),
                    bevelWidth: 1.00,
                    bevelFalloff: 0.12,
                    innerShadowColor: ThemeColor(hex: "#0A080F")!,
                    innerShadowOpacity: 0.36,
                    innerShadowRadius: 3.00
                )
            ),
            .space: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#081220")!.withAlpha(0.50),
                    ThemeColor(hex: "#29323E")!.withAlpha(0.50)
                ]),
                labelColor: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.00),
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#4C545D")!.withAlpha(0.50),
                    ThemeColor(hex: "#575E67")!.withAlpha(0.50)
                ]),
                border: ThemeBorder(color: ThemeColor(hex: "#BABDC1")!.withAlpha(0.60), width: 1.00),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.32, radius: 2.60, offsetY: 1.60),
                topHighlight: ThemeColor(hex: "#BABDC1")!.withAlpha(0.28),
                cornerRadiusOverride: 14.0
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
            assetPrefix: "keyart_auf_",
            heightFraction: 0.44,
            bottomInsetFraction: 0.09,
            opacity: 0.90,
            fillKeys: ["space"],
            labelLiftFraction: 0.14
        ),
        effects: .none
    )

    static let auroraTimberLodge = MochiKeyboardTheme(
        id: "mochi.aurora-timber-lodge",
        name: "Aurora Timber Lodge",
        authorName: "Mochi",
        appearance: .light,
        surface: ThemeSurface(
            baseFill: ThemeFill(stops: [
                    ThemeColor(hex: "#18243A")!,
                    ThemeColor(hex: "#B07D48")!,
                    ThemeColor(hex: "#C27B3B")!
                ]),
            backgroundImage: ThemeBackgroundImage(
                source: .bundled(name: "themebg_aurora_timber_lodge"),
                scalesToFill: true,
                verticalAnchor: 0.5,
                blurRadius: 0.0
            ),
            scrim: ThemeScrim(
                topColor: ThemeColor(hex: "#7E5833")!.withAlpha(0.18),
                bottomColor: ThemeColor(hex: "#7E5833")!.withAlpha(0.05)
            )
        ),
        keyStyles: [
            .input: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#D9AD7A")!,
                    ThemeColor(hex: "#CEA474")!
                ]),
                labelColor: ThemeColor(hex: "#120F16")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#C59D6E")!,
                    ThemeColor(hex: "#B89367")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#120F16")!,
                border: ThemeBorder(color: ThemeColor(hex: "#977855")!.withAlpha(0.32), width: 1.35),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.22, radius: 3.60, offsetY: 2.60),
                topHighlight: nil,
                cornerRadiusOverride: 9.0
            ),
            .system: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#CCA272")!,
                    ThemeColor(hex: "#C0996C")!
                ]),
                labelColor: ThemeColor(hex: "#120F16")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#B59166")!,
                    ThemeColor(hex: "#A7865E")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#120F16")!,
                border: ThemeBorder(color: ThemeColor(hex: "#8D714F")!.withAlpha(0.32), width: 1.35),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.22, radius: 3.60, offsetY: 2.60),
                topHighlight: nil,
                cornerRadiusOverride: 9.0
            ),
            .action: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#C5B19E")!,
                    ThemeColor(hex: "#BBA996")!
                ]),
                labelColor: ThemeColor(hex: "#120F16")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#B3A190")!,
                    ThemeColor(hex: "#A79786")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#120F16")!,
                border: ThemeBorder(color: ThemeColor(hex: "#897B6E")!.withAlpha(0.32), width: 1.35),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.22, radius: 3.60, offsetY: 2.60),
                topHighlight: nil,
                cornerRadiusOverride: 9.0
            ),
            .space: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#D9AD7A")!.withAlpha(0.42),
                    ThemeColor(hex: "#CEA474")!.withAlpha(0.42)
                ]),
                labelColor: ThemeColor(hex: "#120F16")!.withAlpha(0.00),
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#C79F70")!.withAlpha(0.42),
                    ThemeColor(hex: "#BB9569")!.withAlpha(0.42)
                ]),
                border: ThemeBorder(color: ThemeColor(hex: "#F4E7D7")!.withAlpha(0.32), width: 1.35),
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
                    ThemeColor(hex: "#525968")!.withAlpha(0.55)
                ]),
            highlightFill: ThemeFill(stops: [
                    ThemeColor(hex: "#FFFFFF")!.withAlpha(0.16)
                ])
        ),
        keyArt: KeyArtSet(
            assetPrefix: "keyart_atl_",
            heightFraction: 0.52,
            bottomInsetFraction: 0.10,
            opacity: 0.90,
            fillKeys: ["space"],
            labelLiftFraction: 0.15
        ),
        effects: .none
    )

    static let azureSummerEscape = MochiKeyboardTheme(
        id: "mochi.azure-summer-escape",
        name: "Azure Summer Escape",
        authorName: "Mochi",
        appearance: .light,
        surface: ThemeSurface(
            baseFill: ThemeFill(stops: [
                    ThemeColor(hex: "#1C62BA")!,
                    ThemeColor(hex: "#B9D0E2")!,
                    ThemeColor(hex: "#FFF3DD")!
                ]),
            backgroundImage: ThemeBackgroundImage(
                source: .bundled(name: "themebg_azure_summer_escape"),
                scalesToFill: true,
                verticalAnchor: 0.5,
                blurRadius: 0.0
            ),
            scrim: ThemeScrim(
                topColor: ThemeColor(hex: "#9A9FA1")!.withAlpha(0.18),
                bottomColor: ThemeColor(hex: "#9A9FA1")!.withAlpha(0.05)
            )
        ),
        keyStyles: [
            .input: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#E3DBC3")!,
                    ThemeColor(hex: "#DBC4BA")!
                ]),
                labelColor: ThemeColor(hex: "#221C28")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#D6CFB7")!,
                    ThemeColor(hex: "#CBB6AD")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#221C28")!,
                border: ThemeBorder(color: ThemeColor(hex: "#FDFDFB")!.withAlpha(0.42), width: 0.95),
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
                    ThemeColor(hex: "#D9CDBB")!,
                    ThemeColor(hex: "#C9BEAD")!
                ]),
                labelColor: ThemeColor(hex: "#221C28")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#CBBFAF")!,
                    ThemeColor(hex: "#B8AE9F")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#221C28")!,
                border: ThemeBorder(color: ThemeColor(hex: "#FCFCFA")!.withAlpha(0.42), width: 0.95),
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
                    ThemeColor(hex: "#CFD9DE")!,
                    ThemeColor(hex: "#C1CACF")!
                ]),
                labelColor: ThemeColor(hex: "#221C28")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#C2CCD1")!,
                    ThemeColor(hex: "#B3BCC0")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#221C28")!,
                border: ThemeBorder(color: ThemeColor(hex: "#FCFDFD")!.withAlpha(0.42), width: 0.95),
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
                    ThemeColor(hex: "#E3DBC3")!.withAlpha(0.42),
                    ThemeColor(hex: "#DBC4BA")!.withAlpha(0.42)
                ]),
                labelColor: ThemeColor(hex: "#221C28")!.withAlpha(0.00),
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#D7D0B8")!.withAlpha(0.42),
                    ThemeColor(hex: "#CDB8AE")!.withAlpha(0.42)
                ]),
                border: ThemeBorder(color: ThemeColor(hex: "#FDFDFB")!.withAlpha(0.42), width: 0.95),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.15, radius: 2.20, offsetY: 1.30),
                topHighlight: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.46),
                cornerRadiusOverride: 16.0
            )
        ],
        typography: ThemeTypography(fontFamily: nil, weightRawValue: 0.34, sizeMultiplier: 1.0),
        chrome: ThemeChrome(
            inkColor: ThemeColor(hex: "#FFFFFF")!,
            mutedInkColor: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.55),
            panelFill: ThemeFill(stops: [
                    ThemeColor(hex: "#1E59A2")!.withAlpha(0.55)
                ]),
            highlightFill: ThemeFill(stops: [
                    ThemeColor(hex: "#FFFFFF")!.withAlpha(0.16)
                ])
        ),
        keyArt: KeyArtSet(
            assetPrefix: "keyart_aze_",
            heightFraction: 0.48,
            bottomInsetFraction: 0.09,
            opacity: 0.90,
            fillKeys: ["space"],
            labelLiftFraction: 0.14
        ),
        effects: .none
    )

    static let beyondTheHorizon = MochiKeyboardTheme(
        id: "mochi.beyond-the-horizon",
        name: "Beyond the Horizon",
        authorName: "Mochi",
        appearance: .dark,
        surface: ThemeSurface(
            baseFill: ThemeFill(stops: [
                    ThemeColor(hex: "#4E5D94")!,
                    ThemeColor(hex: "#060C1C")!,
                    ThemeColor(hex: "#181F32")!
                ]),
            backgroundImage: ThemeBackgroundImage(
                source: .bundled(name: "themebg_beyond_the_horizon"),
                scalesToFill: true,
                verticalAnchor: 0.5,
                blurRadius: 0.0
            ),
            scrim: ThemeScrim(
                topColor: ThemeColor(hex: "#222635")!.withAlpha(0.20),
                bottomColor: ThemeColor(hex: "#222635")!.withAlpha(0.06)
            )
        ),
        keyStyles: [
            .input: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#0C1121")!,
                    ThemeColor(hex: "#2C313F")!
                ]),
                labelColor: ThemeColor(hex: "#FFFFFF")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#585C66")!,
                    ThemeColor(hex: "#62656F")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#FFFFFF")!,
                border: ThemeBorder(color: ThemeColor(hex: "#D7D8DA")!.withAlpha(0.85), width: 1.00),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.32, radius: 2.60, offsetY: 1.60),
                topHighlight: ThemeColor(hex: "#BBBDC1")!.withAlpha(0.28),
                cornerRadiusOverride: 12.0,
                glass: KeyGlass(
                    bevelColor: ThemeColor(hex: "#C3C5C8")!.withAlpha(0.62),
                    bevelWidth: 1.00,
                    bevelFalloff: 0.12,
                    innerShadowColor: ThemeColor(hex: "#0A080F")!,
                    innerShadowOpacity: 0.36,
                    innerShadowRadius: 3.00
                )
            ),
            .system: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#3E434F")!,
                    ThemeColor(hex: "#4C505C")!
                ]),
                labelColor: ThemeColor(hex: "#FFFFFF")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#6A6E78")!,
                    ThemeColor(hex: "#73767F")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#FFFFFF")!,
                border: ThemeBorder(color: ThemeColor(hex: "#DEDFE1")!.withAlpha(0.85), width: 1.00),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.32, radius: 2.60, offsetY: 1.60),
                topHighlight: ThemeColor(hex: "#C3C5C8")!.withAlpha(0.28),
                cornerRadiusOverride: 12.0,
                glass: KeyGlass(
                    bevelColor: ThemeColor(hex: "#CBCCD0")!.withAlpha(0.62),
                    bevelWidth: 1.00,
                    bevelFalloff: 0.12,
                    innerShadowColor: ThemeColor(hex: "#0A080F")!,
                    innerShadowOpacity: 0.36,
                    innerShadowRadius: 3.00
                )
            ),
            .action: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#0C1121")!,
                    ThemeColor(hex: "#2C313F")!
                ]),
                labelColor: ThemeColor(hex: "#FFFFFF")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#585C66")!,
                    ThemeColor(hex: "#62656F")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#FFFFFF")!,
                border: ThemeBorder(color: ThemeColor(hex: "#D7D8DA")!.withAlpha(0.85), width: 1.00),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.32, radius: 2.60, offsetY: 1.60),
                topHighlight: ThemeColor(hex: "#BBBDC1")!.withAlpha(0.28),
                cornerRadiusOverride: 12.0,
                glass: KeyGlass(
                    bevelColor: ThemeColor(hex: "#C3C5C8")!.withAlpha(0.62),
                    bevelWidth: 1.00,
                    bevelFalloff: 0.12,
                    innerShadowColor: ThemeColor(hex: "#0A080F")!,
                    innerShadowOpacity: 0.36,
                    innerShadowRadius: 3.00
                )
            ),
            .space: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#0C1121")!.withAlpha(0.50),
                    ThemeColor(hex: "#2C313F")!.withAlpha(0.50)
                ]),
                labelColor: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.00),
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#4E535E")!.withAlpha(0.50),
                    ThemeColor(hex: "#5A5E68")!.withAlpha(0.50)
                ]),
                border: ThemeBorder(color: ThemeColor(hex: "#BBBDC1")!.withAlpha(0.60), width: 1.00),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.32, radius: 2.60, offsetY: 1.60),
                topHighlight: ThemeColor(hex: "#BBBDC1")!.withAlpha(0.28),
                cornerRadiusOverride: 14.0
            )
        ],
        typography: ThemeTypography(fontFamily: nil, weightRawValue: 0.34, sizeMultiplier: 1.0),
        chrome: ThemeChrome(
            inkColor: ThemeColor(hex: "#F2ECF0")!,
            mutedInkColor: ThemeColor(hex: "#F2ECF0")!.withAlpha(0.55),
            panelFill: ThemeFill(stops: [
                    ThemeColor(hex: "#555964")!.withAlpha(0.55)
                ]),
            highlightFill: ThemeFill(stops: [
                    ThemeColor(hex: "#FFFFFF")!.withAlpha(0.16)
                ])
        ),
        keyArt: KeyArtSet(
            assetPrefix: "keyart_bth_",
            heightFraction: 0.44,
            bottomInsetFraction: 0.09,
            opacity: 0.90,
            fillKeys: ["space"],
            labelLiftFraction: 0.14
        ),
        effects: .none
    )

    static let bionovaNexus = MochiKeyboardTheme(
        id: "mochi.bionova-nexus",
        name: "Bionova Nexus",
        authorName: "Mochi",
        appearance: .dark,
        surface: ThemeSurface(
            baseFill: ThemeFill(stops: [
                    ThemeColor(hex: "#0D3F40")!,
                    ThemeColor(hex: "#031C19")!,
                    ThemeColor(hex: "#051E23")!
                ]),
            backgroundImage: ThemeBackgroundImage(
                source: .bundled(name: "themebg_bionova_nexus"),
                scalesToFill: true,
                verticalAnchor: 0.5,
                blurRadius: 0.0
            ),
            scrim: ThemeScrim(
                topColor: ThemeColor(hex: "#0C2B2A")!.withAlpha(0.18),
                bottomColor: ThemeColor(hex: "#0C2B2A")!.withAlpha(0.05)
            )
        ),
        keyStyles: [
            .input: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#031716")!,
                    ThemeColor(hex: "#364745")!
                ]),
                labelColor: ThemeColor(hex: "#FFFFFF")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#515F5E")!,
                    ThemeColor(hex: "#647170")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#FFFFFF")!,
                border: ThemeBorder(color: ThemeColor(hex: "#C1C6C5")!.withAlpha(0.55), width: 1.00),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.26, radius: 1.60, offsetY: 1.60),
                topHighlight: ThemeColor(hex: "#B8BEBD")!.withAlpha(0.34),
                cornerRadiusOverride: 8.0,
                glass: KeyGlass(
                    bevelColor: ThemeColor(hex: "#C1C6C5")!.withAlpha(0.70),
                    bevelWidth: 1.00,
                    bevelFalloff: 0.10,
                    innerShadowColor: ThemeColor(hex: "#0A080F")!,
                    innerShadowOpacity: 0.16,
                    innerShadowRadius: 2.00
                )
            ),
            .system: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#364745")!,
                    ThemeColor(hex: "#515F5E")!
                ]),
                labelColor: ThemeColor(hex: "#FFFFFF")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#647170")!,
                    ThemeColor(hex: "#75807F")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#FFFFFF")!,
                border: ThemeBorder(color: ThemeColor(hex: "#C9CDCD")!.withAlpha(0.55), width: 1.00),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.26, radius: 1.60, offsetY: 1.60),
                topHighlight: ThemeColor(hex: "#C1C6C5")!.withAlpha(0.34),
                cornerRadiusOverride: 8.0,
                glass: KeyGlass(
                    bevelColor: ThemeColor(hex: "#C9CDCD")!.withAlpha(0.70),
                    bevelWidth: 1.00,
                    bevelFalloff: 0.10,
                    innerShadowColor: ThemeColor(hex: "#0A080F")!,
                    innerShadowOpacity: 0.16,
                    innerShadowRadius: 2.00
                )
            ),
            .action: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#031716")!,
                    ThemeColor(hex: "#364745")!
                ]),
                labelColor: ThemeColor(hex: "#FFFFFF")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#515F5E")!,
                    ThemeColor(hex: "#647170")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#FFFFFF")!,
                border: ThemeBorder(color: ThemeColor(hex: "#C1C6C5")!.withAlpha(0.55), width: 1.00),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.26, radius: 1.60, offsetY: 1.60),
                topHighlight: ThemeColor(hex: "#B8BEBD")!.withAlpha(0.34),
                cornerRadiusOverride: 8.0,
                glass: KeyGlass(
                    bevelColor: ThemeColor(hex: "#C1C6C5")!.withAlpha(0.70),
                    bevelWidth: 1.00,
                    bevelFalloff: 0.10,
                    innerShadowColor: ThemeColor(hex: "#0A080F")!,
                    innerShadowOpacity: 0.16,
                    innerShadowRadius: 2.00
                )
            ),
            .space: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#031716")!.withAlpha(0.50),
                    ThemeColor(hex: "#364745")!.withAlpha(0.50)
                ]),
                labelColor: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.00),
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#475655")!.withAlpha(0.50),
                    ThemeColor(hex: "#5D6A69")!.withAlpha(0.50)
                ]),
                border: ThemeBorder(color: ThemeColor(hex: "#B8BEBD")!.withAlpha(0.55), width: 1.00),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.26, radius: 1.60, offsetY: 1.60),
                topHighlight: ThemeColor(hex: "#B8BEBD")!.withAlpha(0.34),
                cornerRadiusOverride: 10.0
            )
        ],
        typography: ThemeTypography(fontFamily: nil, weightRawValue: 0.34, sizeMultiplier: 1.0),
        chrome: ThemeChrome(
            inkColor: ThemeColor(hex: "#F2ECF0")!,
            mutedInkColor: ThemeColor(hex: "#F2ECF0")!.withAlpha(0.55),
            panelFill: ThemeFill(stops: [
                    ThemeColor(hex: "#4B5D5B")!.withAlpha(0.55)
                ]),
            highlightFill: ThemeFill(stops: [
                    ThemeColor(hex: "#FFFFFF")!.withAlpha(0.16)
                ])
        ),
        keyArt: KeyArtSet(
            assetPrefix: "keyart_bnn_",
            heightFraction: 0.46,
            bottomInsetFraction: 0.09,
            opacity: 0.90,
            fillKeys: ["space"],
            labelLiftFraction: 0.14
        ),
        effects: .none
    )

    static let botanicalCafe = MochiKeyboardTheme(
        id: "mochi.botanical-cafe",
        name: "Botanical Cafe",
        authorName: "Mochi",
        appearance: .light,
        surface: ThemeSurface(
            baseFill: ThemeFill(stops: [
                    ThemeColor(hex: "#BCA071")!,
                    ThemeColor(hex: "#E0D49A")!,
                    ThemeColor(hex: "#F6DC9F")!
                ]),
            backgroundImage: ThemeBackgroundImage(
                source: .bundled(name: "themebg_botanical_cafe"),
                scalesToFill: true,
                verticalAnchor: 0.5,
                blurRadius: 0.0
            ),
            scrim: ThemeScrim(
                topColor: ThemeColor(hex: "#A39466")!.withAlpha(0.16),
                bottomColor: ThemeColor(hex: "#A39466")!.withAlpha(0.05)
            )
        ),
        keyStyles: [
            .input: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#D5C88B")!,
                    ThemeColor(hex: "#CFC287")!
                ]),
                labelColor: ThemeColor(hex: "#221C28")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#C5B980")!,
                    ThemeColor(hex: "#BFB37C")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#221C28")!,
                border: ThemeBorder(color: ThemeColor(hex: "#221C28")!.withAlpha(0.80), width: 1.70),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.00, radius: 0.00, offsetY: 0.00),
                topHighlight: nil,
                cornerRadiusOverride: 6.0
            ),
            .system: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#CBBE84")!,
                    ThemeColor(hex: "#C4B880")!
                ]),
                labelColor: ThemeColor(hex: "#221C28")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#BAAE79")!,
                    ThemeColor(hex: "#B3A774")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#221C28")!,
                border: ThemeBorder(color: ThemeColor(hex: "#221C28")!.withAlpha(0.80), width: 1.70),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.00, radius: 0.00, offsetY: 0.00),
                topHighlight: nil,
                cornerRadiusOverride: 6.0
            ),
            .action: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#D7C78F")!,
                    ThemeColor(hex: "#D1C18B")!
                ]),
                labelColor: ThemeColor(hex: "#221C28")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#C7B884")!,
                    ThemeColor(hex: "#C0B280")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#221C28")!,
                border: ThemeBorder(color: ThemeColor(hex: "#221C28")!.withAlpha(0.80), width: 1.70),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.00, radius: 0.00, offsetY: 0.00),
                topHighlight: nil,
                cornerRadiusOverride: 6.0
            ),
            .space: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#D5C88B")!.withAlpha(0.42),
                    ThemeColor(hex: "#CFC287")!.withAlpha(0.42)
                ]),
                labelColor: ThemeColor(hex: "#221C28")!.withAlpha(0.00),
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#C7BB82")!.withAlpha(0.42),
                    ThemeColor(hex: "#C1B57D")!.withAlpha(0.42)
                ]),
                border: ThemeBorder(color: ThemeColor(hex: "#F8F6EC")!.withAlpha(0.80), width: 1.70),
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
                    ThemeColor(hex: "#FDFCFA")!.withAlpha(0.55)
                ]),
            highlightFill: ThemeFill(stops: [
                    ThemeColor(hex: "#000000")!.withAlpha(0.16)
                ])
        ),
        keyArt: KeyArtSet(
            assetPrefix: "keyart_bca_",
            heightFraction: 0.40,
            bottomInsetFraction: 0.09,
            opacity: 0.90,
            fillKeys: ["space"],
            labelLiftFraction: 0.13
        ),
        effects: .none
    )

    static let canvasAndCoffee = MochiKeyboardTheme(
        id: "mochi.canvas-and-coffee",
        name: "Canvas & Coffee",
        authorName: "Mochi",
        appearance: .light,
        surface: ThemeSurface(
            baseFill: ThemeFill(stops: [
                    ThemeColor(hex: "#6E411C")!,
                    ThemeColor(hex: "#E6B779")!,
                    ThemeColor(hex: "#F6D099")!
                ]),
            backgroundImage: ThemeBackgroundImage(
                source: .bundled(name: "themebg_canvas_and_coffee"),
                scalesToFill: true,
                verticalAnchor: 0.5,
                blurRadius: 0.0
            ),
            scrim: ThemeScrim(
                topColor: ThemeColor(hex: "#AE8757")!.withAlpha(0.18),
                bottomColor: ThemeColor(hex: "#AE8757")!.withAlpha(0.05)
            )
        ),
        keyStyles: [
            .input: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#ECC38A")!,
                    ThemeColor(hex: "#E3BB84")!
                ]),
                labelColor: ThemeColor(hex: "#221C28")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#DBB580")!,
                    ThemeColor(hex: "#D1AD7A")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#221C28")!,
                border: ThemeBorder(color: ThemeColor(hex: "#A58860")!.withAlpha(0.32), width: 1.35),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.22, radius: 3.60, offsetY: 2.60),
                topHighlight: nil,
                cornerRadiusOverride: 9.0
            ),
            .system: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#E1BA83")!,
                    ThemeColor(hex: "#D7B27D")!
                ]),
                labelColor: ThemeColor(hex: "#221C28")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#CFAB79")!,
                    ThemeColor(hex: "#C4A272")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#221C28")!,
                border: ThemeBorder(color: ThemeColor(hex: "#9D815B")!.withAlpha(0.32), width: 1.35),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.22, radius: 3.60, offsetY: 2.60),
                topHighlight: nil,
                cornerRadiusOverride: 9.0
            ),
            .action: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#ECC38A")!,
                    ThemeColor(hex: "#E3BB84")!
                ]),
                labelColor: ThemeColor(hex: "#221C28")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#DBB580")!,
                    ThemeColor(hex: "#D1AD7A")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#221C28")!,
                border: ThemeBorder(color: ThemeColor(hex: "#A58860")!.withAlpha(0.32), width: 1.35),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.22, radius: 3.60, offsetY: 2.60),
                topHighlight: nil,
                cornerRadiusOverride: 9.0
            ),
            .space: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#ECC38A")!.withAlpha(0.42),
                    ThemeColor(hex: "#E3BB84")!.withAlpha(0.42)
                ]),
                labelColor: ThemeColor(hex: "#221C28")!.withAlpha(0.00),
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#DDB781")!.withAlpha(0.42),
                    ThemeColor(hex: "#D3AE7B")!.withAlpha(0.42)
                ]),
                border: ThemeBorder(color: ThemeColor(hex: "#FDF7F0")!.withAlpha(0.32), width: 1.35),
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
                    ThemeColor(hex: "#7A502C")!.withAlpha(0.55)
                ]),
            highlightFill: ThemeFill(stops: [
                    ThemeColor(hex: "#FFFFFF")!.withAlpha(0.16)
                ])
        ),
        keyArt: KeyArtSet(
            assetPrefix: "keyart_cnc_",
            heightFraction: 0.52,
            bottomInsetFraction: 0.10,
            opacity: 0.90,
            fillKeys: ["space"],
            labelLiftFraction: 0.15
        ),
        effects: .none
    )

    static let capturedMoments = MochiKeyboardTheme(
        id: "mochi.captured-moments",
        name: "Captured Moments",
        authorName: "Mochi",
        appearance: .light,
        surface: ThemeSurface(
            baseFill: ThemeFill(stops: [
                    ThemeColor(hex: "#371901")!,
                    ThemeColor(hex: "#E9C591")!,
                    ThemeColor(hex: "#9D5525")!
                ]),
            backgroundImage: ThemeBackgroundImage(
                source: .bundled(name: "themebg_captured_moments"),
                scalesToFill: true,
                verticalAnchor: 0.5,
                blurRadius: 0.0
            ),
            scrim: ThemeScrim(
                topColor: ThemeColor(hex: "#A9875D")!.withAlpha(0.18),
                bottomColor: ThemeColor(hex: "#A9875D")!.withAlpha(0.05)
            )
        ),
        keyStyles: [
            .input: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#E9C38E")!,
                    ThemeColor(hex: "#E0BC89")!
                ]),
                labelColor: ThemeColor(hex: "#221C28")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#D8B584")!,
                    ThemeColor(hex: "#CEAD7E")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#221C28")!,
                border: ThemeBorder(color: ThemeColor(hex: "#A28863")!.withAlpha(0.32), width: 1.35),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.22, radius: 3.60, offsetY: 2.60),
                topHighlight: nil,
                cornerRadiusOverride: 9.0
            ),
            .system: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#DEBA88")!,
                    ThemeColor(hex: "#D4B282")!
                ]),
                labelColor: ThemeColor(hex: "#221C28")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#CCAB7D")!,
                    ThemeColor(hex: "#C1A276")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#221C28")!,
                border: ThemeBorder(color: ThemeColor(hex: "#9B825E")!.withAlpha(0.32), width: 1.35),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.22, radius: 3.60, offsetY: 2.60),
                topHighlight: nil,
                cornerRadiusOverride: 9.0
            ),
            .action: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#E9C38E")!,
                    ThemeColor(hex: "#E0BC89")!
                ]),
                labelColor: ThemeColor(hex: "#221C28")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#D8B584")!,
                    ThemeColor(hex: "#CEAD7E")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#221C28")!,
                border: ThemeBorder(color: ThemeColor(hex: "#A28863")!.withAlpha(0.32), width: 1.35),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.22, radius: 3.60, offsetY: 2.60),
                topHighlight: nil,
                cornerRadiusOverride: 9.0
            ),
            .space: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#E9C38E")!.withAlpha(0.42),
                    ThemeColor(hex: "#E0BC89")!.withAlpha(0.42)
                ]),
                labelColor: ThemeColor(hex: "#221C28")!.withAlpha(0.00),
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#DAB785")!.withAlpha(0.42),
                    ThemeColor(hex: "#D0AE7F")!.withAlpha(0.42)
                ]),
                border: ThemeBorder(color: ThemeColor(hex: "#FCF7F0")!.withAlpha(0.32), width: 1.35),
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
                    ThemeColor(hex: "#6C5542")!.withAlpha(0.55)
                ]),
            highlightFill: ThemeFill(stops: [
                    ThemeColor(hex: "#FFFFFF")!.withAlpha(0.16)
                ])
        ),
        keyArt: KeyArtSet(
            assetPrefix: "keyart_cpm_",
            heightFraction: 0.52,
            bottomInsetFraction: 0.10,
            opacity: 0.90,
            fillKeys: ["space"],
            labelLiftFraction: 0.15
        ),
        effects: .none
    )

    static let cozyGardenCottage = MochiKeyboardTheme(
        id: "mochi.cozy-garden-cottage",
        name: "Cozy Garden Cottage",
        authorName: "Mochi",
        appearance: .light,
        surface: ThemeSurface(
            baseFill: ThemeFill(stops: [
                    ThemeColor(hex: "#E6DB9B")!,
                    ThemeColor(hex: "#D6CD8C")!,
                    ThemeColor(hex: "#F4DDA7")!
                ]),
            backgroundImage: ThemeBackgroundImage(
                source: .bundled(name: "themebg_cozy_garden_cottage"),
                scalesToFill: true,
                verticalAnchor: 0.5,
                blurRadius: 0.0
            ),
            scrim: ThemeScrim(
                topColor: ThemeColor(hex: "#9F9363")!.withAlpha(0.18),
                bottomColor: ThemeColor(hex: "#9F9363")!.withAlpha(0.05)
            )
        ),
        keyStyles: [
            .input: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#DFCE97")!,
                    ThemeColor(hex: "#D7C691")!
                ]),
                labelColor: ThemeColor(hex: "#221C28")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#D0C08C")!,
                    ThemeColor(hex: "#C7B786")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#221C28")!,
                border: ThemeBorder(color: ThemeColor(hex: "#9C9069")!.withAlpha(0.32), width: 1.35),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.22, radius: 3.60, offsetY: 2.60),
                topHighlight: nil,
                cornerRadiusOverride: 9.0
            ),
            .system: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#D5C590")!,
                    ThemeColor(hex: "#CDBD8A")!
                ]),
                labelColor: ThemeColor(hex: "#221C28")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#C5B685")!,
                    ThemeColor(hex: "#BCAD7F")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#221C28")!,
                border: ThemeBorder(color: ThemeColor(hex: "#958964")!.withAlpha(0.32), width: 1.35),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.22, radius: 3.60, offsetY: 2.60),
                topHighlight: nil,
                cornerRadiusOverride: 9.0
            ),
            .action: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#DFCE97")!,
                    ThemeColor(hex: "#D7C691")!
                ]),
                labelColor: ThemeColor(hex: "#221C28")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#D0C08C")!,
                    ThemeColor(hex: "#C7B786")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#221C28")!,
                border: ThemeBorder(color: ThemeColor(hex: "#9C9069")!.withAlpha(0.32), width: 1.35),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.22, radius: 3.60, offsetY: 2.60),
                topHighlight: nil,
                cornerRadiusOverride: 9.0
            ),
            .space: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#DFCE97")!.withAlpha(0.42),
                    ThemeColor(hex: "#D7C691")!.withAlpha(0.42)
                ]),
                labelColor: ThemeColor(hex: "#221C28")!.withAlpha(0.00),
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#D2C18E")!.withAlpha(0.42),
                    ThemeColor(hex: "#C9B988")!.withAlpha(0.42)
                ]),
                border: ThemeBorder(color: ThemeColor(hex: "#FDFCF8")!.withAlpha(0.32), width: 1.35),
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
                    ThemeColor(hex: "#FCFCF8")!.withAlpha(0.55)
                ]),
            highlightFill: ThemeFill(stops: [
                    ThemeColor(hex: "#000000")!.withAlpha(0.16)
                ])
        ),
        keyArt: KeyArtSet(
            assetPrefix: "keyart_cgc_",
            heightFraction: 0.52,
            bottomInsetFraction: 0.10,
            opacity: 0.90,
            fillKeys: ["space"],
            labelLiftFraction: 0.15
        ),
        effects: .none
    )

    static let creativeWorkspace = MochiKeyboardTheme(
        id: "mochi.creative-workspace",
        name: "Creative Workspace",
        authorName: "Mochi",
        appearance: .light,
        surface: ThemeSurface(
            baseFill: ThemeFill(stops: [
                    ThemeColor(hex: "#CFA577")!,
                    ThemeColor(hex: "#F5DAAF")!,
                    ThemeColor(hex: "#F8BE6A")!
                ]),
            backgroundImage: ThemeBackgroundImage(
                source: .bundled(name: "themebg_creative_workspace"),
                scalesToFill: true,
                verticalAnchor: 0.5,
                blurRadius: 0.0
            ),
            scrim: ThemeScrim(
                topColor: ThemeColor(hex: "#B29974")!.withAlpha(0.16),
                bottomColor: ThemeColor(hex: "#B29974")!.withAlpha(0.05)
            )
        ),
        keyStyles: [
            .input: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#E7C89C")!,
                    ThemeColor(hex: "#E1C398")!
                ]),
                labelColor: ThemeColor(hex: "#221C28")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#D7BA91")!,
                    ThemeColor(hex: "#D0B58C")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#221C28")!,
                border: ThemeBorder(color: ThemeColor(hex: "#221C28")!.withAlpha(0.80), width: 1.70),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.00, radius: 0.00, offsetY: 0.00),
                topHighlight: nil,
                cornerRadiusOverride: 6.0
            ),
            .system: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#DCBF95")!,
                    ThemeColor(hex: "#D6BA90")!
                ]),
                labelColor: ThemeColor(hex: "#221C28")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#CBB089")!,
                    ThemeColor(hex: "#C4AA84")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#221C28")!,
                border: ThemeBorder(color: ThemeColor(hex: "#221C28")!.withAlpha(0.80), width: 1.70),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.00, radius: 0.00, offsetY: 0.00),
                topHighlight: nil,
                cornerRadiusOverride: 6.0
            ),
            .action: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#E4C99D")!,
                    ThemeColor(hex: "#DEC499")!
                ]),
                labelColor: ThemeColor(hex: "#221C28")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#D4BB92")!,
                    ThemeColor(hex: "#CEB58E")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#221C28")!,
                border: ThemeBorder(color: ThemeColor(hex: "#221C28")!.withAlpha(0.80), width: 1.70),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.00, radius: 0.00, offsetY: 0.00),
                topHighlight: nil,
                cornerRadiusOverride: 6.0
            ),
            .space: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#E7C89C")!.withAlpha(0.42),
                    ThemeColor(hex: "#E1C398")!.withAlpha(0.42)
                ]),
                labelColor: ThemeColor(hex: "#221C28")!.withAlpha(0.00),
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#D9BC92")!.withAlpha(0.42),
                    ThemeColor(hex: "#D2B68E")!.withAlpha(0.42)
                ]),
                border: ThemeBorder(color: ThemeColor(hex: "#FDFAF6")!.withAlpha(0.80), width: 1.70),
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
                    ThemeColor(hex: "#FDFBFA")!.withAlpha(0.55)
                ]),
            highlightFill: ThemeFill(stops: [
                    ThemeColor(hex: "#000000")!.withAlpha(0.16)
                ])
        ),
        keyArt: KeyArtSet(
            assetPrefix: "keyart_crw_",
            heightFraction: 0.40,
            bottomInsetFraction: 0.09,
            opacity: 0.90,
            fillKeys: ["space"],
            labelLiftFraction: 0.13
        ),
        effects: .none
    )

    static let deepSeaExplorer = MochiKeyboardTheme(
        id: "mochi.deep-sea-explorer",
        name: "Deep Sea Explorer",
        authorName: "Mochi",
        appearance: .light,
        surface: ThemeSurface(
            baseFill: ThemeFill(stops: [
                    ThemeColor(hex: "#1C5D7B")!,
                    ThemeColor(hex: "#B1D0BF")!,
                    ThemeColor(hex: "#FBC773")!
                ]),
            backgroundImage: ThemeBackgroundImage(
                source: .bundled(name: "themebg_deep_sea_explorer"),
                scalesToFill: true,
                verticalAnchor: 0.5,
                blurRadius: 0.0
            ),
            scrim: ThemeScrim(
                topColor: ThemeColor(hex: "#7B9081")!.withAlpha(0.46),
                bottomColor: ThemeColor(hex: "#7B9081")!.withAlpha(0.34)
            )
        ),
        keyStyles: [
            .input: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#B8CFB9")!.withAlpha(0.73),
                    ThemeColor(hex: "#B1C6B2")!.withAlpha(0.73)
                ]),
                labelColor: ThemeColor(hex: "#221C28")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#ABC0AC")!.withAlpha(0.85),
                    ThemeColor(hex: "#A3B7A4")!.withAlpha(0.85)
                ]),
                pressedLabelColor: ThemeColor(hex: "#221C28")!,
                border: ThemeBorder(color: ThemeColor(hex: "#F5F8F5")!.withAlpha(0.50), width: 1.05),
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
                    ThemeColor(hex: "#B0C5B0")!.withAlpha(0.79),
                    ThemeColor(hex: "#A8BCA9")!.withAlpha(0.79)
                ]),
                labelColor: ThemeColor(hex: "#221C28")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#A1B5A2")!.withAlpha(0.91),
                    ThemeColor(hex: "#99AB99")!.withAlpha(0.91)
                ]),
                pressedLabelColor: ThemeColor(hex: "#221C28")!,
                border: ThemeBorder(color: ThemeColor(hex: "#ECF1ED")!.withAlpha(0.50), width: 1.05),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.17, radius: 1.90, offsetY: 1.10),
                topHighlight: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.50),
                cornerRadiusOverride: 13.0,
                glass: KeyGlass(
                    bevelColor: ThemeColor(hex: "#FBFCFB")!.withAlpha(0.74),
                    bevelWidth: 1.10,
                    bevelFalloff: 0.40,
                    innerShadowColor: ThemeColor(hex: "#0A080F")!,
                    innerShadowOpacity: 0.18,
                    innerShadowRadius: 2.60
                )
            ),
            .action: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#D5C8A3")!.withAlpha(0.79),
                    ThemeColor(hex: "#CDC09C")!.withAlpha(0.79)
                ]),
                labelColor: ThemeColor(hex: "#221C28")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#C6BA97")!.withAlpha(0.91),
                    ThemeColor(hex: "#BDB190")!.withAlpha(0.91)
                ]),
                pressedLabelColor: ThemeColor(hex: "#221C28")!,
                border: ThemeBorder(color: ThemeColor(hex: "#F9F7F2")!.withAlpha(0.50), width: 1.05),
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
                    ThemeColor(hex: "#B8CFB9")!.withAlpha(0.42),
                    ThemeColor(hex: "#B1C6B2")!.withAlpha(0.42)
                ]),
                labelColor: ThemeColor(hex: "#221C28")!.withAlpha(0.00),
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#ADC1AD")!.withAlpha(0.42),
                    ThemeColor(hex: "#A5B8A5")!.withAlpha(0.42)
                ]),
                border: ThemeBorder(color: ThemeColor(hex: "#F5F8F5")!.withAlpha(0.50), width: 1.05),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.17, radius: 1.90, offsetY: 1.10),
                topHighlight: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.50),
                cornerRadiusOverride: 15.0
            )
        ],
        typography: ThemeTypography(fontFamily: nil, weightRawValue: 0.34, sizeMultiplier: 1.0),
        chrome: ThemeChrome(
            inkColor: ThemeColor(hex: "#FFFFFF")!,
            mutedInkColor: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.55),
            panelFill: ThemeFill(stops: [
                    ThemeColor(hex: "#345F6C")!.withAlpha(0.55)
                ]),
            highlightFill: ThemeFill(stops: [
                    ThemeColor(hex: "#FFFFFF")!.withAlpha(0.16)
                ])
        ),
        keyArt: KeyArtSet(
            assetPrefix: "keyart_dse_",
            heightFraction: 0.46,
            bottomInsetFraction: 0.09,
            opacity: 0.90,
            fillKeys: ["space"],
            labelLiftFraction: 0.14
        ),
        effects: .none
    )

    static let dreamsInRewind = MochiKeyboardTheme(
        id: "mochi.dreams-in-rewind",
        name: "Dreams in Rewind",
        authorName: "Mochi",
        appearance: .dark,
        surface: ThemeSurface(
            baseFill: ThemeFill(stops: [
                    ThemeColor(hex: "#120E1F")!,
                    ThemeColor(hex: "#1F1331")!,
                    ThemeColor(hex: "#67226D")!
                ]),
            backgroundImage: ThemeBackgroundImage(
                source: .bundled(name: "themebg_dreams_in_rewind"),
                scalesToFill: true,
                verticalAnchor: 0.5,
                blurRadius: 0.0
            ),
            scrim: ThemeScrim(
                topColor: ThemeColor(hex: "#361C3F")!.withAlpha(0.18),
                bottomColor: ThemeColor(hex: "#361C3F")!.withAlpha(0.05)
            )
        ),
        keyStyles: [
            .input: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#170D22")!,
                    ThemeColor(hex: "#484050")!
                ]),
                labelColor: ThemeColor(hex: "#FFFFFF")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#605967")!,
                    ThemeColor(hex: "#726C78")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#FFFFFF")!,
                border: ThemeBorder(color: ThemeColor(hex: "#D9D7DB")!.withAlpha(0.80), width: 1.00),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.26, radius: 1.60, offsetY: 1.60),
                topHighlight: ThemeColor(hex: "#BEBCC1")!.withAlpha(0.34),
                cornerRadiusOverride: 8.0,
                glass: KeyGlass(
                    bevelColor: ThemeColor(hex: "#C6C4C9")!.withAlpha(0.70),
                    bevelWidth: 1.00,
                    bevelFalloff: 0.10,
                    innerShadowColor: ThemeColor(hex: "#0A080F")!,
                    innerShadowOpacity: 0.16,
                    innerShadowRadius: 2.00
                )
            ),
            .system: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#484050")!,
                    ThemeColor(hex: "#605967")!
                ]),
                labelColor: ThemeColor(hex: "#FFFFFF")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#726C78")!,
                    ThemeColor(hex: "#817B86")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#FFFFFF")!,
                border: ThemeBorder(color: ThemeColor(hex: "#E0DEE1")!.withAlpha(0.80), width: 1.00),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.26, radius: 1.60, offsetY: 1.60),
                topHighlight: ThemeColor(hex: "#C6C4C9")!.withAlpha(0.34),
                cornerRadiusOverride: 8.0,
                glass: KeyGlass(
                    bevelColor: ThemeColor(hex: "#CECCD0")!.withAlpha(0.70),
                    bevelWidth: 1.00,
                    bevelFalloff: 0.10,
                    innerShadowColor: ThemeColor(hex: "#0A080F")!,
                    innerShadowOpacity: 0.16,
                    innerShadowRadius: 2.00
                )
            ),
            .action: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#1F0B1A")!,
                    ThemeColor(hex: "#4E3E4A")!
                ]),
                labelColor: ThemeColor(hex: "#FFFFFF")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#665862")!,
                    ThemeColor(hex: "#776B74")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#FFFFFF")!,
                border: ThemeBorder(color: ThemeColor(hex: "#DAD7D9")!.withAlpha(0.80), width: 1.00),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.26, radius: 1.60, offsetY: 1.60),
                topHighlight: ThemeColor(hex: "#C1BBBF")!.withAlpha(0.34),
                cornerRadiusOverride: 8.0,
                glass: KeyGlass(
                    bevelColor: ThemeColor(hex: "#C8C3C7")!.withAlpha(0.70),
                    bevelWidth: 1.00,
                    bevelFalloff: 0.10,
                    innerShadowColor: ThemeColor(hex: "#0A080F")!,
                    innerShadowOpacity: 0.16,
                    innerShadowRadius: 2.00
                )
            ),
            .space: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#170D22")!.withAlpha(0.50),
                    ThemeColor(hex: "#484050")!.withAlpha(0.50)
                ]),
                labelColor: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.00),
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#57505F")!.withAlpha(0.50),
                    ThemeColor(hex: "#6B6572")!.withAlpha(0.50)
                ]),
                border: ThemeBorder(color: ThemeColor(hex: "#BEBCC1")!.withAlpha(0.55), width: 1.00),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.26, radius: 1.60, offsetY: 1.60),
                topHighlight: ThemeColor(hex: "#BEBCC1")!.withAlpha(0.34),
                cornerRadiusOverride: 10.0
            )
        ],
        typography: ThemeTypography(fontFamily: nil, weightRawValue: 0.34, sizeMultiplier: 1.0),
        chrome: ThemeChrome(
            inkColor: ThemeColor(hex: "#F2ECF0")!,
            mutedInkColor: ThemeColor(hex: "#F2ECF0")!.withAlpha(0.55),
            panelFill: ThemeFill(stops: [
                    ThemeColor(hex: "#5B5764")!.withAlpha(0.55)
                ]),
            highlightFill: ThemeFill(stops: [
                    ThemeColor(hex: "#FFFFFF")!.withAlpha(0.16)
                ])
        ),
        keyArt: KeyArtSet(
            assetPrefix: "keyart_dir_",
            heightFraction: 0.46,
            bottomInsetFraction: 0.09,
            opacity: 0.90,
            fillKeys: ["space"],
            labelLiftFraction: 0.14
        ),
        effects: .none
    )

    static let emberwatchObservatory = MochiKeyboardTheme(
        id: "mochi.emberwatch-observatory",
        name: "Emberwatch Observatory",
        authorName: "Mochi",
        appearance: .dark,
        surface: ThemeSurface(
            baseFill: ThemeFill(stops: [
                    ThemeColor(hex: "#321C21")!,
                    ThemeColor(hex: "#271008")!,
                    ThemeColor(hex: "#A2563F")!
                ]),
            backgroundImage: ThemeBackgroundImage(
                source: .bundled(name: "themebg_emberwatch_observatory"),
                scalesToFill: true,
                verticalAnchor: 0.5,
                blurRadius: 0.0
            ),
            scrim: ThemeScrim(
                topColor: ThemeColor(hex: "#3E1E13")!.withAlpha(0.20),
                bottomColor: ThemeColor(hex: "#3E1E13")!.withAlpha(0.06)
            )
        ),
        keyStyles: [
            .input: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#1F0D06")!,
                    ThemeColor(hex: "#3E2E28")!
                ]),
                labelColor: ThemeColor(hex: "#FFFFFF")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#665954")!,
                    ThemeColor(hex: "#6F635F")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#FFFFFF")!,
                border: ThemeBorder(color: ThemeColor(hex: "#DAD7D6")!.withAlpha(0.85), width: 1.00),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.32, radius: 2.60, offsetY: 1.60),
                topHighlight: ThemeColor(hex: "#C1BCBA")!.withAlpha(0.28),
                cornerRadiusOverride: 12.0,
                glass: KeyGlass(
                    bevelColor: ThemeColor(hex: "#C8C4C2")!.withAlpha(0.62),
                    bevelWidth: 1.00,
                    bevelFalloff: 0.12,
                    innerShadowColor: ThemeColor(hex: "#0A080F")!,
                    innerShadowOpacity: 0.36,
                    innerShadowRadius: 3.00
                )
            ),
            .system: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#4E403A")!,
                    ThemeColor(hex: "#5B4E49")!
                ]),
                labelColor: ThemeColor(hex: "#FFFFFF")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#776C68")!,
                    ThemeColor(hex: "#7E7470")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#FFFFFF")!,
                border: ThemeBorder(color: ThemeColor(hex: "#E1DEDD")!.withAlpha(0.85), width: 1.00),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.32, radius: 2.60, offsetY: 1.60),
                topHighlight: ThemeColor(hex: "#C8C4C2")!.withAlpha(0.28),
                cornerRadiusOverride: 12.0,
                glass: KeyGlass(
                    bevelColor: ThemeColor(hex: "#CFCCCA")!.withAlpha(0.62),
                    bevelWidth: 1.00,
                    bevelFalloff: 0.12,
                    innerShadowColor: ThemeColor(hex: "#0A080F")!,
                    innerShadowOpacity: 0.36,
                    innerShadowRadius: 3.00
                )
            ),
            .action: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#200D05")!,
                    ThemeColor(hex: "#3F2E27")!
                ]),
                labelColor: ThemeColor(hex: "#FFFFFF")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#665954")!,
                    ThemeColor(hex: "#70635E")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#FFFFFF")!,
                border: ThemeBorder(color: ThemeColor(hex: "#DBD7D6")!.withAlpha(0.85), width: 1.00),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.32, radius: 2.60, offsetY: 1.60),
                topHighlight: ThemeColor(hex: "#C1BBB9")!.withAlpha(0.28),
                cornerRadiusOverride: 12.0,
                glass: KeyGlass(
                    bevelColor: ThemeColor(hex: "#C9C4C2")!.withAlpha(0.62),
                    bevelWidth: 1.00,
                    bevelFalloff: 0.12,
                    innerShadowColor: ThemeColor(hex: "#0A080F")!,
                    innerShadowOpacity: 0.36,
                    innerShadowRadius: 3.00
                )
            ),
            .space: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#1F0D06")!.withAlpha(0.50),
                    ThemeColor(hex: "#3E2E28")!.withAlpha(0.50)
                ]),
                labelColor: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.00),
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#5D504B")!.withAlpha(0.50),
                    ThemeColor(hex: "#685B56")!.withAlpha(0.50)
                ]),
                border: ThemeBorder(color: ThemeColor(hex: "#C1BCBA")!.withAlpha(0.60), width: 1.00),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.32, radius: 2.60, offsetY: 1.60),
                topHighlight: ThemeColor(hex: "#C1BCBA")!.withAlpha(0.28),
                cornerRadiusOverride: 14.0
            )
        ],
        typography: ThemeTypography(fontFamily: nil, weightRawValue: 0.34, sizeMultiplier: 1.0),
        chrome: ThemeChrome(
            inkColor: ThemeColor(hex: "#F2ECF0")!,
            mutedInkColor: ThemeColor(hex: "#F2ECF0")!.withAlpha(0.55),
            panelFill: ThemeFill(stops: [
                    ThemeColor(hex: "#665650")!.withAlpha(0.55)
                ]),
            highlightFill: ThemeFill(stops: [
                    ThemeColor(hex: "#FFFFFF")!.withAlpha(0.16)
                ])
        ),
        keyArt: KeyArtSet(
            assetPrefix: "keyart_emo_",
            heightFraction: 0.44,
            bottomInsetFraction: 0.09,
            opacity: 0.90,
            fillKeys: ["space"],
            labelLiftFraction: 0.14
        ),
        effects: .none
    )

    static let goldenMidway = MochiKeyboardTheme(
        id: "mochi.golden-midway",
        name: "Golden Midway",
        authorName: "Mochi",
        appearance: .light,
        surface: ThemeSurface(
            baseFill: ThemeFill(stops: [
                    ThemeColor(hex: "#E69144")!,
                    ThemeColor(hex: "#97632A")!,
                    ThemeColor(hex: "#D0903E")!
                ]),
            backgroundImage: ThemeBackgroundImage(
                source: .bundled(name: "themebg_golden_midway"),
                scalesToFill: true,
                verticalAnchor: 0.5,
                blurRadius: 0.0
            ),
            scrim: ThemeScrim(
                topColor: ThemeColor(hex: "#794F23")!.withAlpha(0.18),
                bottomColor: ThemeColor(hex: "#794F23")!.withAlpha(0.05)
            )
        ),
        keyStyles: [
            .input: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#D9AD78")!,
                    ThemeColor(hex: "#CCA271")!
                ]),
                labelColor: ThemeColor(hex: "#0D0B0F")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#C59D6D")!,
                    ThemeColor(hex: "#B69164")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#0D0B0F")!,
                border: ThemeBorder(color: ThemeColor(hex: "#977853")!.withAlpha(0.40), width: 1.15),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.30, radius: 4.20, offsetY: 3.00),
                topHighlight: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.62),
                cornerRadiusOverride: 19.0,
                glass: KeyGlass(
                    bevelColor: ThemeColor(hex: "#FAF4ED")!.withAlpha(0.00),
                    bevelWidth: 0.00,
                    bevelFalloff: 0.50,
                    innerShadowColor: ThemeColor(hex: "#FDFAF7")!,
                    innerShadowOpacity: 0.34,
                    innerShadowRadius: 3.20
                )
            ),
            .system: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#CCA271")!,
                    ThemeColor(hex: "#BE9769")!
                ]),
                labelColor: ThemeColor(hex: "#0D0B0F")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#B69164")!,
                    ThemeColor(hex: "#A5835B")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#0D0B0F")!,
                border: ThemeBorder(color: ThemeColor(hex: "#8E714E")!.withAlpha(0.40), width: 1.15),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.30, radius: 4.20, offsetY: 3.00),
                topHighlight: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.62),
                cornerRadiusOverride: 19.0,
                glass: KeyGlass(
                    bevelColor: ThemeColor(hex: "#F5ECE2")!.withAlpha(0.00),
                    bevelWidth: 0.00,
                    bevelFalloff: 0.50,
                    innerShadowColor: ThemeColor(hex: "#F8F3EC")!,
                    innerShadowOpacity: 0.34,
                    innerShadowRadius: 3.20
                )
            ),
            .action: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#C5B19D")!,
                    ThemeColor(hex: "#B9A794")!
                ]),
                labelColor: ThemeColor(hex: "#0D0B0F")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#B3A18F")!,
                    ThemeColor(hex: "#A59484")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#0D0B0F")!,
                border: ThemeBorder(color: ThemeColor(hex: "#897B6D")!.withAlpha(0.40), width: 1.15),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.30, radius: 4.20, offsetY: 3.00),
                topHighlight: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.62),
                cornerRadiusOverride: 19.0,
                glass: KeyGlass(
                    bevelColor: ThemeColor(hex: "#F7F4F1")!.withAlpha(0.00),
                    bevelWidth: 0.00,
                    bevelFalloff: 0.50,
                    innerShadowColor: ThemeColor(hex: "#FCFAF9")!,
                    innerShadowOpacity: 0.34,
                    innerShadowRadius: 3.20
                )
            ),
            .space: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#D9AD78")!.withAlpha(0.42),
                    ThemeColor(hex: "#CCA271")!.withAlpha(0.42)
                ]),
                labelColor: ThemeColor(hex: "#0D0B0F")!.withAlpha(0.00),
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#C79F6E")!.withAlpha(0.42),
                    ThemeColor(hex: "#B99366")!.withAlpha(0.42)
                ]),
                border: ThemeBorder(color: ThemeColor(hex: "#F4E7D7")!.withAlpha(0.40), width: 1.15),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.30, radius: 4.20, offsetY: 3.00),
                topHighlight: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.62),
                cornerRadiusOverride: 20.0
            )
        ],
        typography: ThemeTypography(fontFamily: nil, weightRawValue: 0.34, sizeMultiplier: 1.0),
        chrome: ThemeChrome(
            inkColor: ThemeColor(hex: "#FFFFFF")!,
            mutedInkColor: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.55),
            panelFill: ThemeFill(stops: [
                    ThemeColor(hex: "#7A5022")!.withAlpha(0.55)
                ]),
            highlightFill: ThemeFill(stops: [
                    ThemeColor(hex: "#FFFFFF")!.withAlpha(0.16)
                ])
        ),
        keyArt: KeyArtSet(
            assetPrefix: "keyart_gdm_",
            heightFraction: 0.50,
            bottomInsetFraction: 0.10,
            opacity: 0.90,
            fillKeys: ["space"],
            labelLiftFraction: 0.15
        ),
        effects: .none
    )

    static let ironAndEmberLoft = MochiKeyboardTheme(
        id: "mochi.iron-and-ember-loft",
        name: "Iron & Ember Loft",
        authorName: "Mochi",
        appearance: .dark,
        surface: ThemeSurface(
            baseFill: ThemeFill(stops: [
                    ThemeColor(hex: "#1C1711")!,
                    ThemeColor(hex: "#252120")!,
                    ThemeColor(hex: "#6F462B")!
                ]),
            backgroundImage: ThemeBackgroundImage(
                source: .bundled(name: "themebg_iron_and_ember_loft"),
                scalesToFill: true,
                verticalAnchor: 0.5,
                blurRadius: 0.0
            ),
            scrim: ThemeScrim(
                topColor: ThemeColor(hex: "#2F251E")!.withAlpha(0.18),
                bottomColor: ThemeColor(hex: "#2F251E")!.withAlpha(0.05)
            )
        ),
        keyStyles: [
            .input: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#1A1714")!,
                    ThemeColor(hex: "#474442")!
                ]),
                labelColor: ThemeColor(hex: "#FFFFFF")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#5E5C5B")!,
                    ThemeColor(hex: "#716F6D")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#FFFFFF")!,
                border: ThemeBorder(color: ThemeColor(hex: "#C6C5C4")!.withAlpha(0.55), width: 1.00),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.26, radius: 1.60, offsetY: 1.60),
                topHighlight: ThemeColor(hex: "#BEBDBC")!.withAlpha(0.34),
                cornerRadiusOverride: 8.0,
                glass: KeyGlass(
                    bevelColor: ThemeColor(hex: "#C6C5C4")!.withAlpha(0.70),
                    bevelWidth: 1.00,
                    bevelFalloff: 0.10,
                    innerShadowColor: ThemeColor(hex: "#0A080F")!,
                    innerShadowOpacity: 0.16,
                    innerShadowRadius: 2.00
                )
            ),
            .system: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#474442")!,
                    ThemeColor(hex: "#5E5C5B")!
                ]),
                labelColor: ThemeColor(hex: "#FFFFFF")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#716F6D")!,
                    ThemeColor(hex: "#7F7E7C")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#FFFFFF")!,
                border: ThemeBorder(color: ThemeColor(hex: "#CDCDCC")!.withAlpha(0.55), width: 1.00),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.26, radius: 1.60, offsetY: 1.60),
                topHighlight: ThemeColor(hex: "#C6C5C4")!.withAlpha(0.34),
                cornerRadiusOverride: 8.0,
                glass: KeyGlass(
                    bevelColor: ThemeColor(hex: "#CDCDCC")!.withAlpha(0.70),
                    bevelWidth: 1.00,
                    bevelFalloff: 0.10,
                    innerShadowColor: ThemeColor(hex: "#0A080F")!,
                    innerShadowOpacity: 0.16,
                    innerShadowRadius: 2.00
                )
            ),
            .action: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#1F150F")!,
                    ThemeColor(hex: "#4B433E")!
                ]),
                labelColor: ThemeColor(hex: "#FFFFFF")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#625B57")!,
                    ThemeColor(hex: "#746E6A")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#FFFFFF")!,
                border: ThemeBorder(color: ThemeColor(hex: "#C7C5C3")!.withAlpha(0.55), width: 1.00),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.26, radius: 1.60, offsetY: 1.60),
                topHighlight: ThemeColor(hex: "#BFBCBB")!.withAlpha(0.34),
                cornerRadiusOverride: 8.0,
                glass: KeyGlass(
                    bevelColor: ThemeColor(hex: "#C7C5C3")!.withAlpha(0.70),
                    bevelWidth: 1.00,
                    bevelFalloff: 0.10,
                    innerShadowColor: ThemeColor(hex: "#0A080F")!,
                    innerShadowOpacity: 0.16,
                    innerShadowRadius: 2.00
                )
            ),
            .space: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#1A1714")!.withAlpha(0.50),
                    ThemeColor(hex: "#474442")!.withAlpha(0.50)
                ]),
                labelColor: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.00),
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#565452")!.withAlpha(0.50),
                    ThemeColor(hex: "#6A6866")!.withAlpha(0.50)
                ]),
                border: ThemeBorder(color: ThemeColor(hex: "#BEBDBC")!.withAlpha(0.55), width: 1.00),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.26, radius: 1.60, offsetY: 1.60),
                topHighlight: ThemeColor(hex: "#BEBDBC")!.withAlpha(0.34),
                cornerRadiusOverride: 10.0
            )
        ],
        typography: ThemeTypography(fontFamily: nil, weightRawValue: 0.34, sizeMultiplier: 1.0),
        chrome: ThemeChrome(
            inkColor: ThemeColor(hex: "#F2ECF0")!,
            mutedInkColor: ThemeColor(hex: "#F2ECF0")!.withAlpha(0.55),
            panelFill: ThemeFill(stops: [
                    ThemeColor(hex: "#5C5954")!.withAlpha(0.55)
                ]),
            highlightFill: ThemeFill(stops: [
                    ThemeColor(hex: "#FFFFFF")!.withAlpha(0.16)
                ])
        ),
        keyArt: KeyArtSet(
            assetPrefix: "keyart_iel_",
            heightFraction: 0.46,
            bottomInsetFraction: 0.09,
            opacity: 0.90,
            fillKeys: ["space"],
            labelLiftFraction: 0.14
        ),
        effects: .none
    )

    static let japaneseZen = MochiKeyboardTheme(
        id: "mochi.japanese-zen",
        name: "Japanese Zen",
        authorName: "Mochi",
        appearance: .light,
        surface: ThemeSurface(
            baseFill: ThemeFill(stops: [
                    ThemeColor(hex: "#576149")!,
                    ThemeColor(hex: "#CDC78D")!,
                    ThemeColor(hex: "#92674D")!
                ]),
            backgroundImage: ThemeBackgroundImage(
                source: .bundled(name: "themebg_japanese_zen"),
                scalesToFill: true,
                verticalAnchor: 0.5,
                blurRadius: 0.0
            ),
            scrim: ThemeScrim(
                topColor: ThemeColor(hex: "#948B5E")!.withAlpha(0.16),
                bottomColor: ThemeColor(hex: "#948B5E")!.withAlpha(0.05)
            )
        ),
        keyStyles: [
            .input: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#C8C085")!,
                    ThemeColor(hex: "#C2BB81")!
                ]),
                labelColor: ThemeColor(hex: "#221C28")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#B8B17A")!,
                    ThemeColor(hex: "#B1AA75")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#221C28")!,
                border: ThemeBorder(color: ThemeColor(hex: "#221C28")!.withAlpha(0.80), width: 1.70),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.00, radius: 0.00, offsetY: 0.00),
                topHighlight: nil,
                cornerRadiusOverride: 6.0
            ),
            .system: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#BEB67E")!,
                    ThemeColor(hex: "#B7B079")!
                ]),
                labelColor: ThemeColor(hex: "#221C28")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#ACA572")!,
                    ThemeColor(hex: "#A49E6D")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#221C28")!,
                border: ThemeBorder(color: ThemeColor(hex: "#221C28")!.withAlpha(0.80), width: 1.70),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.00, radius: 0.00, offsetY: 0.00),
                topHighlight: nil,
                cornerRadiusOverride: 6.0
            ),
            .action: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#CDBF86")!,
                    ThemeColor(hex: "#C7B982")!
                ]),
                labelColor: ThemeColor(hex: "#221C28")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#BCAF7B")!,
                    ThemeColor(hex: "#B5A976")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#221C28")!,
                border: ThemeBorder(color: ThemeColor(hex: "#221C28")!.withAlpha(0.80), width: 1.70),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.00, radius: 0.00, offsetY: 0.00),
                topHighlight: nil,
                cornerRadiusOverride: 6.0
            ),
            .space: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#C8C085")!.withAlpha(0.42),
                    ThemeColor(hex: "#C2BB81")!.withAlpha(0.42)
                ]),
                labelColor: ThemeColor(hex: "#221C28")!.withAlpha(0.00),
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#BAB37B")!.withAlpha(0.42),
                    ThemeColor(hex: "#B3AC77")!.withAlpha(0.42)
                ]),
                border: ThemeBorder(color: ThemeColor(hex: "#F2F0E2")!.withAlpha(0.80), width: 1.70),
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
                    ThemeColor(hex: "#545C45")!.withAlpha(0.55)
                ]),
            highlightFill: ThemeFill(stops: [
                    ThemeColor(hex: "#FFFFFF")!.withAlpha(0.16)
                ])
        ),
        keyArt: KeyArtSet(
            assetPrefix: "keyart_jpz_",
            heightFraction: 0.40,
            bottomInsetFraction: 0.09,
            opacity: 0.90,
            fillKeys: ["space"],
            labelLiftFraction: 0.13
        ),
        effects: .none
    )

    static let midnightCarnival = MochiKeyboardTheme(
        id: "mochi.midnight-carnival",
        name: "Midnight Carnival",
        authorName: "Mochi",
        appearance: .dark,
        surface: ThemeSurface(
            baseFill: ThemeFill(stops: [
                    ThemeColor(hex: "#1D0D06")!,
                    ThemeColor(hex: "#241109")!,
                    ThemeColor(hex: "#723413")!
                ]),
            backgroundImage: ThemeBackgroundImage(
                source: .bundled(name: "themebg_midnight_carnival"),
                scalesToFill: true,
                verticalAnchor: 0.5,
                blurRadius: 0.0
            ),
            scrim: ThemeScrim(
                topColor: ThemeColor(hex: "#372117")!.withAlpha(0.20),
                bottomColor: ThemeColor(hex: "#372117")!.withAlpha(0.06)
            )
        ),
        keyStyles: [
            .input: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#1E0E07")!,
                    ThemeColor(hex: "#3C2E29")!
                ]),
                labelColor: ThemeColor(hex: "#FFFFFF")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#645955")!,
                    ThemeColor(hex: "#6E635F")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#FFFFFF")!,
                border: ThemeBorder(color: ThemeColor(hex: "#DAD7D6")!.withAlpha(0.85), width: 1.00),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.32, radius: 2.60, offsetY: 1.60),
                topHighlight: ThemeColor(hex: "#C0BCBA")!.withAlpha(0.28),
                cornerRadiusOverride: 12.0,
                glass: KeyGlass(
                    bevelColor: ThemeColor(hex: "#C8C4C2")!.withAlpha(0.62),
                    bevelWidth: 1.00,
                    bevelFalloff: 0.12,
                    innerShadowColor: ThemeColor(hex: "#0A080F")!,
                    innerShadowOpacity: 0.36,
                    innerShadowRadius: 3.00
                )
            ),
            .system: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#4D403B")!,
                    ThemeColor(hex: "#5A4E49")!
                ]),
                labelColor: ThemeColor(hex: "#FFFFFF")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#766C68")!,
                    ThemeColor(hex: "#7D7470")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#FFFFFF")!,
                border: ThemeBorder(color: ThemeColor(hex: "#E0DEDD")!.withAlpha(0.85), width: 1.00),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.32, radius: 2.60, offsetY: 1.60),
                topHighlight: ThemeColor(hex: "#C8C4C2")!.withAlpha(0.28),
                cornerRadiusOverride: 12.0,
                glass: KeyGlass(
                    bevelColor: ThemeColor(hex: "#CFCCCA")!.withAlpha(0.62),
                    bevelWidth: 1.00,
                    bevelFalloff: 0.12,
                    innerShadowColor: ThemeColor(hex: "#0A080F")!,
                    innerShadowOpacity: 0.36,
                    innerShadowRadius: 3.00
                )
            ),
            .action: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#1E0E07")!,
                    ThemeColor(hex: "#3C2E28")!
                ]),
                labelColor: ThemeColor(hex: "#FFFFFF")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#645955")!,
                    ThemeColor(hex: "#6E635F")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#FFFFFF")!,
                border: ThemeBorder(color: ThemeColor(hex: "#DAD7D6")!.withAlpha(0.85), width: 1.00),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.32, radius: 2.60, offsetY: 1.60),
                topHighlight: ThemeColor(hex: "#C0BCBA")!.withAlpha(0.28),
                cornerRadiusOverride: 12.0,
                glass: KeyGlass(
                    bevelColor: ThemeColor(hex: "#C8C4C2")!.withAlpha(0.62),
                    bevelWidth: 1.00,
                    bevelFalloff: 0.12,
                    innerShadowColor: ThemeColor(hex: "#0A080F")!,
                    innerShadowOpacity: 0.36,
                    innerShadowRadius: 3.00
                )
            ),
            .space: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#1E0E07")!.withAlpha(0.50),
                    ThemeColor(hex: "#3C2E29")!.withAlpha(0.50)
                ]),
                labelColor: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.00),
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#5C504C")!.withAlpha(0.50),
                    ThemeColor(hex: "#665C57")!.withAlpha(0.50)
                ]),
                border: ThemeBorder(color: ThemeColor(hex: "#C0BCBA")!.withAlpha(0.60), width: 1.00),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.32, radius: 2.60, offsetY: 1.60),
                topHighlight: ThemeColor(hex: "#C0BCBA")!.withAlpha(0.28),
                cornerRadiusOverride: 14.0
            )
        ],
        typography: ThemeTypography(fontFamily: nil, weightRawValue: 0.34, sizeMultiplier: 1.0),
        chrome: ThemeChrome(
            inkColor: ThemeColor(hex: "#F2ECF0")!,
            mutedInkColor: ThemeColor(hex: "#F2ECF0")!.withAlpha(0.55),
            panelFill: ThemeFill(stops: [
                    ThemeColor(hex: "#625752")!.withAlpha(0.55)
                ]),
            highlightFill: ThemeFill(stops: [
                    ThemeColor(hex: "#FFFFFF")!.withAlpha(0.16)
                ])
        ),
        keyArt: KeyArtSet(
            assetPrefix: "keyart_mnc_",
            heightFraction: 0.44,
            bottomInsetFraction: 0.09,
            opacity: 0.90,
            fillKeys: ["space"],
            labelLiftFraction: 0.14
        ),
        effects: .none
    )

    static let midnightVoyage = MochiKeyboardTheme(
        id: "mochi.midnight-voyage",
        name: "Midnight Voyage",
        authorName: "Mochi",
        appearance: .light,
        surface: ThemeSurface(
            baseFill: ThemeFill(stops: [
                    ThemeColor(hex: "#AA6852")!,
                    ThemeColor(hex: "#E1B683")!,
                    ThemeColor(hex: "#B58358")!
                ]),
            backgroundImage: ThemeBackgroundImage(
                source: .bundled(name: "themebg_midnight_voyage"),
                scalesToFill: true,
                verticalAnchor: 0.5,
                blurRadius: 0.0
            ),
            scrim: ThemeScrim(
                topColor: ThemeColor(hex: "#9F815F")!.withAlpha(0.46),
                bottomColor: ThemeColor(hex: "#9F815F")!.withAlpha(0.34)
            )
        ),
        keyStyles: [
            .input: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#DFC092")!.withAlpha(0.73),
                    ThemeColor(hex: "#D6B88C")!.withAlpha(0.73)
                ]),
                labelColor: ThemeColor(hex: "#221C28")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#CEB186")!.withAlpha(0.85),
                    ThemeColor(hex: "#C4A880")!.withAlpha(0.85)
                ]),
                pressedLabelColor: ThemeColor(hex: "#221C28")!,
                border: ThemeBorder(color: ThemeColor(hex: "#F9F3EB")!.withAlpha(0.50), width: 1.05),
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
                    ThemeColor(hex: "#D4B68A")!.withAlpha(0.79),
                    ThemeColor(hex: "#CAAE84")!.withAlpha(0.79)
                ]),
                labelColor: ThemeColor(hex: "#221C28")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#C1A67E")!.withAlpha(0.91),
                    ThemeColor(hex: "#B69D77")!.withAlpha(0.91)
                ]),
                pressedLabelColor: ThemeColor(hex: "#221C28")!,
                border: ThemeBorder(color: ThemeColor(hex: "#F4ECE0")!.withAlpha(0.50), width: 1.05),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.17, radius: 1.90, offsetY: 1.10),
                topHighlight: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.50),
                cornerRadiusOverride: 13.0,
                glass: KeyGlass(
                    bevelColor: ThemeColor(hex: "#FBF8F4")!.withAlpha(0.74),
                    bevelWidth: 1.10,
                    bevelFalloff: 0.40,
                    innerShadowColor: ThemeColor(hex: "#0A080F")!,
                    innerShadowOpacity: 0.18,
                    innerShadowRadius: 2.60
                )
            ),
            .action: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#DFC092")!.withAlpha(0.79),
                    ThemeColor(hex: "#D6B88C")!.withAlpha(0.79)
                ]),
                labelColor: ThemeColor(hex: "#221C28")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#CEB186")!.withAlpha(0.91),
                    ThemeColor(hex: "#C4A880")!.withAlpha(0.91)
                ]),
                pressedLabelColor: ThemeColor(hex: "#221C28")!,
                border: ThemeBorder(color: ThemeColor(hex: "#F9F3EB")!.withAlpha(0.50), width: 1.05),
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
                    ThemeColor(hex: "#DFC092")!.withAlpha(0.42),
                    ThemeColor(hex: "#D6B88C")!.withAlpha(0.42)
                ]),
                labelColor: ThemeColor(hex: "#221C28")!.withAlpha(0.00),
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#D0B388")!.withAlpha(0.42),
                    ThemeColor(hex: "#C6AA81")!.withAlpha(0.42)
                ]),
                border: ThemeBorder(color: ThemeColor(hex: "#F9F3EB")!.withAlpha(0.50), width: 1.05),
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
            assetPrefix: "keyart_mdv_",
            heightFraction: 0.46,
            bottomInsetFraction: 0.09,
            opacity: 0.90,
            fillKeys: ["space"],
            labelLiftFraction: 0.14
        ),
        effects: .none
    )

    static let neonRollerNights = MochiKeyboardTheme(
        id: "mochi.neon-roller-nights",
        name: "Neon Roller Nights",
        authorName: "Mochi",
        appearance: .dark,
        surface: ThemeSurface(
            baseFill: ThemeFill(stops: [
                    ThemeColor(hex: "#342657")!,
                    ThemeColor(hex: "#1D1229")!,
                    ThemeColor(hex: "#533F73")!
                ]),
            backgroundImage: ThemeBackgroundImage(
                source: .bundled(name: "themebg_neon_roller_nights"),
                scalesToFill: true,
                verticalAnchor: 0.5,
                blurRadius: 0.0
            ),
            scrim: ThemeScrim(
                topColor: ThemeColor(hex: "#331E3D")!.withAlpha(0.18),
                bottomColor: ThemeColor(hex: "#331E3D")!.withAlpha(0.05)
            )
        ),
        keyStyles: [
            .input: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#1A0E23")!,
                    ThemeColor(hex: "#494050")!
                ]),
                labelColor: ThemeColor(hex: "#FFFFFF")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#615967")!,
                    ThemeColor(hex: "#736C78")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#FFFFFF")!,
                border: ThemeBorder(color: ThemeColor(hex: "#C7C4C9")!.withAlpha(0.55), width: 1.00),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.26, radius: 1.60, offsetY: 1.60),
                topHighlight: ThemeColor(hex: "#BFBCC1")!.withAlpha(0.34),
                cornerRadiusOverride: 8.0,
                glass: KeyGlass(
                    bevelColor: ThemeColor(hex: "#C7C4C9")!.withAlpha(0.70),
                    bevelWidth: 1.00,
                    bevelFalloff: 0.10,
                    innerShadowColor: ThemeColor(hex: "#0A080F")!,
                    innerShadowOpacity: 0.16,
                    innerShadowRadius: 2.00
                )
            ),
            .system: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#494050")!,
                    ThemeColor(hex: "#615967")!
                ]),
                labelColor: ThemeColor(hex: "#FFFFFF")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#736C78")!,
                    ThemeColor(hex: "#817B87")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#FFFFFF")!,
                border: ThemeBorder(color: ThemeColor(hex: "#CECCD0")!.withAlpha(0.55), width: 1.00),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.26, radius: 1.60, offsetY: 1.60),
                topHighlight: ThemeColor(hex: "#C7C4C9")!.withAlpha(0.34),
                cornerRadiusOverride: 8.0,
                glass: KeyGlass(
                    bevelColor: ThemeColor(hex: "#CECCD0")!.withAlpha(0.70),
                    bevelWidth: 1.00,
                    bevelFalloff: 0.10,
                    innerShadowColor: ThemeColor(hex: "#0A080F")!,
                    innerShadowOpacity: 0.16,
                    innerShadowRadius: 2.00
                )
            ),
            .action: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#1C0F18")!,
                    ThemeColor(hex: "#4B4048")!
                ]),
                labelColor: ThemeColor(hex: "#FFFFFF")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#625960")!,
                    ThemeColor(hex: "#746C72")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#FFFFFF")!,
                border: ThemeBorder(color: ThemeColor(hex: "#C7C4C6")!.withAlpha(0.55), width: 1.00),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.26, radius: 1.60, offsetY: 1.60),
                topHighlight: ThemeColor(hex: "#BFBCBE")!.withAlpha(0.34),
                cornerRadiusOverride: 8.0,
                glass: KeyGlass(
                    bevelColor: ThemeColor(hex: "#C7C4C6")!.withAlpha(0.70),
                    bevelWidth: 1.00,
                    bevelFalloff: 0.10,
                    innerShadowColor: ThemeColor(hex: "#0A080F")!,
                    innerShadowOpacity: 0.16,
                    innerShadowRadius: 2.00
                )
            ),
            .space: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#1A0E23")!.withAlpha(0.50),
                    ThemeColor(hex: "#494050")!.withAlpha(0.50)
                ]),
                labelColor: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.00),
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#58505F")!.withAlpha(0.50),
                    ThemeColor(hex: "#6C6572")!.withAlpha(0.50)
                ]),
                border: ThemeBorder(color: ThemeColor(hex: "#BFBCC1")!.withAlpha(0.55), width: 1.00),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.26, radius: 1.60, offsetY: 1.60),
                topHighlight: ThemeColor(hex: "#BFBCC1")!.withAlpha(0.34),
                cornerRadiusOverride: 10.0
            )
        ],
        typography: ThemeTypography(fontFamily: nil, weightRawValue: 0.34, sizeMultiplier: 1.0),
        chrome: ThemeChrome(
            inkColor: ThemeColor(hex: "#F2ECF0")!,
            mutedInkColor: ThemeColor(hex: "#F2ECF0")!.withAlpha(0.55),
            panelFill: ThemeFill(stops: [
                    ThemeColor(hex: "#5E5667")!.withAlpha(0.55)
                ]),
            highlightFill: ThemeFill(stops: [
                    ThemeColor(hex: "#FFFFFF")!.withAlpha(0.16)
                ])
        ),
        keyArt: KeyArtSet(
            assetPrefix: "keyart_nrn_",
            heightFraction: 0.46,
            bottomInsetFraction: 0.09,
            opacity: 0.90,
            fillKeys: ["space"],
            labelLiftFraction: 0.14
        ),
        effects: .none
    )

    static let parisianMorning = MochiKeyboardTheme(
        id: "mochi.parisian-morning",
        name: "Parisian Morning",
        authorName: "Mochi",
        appearance: .light,
        surface: ThemeSurface(
            baseFill: ThemeFill(stops: [
                    ThemeColor(hex: "#FABE94")!,
                    ThemeColor(hex: "#E4B297")!,
                    ThemeColor(hex: "#D79268")!
                ]),
            backgroundImage: ThemeBackgroundImage(
                source: .bundled(name: "themebg_parisian_morning"),
                scalesToFill: true,
                verticalAnchor: 0.5,
                blurRadius: 0.0
            ),
            scrim: ThemeScrim(
                topColor: ThemeColor(hex: "#A57F67")!.withAlpha(0.18),
                bottomColor: ThemeColor(hex: "#A57F67")!.withAlpha(0.05)
            )
        ),
        keyStyles: [
            .input: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#F0C994")!,
                    ThemeColor(hex: "#F39E93")!
                ]),
                labelColor: ThemeColor(hex: "#221C28")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#E0BC8A")!,
                    ThemeColor(hex: "#DC8F85")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#221C28")!,
                border: ThemeBorder(color: ThemeColor(hex: "#FEFCF9")!.withAlpha(0.42), width: 0.95),
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
                    ThemeColor(hex: "#E2B18E")!,
                    ThemeColor(hex: "#CCA081")!
                ]),
                labelColor: ThemeColor(hex: "#221C28")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#CFA182")!,
                    ThemeColor(hex: "#B68E72")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#221C28")!,
                border: ThemeBorder(color: ThemeColor(hex: "#F7EBE2")!.withAlpha(0.42), width: 0.95),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.15, radius: 2.20, offsetY: 1.30),
                topHighlight: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.46),
                cornerRadiusOverride: 14.0,
                glass: KeyGlass(
                    bevelColor: ThemeColor(hex: "#FCF8F5")!.withAlpha(0.60),
                    bevelWidth: 0.80,
                    bevelFalloff: 0.18,
                    innerShadowColor: ThemeColor(hex: "#0A080F")!,
                    innerShadowOpacity: 0.12,
                    innerShadowRadius: 2.00
                )
            ),
            .action: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#EEBA96")!,
                    ThemeColor(hex: "#DAAA89")!
                ]),
                labelColor: ThemeColor(hex: "#221C28")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#DCAC8B")!,
                    ThemeColor(hex: "#C59A7C")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#221C28")!,
                border: ThemeBorder(color: ThemeColor(hex: "#FCF2EC")!.withAlpha(0.42), width: 0.95),
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
                    ThemeColor(hex: "#F0C994")!.withAlpha(0.42),
                    ThemeColor(hex: "#F39E93")!.withAlpha(0.42)
                ]),
                labelColor: ThemeColor(hex: "#221C28")!.withAlpha(0.00),
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#E2BD8B")!.withAlpha(0.42),
                    ThemeColor(hex: "#DF9187")!.withAlpha(0.42)
                ]),
                border: ThemeBorder(color: ThemeColor(hex: "#FEFCF9")!.withAlpha(0.42), width: 0.95),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.15, radius: 2.20, offsetY: 1.30),
                topHighlight: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.46),
                cornerRadiusOverride: 16.0
            )
        ],
        typography: ThemeTypography(fontFamily: nil, weightRawValue: 0.34, sizeMultiplier: 1.0),
        chrome: ThemeChrome(
            inkColor: ThemeColor(hex: "#201A26")!,
            mutedInkColor: ThemeColor(hex: "#201A26")!.withAlpha(0.55),
            panelFill: ThemeFill(stops: [
                    ThemeColor(hex: "#FEFBFA")!.withAlpha(0.55)
                ]),
            highlightFill: ThemeFill(stops: [
                    ThemeColor(hex: "#000000")!.withAlpha(0.16)
                ])
        ),
        keyArt: KeyArtSet(
            assetPrefix: "keyart_prm_",
            heightFraction: 0.48,
            bottomInsetFraction: 0.09,
            opacity: 0.90,
            fillKeys: ["space"],
            labelLiftFraction: 0.14
        ),
        effects: .none
    )

    static let theWanderersCabin = MochiKeyboardTheme(
        id: "mochi.the-wanderers-cabin",
        name: "The Wanderers Cabin",
        authorName: "Mochi",
        appearance: .dark,
        surface: ThemeSurface(
            baseFill: ThemeFill(stops: [
                    ThemeColor(hex: "#2B1506")!,
                    ThemeColor(hex: "#422611")!,
                    ThemeColor(hex: "#C68342")!
                ]),
            backgroundImage: ThemeBackgroundImage(
                source: .bundled(name: "themebg_the_wanderers_cabin"),
                scalesToFill: true,
                verticalAnchor: 0.5,
                blurRadius: 0.0
            ),
            scrim: ThemeScrim(
                topColor: ThemeColor(hex: "#422612")!.withAlpha(0.20),
                bottomColor: ThemeColor(hex: "#422612")!.withAlpha(0.06)
            )
        ),
        keyStyles: [
            .input: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#301A0C")!,
                    ThemeColor(hex: "#473427")!
                ]),
                labelColor: ThemeColor(hex: "#FFFFFF")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#6B5C52")!,
                    ThemeColor(hex: "#74665C")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#FFFFFF")!,
                border: ThemeBorder(color: ThemeColor(hex: "#CAC5C1")!.withAlpha(0.60), width: 1.00),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.32, radius: 2.60, offsetY: 1.60),
                topHighlight: ThemeColor(hex: "#C3BDB9")!.withAlpha(0.28),
                cornerRadiusOverride: 12.0,
                glass: KeyGlass(
                    bevelColor: ThemeColor(hex: "#CAC5C1")!.withAlpha(0.62),
                    bevelWidth: 1.00,
                    bevelFalloff: 0.12,
                    innerShadowColor: ThemeColor(hex: "#0A080F")!,
                    innerShadowOpacity: 0.36,
                    innerShadowRadius: 3.00
                )
            ),
            .system: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#554438")!,
                    ThemeColor(hex: "#615146")!
                ]),
                labelColor: ThemeColor(hex: "#FFFFFF")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#7C6E65")!,
                    ThemeColor(hex: "#83766D")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#FFFFFF")!,
                border: ThemeBorder(color: ThemeColor(hex: "#D1CDCA")!.withAlpha(0.60), width: 1.00),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.32, radius: 2.60, offsetY: 1.60),
                topHighlight: ThemeColor(hex: "#CAC5C1")!.withAlpha(0.28),
                cornerRadiusOverride: 12.0,
                glass: KeyGlass(
                    bevelColor: ThemeColor(hex: "#D1CDCA")!.withAlpha(0.62),
                    bevelWidth: 1.00,
                    bevelFalloff: 0.12,
                    innerShadowColor: ThemeColor(hex: "#0A080F")!,
                    innerShadowOpacity: 0.36,
                    innerShadowRadius: 3.00
                )
            ),
            .action: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#2C1C0F")!,
                    ThemeColor(hex: "#433529")!
                ]),
                labelColor: ThemeColor(hex: "#FFFFFF")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#685D53")!,
                    ThemeColor(hex: "#71665D")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#FFFFFF")!,
                border: ThemeBorder(color: ThemeColor(hex: "#C9C5C2")!.withAlpha(0.60), width: 1.00),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.32, radius: 2.60, offsetY: 1.60),
                topHighlight: ThemeColor(hex: "#C2BDB9")!.withAlpha(0.28),
                cornerRadiusOverride: 12.0,
                glass: KeyGlass(
                    bevelColor: ThemeColor(hex: "#C9C5C2")!.withAlpha(0.62),
                    bevelWidth: 1.00,
                    bevelFalloff: 0.12,
                    innerShadowColor: ThemeColor(hex: "#0A080F")!,
                    innerShadowOpacity: 0.36,
                    innerShadowRadius: 3.00
                )
            ),
            .space: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#301A0C")!.withAlpha(0.50),
                    ThemeColor(hex: "#473427")!.withAlpha(0.50)
                ]),
                labelColor: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.00),
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#635348")!.withAlpha(0.50),
                    ThemeColor(hex: "#6D5E54")!.withAlpha(0.50)
                ]),
                border: ThemeBorder(color: ThemeColor(hex: "#C3BDB9")!.withAlpha(0.60), width: 1.00),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.32, radius: 2.60, offsetY: 1.60),
                topHighlight: ThemeColor(hex: "#C3BDB9")!.withAlpha(0.28),
                cornerRadiusOverride: 14.0
            )
        ],
        typography: ThemeTypography(fontFamily: nil, weightRawValue: 0.34, sizeMultiplier: 1.0),
        chrome: ThemeChrome(
            inkColor: ThemeColor(hex: "#F2ECF0")!,
            mutedInkColor: ThemeColor(hex: "#F2ECF0")!.withAlpha(0.55),
            panelFill: ThemeFill(stops: [
                    ThemeColor(hex: "#66564B")!.withAlpha(0.55)
                ]),
            highlightFill: ThemeFill(stops: [
                    ThemeColor(hex: "#FFFFFF")!.withAlpha(0.16)
                ])
        ),
        keyArt: KeyArtSet(
            assetPrefix: "keyart_twc_",
            heightFraction: 0.44,
            bottomInsetFraction: 0.09,
            opacity: 0.90,
            fillKeys: ["space"],
            labelLiftFraction: 0.14
        ),
        effects: .none
    )

    static let toymakersMemories = MochiKeyboardTheme(
        id: "mochi.toymakers-memories",
        name: "Toymakers Memories",
        authorName: "Mochi",
        appearance: .light,
        surface: ThemeSurface(
            baseFill: ThemeFill(stops: [
                    ThemeColor(hex: "#5D4C30")!,
                    ThemeColor(hex: "#E8B774")!,
                    ThemeColor(hex: "#F9CA7C")!
                ]),
            backgroundImage: ThemeBackgroundImage(
                source: .bundled(name: "themebg_toymakers_memories"),
                scalesToFill: true,
                verticalAnchor: 0.5,
                blurRadius: 0.0
            ),
            scrim: ThemeScrim(
                topColor: ThemeColor(hex: "#A37A49")!.withAlpha(0.18),
                bottomColor: ThemeColor(hex: "#A37A49")!.withAlpha(0.05)
            )
        ),
        keyStyles: [
            .input: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#E6B875")!,
                    ThemeColor(hex: "#DAAE6F")!
                ]),
                labelColor: ThemeColor(hex: "#221C28")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#D4A96B")!,
                    ThemeColor(hex: "#C69E64")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#221C28")!,
                border: ThemeBorder(color: ThemeColor(hex: "#A18051")!.withAlpha(0.40), width: 1.15),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.30, radius: 4.20, offsetY: 3.00),
                topHighlight: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.62),
                cornerRadiusOverride: 19.0,
                glass: KeyGlass(
                    bevelColor: ThemeColor(hex: "#FEFCF9")!.withAlpha(0.00),
                    bevelWidth: 0.00,
                    bevelFalloff: 0.50,
                    innerShadowColor: ThemeColor(hex: "#FFFFFF")!,
                    innerShadowOpacity: 0.34,
                    innerShadowRadius: 3.20
                )
            ),
            .system: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#DAAE6F")!,
                    ThemeColor(hex: "#CDA368")!
                ]),
                labelColor: ThemeColor(hex: "#221C28")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#C69E64")!,
                    ThemeColor(hex: "#B7925D")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#221C28")!,
                border: ThemeBorder(color: ThemeColor(hex: "#98794D")!.withAlpha(0.40), width: 1.15),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.30, radius: 4.20, offsetY: 3.00),
                topHighlight: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.62),
                cornerRadiusOverride: 19.0,
                glass: KeyGlass(
                    bevelColor: ThemeColor(hex: "#FAF4EC")!.withAlpha(0.00),
                    bevelWidth: 0.00,
                    bevelFalloff: 0.50,
                    innerShadowColor: ThemeColor(hex: "#FDFBF7")!,
                    innerShadowOpacity: 0.34,
                    innerShadowRadius: 3.20
                )
            ),
            .action: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#E6B875")!,
                    ThemeColor(hex: "#DAAE6F")!
                ]),
                labelColor: ThemeColor(hex: "#221C28")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#D4A96B")!,
                    ThemeColor(hex: "#C69E64")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#221C28")!,
                border: ThemeBorder(color: ThemeColor(hex: "#A18051")!.withAlpha(0.40), width: 1.15),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.30, radius: 4.20, offsetY: 3.00),
                topHighlight: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.62),
                cornerRadiusOverride: 19.0,
                glass: KeyGlass(
                    bevelColor: ThemeColor(hex: "#FEFCF9")!.withAlpha(0.00),
                    bevelWidth: 0.00,
                    bevelFalloff: 0.50,
                    innerShadowColor: ThemeColor(hex: "#FFFFFF")!,
                    innerShadowOpacity: 0.34,
                    innerShadowRadius: 3.20
                )
            ),
            .space: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#E6B875")!.withAlpha(0.42),
                    ThemeColor(hex: "#DAAE6F")!.withAlpha(0.42)
                ]),
                labelColor: ThemeColor(hex: "#221C28")!.withAlpha(0.00),
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#D6AA6D")!.withAlpha(0.42),
                    ThemeColor(hex: "#C8A066")!.withAlpha(0.42)
                ]),
                border: ThemeBorder(color: ThemeColor(hex: "#F9EFE0")!.withAlpha(0.40), width: 1.15),
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
                    ThemeColor(hex: "#68573B")!.withAlpha(0.55)
                ]),
            highlightFill: ThemeFill(stops: [
                    ThemeColor(hex: "#FFFFFF")!.withAlpha(0.16)
                ])
        ),
        keyArt: KeyArtSet(
            assetPrefix: "keyart_tym_",
            heightFraction: 0.50,
            bottomInsetFraction: 0.10,
            opacity: 0.90,
            fillKeys: ["space"],
            labelLiftFraction: 0.15
        ),
        effects: .none
    )

    static let velvetReelReverie = MochiKeyboardTheme(
        id: "mochi.velvet-reel-reverie",
        name: "Velvet Reel Reverie",
        authorName: "Mochi",
        appearance: .light,
        surface: ThemeSurface(
            baseFill: ThemeFill(stops: [
                    ThemeColor(hex: "#53311D")!,
                    ThemeColor(hex: "#F1C380")!,
                    ThemeColor(hex: "#D79E61")!
                ]),
            backgroundImage: ThemeBackgroundImage(
                source: .bundled(name: "themebg_velvet_reel_reverie"),
                scalesToFill: true,
                verticalAnchor: 0.5,
                blurRadius: 0.0
            ),
            scrim: ThemeScrim(
                topColor: ThemeColor(hex: "#A0774A")!.withAlpha(0.18),
                bottomColor: ThemeColor(hex: "#A0774A")!.withAlpha(0.05)
            )
        ),
        keyStyles: [
            .input: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#E7B475")!,
                    ThemeColor(hex: "#DCAC6F")!
                ]),
                labelColor: ThemeColor(hex: "#221C28")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#D4A56B")!,
                    ThemeColor(hex: "#C89C65")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#221C28")!,
                border: ThemeBorder(color: ThemeColor(hex: "#F9EDDE")!.withAlpha(0.55), width: 1.00),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.26, radius: 1.60, offsetY: 1.60),
                topHighlight: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.34),
                cornerRadiusOverride: 8.0,
                glass: KeyGlass(
                    bevelColor: ThemeColor(hex: "#FDFAF6")!.withAlpha(0.70),
                    bevelWidth: 1.00,
                    bevelFalloff: 0.10,
                    innerShadowColor: ThemeColor(hex: "#0A080F")!,
                    innerShadowOpacity: 0.16,
                    innerShadowRadius: 2.00
                )
            ),
            .system: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#DAAA6E")!,
                    ThemeColor(hex: "#CFA269")!
                ]),
                labelColor: ThemeColor(hex: "#221C28")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#C59A64")!,
                    ThemeColor(hex: "#B8905D")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#221C28")!,
                border: ThemeBorder(color: ThemeColor(hex: "#F4E5D3")!.withAlpha(0.55), width: 1.00),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.26, radius: 1.60, offsetY: 1.60),
                topHighlight: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.34),
                cornerRadiusOverride: 8.0,
                glass: KeyGlass(
                    bevelColor: ThemeColor(hex: "#FAF2EA")!.withAlpha(0.70),
                    bevelWidth: 1.00,
                    bevelFalloff: 0.10,
                    innerShadowColor: ThemeColor(hex: "#0A080F")!,
                    innerShadowOpacity: 0.16,
                    innerShadowRadius: 2.00
                )
            ),
            .action: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#E7B475")!,
                    ThemeColor(hex: "#DCAC6F")!
                ]),
                labelColor: ThemeColor(hex: "#221C28")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#D4A56B")!,
                    ThemeColor(hex: "#C89C65")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#221C28")!,
                border: ThemeBorder(color: ThemeColor(hex: "#F9EDDE")!.withAlpha(0.55), width: 1.00),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.26, radius: 1.60, offsetY: 1.60),
                topHighlight: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.34),
                cornerRadiusOverride: 8.0,
                glass: KeyGlass(
                    bevelColor: ThemeColor(hex: "#FDFAF6")!.withAlpha(0.70),
                    bevelWidth: 1.00,
                    bevelFalloff: 0.10,
                    innerShadowColor: ThemeColor(hex: "#0A080F")!,
                    innerShadowOpacity: 0.16,
                    innerShadowRadius: 2.00
                )
            ),
            .space: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#E7B475")!.withAlpha(0.42),
                    ThemeColor(hex: "#DCAC6F")!.withAlpha(0.42)
                ]),
                labelColor: ThemeColor(hex: "#221C28")!.withAlpha(0.00),
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#D6A76C")!.withAlpha(0.42),
                    ThemeColor(hex: "#CA9E66")!.withAlpha(0.42)
                ]),
                border: ThemeBorder(color: ThemeColor(hex: "#F9EDDE")!.withAlpha(0.55), width: 1.00),
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
                    ThemeColor(hex: "#705341")!.withAlpha(0.55)
                ]),
            highlightFill: ThemeFill(stops: [
                    ThemeColor(hex: "#FFFFFF")!.withAlpha(0.16)
                ])
        ),
        keyArt: KeyArtSet(
            assetPrefix: "keyart_vrr_",
            heightFraction: 0.46,
            bottomInsetFraction: 0.09,
            opacity: 0.90,
            fillKeys: ["space"],
            labelLiftFraction: 0.14
        ),
        effects: .none
    )

    static let whispersOfTheSewingHearth = MochiKeyboardTheme(
        id: "mochi.whispers-of-the-sewing-hearth",
        name: "Whispers of the Sewing Hearth",
        authorName: "Mochi",
        appearance: .light,
        surface: ThemeSurface(
            baseFill: ThemeFill(stops: [
                    ThemeColor(hex: "#92561A")!,
                    ThemeColor(hex: "#F9D69C")!,
                    ThemeColor(hex: "#F5C889")!
                ]),
            backgroundImage: ThemeBackgroundImage(
                source: .bundled(name: "themebg_whispers_of_the_sewing_hearth"),
                scalesToFill: true,
                verticalAnchor: 0.5,
                blurRadius: 0.0
            ),
            scrim: ThemeScrim(
                topColor: ThemeColor(hex: "#B18E5E")!.withAlpha(0.18),
                bottomColor: ThemeColor(hex: "#B18E5E")!.withAlpha(0.05)
            )
        ),
        keyStyles: [
            .input: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#F0C98B")!,
                    ThemeColor(hex: "#E7C286")!
                ]),
                labelColor: ThemeColor(hex: "#221C28")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#DFBB82")!,
                    ThemeColor(hex: "#D6B37C")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#221C28")!,
                border: ThemeBorder(color: ThemeColor(hex: "#A78C61")!.withAlpha(0.32), width: 1.35),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.22, radius: 3.60, offsetY: 2.60),
                topHighlight: nil,
                cornerRadiusOverride: 9.0
            ),
            .system: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#E5C085")!,
                    ThemeColor(hex: "#DCB880")!
                ]),
                labelColor: ThemeColor(hex: "#221C28")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#D4B27B")!,
                    ThemeColor(hex: "#C9A975")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#221C28")!,
                border: ThemeBorder(color: ThemeColor(hex: "#A0865D")!.withAlpha(0.32), width: 1.35),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.22, radius: 3.60, offsetY: 2.60),
                topHighlight: nil,
                cornerRadiusOverride: 9.0
            ),
            .action: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#F0C98B")!,
                    ThemeColor(hex: "#E7C286")!
                ]),
                labelColor: ThemeColor(hex: "#221C28")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#DFBB82")!,
                    ThemeColor(hex: "#D6B37C")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#221C28")!,
                border: ThemeBorder(color: ThemeColor(hex: "#A78C61")!.withAlpha(0.32), width: 1.35),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.22, radius: 3.60, offsetY: 2.60),
                topHighlight: nil,
                cornerRadiusOverride: 9.0
            ),
            .space: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#F0C98B")!.withAlpha(0.42),
                    ThemeColor(hex: "#E7C286")!.withAlpha(0.42)
                ]),
                labelColor: ThemeColor(hex: "#221C28")!.withAlpha(0.00),
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#E1BD83")!.withAlpha(0.42),
                    ThemeColor(hex: "#D8B57D")!.withAlpha(0.42)
                ]),
                border: ThemeBorder(color: ThemeColor(hex: "#FEFBF7")!.withAlpha(0.32), width: 1.35),
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
                    ThemeColor(hex: "#804D1A")!.withAlpha(0.55)
                ]),
            highlightFill: ThemeFill(stops: [
                    ThemeColor(hex: "#FFFFFF")!.withAlpha(0.16)
                ])
        ),
        keyArt: KeyArtSet(
            assetPrefix: "keyart_wsh_",
            heightFraction: 0.52,
            bottomInsetFraction: 0.10,
            opacity: 0.90,
            fillKeys: ["space"],
            labelLiftFraction: 0.15
        ),
        effects: .none
    )

    static let enchantedMidnightLibrary = MochiKeyboardTheme(
        id: "mochi.enchanted-midnight-library",
        name: "Enchanted Midnight Library",
        authorName: "Mochi",
        appearance: .dark,
        surface: ThemeSurface(
            baseFill: ThemeFill(stops: [
                    ThemeColor(hex: "#361F54")!,
                    ThemeColor(hex: "#3A224C")!,
                    ThemeColor(hex: "#6E496B")!
                ]),
            backgroundImage: ThemeBackgroundImage(
                source: .bundled(name: "themebg_enchanted_midnight_library"),
                scalesToFill: true,
                verticalAnchor: 0.5,
                blurRadius: 0.0
            ),
            scrim: ThemeScrim(
                topColor: ThemeColor(hex: "#36223D")!.withAlpha(0.20),
                bottomColor: ThemeColor(hex: "#36223D")!.withAlpha(0.06)
            )
        ),
        keyStyles: [
            .input: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#261632")!,
                    ThemeColor(hex: "#3F314A")!
                ]),
                labelColor: ThemeColor(hex: "#FFFFFF")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#665A6E")!,
                    ThemeColor(hex: "#6F6476")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#FFFFFF")!,
                border: ThemeBorder(color: ThemeColor(hex: "#C8C4CB")!.withAlpha(0.60), width: 1.00),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.32, radius: 2.60, offsetY: 1.60),
                topHighlight: ThemeColor(hex: "#C1BCC4")!.withAlpha(0.28),
                cornerRadiusOverride: 12.0,
                glass: KeyGlass(
                    bevelColor: ThemeColor(hex: "#C8C4CB")!.withAlpha(0.62),
                    bevelWidth: 1.00,
                    bevelFalloff: 0.12,
                    innerShadowColor: ThemeColor(hex: "#0A080F")!,
                    innerShadowOpacity: 0.36,
                    innerShadowRadius: 3.00
                )
            ),
            .system: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#4F4258")!,
                    ThemeColor(hex: "#5B4F64")!
                ]),
                labelColor: ThemeColor(hex: "#FFFFFF")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#776C7E")!,
                    ThemeColor(hex: "#7E7485")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#FFFFFF")!,
                border: ThemeBorder(color: ThemeColor(hex: "#D0CCD2")!.withAlpha(0.60), width: 1.00),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.32, radius: 2.60, offsetY: 1.60),
                topHighlight: ThemeColor(hex: "#C8C4CB")!.withAlpha(0.28),
                cornerRadiusOverride: 12.0,
                glass: KeyGlass(
                    bevelColor: ThemeColor(hex: "#D0CCD2")!.withAlpha(0.62),
                    bevelWidth: 1.00,
                    bevelFalloff: 0.12,
                    innerShadowColor: ThemeColor(hex: "#0A080F")!,
                    innerShadowOpacity: 0.36,
                    innerShadowRadius: 3.00
                )
            ),
            .action: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#261632")!,
                    ThemeColor(hex: "#3F314A")!
                ]),
                labelColor: ThemeColor(hex: "#FFFFFF")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#665A6E")!,
                    ThemeColor(hex: "#6F6476")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#FFFFFF")!,
                border: ThemeBorder(color: ThemeColor(hex: "#C8C4CB")!.withAlpha(0.60), width: 1.00),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.32, radius: 2.60, offsetY: 1.60),
                topHighlight: ThemeColor(hex: "#C1BCC4")!.withAlpha(0.28),
                cornerRadiusOverride: 12.0,
                glass: KeyGlass(
                    bevelColor: ThemeColor(hex: "#C8C4CB")!.withAlpha(0.62),
                    bevelWidth: 1.00,
                    bevelFalloff: 0.12,
                    innerShadowColor: ThemeColor(hex: "#0A080F")!,
                    innerShadowOpacity: 0.36,
                    innerShadowRadius: 3.00
                )
            ),
            .space: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#261632")!.withAlpha(0.50),
                    ThemeColor(hex: "#3F314A")!.withAlpha(0.50)
                ]),
                labelColor: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.00),
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#5D5166")!.withAlpha(0.50),
                    ThemeColor(hex: "#675C70")!.withAlpha(0.50)
                ]),
                border: ThemeBorder(color: ThemeColor(hex: "#C1BCC4")!.withAlpha(0.60), width: 1.00),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.32, radius: 2.60, offsetY: 1.60),
                topHighlight: ThemeColor(hex: "#C1BCC4")!.withAlpha(0.28),
                cornerRadiusOverride: 14.0
            )
        ],
        typography: ThemeTypography(fontFamily: nil, weightRawValue: 0.34, sizeMultiplier: 1.0),
        chrome: ThemeChrome(
            inkColor: ThemeColor(hex: "#F2ECF0")!,
            mutedInkColor: ThemeColor(hex: "#F2ECF0")!.withAlpha(0.55),
            panelFill: ThemeFill(stops: [
                    ThemeColor(hex: "#635179")!.withAlpha(0.55)
                ]),
            highlightFill: ThemeFill(stops: [
                    ThemeColor(hex: "#FFFFFF")!.withAlpha(0.16)
                ])
        ),
        keyArt: KeyArtSet(
            assetPrefix: "keyart_eml_",
            heightFraction: 0.44,
            bottomInsetFraction: 0.09,
            opacity: 0.90,
            fillKeys: ["space"],
            labelLiftFraction: 0.14
        ),
        effects: .none
    )

    static let moonlitMeowCafe = MochiKeyboardTheme(
        id: "mochi.moonlit-meow-cafe",
        name: "Moonlit Meow Cafe",
        authorName: "Mochi",
        appearance: .light,
        surface: ThemeSurface(
            baseFill: ThemeFill(stops: [
                    ThemeColor(hex: "#47295D")!,
                    ThemeColor(hex: "#96608A")!,
                    ThemeColor(hex: "#CA8AB2")!
                ]),
            backgroundImage: ThemeBackgroundImage(
                source: .bundled(name: "themebg_moonlit_meow_cafe"),
                scalesToFill: true,
                verticalAnchor: 0.5,
                blurRadius: 0.0
            ),
            scrim: ThemeScrim(
                topColor: ThemeColor(hex: "#754B67")!.withAlpha(0.46),
                bottomColor: ThemeColor(hex: "#754B67")!.withAlpha(0.34)
            )
        ),
        keyStyles: [
            .input: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#D6A8C1")!.withAlpha(0.73),
                    ThemeColor(hex: "#CB9FB8")!.withAlpha(0.73)
                ]),
                labelColor: ThemeColor(hex: "#120F16")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#C298AF")!.withAlpha(0.85),
                    ThemeColor(hex: "#B58EA4")!.withAlpha(0.85)
                ]),
                pressedLabelColor: ThemeColor(hex: "#120F16")!,
                border: ThemeBorder(color: ThemeColor(hex: "#F3E5ED")!.withAlpha(0.50), width: 1.05),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.17, radius: 1.90, offsetY: 1.10),
                topHighlight: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.50),
                cornerRadiusOverride: 13.0,
                glass: KeyGlass(
                    bevelColor: ThemeColor(hex: "#F9F3F7")!.withAlpha(0.74),
                    bevelWidth: 1.10,
                    bevelFalloff: 0.40,
                    innerShadowColor: ThemeColor(hex: "#0A080F")!,
                    innerShadowOpacity: 0.18,
                    innerShadowRadius: 2.60
                )
            ),
            .system: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#C99DB6")!.withAlpha(0.79),
                    ThemeColor(hex: "#BD94AB")!.withAlpha(0.79)
                ]),
                labelColor: ThemeColor(hex: "#120F16")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#B38CA2")!.withAlpha(0.91),
                    ThemeColor(hex: "#A58195")!.withAlpha(0.91)
                ]),
                pressedLabelColor: ThemeColor(hex: "#120F16")!,
                border: ThemeBorder(color: ThemeColor(hex: "#ECDDE5")!.withAlpha(0.50), width: 1.05),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.17, radius: 1.90, offsetY: 1.10),
                topHighlight: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.50),
                cornerRadiusOverride: 13.0,
                glass: KeyGlass(
                    bevelColor: ThemeColor(hex: "#F4EBF0")!.withAlpha(0.74),
                    bevelWidth: 1.10,
                    bevelFalloff: 0.40,
                    innerShadowColor: ThemeColor(hex: "#0A080F")!,
                    innerShadowOpacity: 0.18,
                    innerShadowRadius: 2.60
                )
            ),
            .action: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#D6A8C1")!.withAlpha(0.79),
                    ThemeColor(hex: "#CB9FB8")!.withAlpha(0.79)
                ]),
                labelColor: ThemeColor(hex: "#120F16")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#C298AF")!.withAlpha(0.91),
                    ThemeColor(hex: "#B58EA4")!.withAlpha(0.91)
                ]),
                pressedLabelColor: ThemeColor(hex: "#120F16")!,
                border: ThemeBorder(color: ThemeColor(hex: "#F3E5ED")!.withAlpha(0.50), width: 1.05),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.17, radius: 1.90, offsetY: 1.10),
                topHighlight: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.50),
                cornerRadiusOverride: 13.0,
                glass: KeyGlass(
                    bevelColor: ThemeColor(hex: "#F9F3F7")!.withAlpha(0.74),
                    bevelWidth: 1.10,
                    bevelFalloff: 0.40,
                    innerShadowColor: ThemeColor(hex: "#0A080F")!,
                    innerShadowOpacity: 0.18,
                    innerShadowRadius: 2.60
                )
            ),
            .space: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#D6A8C1")!.withAlpha(0.42),
                    ThemeColor(hex: "#CB9FB8")!.withAlpha(0.42)
                ]),
                labelColor: ThemeColor(hex: "#120F16")!.withAlpha(0.00),
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#C49AB1")!.withAlpha(0.42),
                    ThemeColor(hex: "#B890A6")!.withAlpha(0.42)
                ]),
                border: ThemeBorder(color: ThemeColor(hex: "#F3E5ED")!.withAlpha(0.50), width: 1.05),
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
                    ThemeColor(hex: "#6C4E75")!.withAlpha(0.55)
                ]),
            highlightFill: ThemeFill(stops: [
                    ThemeColor(hex: "#FFFFFF")!.withAlpha(0.16)
                ])
        ),
        keyArt: KeyArtSet(
            assetPrefix: "keyart_mwc_",
            heightFraction: 0.46,
            bottomInsetFraction: 0.09,
            opacity: 0.90,
            fillKeys: ["space"],
            labelLiftFraction: 0.14
        ),
        effects: .none
    )

    static let mysticOceanAtelier = MochiKeyboardTheme(
        id: "mochi.mystic-ocean-atelier",
        name: "Mystic Ocean Atelier",
        authorName: "Mochi",
        appearance: .light,
        surface: ThemeSurface(
            baseFill: ThemeFill(stops: [
                    ThemeColor(hex: "#56ACAA")!,
                    ThemeColor(hex: "#7CC4B7")!,
                    ThemeColor(hex: "#E7DCB6")!
                ]),
            backgroundImage: ThemeBackgroundImage(
                source: .bundled(name: "themebg_mystic_ocean_atelier"),
                scalesToFill: true,
                verticalAnchor: 0.5,
                blurRadius: 0.0
            ),
            scrim: ThemeScrim(
                topColor: ThemeColor(hex: "#5B887E")!.withAlpha(0.46),
                bottomColor: ThemeColor(hex: "#5B887E")!.withAlpha(0.34)
            )
        ),
        keyStyles: [
            .input: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#C2C0A2")!.withAlpha(0.73),
                    ThemeColor(hex: "#BAB79B")!.withAlpha(0.73)
                ]),
                labelColor: ThemeColor(hex: "#221C28")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#B2B095")!.withAlpha(0.85),
                    ThemeColor(hex: "#A9A68D")!.withAlpha(0.85)
                ]),
                pressedLabelColor: ThemeColor(hex: "#221C28")!,
                border: ThemeBorder(color: ThemeColor(hex: "#F0F0E9")!.withAlpha(0.50), width: 1.05),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.17, radius: 1.90, offsetY: 1.10),
                topHighlight: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.50),
                cornerRadiusOverride: 13.0,
                glass: KeyGlass(
                    bevelColor: ThemeColor(hex: "#FBFBFA")!.withAlpha(0.74),
                    bevelWidth: 1.10,
                    bevelFalloff: 0.40,
                    innerShadowColor: ThemeColor(hex: "#0A080F")!,
                    innerShadowOpacity: 0.18,
                    innerShadowRadius: 2.60
                )
            ),
            .system: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#B8B599")!.withAlpha(0.79),
                    ThemeColor(hex: "#AFAC92")!.withAlpha(0.79)
                ]),
                labelColor: ThemeColor(hex: "#221C28")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#A7A48B")!.withAlpha(0.91),
                    ThemeColor(hex: "#9C9A82")!.withAlpha(0.91)
                ]),
                pressedLabelColor: ThemeColor(hex: "#221C28")!,
                border: ThemeBorder(color: ThemeColor(hex: "#E9E8E0")!.withAlpha(0.50), width: 1.05),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.17, radius: 1.90, offsetY: 1.10),
                topHighlight: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.50),
                cornerRadiusOverride: 13.0,
                glass: KeyGlass(
                    bevelColor: ThemeColor(hex: "#F5F4F0")!.withAlpha(0.74),
                    bevelWidth: 1.10,
                    bevelFalloff: 0.40,
                    innerShadowColor: ThemeColor(hex: "#0A080F")!,
                    innerShadowOpacity: 0.18,
                    innerShadowRadius: 2.60
                )
            ),
            .action: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#A9C5B1")!.withAlpha(0.79),
                    ThemeColor(hex: "#A1BDA9")!.withAlpha(0.79)
                ]),
                labelColor: ThemeColor(hex: "#221C28")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#9BB5A3")!.withAlpha(0.91),
                    ThemeColor(hex: "#92AB9A")!.withAlpha(0.91)
                ]),
                pressedLabelColor: ThemeColor(hex: "#221C28")!,
                border: ThemeBorder(color: ThemeColor(hex: "#EAF1EC")!.withAlpha(0.50), width: 1.05),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.17, radius: 1.90, offsetY: 1.10),
                topHighlight: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.50),
                cornerRadiusOverride: 13.0,
                glass: KeyGlass(
                    bevelColor: ThemeColor(hex: "#FAFCFB")!.withAlpha(0.74),
                    bevelWidth: 1.10,
                    bevelFalloff: 0.40,
                    innerShadowColor: ThemeColor(hex: "#0A080F")!,
                    innerShadowOpacity: 0.18,
                    innerShadowRadius: 2.60
                )
            ),
            .space: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#C2C0A2")!.withAlpha(0.42),
                    ThemeColor(hex: "#BAB79B")!.withAlpha(0.42)
                ]),
                labelColor: ThemeColor(hex: "#221C28")!.withAlpha(0.00),
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#B4B296")!.withAlpha(0.42),
                    ThemeColor(hex: "#ABA88E")!.withAlpha(0.42)
                ]),
                border: ThemeBorder(color: ThemeColor(hex: "#F0F0E9")!.withAlpha(0.50), width: 1.05),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.17, radius: 1.90, offsetY: 1.10),
                topHighlight: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.50),
                cornerRadiusOverride: 15.0
            )
        ],
        typography: ThemeTypography(fontFamily: nil, weightRawValue: 0.34, sizeMultiplier: 1.0),
        chrome: ThemeChrome(
            inkColor: ThemeColor(hex: "#0B090D")!,
            mutedInkColor: ThemeColor(hex: "#0B090D")!.withAlpha(0.55),
            panelFill: ThemeFill(stops: [
                    ThemeColor(hex: "#FAFCFC")!.withAlpha(0.55)
                ]),
            highlightFill: ThemeFill(stops: [
                    ThemeColor(hex: "#000000")!.withAlpha(0.16)
                ])
        ),
        keyArt: KeyArtSet(
            assetPrefix: "keyart_moa_",
            heightFraction: 0.46,
            bottomInsetFraction: 0.09,
            opacity: 0.90,
            fillKeys: ["space"],
            labelLiftFraction: 0.14
        ),
        effects: .none
    )

    static let neonDreamDistrict = MochiKeyboardTheme(
        id: "mochi.neon-dream-district",
        name: "Neon Dream District",
        authorName: "Mochi",
        appearance: .dark,
        surface: ThemeSurface(
            baseFill: ThemeFill(stops: [
                    ThemeColor(hex: "#2D1C61")!,
                    ThemeColor(hex: "#150E30")!,
                    ThemeColor(hex: "#27124D")!
                ]),
            backgroundImage: ThemeBackgroundImage(
                source: .bundled(name: "themebg_neon_dream_district"),
                scalesToFill: true,
                verticalAnchor: 0.5,
                blurRadius: 0.0
            ),
            scrim: ThemeScrim(
                topColor: ThemeColor(hex: "#2C1F48")!.withAlpha(0.18),
                bottomColor: ThemeColor(hex: "#2C1F48")!.withAlpha(0.05)
            )
        ),
        keyStyles: [
            .input: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#14101F")!,
                    ThemeColor(hex: "#4A4753")!
                ]),
                labelColor: ThemeColor(hex: "#FFFFFF")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#5D5A65")!,
                    ThemeColor(hex: "#737079")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#FFFFFF")!,
                border: ThemeBorder(color: ThemeColor(hex: "#282532")!.withAlpha(0.40), width: 1.15),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.30, radius: 4.20, offsetY: 3.00),
                topHighlight: ThemeColor(hex: "#BDBCC0")!.withAlpha(0.62),
                cornerRadiusOverride: 19.0,
                glass: KeyGlass(
                    bevelColor: ThemeColor(hex: "#C5C4C8")!.withAlpha(0.00),
                    bevelWidth: 0.00,
                    bevelFalloff: 0.50,
                    innerShadowColor: ThemeColor(hex: "#BDBCC0")!,
                    innerShadowOpacity: 0.34,
                    innerShadowRadius: 3.20
                )
            ),
            .system: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#45414D")!,
                    ThemeColor(hex: "#615E68")!
                ]),
                labelColor: ThemeColor(hex: "#FFFFFF")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#6F6D76")!,
                    ThemeColor(hex: "#817F87")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#FFFFFF")!,
                border: ThemeBorder(color: ThemeColor(hex: "#2D2B33")!.withAlpha(0.40), width: 1.15),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.30, radius: 4.20, offsetY: 3.00),
                topHighlight: ThemeColor(hex: "#C5C4C8")!.withAlpha(0.62),
                cornerRadiusOverride: 19.0,
                glass: KeyGlass(
                    bevelColor: ThemeColor(hex: "#CDCCCF")!.withAlpha(0.00),
                    bevelWidth: 0.00,
                    bevelFalloff: 0.50,
                    innerShadowColor: ThemeColor(hex: "#C5C4C8")!,
                    innerShadowOpacity: 0.34,
                    innerShadowRadius: 3.20
                )
            ),
            .action: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#14101F")!,
                    ThemeColor(hex: "#4A4753")!
                ]),
                labelColor: ThemeColor(hex: "#FFFFFF")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#5D5A65")!,
                    ThemeColor(hex: "#737079")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#FFFFFF")!,
                border: ThemeBorder(color: ThemeColor(hex: "#282532")!.withAlpha(0.40), width: 1.15),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.30, radius: 4.20, offsetY: 3.00),
                topHighlight: ThemeColor(hex: "#BDBCC0")!.withAlpha(0.62),
                cornerRadiusOverride: 19.0,
                glass: KeyGlass(
                    bevelColor: ThemeColor(hex: "#C5C4C8")!.withAlpha(0.00),
                    bevelWidth: 0.00,
                    bevelFalloff: 0.50,
                    innerShadowColor: ThemeColor(hex: "#BDBCC0")!,
                    innerShadowOpacity: 0.34,
                    innerShadowRadius: 3.20
                )
            ),
            .space: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#14101F")!.withAlpha(0.50),
                    ThemeColor(hex: "#4A4753")!.withAlpha(0.50)
                ]),
                labelColor: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.00),
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#54515C")!.withAlpha(0.50),
                    ThemeColor(hex: "#6C6973")!.withAlpha(0.50)
                ]),
                border: ThemeBorder(color: ThemeColor(hex: "#BDBCC0")!.withAlpha(0.40), width: 1.15),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.30, radius: 4.20, offsetY: 3.00),
                topHighlight: ThemeColor(hex: "#BDBCC0")!.withAlpha(0.62),
                cornerRadiusOverride: 20.0
            )
        ],
        typography: ThemeTypography(fontFamily: nil, weightRawValue: 0.34, sizeMultiplier: 1.0),
        chrome: ThemeChrome(
            inkColor: ThemeColor(hex: "#F2ECF0")!,
            mutedInkColor: ThemeColor(hex: "#F2ECF0")!.withAlpha(0.55),
            panelFill: ThemeFill(stops: [
                    ThemeColor(hex: "#5B566E")!.withAlpha(0.55)
                ]),
            highlightFill: ThemeFill(stops: [
                    ThemeColor(hex: "#FFFFFF")!.withAlpha(0.16)
                ])
        ),
        keyArt: KeyArtSet(
            assetPrefix: "keyart_ndd_",
            heightFraction: 0.50,
            bottomInsetFraction: 0.10,
            opacity: 0.90,
            fillKeys: ["space"],
            labelLiftFraction: 0.15
        ),
        effects: .none
    )

    static let sweetdreamCarnival = MochiKeyboardTheme(
        id: "mochi.sweetdream-carnival",
        name: "Sweetdream Carnival",
        authorName: "Mochi",
        appearance: .light,
        surface: ThemeSurface(
            baseFill: ThemeFill(stops: [
                    ThemeColor(hex: "#905A98")!,
                    ThemeColor(hex: "#F2A8C4")!,
                    ThemeColor(hex: "#FDB9C6")!
                ]),
            backgroundImage: ThemeBackgroundImage(
                source: .bundled(name: "themebg_sweetdream_carnival"),
                scalesToFill: true,
                verticalAnchor: 0.5,
                blurRadius: 0.0
            ),
            scrim: ThemeScrim(
                topColor: ThemeColor(hex: "#B68091")!.withAlpha(0.18),
                bottomColor: ThemeColor(hex: "#B68091")!.withAlpha(0.05)
            )
        ),
        keyStyles: [
            .input: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#FBB9C1")!,
                    ThemeColor(hex: "#EFB1B8")!
                ]),
                labelColor: ThemeColor(hex: "#221C28")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#E9ACB4")!,
                    ThemeColor(hex: "#DCA3AA")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#221C28")!,
                border: ThemeBorder(color: ThemeColor(hex: "#AF8187")!.withAlpha(0.40), width: 1.15),
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
                    ThemeColor(hex: "#EFB1B8")!,
                    ThemeColor(hex: "#E3A7AF")!
                ]),
                labelColor: ThemeColor(hex: "#221C28")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#DCA3AA")!,
                    ThemeColor(hex: "#CE989F")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#221C28")!,
                border: ThemeBorder(color: ThemeColor(hex: "#A77B80")!.withAlpha(0.40), width: 1.15),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.30, radius: 4.20, offsetY: 3.00),
                topHighlight: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.62),
                cornerRadiusOverride: 19.0,
                glass: KeyGlass(
                    bevelColor: ThemeColor(hex: "#FEFCFD")!.withAlpha(0.00),
                    bevelWidth: 0.00,
                    bevelFalloff: 0.50,
                    innerShadowColor: ThemeColor(hex: "#FFFFFF")!,
                    innerShadowOpacity: 0.34,
                    innerShadowRadius: 3.20
                )
            ),
            .action: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#FBB9C1")!,
                    ThemeColor(hex: "#EFB1B8")!
                ]),
                labelColor: ThemeColor(hex: "#221C28")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#E9ACB4")!,
                    ThemeColor(hex: "#DCA3AA")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#221C28")!,
                border: ThemeBorder(color: ThemeColor(hex: "#AF8187")!.withAlpha(0.40), width: 1.15),
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
                    ThemeColor(hex: "#FBB9C1")!.withAlpha(0.42),
                    ThemeColor(hex: "#EFB1B8")!.withAlpha(0.42)
                ]),
                labelColor: ThemeColor(hex: "#221C28")!.withAlpha(0.00),
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#EBAEB5")!.withAlpha(0.42),
                    ThemeColor(hex: "#DEA4AB")!.withAlpha(0.42)
                ]),
                border: ThemeBorder(color: ThemeColor(hex: "#FEF7F8")!.withAlpha(0.40), width: 1.15),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.30, radius: 4.20, offsetY: 3.00),
                topHighlight: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.62),
                cornerRadiusOverride: 20.0
            )
        ],
        typography: ThemeTypography(fontFamily: nil, weightRawValue: 0.34, sizeMultiplier: 1.0),
        chrome: ThemeChrome(
            inkColor: ThemeColor(hex: "#FFFFFF")!,
            mutedInkColor: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.55),
            panelFill: ThemeFill(stops: [
                    ThemeColor(hex: "#754A79")!.withAlpha(0.55)
                ]),
            highlightFill: ThemeFill(stops: [
                    ThemeColor(hex: "#FFFFFF")!.withAlpha(0.16)
                ])
        ),
        keyArt: KeyArtSet(
            assetPrefix: "keyart_swc_",
            heightFraction: 0.50,
            bottomInsetFraction: 0.10,
            opacity: 0.90,
            fillKeys: ["space"],
            labelLiftFraction: 0.15
        ),
        effects: .none
    )

    static let wanderlustScrapbook = MochiKeyboardTheme(
        id: "mochi.wanderlust-scrapbook",
        name: "Wanderlust Scrapbook",
        authorName: "Mochi",
        appearance: .light,
        surface: ThemeSurface(
            baseFill: ThemeFill(stops: [
                    ThemeColor(hex: "#160C03")!,
                    ThemeColor(hex: "#E8BE86")!,
                    ThemeColor(hex: "#C49054")!
                ]),
            backgroundImage: ThemeBackgroundImage(
                source: .bundled(name: "themebg_wanderlust_scrapbook"),
                scalesToFill: true,
                verticalAnchor: 0.5,
                blurRadius: 0.0
            ),
            scrim: ThemeScrim(
                topColor: ThemeColor(hex: "#9D774C")!.withAlpha(0.18),
                bottomColor: ThemeColor(hex: "#9D774C")!.withAlpha(0.05)
            )
        ),
        keyStyles: [
            .input: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#E4B57B")!,
                    ThemeColor(hex: "#D9AD76")!
                ]),
                labelColor: ThemeColor(hex: "#221C28")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#D1A671")!,
                    ThemeColor(hex: "#C59D6B")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#221C28")!,
                border: ThemeBorder(color: ThemeColor(hex: "#9F7E56")!.withAlpha(0.32), width: 1.35),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.22, radius: 3.60, offsetY: 2.60),
                topHighlight: nil,
                cornerRadiusOverride: 9.0
            ),
            .system: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#D7AB74")!,
                    ThemeColor(hex: "#CCA36E")!
                ]),
                labelColor: ThemeColor(hex: "#221C28")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#C39B69")!,
                    ThemeColor(hex: "#B69162")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#221C28")!,
                border: ThemeBorder(color: ThemeColor(hex: "#967751")!.withAlpha(0.32), width: 1.35),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.22, radius: 3.60, offsetY: 2.60),
                topHighlight: nil,
                cornerRadiusOverride: 9.0
            ),
            .action: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#E4B57B")!,
                    ThemeColor(hex: "#D9AD76")!
                ]),
                labelColor: ThemeColor(hex: "#221C28")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#D1A671")!,
                    ThemeColor(hex: "#C59D6B")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#221C28")!,
                border: ThemeBorder(color: ThemeColor(hex: "#9F7E56")!.withAlpha(0.32), width: 1.35),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.22, radius: 3.60, offsetY: 2.60),
                topHighlight: nil,
                cornerRadiusOverride: 9.0
            ),
            .space: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#E4B57B")!.withAlpha(0.42),
                    ThemeColor(hex: "#D9AD76")!.withAlpha(0.42)
                ]),
                labelColor: ThemeColor(hex: "#221C28")!.withAlpha(0.00),
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#D3A872")!.withAlpha(0.42),
                    ThemeColor(hex: "#C89F6C")!.withAlpha(0.42)
                ]),
                border: ThemeBorder(color: ThemeColor(hex: "#F8EDDF")!.withAlpha(0.32), width: 1.35),
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
                    ThemeColor(hex: "#605850")!.withAlpha(0.55)
                ]),
            highlightFill: ThemeFill(stops: [
                    ThemeColor(hex: "#FFFFFF")!.withAlpha(0.16)
                ])
        ),
        keyArt: KeyArtSet(
            assetPrefix: "keyart_wls_",
            heightFraction: 0.52,
            bottomInsetFraction: 0.10,
            opacity: 0.90,
            fillKeys: ["space"],
            labelLiftFraction: 0.15
        ),
        effects: .none
    )

    static let whisperingMushroomCottage = MochiKeyboardTheme(
        id: "mochi.whispering-mushroom-cottage",
        name: "Whispering Mushroom Cottage",
        authorName: "Mochi",
        appearance: .light,
        surface: ThemeSurface(
            baseFill: ThemeFill(stops: [
                    ThemeColor(hex: "#57451F")!,
                    ThemeColor(hex: "#C9BB68")!,
                    ThemeColor(hex: "#E3C87B")!
                ]),
            backgroundImage: ThemeBackgroundImage(
                source: .bundled(name: "themebg_whispering_mushroom_cottage"),
                scalesToFill: true,
                verticalAnchor: 0.5,
                blurRadius: 0.0
            ),
            scrim: ThemeScrim(
                topColor: ThemeColor(hex: "#8A7F43")!.withAlpha(0.18),
                bottomColor: ThemeColor(hex: "#8A7F43")!.withAlpha(0.05)
            )
        ),
        keyStyles: [
            .input: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#D0BE70")!,
                    ThemeColor(hex: "#C7B66B")!
                ]),
                labelColor: ThemeColor(hex: "#221C28")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#BFAF66")!,
                    ThemeColor(hex: "#B5A561")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#221C28")!,
                border: ThemeBorder(color: ThemeColor(hex: "#91844E")!.withAlpha(0.32), width: 1.35),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.22, radius: 3.60, offsetY: 2.60),
                topHighlight: nil,
                cornerRadiusOverride: 9.0
            ),
            .system: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#C5B46A")!,
                    ThemeColor(hex: "#BBAB64")!
                ]),
                labelColor: ThemeColor(hex: "#221C28")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#B2A360")!,
                    ThemeColor(hex: "#A7985A")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#221C28")!,
                border: ThemeBorder(color: ThemeColor(hex: "#897D49")!.withAlpha(0.32), width: 1.35),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.22, radius: 3.60, offsetY: 2.60),
                topHighlight: nil,
                cornerRadiusOverride: 9.0
            ),
            .action: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#D0BE70")!,
                    ThemeColor(hex: "#C7B66B")!
                ]),
                labelColor: ThemeColor(hex: "#221C28")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#BFAF66")!,
                    ThemeColor(hex: "#B5A561")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#221C28")!,
                border: ThemeBorder(color: ThemeColor(hex: "#91844E")!.withAlpha(0.32), width: 1.35),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.22, radius: 3.60, offsetY: 2.60),
                topHighlight: nil,
                cornerRadiusOverride: 9.0
            ),
            .space: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#D0BE70")!.withAlpha(0.42),
                    ThemeColor(hex: "#C7B66B")!.withAlpha(0.42)
                ]),
                labelColor: ThemeColor(hex: "#221C28")!.withAlpha(0.00),
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#C1B068")!.withAlpha(0.42),
                    ThemeColor(hex: "#B7A762")!.withAlpha(0.42)
                ]),
                border: ThemeBorder(color: ThemeColor(hex: "#F4F0DD")!.withAlpha(0.32), width: 1.35),
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
                    ThemeColor(hex: "#675733")!.withAlpha(0.55)
                ]),
            highlightFill: ThemeFill(stops: [
                    ThemeColor(hex: "#FFFFFF")!.withAlpha(0.16)
                ])
        ),
        keyArt: KeyArtSet(
            assetPrefix: "keyart_wms_",
            heightFraction: 0.52,
            bottomInsetFraction: 0.10,
            opacity: 0.90,
            fillKeys: ["space"],
            labelLiftFraction: 0.15
        ),
        effects: .none
    )

    static let astralGearworks = MochiKeyboardTheme(
        id: "mochi.astral-gearworks",
        name: "Astral Gearworks",
        authorName: "Mochi",
        appearance: .dark,
        surface: ThemeSurface(
            baseFill: ThemeFill(stops: [
                    ThemeColor(hex: "#0E0808")!,
                    ThemeColor(hex: "#101A32")!,
                    ThemeColor(hex: "#131E3C")!
                ]),
            backgroundImage: ThemeBackgroundImage(
                source: .bundled(name: "themebg_astral_gearworks"),
                scalesToFill: true,
                verticalAnchor: 0.5,
                blurRadius: 0.0
            ),
            scrim: ThemeScrim(
                topColor: ThemeColor(hex: "#212636")!.withAlpha(0.18),
                bottomColor: ThemeColor(hex: "#212636")!.withAlpha(0.05)
            )
        ),
        keyStyles: [
            .input: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#111119")!,
                    ThemeColor(hex: "#424348")!
                ]),
                labelColor: ThemeColor(hex: "#FFFFFF")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#5B5B60")!,
                    ThemeColor(hex: "#6D6E72")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#FFFFFF")!,
                border: ThemeBorder(color: ThemeColor(hex: "#D8D8D9")!.withAlpha(0.80), width: 1.00),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.26, radius: 1.60, offsetY: 1.60),
                topHighlight: ThemeColor(hex: "#BCBCBE")!.withAlpha(0.34),
                cornerRadiusOverride: 8.0,
                glass: KeyGlass(
                    bevelColor: ThemeColor(hex: "#C4C5C6")!.withAlpha(0.70),
                    bevelWidth: 1.00,
                    bevelFalloff: 0.10,
                    innerShadowColor: ThemeColor(hex: "#0A080F")!,
                    innerShadowOpacity: 0.16,
                    innerShadowRadius: 2.00
                )
            ),
            .system: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#424348")!,
                    ThemeColor(hex: "#5B5B60")!
                ]),
                labelColor: ThemeColor(hex: "#FFFFFF")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#6D6E72")!,
                    ThemeColor(hex: "#7D7D81")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#FFFFFF")!,
                border: ThemeBorder(color: ThemeColor(hex: "#DFDFE0")!.withAlpha(0.80), width: 1.00),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.26, radius: 1.60, offsetY: 1.60),
                topHighlight: ThemeColor(hex: "#C4C5C6")!.withAlpha(0.34),
                cornerRadiusOverride: 8.0,
                glass: KeyGlass(
                    bevelColor: ThemeColor(hex: "#CCCCCE")!.withAlpha(0.70),
                    bevelWidth: 1.00,
                    bevelFalloff: 0.10,
                    innerShadowColor: ThemeColor(hex: "#0A080F")!,
                    innerShadowOpacity: 0.16,
                    innerShadowRadius: 2.00
                )
            ),
            .action: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#0D121E")!,
                    ThemeColor(hex: "#3F434D")!
                ]),
                labelColor: ThemeColor(hex: "#FFFFFF")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#585C64")!,
                    ThemeColor(hex: "#6B6E76")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#FFFFFF")!,
                border: ThemeBorder(color: ThemeColor(hex: "#D7D8DA")!.withAlpha(0.80), width: 1.00),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.26, radius: 1.60, offsetY: 1.60),
                topHighlight: ThemeColor(hex: "#BBBDC0")!.withAlpha(0.34),
                cornerRadiusOverride: 8.0,
                glass: KeyGlass(
                    bevelColor: ThemeColor(hex: "#C3C5C8")!.withAlpha(0.70),
                    bevelWidth: 1.00,
                    bevelFalloff: 0.10,
                    innerShadowColor: ThemeColor(hex: "#0A080F")!,
                    innerShadowOpacity: 0.16,
                    innerShadowRadius: 2.00
                )
            ),
            .space: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#111119")!.withAlpha(0.50),
                    ThemeColor(hex: "#424348")!.withAlpha(0.50)
                ]),
                labelColor: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.00),
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#525258")!.withAlpha(0.50),
                    ThemeColor(hex: "#66676B")!.withAlpha(0.50)
                ]),
                border: ThemeBorder(color: ThemeColor(hex: "#BCBCBE")!.withAlpha(0.55), width: 1.00),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.26, radius: 1.60, offsetY: 1.60),
                topHighlight: ThemeColor(hex: "#BCBCBE")!.withAlpha(0.34),
                cornerRadiusOverride: 10.0
            )
        ],
        typography: ThemeTypography(fontFamily: nil, weightRawValue: 0.34, sizeMultiplier: 1.0),
        chrome: ThemeChrome(
            inkColor: ThemeColor(hex: "#F2ECF0")!,
            mutedInkColor: ThemeColor(hex: "#F2ECF0")!.withAlpha(0.55),
            panelFill: ThemeFill(stops: [
                    ThemeColor(hex: "#5C5859")!.withAlpha(0.55)
                ]),
            highlightFill: ThemeFill(stops: [
                    ThemeColor(hex: "#FFFFFF")!.withAlpha(0.16)
                ])
        ),
        keyArt: KeyArtSet(
            assetPrefix: "keyart_asg_",
            heightFraction: 0.46,
            bottomInsetFraction: 0.09,
            opacity: 0.90,
            fillKeys: ["space"],
            labelLiftFraction: 0.14
        ),
        effects: .none
    )

    static let egyptThroughTime = MochiKeyboardTheme(
        id: "mochi.egypt-through-time",
        name: "Egypt Through Time",
        authorName: "Mochi",
        appearance: .dark,
        surface: ThemeSurface(
            baseFill: ThemeFill(stops: [
                    ThemeColor(hex: "#785D44")!,
                    ThemeColor(hex: "#160D06")!,
                    ThemeColor(hex: "#1A1208")!
                ]),
            backgroundImage: ThemeBackgroundImage(
                source: .bundled(name: "themebg_egypt_through_time"),
                scalesToFill: true,
                verticalAnchor: 0.5,
                blurRadius: 0.0
            ),
            scrim: ThemeScrim(
                topColor: ThemeColor(hex: "#2F251B")!.withAlpha(0.18),
                bottomColor: ThemeColor(hex: "#2F251B")!.withAlpha(0.05)
            )
        ),
        keyStyles: [
            .input: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#17110A")!,
                    ThemeColor(hex: "#47423C")!
                ]),
                labelColor: ThemeColor(hex: "#FFFFFF")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#5F5B56")!,
                    ThemeColor(hex: "#716E69")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#FFFFFF")!,
                border: ThemeBorder(color: ThemeColor(hex: "#D9D8D7")!.withAlpha(0.80), width: 1.00),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.26, radius: 1.60, offsetY: 1.60),
                topHighlight: ThemeColor(hex: "#BEBCBA")!.withAlpha(0.34),
                cornerRadiusOverride: 8.0,
                glass: KeyGlass(
                    bevelColor: ThemeColor(hex: "#C6C4C3")!.withAlpha(0.70),
                    bevelWidth: 1.00,
                    bevelFalloff: 0.10,
                    innerShadowColor: ThemeColor(hex: "#0A080F")!,
                    innerShadowOpacity: 0.16,
                    innerShadowRadius: 2.00
                )
            ),
            .system: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#47423C")!,
                    ThemeColor(hex: "#5F5B56")!
                ]),
                labelColor: ThemeColor(hex: "#FFFFFF")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#716E69")!,
                    ThemeColor(hex: "#807D79")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#FFFFFF")!,
                border: ThemeBorder(color: ThemeColor(hex: "#DFDFDE")!.withAlpha(0.80), width: 1.00),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.26, radius: 1.60, offsetY: 1.60),
                topHighlight: ThemeColor(hex: "#C6C4C3")!.withAlpha(0.34),
                cornerRadiusOverride: 8.0,
                glass: KeyGlass(
                    bevelColor: ThemeColor(hex: "#CDCCCB")!.withAlpha(0.70),
                    bevelWidth: 1.00,
                    bevelFalloff: 0.10,
                    innerShadowColor: ThemeColor(hex: "#0A080F")!,
                    innerShadowOpacity: 0.16,
                    innerShadowRadius: 2.00
                )
            ),
            .action: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#1A1006")!,
                    ThemeColor(hex: "#49423A")!
                ]),
                labelColor: ThemeColor(hex: "#FFFFFF")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#615B54")!,
                    ThemeColor(hex: "#736D67")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#FFFFFF")!,
                border: ThemeBorder(color: ThemeColor(hex: "#D9D8D6")!.withAlpha(0.80), width: 1.00),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.26, radius: 1.60, offsetY: 1.60),
                topHighlight: ThemeColor(hex: "#BFBCB9")!.withAlpha(0.34),
                cornerRadiusOverride: 8.0,
                glass: KeyGlass(
                    bevelColor: ThemeColor(hex: "#C7C4C2")!.withAlpha(0.70),
                    bevelWidth: 1.00,
                    bevelFalloff: 0.10,
                    innerShadowColor: ThemeColor(hex: "#0A080F")!,
                    innerShadowOpacity: 0.16,
                    innerShadowRadius: 2.00
                )
            ),
            .space: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#17110A")!.withAlpha(0.50),
                    ThemeColor(hex: "#47423C")!.withAlpha(0.50)
                ]),
                labelColor: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.00),
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#57524D")!.withAlpha(0.50),
                    ThemeColor(hex: "#6B6762")!.withAlpha(0.50)
                ]),
                border: ThemeBorder(color: ThemeColor(hex: "#BEBCBA")!.withAlpha(0.55), width: 1.00),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.26, radius: 1.60, offsetY: 1.60),
                topHighlight: ThemeColor(hex: "#BEBCBA")!.withAlpha(0.34),
                cornerRadiusOverride: 10.0
            )
        ],
        typography: ThemeTypography(fontFamily: nil, weightRawValue: 0.34, sizeMultiplier: 1.0),
        chrome: ThemeChrome(
            inkColor: ThemeColor(hex: "#F2ECF0")!,
            mutedInkColor: ThemeColor(hex: "#F2ECF0")!.withAlpha(0.55),
            panelFill: ThemeFill(stops: [
                    ThemeColor(hex: "#5E5853")!.withAlpha(0.55)
                ]),
            highlightFill: ThemeFill(stops: [
                    ThemeColor(hex: "#FFFFFF")!.withAlpha(0.16)
                ])
        ),
        keyArt: KeyArtSet(
            assetPrefix: "keyart_egt_",
            heightFraction: 0.46,
            bottomInsetFraction: 0.09,
            opacity: 0.90,
            fillKeys: ["space"],
            labelLiftFraction: 0.14
        ),
        effects: .none
    )

    static let galaxyMart = MochiKeyboardTheme(
        id: "mochi.galaxy-mart",
        name: "Galaxy Mart",
        authorName: "Mochi",
        appearance: .dark,
        surface: ThemeSurface(
            baseFill: ThemeFill(stops: [
                    ThemeColor(hex: "#060758")!,
                    ThemeColor(hex: "#130F38")!,
                    ThemeColor(hex: "#4E40CC")!
                ]),
            backgroundImage: ThemeBackgroundImage(
                source: .bundled(name: "themebg_galaxy_mart"),
                scalesToFill: true,
                verticalAnchor: 0.5,
                blurRadius: 0.0
            ),
            scrim: ThemeScrim(
                topColor: ThemeColor(hex: "#271F50")!.withAlpha(0.18),
                bottomColor: ThemeColor(hex: "#271F50")!.withAlpha(0.05)
            )
        ),
        keyStyles: [
            .input: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#110D2E")!,
                    ThemeColor(hex: "#49465F")!
                ]),
                labelColor: ThemeColor(hex: "#FFFFFF")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#5C5970")!,
                    ThemeColor(hex: "#726F83")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#FFFFFF")!,
                border: ThemeBorder(color: ThemeColor(hex: "#272341")!.withAlpha(0.40), width: 1.15),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.30, radius: 4.20, offsetY: 3.00),
                topHighlight: ThemeColor(hex: "#BDBCC5")!.withAlpha(0.62),
                cornerRadiusOverride: 19.0,
                glass: KeyGlass(
                    bevelColor: ThemeColor(hex: "#C5C4CC")!.withAlpha(0.00),
                    bevelWidth: 0.00,
                    bevelFalloff: 0.50,
                    innerShadowColor: ThemeColor(hex: "#BDBCC5")!,
                    innerShadowOpacity: 0.34,
                    innerShadowRadius: 3.20
                )
            ),
            .system: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#43405A")!,
                    ThemeColor(hex: "#605D74")!
                ]),
                labelColor: ThemeColor(hex: "#FFFFFF")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#6F6C80")!,
                    ThemeColor(hex: "#817E90")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#FFFFFF")!,
                border: ThemeBorder(color: ThemeColor(hex: "#2C2A3B")!.withAlpha(0.40), width: 1.15),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.30, radius: 4.20, offsetY: 3.00),
                topHighlight: ThemeColor(hex: "#C5C4CC")!.withAlpha(0.62),
                cornerRadiusOverride: 19.0,
                glass: KeyGlass(
                    bevelColor: ThemeColor(hex: "#CDCCD3")!.withAlpha(0.00),
                    bevelWidth: 0.00,
                    bevelFalloff: 0.50,
                    innerShadowColor: ThemeColor(hex: "#C5C4CC")!,
                    innerShadowOpacity: 0.34,
                    innerShadowRadius: 3.20
                )
            ),
            .action: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#110D2E")!,
                    ThemeColor(hex: "#49465F")!
                ]),
                labelColor: ThemeColor(hex: "#FFFFFF")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#5C5970")!,
                    ThemeColor(hex: "#726F83")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#FFFFFF")!,
                border: ThemeBorder(color: ThemeColor(hex: "#272341")!.withAlpha(0.40), width: 1.15),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.30, radius: 4.20, offsetY: 3.00),
                topHighlight: ThemeColor(hex: "#BDBCC5")!.withAlpha(0.62),
                cornerRadiusOverride: 19.0,
                glass: KeyGlass(
                    bevelColor: ThemeColor(hex: "#C5C4CC")!.withAlpha(0.00),
                    bevelWidth: 0.00,
                    bevelFalloff: 0.50,
                    innerShadowColor: ThemeColor(hex: "#BDBCC5")!,
                    innerShadowOpacity: 0.34,
                    innerShadowRadius: 3.20
                )
            ),
            .space: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#110D2E")!.withAlpha(0.50),
                    ThemeColor(hex: "#49465F")!.withAlpha(0.50)
                ]),
                labelColor: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.00),
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#535068")!.withAlpha(0.50),
                    ThemeColor(hex: "#6B687D")!.withAlpha(0.50)
                ]),
                border: ThemeBorder(color: ThemeColor(hex: "#BDBCC5")!.withAlpha(0.40), width: 1.15),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.30, radius: 4.20, offsetY: 3.00),
                topHighlight: ThemeColor(hex: "#BDBCC5")!.withAlpha(0.62),
                cornerRadiusOverride: 20.0
            )
        ],
        typography: ThemeTypography(fontFamily: nil, weightRawValue: 0.34, sizeMultiplier: 1.0),
        chrome: ThemeChrome(
            inkColor: ThemeColor(hex: "#F2ECF0")!,
            mutedInkColor: ThemeColor(hex: "#F2ECF0")!.withAlpha(0.55),
            panelFill: ThemeFill(stops: [
                    ThemeColor(hex: "#595673")!.withAlpha(0.55)
                ]),
            highlightFill: ThemeFill(stops: [
                    ThemeColor(hex: "#FFFFFF")!.withAlpha(0.16)
                ])
        ),
        keyArt: KeyArtSet(
            assetPrefix: "keyart_gxm_",
            heightFraction: 0.50,
            bottomInsetFraction: 0.10,
            opacity: 0.90,
            fillKeys: ["space"],
            labelLiftFraction: 0.15
        ),
        effects: .none
    )

    static let midnightRacingGarage = MochiKeyboardTheme(
        id: "mochi.midnight-racing-garage",
        name: "Midnight Racing Garage",
        authorName: "Mochi",
        appearance: .dark,
        surface: ThemeSurface(
            baseFill: ThemeFill(stops: [
                    ThemeColor(hex: "#111E3F")!,
                    ThemeColor(hex: "#0C0D17")!,
                    ThemeColor(hex: "#141728")!
                ]),
            backgroundImage: ThemeBackgroundImage(
                source: .bundled(name: "themebg_midnight_racing_garage"),
                scalesToFill: true,
                verticalAnchor: 0.5,
                blurRadius: 0.0
            ),
            scrim: ThemeScrim(
                topColor: ThemeColor(hex: "#262532")!.withAlpha(0.18),
                bottomColor: ThemeColor(hex: "#262532")!.withAlpha(0.05)
            )
        ),
        keyStyles: [
            .input: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#13111A")!,
                    ThemeColor(hex: "#444249")!
                ]),
                labelColor: ThemeColor(hex: "#FFFFFF")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#5C5B61")!,
                    ThemeColor(hex: "#6F6D73")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#FFFFFF")!,
                border: ThemeBorder(color: ThemeColor(hex: "#D8D8D9")!.withAlpha(0.80), width: 1.00),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.26, radius: 1.60, offsetY: 1.60),
                topHighlight: ThemeColor(hex: "#BDBCBF")!.withAlpha(0.34),
                cornerRadiusOverride: 8.0,
                glass: KeyGlass(
                    bevelColor: ThemeColor(hex: "#C5C4C7")!.withAlpha(0.70),
                    bevelWidth: 1.00,
                    bevelFalloff: 0.10,
                    innerShadowColor: ThemeColor(hex: "#0A080F")!,
                    innerShadowOpacity: 0.16,
                    innerShadowRadius: 2.00
                )
            ),
            .system: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#444249")!,
                    ThemeColor(hex: "#5C5B61")!
                ]),
                labelColor: ThemeColor(hex: "#FFFFFF")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#6F6D73")!,
                    ThemeColor(hex: "#7E7D82")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#FFFFFF")!,
                border: ThemeBorder(color: ThemeColor(hex: "#DFDFE0")!.withAlpha(0.80), width: 1.00),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.26, radius: 1.60, offsetY: 1.60),
                topHighlight: ThemeColor(hex: "#C5C4C7")!.withAlpha(0.34),
                cornerRadiusOverride: 8.0,
                glass: KeyGlass(
                    bevelColor: ThemeColor(hex: "#CDCCCE")!.withAlpha(0.70),
                    bevelWidth: 1.00,
                    bevelFalloff: 0.10,
                    innerShadowColor: ThemeColor(hex: "#0A080F")!,
                    innerShadowOpacity: 0.16,
                    innerShadowRadius: 2.00
                )
            ),
            .action: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#13111A")!,
                    ThemeColor(hex: "#444249")!
                ]),
                labelColor: ThemeColor(hex: "#FFFFFF")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#5C5B61")!,
                    ThemeColor(hex: "#6F6D73")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#FFFFFF")!,
                border: ThemeBorder(color: ThemeColor(hex: "#D8D8D9")!.withAlpha(0.80), width: 1.00),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.26, radius: 1.60, offsetY: 1.60),
                topHighlight: ThemeColor(hex: "#BDBCBF")!.withAlpha(0.34),
                cornerRadiusOverride: 8.0,
                glass: KeyGlass(
                    bevelColor: ThemeColor(hex: "#C5C4C7")!.withAlpha(0.70),
                    bevelWidth: 1.00,
                    bevelFalloff: 0.10,
                    innerShadowColor: ThemeColor(hex: "#0A080F")!,
                    innerShadowOpacity: 0.16,
                    innerShadowRadius: 2.00
                )
            ),
            .space: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#13111A")!.withAlpha(0.50),
                    ThemeColor(hex: "#444249")!.withAlpha(0.50)
                ]),
                labelColor: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.00),
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#545258")!.withAlpha(0.50),
                    ThemeColor(hex: "#68666C")!.withAlpha(0.50)
                ]),
                border: ThemeBorder(color: ThemeColor(hex: "#BDBCBF")!.withAlpha(0.55), width: 1.00),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.26, radius: 1.60, offsetY: 1.60),
                topHighlight: ThemeColor(hex: "#BDBCBF")!.withAlpha(0.34),
                cornerRadiusOverride: 10.0
            )
        ],
        typography: ThemeTypography(fontFamily: nil, weightRawValue: 0.34, sizeMultiplier: 1.0),
        chrome: ThemeChrome(
            inkColor: ThemeColor(hex: "#F2ECF0")!,
            mutedInkColor: ThemeColor(hex: "#F2ECF0")!.withAlpha(0.55),
            panelFill: ThemeFill(stops: [
                    ThemeColor(hex: "#585960")!.withAlpha(0.55)
                ]),
            highlightFill: ThemeFill(stops: [
                    ThemeColor(hex: "#FFFFFF")!.withAlpha(0.16)
                ])
        ),
        keyArt: KeyArtSet(
            assetPrefix: "keyart_mrg_",
            heightFraction: 0.46,
            bottomInsetFraction: 0.09,
            opacity: 0.90,
            fillKeys: ["space"],
            labelLiftFraction: 0.14
        ),
        effects: .none
    )

    static let moonlitHydrangea = MochiKeyboardTheme(
        id: "mochi.moonlit-hydrangea",
        name: "Moonlit Hydrangea",
        authorName: "Mochi",
        appearance: .dark,
        surface: ThemeSurface(
            baseFill: ThemeFill(stops: [
                    ThemeColor(hex: "#505A9A")!,
                    ThemeColor(hex: "#253461")!,
                    ThemeColor(hex: "#5A58B2")!
                ]),
            backgroundImage: ThemeBackgroundImage(
                source: .bundled(name: "themebg_moonlit_hydrangea"),
                scalesToFill: true,
                verticalAnchor: 0.5,
                blurRadius: 0.0
            ),
            scrim: ThemeScrim(
                topColor: ThemeColor(hex: "#232B53")!.withAlpha(0.18),
                bottomColor: ThemeColor(hex: "#232B53")!.withAlpha(0.05)
            )
        ),
        keyStyles: [
            .input: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#191C49")!,
                    ThemeColor(hex: "#13283B")!
                ]),
                labelColor: ThemeColor(hex: "#FFFFFF")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#5B5D7D")!,
                    ThemeColor(hex: "#536371")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#FFFFFF")!,
                border: ThemeBorder(color: ThemeColor(hex: "#C5C5D1")!.withAlpha(0.42), width: 0.95),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.15, radius: 2.20, offsetY: 1.30),
                topHighlight: ThemeColor(hex: "#BCBDCA")!.withAlpha(0.46),
                cornerRadiusOverride: 14.0,
                glass: KeyGlass(
                    bevelColor: ThemeColor(hex: "#C5C5D1")!.withAlpha(0.60),
                    bevelWidth: 0.80,
                    bevelFalloff: 0.18,
                    innerShadowColor: ThemeColor(hex: "#0A080F")!,
                    innerShadowOpacity: 0.12,
                    innerShadowRadius: 2.00
                )
            ),
            .system: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#414A67")!,
                    ThemeColor(hex: "#6B7289")!
                ]),
                labelColor: ThemeColor(hex: "#FFFFFF")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#6B7289")!,
                    ThemeColor(hex: "#888EA0")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#FFFFFF")!,
                border: ThemeBorder(color: ThemeColor(hex: "#CCCED6")!.withAlpha(0.42), width: 0.95),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.15, radius: 2.20, offsetY: 1.30),
                topHighlight: ThemeColor(hex: "#C4C7D0")!.withAlpha(0.46),
                cornerRadiusOverride: 14.0,
                glass: KeyGlass(
                    bevelColor: ThemeColor(hex: "#CCCED6")!.withAlpha(0.60),
                    bevelWidth: 0.80,
                    bevelFalloff: 0.18,
                    innerShadowColor: ThemeColor(hex: "#0A080F")!,
                    innerShadowOpacity: 0.12,
                    innerShadowRadius: 2.00
                )
            ),
            .action: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#1A2448")!,
                    ThemeColor(hex: "#59617A")!
                ]),
                labelColor: ThemeColor(hex: "#FFFFFF")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#59617A")!,
                    ThemeColor(hex: "#7A8195")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#FFFFFF")!,
                border: ThemeBorder(color: ThemeColor(hex: "#C4C7D0")!.withAlpha(0.42), width: 0.95),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.15, radius: 2.20, offsetY: 1.30),
                topHighlight: ThemeColor(hex: "#BBBFC9")!.withAlpha(0.46),
                cornerRadiusOverride: 14.0,
                glass: KeyGlass(
                    bevelColor: ThemeColor(hex: "#C4C7D0")!.withAlpha(0.60),
                    bevelWidth: 0.80,
                    bevelFalloff: 0.18,
                    innerShadowColor: ThemeColor(hex: "#0A080F")!,
                    innerShadowOpacity: 0.12,
                    innerShadowRadius: 2.00
                )
            ),
            .space: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#191C49")!.withAlpha(0.50),
                    ThemeColor(hex: "#13283B")!.withAlpha(0.50)
                ]),
                labelColor: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.00),
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#525476")!.withAlpha(0.50),
                    ThemeColor(hex: "#4A5B6A")!.withAlpha(0.50)
                ]),
                border: ThemeBorder(color: ThemeColor(hex: "#BCBDCA")!.withAlpha(0.42), width: 0.95),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.15, radius: 2.20, offsetY: 1.30),
                topHighlight: ThemeColor(hex: "#BCBDCA")!.withAlpha(0.46),
                cornerRadiusOverride: 16.0
            )
        ],
        typography: ThemeTypography(fontFamily: nil, weightRawValue: 0.34, sizeMultiplier: 1.0),
        chrome: ThemeChrome(
            inkColor: ThemeColor(hex: "#F2ECF0")!,
            mutedInkColor: ThemeColor(hex: "#F2ECF0")!.withAlpha(0.55),
            panelFill: ThemeFill(stops: [
                    ThemeColor(hex: "#4C587D")!.withAlpha(0.55)
                ]),
            highlightFill: ThemeFill(stops: [
                    ThemeColor(hex: "#FFFFFF")!.withAlpha(0.16)
                ])
        ),
        keyArt: KeyArtSet(
            assetPrefix: "keyart_mhy_",
            heightFraction: 0.48,
            bottomInsetFraction: 0.09,
            opacity: 0.90,
            fillKeys: ["space"],
            labelLiftFraction: 0.14
        ),
        effects: .none
    )

    static let pirateTreasureNight = MochiKeyboardTheme(
        id: "mochi.pirate-treasure-night",
        name: "Pirate Treasure Night",
        authorName: "Mochi",
        appearance: .dark,
        surface: ThemeSurface(
            baseFill: ThemeFill(stops: [
                    ThemeColor(hex: "#2B4E7E")!,
                    ThemeColor(hex: "#0C1324")!,
                    ThemeColor(hex: "#623E26")!
                ]),
            backgroundImage: ThemeBackgroundImage(
                source: .bundled(name: "themebg_pirate_treasure_night"),
                scalesToFill: true,
                verticalAnchor: 0.5,
                blurRadius: 0.0
            ),
            scrim: ThemeScrim(
                topColor: ThemeColor(hex: "#262630")!.withAlpha(0.20),
                bottomColor: ThemeColor(hex: "#262630")!.withAlpha(0.06)
            )
        ),
        keyStyles: [
            .input: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#0F111C")!,
                    ThemeColor(hex: "#2F313A")!
                ]),
                labelColor: ThemeColor(hex: "#FFFFFF")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#5A5B62")!,
                    ThemeColor(hex: "#64656C")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#FFFFFF")!,
                border: ThemeBorder(color: ThemeColor(hex: "#D7D8DA")!.withAlpha(0.85), width: 1.00),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.32, radius: 2.60, offsetY: 1.60),
                topHighlight: ThemeColor(hex: "#BCBCBF")!.withAlpha(0.28),
                cornerRadiusOverride: 12.0,
                glass: KeyGlass(
                    bevelColor: ThemeColor(hex: "#C4C5C7")!.withAlpha(0.62),
                    bevelWidth: 1.00,
                    bevelFalloff: 0.12,
                    innerShadowColor: ThemeColor(hex: "#0A080F")!,
                    innerShadowOpacity: 0.36,
                    innerShadowRadius: 3.00
                )
            ),
            .system: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#41434B")!,
                    ThemeColor(hex: "#4E5058")!
                ]),
                labelColor: ThemeColor(hex: "#FFFFFF")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#6C6E74")!,
                    ThemeColor(hex: "#74767C")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#FFFFFF")!,
                border: ThemeBorder(color: ThemeColor(hex: "#DEDFE0")!.withAlpha(0.85), width: 1.00),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.32, radius: 2.60, offsetY: 1.60),
                topHighlight: ThemeColor(hex: "#C4C5C7")!.withAlpha(0.28),
                cornerRadiusOverride: 12.0,
                glass: KeyGlass(
                    bevelColor: ThemeColor(hex: "#CCCCCE")!.withAlpha(0.62),
                    bevelWidth: 1.00,
                    bevelFalloff: 0.12,
                    innerShadowColor: ThemeColor(hex: "#0A080F")!,
                    innerShadowOpacity: 0.36,
                    innerShadowRadius: 3.00
                )
            ),
            .action: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#0D121E")!,
                    ThemeColor(hex: "#2E313C")!
                ]),
                labelColor: ThemeColor(hex: "#FFFFFF")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#595C64")!,
                    ThemeColor(hex: "#63656D")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#FFFFFF")!,
                border: ThemeBorder(color: ThemeColor(hex: "#D7D8DA")!.withAlpha(0.85), width: 1.00),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.32, radius: 2.60, offsetY: 1.60),
                topHighlight: ThemeColor(hex: "#BBBDC0")!.withAlpha(0.28),
                cornerRadiusOverride: 12.0,
                glass: KeyGlass(
                    bevelColor: ThemeColor(hex: "#C4C5C8")!.withAlpha(0.62),
                    bevelWidth: 1.00,
                    bevelFalloff: 0.12,
                    innerShadowColor: ThemeColor(hex: "#0A080F")!,
                    innerShadowOpacity: 0.36,
                    innerShadowRadius: 3.00
                )
            ),
            .space: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#0F111C")!.withAlpha(0.50),
                    ThemeColor(hex: "#2F313A")!.withAlpha(0.50)
                ]),
                labelColor: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.00),
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#51535A")!.withAlpha(0.50),
                    ThemeColor(hex: "#5C5D64")!.withAlpha(0.50)
                ]),
                border: ThemeBorder(color: ThemeColor(hex: "#BCBCBF")!.withAlpha(0.60), width: 1.00),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.32, radius: 2.60, offsetY: 1.60),
                topHighlight: ThemeColor(hex: "#BCBCBF")!.withAlpha(0.28),
                cornerRadiusOverride: 14.0
            )
        ],
        typography: ThemeTypography(fontFamily: nil, weightRawValue: 0.34, sizeMultiplier: 1.0),
        chrome: ThemeChrome(
            inkColor: ThemeColor(hex: "#F2ECF0")!,
            mutedInkColor: ThemeColor(hex: "#F2ECF0")!.withAlpha(0.55),
            panelFill: ThemeFill(stops: [
                    ThemeColor(hex: "#545965")!.withAlpha(0.55)
                ]),
            highlightFill: ThemeFill(stops: [
                    ThemeColor(hex: "#FFFFFF")!.withAlpha(0.16)
                ])
        ),
        keyArt: KeyArtSet(
            assetPrefix: "keyart_ptn_",
            heightFraction: 0.44,
            bottomInsetFraction: 0.09,
            opacity: 0.90,
            fillKeys: ["space"],
            labelLiftFraction: 0.14
        ),
        effects: .none
    )

    static let starlit90sHaven = MochiKeyboardTheme(
        id: "mochi.starlit-90s-haven",
        name: "Starlit 90s Haven",
        authorName: "Mochi",
        appearance: .light,
        surface: ThemeSurface(
            baseFill: ThemeFill(stops: [
                    ThemeColor(hex: "#452F56")!,
                    ThemeColor(hex: "#886B99")!,
                    ThemeColor(hex: "#B790A5")!
                ]),
            backgroundImage: ThemeBackgroundImage(
                source: .bundled(name: "themebg_starlit_90s_haven"),
                scalesToFill: true,
                verticalAnchor: 0.5,
                blurRadius: 0.0
            ),
            scrim: ThemeScrim(
                topColor: ThemeColor(hex: "#6B526E")!.withAlpha(0.18),
                bottomColor: ThemeColor(hex: "#6B526E")!.withAlpha(0.05)
            )
        ),
        keyStyles: [
            .input: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#C8ADBE")!,
                    ThemeColor(hex: "#BCA3B2")!
                ]),
                labelColor: ThemeColor(hex: "#0D0B0F")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#B59DAC")!,
                    ThemeColor(hex: "#A7919F")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#0D0B0F")!,
                border: ThemeBorder(color: ThemeColor(hex: "#8B7884")!.withAlpha(0.40), width: 1.15),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.30, radius: 4.20, offsetY: 3.00),
                topHighlight: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.62),
                cornerRadiusOverride: 19.0,
                glass: KeyGlass(
                    bevelColor: ThemeColor(hex: "#F7F4F6")!.withAlpha(0.00),
                    bevelWidth: 0.00,
                    bevelFalloff: 0.50,
                    innerShadowColor: ThemeColor(hex: "#FCFAFB")!,
                    innerShadowOpacity: 0.34,
                    innerShadowRadius: 3.20
                )
            ),
            .system: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#BCA3B2")!,
                    ThemeColor(hex: "#AF97A5")!
                ]),
                labelColor: ThemeColor(hex: "#0D0B0F")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#A7919F")!,
                    ThemeColor(hex: "#988390")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#0D0B0F")!,
                border: ThemeBorder(color: ThemeColor(hex: "#82717C")!.withAlpha(0.40), width: 1.15),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.30, radius: 4.20, offsetY: 3.00),
                topHighlight: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.62),
                cornerRadiusOverride: 19.0,
                glass: KeyGlass(
                    bevelColor: ThemeColor(hex: "#F1ECEF")!.withAlpha(0.00),
                    bevelWidth: 0.00,
                    bevelFalloff: 0.50,
                    innerShadowColor: ThemeColor(hex: "#F6F3F5")!,
                    innerShadowOpacity: 0.34,
                    innerShadowRadius: 3.20
                )
            ),
            .action: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#BDB1BD")!,
                    ThemeColor(hex: "#B2A6B1")!
                ]),
                labelColor: ThemeColor(hex: "#0D0B0F")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#ABA1AB")!,
                    ThemeColor(hex: "#9E949E")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#0D0B0F")!,
                border: ThemeBorder(color: ThemeColor(hex: "#837B83")!.withAlpha(0.40), width: 1.15),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.30, radius: 4.20, offsetY: 3.00),
                topHighlight: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.62),
                cornerRadiusOverride: 19.0,
                glass: KeyGlass(
                    bevelColor: ThemeColor(hex: "#F6F4F6")!.withAlpha(0.00),
                    bevelWidth: 0.00,
                    bevelFalloff: 0.50,
                    innerShadowColor: ThemeColor(hex: "#FBFAFB")!,
                    innerShadowOpacity: 0.34,
                    innerShadowRadius: 3.20
                )
            ),
            .space: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#C8ADBE")!.withAlpha(0.42),
                    ThemeColor(hex: "#BCA3B2")!.withAlpha(0.42)
                ]),
                labelColor: ThemeColor(hex: "#0D0B0F")!.withAlpha(0.00),
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#B89FAE")!.withAlpha(0.42),
                    ThemeColor(hex: "#AA93A1")!.withAlpha(0.42)
                ]),
                border: ThemeBorder(color: ThemeColor(hex: "#EEE6EB")!.withAlpha(0.40), width: 1.15),
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
                    ThemeColor(hex: "#655272")!.withAlpha(0.55)
                ]),
            highlightFill: ThemeFill(stops: [
                    ThemeColor(hex: "#FFFFFF")!.withAlpha(0.16)
                ])
        ),
        keyArt: KeyArtSet(
            assetPrefix: "keyart_s90_",
            heightFraction: 0.50,
            bottomInsetFraction: 0.10,
            opacity: 0.90,
            fillKeys: ["space"],
            labelLiftFraction: 0.15
        ),
        effects: .none
    )

    static let starlitDiscoReverie = MochiKeyboardTheme(
        id: "mochi.starlit-disco-reverie",
        name: "Starlit Disco Reverie",
        authorName: "Mochi",
        appearance: .dark,
        surface: ThemeSurface(
            baseFill: ThemeFill(stops: [
                    ThemeColor(hex: "#590448")!,
                    ThemeColor(hex: "#140522")!,
                    ThemeColor(hex: "#9B0E6B")!
                ]),
            backgroundImage: ThemeBackgroundImage(
                source: .bundled(name: "themebg_starlit_disco_reverie"),
                scalesToFill: true,
                verticalAnchor: 0.5,
                blurRadius: 0.0
            ),
            scrim: ThemeScrim(
                topColor: ThemeColor(hex: "#391B3F")!.withAlpha(0.18),
                bottomColor: ThemeColor(hex: "#391B3F")!.withAlpha(0.05)
            )
        ),
        keyStyles: [
            .input: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#1A0B27")!,
                    ThemeColor(hex: "#4A3F54")!
                ]),
                labelColor: ThemeColor(hex: "#FFFFFF")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#62586B")!,
                    ThemeColor(hex: "#746B7C")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#FFFFFF")!,
                border: ThemeBorder(color: ThemeColor(hex: "#D9D7DC")!.withAlpha(0.80), width: 1.00),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.26, radius: 1.60, offsetY: 1.60),
                topHighlight: ThemeColor(hex: "#BFBBC3")!.withAlpha(0.34),
                cornerRadiusOverride: 8.0,
                glass: KeyGlass(
                    bevelColor: ThemeColor(hex: "#C7C3CA")!.withAlpha(0.70),
                    bevelWidth: 1.00,
                    bevelFalloff: 0.10,
                    innerShadowColor: ThemeColor(hex: "#0A080F")!,
                    innerShadowOpacity: 0.16,
                    innerShadowRadius: 2.00
                )
            ),
            .system: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#4A3F54")!,
                    ThemeColor(hex: "#62586B")!
                ]),
                labelColor: ThemeColor(hex: "#FFFFFF")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#746B7C")!,
                    ThemeColor(hex: "#827A89")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#FFFFFF")!,
                border: ThemeBorder(color: ThemeColor(hex: "#E0DEE2")!.withAlpha(0.80), width: 1.00),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.26, radius: 1.60, offsetY: 1.60),
                topHighlight: ThemeColor(hex: "#C7C3CA")!.withAlpha(0.34),
                cornerRadiusOverride: 8.0,
                glass: KeyGlass(
                    bevelColor: ThemeColor(hex: "#CECBD1")!.withAlpha(0.70),
                    bevelWidth: 1.00,
                    bevelFalloff: 0.10,
                    innerShadowColor: ThemeColor(hex: "#0A080F")!,
                    innerShadowOpacity: 0.16,
                    innerShadowRadius: 2.00
                )
            ),
            .action: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#230622")!,
                    ThemeColor(hex: "#523C52")!
                ]),
                labelColor: ThemeColor(hex: "#FFFFFF")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#695569")!,
                    ThemeColor(hex: "#7A697A")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#FFFFFF")!,
                border: ThemeBorder(color: ThemeColor(hex: "#DBD7DB")!.withAlpha(0.80), width: 1.00),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.26, radius: 1.60, offsetY: 1.60),
                topHighlight: ThemeColor(hex: "#C2BAC2")!.withAlpha(0.34),
                cornerRadiusOverride: 8.0,
                glass: KeyGlass(
                    bevelColor: ThemeColor(hex: "#CAC3C9")!.withAlpha(0.70),
                    bevelWidth: 1.00,
                    bevelFalloff: 0.10,
                    innerShadowColor: ThemeColor(hex: "#0A080F")!,
                    innerShadowOpacity: 0.16,
                    innerShadowRadius: 2.00
                )
            ),
            .space: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#1A0B27")!.withAlpha(0.50),
                    ThemeColor(hex: "#4A3F54")!.withAlpha(0.50)
                ]),
                labelColor: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.00),
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#594F63")!.withAlpha(0.50),
                    ThemeColor(hex: "#6D6475")!.withAlpha(0.50)
                ]),
                border: ThemeBorder(color: ThemeColor(hex: "#BFBBC3")!.withAlpha(0.55), width: 1.00),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.26, radius: 1.60, offsetY: 1.60),
                topHighlight: ThemeColor(hex: "#BFBBC3")!.withAlpha(0.34),
                cornerRadiusOverride: 10.0
            )
        ],
        typography: ThemeTypography(fontFamily: nil, weightRawValue: 0.34, sizeMultiplier: 1.0),
        chrome: ThemeChrome(
            inkColor: ThemeColor(hex: "#F2ECF0")!,
            mutedInkColor: ThemeColor(hex: "#F2ECF0")!.withAlpha(0.55),
            panelFill: ThemeFill(stops: [
                    ThemeColor(hex: "#605569")!.withAlpha(0.55)
                ]),
            highlightFill: ThemeFill(stops: [
                    ThemeColor(hex: "#FFFFFF")!.withAlpha(0.16)
                ])
        ),
        keyArt: KeyArtSet(
            assetPrefix: "keyart_sdr_",
            heightFraction: 0.46,
            bottomInsetFraction: 0.09,
            opacity: 0.90,
            fillKeys: ["space"],
            labelLiftFraction: 0.14
        ),
        effects: .none
    )

    static let sunsetMirage = MochiKeyboardTheme(
        id: "mochi.sunset-mirage",
        name: "Sunset Mirage",
        authorName: "Mochi",
        appearance: .light,
        surface: ThemeSurface(
            baseFill: ThemeFill(stops: [
                    ThemeColor(hex: "#E98247")!,
                    ThemeColor(hex: "#EA8A2D")!,
                    ThemeColor(hex: "#9D4517")!
                ]),
            backgroundImage: ThemeBackgroundImage(
                source: .bundled(name: "themebg_sunset_mirage"),
                scalesToFill: true,
                verticalAnchor: 0.5,
                blurRadius: 0.0
            ),
            scrim: ThemeScrim(
                topColor: ThemeColor(hex: "#804214")!.withAlpha(0.18),
                bottomColor: ThemeColor(hex: "#804214")!.withAlpha(0.05)
            )
        ),
        keyStyles: [
            .input: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#ECBC6A")!,
                    ThemeColor(hex: "#F0846E")!
                ]),
                labelColor: ThemeColor(hex: "#000000")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#DAAE62")!,
                    ThemeColor(hex: "#D27461")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#000000")!,
                border: ThemeBorder(color: ThemeColor(hex: "#FBF3E3")!.withAlpha(0.42), width: 0.95),
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
                    ThemeColor(hex: "#DB9D67")!,
                    ThemeColor(hex: "#C08A5A")!
                ]),
                labelColor: ThemeColor(hex: "#000000")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#C38C5B")!,
                    ThemeColor(hex: "#A3754C")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#000000")!,
                border: ThemeBorder(color: ThemeColor(hex: "#F2DDCA")!.withAlpha(0.42), width: 0.95),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.15, radius: 2.20, offsetY: 1.30),
                topHighlight: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.46),
                cornerRadiusOverride: 14.0,
                glass: KeyGlass(
                    bevelColor: ThemeColor(hex: "#F8EBE1")!.withAlpha(0.60),
                    bevelWidth: 0.80,
                    bevelFalloff: 0.18,
                    innerShadowColor: ThemeColor(hex: "#0A080F")!,
                    innerShadowOpacity: 0.12,
                    innerShadowRadius: 2.00
                )
            ),
            .action: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#CDAF9A")!,
                    ThemeColor(hex: "#B79D8A")!
                ]),
                labelColor: ThemeColor(hex: "#000000")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#BA9F8C")!,
                    ThemeColor(hex: "#A18A79")!
                ]),
                pressedLabelColor: ThemeColor(hex: "#000000")!,
                border: ThemeBorder(color: ThemeColor(hex: "#F0E7E1")!.withAlpha(0.42), width: 0.95),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.15, radius: 2.20, offsetY: 1.30),
                topHighlight: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.46),
                cornerRadiusOverride: 14.0,
                glass: KeyGlass(
                    bevelColor: ThemeColor(hex: "#F8F4F1")!.withAlpha(0.60),
                    bevelWidth: 0.80,
                    bevelFalloff: 0.18,
                    innerShadowColor: ThemeColor(hex: "#0A080F")!,
                    innerShadowOpacity: 0.12,
                    innerShadowRadius: 2.00
                )
            ),
            .space: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#ECBC6A")!.withAlpha(0.42),
                    ThemeColor(hex: "#F0846E")!.withAlpha(0.42)
                ]),
                labelColor: ThemeColor(hex: "#000000")!.withAlpha(0.00),
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#DCB063")!.withAlpha(0.42),
                    ThemeColor(hex: "#D67562")!.withAlpha(0.42)
                ]),
                border: ThemeBorder(color: ThemeColor(hex: "#FBF3E3")!.withAlpha(0.42), width: 0.95),
                shadow: ThemeShadow(color: ThemeColor(hex: "#0F0A17")!, opacity: 0.15, radius: 2.20, offsetY: 1.30),
                topHighlight: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.46),
                cornerRadiusOverride: 16.0
            )
        ],
        typography: ThemeTypography(fontFamily: nil, weightRawValue: 0.34, sizeMultiplier: 1.0),
        chrome: ThemeChrome(
            inkColor: ThemeColor(hex: "#FFFFFF")!,
            mutedInkColor: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.55),
            panelFill: ThemeFill(stops: [
                    ThemeColor(hex: "#934116")!.withAlpha(0.55)
                ]),
            highlightFill: ThemeFill(stops: [
                    ThemeColor(hex: "#FFFFFF")!.withAlpha(0.16)
                ])
        ),
        keyArt: KeyArtSet(
            assetPrefix: "keyart_sum_",
            heightFraction: 0.48,
            bottomInsetFraction: 0.09,
            opacity: 0.90,
            fillKeys: ["space"],
            labelLiftFraction: 0.14
        ),
        effects: .none
    )
}
