package com.mochi.keyboard.designsystem

import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.TextUnit
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp

/**
 * Ported from `ios/MochiApp/Features/Wallpapers/WallpaperMetrics.swift` - every number here is the
 * exact figure that file carries (iOS points == Compose dp, same convention `ThemesMetrics.kt`
 * uses), scaled by the real viewport width against the 402dp baseline Figma was measured at, so the
 * fixed-width rail + content pane stays proportionally identical on narrower/wider phones instead of
 * cropping. At 402dp, [s] is 1 and every figure below is untouched.
 */
class WallpaperMetrics(widthDp: Float) {
    private val s: Float = ((if (widthDp > 0) widthDp else BASE_WIDTH) / BASE_WIDTH).coerceIn(0.82f, 1.30f)

    // Rail
    val railWidth: Dp get() = (128.73f * s).dp
    val railPadH: Dp get() = (14.3f * s).dp
    val railTop: Dp get() = (8f * s).dp
    val railGap: Dp get() = (18f * s).dp
    val railPillH: Dp get() = (23.2f * s).dp
    val railNavGap: Dp get() = (13.4f * s).dp
    val railThumb: Dp get() = (11.6f * s).dp
    val railNavDrop: Dp get() = (12f * s).dp
    val railRecentDrop: Dp get() = (14f * s).dp
    val railPremiumDrop: Dp get() = (12f * s).dp

    // Content pane
    val contentPadH: Dp get() = (11.2f * s).dp
    val contentTop: Dp get() = (6f * s).dp
    val sectionGap: Dp get() = (15f * s).dp

    // Search
    val searchHeight: Dp get() = (29.5f * s).dp
    val searchRadius: Dp get() = (11.2f * s).dp
    val searchPadH: Dp get() = (12f * s).dp

    // Featured banner
    val bannerAspect: Float get() = 2.257f
    val bannerRadius: Dp get() = (10.4f * s).dp
    val bannerPad: Dp get() = (11f * s).dp

    // Chips
    val chipW: Dp get() = (26.98f * s).dp
    val chipH: Dp get() = (29.8f * s).dp
    val chipGap: Dp get() = (9.86f * s).dp
    val chipRadius: Dp get() = (6f * s).dp
    val chipBorderWidth: Dp get() = 1.dp

    // Cards
    val cardW: Dp get() = (77.57f * s).dp
    val cardGutter: Dp get() = (7.81f * s).dp
    val cardArtAspect: Float get() = 1.109f
    val cardBodyH: Dp get() = (30.9f * s).dp
    val cardRadius: Dp get() = (9f * s).dp
    val cardPadH: Dp get() = (6f * s).dp
    val badgeInset: Dp get() = (5f * s).dp

    val goPremiumRadius: Dp get() = (9f * s).dp
    val hairline: Dp get() = 0.5.dp

    // Wallpaper-shaped grids
    val tileAspect: Float get() = 9f / 19.5f
    val popularColumns: Int get() = 3
    val popularRows: Int get() = 3
    val popularGutter: Dp get() = (7.81f * s).dp
    val popularCardArtAspect: Float get() = 0.94f
    val gridColumns: Int get() = 3
    val gridGutter: Dp get() = (7f * s).dp
    val gridRadius: Dp get() = (8f * s).dp

    // Type
    val railTitle: TextUnit get() = (18.3f * s).sp
    val railSubtitle: TextUnit get() = (7.8f * s).sp
    val railNav: TextUnit get() = (9.3f * s).sp
    val railSectionHeading: TextUnit get() = (8.5f * s).sp
    val railRecentName: TextUnit get() = (7.3f * s).sp
    val railButton: TextUnit get() = (7.6f * s).sp
    val goPremiumTitle: TextUnit get() = (9.3f * s).sp
    val goPremiumBody: TextUnit get() = (6.6f * s).sp
    val goPremiumButton: TextUnit get() = (7.6f * s).sp
    val search: TextUnit get() = (10.2f * s).sp
    val bannerTitle: TextUnit get() = (13.4f * s).sp
    val bannerDesc: TextUnit get() = (7.8f * s).sp
    val bannerMeta: TextUnit get() = (7.3f * s).sp
    val bannerButton: TextUnit get() = (8.3f * s).sp
    val chip: TextUnit get() = (5.0f * s).sp
    val sectionTitle: TextUnit get() = (11.0f * s).sp
    val seeAll: TextUnit get() = (10.2f * s).sp
    val cardName: TextUnit get() = (8.2f * s).sp
    val cardMeta: TextUnit get() = (6.8f * s).sp
    val badge: TextUnit get() = (6.1f * s).sp

    private companion object {
        const val BASE_WIDTH = 402f
    }
}
