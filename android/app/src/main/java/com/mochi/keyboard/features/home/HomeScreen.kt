package com.mochi.keyboard.features.home

import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.WindowInsets
import androidx.compose.foundation.layout.aspectRatio
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.horizontalScroll
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.heightIn
import androidx.compose.foundation.layout.offset
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.statusBars
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.layout.windowInsetsPadding
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.shadow
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import androidx.lifecycle.viewmodel.compose.viewModel
import com.mochi.keyboard.R
import com.mochi.keyboard.components.FontArtCard
import com.mochi.keyboard.components.SectionHeader
import com.mochi.keyboard.components.SparkleField
import com.mochi.keyboard.components.ThemeArt
import com.mochi.keyboard.data.rememberMochiViewModelFactory
import com.mochi.keyboard.designsystem.ActionCardTuning
import com.mochi.keyboard.designsystem.HomeMetrics
import com.mochi.keyboard.designsystem.MochiColor
import com.mochi.keyboard.designsystem.MochiFont
import com.mochi.keyboard.designsystem.MochiGradient
import com.mochi.keyboard.designsystem.MochiSpacing
import com.mochi.keyboard.mockdata.MockData
import com.mochi.keyboard.model.FontItem
import com.mochi.keyboard.model.KeyboardTheme

private enum class LibraryTab { FONTS, THEMES }

/** Ported from ios/MochiApp/Features/Home/HomeView.swift. Layout numbers live in HomeMetrics /
 * ActionCardTuning, not here — see that file for where each came from. A single fixed viewport,
 * no scrolling: every gap between sections is a flexible Spacer with a floor (heightIn(min=)),
 * matching iOS's `Spacer(minLength:)` so any leftover height from a taller-than-16:9 screen is
 * spent evenly across the gaps instead of pooling as dead space at the bottom. */
@Composable
fun HomeScreen(
    modifier: Modifier = Modifier,
    onThemeClick: (KeyboardTheme) -> Unit = {},
    onCreateTabClick: () -> Unit = {},
    onChooseTabClick: () -> Unit = {},
    viewModel: HomeViewModel = viewModel(factory = rememberMochiViewModelFactory())
) {
    val uiState by viewModel.uiState.collectAsStateWithLifecycle()
    HomeScreenContent(modifier, uiState, onThemeClick, onCreateTabClick, onChooseTabClick)
}

/** Real Firestore data only replaces the two theme rows once it's actually loaded (HomeUiState.Data)
 * — Loading/Empty/Error fall back to MockData rather than collapsing or reflowing this screen's
 * fixed-viewport layout. */
@Composable
private fun HomeScreenContent(
    modifier: Modifier = Modifier,
    uiState: HomeUiState,
    onThemeClick: (KeyboardTheme) -> Unit = {},
    onCreateTabClick: () -> Unit = {},
    onChooseTabClick: () -> Unit = {}
) {
    var libraryTab by remember { mutableStateOf(LibraryTab.FONTS) }
    val recentlyApplied = (uiState as? HomeUiState.Data)?.recentlyApplied ?: MockData.popularThemes
    val popularThemes = (uiState as? HomeUiState.Data)?.popular ?: MockData.homePopularThemes

    Box(modifier = modifier.fillMaxSize()) {
        Image(
            painter = painterResource(R.drawable.home_background),
            contentDescription = null,
            contentScale = ContentScale.Crop,
            modifier = Modifier.fillMaxSize()
        )
        SparkleField(modifier = Modifier.fillMaxSize())

        Column(
            modifier = Modifier
                .fillMaxSize()
                .windowInsetsPadding(WindowInsets.statusBars)
                .padding(horizontal = MochiSpacing.md)
                .padding(bottom = 84.dp) // reserves space for MochiTabBar, which overlays on top edge-to-edge
                // Compose's padding() rejects negative values (unlike SwiftUI); offset() shifts
                // the whole column up the same way without that restriction.
                .offset(y = HomeMetrics.headerTopPadding)
        ) {
            Header(onCreateTabClick)

            FlexGap(HomeMetrics.gapHeaderCarousel)
            RecentlyAppliedRow(recentlyApplied, onThemeClick)

            FlexGap(HomeMetrics.gapCarouselCards)
            QuickActionCards(onCreateTabClick, onChooseTabClick)

            FlexGap(HomeMetrics.gapCardsPills)
            LibraryToggle(libraryTab) { libraryTab = it }

            FlexGap(HomeMetrics.gapPillsSection)
            SectionHeader(title = "Popular Themes", titleSize = HomeMetrics.sectionHeaderSize, actionSize = HomeMetrics.seeAllSize)
            Spacer(modifier = Modifier.height(HomeMetrics.sectionHeaderGap))
            ThemesRow(popularThemes, onThemeClick)

            FlexGap(HomeMetrics.gapThemesFonts)
            SectionHeader(title = "Font Collection", titleSize = HomeMetrics.sectionHeaderSize, actionSize = HomeMetrics.seeAllSize)
            Spacer(modifier = Modifier.height(HomeMetrics.sectionHeaderGap))
            FontsRow(MockData.fonts)

            // Fixed, so leftover height from a taller-than-16:9 screen lands in the FlexGaps
            // above rather than pooling here as dead space.
            Spacer(modifier = Modifier.height(HomeMetrics.bottomGap))
        }
    }
}

