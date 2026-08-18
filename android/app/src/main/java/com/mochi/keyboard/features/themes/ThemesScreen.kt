package com.mochi.keyboard.features.themes

import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.horizontalScroll
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.WindowInsets
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.offset
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.statusBars
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.layout.windowInsetsPadding
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material.icons.automirrored.filled.KeyboardArrowRight
import androidx.compose.material.icons.filled.Favorite
import androidx.compose.material.icons.filled.GridView
import androidx.compose.material.icons.filled.MoreHoriz
import androidx.compose.material.icons.filled.Search
import androidx.compose.material.icons.filled.Wallpaper
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.StrokeJoin
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.platform.LocalDensity
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import androidx.lifecycle.viewmodel.compose.viewModel
import com.mochi.keyboard.R
import com.mochi.keyboard.components.DownloadGlyph
import com.mochi.keyboard.components.FunnelGlyph
import com.mochi.keyboard.components.PencilGlyph
import com.mochi.keyboard.components.SlidersGlyph
import com.mochi.keyboard.components.SparkleField
import com.mochi.keyboard.components.TripleDot
import com.mochi.keyboard.data.rememberMochiViewModelFactory
import com.mochi.keyboard.designsystem.MochiColor
import com.mochi.keyboard.designsystem.MochiFont
import com.mochi.keyboard.designsystem.MochiGradient
import com.mochi.keyboard.designsystem.ThemesMetrics
import com.mochi.keyboard.designsystem.ThemesType
import com.mochi.keyboard.mockdata.MockData
import com.mochi.keyboard.model.KeyboardTheme

@Preview(showBackground = true, widthDp = 393, heightDp = 2400)
@Composable
private fun ThemesScreenPreview() {
    ThemesScreenContent(themes = MockData.shopThemes)
}

/** The seven categories the Fonts frame also uses, with the same marks. Widths/icon widths are
 * measured off the export rather than derived from content, per ThemesView.swift's own Category
 * enum — letting labels size the pills pushed "Other" off-screen there, so the exact figures are
 * carried over 1:1 (iOS points == Compose dp). */
private enum class ThemeCategory(val label: String, val width: Dp, val iconWidth: Dp) {
    ALL("All", 36.14.dp, 6.12.dp),
    CUTE("Cute", 37.99.dp, 9.82.dp),
    HANDWRITTEN("Handwritten", 60.61.dp, 6.86.dp),
    MINIMAL("Minimal", 45.41.dp, 7.97.dp),
    BOLD("Bold", 33.55.dp, 3.89.dp),
    ELEGANT("Elegant", 43.55.dp, 3.52.dp),
    OTHER("Other", 33.18.dp, 5.75.dp)
}

/** Same real-art catalog names as ThemeArt's, but drawn flat/clipped instead of with that
 * component's purple-tinted card shadow — ThemesView.swift applies no shadow anywhere on this
 * page, unlike Home's theme rows. Mirrors ProfileScreen's profileArt precedent for the same
 * reason. */
private val themesArt: Map<String, Int> = mapOf(
    "theme_fantasy_castle_night" to R.drawable.theme_fantasy_castle_night,
    "theme_space_vibe" to R.drawable.theme_space_vibe,
    "theme_dreamy_castle" to R.drawable.theme_dreamy_castle,
    "theme_pastel_pink_sky" to R.drawable.theme_pastel_pink_sky,
    "theme_forest" to R.drawable.theme_forest,
    "theme_cozy_sakura_cafe" to R.drawable.theme_cozy_sakura_cafe,
    "theme_pastel_rainbow" to R.drawable.theme_pastel_rainbow,
    "theme_sakura_train" to R.drawable.theme_sakura_train,
    "theme_kawaii_boba" to R.drawable.theme_kawaii_boba
)

@Composable
private fun ThemesArtImage(assetName: String, modifier: Modifier = Modifier) {
    val resId = themesArt[assetName] ?: return
    Image(painter = painterResource(resId), contentDescription = null, contentScale = ContentScale.Crop, modifier = modifier)
}

