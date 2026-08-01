package com.mochi.keyboard.designsystem

import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp

/**
 * Ported from ios/MochiApp/DesignSystem/Theme.swift — keep both in sync until a shared token
 * source exists. Values are pixel-sampled off docs/figma (screen exports; see the iOS file for the
 * per-color sampling notes); this file carries only the resulting hex values plus a short pointer
 * to which frame each one came from.
 */
object MochiColor {
    val purple = Color(0xFF8B5CF6)
    val purpleDark = Color(0xFF7C3AED)
    val pink = Color(0xFFEC4999)
    val pinkLight = Color(0xFFF9B7DA)
    val lavender = Color(0xFFCEBFF9)

    /** Pure black — section headers, card titles/subtitles, pill labels all sample to (0,0,0) in figma/1.png; lighter-reading text is a lighter Inter weight, not a lighter color. */
    val textPrimary = Color.Black
    val textSecondary = Color(0xFF757080)

    /** Flat #AAAAAA — Community's search placeholder, "N Themes" byline and theme descriptions (figma/2.png). */
    val textMuted = Color(0xFFAAAAAA)

    /** #9750AB — the "by <creator>" byline under a Top Themes card; lighter/pinker than logoSolid. */
    val creatorLink = Color(0xFF9750AB)

    /** #F44336 — the filled like heart (Material Red 500, not the app's own pink). */
    val heart = Color(0xFFF44336)

    /** #8A4FA0 — the 1pt outline on Community's search field, filter pills and round download buttons. */
    val outline = Color(0xFF8A4FA0)

    /** Sampled directly from docs/figma/1.png — the "Mochi" wordmark is flat, not a gradient. */
    val logoSolid = Color(0xFF9C28B1)

    val cardBackground = Color.White
    val screenBackgroundFallback = Color(0xFFF9E7F6)

    val freeTag = Color(0xFF8CCA65)
    val premiumTag = Color(0xFFF9B33C)

    // Fonts page (figma/5.png)
    val freeChipText = Color(0xFF77A509)
    val freeChipBackground = Color(0xFFF4F6D2)
    val proChipText = Color(0xFFFD981B)
    val proChipBackground = Color(0xFFFDEDC6)

    /** #8A8585 — a warm grey; Community's textMuted is neutral #AAAAAA and reads cooler against Fonts' pink background. */
    val textGreyWarm = Color(0xFF8A8585)
    val badgePink = Color(0xFFF9D0ED)
    val backButtonStart = Color(0xFFE3ABF4)
    val backButtonEnd = Color(0xFFC979E0)

    // Themes page (figma/8.png)
    val downloadGlyph = Color(0xFFA92CC0)

    // Create Custom Theme (figma/4.png)
    val pickerHue = Color(0xFFBD16F7)

    // Profile (figma/3.png)
    val editProfileStroke = Color(0xFF621570)
    val editProfileInk = Color(0xFF9012A7)

    /** The RECENT grid, left-to-right then top-to-bottom off the six swatches. */
    val recentSwatches = listOf(
        Color(0xFFF1BFF3),
        Color(0xFFEC9FD4),
        Color(0xFFA1C9EA),
        Color(0xFFDDACD7),
        Color(0xFFF0C2D3),
        Color(0xFFB689D0)
    )
}

object MochiGradient {
    val background = Brush.linearGradient(
        colors = listOf(Color(0xFFFCD9EC), Color(0xFFE6C8F2), Color(0xFFCDBDF5))
    )

    val primaryButton = Brush.horizontalGradient(
        colors = listOf(MochiColor.pink, MochiColor.pink.copy(alpha = 0.85f), MochiColor.purple)
    )

    /** Home's action-card buttons and the selected FONTS/THEMES pill — starts orchid, warms to pink a third of the way across, ends periwinkle (figma/1.png). */
    val softButton = Brush.horizontalGradient(
        colorStops = arrayOf(
            0.0f to Color(0xFFCE76DB),
            0.32f to Color(0xFFE27FCC),
            1.0f to Color(0xFF8F7CE9)
        )
    )

    /** Fonts page accent ramp — the selected category pill, both Apply buttons, the "Aa" title chip and the selected tab icon (figma/5.png). A full step pinker at the start than softButton. */
    val fontsAccent = Brush.horizontalGradient(
        colorStops = arrayOf(
            0.0f to Color(0xFFDE79D3),
            0.28f to Color(0xFFE17FCE),
            1.0f to Color(0xFF877FE9)
        )
    )

    val logoText = Brush.horizontalGradient(
        colors = listOf(MochiColor.purpleDark, MochiColor.pink)
    )

    /** Themes page's Apply capsule and selected "All" pill — opens pink rather than softButton's orchid (figma/8.png). */
    val themeButton = Brush.horizontalGradient(
        colorStops = arrayOf(
            0.0f to Color(0xFFE580C9),
            0.30f to Color(0xFFE37FCC),
            0.55f to Color(0xFFD078DD),
            1.0f to Color(0xFF8F7BE9)
        )
    )

    /** The two Themes-page header discs (back + search) — both carry this ramp with a black glyph. */
    val themeCircleButton = Brush.horizontalGradient(
        colors = listOf(Color(0xFFE280CC), Color(0xFFBC79E3))
    )

    /** The rounded-square chip holding the palette mark left of the "Themes" title. */
    val themeBadge = Brush.linearGradient(
        colors = listOf(Color(0xFFDE79D8), Color(0xFFA17EE7))
    )

    /** Create Custom Theme's selected editor pill ("Fonts") — only 294px wide in figma/4.png, so it spans a shorter stretch of the family ramp than softButton. */
    val editorPill = Brush.horizontalGradient(
        colors = listOf(Color(0xFFE581C5), Color(0xFFB17BE3))
    )

    /** The four tag chips — a touch cooler at the closing end than editorPill. */
    val tagPill = Brush.horizontalGradient(
        colors = listOf(Color(0xFFE47ECB), Color(0xFFA07CE5))
    )

    /** Fill of the four key-shape previews — pale lavender at the cap, deepening to orchid at the foot. */
    val keyShapePreview = Brush.verticalGradient(
        colors = listOf(Color(0xFFECE2F7), Color(0xFFCEAAE8))
    )

    /** The rail under each saturation/value square. Figma stops the sweep at magenta rather than carrying it back to red, so this runs 11/12 of the hue wheel, not a full turn. */
    val hueSpectrum = Brush.horizontalGradient(
        colors = (0..11).map { i -> Color.hsv(hue = i * 30f, saturation = 1f, value = 1f) }
    )

    val premiumBanner = Brush.linearGradient(
        colors = listOf(Color(0xFF6A34C7), Color(0xFFAA47D0))
    )
}

object MochiRadius {
    val card = 20.dp
    val pill = 999.dp
    val sheet = 28.dp
}

object MochiSpacing {
    val xs = 4.dp
    val sm = 8.dp
    val md = 16.dp
    val lg = 24.dp
    val xl = 32.dp
}