/** A flexible gap with a floor, mirroring SwiftUI's `Spacer(minLength:)` inside a non-scrolling
 * column: shares leftover column height evenly with every other FlexGap while never collapsing
 * below `min`. */
@Composable
private fun androidx.compose.foundation.layout.ColumnScope.FlexGap(min: Dp) {
    Spacer(modifier = Modifier.weight(1f).heightIn(min = min))
}

@Composable
private fun Header(onCreateTabClick: () -> Unit) {
    Row(modifier = Modifier.fillMaxWidth(), verticalAlignment = Alignment.Top) {
        Text(
            text = "Mochi",
            style = MochiFont.logo(HomeMetrics.logoSize),
            color = MochiColor.logoSolid // flat color, not a gradient
        )
        Spacer(modifier = Modifier.weight(1f))
        Column(
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.spacedBy(5.dp),
            modifier = Modifier.clickable(onClick = onCreateTabClick)
        ) {
            // Single sparkle: home_background.png already bakes in an ambient sparkle near this
            // corner, so no extra overlay is added here — matches iOS 1:1.
            Image(
                painter = painterResource(R.drawable.icon_create_custom),
                contentDescription = "Create Custom",
                modifier = Modifier.size(HomeMetrics.createCustomIcon).clip(CircleShape)
            )
            Text(
                text = "Create Custom",
                style = MochiFont.caption(HomeMetrics.createCustomLabel),
                color = MochiColor.textPrimary
            )
        }
    }
}

/** Figma shows exactly 3 recently-applied cards filling the row edge-to-edge, no scrolling —
 * weight(1f) on each card equalizes their widths across the row regardless of name length,
 * standing in for iOS's explicit `contentWidth`-derived card width. */
@Composable
private fun RecentlyAppliedRow(themes: List<KeyboardTheme>, onThemeClick: (KeyboardTheme) -> Unit) {
    Row(horizontalArrangement = Arrangement.spacedBy(HomeMetrics.carouselGap)) {
        themes.forEach { theme ->
            ThemeCardWithName(
                theme,
                artRadius = HomeMetrics.carouselArtRadius,
                artRatio = HomeMetrics.carouselArtRatio,
                onClick = { onThemeClick(theme) },
                modifier = Modifier.weight(1f)
            )
        }
    }
}

/** Transparent background behind the text, no white card box, and deliberately NO crown/like
 * count — those belong to the dedicated Themes tab's card, not Home's. Shared by the Recently
 * Applied row and the Popular Themes row so both stay pixel-identical in styling. */
@Composable
private fun ThemeCardWithName(theme: KeyboardTheme, artRadius: Dp, artRatio: Float, onClick: () -> Unit, modifier: Modifier = Modifier) {
    Column(
        verticalArrangement = Arrangement.spacedBy(HomeMetrics.carouselNameGap),
        modifier = modifier.clickable(onClick = onClick)
    ) {
        Box(modifier = Modifier.fillMaxWidth().aspectRatio(artRatio)) {
            ThemeArt(assetName = theme.imageAssetName, seed = theme.id, cornerRadius = artRadius, modifier = Modifier.fillMaxSize())
        }
        Text(
            text = theme.name,
            style = MochiFont.itemName(HomeMetrics.themeNameSize),
            color = MochiColor.textPrimary,
            textAlign = TextAlign.Center,
            maxLines = 2,
            modifier = Modifier.fillMaxWidth().heightIn(min = HomeMetrics.carouselNameReserve)
        )
    }
}

