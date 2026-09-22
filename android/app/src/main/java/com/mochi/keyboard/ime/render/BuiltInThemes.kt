package com.mochi.keyboard.ime.render

/**
 * The 3 hand-authored themes, ported token-for-token from iOS's `BuiltInThemes.swift` (Cozy Sakura
 * Café, Fantasy Castle Night, Dreamy Castle) — same colours, same key styles, same background art
 * and per-key illustrations (copied byte-for-byte from `ios/SharedAssets/KeyboardArt.xcassets`).
 * Batches 2-8 (iOS's other 137 generated themes) are a later slice.
 */
object BuiltInThemes {
    val default get() = cozySakuraCafe

    /** All 140 themes — the 3 hand-authored ones plus batches 2-8 (137 more, machine-ported from
     * iOS's `BuiltInThemes+BatchN.swift`), mirroring iOS's own `BuiltInThemes.all` exactly. */
    val all: List<MochiKeyboardTheme> by lazy {
        listOf(cozySakuraCafe, fantasyCastleNight, dreamyCastle) +
            BuiltInThemesBatch2.all + BuiltInThemesBatch3.all + BuiltInThemesBatch4.all +
            BuiltInThemesBatch5.all + BuiltInThemesBatch6.all + BuiltInThemesBatch7.all + BuiltInThemesBatch8.all
    }

    fun byId(id: String): MochiKeyboardTheme? = all.firstOrNull { it.id == id }

    // MARK: - Cozy Sakura Café

