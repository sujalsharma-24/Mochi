package com.mochi.app.features.home

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.horizontalScroll
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Add
import androidx.compose.material.icons.filled.Palette
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
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.mochi.app.components.GradientButton
import com.mochi.app.components.KeyboardPreviewPlaceholder
import com.mochi.app.components.SectionHeader
import com.mochi.app.components.ThemeCard
import com.mochi.app.designsystem.MochiColor
import com.mochi.app.designsystem.MochiFont
import com.mochi.app.designsystem.MochiGradient
import com.mochi.app.designsystem.MochiRadius
import com.mochi.app.designsystem.MochiSpacing
import com.mochi.app.mockdata.MockData
import com.mochi.app.model.FontItem
import com.mochi.app.model.KeyboardTheme

private enum class LibraryTab { FONTS, THEMES }

/** Ported from ios/MochiApp/Features/Home/HomeView.swift */
@Composable
fun HomeScreen(modifier: Modifier = Modifier) {
    var libraryTab by remember { mutableStateOf(LibraryTab.THEMES) }

    Box(modifier = modifier.fillMaxSize().background(MochiGradient.background)) {
        Column(
            modifier = Modifier
                .fillMaxSize()
                .verticalScroll(rememberScrollState())
                .padding(horizontal = MochiSpacing.md)
                .padding(top = MochiSpacing.md, bottom = 90.dp),
            verticalArrangement = Arrangement.spacedBy(MochiSpacing.lg)
        ) {
            Header()
            RecentlyAppliedRow(MockData.popularThemes)
            QuickActionCards()
            LibraryToggle(libraryTab) { libraryTab = it }
            SectionHeader(title = "Popular Themes")
            ThemesRow(MockData.popularThemes)
            SectionHeader(title = "Font Collection")
            FontsRow(MockData.fonts)
        }
    }
}

@Composable
private fun Header() {
    Row(modifier = Modifier.fillMaxWidth(), verticalAlignment = Alignment.CenterVertically) {
        Text(text = "Mochi", style = MochiFont.logo(), color = MochiColor.purpleDark)
        Spacer(modifier = Modifier.weight(1f))
        Column(horizontalAlignment = Alignment.CenterHorizontally, verticalArrangement = Arrangement.spacedBy(4.dp)) {
            Box(
                modifier = Modifier
                    .size(44.dp)
                    .clip(CircleShape)
                    .background(MochiGradient.primaryButton),
                contentAlignment = Alignment.Center
            ) {
                Icon(imageVector = Icons.Filled.Add, contentDescription = "Create Custom", tint = Color.White)
            }
            Text(text = "Create Custom", style = MochiFont.caption(11.sp), color = MochiColor.textPrimary)
        }
    }
}

@Composable
private fun RecentlyAppliedRow(themes: List<KeyboardTheme>) {
    Row(
        modifier = Modifier.horizontalScroll(rememberScrollState()),
        horizontalArrangement = Arrangement.spacedBy(MochiSpacing.md)
    ) {
        themes.forEach { theme ->
            Column(
                horizontalAlignment = Alignment.CenterHorizontally,
                verticalArrangement = Arrangement.spacedBy(MochiSpacing.sm)
            ) {
                KeyboardPreviewPlaceholder(seed = theme.id, modifier = Modifier.size(width = 150.dp, height = 130.dp))
                Text(
                    text = theme.name,
                    style = MochiFont.body(13.sp),
                    color = MochiColor.textPrimary,
                    textAlign = TextAlign.Center,
                    modifier = Modifier.width(150.dp)
                )
            }
        }
    }
}

@Composable
private fun QuickActionCards() {
    Row(horizontalArrangement = Arrangement.spacedBy(MochiSpacing.md)) {
        ActionCard(
            title = "Custom Create",
            subtitle = "Design your own keyboard",
            buttonTitle = "Create",
            modifier = Modifier.weight(1f)
        )
        ActionCard(
            title = "Choose from Library",
            subtitle = "Pick a created keyboard",
            buttonTitle = "Choose",
            modifier = Modifier.weight(1f)
        )
    }
}

@Composable
private fun ActionCard(title: String, subtitle: String, buttonTitle: String, modifier: Modifier = Modifier) {
    Column(
        modifier = modifier
            .clip(RoundedCornerShape(MochiRadius.card))
            .background(Color.White)
            .padding(MochiSpacing.md),
        verticalArrangement = Arrangement.spacedBy(MochiSpacing.sm)
    ) {
        Icon(imageVector = Icons.Filled.Palette, contentDescription = null, tint = MochiColor.purple, modifier = Modifier.size(26.dp))
        Text(text = title, style = MochiFont.heading(15.sp), color = MochiColor.textPrimary)
        Text(text = subtitle, style = MochiFont.caption(12.sp), color = MochiColor.textSecondary)
        GradientButton(title = buttonTitle) {}
    }
}

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
        Modifier.background(Color.White, CircleShape)
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
            text = title,
            style = MochiFont.button(),
            color = if (isSelected) Color.White else MochiColor.textPrimary
        )
    }
}

@Composable
private fun ThemesRow(themes: List<KeyboardTheme>) {
    Row(
        modifier = Modifier.horizontalScroll(rememberScrollState()),
        horizontalArrangement = Arrangement.spacedBy(MochiSpacing.md)
    ) {
        themes.forEach { theme -> ThemeCard(theme = theme, modifier = Modifier.width(150.dp)) }
    }
}

@Composable
private fun FontsRow(fonts: List<FontItem>) {
    Row(
        modifier = Modifier.horizontalScroll(rememberScrollState()),
        horizontalArrangement = Arrangement.spacedBy(MochiSpacing.md)
    ) {
        fonts.forEach { font ->
            Column(
                modifier = Modifier
                    .size(width = 120.dp, height = 130.dp)
                    .clip(RoundedCornerShape(MochiRadius.card))
                    .background(Color.White)
                    .padding(6.dp),
                horizontalAlignment = Alignment.CenterHorizontally,
                verticalArrangement = Arrangement.spacedBy(6.dp)
            ) {
                Text(text = "Aa", style = MochiFont.logo(34.sp), color = MochiColor.purple)
                Text(text = font.name, style = MochiFont.heading(13.sp), color = MochiColor.textPrimary, textAlign = TextAlign.Center)
                Text(text = font.styleDescription, style = MochiFont.caption(11.sp), color = MochiColor.textSecondary, textAlign = TextAlign.Center)
            }
        }
    }
}

@Preview(showBackground = true, widthDp = 393, heightDp = 852)
@Composable
private fun HomeScreenPreview() {
    HomeScreen()
}