/** Ported from ios/MochiApp/Features/Themes/ThemesView.swift against docs/figma/8.png. Geometry
 * lives in ThemesMetrics/ThemesType (designsystem/ThemesMetrics.kt), not here. iOS wires no
 * interaction at all on this page beyond the category-pill selection state — Preview/Apply and
 * the card tap are plain styled Text, not Button — so none is added here either. */
@Composable
fun ThemesScreen(
    modifier: Modifier = Modifier,
    onSearchClick: () -> Unit = {},
    onWallpapersClick: () -> Unit = {},
    onThemeClick: (KeyboardTheme) -> Unit = {},
    viewModel: ThemesViewModel = viewModel(factory = rememberMochiViewModelFactory())
) {
    val uiState by viewModel.uiState.collectAsStateWithLifecycle()
    // Real Firestore data only replaces the grid once it's actually loaded - Loading/Empty/Error
    // fall back to MockData rather than showing a blank/broken grid, same pattern as HomeScreen.
    val themes = (uiState as? ThemesUiState.Data)?.themes ?: MockData.shopThemes
    ThemesScreenContent(modifier, themes, onSearchClick, onWallpapersClick, onThemeClick)
}

/** Split from ThemesScreen so @Preview can render this directly with MockData, without going
 * through rememberMochiViewModelFactory() - that factory casts LocalContext's application to
 * MochiApplication, which Preview's fake context isn't, and would crash the preview. Same pattern
 * as HomeScreen/HomeScreenContent. */
@Composable
private fun ThemesScreenContent(
    modifier: Modifier = Modifier,
    themes: List<KeyboardTheme> = MockData.shopThemes,
    onSearchClick: () -> Unit = {},
    onWallpapersClick: () -> Unit = {},
    onThemeClick: (KeyboardTheme) -> Unit = {}
) {
    var category by remember { mutableStateOf(ThemeCategory.ALL) }

    Box(modifier = modifier.fillMaxSize()) {
        Image(
            painter = painterResource(R.drawable.themes_background),
            contentDescription = null,
            contentScale = ContentScale.Crop,
            modifier = Modifier.fillMaxSize()
        )
        SparkleField(modifier = Modifier.fillMaxSize())

        Column(
            modifier = Modifier
                .fillMaxSize()
                .verticalScroll(rememberScrollState())
                .windowInsetsPadding(WindowInsets.statusBars)
                .padding(horizontal = ThemesMetrics.margin)
                .padding(bottom = 100.dp)
                // Compose's padding() rejects negative values (unlike SwiftUI); offset() shifts
                // the whole column up the same way without that restriction.
                .offset(y = ThemesMetrics.contentTop)
        ) {
            Spacer(modifier = Modifier.height(ThemesMetrics.headerTop))
            ThemesHeader(onSearchClick, onWallpapersClick)

            Spacer(modifier = Modifier.height(ThemesMetrics.headerToPills))
            CategoryBar(selected = category, onSelect = { category = it })

            Spacer(modifier = Modifier.height(ThemesMetrics.pillsToFilter))
            FilterRow()

            Spacer(modifier = Modifier.height(ThemesMetrics.filterToGrid))
            CardGrid(themes, onThemeClick)

            Spacer(modifier = Modifier.height(ThemesMetrics.gridToHeading))
            DownloadedSection(MockData.downloadedThemes)
        }
    }
}

// region Header