    val cozySakuraCafe: MochiKeyboardTheme by lazy {
        MochiKeyboardTheme(
            id = "mochi.cozy-sakura-cafe",
            name = "Cozy Sakura Café",
            authorName = "Mochi",
            appearance = ThemeAppearance.DARK,
            surface = ThemeSurface(
                baseFill = ThemeFill(
                    listOf(ThemeColor.hex("#3A2470"), ThemeColor.hex("#5A3A8E"), ThemeColor.hex("#7A4A96"))
                ),
                backgroundImage = ThemeBackgroundImage(
                    bundledName = "themebg_cozy_sakura_cafe",
                    scalesToFill = true,
                    verticalAnchor = 0.56
                ),
                scrim = ThemeScrim(
                    topColor = ThemeColor.hex("#9A7FE0").withAlpha(0.30),
                    bottomColor = ThemeColor.hex("#B07FD0").withAlpha(0.26)
                )
            ),
            keyStyles = mapOf(
                KeyRole.INPUT to KeyStyle(
                    fill = ThemeFill(listOf(ThemeColor.hex("#FBF7FF").withAlpha(0.95), ThemeColor.hex("#E9DDFB").withAlpha(0.95))),
                    labelColor = ThemeColor.hex("#34205C"),
                    pressedFill = ThemeFill(listOf(ThemeColor.hex("#DCCDF4").withAlpha(0.97), ThemeColor.hex("#CDBBEE").withAlpha(0.97))),
                    border = ThemeBorder(ThemeColor.hex("#FFFFFF").withAlpha(0.70), 1.0),
                    shadow = ThemeShadow(ThemeColor.hex("#1B0E38"), 0.30, 3.5, 2.0),
                    topHighlight = ThemeColor.hex("#FFFFFF").withAlpha(0.60),
                    cornerRadiusOverrideDp = 15.0,
                    glass = KeyGlass(
                        bevelColor = ThemeColor.hex("#FFFFFF").withAlpha(0.0),
                        bevelWidth = 0.0,
                        innerShadowColor = ThemeColor.hex("#FFFFFF"),
                        innerShadowOpacity = 0.40,
                        innerShadowRadius = 3.5
                    )
                ),
                KeyRole.SYSTEM to KeyStyle(
                    fill = ThemeFill(listOf(ThemeColor.hex("#E6D8FA").withAlpha(0.95), ThemeColor.hex("#D3C0F3").withAlpha(0.95))),
                    labelColor = ThemeColor.hex("#34205C"),
                    pressedFill = ThemeFill(listOf(ThemeColor.hex("#C8B3EC").withAlpha(0.97), ThemeColor.hex("#B9A2E4").withAlpha(0.97))),
                    border = ThemeBorder(ThemeColor.hex("#FFFFFF").withAlpha(0.62), 1.0),
                    shadow = ThemeShadow(ThemeColor.hex("#1B0E38"), 0.30, 3.5, 2.0),
                    topHighlight = ThemeColor.hex("#FFFFFF").withAlpha(0.55),
                    cornerRadiusOverrideDp = 15.0,
                    glass = KeyGlass(
                        bevelColor = ThemeColor.hex("#FFFFFF").withAlpha(0.0),
                        bevelWidth = 0.0,
                        innerShadowColor = ThemeColor.hex("#FFFFFF"),
                        innerShadowOpacity = 0.34,
                        innerShadowRadius = 3.5
                    )
                ),
                KeyRole.ACTION to KeyStyle(
                    fill = ThemeFill(listOf(ThemeColor.hex("#FCE0EE").withAlpha(0.96), ThemeColor.hex("#F4B9D6").withAlpha(0.96))),
                    labelColor = ThemeColor.hex("#4A1838"),
                    pressedFill = ThemeFill(listOf(ThemeColor.hex("#EEC2D8").withAlpha(0.98), ThemeColor.hex("#E3A2C2").withAlpha(0.98))),
                    border = ThemeBorder(ThemeColor.hex("#FFFFFF").withAlpha(0.70), 1.0),
                    shadow = ThemeShadow(ThemeColor.hex("#2E0A22"), 0.30, 3.5, 2.0),
                    topHighlight = ThemeColor.hex("#FFFFFF").withAlpha(0.60),
                    cornerRadiusOverrideDp = 15.0,
                    glass = KeyGlass(
                        bevelColor = ThemeColor.hex("#FFFFFF").withAlpha(0.0),
                        bevelWidth = 0.0,
                        innerShadowColor = ThemeColor.hex("#FFFFFF"),
                        innerShadowOpacity = 0.40,
                        innerShadowRadius = 3.5
                    )
                ),
                KeyRole.SPACE to KeyStyle(
                    fill = ThemeFill(listOf(ThemeColor.hex("#F4ECFF").withAlpha(0.45), ThemeColor.hex("#E2D3F8").withAlpha(0.45))),
                    labelColor = ThemeColor.hex("#000000").withAlpha(0.0),
                    pressedFill = ThemeFill(listOf(ThemeColor.hex("#3A2470").withAlpha(0.72), ThemeColor.hex("#3A2470").withAlpha(0.72))),
                    border = ThemeBorder(ThemeColor.hex("#FFFFFF").withAlpha(0.80), 1.0),
                    shadow = ThemeShadow(ThemeColor.hex("#1B0E38"), 0.28, 3.5, 2.0),
                    topHighlight = ThemeColor.hex("#FFFFFF").withAlpha(0.35),
                    cornerRadiusOverrideDp = 16.0
                )
            ),
            typography = ThemeTypography(sizeMultiplier = 1.0),
            chrome = ThemeChrome(
                inkColor = ThemeColor.hex("#FFFFFF"),
                mutedInkColor = ThemeColor.hex("#FFFFFF").withAlpha(0.60),
                panelFill = ThemeFill(ThemeColor.hex("#241545").withAlpha(0.55)),
                highlightFill = ThemeFill(ThemeColor.hex("#FFFFFF").withAlpha(0.18))
            ),
            keyArt = KeyArtSet(
                assetPrefix = "keyart_csc_",
                heightFraction = 0.54,
                bottomInsetFraction = 0.07,
                opacity = 0.98,
                labelLiftFraction = 0.15
            ),
            effects = ThemeEffects(isEnabled = true, birthRate = 4.0, tint = ThemeColor.hex("#FFC6E0"))
        )
    }

    // MARK: - Fantasy Castle Night

