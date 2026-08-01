package com.mochi.keyboard.designsystem

import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.TextUnit
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp

/**
 * Ported from ios/MochiApp/DesignSystem/HomeMetrics.swift. iOS points and Compose dp are both
 * density-independent design units, so every figure below is carried over 1:1 rather than
 * re-derived — see the iOS file for which raw Figma px each one traces back to and why.
 */
data class ActionCardTuning(
    val hPad: Dp,
    val vPad: Dp,
    val iconSize: Dp,
    val iconHOffset: Dp,
    val iconVOffset: Dp,
    val iconTextGap: Dp,
    val titleSize: TextUnit,
    val titleVOffset: Dp,
    val titleGap: Dp,
    val subtitleSize: TextUnit,
    val subtitleVOffset: Dp,
    val textColumnExtra: Dp,
    val textVOffset: Dp,
    val buttonWidth: Dp,
    val buttonHeight: Dp,
    val buttonTextSize: TextUnit,
    val buttonVOffset: Dp
) {
    companion object {
        val customCreate = ActionCardTuning(
            hPad = 19.dp,
            vPad = 9.5.dp,
            iconSize = 52.dp,
            iconHOffset = 0.dp,
            iconVOffset = 2.5.dp,
            iconTextGap = 17.5.dp,
            titleSize = 9.5.sp,
            titleVOffset = (-9).dp,
            titleGap = 2.dp,
            subtitleSize = 8.5.sp,
            subtitleVOffset = (-6.5).dp,
            textColumnExtra = 0.dp,
            textVOffset = 0.dp,
            buttonWidth = 68.dp,
            buttonHeight = 22.dp,
            buttonTextSize = 10.sp,
            buttonVOffset = 0.dp
        )

        val chooseLibrary = ActionCardTuning(
            hPad = 24.5.dp,
            vPad = 8.5.dp,
            iconSize = 52.dp,
            iconHOffset = 0.dp,
            iconVOffset = 0.5.dp,
            iconTextGap = 12.5.dp,
            titleSize = 9.5.sp,
            titleVOffset = (-5.5).dp,
            titleGap = 2.dp,
            subtitleSize = 8.5.sp,
            subtitleVOffset = 0.dp,
            textColumnExtra = 0.dp,
            textVOffset = 0.dp,
            buttonWidth = 68.dp,
            buttonHeight = 22.dp,
            buttonTextSize = 10.sp,
            buttonVOffset = 0.dp
        )
    }
}

object HomeMetrics {
    // Header
    val headerTopPadding: Dp = (-6).dp
    val logoSize: TextUnit = 44.5.sp
    val createCustomIcon: Dp = 33.dp
    val createCustomLabel: TextUnit = 9.5.sp
    val gapHeaderCarousel: Dp = 18.dp

    // Top "recently applied" carousel
    val carouselGap: Dp = 7.dp
    const val carouselArtRatio: Float = 1.28f
    val carouselNameGap: Dp = 8.dp
    val themeNameSize: TextUnit = 10.5.sp
    val carouselArtRadius: Dp = 9.dp
    val carouselNameReserve: Dp = 14.dp
    val gapCarouselCards: Dp = 22.dp

    // Action cards — shared box; per-card values live in ActionCardTuning
    const val actionCardRatio: Float = 1.73f
    val actionCardGap: Dp = 10.5.dp
    val actionCardRadius: Dp = 13.dp
    val gapCardsPills: Dp = 21.dp

    // FONTS / THEMES toggle
    val pillHeight: Dp = 27.dp
    val pillLabelSize: TextUnit = 15.5.sp
    val pillExtraInset: Dp = 6.dp
    val pillGap: Dp = 11.dp
    val gapPillsSection: Dp = 24.dp

    // Section headers
    val sectionHeaderSize: TextUnit = 10.5.sp
    val seeAllSize: TextUnit = 10.sp
    val sectionHeaderGap: Dp = 10.dp

    // Popular Themes row
    val popularCardWidth: Dp = 158.dp
    val popularCardGap: Dp = 9.dp
    val popularArtRadius: Dp = 13.dp
    val gapThemesFonts: Dp = 22.dp

    // Font Collection row
    val fontCardWidth: Dp = 104.dp
    const val fontCardRatio: Float = 487f / 401f
    val fontCardGap: Dp = 9.dp
    val fontCardRadius: Dp = 10.dp
    val bottomGap: Dp = 41.dp

    // Tab bar
    val tabIconSize: Dp = 18.dp
    val tabKeyboardWidth: Dp = 23.dp
    val tabLabelSize: TextUnit = 9.sp
    val tabCreateSize: Dp = 50.dp
}
