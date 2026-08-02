package com.mochi.keyboard.designsystem

import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.DpSize
import androidx.compose.ui.unit.TextUnit
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp

/**
 * Ported from ios/MochiApp/Features/Fonts/FontsView.swift. iOS solves each figure as
 * `rawFigmaPx * k` then, for most vertical/type figures, `* S` (S = 1.27) to close the gap between
 * the 16:9 Figma export and a ~19.5:9 device — the filter pills use a smaller `SPill` (1.13) and
 * the downloaded strip its own `SDownload` (1.10), both undershooting `S` so those rows still fit
 * their measured widths without truncating. Only the resulting point values are carried over here
 * (iOS points == Compose dp, 1:1), not the k/S/SPill/SDownload formulas themselves.
 */
object FontsMetrics {
    val margin: Dp = 14.32.dp
    val contentTop: Dp = (-8).dp
    val hairline: Dp = 0.5.dp

    // Header — 150px circles, a 60px "Aa" chip, then the title block centred on the page.
    val headerTop: Dp = 14.9.dp
    val circleButton: Dp = 35.43.dp
    val badge = DpSize(15.37.dp, 14.35.dp)
    val badgeRadius: Dp = 3.30.dp
    val badgeToTitle: Dp = 4.1.dp
    val titleToSubtitle: Dp = 1.0.dp
    val headerToPills: Dp = 10.0.dp

    // Filter pills — one white capsule bar holding seven pills; "Other" ends flush with the margin.
    val pillBarHeight: Dp = 23.62.dp
    val pillHeight: Dp = 13.21.dp
    val pillBarInset: Dp = 6.0.dp
    val pillGap: Dp = 9.0.dp
    val pillPad: Dp = 6.2.dp
    val pillIconGap: Dp = 2.4.dp
    val pillsToSort: Dp = 6.6.dp

    // Sort row — two capsules and one rounded-rect container, all the same height.
    val sortHeight: Dp = 23.62.dp
    val settings = DpSize(28.32.dp, 23.62.dp)
    val sortToGrid: Dp = 8.7.dp

    // Card grid — square cards at width scale; only the white body takes S.
    val cardWidth: Dp = 119.06.dp
    val cardGap: Dp = 8.0.dp
    val cardRadius: Dp = 8.6.dp
    const val cardArtAspect: Float = 640f / 442f
    val cardBodyHeight: Dp = 40.01.dp
    val cardPad: Dp = 8.2.dp
    val cardButtonHeight: Dp = 10.41.dp
    val cardButtonGap: Dp = 14.1.dp
    val heart: Dp = 18.92.dp
    val heartInset: Dp = 8.2.dp
    val heartTopInset: Dp = 6.5.dp
    val chipRadius: Dp = 3.18.dp
    val gridToPanel: Dp = 8.8.dp

    // Font preview panel
    val panelRadius: Dp = 9.3.dp
    val panelPad: Dp = 8.4.dp
    val fieldSize = DpSize(92.0.dp, 14.35.dp)
    val fieldRadius: Dp = 6.35.dp
    const val letterColumns: Int = 13
    val letterCellHeight: Dp = 18.92.dp
    val letterRowGap: Dp = 8.2.dp
    val letterCellRadius: Dp = 2.03.dp
    val headingToGrid: Dp = 4.5.dp
    val gridToSlider: Dp = 6.0.dp
    val sliderKnob: Dp = 5.84.dp
    val sliderTrack: Dp = 1.65.dp
    val panelToApply: Dp = 10.0.dp

    // Apply panel
    val applyPanelHeight: Dp = 44.83.dp
    val applyButton = DpSize(64.7.dp, 21.97.dp)
    val applyToDownloads: Dp = 10.6.dp

    // My downloaded fonts — five cards, width-bound; SDownload keeps names from wrapping twice.
    val downloadCard: Dp = 67.5.dp
    val downloadCardGap: Dp = 9.1.dp
    const val downloadArtAspect: Float = 363f / 232f
    val downloadBodyHeight: Dp = 23.37.dp
    val downloadRadius: Dp = 5.6.dp
    val headingToDownloads: Dp = 7.5.dp
}

/** Ported from FontsView.swift's private `Type` enum. Most of this page is Regular/Medium — only
 * four runs are Bold (the two "FONT PREVIEW" labels, the apply-panel heading, "MY DOWNLOADED
 * FONTS") plus the single leading letterforms inside the Minimal/Bold/Elegant pills. */
object FontsType {
    val pageTitle: TextUnit = 18.31.sp     // itemName() / Medium
    val pageSubtitle: TextUnit = 8.38.sp   // body() / Regular
    val badgeGlyph: TextUnit = 6.86.sp     // itemName() / Medium
    val pill: TextUnit = 7.46.sp           // body() / Regular; title()/Bold for the "Aa"/"B"/"E" marks
    val sort: TextUnit = 9.33.sp           // body() / Regular
    val cardTitle: TextUnit = 9.33.sp      // itemName() / Medium
    val cardSubtitle: TextUnit = 6.97.sp   // itemName() / Medium
    val chip: TextUnit = 6.97.sp           // itemName() / Medium
    val cardButton: TextUnit = 6.73.sp     // body() / Regular
    val panelHeading: TextUnit = 11.23.sp  // title() / Bold
    val placeholder: TextUnit = 8.15.sp    // body() / Regular
    val letter: TextUnit = 10.40.sp        // script() — Kaushan Script Regular
    val sliderLabel: TextUnit = 8.38.sp    // title() / Bold
    val percent: TextUnit = 9.09.sp        // body() / Regular
    val applyHeading: TextUnit = 11.23.sp  // title() / Bold
    val applySubtitle: TextUnit = 8.15.sp  // body() / Regular
    val applyButton: TextUnit = 8.89.sp    // itemName() / Medium
    val sectionTitle: TextUnit = 11.23.sp  // title() / Bold
    val seeAll: TextUnit = 10.99.sp        // body() / Regular
    val downloadName: TextUnit = 6.04.sp   // body() / Regular
    val downloadChip: TextUnit = 4.4.sp    // body() / Regular
}