    val fantasyCastleNight: MochiKeyboardTheme by lazy {
        MochiKeyboardTheme(
            id = "mochi.fantasy-castle-night",
            name = "Fantasy Castle Night",
            authorName = "Mochi",
            appearance = ThemeAppearance.DARK,
            surface = ThemeSurface(
                baseFill = ThemeFill(
                    listOf(ThemeColor.hex("#2A1FA8"), ThemeColor.hex("#5B3FD0"), ThemeColor.hex("#7A4CC8"))
                ),
                backgroundImage = ThemeBackgroundImage(
                    bundledName = "themebg_fantasy_castle_night",
                    scalesToFill = true,
                    verticalAnchor = 0.1
                ),
                scrim = ThemeScrim(
                    topColor = ThemeColor.hex("#8A7AF0").withAlpha(0.26),
                    bottomColor = ThemeColor.hex("#9A80F0").withAlpha(0.22)
                )
            ),
            keyStyles = mapOf(
                KeyRole.INPUT to KeyStyle(
                    fill = ThemeFill(listOf(ThemeColor.hex("#F1EAFF").withAlpha(0.86), ThemeColor.hex("#C9BAFB").withAlpha(0.86))),
                    labelColor = ThemeColor.hex("#1C1452"),
                    pressedFill = ThemeFill(listOf(ThemeColor.hex("#DCCFFE").withAlpha(0.92), ThemeColor.hex("#B3A2F6").withAlpha(0.92))),
                    border = ThemeBorder(ThemeColor.hex("#FFFFFF").withAlpha(0.72), 1.0),
                    shadow = ThemeShadow(ThemeColor.hex("#140A33"), 0.34, 3.5, 2.0),
                    topHighlight = ThemeColor.hex("#FFFFFF").withAlpha(0.50),
                    cornerRadiusOverrideDp = 13.0,
                    glass = KeyGlass(
                        bevelColor = ThemeColor.hex("#FFFFFF").withAlpha(0.85),
                        bevelWidth = 1.2,
                        innerShadowColor = ThemeColor.hex("#3A2A90"),
                        innerShadowOpacity = 0.30,
                        innerShadowRadius = 3.0
                    )
                ),
                KeyRole.SYSTEM to KeyStyle(
                    fill = ThemeFill(listOf(ThemeColor.hex("#DCCFFD").withAlpha(0.86), ThemeColor.hex("#B2A2F4").withAlpha(0.86))),
                    labelColor = ThemeColor.hex("#1C1452"),
                    pressedFill = ThemeFill(listOf(ThemeColor.hex("#C7B8F8").withAlpha(0.92), ThemeColor.hex("#9E8CEE").withAlpha(0.92))),
                    border = ThemeBorder(ThemeColor.hex("#FFFFFF").withAlpha(0.72), 1.0),
                    shadow = ThemeShadow(ThemeColor.hex("#140A33"), 0.34, 3.5, 2.0),
                    topHighlight = ThemeColor.hex("#FFFFFF").withAlpha(0.42),
                    cornerRadiusOverrideDp = 13.0,
                    glass = KeyGlass(
                        bevelColor = ThemeColor.hex("#FFFFFF").withAlpha(0.85),
                        bevelWidth = 1.2,
                        innerShadowColor = ThemeColor.hex("#3A2A90"),
                        innerShadowOpacity = 0.30,
                        innerShadowRadius = 3.0
                    )
                ),
                KeyRole.ACTION to KeyStyle(
                    fill = ThemeFill(listOf(ThemeColor.hex("#F1EAFF").withAlpha(0.86), ThemeColor.hex("#C9BAFB").withAlpha(0.86))),
                    labelColor = ThemeColor.hex("#1C1452"),
                    pressedFill = ThemeFill(listOf(ThemeColor.hex("#DCCFFE").withAlpha(0.92), ThemeColor.hex("#B3A2F6").withAlpha(0.92))),
                    border = ThemeBorder(ThemeColor.hex("#FFFFFF").withAlpha(0.72), 1.0),
                    shadow = ThemeShadow(ThemeColor.hex("#140A33"), 0.34, 3.5, 2.0),
                    topHighlight = ThemeColor.hex("#FFFFFF").withAlpha(0.50),
                    cornerRadiusOverrideDp = 13.0,
                    glass = KeyGlass(
                        bevelColor = ThemeColor.hex("#FFFFFF").withAlpha(0.85),
                        bevelWidth = 1.2,
                        innerShadowColor = ThemeColor.hex("#3A2A90"),
                        innerShadowOpacity = 0.30,
                        innerShadowRadius = 3.0
                    )
                ),
                KeyRole.SPACE to KeyStyle(
                    fill = ThemeFill(listOf(ThemeColor.hex("#E4DAFF").withAlpha(0.42), ThemeColor.hex("#B9A8F8").withAlpha(0.42))),
                    labelColor = ThemeColor.hex("#000000").withAlpha(0.0),
                    pressedFill = ThemeFill(listOf(ThemeColor.hex("#3A2C90").withAlpha(0.72), ThemeColor.hex("#3A2C90").withAlpha(0.72))),
                    border = ThemeBorder(ThemeColor.hex("#FFFFFF").withAlpha(0.80), 1.0),
                    shadow = ThemeShadow(ThemeColor.hex("#140A33"), 0.30, 3.5, 2.0),
                    topHighlight = ThemeColor.hex("#FFFFFF").withAlpha(0.35),
                    cornerRadiusOverrideDp = 14.0
                )
            ),
            typography = ThemeTypography(sizeMultiplier = 1.0),
            chrome = ThemeChrome(
                inkColor = ThemeColor.hex("#FFFFFF"),
                mutedInkColor = ThemeColor.hex("#FFFFFF").withAlpha(0.60),
                panelFill = ThemeFill(ThemeColor.hex("#1A1152").withAlpha(0.62)),
                highlightFill = ThemeFill(ThemeColor.hex("#FFFFFF").withAlpha(0.18))
            ),
            keyArt = KeyArtSet(
                assetPrefix = "keyart_fcn_",
                heightFraction = 0.54,
                bottomInsetFraction = 0.07,
                opacity = 0.98,
                labelLiftFraction = 0.15
            ),
            effects = ThemeEffects(isEnabled = true, birthRate = 5.0, tint = ThemeColor.hex("#E8DCFF"))
        )
    }