@Composable
private fun ThemesHeader(onSearchClick: () -> Unit, onWallpapersClick: () -> Unit) {
    Box(modifier = Modifier.fillMaxWidth().height(ThemesMetrics.circleButton)) {
        Row(modifier = Modifier.fillMaxWidth(), verticalAlignment = Alignment.CenterVertically) {
            ThemesCircleButton(icon = Icons.AutoMirrored.Filled.ArrowBack)
            Spacer(modifier = Modifier.weight(1f))
            // No affordance for this exists in docs/figma/8.png (Figma is authoritative and shows
            // no Live Wallpapers entry point on this frame) - added per the feature spec's Screen 4
            // "Live Wallpapers section" placement, same "check the spec rather than guess" approach
            // Session 21 used for Leaderboard's identical dead-callback bug.
            ThemesCircleButton(icon = Icons.Filled.Wallpaper, onClick = onWallpapersClick)
            Spacer(modifier = Modifier.width(8.dp))
            ThemesCircleButton(icon = Icons.Filled.Search, onClick = onSearchClick)
        }

        Column(
            modifier = Modifier.align(Alignment.Center),
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.spacedBy(ThemesMetrics.titleToSubtitle)
        ) {
            Row(
                verticalAlignment = Alignment.CenterVertically,
                horizontalArrangement = Arrangement.spacedBy(ThemesMetrics.badgeToTitle)
            ) {
                Box(
                    modifier = Modifier
                        .size(ThemesMetrics.badge)
                        .clip(RoundedCornerShape(ThemesMetrics.badgeRadius))
                        .background(MochiGradient.themeBadge),
                    contentAlignment = Alignment.Center
                ) {
                    Icon(
                        painter = painterResource(R.drawable.icon_palette_outline),
                        contentDescription = null,
                        tint = MochiColor.textPrimary,
                        modifier = Modifier.size(ThemesMetrics.badgeGlyph)
                    )
                }
                Text(text = "Themes", style = MochiFont.title(ThemesType.pageTitle), color = MochiColor.logoSolid)
            }
            Text(
                text = "Browse and apply beautiful themes",
                style = MochiFont.caption(ThemesType.pageSubtitle),
                color = MochiColor.textGreyWarm
            )
        }
    }
}

/** Both header discs share this ramp under a black glyph — a matched pair, unlike Fonts' search
 * button which is a flat logoSolid disc with a white glyph. */
@Composable
private fun ThemesCircleButton(icon: androidx.compose.ui.graphics.vector.ImageVector, onClick: () -> Unit = {}) {
    Box(
        modifier = Modifier
            .size(ThemesMetrics.circleButton)
            .clip(CircleShape)
            .background(MochiGradient.themeCircleButton)
            .clickable(onClick = onClick),
        contentAlignment = Alignment.Center
    ) {
        Icon(
            imageVector = icon,
            contentDescription = null,
            tint = MochiColor.textPrimary,
            modifier = Modifier.size(ThemesMetrics.circleButton * 0.40f)
        )
    }
}

// endregion

// region Category bar

@Composable
private fun CategoryBar(selected: ThemeCategory, onSelect: (ThemeCategory) -> Unit) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .height(ThemesMetrics.pillBarHeight)
            .clip(CircleShape)
            .background(Color.White)
            .border(ThemesMetrics.hairline, MochiColor.logoSolid, CircleShape)
            .horizontalScroll(rememberScrollState())
            .padding(horizontal = ThemesMetrics.pillBarInset),
        verticalAlignment = Alignment.CenterVertically,
        horizontalArrangement = Arrangement.spacedBy(ThemesMetrics.pillGap)
    ) {
        ThemeCategory.entries.forEach { item ->
            CategoryPill(item = item, isSelected = item == selected, onSelect = { onSelect(item) })
        }
    }
}

@Composable
private fun CategoryPill(item: ThemeCategory, isSelected: Boolean, onSelect: () -> Unit) {
    Row(
        modifier = Modifier
            .width(item.width)
            .height(ThemesMetrics.pillHeight)
            .clip(CircleShape)
            .then(
                if (isSelected) Modifier.background(MochiGradient.themeButton)
                else Modifier.border(ThemesMetrics.hairline, MochiColor.logoSolid, CircleShape)
            )
            .clickable(onClick = onSelect),
        verticalAlignment = Alignment.CenterVertically,
        horizontalArrangement = Arrangement.spacedBy(ThemesMetrics.pillIconGap, Alignment.CenterHorizontally)
    ) {
        CategoryIcon(item)
        Text(text = item.label, style = MochiFont.body(ThemesType.pill), color = MochiColor.textPrimary, maxLines = 1)
    }
}

