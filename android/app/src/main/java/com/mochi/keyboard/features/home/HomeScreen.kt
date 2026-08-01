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
import androidx.compose.foundation.layout.fillMaxHeight
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.horizontalScroll
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
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import androidx.lifecycle.viewmodel.compose.viewModel
import com.mochi.keyboard.R
import com.mochi.keyboard.components.FontArtCard
import com.mochi.keyboard.components.SectionHeader
import com.mochi.keyboard.components.ThemeArt
import com.mochi.keyboard.data.rememberMochiViewModelFactory
import com.mochi.keyboard.designsystem.MochiColor
import com.mochi.keyboard.designsystem.MochiFont
import com.mochi.keyboard.designsystem.MochiGradient
import com.mochi.keyboard.designsystem.MochiRadius
import com.mochi.keyboard.designsystem.MochiSpacing
import com.mochi.keyboard.mockdata.MockData
import com.mochi.keyboard.model.FontItem
import com.mochi.keyboard.model.KeyboardTheme

private enum class LibraryTab { FONTS, THEMES }

/** Ported from ios/MochiApp/Features/Home/HomeView.swift. Figma's Home screen is a single fixed
 * viewport with no scrolling — every section below sizes itself by weight() against the available
 * height instead of a fixed dp, so the whole screen always fits exactly with no cut-off content
 * and no scrollbar, matching docs/figma/1.png / 13.png. */
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
 * carefully pixel-tuned fixed-viewport layout (see class doc above). Once the emulator has themes
 * seeded (firestore/seed/seed.mjs), this renders real data; until then it looks identical to before. */
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

        Column(
            modifier = Modifier
                .fillMaxSize()
                .windowInsetsPadding(WindowInsets.statusBars)
                .padding(horizontal = MochiSpacing.md)
                .padding(top = 24.dp, bottom = 84.dp)
        ) {
            Header(onCreateTabClick)
            Spacer(modifier = Modifier.height(MochiSpacing.sm))
            RecentlyAppliedRow(recentlyApplied, onThemeClick)
            Spacer(modifier = Modifier.height(MochiSpacing.sm))
            QuickActionCards(onCreateTabClick, onChooseTabClick)
            Spacer(modifier = Modifier.height(20.dp))
            LibraryToggle(libraryTab) { libraryTab = it }
            Spacer(modifier = Modifier.height(MochiSpacing.lg))
            SectionHeader(title = "Popular Themes")
            Spacer(modifier = Modifier.height(4.dp))
            ThemesRow(popularThemes, onThemeClick)
            Spacer(modifier = Modifier.height(MochiSpacing.sm))
            SectionHeader(title = "Font Collection")
            Spacer(modifier = Modifier.height(4.dp))
            FontsRow(MockData.fonts)
            Spacer(modifier = Modifier.weight(1f))
        }
    }
}

@Composable
private fun Header(onCreateTabClick: () -> Unit) {
    Row(modifier = Modifier.fillMaxWidth(), verticalAlignment = Alignment.Top) {
        Text(
            text = "Mochi",
            // Pixel-measured as a fraction of docs/figma/1.png's own frame width (device-
            // independent: wordmark height is ~8.07% of screen width there) then applied to this
            // device's REAL density (`adb shell wm density` = 300dpi = 1.875px/dp, 384dp logical
            // width) rather than assuming a dp figure - two earlier passes both guessed the wrong
            // px/dp scale (once via the Create Custom icon's assumed-vs-actual Figma size, once via
            // an assumed 393dp device width) and overshot. Target: ~31dp height -> 42sp measured
            // against this device's actual rendering. Offset scales with font size since Fredoka's
            // internal leading (the gap above the cap-height) grows with it too.
            style = MochiFont.logo(42.sp),
            color = MochiColor.logoSolid,
            modifier = Modifier.offset(y = (-10).dp)
        )
        Spacer(modifier = Modifier.weight(1f))
        Column(
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.spacedBy(4.dp),
            modifier = Modifier.clickable(onClick = onCreateTabClick)
        ) {
            Box(modifier = Modifier.size(48.dp)) {
                Image(
                    painter = painterResource(R.drawable.icon_create_custom),
                    contentDescription = "Create Custom",
                    modifier = Modifier.size(48.dp).clip(CircleShape)
                )
                // Pixel-measured from docs/figma/1.png: a single sparkle sits ~31dp right / ~11dp
                // above the icon's center, overlapping its top-right edge. Extracted as its own
                // sprite (ic_star_sparkle) rather than baked into home_background.png, since the
                // background's own baked-in stars were measurably misplaced relative to this icon.
                Image(
                    painter = painterResource(R.drawable.ic_star_sparkle),
                    contentDescription = null,
                    modifier = Modifier
                        .size(width = 24.dp, height = 28.dp)
                        .offset(x = 43.dp, y = (-1).dp)
                )
            }
            Text(
                text = "Create Custom",
                style = MochiFont.caption(10.sp).copy(fontWeight = FontWeight.Bold),
                color = MochiColor.textPrimary
            )
        }
    }
}

