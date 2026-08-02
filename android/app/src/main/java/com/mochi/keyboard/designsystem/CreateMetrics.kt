package com.mochi.keyboard.designsystem

import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.TextUnit
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp

/**
 * Ported from ios/MochiApp/Features/Create/CreateThemeView.swift, against docs/figma/4.png. iOS
 * lays this one page out on an absolute canvas — three ragged columns overlap vertically in the
 * middle third, which no stack of HStacks/VStacks reproduces without inventing spacing the design
 * never had — using a single scale `k = screenWidth / 2161` applied to *everything* (positions,
 * sizes and type; unlike Fonts/Themes this frame needs no separate vertical lift). This port keeps
 * iOS's per-element sizes (each raw Figma px times k, k = 402/2161, matching the reference width
 * every other screen's Metrics file measures against) but reproduces the layout as ordinary
 * Compose Row/Column grouping rather than porting the x/y coordinates — same call as Profile's and
 * Themes' absolute-canvas sections, just applied at a larger structural scale here since the
 * column grouping (not just per-element spacing) is a first-order part of how this page reads.
 */
object CreateMetrics {
    /** Content margin (79px inset, contentWidth 2003px) and the same -6pt pull back into the safe
     * area Themes/Fonts use, since Figma's y=0 is the literal top of the screen. */
    val margin: Dp = 14.69.dp
    val contentTop: Dp = (-6).dp

    /** Every white panel's ring: measured at ~3px on the 2161px export, which floors out at 0.5pt
     * rather than the arithmetic ~0.56pt — carried over as the fixed value iOS's own `max` resolves. */
    val panelStroke: Dp = 0.56.dp

    // Header
    val circleButton: Dp = 28.46.dp
    val backArrowIcon: Dp = 14.51.dp
    val titleSize: TextUnit = 15.01.sp
    val subtitleSize: TextUnit = 7.44.sp

    // Live keyboard preview
    val keyboardPreviewAspect: Float = 2009f / 1083f
    val keyboardPreviewRadius: Dp = 11.16.dp

    // Editor tabs
    val tabBarHeight: Dp = 18.98.dp
    val tabPillHeight: Dp = 17.11.dp
    val tabTextSize: TextUnit = 9.49.sp

    // Background card
    val bgPanelRadius: Dp = 7.07.dp
    val bgTileWidth: Dp = 50.41.dp
    val bgTileHeight: Dp = 46.13.dp
    val bgTileGap: Dp = 8.74.dp
    val bgHeadingSize: TextUnit = 9.47.sp
    val sourceTileRadius: Dp = 5.58.dp
    val sourceCaptionSize: TextUnit = 7.44.sp
    val bgCheckBadge: Dp = 9.67.dp

    // Key shape
    val keyShapeChip: Dp = 33.11.dp
    val keyShapeChipRadius: Dp = 5.21.dp
    val keyShapeInner: Dp = 18.60.dp
    val keyShapeGap: Dp = 5.58.dp
    val keyShapeCheckBadge: Dp = 8.93.dp

    // Key/letter color pickers (shared shape, two sizes)
    val satRadius: Dp = 7.44.dp
    val knobStroke: Dp = 1.30.dp
    val knobDia: Dp = 10.42.dp
    val hueKnobDia: Dp = 9.67.dp
    val keySatSize = androidx.compose.ui.unit.DpSize(113.85.dp, 54.69.dp)
    val keyHueSize = androidx.compose.ui.unit.DpSize(113.48.dp, 6.51.dp)
    val letterSatSize = androidx.compose.ui.unit.DpSize(132.45.dp, 49.30.dp)
    val letterHueSize = androidx.compose.ui.unit.DpSize(131.71.dp, 6.88.dp)

    // Recent swatches
    val recentHeadingSize: TextUnit = 6.60.sp
    val swatchWidth: Dp = 22.14.dp
    val swatchHeight: Dp = 19.91.dp
    val swatchRadius: Dp = 4.09.dp
    val swatchColGap: Dp = 5.02.dp
    val swatchRowGap: Dp = 5.58.dp
    val eyedropperSize = androidx.compose.ui.unit.DpSize(26.42.dp, 16.74.dp)
    val eyedropperRadius: Dp = 4.47.dp
    val eyedropperIcon: Dp = 8.19.dp

    // Font style
    val fontChipWidth: Dp = 41.11.dp
    val fontChipHeight: Dp = 34.23.dp
    val fontChipRadius: Dp = 4.84.dp
    val fontChipGap: Dp = 5.5.dp
    val fontSpecimenW: Dp = 36.65.dp
    val fontCaptionSize: TextUnit = 5.12.sp
    val fontCheckBadge: Dp = 8.19.dp

    // Live preview toggle panel
    val livePanelRadius: Dp = 7.07.dp
    val liveEyeSize = androidx.compose.ui.unit.DpSize(12.09.dp, 8.19.dp)
    val liveHeadingSize: TextUnit = 9.47.sp
    val liveSubtitleSize: TextUnit = 6.72.sp
    val resetCapsule = androidx.compose.ui.unit.DpSize(52.83.dp, 17.11.dp)
    val resetIcon: Dp = 5.95.dp
    val resetTextSize: TextUnit = 6.88.sp
    val resetGap: Dp = 5.58.dp

    // Theme name + tags
    val nameFieldRadius: Dp = 10.42.dp
    val nameFieldHeight: Dp = 20.84.dp
    val namePlaceholderSize: TextUnit = 8.19.sp
    val namePencilIcon: Dp = 9.67.dp
    val tagPillHeight: Dp = 13.58.dp
    val tagTextSize: TextUnit = 6.98.sp
    val plusIcon: Dp = 8.74.dp
    val tagsHeadingSize: TextUnit = 9.47.sp
    /** Name field vs. tags panel width ratio (833:1117 in Figma) — used as Row weights. */
    val nameFieldWeight: Float = 833f
    val tagsFieldWeight: Float = 1117f

    // Save Draft / Publish Theme
    val actionBtnHeight: Dp = 34.60.dp
    val actionGutter: Dp = 9.30.dp
    val actionRadius: Dp = 7.07.dp
    val floppyStroke: Dp = 0.93.dp
    val floppySize = androidx.compose.ui.unit.DpSize(8.56.dp, 10.42.dp)
    val actionTitleSize: TextUnit = 10.23.sp
    val actionSubtitleSize: TextUnit = 8.74.sp
    val saveIconGap: Dp = 5.77.dp
    val publishIcon: Dp = 11.16.dp
    val publishIconGap: Dp = 6.14.dp
}