/** Figma gives each category a different kind of mark: three are set in type ("Aa", "B", "E"),
 * two are drawn Path glyphs, "All" is a system-style grid mark, and "Cute" is rendered artwork
 * (a purple bow) rather than a glyph. */
@Composable
private fun CategoryIcon(item: ThemeCategory) {
    val density = LocalDensity.current
    val glyphStrokePx = with(density) { ThemesMetrics.glyphStroke.toPx() }

    Box(modifier = Modifier.width(item.iconWidth), contentAlignment = Alignment.Center) {
        when (item) {
            ThemeCategory.ALL -> Icon(
                imageVector = Icons.Filled.GridView,
                contentDescription = null,
                tint = MochiColor.textPrimary,
                modifier = Modifier.size(item.iconWidth * 0.95f)
            )
            ThemeCategory.CUTE -> Image(
                painter = painterResource(R.drawable.icon_bow),
                contentDescription = null,
                contentScale = ContentScale.Fit,
                modifier = Modifier.size(item.iconWidth)
            )
            ThemeCategory.HANDWRITTEN -> PencilGlyph(
                color = MochiColor.textPrimary,
                strokeWidth = glyphStrokePx,
                modifier = Modifier.size(item.iconWidth)
            )
            ThemeCategory.MINIMAL -> Text(text = "Aa", style = MochiFont.heading(ThemesType.pill), color = MochiColor.textPrimary)
            ThemeCategory.BOLD -> Text(text = "B", style = MochiFont.title(ThemesType.pill), color = MochiColor.textPrimary)
            ThemeCategory.ELEGANT -> Text(text = "E", style = MochiFont.heading(ThemesType.pill), color = MochiColor.textPrimary)
            ThemeCategory.OTHER -> TripleDot(
                color = MochiColor.textPrimary,
                modifier = Modifier.width(item.iconWidth).height(1.48.dp)
            )
        }
    }
}

// endregion

// region Filter row

/** Right-aligned; unlike the Fonts frame there is no "Soft by" capsule on the left of it. */
@Composable
private fun FilterRow() {
    val density = LocalDensity.current
    val glyphStrokePx = with(density) { ThemesMetrics.glyphStroke.toPx() }

    Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.End, verticalAlignment = Alignment.CenterVertically) {
        Row(
            modifier = Modifier
                .width(ThemesMetrics.filterWidth)
                .height(ThemesMetrics.filterHeight)
                .clip(CircleShape)
                .background(Color.White)
                .border(ThemesMetrics.hairline, MochiColor.logoSolid, CircleShape),
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.spacedBy(ThemesMetrics.filterHeight * 0.16f, Alignment.CenterHorizontally)
        ) {
            FunnelGlyph(
                color = MochiColor.logoSolid,
                style = Stroke(width = glyphStrokePx, join = StrokeJoin.Round),
                modifier = Modifier.size(width = ThemesMetrics.funnelGlyph.width, height = ThemesMetrics.funnelGlyph.height)
            )
            Text(text = "Filter", style = MochiFont.caption(ThemesType.filter), color = MochiColor.logoSolid)
        }

        Spacer(modifier = Modifier.width(ThemesMetrics.filterGap))

        Box(
            modifier = Modifier
                .width(ThemesMetrics.slidersWidth)
                .height(ThemesMetrics.filterHeight)
                .clip(CircleShape)
                .background(Color.White)
                .border(ThemesMetrics.hairline, MochiColor.logoSolid, CircleShape),
            contentAlignment = Alignment.Center
        ) {
            SlidersGlyph(
                color = MochiColor.logoSolid,
                strokeWidth = glyphStrokePx,
                modifier = Modifier.size(width = ThemesMetrics.slidersGlyph.width, height = ThemesMetrics.slidersGlyph.height)
            )
        }
    }
}

// endregion

// region Card grid

