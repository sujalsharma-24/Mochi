package com.mochi.keyboard.designsystem

import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.DpSize
import androidx.compose.ui.unit.TextUnit
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp

/**
 * Ported from ios/MochiApp/Features/Community/CommunityView.swift against docs/figma/2.png.
 * Unlike Themes/Fonts, iOS's own constants here already have `k` (402/2169) baked into the literal
 * numbers — the header comment derives each one as `measured px * k` and writes the *result* as
 * the Swift constant — so `S` (1.22) is the only further scaling this file needs to apply; widths
 * (card/tile/row sizes, which are already at the screen's limit) skip `S` entirely and are used as
 * literal points. Carried over 1:1 as dp/sp, matching every other screen's Metrics convention.
 */
object CommunityMetrics {
    val margin: Dp = 16.dp
    /** How far the two scrollable rows bleed back out of the page gutter so their last card/tile
     * isn't clipped short of the margin. */
    val rowBleed: Dp = 2.dp
    val contentTop: Dp = (-18).dp

    // Header
    val avatar: Dp = 48.8.dp
    val headerToSearch: Dp = 10.49.dp

    // Search field
    val searchHeight: Dp = 34.16.dp
    val searchRadius: Dp = 8.54.dp
    val searchInset: Dp = 14.6.dp
    val hairline: Dp = 0.45.dp
    val searchIcon: Dp = 17.45.dp
    val searchToPills: Dp = 10.98.dp

    // Filter pills — five equal flexible columns filling the content width exactly.
    val pillHeight: Dp = 29.28.dp
    val pillGap: Dp = 10.dp
    val pillRadius: Dp = 9.15.dp
    val pillsToHeading: Dp = 9.76.dp

    // Section headings
    val headingToContent: Dp = 10.19.dp
    val headingToTopThemes: Dp = 15.49.dp
    val contentToHeading: Dp = 11.59.dp

    // Top Themes
    val themeCard: Dp = 118.dp
    val themeCardGap: Dp = 9.dp
    val themeArtHeight: Dp = 91.dp
    val themeBodyHeight: Dp = 50.02.dp
    val cardRadius: Dp = 12.dp
    val rankBadge: Dp = 15.7.dp
    val downloadButton: Dp = 16.7.dp

    // Popular Creators — the one row where S also scales width (see class doc).
    val creatorCard = DpSize(105.77.dp, 67.83.dp)
    val creatorCardGap: Dp = 9.dp
    val creatorAvatar: Dp = 32.57.dp
    val creatorInset: Dp = 9.52.dp
    val creatorTrailing: Dp = 3.90.dp
    val creatorAvatarGap: Dp = 4.88.dp
    val followSize = DpSize(54.78.dp, 18.54.dp)

    // Latest Creations
    val latestCardHeight: Dp = 83.04.dp
    val latestCardGap: Dp = 4.88.dp
    val latestThumb = DpSize(148.02.dp, 69.74.dp)
    val latestThumbRadius: Dp = 7.84.dp
    val latestThumbGap: Dp = 8.93.dp
    val latestDownload: Dp = 15.dp
    val tagHeight: Dp = 12.2.dp
    val tagGap: Dp = 4.dp
    val verifiedBadge: Dp = 7.44.dp
    /** Deliberately trimmed rather than reproduced — see class doc on `latestTrailing` in the iOS
     * source: the 24pt of bare white after "..." a 16:9 frame can afford but the enlarged type here can't. */
    val latestTrailing: Dp = 8.dp
}

/** Ported from CommunityView.swift's private `Type` enum. Weight was settled by template-matching
 * each glyph run against the four bundled Inter weights, not assumed — several runs (Latest
 * Creations title/byline, creator-tile name, selected pill) land on Medium rather than SemiBold. */
object CommunityType {
    val logo: TextUnit = 51.24.sp          // logo() — Fredoka
    val searchPlaceholder: TextUnit = 10.65.sp  // caption() / Medium
    val pillSelected: TextUnit = 12.66.sp  // itemName() / Medium
    val pillIdle: TextUnit = 11.22.sp      // body() / Regular
    val sectionTitle: TextUnit = 10.61.sp  // title() / Bold
    val seeAll: TextUnit = 10.00.sp        // body() / Regular
    val themeName: TextUnit = 9.04.sp      // body() / Regular
    val themeByline: TextUnit = 6.67.sp    // itemName() / Medium
    val themeLikes: TextUnit = 5.45.sp     // body() / Regular
    val creatorName: TextUnit = 6.71.sp    // itemName() / Medium
    val creatorThemes: TextUnit = 5.75.sp  // caption() / Medium
    val followLabel: TextUnit = 7.56.sp    // button() / SemiBold
    val latestTitle: TextUnit = 10.22.sp   // itemName() / Medium
    val latestByline: TextUnit = 7.94.sp   // itemName() / Medium
    val latestSummary: TextUnit = 6.36.sp  // body() / Regular
    val latestLikes: TextUnit = 6.06.sp    // itemName() / Medium
    val tag: TextUnit = 6.69.sp            // caption() / Medium
}
