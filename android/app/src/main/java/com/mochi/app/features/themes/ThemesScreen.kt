package com.mochi.app.features.themes

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.horizontalScroll
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.aspectRatio
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material.icons.filled.Download
import androidx.compose.material.icons.filled.Favorite
import androidx.compose.material.icons.filled.MoreVert
import androidx.compose.material.icons.filled.Search
import androidx.compose.material.icons.filled.Tune
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
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.mochi.app.components.GradientButton
import com.mochi.app.components.ThemeArt
import com.mochi.app.designsystem.MochiColor
import com.mochi.app.designsystem.MochiFont
import com.mochi.app.designsystem.MochiGradient
import com.mochi.app.designsystem.MochiRadius
import com.mochi.app.designsystem.MochiSpacing
import com.mochi.app.mockdata.MockData
import com.mochi.app.model.KeyboardTheme

@Preview(showBackground = true, widthDp = 393, heightDp = 2100)
@Composable
private fun ThemesScreenPreview() {
    ThemesScreen()
}

private val categories = listOf("All", "Cute", "Handwritten", "Minimal", "Bold", "Elegant", "Other")

/** Ported from docs/figma/8.png */
@Composable
fun ThemesScreen(
    modifier: Modifier = Modifier,
    onSearchClick: () -> Unit = {},
    onWallpapersClick: () -> Unit = {}
) {
    var selectedCategory by remember { mutableStateOf("All") }
    var modalTheme by remember { mutableStateOf<KeyboardTheme?>(null) }

    Box(modifier = modifier.fillMaxSize().background(MochiGradient.background)) {
        Column(
            modifier = Modifier
                .fillMaxSize()
                .verticalScroll(rememberScrollState())
                .padding(horizontal = MochiSpacing.md)
                .padding(top = MochiSpacing.md, bottom = 100.dp),
            verticalArrangement = Arrangement.spacedBy(MochiSpacing.lg)
        ) {
            ThemesHeader(onSearchClick)
            CategoryChips(selectedCategory) { selectedCategory = it }
            FilterRow()
            ThemeShopGrid { modalTheme = it }
            LiveWallpapersBanner(onWallpapersClick)
            DownloadedThemesRow()
        }

        modalTheme?.let { theme ->
            ApplyThemeModal(theme, onDismiss = { modalTheme = null })
        }
    }
}

@Composable
private fun ThemesHeader(onSearchClick: () -> Unit) {
    Row(modifier = Modifier.fillMaxWidth(), verticalAlignment = Alignment.CenterVertically) {
        CircleIconButton(icon = Icons.AutoMirrored.Filled.ArrowBack)
        Column(modifier = Modifier.weight(1f).padding(horizontal = MochiSpacing.sm), horizontalAlignment = Alignment.CenterHorizontally) {
            Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(6.dp)) {
                Box(
                    modifier = Modifier.size(22.dp).clip(RoundedCornerShape(6.dp)).background(MochiColor.purple),
                    contentAlignment = Alignment.Center
                ) {
                    Icon(imageVector = com.mochi.app.ui.MochiTab.THEMES.icon, contentDescription = null, tint = Color.White, modifier = Modifier.size(14.dp))
                }
                Text(text = "Themes", style = MochiFont.title(26.sp), color = MochiColor.purple)
            }
            Text(text = "Browse and apply beautiful themes", style = MochiFont.caption(12.sp), color = MochiColor.textSecondary)
        }
        CircleIconButton(icon = Icons.Filled.Search, onClick = onSearchClick)
    }
}

@Composable
private fun CircleIconButton(icon: ImageVector, onClick: () -> Unit = {}) {
    Box(
        modifier = Modifier.size(44.dp).clip(CircleShape).background(MochiGradient.primaryButton).clickable(onClick = onClick),
        contentAlignment = Alignment.Center
    ) {
        Icon(imageVector = icon, contentDescription = null, tint = Color.White)
    }
}

@Composable
private fun LiveWallpapersBanner(onClick: () -> Unit) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .clip(RoundedCornerShape(MochiRadius.card))
            .background(Color.White)
            .clickable(onClick = onClick)
            .padding(MochiSpacing.md),
        verticalAlignment = Alignment.CenterVertically
    ) {
        Box(
            modifier = Modifier.size(44.dp).clip(RoundedCornerShape(12.dp)).background(MochiGradient.primaryButton),
            contentAlignment = Alignment.Center
        ) {
            Text(text = "🌌", style = MochiFont.heading(18.sp))
        }
        Column(modifier = Modifier.weight(1f).padding(horizontal = MochiSpacing.sm)) {
            Text(text = "Live Wallpapers", style = MochiFont.heading(14.sp), color = MochiColor.purple)
            Text(text = "5 animated wallpapers · Premium", style = MochiFont.caption(11.sp), color = MochiColor.textSecondary)
        }
        Text(text = "›", style = MochiFont.heading(18.sp), color = MochiColor.purple)
    }
}