    // MARK: - Dreamy Castle

    val dreamyCastle: MochiKeyboardTheme by lazy {
        MochiKeyboardTheme(
            id = "mochi.dreamy-castle",
            name = "Dreamy Castle",
            authorName = "Mochi",
            appearance = ThemeAppearance.DARK,
            surface = ThemeSurface(
                baseFill = ThemeFill(
                    listOf(ThemeColor.hex("#6E4E80"), ThemeColor.hex("#A06E90"), ThemeColor.hex("#5D3E63"))
                ),
                backgroundImage = ThemeBackgroundImage(
                    bundledName = "themebg_dreamy_castle",
                    scalesToFill = true,
                    verticalAnchor = 0.3
                ),
                scrim = ThemeScrim(
                    topColor = ThemeColor.hex("#F0B0C0").withAlpha(0.12),
                    bottomColor = ThemeColor.hex("#3A2040").withAlpha(0.10)
                )
            ),
            keyStyles = mapOf(
                KeyRole.INPUT to KeyStyle(
                    fill = ThemeFill(listOf(ThemeColor.hex("#FFF4FA").withAlpha(0.88), ThemeColor.hex("#F0D8E8").withAlpha(0.88))),
                    labelColor = ThemeColor.hex("#3A1734"),
                    pressedFill = ThemeFill(listOf(ThemeColor.hex("#EBD2E2").withAlpha(0.94), ThemeColor.hex("#DDBDD2").withAlpha(0.94))),
                    border = ThemeBorder(ThemeColor.hex("#FFF4FA").withAlpha(0.72), 1.0),
                    shadow = ThemeShadow(ThemeColor.hex("#1E0E28"), 0.32, 3.5, 2.0),
                    topHighlight = ThemeColor.hex("#FFFFFF").withAlpha(0.55),
                    cornerRadiusOverrideDp = 15.0,
                    glass = KeyGlass(
                        bevelColor = ThemeColor.hex("#FFFFFF").withAlpha(0.85),
                        bevelWidth = 1.2,
                        innerShadowColor = ThemeColor.hex("#6A3A60"),
                        innerShadowOpacity = 0.30,
                        innerShadowRadius = 3.0
                    )
                ),
                KeyRole.SYSTEM to KeyStyle(
                    fill = ThemeFill(listOf(ThemeColor.hex("#EDD6E6").withAlpha(0.88), ThemeColor.hex("#DCBCD2").withAlpha(0.88))),
                    labelColor = ThemeColor.hex("#3A1734"),
                    pressedFill = ThemeFill(listOf(ThemeColor.hex("#D8BDD0").withAlpha(0.94), ThemeColor.hex("#C8A6BE").withAlpha(0.94))),
                    border = ThemeBorder(ThemeColor.hex("#FFF4FA").withAlpha(0.72), 1.0),
                    shadow = ThemeShadow(ThemeColor.hex("#1E0E28"), 0.32, 3.5, 2.0),
                    topHighlight = ThemeColor.hex("#FFFFFF").withAlpha(0.48),
                    cornerRadiusOverrideDp = 15.0,
                    glass = KeyGlass(
                        bevelColor = ThemeColor.hex("#FFFFFF").withAlpha(0.85),
                        bevelWidth = 1.2,
                        innerShadowColor = ThemeColor.hex("#6A3A60"),
                        innerShadowOpacity = 0.30,
                        innerShadowRadius = 3.0
                    )
                ),
                KeyRole.ACTION to KeyStyle(
                    fill = ThemeFill(listOf(ThemeColor.hex("#FFE2CC").withAlpha(0.94), ThemeColor.hex("#F7B893").withAlpha(0.94))),
                    labelColor = ThemeColor.hex("#4A1D14"),
                    pressedFill = ThemeFill(listOf(ThemeColor.hex("#F2CDB2").withAlpha(0.98), ThemeColor.hex("#E9A27C").withAlpha(0.98))),
                    border = ThemeBorder(ThemeColor.hex("#FFF1E6").withAlpha(0.72), 1.0),
                    shadow = ThemeShadow(ThemeColor.hex("#2E0E12"), 0.32, 3.5, 2.0),
                    topHighlight = ThemeColor.hex("#FFFFFF").withAlpha(0.55),
                    cornerRadiusOverrideDp = 15.0,
                    glass = KeyGlass(
                        bevelColor = ThemeColor.hex("#FFFFFF").withAlpha(0.85),
                        bevelWidth = 1.2,
                        innerShadowColor = ThemeColor.hex("#8A4020"),
                        innerShadowOpacity = 0.30,
                        innerShadowRadius = 3.0
                    )
                ),
                KeyRole.SPACE to KeyStyle(
                    fill = ThemeFill(listOf(ThemeColor.hex("#F8E6F0").withAlpha(0.45), ThemeColor.hex("#E8C8DC").withAlpha(0.45))),
                    labelColor = ThemeColor.hex("#000000").withAlpha(0.0),
                    pressedFill = ThemeFill(listOf(ThemeColor.hex("#4A3550").withAlpha(0.72), ThemeColor.hex("#4A3550").withAlpha(0.72))),
                    border = ThemeBorder(ThemeColor.hex("#FFF4FA").withAlpha(0.80), 1.0),
                    shadow = ThemeShadow(ThemeColor.hex("#1E0E28"), 0.28, 3.5, 2.0),
                    topHighlight = ThemeColor.hex("#FFFFFF").withAlpha(0.35),
                    cornerRadiusOverrideDp = 16.0
                )
            ),
            typography = ThemeTypography(sizeMultiplier = 1.0),
            chrome = ThemeChrome(
                inkColor = ThemeColor.hex("#FFFFFF"),
                mutedInkColor = ThemeColor.hex("#FFFFFF").withAlpha(0.60),
                panelFill = ThemeFill(ThemeColor.hex("#2A1638").withAlpha(0.55)),
                highlightFill = ThemeFill(ThemeColor.hex("#FFFFFF").withAlpha(0.18))
            ),
            keyArt = KeyArtSet(
                assetPrefix = "keyart_dc_",
                heightFraction = 0.54,
                bottomInsetFraction = 0.07,
                opacity = 0.98,
                labelLiftFraction = 0.15
            ),
            effects = ThemeEffects.NONE
        )
    }
}