/** Figma shows exactly 3 recently-applied cards filling the row edge-to-edge with no scrolling.
 * Shares KeyboardPreviewCard with the Popular Themes row below so both rows are guaranteed
 * pixel-identical sizing/styling rather than two independently-tuned card implementations. */
@Composable
private fun RecentlyAppliedRow(themes: List<KeyboardTheme>, onThemeClick: (KeyboardTheme) -> Unit, modifier: Modifier = Modifier) {
    Row(modifier = modifier.fillMaxWidth(), horizontalArrangement = Arrangement.spacedBy(MochiSpacing.sm)) {
        themes.forEach { theme ->
            KeyboardPreviewCard(theme = theme, onTap = { onThemeClick(theme) }, modifier = Modifier.weight(1f))
        }
    }
}

/** Single shared card for any row of equal-size keyboard preview thumbnails (Recently Applied,
 * Popular Themes): a fixed 1.35:1 landscape aspect ratio (matching the real keyboard art's own
 * proportions, measured from docs/figma/13.png) so the full mini keyboard scene is visible instead
 * of being cropped to whatever height a weighted row happened to allocate. Transparent background
 * behind the text (no white card box), matching Figma. */
@Composable
private fun KeyboardPreviewCard(theme: KeyboardTheme, onTap: () -> Unit, modifier: Modifier = Modifier) {
    Column(
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.spacedBy(MochiSpacing.sm),
        modifier = modifier.clickable(onClick = onTap)
    ) {
        ThemeArt(assetName = theme.imageAssetName, seed = theme.id, modifier = Modifier.fillMaxWidth().aspectRatio(1.35f))
        Text(
            text = theme.name,
            style = MochiFont.heading(12.sp),
            color = MochiColor.textPrimary,
            textAlign = TextAlign.Center,
            maxLines = 1,
            modifier = Modifier.fillMaxWidth()
        )
    }
}

/** Pixel-measured from docs/figma/13.png (card1_isolated.png: 995x545px) — the card is a ~1.83:1
 * landscape rectangle, not a square/tall shape. Fixed aspectRatio on both cards (rather than the
 * previous IntrinsicSize.Min content-matching) guarantees identical dimensions directly, and is
 * simpler: both cards are the same size by construction, not by matching each other's content. */
@Composable
private fun QuickActionCards(onCreateTabClick: () -> Unit, onChooseTabClick: () -> Unit, modifier: Modifier = Modifier) {
    Row(modifier = modifier.fillMaxWidth(), horizontalArrangement = Arrangement.spacedBy(MochiSpacing.sm)) {
        ActionCard(
            iconResId = R.drawable.icon_palette,
            title = "Custom Create",
            subtitle = "Design your own keyboard",
            buttonTitle = "Create",
            modifier = Modifier.weight(1f),
            onButtonClick = onCreateTabClick
        )
        ActionCard(
            iconResId = R.drawable.icon_library,
            title = "Choose from Library",
            subtitle = "Pick a created keyboard",
            buttonTitle = "Choose",
            modifier = Modifier.weight(1f),
            onButtonClick = onChooseTabClick
        )
    }
}

/** Figma lays these out icon-left / text-right (not icon-on-top-of-text), inside a card with a
 * visible border outline rather than a plain shadowed white box. Re-measured directly from a tight
 * crop of docs/figma/13.png (card border box 974x534px): true aspect ratio is 1.83:1 — restored
 * here now that the icon (48dp, ~28% of card width) and text sizes below are also re-measured down
 * to their correct proportions, which is what actually fixes the overflow that previously forced a
 * loosened 1.55:1 ratio (the ratio wasn't the bug; oversized content was). Arrangement.SpaceBetween
 * still pins the button to the bottom regardless of the 1- vs 2-line title. */