@Composable
private fun QuickActionCards(onCreateTabClick: () -> Unit, onChooseTabClick: () -> Unit) {
    Row(horizontalArrangement = Arrangement.spacedBy(HomeMetrics.actionCardGap)) {
        ActionCard(
            tuning = ActionCardTuning.customCreate,
            iconResId = R.drawable.icon_palette,
            title = "Custom Create",
            subtitle = "Design your own\nkeyboard",
            buttonTitle = "Create",
            onButtonClick = onCreateTabClick,
            modifier = Modifier.weight(1f)
        )
        ActionCard(
            tuning = ActionCardTuning.chooseLibrary,
            iconResId = R.drawable.icon_library,
            title = "Choose from\nLibrary",
            subtitle = "Pick a created\nkeyboard",
            buttonTitle = "Choose",
            onButtonClick = onChooseTabClick,
            modifier = Modifier.weight(1f)
        )
    }
}

/** Icon on the left, title+subtitle to its right, button BELOW and horizontally CENTERED in the
 * card. The icon/text row is vertically centered in the space above the button (a weighted Box)
 * so both cards stay the same height regardless of whether the title wraps to one or two lines.
 * `aspectRatio` derives the card's height from whatever width the parent Row's weight(1f) gives
 * it, standing in for iOS's explicit `contentWidth`-derived actionCardWidth. */
@Composable
private fun ActionCard(
    tuning: ActionCardTuning,
    iconResId: Int,
    title: String,
    subtitle: String,
    buttonTitle: String,
    onButtonClick: () -> Unit,
    modifier: Modifier = Modifier
) {
    val shape = RoundedCornerShape(HomeMetrics.actionCardRadius)

    Column(
        modifier = modifier
            .aspectRatio(HomeMetrics.actionCardRatio)
            .shadow(10.dp, shape, ambientColor = MochiColor.purpleDark.copy(alpha = 0.10f), spotColor = MochiColor.purpleDark.copy(alpha = 0.10f))
            .clip(shape)
            .background(Color.White)
            .border(1.dp, MochiColor.purple.copy(alpha = 0.3f), shape)
            .padding(horizontal = tuning.hPad, vertical = tuning.vPad)
    ) {
        Box(modifier = Modifier.weight(1f).fillMaxWidth(), contentAlignment = Alignment.CenterStart) {
            Row(horizontalArrangement = Arrangement.spacedBy(tuning.iconTextGap), verticalAlignment = Alignment.CenterVertically) {
                Image(
                    painter = painterResource(iconResId),
                    contentDescription = null,
                    contentScale = ContentScale.Fit,
                    modifier = Modifier.size(tuning.iconSize).offset(x = tuning.iconHOffset, y = tuning.iconVOffset)
                )
                Column(
                    horizontalAlignment = Alignment.Start,
                    verticalArrangement = Arrangement.spacedBy(tuning.titleGap),
                    modifier = Modifier.weight(1f).offset(y = tuning.textVOffset)
                ) {
                    Text(
                        text = title,
                        style = MochiFont.heading(tuning.titleSize),
                        color = MochiColor.textPrimary,
                        modifier = Modifier.offset(y = tuning.titleVOffset)
                    )
                    Text(
                        text = subtitle,
                        style = MochiFont.body(tuning.subtitleSize),
                        color = MochiColor.textPrimary,
                        modifier = Modifier.offset(y = tuning.subtitleVOffset)
                    )
                }
            }
        }
        Box(modifier = Modifier.fillMaxWidth(), contentAlignment = Alignment.Center) {
            SlimPillButton(title = buttonTitle, tuning = tuning, onClick = onButtonClick, modifier = Modifier.offset(y = tuning.buttonVOffset))
        }
    }
}

/** Deliberately a plain clickable Box, not GradientButton: Material's TextButton enforces a
 * ~40dp minimum touch height no matter what explicit height is passed, which silently overflowed
 * the card. Inter Regular (MochiFont.body), not SemiBold — "Create"/"Choose" read as plain weight
 * in the design and bold made them compete with the card title above. */
@Composable
private fun SlimPillButton(title: String, tuning: ActionCardTuning, modifier: Modifier = Modifier, onClick: () -> Unit) {
    Box(
        modifier = modifier
            .width(tuning.buttonWidth)
            .height(tuning.buttonHeight)
            .clip(CircleShape)
            .background(MochiGradient.softButton)
            .clickable(onClick = onClick),
        contentAlignment = Alignment.Center
    ) {
        Text(text = title, style = MochiFont.body(tuning.buttonTextSize), color = MochiColor.textPrimary)
    }
}

/** The pills sit inset from the screen edges further than the rest of the page (Figma: 154px vs
 * 82-91px), so this row gets its own extra padding on top of the shared screen margin. */