@Composable
private fun CardGrid(themes: List<KeyboardTheme>, onThemeClick: (KeyboardTheme) -> Unit) {
    Column(verticalArrangement = Arrangement.spacedBy(ThemesMetrics.cardGap)) {
        themes.chunked(3).forEach { row ->
            Row(horizontalArrangement = Arrangement.spacedBy(ThemesMetrics.cardGap)) {
                row.forEach { theme -> ThemeGridCard(theme, onClick = { onThemeClick(theme) }) }
            }
        }
    }
}

@Composable
private fun ThemeGridCard(theme: KeyboardTheme, onClick: () -> Unit) {
    val density = LocalDensity.current

    Column(
        modifier = Modifier
            .width(ThemesMetrics.cardWidth)
            .clip(RoundedCornerShape(ThemesMetrics.cardRadius))
    ) {
        Box {
            ThemesArtImage(
                assetName = theme.imageAssetName,
                modifier = Modifier
                    .width(ThemesMetrics.cardWidth)
                    .height(ThemesMetrics.cardWidth / ThemesMetrics.cardArtAspect)
            )
            Box(
                modifier = Modifier
                    .align(Alignment.TopEnd)
                    .padding(top = ThemesMetrics.downloadTop, end = ThemesMetrics.downloadTrailing)
                    .size(ThemesMetrics.download)
                    .clip(CircleShape)
                    .background(Color.White),
                contentAlignment = Alignment.Center
            ) {
                DownloadGlyph(
                    color = MochiColor.downloadGlyph,
                    strokeWidth = with(density) { (ThemesMetrics.download * 0.046f).toPx() },
                    modifier = Modifier.size(width = ThemesMetrics.download * 0.477f, height = ThemesMetrics.download * 0.492f)
                )
            }
        }

        Column(
            modifier = Modifier
                .width(ThemesMetrics.cardWidth)
                .height(ThemesMetrics.cardBodyHeight)
                .background(Color.White)
                .padding(horizontal = ThemesMetrics.cardPad)
        ) {
            Spacer(modifier = Modifier.height(ThemesMetrics.bodyTopToTitle))

            Row(verticalAlignment = Alignment.CenterVertically) {
                Column(
                    modifier = Modifier.weight(1f, fill = false),
                    verticalArrangement = Arrangement.spacedBy(ThemesMetrics.titleToByline)
                ) {
                    Text(
                        text = theme.name,
                        style = MochiFont.caption(ThemesType.cardTitle),
                        color = MochiColor.textPrimary,
                        maxLines = 1,
                        overflow = TextOverflow.Ellipsis
                    )
                    Text(
                        text = theme.creatorName,
                        style = MochiFont.caption(ThemesType.cardByline),
                        color = MochiColor.creatorLink,
                        maxLines = 1,
                        overflow = TextOverflow.Ellipsis
                    )
                }
                Spacer(modifier = Modifier.width(1.dp))
                Row(
                    verticalAlignment = Alignment.CenterVertically,
                    horizontalArrangement = Arrangement.spacedBy(ThemesMetrics.heartToCount)
                ) {
                    Icon(
                        imageVector = Icons.Filled.Favorite,
                        contentDescription = null,
                        tint = MochiColor.heart,
                        modifier = Modifier.size(width = ThemesMetrics.heart.width, height = ThemesMetrics.heart.height)
                    )
                    Text(text = theme.likeCountFormatted, style = MochiFont.caption(ThemesType.likeCount), color = MochiColor.textPrimary)
                }
            }

            Spacer(modifier = Modifier.height(ThemesMetrics.bylineToButtons))

            Row(horizontalArrangement = Arrangement.spacedBy(ThemesMetrics.cardButtonGap)) {
                Box(
                    modifier = Modifier
                        .weight(1f)
                        .height(ThemesMetrics.cardButtonHeight)
                        .clip(CircleShape)
                        .background(Color.White)
                        .border(ThemesMetrics.hairline, MochiColor.logoSolid, CircleShape)
                        .clickable(onClick = onClick),
                    contentAlignment = Alignment.Center
                ) {
                    Text(text = "Preview", style = MochiFont.body(ThemesType.previewButton), color = MochiColor.textPrimary)
                }
                Box(
                    modifier = Modifier
                        .weight(1f)
                        .height(ThemesMetrics.cardButtonHeight)
                        .clip(CircleShape)
                        .background(MochiGradient.themeButton)
                        .clickable(onClick = onClick),
                    contentAlignment = Alignment.Center
                ) {
                    Text(text = "Apply", style = MochiFont.body(ThemesType.applyButton), color = MochiColor.textPrimary)
                }
            }

            Spacer(modifier = Modifier.height(ThemesMetrics.bodyBottom))
        }
    }
}