@Composable
private fun CategoryChips(selected: String, onSelect: (String) -> Unit) {
    Row(
        modifier = Modifier.horizontalScroll(rememberScrollState()),
        horizontalArrangement = Arrangement.spacedBy(MochiSpacing.sm)
    ) {
        categories.forEach { category ->
            val isSelected = category == selected
            Row(
                modifier = Modifier
                    .clip(RoundedCornerShape(MochiRadius.pill))
                    .then(
                        if (isSelected) Modifier.background(MochiGradient.primaryButton)
                        else Modifier.background(Color.White).border(1.dp, MochiColor.purple.copy(alpha = 0.25f), RoundedCornerShape(MochiRadius.pill))
                    )
                    .clickable { onSelect(category) }
                    .padding(horizontal = 16.dp, vertical = 10.dp)
            ) {
                Text(text = category, style = MochiFont.body(13.sp), color = MochiColor.textPrimary)
            }
        }
    }
}

@Composable
private fun FilterRow() {
    Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.End, verticalAlignment = Alignment.CenterVertically) {
        Row(
            modifier = Modifier
                .clip(RoundedCornerShape(MochiRadius.pill))
                .border(1.dp, MochiColor.purple.copy(alpha = 0.25f), RoundedCornerShape(MochiRadius.pill))
                .padding(horizontal = 14.dp, vertical = 8.dp)
        ) {
            Text(text = "Filter", style = MochiFont.caption(13.sp), color = MochiColor.textPrimary)
        }
        Spacer(modifier = Modifier.width(8.dp))
        Box(
            modifier = Modifier.size(36.dp).clip(CircleShape).border(1.dp, MochiColor.purple.copy(alpha = 0.25f), CircleShape),
            contentAlignment = Alignment.Center
        ) {
            Icon(imageVector = Icons.Filled.Tune, contentDescription = "Filter options", tint = MochiColor.textPrimary, modifier = Modifier.size(18.dp))
        }
    }
}

@Composable
private fun ThemeShopGrid(onSelect: (KeyboardTheme) -> Unit) {
    Column(verticalArrangement = Arrangement.spacedBy(MochiSpacing.md)) {
        MockData.shopThemes.chunked(3).forEach { row ->
            Row(horizontalArrangement = Arrangement.spacedBy(MochiSpacing.md)) {
                row.forEach { theme ->
                    ThemeShopCard(theme, Modifier.weight(1f)) { onSelect(theme) }
                }
                repeat(3 - row.size) { Spacer(modifier = Modifier.weight(1f)) }
            }
        }
    }
}

@Composable
private fun ThemeShopCard(theme: KeyboardTheme, modifier: Modifier = Modifier, onTap: () -> Unit) {
    Column(
        modifier = modifier
            .clip(RoundedCornerShape(MochiRadius.card))
            .background(Color.White)
            .clickable(onClick = onTap),
        verticalArrangement = Arrangement.spacedBy(6.dp)
    ) {
        Box {
            ThemeArt(assetName = theme.imageAssetName, seed = theme.id, modifier = Modifier.fillMaxWidth().aspectRatio(1f))
            Box(
                modifier = Modifier
                    .align(Alignment.TopEnd)
                    .padding(6.dp)
                    .size(22.dp)
                    .clip(CircleShape)
                    .background(Color.White),
                contentAlignment = Alignment.Center
            ) {
                Icon(imageVector = Icons.Filled.Download, contentDescription = null, tint = MochiColor.purple, modifier = Modifier.size(12.dp))
            }
        }
        Column(modifier = Modifier.padding(horizontal = 8.dp, vertical = 4.dp), verticalArrangement = Arrangement.spacedBy(2.dp)) {
            Text(text = theme.name, style = MochiFont.heading(12.sp), color = MochiColor.textPrimary, maxLines = 1)
            Text(text = "by ${theme.creatorName}", style = MochiFont.caption(10.sp), color = MochiColor.purple, maxLines = 1)
            Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(3.dp)) {
                Icon(imageVector = Icons.Filled.Favorite, contentDescription = null, tint = MochiColor.pink, modifier = Modifier.size(10.dp))
                Text(text = theme.likeCountFormatted, style = MochiFont.caption(10.sp), color = MochiColor.textSecondary)
            }
            Spacer(modifier = Modifier.height(2.dp))
            Row(horizontalArrangement = Arrangement.spacedBy(4.dp)) {
                SmallPillButton(title = "Preview", modifier = Modifier.weight(1f), filled = false) {}
                SmallPillButton(title = "Apply", modifier = Modifier.weight(1f), filled = true, onClick = onTap)
            }
        }
    }
}

