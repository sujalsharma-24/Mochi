package com.mochi.keyboard.designsystem

import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.DpSize
import androidx.compose.ui.unit.TextUnit
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp

/**
 * Ported from ios/MochiApp/Features/Themes/ThemesView.swift. iOS solves each figure as
 * `rawFigmaPx * k` then, for most vertical/type figures, `* S` (S = 1.22) to make up the gap
 * between the 16:9 Figma export and a ~19.5:9 device — see the iOS file for the full derivation.
 * Only the resulting point values are carried over here (iOS points == Compose dp, 1:1), not the
 * `k`/`S` formulas themselves.
 */
object ThemesMetrics {
    val margin: Dp = 14.83.dp
    val contentTop: Dp = (-6).dp

    // Header
    val headerTop: Dp = 13.90.dp
    val circleButton: Dp = 34.82.dp
    val badge: Dp = 17.41.dp
    val badgeRadius: Dp = 3.62.dp
    val badgeGlyph: Dp = 11.31.dp
    val badgeToTitle: Dp = 4.26.dp
    val titleToSubtitle: Dp = 2.dp
    val headerToPills: Dp = 16.68.dp

    // Category bar
    val pillBarHeight: Dp = 19.28.dp
    val pillHeight: Dp = 14.08.dp
    val pillBarInset: Dp = 7.41.dp
    val pillGap: Dp = 11.03.dp
    val pillIconGap: Dp = 3.dp
    val pillsToFilter: Dp = 6.67.dp

    // Filter row
    val filterHeight: Dp = 23.52.dp
    val filterWidth: Dp = 52.91.dp
    val slidersWidth: Dp = 30.07.dp
    val filterGap: Dp = 10.17.dp
    val filterToGrid: Dp = 6.67.dp
    val funnelGlyph = DpSize(8.82.dp, 8.14.dp)
    val slidersGlyph = DpSize(9.94.dp, 8.14.dp)
    val glyphStroke: Dp = 0.90.dp

    // Card grid
    val cardWidth: Dp = 118.62.dp
    val cardGap: Dp = 8.15.dp
    val cardRadius: Dp = 10.38.dp
    const val cardArtAspect: Float = 640f / 440f
    val cardBodyHeight: Dp = 45.23.dp
    val cardPad: Dp = 6.90.dp
    val download: Dp = 12.05.dp
    val downloadTrailing: Dp = 6.49.dp
    val downloadTop: Dp = 4.63.dp

    val bodyTopToTitle: Dp = 4.50.dp
    val titleToByline: Dp = 3.dp
    val bylineToButtons: Dp = 4.50.dp
    val cardButtonHeight: Dp = 11.31.dp
    val cardButtonGap: Dp = 17.79.dp
    val bodyBottom: Dp = 3.62.dp
    val heartToCount: Dp = 2.60.dp
    val heart = DpSize(6.33.dp, 5.65.dp)

    // Downloaded strip
    val gridToHeading: Dp = 64.49.dp
    val headingInset: Dp = 15.94.dp
    val headingToStrip: Dp = 4.18.dp
    val seeAllGap: Dp = 2.60.dp
    val downloadCard: Dp = 85.43.dp
    val downloadCardGap: Dp = 9.82.dp
    const val downloadArtAspect: Float = 461f / 308f
    val downloadBodyHeight: Dp = 21.25.dp
    val downloadRadius: Dp = 7.60.dp
    val downloadNamePad: Dp = 3.52.dp
    val ellipsisDisc: Dp = 12.97.dp
    val ellipsisTrailing: Dp = 5.56.dp
    val ellipsisTop: Dp = 5.93.dp

    val hairline: Dp = 0.5.dp
}

/** Ported from ThemesView.swift's private `Type` enum. Weight beside each field name is the
 * MochiFont function it must be paired with — this page is almost entirely Medium/Regular; only
 * the page title and strip heading are Bold. */
object ThemesType {
    val pageTitle: TextUnit = 17.79.sp     // title() / Bold
    val pageSubtitle: TextUnit = 8.11.sp   // caption() / Medium
    val pill: TextUnit = 6.63.sp           // body() / Regular
    val filter: TextUnit = 9.11.sp         // caption() / Medium
    val cardTitle: TextUnit = 8.19.sp      // caption() / Medium
    val cardByline: TextUnit = 6.73.sp     // caption() / Medium
    val likeCount: TextUnit = 5.40.sp      // caption() / Medium
    val previewButton: TextUnit = 6.64.sp  // body() / Regular
    val applyButton: TextUnit = 6.61.sp    // body() / Regular
    val sectionTitle: TextUnit = 10.75.sp  // title() / Bold
    val seeAll: TextUnit = 10.78.sp        // body() / Regular
    val downloadName: TextUnit = 6.75.sp   // caption() / Medium
}
