package com.mochi.app.features.home

import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.BoxScope
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.IntrinsicSize
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.WindowInsets
import androidx.compose.foundation.layout.aspectRatio
import androidx.compose.foundation.layout.fillMaxHeight
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.statusBars
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.layout.windowInsetsPadding
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
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.mochi.app.R
import com.mochi.app.components.FontArtCard
import com.mochi.app.components.GradientButton
import com.mochi.app.components.SectionHeader
import com.mochi.app.components.ThemeArt
import com.mochi.app.designsystem.MochiColor
import com.mochi.app.designsystem.MochiFont
import com.mochi.app.designsystem.MochiGradient
import com.mochi.app.designsystem.MochiRadius
import com.mochi.app.designsystem.MochiSpacing
import com.mochi.app.mockdata.MockData
import com.mochi.app.model.FontItem
import com.mochi.app.model.KeyboardTheme

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
    onChooseTabClick: () -> Unit = {}
) {
    var libraryTab by remember { mutableStateOf(LibraryTab.THEMES) }

    Box(modifier = modifier.fillMaxSize().background(MochiGradient.background)) {
        // Drawn behind the content column on purpose: these are background flourishes (matching
        // the little accent stars in docs/figma/1.png / 13.png), so any card/button on top of a
        // sparkle's position simply covers it rather than the sparkle floating over content.
        SparkleDecorations()

        Column(
            modifier = Modifier
                .fillMaxSize()
                .windowInsetsPadding(WindowInsets.statusBars)
                .padding(horizontal = MochiSpacing.md)
                .padding(top = MochiSpacing.sm, bottom = 84.dp)
        ) {
            Header(onCreateTabClick)
            Spacer(modifier = Modifier.height(MochiSpacing.sm))
            RecentlyAppliedRow(MockData.popularThemes, onThemeClick, modifier = Modifier.weight(1f))
            Spacer(modifier = Modifier.height(MochiSpacing.sm))
            QuickActionCards(onCreateTabClick, onChooseTabClick)
            Spacer(modifier = Modifier.height(MochiSpacing.sm))
            LibraryToggle(libraryTab) { libraryTab = it }
            Spacer(modifier = Modifier.height(MochiSpacing.sm))
            SectionHeader(title = "Popular Themes")
            Spacer(modifier = Modifier.height(4.dp))
            ThemesRow(MockData.homePopularThemes, onThemeClick, modifier = Modifier.weight(1f))
            Spacer(modifier = Modifier.height(MochiSpacing.sm))
            SectionHeader(title = "Font Collection")
            Spacer(modifier = Modifier.height(4.dp))
            FontsRow(MockData.fonts)
        }
    }
}

/** Small decorative sparkles scattered on the background gradient, matching the accent stars
 * visible near the action-cards area in docs/figma/1.png / 13.png. */
@Composable
private fun BoxScope.SparkleDecorations() {
    Text(
        text = "✦",
        style = MochiFont.body(14.sp),
        color = Color.White.copy(alpha = 0.7f),
        modifier = Modifier.padding(end = 20.dp, top = 90.dp).align(Alignment.TopEnd)
    )
    Text(
        text = "✦",
        style = MochiFont.body(10.sp),
        color = Color.White.copy(alpha = 0.6f),
        modifier = Modifier.padding(end = 48.dp, top = 110.dp).align(Alignment.TopEnd)
    )
}

@Composable
private fun Header(onCreateTabClick: () -> Unit) {
    Row(modifier = Modifier.fillMaxWidth(), verticalAlignment = Alignment.CenterVertically) {
        Text(text = "Mochi", style = MochiFont.logo(40.sp), color = MochiColor.logoSolid)
        Spacer(modifier = Modifier.weight(1f))
        Column(
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.spacedBy(4.dp),
            modifier = Modifier.clickable(onClick = onCreateTabClick)
        ) {
            Image(
                painter = painterResource(R.drawable.icon_create_custom),
                contentDescription = "Create Custom",
                modifier = Modifier.size(48.dp).clip(CircleShape)
            )
            Text(text = "Create Custom", style = MochiFont.caption(10.sp), color = MochiColor.textPrimary)
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
            KeyboardPreviewCard(theme = theme, onTap = { onThemeClick(theme) }, modifier = Modifier.weight(1f).fillMaxHeight())
        }
    }
}

/** Single shared card for any row of equal-size keyboard preview thumbnails (Recently Applied,
 * Popular Themes): art fills the remaining height after the name label, transparent background
 * behind the text (no white card box), matching Figma. */
