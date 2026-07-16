package com.mochi.app.designsystem

import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp

/** Ported from ios/MochiApp/DesignSystem/Theme.swift — keep both in sync until a shared token source exists. */
object MochiColor {
    val purple = Color(0xFF8B5CF6)
    val purpleDark = Color(0xFF7C3AED)
    val pink = Color(0xFFEC4999)
    val pinkLight = Color(0xFFF9B6DA)
    val lavender = Color(0xFFCEBFF9)

    /** Sampled directly from docs/figma/1.png — the "Mochi" wordmark is flat, not a gradient. */
    val logoSolid = Color(0xFF9C28B1)

    val textPrimary = Color(0xFF251B3C)
    val textSecondary = Color(0xFF6B617F)

    val cardBackground = Color.White
    val screenBackgroundFallback = Color(0xFFF9E7F6)

    val freeTag = Color(0xFF8CCA65)
    val premiumTag = Color(0xFFF9B33C)
}

object MochiGradient {
    /** Sampled directly from docs/figma/1.png (top-left / mid / bottom-right) — pink to lavender to peach. */
    val background = Brush.linearGradient(
        colors = listOf(
            Color(0xFFF6A7F2),
            Color(0xFFD2CAFB),
            Color(0xFFFDD7D1)
        )
    )

    val primaryButton = Brush.horizontalGradient(
        colors = listOf(MochiColor.pink, MochiColor.purple)
    )

    /** Softer pink-to-purple for small pill buttons (e.g. Home's Create/Choose) — primaryButton's
     * saturated pink/purple reads as near-solid magenta at small sizes; this pastel-shifted pair
     * keeps the same hue direction but shows a visible, gentler gradient. */
    val softButton = Brush.horizontalGradient(
        colors = listOf(Color(0xFFF48FB1), Color(0xFFAB8CE8))
    )

    val logoText = Brush.horizontalGradient(
        colors = listOf(MochiColor.purpleDark, MochiColor.pink)
    )

    val premiumBanner = Brush.linearGradient(
        colors = listOf(
            Color(0xFF6A34C7),
            Color(0xFFAA47D0)
        )
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