@Composable
private fun ActionCard(iconResId: Int, title: String, subtitle: String, buttonTitle: String, modifier: Modifier = Modifier, onButtonClick: () -> Unit = {}) {
    Column(
        modifier = modifier
            .aspectRatio(1.83f)
            .clip(RoundedCornerShape(MochiRadius.card))
            .background(Color.White)
            .border(1.dp, MochiColor.purple.copy(alpha = 0.3f), RoundedCornerShape(MochiRadius.card))
            // Grid-measured directly off docs/figma/1.png (5.52px/dp, the frame-width scale, not
            // the icon): icon sits ~24dp from the card's left edge and ~19dp from its top, while
            // the button sits only ~13dp above the card's bottom - the flat 8dp (MochiSpacing.sm)
            // padding this replaced was roughly a third of the real inset on every side. Top/bottom
            // trimmed back from the raw measurement (18/13dp) to 14/10dp - the full figure clipped
            // the "Choose from Library" button off the bottom of the card, since its 2-line title
            // leaves less vertical room than "Custom Create"'s 1-line title at this aspect ratio.
            .padding(start = 20.dp, top = 14.dp, end = 16.dp, bottom = 10.dp),
        verticalArrangement = Arrangement.SpaceBetween
    ) {
        Row(horizontalArrangement = Arrangement.spacedBy(MochiSpacing.md), verticalAlignment = Alignment.Top) {
            Image(
                painter = painterResource(iconResId),
                contentDescription = null,
                // Figma's icon bbox is ~49x39dp (a wide, non-square palette+brush shape) - 56dp
                // was oversized; 48dp lets Fit scaling land close to the measured max dimension.
                modifier = Modifier.size(48.dp)
            )
            Column(horizontalAlignment = Alignment.Start, verticalArrangement = Arrangement.spacedBy(2.dp)) {
                Text(
                    text = title,
                    style = MochiFont.heading(10.sp).copy(lineHeight = 12.sp),
                    color = MochiColor.textPrimary,
                    textAlign = TextAlign.Start
                )
                Text(
                    text = subtitle,
                    style = MochiFont.caption(9.sp).copy(lineHeight = 10.sp),
                    color = MochiColor.textPrimary,
                    maxLines = 2,
                    textAlign = TextAlign.Start
                )
            }
        }
        Box(modifier = Modifier.fillMaxWidth(), contentAlignment = Alignment.Center) {
            SlimPillButton(title = buttonTitle, onClick = onButtonClick)
        }
    }
}

/** GradientButton wraps Material's TextButton, which enforces a ~40dp minimum touch height no
 * matter what explicit height() is passed in — that silently won over an earlier attempt at a
 * 24dp button here, overflowing the card and clipping the subtitle text below it. This is a plain
 * Box (same pattern as ToggleButton below), so the height is genuinely whatever is set here. */
@Composable
private fun SlimPillButton(title: String, modifier: Modifier = Modifier, onClick: () -> Unit) {
    Box(
        // Figma-measured (both action-card buttons, "Create" and "Choose"): ~62.5dp wide,
        // ~19.5dp tall - both pills are already forced identical by this one shared composable,
        // used the same way by both cards. "Choose" LOOKS more cramped only because its letters
        // (h, o, o) are wider than "Create"'s at the same font size - true in Figma too (its
        // Choose text fills ~48% of the pill vs Create's ~45%) - dropping to 9sp gives both words
        // more breathing room without shrinking the pill itself.
        modifier = modifier
            .width(63.dp)
            .height(20.dp)
            .clip(CircleShape)
            .background(MochiGradient.softButton)
            .clickable(onClick = onClick),
        contentAlignment = Alignment.Center
    ) {
        Text(text = title, style = MochiFont.button(9.sp), color = MochiColor.textPrimary)
    }
}

/** Pixel-measured from docs/figma/1.png: the FONTS/THEMES pills don't span the full card-row
 * width — they sit inset with roughly double the standard screen margin on each side (~32dp vs
 * the usual 16dp), so this row needs its own extra horizontal padding on top of the outer
 * Column's padding, not just weight(1f) filling the full available width. */