@Composable
private fun KeyboardPreviewCard(theme: KeyboardTheme, onTap: () -> Unit, modifier: Modifier = Modifier) {
    Column(
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.spacedBy(6.dp),
        modifier = modifier.clickable(onClick = onTap)
    ) {
        ThemeArt(assetName = theme.imageAssetName, seed = theme.id, modifier = Modifier.fillMaxWidth().weight(1f))
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

/** IntrinsicSize.Min on the row + fillMaxHeight on each card makes both cards match the taller
 * card's height — without it, "Custom Create" (1-line title) and "Choose from Library" (2-line
 * title) sized to their own content and came out visibly different heights. */
@Composable
private fun QuickActionCards(onCreateTabClick: () -> Unit, onChooseTabClick: () -> Unit, modifier: Modifier = Modifier) {
    Row(modifier = modifier.fillMaxWidth().height(IntrinsicSize.Min), horizontalArrangement = Arrangement.spacedBy(MochiSpacing.md)) {
        ActionCard(
            iconResId = R.drawable.icon_palette,
            title = "Custom Create",
            subtitle = "Design your own keyboard",
            buttonTitle = "Create",
            modifier = Modifier.weight(1f).fillMaxHeight(),
            onButtonClick = onCreateTabClick
        )
        ActionCard(
            iconResId = R.drawable.icon_library,
            title = "Choose from Library",
            subtitle = "Pick a created keyboard",
            buttonTitle = "Choose",
            modifier = Modifier.weight(1f).fillMaxHeight(),
            onButtonClick = onChooseTabClick
        )
    }
}

/** Figma lays these out icon-left / text-right (not icon-on-top-of-text), inside a card with a
 * visible border outline rather than a plain shadowed white box. Arrangement.SpaceBetween pins
 * the button to the bottom of the card regardless of how many lines the title/description wrap
 * to, so — combined with QuickActionCards' IntrinsicSize.Min stretch — both buttons always land
 * at the same vertical position. Both buttons share one fixed min-width so "Create" and "Choose"
 * render identically sized instead of shrinking to their own text. */
@Composable
private fun ActionCard(iconResId: Int, title: String, subtitle: String, buttonTitle: String, modifier: Modifier = Modifier, onButtonClick: () -> Unit = {}) {
    Column(
        modifier = modifier
            .clip(RoundedCornerShape(MochiRadius.card))
            .background(Color.White)
            .border(1.dp, MochiColor.purple.copy(alpha = 0.3f), RoundedCornerShape(MochiRadius.card))
            .padding(MochiSpacing.sm),
        verticalArrangement = Arrangement.SpaceBetween
    ) {
        Row(horizontalArrangement = Arrangement.spacedBy(8.dp), verticalAlignment = Alignment.CenterVertically) {
            Image(
                painter = painterResource(iconResId),
                contentDescription = null,
                modifier = Modifier.size(56.dp)
            )
            Column(verticalArrangement = Arrangement.spacedBy(2.dp)) {
                Text(text = title, style = MochiFont.heading(13.sp), color = MochiColor.textPrimary)
                Text(text = subtitle, style = MochiFont.caption(10.sp), color = MochiColor.textSecondary, maxLines = 2)
            }
        }
        GradientButton(
            title = buttonTitle,
            fillMaxWidth = false,
            compact = true,
            modifier = Modifier.width(ActionButtonMinWidth),
            onClick = onButtonClick
        )
    }
}

private val ActionButtonMinWidth = 96.dp

@Composable
private fun LibraryToggle(selected: LibraryTab, onSelect: (LibraryTab) -> Unit) {
    Row(horizontalArrangement = Arrangement.spacedBy(MochiSpacing.sm)) {
        ToggleButton("Fonts", selected == LibraryTab.FONTS, Modifier.weight(1f)) { onSelect(LibraryTab.FONTS) }
        ToggleButton("Themes", selected == LibraryTab.THEMES, Modifier.weight(1f)) { onSelect(LibraryTab.THEMES) }
    }
}

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
            .padding(vertical = 12.dp),
        contentAlignment = Alignment.Center
    ) {
        Text(
            text = title.uppercase(),
            style = MochiFont.button(19.sp),
            color = MochiColor.textPrimary
        )
    }
}

/** Fixed layout has no scrolling, so all 3 popular themes render fully rather than Figma's
 * scroll-peeked 2.5 — same KeyboardPreviewCard as RecentlyAppliedRow, sized identically. */
@Composable
private fun ThemesRow(themes: List<KeyboardTheme>, onThemeClick: (KeyboardTheme) -> Unit, modifier: Modifier = Modifier) {
    Row(modifier = modifier.fillMaxWidth(), horizontalArrangement = Arrangement.spacedBy(MochiSpacing.sm)) {
        themes.forEach { theme ->
            KeyboardPreviewCard(theme = theme, onTap = { onThemeClick(theme) }, modifier = Modifier.weight(1f).fillMaxHeight())
        }
    }
}

/** Figma fits all 4 font cards fully on screen with no scrolling. Cards are a landscape rectangle
 * (~1.23:1 measured from docs/figma/13.png), not the near-square shape weight-based height gave
 * them — fixed aspectRatio here instead, so the row is intrinsic-height like ActionCards. */
@Composable
private fun FontsRow(fonts: List<FontItem>, modifier: Modifier = Modifier) {
    Row(modifier = modifier.fillMaxWidth(), horizontalArrangement = Arrangement.spacedBy(MochiSpacing.sm)) {
        fonts.forEach { font ->
            FontArtCard(
                assetName = font.previewAssetName,
                modifier = Modifier.weight(1f).aspectRatio(1.23f)
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
    HomeScreen()
}