@Composable
private fun LibraryToggle(selected: LibraryTab, onSelect: (LibraryTab) -> Unit) {
    Row(
        horizontalArrangement = Arrangement.spacedBy(HomeMetrics.pillGap),
        modifier = Modifier.padding(horizontal = HomeMetrics.pillExtraInset)
    ) {
        ToggleButton("Fonts", selected == LibraryTab.FONTS, Modifier.weight(1f)) { onSelect(LibraryTab.FONTS) }
        ToggleButton("Themes", selected == LibraryTab.THEMES, Modifier.weight(1f)) { onSelect(LibraryTab.THEMES) }
    }
}

@Composable
private fun ToggleButton(title: String, isSelected: Boolean, modifier: Modifier = Modifier, onClick: () -> Unit) {
    val shape = CircleShape
    Box(
        modifier = modifier
            .height(HomeMetrics.pillHeight)
            .clip(shape)
            .then(
                if (isSelected) {
                    Modifier.background(MochiGradient.softButton)
                } else {
                    Modifier.background(Color.White).border(1.dp, MochiColor.purple.copy(alpha = 0.4f), shape)
                }
            )
            .clickable(onClick = onClick),
        contentAlignment = Alignment.Center
    ) {
        Text(text = title.uppercase(), style = MochiFont.title(HomeMetrics.pillLabelSize), color = MochiColor.textPrimary)
    }
}

/** Figma sizes Popular Themes cards bigger than Recently Applied's, horizontally scrollable so
 * ~2.5 cards are visible (the 3rd peeking as a scroll affordance). */
@Composable
private fun ThemesRow(themes: List<KeyboardTheme>, onThemeClick: (KeyboardTheme) -> Unit) {
    Row(
        modifier = Modifier.horizontalScroll(rememberScrollState()),
        horizontalArrangement = Arrangement.spacedBy(HomeMetrics.popularCardGap)
    ) {
        themes.forEach { theme ->
            ThemeCardWithName(
                theme = theme,
                artRadius = HomeMetrics.popularArtRadius,
                artRatio = HomeMetrics.carouselArtRatio,
                onClick = { onThemeClick(theme) },
                modifier = Modifier.width(HomeMetrics.popularCardWidth)
            )
        }
    }
}

/** Real per-style decorative art rather than a flat system "Aa" glyph — Figma's Font Collection
 * cards are bespoke illustrations. The "Aa" placeholder (fonts without extracted art) uses the
 * logo font. */
@Composable
private fun FontsRow(fonts: List<FontItem>) {
    val cardWidth = HomeMetrics.fontCardWidth
    val cardHeight = cardWidth / HomeMetrics.fontCardRatio
    Row(
        modifier = Modifier.horizontalScroll(rememberScrollState()),
        horizontalArrangement = Arrangement.spacedBy(HomeMetrics.fontCardGap)
    ) {
        fonts.forEach { font ->
            FontArtCard(
                assetName = font.previewAssetName,
                cornerRadius = HomeMetrics.fontCardRadius,
                modifier = Modifier.width(cardWidth).height(cardHeight)
            ) {
                Column(
                    horizontalAlignment = Alignment.CenterHorizontally,
                    verticalArrangement = Arrangement.spacedBy(6.dp),
                    modifier = Modifier
                        .width(cardWidth)
                        .height(cardHeight)
                        .clip(RoundedCornerShape(HomeMetrics.fontCardRadius))
                        .background(Color.White)
                        .padding(8.dp)
                ) {
                    Text(text = "Aa", style = MochiFont.logo((cardWidth.value * 0.27f).sp), color = MochiColor.purple)
                    Column(horizontalAlignment = Alignment.CenterHorizontally, verticalArrangement = Arrangement.spacedBy(1.dp)) {
                        Text(text = font.name, style = MochiFont.heading((cardWidth.value * 0.1f).sp), color = MochiColor.textPrimary, textAlign = TextAlign.Center, maxLines = 1)
                        Text(text = font.styleDescription, style = MochiFont.body((cardWidth.value * 0.083f).sp), color = MochiColor.textPrimary, textAlign = TextAlign.Center, maxLines = 1)
                    }
                }
            }
        }
    }
}

@Preview(showBackground = true, widthDp = 393, heightDp = 852)
@Composable
private fun HomeScreenPreview() {
    HomeScreenContent(uiState = HomeUiState.Data(MockData.popularThemes, MockData.homePopularThemes))
}