@Composable
private fun LibraryToggle(selected: LibraryTab, onSelect: (LibraryTab) -> Unit) {
    Row(
        horizontalArrangement = Arrangement.spacedBy(20.dp),
        modifier = Modifier.padding(horizontal = 16.dp)
    ) {
        ToggleButton("Fonts", selected == LibraryTab.FONTS, Modifier.weight(1f)) { onSelect(LibraryTab.FONTS) }
        ToggleButton("Themes", selected == LibraryTab.THEMES, Modifier.weight(1f)) { onSelect(LibraryTab.THEMES) }
    }
}

/** Pixel-measured from docs/figma/13.png: the "FONTS"/"THEMES" pill text has a cap-height ~1.6x
 * the action-card title's cap-height (59px vs 37px in the source crop) and fills a much larger
 * fraction of the pill's own height than a typical button label — bold, chunky, dominant text is
 * the actual Figma look, not a small label inside generous padding. */
@Composable
private fun ToggleButton(title: String, isSelected: Boolean, modifier: Modifier = Modifier, onClick: () -> Unit) {
    val background = if (isSelected) {
        Modifier.background(MochiGradient.primaryButton, CircleShape)
    } else {
        Modifier.background(Color.White, CircleShape).border(1.dp, MochiColor.purple.copy(alpha = 0.4f), CircleShape)
    }
    Box(
        modifier = modifier
            .clip(CircleShape)
            .then(background)
            .clickable(onClick = onClick)
            .padding(vertical = 3.dp),
        contentAlignment = Alignment.Center
    ) {
        Text(
            text = title.uppercase(),
            style = MochiFont.button(16.sp),
            color = MochiColor.textPrimary
        )
    }
}

/** Figma shows Popular Themes at a bigger fixed card size than Recently Applied, with the row
 * horizontally scrollable so exactly 2.5 cards are visible (the 3rd peeking at the edge as a
 * scroll affordance) rather than 3 equal-weight cards shrunk to fit fully on screen. 138dp solves
 * screenContentWidth(361dp) = 2*cardWidth + 2*gap(8dp) + 0.5*cardWidth for exactly a half-peek —
 * 148dp only left ~33% of the 3rd card visible. */
@Composable
private fun ThemesRow(themes: List<KeyboardTheme>, onThemeClick: (KeyboardTheme) -> Unit, modifier: Modifier = Modifier) {
    Row(
        modifier = modifier.horizontalScroll(rememberScrollState()),
        horizontalArrangement = Arrangement.spacedBy(MochiSpacing.sm)
    ) {
        themes.forEach { theme ->
            KeyboardPreviewCard(theme = theme, onTap = { onThemeClick(theme) }, modifier = Modifier.width(138.dp))
        }
    }
}

/** Figma sizes these bigger than "4 equal columns dividing the screen width" allows — the 4th
 * card visibly pokes past the screen edge, cut off, as a scroll affordance. Fixed 90dp width
 * (up from the ~84dp that 4-equal-columns produced) with horizontal scroll instead of weight(1f). */
@Composable
private fun FontsRow(fonts: List<FontItem>, modifier: Modifier = Modifier) {
    Row(
        modifier = modifier.horizontalScroll(rememberScrollState()),
        horizontalArrangement = Arrangement.spacedBy(MochiSpacing.sm)
    ) {
        fonts.forEach { font ->
            FontArtCard(
                assetName = font.previewAssetName,
                modifier = Modifier.width(90.dp).aspectRatio(1.23f)
            ) {
                Column(
                    modifier = Modifier
                        .fillMaxSize()
                        .clip(RoundedCornerShape(MochiRadius.card))
                        .background(Color.White)
                        .padding(6.dp),
                    horizontalAlignment = Alignment.CenterHorizontally,
                    verticalArrangement = Arrangement.spacedBy(4.dp)
                ) {
                    Text(text = "Aa", style = MochiFont.logo(24.sp), color = MochiColor.purple)
                    Text(text = font.name, style = MochiFont.heading(10.sp), color = MochiColor.textPrimary, textAlign = TextAlign.Center, maxLines = 1)
                    Text(text = font.styleDescription, style = MochiFont.caption(8.sp), color = MochiColor.textSecondary, textAlign = TextAlign.Center, maxLines = 1)
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