// endregion

// region Downloaded strip

@Composable
private fun DownloadedSection(themes: List<KeyboardTheme>) {
    Column {
        Row(
            modifier = Modifier.fillMaxWidth().padding(horizontal = ThemesMetrics.headingInset),
            verticalAlignment = Alignment.CenterVertically
        ) {
            Text(
                text = "MY DOWNLOADED THEMES",
                style = MochiFont.title(ThemesType.sectionTitle),
                color = MochiColor.textPrimary,
                modifier = Modifier.weight(1f)
            )
            Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(ThemesMetrics.seeAllGap)) {
                Text(text = "see all", style = MochiFont.body(ThemesType.seeAll), color = MochiColor.logoSolid)
                Icon(
                    imageVector = Icons.AutoMirrored.Filled.KeyboardArrowRight,
                    contentDescription = null,
                    tint = MochiColor.logoSolid,
                    modifier = Modifier.size((ThemesType.seeAll.value * 0.80f).dp)
                )
            }
        }

        Spacer(modifier = Modifier.height(ThemesMetrics.headingToStrip))

        // The four tiles (85.43dp + 9.82dp gap, times four) land within a rounding error of the
        // 372dp content width, so this fills the row rather than genuinely needing to scroll —
        // still wrapped for headroom on narrower devices, same as the rest of the app's rows.
        Row(
            modifier = Modifier.horizontalScroll(rememberScrollState()),
            horizontalArrangement = Arrangement.spacedBy(ThemesMetrics.downloadCardGap)
        ) {
            themes.forEach { theme -> DownloadCard(theme) }
        }
    }
}

@Composable
private fun DownloadCard(theme: KeyboardTheme) {
    Column(
        modifier = Modifier
            .width(ThemesMetrics.downloadCard)
            .clip(RoundedCornerShape(ThemesMetrics.downloadRadius))
    ) {
        Box {
            ThemesArtImage(
                assetName = theme.imageAssetName,
                modifier = Modifier
                    .width(ThemesMetrics.downloadCard)
                    .height(ThemesMetrics.downloadCard / ThemesMetrics.downloadArtAspect)
            )
            Box(
                modifier = Modifier
                    .align(Alignment.TopEnd)
                    .padding(top = ThemesMetrics.ellipsisTop, end = ThemesMetrics.ellipsisTrailing)
                    .size(ThemesMetrics.ellipsisDisc)
                    .clip(CircleShape)
                    .background(Color.White),
                contentAlignment = Alignment.Center
            ) {
                Icon(
                    imageVector = Icons.Filled.MoreHoriz,
                    contentDescription = null,
                    tint = MochiColor.textPrimary,
                    modifier = Modifier.size(ThemesMetrics.ellipsisDisc * 0.44f)
                )
            }
        }
        Box(
            modifier = Modifier
                .width(ThemesMetrics.downloadCard)
                .height(ThemesMetrics.downloadBodyHeight)
                .background(Color.White)
                .padding(horizontal = ThemesMetrics.downloadNamePad),
            contentAlignment = Alignment.CenterStart
        ) {
            Text(
                text = theme.name,
                style = MochiFont.caption(ThemesType.downloadName),
                color = MochiColor.textPrimary,
                maxLines = 1,
                overflow = TextOverflow.Ellipsis
            )
        }
    }
}

// endregion