@Composable
private fun SmallPillButton(title: String, modifier: Modifier = Modifier, filled: Boolean, onClick: () -> Unit) {
    Box(
        modifier = modifier
            .clip(RoundedCornerShape(MochiRadius.pill))
            .then(
                if (filled) Modifier.background(MochiGradient.primaryButton)
                else Modifier.background(Color.White).border(1.dp, MochiColor.purple.copy(alpha = 0.35f), RoundedCornerShape(MochiRadius.pill))
            )
            .clickable(onClick = onClick)
            .padding(vertical = 6.dp),
        contentAlignment = Alignment.Center
    ) {
        Text(text = title, style = MochiFont.caption(9.sp), color = MochiColor.textPrimary)
    }
}

@Composable
private fun DownloadedThemesRow() {
    Column(verticalArrangement = Arrangement.spacedBy(MochiSpacing.sm)) {
        Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceBetween) {
            Text(text = "MY DOWNLOADED THEMES", style = MochiFont.heading(13.sp), color = MochiColor.textPrimary)
            Text(text = "see all", style = MochiFont.caption(13.sp), color = MochiColor.textPrimary)
        }
        Row(
            modifier = Modifier.horizontalScroll(rememberScrollState()),
            horizontalArrangement = Arrangement.spacedBy(MochiSpacing.sm)
        ) {
            MockData.downloadedThemes.forEach { theme ->
                Column(
                    modifier = Modifier.width(150.dp).clip(RoundedCornerShape(MochiRadius.card)).background(Color.White),
                    verticalArrangement = Arrangement.spacedBy(4.dp)
                ) {
                    Box {
                        ThemeArt(assetName = theme.imageAssetName, seed = theme.id, modifier = Modifier.fillMaxWidth().aspectRatio(1.4f))
                        Icon(
                            imageVector = Icons.Filled.MoreVert,
                            contentDescription = null,
                            tint = Color.White,
                            modifier = Modifier
                                .align(Alignment.TopEnd)
                                .padding(4.dp)
                                .clip(CircleShape)
                                .background(Color.Black.copy(alpha = 0.3f))
                                .size(18.dp)
                        )
                    }
                    Text(
                        text = theme.name,
                        style = MochiFont.caption(11.sp),
                        color = MochiColor.textPrimary,
                        maxLines = 1,
                        textAlign = TextAlign.Start,
                        modifier = Modifier.padding(horizontal = 6.dp).padding(bottom = 6.dp)
                    )
                }
            }
        }
    }
}

@Composable
private fun ApplyThemeModal(theme: KeyboardTheme, onDismiss: () -> Unit) {
    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(Color.Black.copy(alpha = 0.4f))
            .clickable(onClick = onDismiss),
        contentAlignment = Alignment.Center
    ) {
        Column(
            modifier = Modifier
                .padding(horizontal = MochiSpacing.lg)
                .clip(RoundedCornerShape(MochiRadius.sheet))
                .background(Color.White)
                .clickable(enabled = false) {}
                .padding(MochiSpacing.md),
            verticalArrangement = Arrangement.spacedBy(MochiSpacing.sm)
        ) {
            Row(horizontalArrangement = Arrangement.spacedBy(MochiSpacing.md)) {
                ThemeArt(assetName = theme.imageAssetName, seed = theme.id, modifier = Modifier.size(90.dp))
                Column(verticalArrangement = Arrangement.spacedBy(2.dp)) {
                    Text(text = theme.name, style = MochiFont.heading(16.sp), color = MochiColor.textPrimary)
                    Text(text = "by ${theme.creatorName}", style = MochiFont.caption(12.sp), color = MochiColor.purple)
                    Spacer(modifier = Modifier.height(4.dp))
                    Text(text = "Apply this theme to your keyboard?", style = MochiFont.body(12.sp), color = MochiColor.textSecondary)
                }
            }
            Row(horizontalArrangement = Arrangement.spacedBy(6.dp)) {
                listOf("Beautiful Design", "Smooth Typing", "Lightweight").forEach { tag ->
                    Box(
                        modifier = Modifier
                            .clip(RoundedCornerShape(MochiRadius.pill))
                            .border(1.dp, MochiColor.purple.copy(alpha = 0.25f), RoundedCornerShape(MochiRadius.pill))
                            .padding(horizontal = 10.dp, vertical = 5.dp)
                    ) {
                        Text(text = tag, style = MochiFont.caption(9.sp), color = MochiColor.textPrimary)
                    }
                }
            }
            Row(horizontalArrangement = Arrangement.spacedBy(MochiSpacing.sm)) {
                SmallPillButton(title = "Preview", modifier = Modifier.weight(1f).height(40.dp), filled = false, onClick = onDismiss)
                Box(modifier = Modifier.weight(1f)) {
                    GradientButton(title = "Download & Apply", modifier = Modifier.height(40.dp), onClick = onDismiss)
                }
            }
        }
    }
}
