import Foundation

/// Themes compiled into the app and the extension.
///
/// At least one of these must always render correctly with no App Group, no network, and no user
/// data — it is what the keyboard falls back to on a fresh install, on a failed sync, and on a
/// theme document it cannot read.
enum BuiltInThemes {
    static let `default` = cozySakuraCafe

    static let all: [MochiKeyboardTheme] = [
        cozySakuraCafe, fantasyCastleNight, dreamyCastle
    ] + batch2 + batch3 + batch4 + batch5 + batch6 + batch7 + batch8

    // MARK: - Cozy Sakura Café

    /// Lantern-lit café street under cherry blossoms. Soft **jelly** caps — near-opaque lavender milk
    /// with a bright inner glow and a white rim — in the pale-lavender look of the theme's showcase art.
    /// The plate itself is a very deep night (mean L 0.05), so the scrim *lifts* it toward lavender rather
    /// than darkening it: dark caps on a black plate read murky, pale caps on a lifted violet read cosy.
    /// Return keeps the café's sakura-pink accent, softened to sit in the same pastel family.
    static let cozySakuraCafe = MochiKeyboardTheme(
        id: "mochi.cozy-sakura-cafe",
        name: "Cozy Sakura Café",
        authorName: "Mochi",
        appearance: .dark,
        surface: ThemeSurface(
            baseFill: ThemeFill(stops: [
                ThemeColor(hex: "#3A2470")!,
                ThemeColor(hex: "#5A3A8E")!,
                ThemeColor(hex: "#7A4A96")!
            ]),
            backgroundImage: ThemeBackgroundImage(
                source: .bundled(name: "themebg_cozy_sakura_cafe"),
                scalesToFill: true,
                verticalAnchor: 0.56,
                blurRadius: 0
            ),
            scrim: ThemeScrim(
                topColor: ThemeColor(hex: "#9A7FE0")!.withAlpha(0.30),
                bottomColor: ThemeColor(hex: "#B07FD0")!.withAlpha(0.26)
            )
        ),
        keyStyles: [
            .input: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#FBF7FF")!.withAlpha(0.95),
                    ThemeColor(hex: "#E9DDFB")!.withAlpha(0.95)
                ]),
                labelColor: ThemeColor(hex: "#34205C")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#DCCDF4")!.withAlpha(0.97),
                    ThemeColor(hex: "#CDBBEE")!.withAlpha(0.97)
                ]),
                border: ThemeBorder(color: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.70), width: 1),
                shadow: ThemeShadow(color: ThemeColor(hex: "#1B0E38")!, opacity: 0.30, radius: 3.5, offsetY: 2.0),
                topHighlight: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.60),
                cornerRadiusOverride: 15,
                glass: KeyGlass(
                    bevelColor: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.00),
                    bevelWidth: 0.0,
                    bevelFalloff: 0.5,
                    innerShadowColor: ThemeColor(hex: "#FFFFFF")!,
                    innerShadowOpacity: 0.40,
                    innerShadowRadius: 3.5
                )
            ),
            .system: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#E6D8FA")!.withAlpha(0.95),
                    ThemeColor(hex: "#D3C0F3")!.withAlpha(0.95)
                ]),
                labelColor: ThemeColor(hex: "#34205C")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#C8B3EC")!.withAlpha(0.97),
                    ThemeColor(hex: "#B9A2E4")!.withAlpha(0.97)
                ]),
                border: ThemeBorder(color: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.62), width: 1),
                shadow: ThemeShadow(color: ThemeColor(hex: "#1B0E38")!, opacity: 0.30, radius: 3.5, offsetY: 2.0),
                topHighlight: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.55),
                cornerRadiusOverride: 15,
                glass: KeyGlass(
                    bevelColor: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.00),
                    bevelWidth: 0.0,
                    bevelFalloff: 0.5,
                    innerShadowColor: ThemeColor(hex: "#FFFFFF")!,
                    innerShadowOpacity: 0.34,
                    innerShadowRadius: 3.5
                )
            ),
            .action: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#FCE0EE")!.withAlpha(0.96),
                    ThemeColor(hex: "#F4B9D6")!.withAlpha(0.96)
                ]),
                labelColor: ThemeColor(hex: "#4A1838")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#EEC2D8")!.withAlpha(0.98),
                    ThemeColor(hex: "#E3A2C2")!.withAlpha(0.98)
                ]),
                border: ThemeBorder(color: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.70), width: 1),
                shadow: ThemeShadow(color: ThemeColor(hex: "#2E0A22")!, opacity: 0.30, radius: 3.5, offsetY: 2.0),
                topHighlight: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.60),
                cornerRadiusOverride: 15,
                glass: KeyGlass(
                    bevelColor: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.00),
                    bevelWidth: 0.0,
                    bevelFalloff: 0.5,
                    innerShadowColor: ThemeColor(hex: "#FFFFFF")!,
                    innerShadowOpacity: 0.40,
                    innerShadowRadius: 3.5
                )
            ),
            .space: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#F4ECFF")!.withAlpha(0.45),
                    ThemeColor(hex: "#E2D3F8")!.withAlpha(0.45)
                ]),
                labelColor: ThemeColor(hex: "#000000")!.withAlpha(0.00),
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#3A2470")!.withAlpha(0.72),
                    ThemeColor(hex: "#3A2470")!.withAlpha(0.72)
                ]),
                border: ThemeBorder(color: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.80), width: 1),
                shadow: ThemeShadow(color: ThemeColor(hex: "#1B0E38")!, opacity: 0.28, radius: 3.5, offsetY: 2.0),
                topHighlight: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.35),
                cornerRadiusOverride: 16
            )
        ],
        typography: ThemeTypography(fontFamily: nil, weightRawValue: 0.3, sizeMultiplier: 1.0),
        chrome: ThemeChrome(
            inkColor: ThemeColor(hex: "#FFFFFF")!,
            mutedInkColor: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.60),
            panelFill: ThemeFill(ThemeColor(hex: "#241545")!.withAlpha(0.55)),
            highlightFill: ThemeFill(ThemeColor(hex: "#FFFFFF")!.withAlpha(0.18))
        ),
        keyArt: KeyArtSet(
            assetPrefix: "keyart_csc_",
            heightFraction: 0.54,
            bottomInsetFraction: 0.07,
            opacity: 0.98,
            fillKeys: ["space"],
            labelLiftFraction: 0.15
        ),
        effects: ThemeEffects(isEnabled: true, birthRate: 4.0, particleImageName: nil, tint: ThemeColor(hex: "#FFC6E0")!)
    )

    // MARK: - Fantasy Castle Night

    /// Starlit lake between two glowing castles. **Frosted glass**: pale lavender panes with a
    /// bright white rim and bevel glint, translucent enough that the violet sky reads through each cap —
    /// the treatment of the theme's showcase art. A light lavender lift keeps the plate vivid violet
    /// instead of near-black, so the glass sits *in* the night rather than on top of a void.
    /// `verticalAnchor 0.10` keeps the crescent moon (top-left of the plate) in frame.
    static let fantasyCastleNight = MochiKeyboardTheme(
        id: "mochi.fantasy-castle-night",
        name: "Fantasy Castle Night",
        authorName: "Mochi",
        appearance: .dark,
        surface: ThemeSurface(
            baseFill: ThemeFill(stops: [
                ThemeColor(hex: "#2A1FA8")!,
                ThemeColor(hex: "#5B3FD0")!,
                ThemeColor(hex: "#7A4CC8")!
            ]),
            backgroundImage: ThemeBackgroundImage(
                source: .bundled(name: "themebg_fantasy_castle_night"),
                scalesToFill: true,
                verticalAnchor: 0.1,
                blurRadius: 0
            ),
            scrim: ThemeScrim(
                topColor: ThemeColor(hex: "#8A7AF0")!.withAlpha(0.26),
                bottomColor: ThemeColor(hex: "#9A80F0")!.withAlpha(0.22)
            )
        ),
        keyStyles: [
            .input: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#F1EAFF")!.withAlpha(0.86),
                    ThemeColor(hex: "#C9BAFB")!.withAlpha(0.86)
                ]),
                labelColor: ThemeColor(hex: "#1C1452")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#DCCFFE")!.withAlpha(0.92),
                    ThemeColor(hex: "#B3A2F6")!.withAlpha(0.92)
                ]),
                border: ThemeBorder(color: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.72), width: 1),
                shadow: ThemeShadow(color: ThemeColor(hex: "#140A33")!, opacity: 0.34, radius: 3.5, offsetY: 2.0),
                topHighlight: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.50),
                cornerRadiusOverride: 13,
                glass: KeyGlass(
                    bevelColor: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.85),
                    bevelWidth: 1.2,
                    bevelFalloff: 0.5,
                    innerShadowColor: ThemeColor(hex: "#3A2A90")!,
                    innerShadowOpacity: 0.30,
                    innerShadowRadius: 3.0
                )
            ),
            .system: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#DCCFFD")!.withAlpha(0.86),
                    ThemeColor(hex: "#B2A2F4")!.withAlpha(0.86)
                ]),
                labelColor: ThemeColor(hex: "#1C1452")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#C7B8F8")!.withAlpha(0.92),
                    ThemeColor(hex: "#9E8CEE")!.withAlpha(0.92)
                ]),
                border: ThemeBorder(color: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.72), width: 1),
                shadow: ThemeShadow(color: ThemeColor(hex: "#140A33")!, opacity: 0.34, radius: 3.5, offsetY: 2.0),
                topHighlight: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.42),
                cornerRadiusOverride: 13,
                glass: KeyGlass(
                    bevelColor: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.85),
                    bevelWidth: 1.2,
                    bevelFalloff: 0.5,
                    innerShadowColor: ThemeColor(hex: "#3A2A90")!,
                    innerShadowOpacity: 0.30,
                    innerShadowRadius: 3.0
                )
            ),
            .action: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#F1EAFF")!.withAlpha(0.86),
                    ThemeColor(hex: "#C9BAFB")!.withAlpha(0.86)
                ]),
                labelColor: ThemeColor(hex: "#1C1452")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#DCCFFE")!.withAlpha(0.92),
                    ThemeColor(hex: "#B3A2F6")!.withAlpha(0.92)
                ]),
                border: ThemeBorder(color: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.72), width: 1),
                shadow: ThemeShadow(color: ThemeColor(hex: "#140A33")!, opacity: 0.34, radius: 3.5, offsetY: 2.0),
                topHighlight: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.50),
                cornerRadiusOverride: 13,
                glass: KeyGlass(
                    bevelColor: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.85),
                    bevelWidth: 1.2,
                    bevelFalloff: 0.5,
                    innerShadowColor: ThemeColor(hex: "#3A2A90")!,
                    innerShadowOpacity: 0.30,
                    innerShadowRadius: 3.0
                )
            ),
            .space: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#E4DAFF")!.withAlpha(0.42),
                    ThemeColor(hex: "#B9A8F8")!.withAlpha(0.42)
                ]),
                labelColor: ThemeColor(hex: "#000000")!.withAlpha(0.00),
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#3A2C90")!.withAlpha(0.72),
                    ThemeColor(hex: "#3A2C90")!.withAlpha(0.72)
                ]),
                border: ThemeBorder(color: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.80), width: 1),
                shadow: ThemeShadow(color: ThemeColor(hex: "#140A33")!, opacity: 0.30, radius: 3.5, offsetY: 2.0),
                topHighlight: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.35),
                cornerRadiusOverride: 14
            )
        ],
        typography: ThemeTypography(fontFamily: nil, weightRawValue: 0.34, sizeMultiplier: 1.0),
        chrome: ThemeChrome(
            inkColor: ThemeColor(hex: "#FFFFFF")!,
            mutedInkColor: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.60),
            panelFill: ThemeFill(ThemeColor(hex: "#1A1152")!.withAlpha(0.62)),
            highlightFill: ThemeFill(ThemeColor(hex: "#FFFFFF")!.withAlpha(0.18))
        ),
        keyArt: KeyArtSet(
            assetPrefix: "keyart_fcn_",
            heightFraction: 0.54,
            bottomInsetFraction: 0.07,
            opacity: 0.98,
            fillKeys: ["space"],
            labelLiftFraction: 0.15
        ),
        effects: ThemeEffects(isEnabled: true, birthRate: 5.0, particleImageName: nil, tint: ThemeColor(hex: "#E8DCFF")!)
    )

    // MARK: - Dreamy Castle

    /// Twilight lake below snow peaks, the sky banded violet-to-coral. **Soft frosted glass** in a
    /// warm rose-lilac, rounder than Fantasy Castle Night's panes, with a peach sunset accent on return.
    /// The plate is mid-dusk (mean L 0.17), so the scrim only warms and evens it — no darkening, which is
    /// what made the old caps read heavy.
    static let dreamyCastle = MochiKeyboardTheme(
        id: "mochi.dreamy-castle",
        name: "Dreamy Castle",
        authorName: "Mochi",
        appearance: .dark,
        surface: ThemeSurface(
            baseFill: ThemeFill(stops: [
                ThemeColor(hex: "#6E4E80")!,
                ThemeColor(hex: "#A06E90")!,
                ThemeColor(hex: "#5D3E63")!
            ]),
            backgroundImage: ThemeBackgroundImage(
                source: .bundled(name: "themebg_dreamy_castle"),
                scalesToFill: true,
                verticalAnchor: 0.3,
                blurRadius: 0
            ),
            scrim: ThemeScrim(
                topColor: ThemeColor(hex: "#F0B0C0")!.withAlpha(0.12),
                bottomColor: ThemeColor(hex: "#3A2040")!.withAlpha(0.10)
            )
        ),
        keyStyles: [
            .input: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#FFF4FA")!.withAlpha(0.88),
                    ThemeColor(hex: "#F0D8E8")!.withAlpha(0.88)
                ]),
                labelColor: ThemeColor(hex: "#3A1734")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#EBD2E2")!.withAlpha(0.94),
                    ThemeColor(hex: "#DDBDD2")!.withAlpha(0.94)
                ]),
                border: ThemeBorder(color: ThemeColor(hex: "#FFF4FA")!.withAlpha(0.72), width: 1),
                shadow: ThemeShadow(color: ThemeColor(hex: "#1E0E28")!, opacity: 0.32, radius: 3.5, offsetY: 2.0),
                topHighlight: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.55),
                cornerRadiusOverride: 15,
                glass: KeyGlass(
                    bevelColor: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.85),
                    bevelWidth: 1.2,
                    bevelFalloff: 0.5,
                    innerShadowColor: ThemeColor(hex: "#6A3A60")!,
                    innerShadowOpacity: 0.30,
                    innerShadowRadius: 3.0
                )
            ),
            .system: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#EDD6E6")!.withAlpha(0.88),
                    ThemeColor(hex: "#DCBCD2")!.withAlpha(0.88)
                ]),
                labelColor: ThemeColor(hex: "#3A1734")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#D8BDD0")!.withAlpha(0.94),
                    ThemeColor(hex: "#C8A6BE")!.withAlpha(0.94)
                ]),
                border: ThemeBorder(color: ThemeColor(hex: "#FFF4FA")!.withAlpha(0.72), width: 1),
                shadow: ThemeShadow(color: ThemeColor(hex: "#1E0E28")!, opacity: 0.32, radius: 3.5, offsetY: 2.0),
                topHighlight: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.48),
                cornerRadiusOverride: 15,
                glass: KeyGlass(
                    bevelColor: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.85),
                    bevelWidth: 1.2,
                    bevelFalloff: 0.5,
                    innerShadowColor: ThemeColor(hex: "#6A3A60")!,
                    innerShadowOpacity: 0.30,
                    innerShadowRadius: 3.0
                )
            ),
            .action: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#FFE2CC")!.withAlpha(0.94),
                    ThemeColor(hex: "#F7B893")!.withAlpha(0.94)
                ]),
                labelColor: ThemeColor(hex: "#4A1D14")!,
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#F2CDB2")!.withAlpha(0.98),
                    ThemeColor(hex: "#E9A27C")!.withAlpha(0.98)
                ]),
                border: ThemeBorder(color: ThemeColor(hex: "#FFF1E6")!.withAlpha(0.72), width: 1),
                shadow: ThemeShadow(color: ThemeColor(hex: "#2E0E12")!, opacity: 0.32, radius: 3.5, offsetY: 2.0),
                topHighlight: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.55),
                cornerRadiusOverride: 15,
                glass: KeyGlass(
                    bevelColor: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.85),
                    bevelWidth: 1.2,
                    bevelFalloff: 0.5,
                    innerShadowColor: ThemeColor(hex: "#8A4020")!,
                    innerShadowOpacity: 0.30,
                    innerShadowRadius: 3.0
                )
            ),
            .space: KeyStyle(
                fill: ThemeFill(stops: [
                    ThemeColor(hex: "#F8E6F0")!.withAlpha(0.45),
                    ThemeColor(hex: "#E8C8DC")!.withAlpha(0.45)
                ]),
                labelColor: ThemeColor(hex: "#000000")!.withAlpha(0.00),
                pressedFill: ThemeFill(stops: [
                    ThemeColor(hex: "#4A3550")!.withAlpha(0.72),
                    ThemeColor(hex: "#4A3550")!.withAlpha(0.72)
                ]),
                border: ThemeBorder(color: ThemeColor(hex: "#FFF4FA")!.withAlpha(0.80), width: 1),
                shadow: ThemeShadow(color: ThemeColor(hex: "#1E0E28")!, opacity: 0.28, radius: 3.5, offsetY: 2.0),
                topHighlight: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.35),
                cornerRadiusOverride: 16
            )
        ],
        typography: ThemeTypography(fontFamily: nil, weightRawValue: 0.3, sizeMultiplier: 1.0),
        chrome: ThemeChrome(
            inkColor: ThemeColor(hex: "#FFFFFF")!,
            mutedInkColor: ThemeColor(hex: "#FFFFFF")!.withAlpha(0.60),
            panelFill: ThemeFill(ThemeColor(hex: "#2A1638")!.withAlpha(0.55)),
            highlightFill: ThemeFill(ThemeColor(hex: "#FFFFFF")!.withAlpha(0.18))
        ),
        keyArt: KeyArtSet(
            assetPrefix: "keyart_dc_",
            heightFraction: 0.54,
            bottomInsetFraction: 0.07,
            opacity: 0.98,
            fillKeys: ["space"],
            labelLiftFraction: 0.15
        ),
        effects: .none
    )
}
