package com.mochi.app.features.profile

import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
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
import androidx.compose.material.icons.filled.Check
import androidx.compose.material.icons.filled.Download
import androidx.compose.material.icons.filled.Edit
import androidx.compose.material.icons.filled.Favorite
import androidx.compose.material.icons.filled.Group
import androidx.compose.material.icons.filled.MoreVert
import androidx.compose.material.icons.filled.PhotoCamera
import androidx.compose.material.icons.filled.Settings
import androidx.compose.material.icons.filled.Verified
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
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.mochi.app.R
import com.mochi.app.components.FontArtCard
import com.mochi.app.components.ThemeArt
import com.mochi.app.designsystem.MochiColor
import com.mochi.app.designsystem.MochiFont
import com.mochi.app.designsystem.MochiGradient
import com.mochi.app.designsystem.MochiRadius
import com.mochi.app.designsystem.MochiSpacing
import com.mochi.app.mockdata.MockData
import com.mochi.app.model.KeyboardTheme

@Preview(showBackground = true, widthDp = 393, heightDp = 3000)
@Composable
private fun ProfileScreenPreview() {
    ProfileScreen()
}

private data class CreationItem(val name: String, val label: String, val likeCount: String, val downloadCount: String, val assetName: String, val isFont: Boolean = false)

private val myCreations = listOf(
    CreationItem("Pastel Rainbow", "Theme", "12.5K", "3.4K", "theme_pastel_rainbow"),
    CreationItem("Forest Theme", "Theme", "908", "2.6K", "theme_forest"),
    CreationItem("Pastel Pink Sky", "Theme", "12.5K", "3.1K", "theme_pastel_pink_sky"),
    CreationItem("Typewriter Classic", "Font", "755", "1.8K", "font_shop_typewriter_classic", isFont = true)
)

private val myDownloads = listOf(
    KeyboardTheme("fantasy-castle-night", "Fantasy Castle Night", "", "theme_fantasy_castle_night", 825, true, emptyList()),
    KeyboardTheme("forest-theme-dl", "Forest Theme", "", "theme_forest", 500, false, emptyList()),
    KeyboardTheme("kawaii-boba-tea-dl", "kawaii boba tea", "", "theme_kawaii_boba", 10_000, true, emptyList()),
    KeyboardTheme("cozy-sakura-cafe-dl", "Cozy Sakura Café", "", "theme_cozy_sakura_cafe", 12_500, true, emptyList())
)

private data class LikedThemeRow(val name: String, val creatorName: String, val likeCount: String, val assetName: String)

private val likedThemes = listOf(
    LikedThemeRow("Pastel Pink Sky", "Vibe Studio", "2.1K", "theme_pastel_pink_sky"),
    LikedThemeRow("Pastel Dream", "Dreamy Designs", "1.6K", ""),
    LikedThemeRow("Pastel Rainbow", "Clean Keys", "2.3K", "theme_pastel_rainbow")
)

/** Ported from docs/figma/3.png */
@Composable
fun ProfileScreen(
    modifier: Modifier = Modifier,
    onBack: () -> Unit = {},
    onSettingsClick: () -> Unit = {},
    onPaywallClick: () -> Unit = {}
) {
    var downloadsTab by remember { mutableStateOf("Theme") }

    Box(modifier = modifier.fillMaxSize().background(MochiGradient.background)) {
        Column(
            modifier = Modifier
                .fillMaxSize()
                .verticalScroll(rememberScrollState())
                .padding(horizontal = MochiSpacing.md)
                .padding(top = MochiSpacing.md, bottom = 100.dp),
            verticalArrangement = Arrangement.spacedBy(MochiSpacing.lg)
        ) {
            TopBar(onBack, onSettingsClick)
            ProfileHeader()
            PremiumBanner(title = "Mochi Pro", subtitle = "You're on Premium Plan  Enjoy all premium features and unlimited creations.", buttonTitle = "Upgrade Plan", onClick = onPaywallClick)
            MyCreationsSection()
            MyDownloadsSection(downloadsTab) { downloadsTab = it }
            Row(horizontalArrangement = Arrangement.spacedBy(MochiSpacing.sm)) {
                LikedThemesCard(modifier = Modifier.weight(1f))
                FollowStatsCard(modifier = Modifier.weight(1f))
            }
            PremiumBanner(title = "Go Premium", subtitle = "Unlock all premium themes, fonts, and features.", buttonTitle = "Upgrade Plan", onClick = onPaywallClick)
        }
    }
}

@Composable
private fun TopBar(onBack: () -> Unit, onSettingsClick: () -> Unit) {
    Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceBetween) {
        Box(
            modifier = Modifier.size(44.dp).clip(CircleShape).background(MochiGradient.primaryButton).clickable(onClick = onBack),
            contentAlignment = Alignment.Center
        ) {
            Icon(imageVector = Icons.AutoMirrored.Filled.ArrowBack, contentDescription = "Back", tint = Color.White)
        }
        Box(
            modifier = Modifier.size(44.dp).clip(CircleShape).background(Color.White).clickable(onClick = onSettingsClick),
            contentAlignment = Alignment.Center
        ) {
            Icon(imageVector = Icons.Filled.Settings, contentDescription = "Settings", tint = MochiColor.purple)
        }
    }
}

@Composable
private fun ProfileHeader() {
    Row(verticalAlignment = Alignment.Top, horizontalArrangement = Arrangement.spacedBy(MochiSpacing.md)) {
        Box {
            Image(
                painter = painterResource(R.drawable.avatar_header_user),
                contentDescription = "Mochi Creator",
                modifier = Modifier.size(96.dp).clip(CircleShape).border(3.dp, Color.White, CircleShape)
            )
            Box(
                modifier = Modifier
                    .align(Alignment.BottomEnd)
                    .size(28.dp)
                    .clip(CircleShape)
                    .background(MochiColor.purple)
                    .border(2.dp, Color.White, CircleShape),
                contentAlignment = Alignment.Center
            ) {
                Icon(imageVector = Icons.Filled.PhotoCamera, contentDescription = "Change photo", tint = Color.White, modifier = Modifier.size(14.dp))
            }
        }
        Column(modifier = Modifier.weight(1f), verticalArrangement = Arrangement.spacedBy(2.dp)) {
            Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(6.dp)) {
                Text(text = "Mochi Creator", style = MochiFont.title(22.sp), color = MochiColor.textPrimary)
                Icon(imageVector = Icons.Filled.Verified, contentDescription = "Verified", tint = MochiColor.purple, modifier = Modifier.size(18.dp))
            }
            Text(text = "@mochicreator", style = MochiFont.body(13.sp), color = MochiColor.purple)
            Text(text = "Creating cute & colorful keyboard themes to make typing more fun!", style = MochiFont.caption(12.sp), color = MochiColor.textSecondary)
            Spacer(modifier = Modifier.height(4.dp))
            Row(horizontalArrangement = Arrangement.spacedBy(MochiSpacing.md)) {
                StatColumn("128", "Creations")
                StatColumn("2.4K", "Followers")
                StatColumn("156", "Following")
            }
        }
    }
    Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.End) {
        Row(
            modifier = Modifier
                .clip(RoundedCornerShape(MochiRadius.pill))
                .border(1.dp, MochiColor.purple.copy(alpha = 0.3f), RoundedCornerShape(MochiRadius.pill))
                .padding(horizontal = 16.dp, vertical = 10.dp),
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.spacedBy(6.dp)
        ) {
            Icon(imageVector = Icons.Filled.Edit, contentDescription = null, tint = MochiColor.purple, modifier = Modifier.size(14.dp))
            Text(text = "Edit Profile", style = MochiFont.caption(13.sp), color = MochiColor.purple)
        }
    }
}

@Composable
private fun StatColumn(value: String, label: String) {
    Column {
        Text(text = value, style = MochiFont.heading(16.sp), color = MochiColor.textPrimary)
        Text(text = label, style = MochiFont.caption(10.sp), color = MochiColor.textSecondary)
    }
}

@Composable
private fun PremiumBanner(title: String, subtitle: String, buttonTitle: String, onClick: () -> Unit = {}) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .clip(RoundedCornerShape(MochiRadius.card))
            .background(Color.White)
            .padding(MochiSpacing.md),
        verticalAlignment = Alignment.CenterVertically
    ) {
        Image(
            painter = painterResource(R.drawable.icon_premium_crown),
            contentDescription = null,
            modifier = Modifier.size(56.dp).clip(CircleShape)
        )
        Column(modifier = Modifier.weight(1f).padding(horizontal = MochiSpacing.sm)) {
            Text(text = title, style = MochiFont.title(18.sp), color = MochiColor.purple)
            Text(text = subtitle, style = MochiFont.caption(11.sp), color = MochiColor.textSecondary)
        }
        Row(
            modifier = Modifier
                .clip(RoundedCornerShape(MochiRadius.pill))
                .background(MochiGradient.primaryButton)
                .clickable(onClick = onClick)
                .padding(horizontal = 14.dp, vertical = 10.dp),
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.spacedBy(4.dp)
        ) {
            Text(text = "👑", style = MochiFont.caption(12.sp))
            Text(text = buttonTitle, style = MochiFont.caption(12.sp), color = Color.White)
        }
    }
}

@Composable
private fun MyCreationsSection() {
    Column(verticalArrangement = Arrangement.spacedBy(MochiSpacing.sm)) {
        Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceBetween) {
            Text(text = "MY CREATIONS", style = MochiFont.heading(13.sp), color = MochiColor.textPrimary)
            Text(text = "see all", style = MochiFont.caption(13.sp), color = MochiColor.textPrimary)
        }
        Column(verticalArrangement = Arrangement.spacedBy(MochiSpacing.md)) {
            myCreations.chunked(2).forEach { row ->
                Row(horizontalArrangement = Arrangement.spacedBy(MochiSpacing.md)) {
                    row.forEach { item -> CreationCard(item, Modifier.weight(1f)) }
                    repeat(2 - row.size) { Spacer(modifier = Modifier.weight(1f)) }
                }
            }
        }
    }
}

@Composable
private fun CreationCard(item: CreationItem, modifier: Modifier = Modifier) {
    Column(
        modifier = modifier.clip(RoundedCornerShape(MochiRadius.card)).background(Color.White),
        verticalArrangement = Arrangement.spacedBy(4.dp)
    ) {
        Box {
            if (item.isFont) {
                FontArtCard(assetName = item.assetName, modifier = Modifier.fillMaxWidth().aspectRatio(1f)) {
                    Box(modifier = Modifier.fillMaxWidth().aspectRatio(1f).background(Color(0xFFE8F2FC)))
                }
            } else {
                ThemeArt(assetName = item.assetName, seed = item.name, modifier = Modifier.fillMaxWidth().aspectRatio(1f))
            }
            Icon(
                imageVector = Icons.Filled.MoreVert,
                contentDescription = null,
                tint = Color.White,
                modifier = Modifier
                    .align(Alignment.TopEnd)
                    .padding(6.dp)
                    .clip(CircleShape)
                    .background(Color.Black.copy(alpha = 0.3f))
                    .size(22.dp)
            )
        }
        Column(modifier = Modifier.padding(horizontal = 8.dp, vertical = 4.dp), verticalArrangement = Arrangement.spacedBy(2.dp)) {
            Text(text = item.name, style = MochiFont.heading(12.sp), color = MochiColor.textPrimary, maxLines = 1, overflow = TextOverflow.Ellipsis)
            Text(text = item.label, style = MochiFont.caption(11.sp), color = MochiColor.purple)
            Row(modifier = Modifier.fillMaxWidth(), verticalAlignment = Alignment.CenterVertically) {
                Icon(imageVector = Icons.Filled.Favorite, contentDescription = null, tint = MochiColor.pink, modifier = Modifier.size(10.dp))
                Spacer(modifier = Modifier.width(3.dp))
                Text(text = item.likeCount, style = MochiFont.caption(10.sp), color = MochiColor.textSecondary, modifier = Modifier.weight(1f))
                Icon(imageVector = Icons.Filled.Download, contentDescription = null, tint = MochiColor.textSecondary, modifier = Modifier.size(11.dp))
                Spacer(modifier = Modifier.width(2.dp))
                Text(text = item.downloadCount, style = MochiFont.caption(10.sp), color = MochiColor.textSecondary)
            }
        }
    }
}

@Composable
private fun MyDownloadsSection(selected: String, onSelect: (String) -> Unit) {
    Column(verticalArrangement = Arrangement.spacedBy(MochiSpacing.sm)) {
        Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(MochiSpacing.sm)) {
            Text(text = "MY DOWNLOADS", style = MochiFont.heading(13.sp), color = MochiColor.textPrimary)
            Spacer(modifier = Modifier.weight(1f))
            listOf("Theme", "Font").forEach { tab ->
                val isSelected = tab == selected
                Box(
                    modifier = Modifier
                        .clip(RoundedCornerShape(MochiRadius.pill))
                        .then(
                            if (isSelected) Modifier.background(MochiGradient.primaryButton)
                            else Modifier.background(Color.White).border(1.dp, MochiColor.purple.copy(alpha = 0.3f), RoundedCornerShape(MochiRadius.pill))
                        )
                        .clickable { onSelect(tab) }
                        .padding(horizontal = 14.dp, vertical = 8.dp)
                ) {
                    Text(text = tab, style = MochiFont.caption(12.sp), color = if (isSelected) Color.White else MochiColor.purple)
                }
            }
        }
        Row(horizontalArrangement = Arrangement.spacedBy(MochiSpacing.md)) {
            myDownloads.forEach { theme ->
                Column(
                    modifier = Modifier.weight(1f).clip(RoundedCornerShape(MochiRadius.card)).background(Color.White),
                    verticalArrangement = Arrangement.spacedBy(4.dp)
                ) {
                    Box {
                        ThemeArt(assetName = theme.imageAssetName, seed = theme.id, modifier = Modifier.fillMaxWidth().aspectRatio(1f))
                        Box(
                            modifier = Modifier
                                .align(Alignment.TopEnd)
                                .padding(6.dp)
                                .size(20.dp)
                                .clip(CircleShape)
                                .background(Color.White),
                            contentAlignment = Alignment.Center
                        ) {
                            Icon(imageVector = Icons.Filled.Check, contentDescription = null, tint = MochiColor.purple, modifier = Modifier.size(12.dp))
                        }
                    }
                    Row(modifier = Modifier.padding(horizontal = 6.dp, vertical = 4.dp), verticalAlignment = Alignment.CenterVertically) {
                        Text(text = theme.name, style = MochiFont.caption(10.sp), color = MochiColor.textPrimary, maxLines = 1, overflow = TextOverflow.Ellipsis, modifier = Modifier.weight(1f))
                        Icon(imageVector = Icons.Filled.Favorite, contentDescription = null, tint = MochiColor.pink, modifier = Modifier.size(9.dp))
                        Spacer(modifier = Modifier.width(2.dp))
                        Text(text = theme.likeCountFormatted, style = MochiFont.caption(9.sp), color = MochiColor.textSecondary)
                    }
                }
            }
        }
    }
}

@Composable
private fun LikedThemesCard(modifier: Modifier = Modifier) {
    Column(
        modifier = modifier.clip(RoundedCornerShape(MochiRadius.card)).background(Color.White).padding(MochiSpacing.sm),
        verticalArrangement = Arrangement.spacedBy(MochiSpacing.sm)
    ) {
        Row(modifier = Modifier.fillMaxWidth(), verticalAlignment = Alignment.CenterVertically) {
            Icon(imageVector = Icons.Filled.Favorite, contentDescription = null, tint = MochiColor.pink, modifier = Modifier.size(14.dp))
            Text(text = " Liked Themes", style = MochiFont.heading(12.sp), color = MochiColor.textPrimary, modifier = Modifier.weight(1f))
            Text(text = "See all", style = MochiFont.caption(11.sp), color = MochiColor.purple)
        }
        likedThemes.forEach { theme ->
            Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                ThemeArt(assetName = theme.assetName, seed = theme.name, modifier = Modifier.size(36.dp))
                Column(modifier = Modifier.weight(1f)) {
                    Text(text = theme.name, style = MochiFont.caption(11.sp), color = MochiColor.textPrimary, maxLines = 1)
                    Text(text = "by ${theme.creatorName}", style = MochiFont.caption(9.sp), color = MochiColor.textSecondary)
                }
                Row(verticalAlignment = Alignment.CenterVertically) {
                    Icon(imageVector = Icons.Filled.Favorite, contentDescription = null, tint = MochiColor.pink, modifier = Modifier.size(9.dp))
                    Text(text = theme.likeCount, style = MochiFont.caption(10.sp), color = MochiColor.textSecondary)
                }
            }
        }
    }
}

@Composable
private fun FollowStatsCard(modifier: Modifier = Modifier) {
    Column(
        modifier = modifier.clip(RoundedCornerShape(MochiRadius.card)).background(Color.White).padding(MochiSpacing.sm),
        verticalArrangement = Arrangement.spacedBy(MochiSpacing.md)
    ) {
        Row(modifier = Modifier.fillMaxWidth(), verticalAlignment = Alignment.CenterVertically) {
            Icon(imageVector = Icons.Filled.Favorite, contentDescription = null, tint = MochiColor.pink, modifier = Modifier.size(14.dp))
            Text(text = " Social", style = MochiFont.heading(12.sp), color = MochiColor.textPrimary, modifier = Modifier.weight(1f))
            Text(text = "See all", style = MochiFont.caption(11.sp), color = MochiColor.purple)
        }
        SocialStatRow("Followers", "2.1K")
        SocialStatRow("Following", "126")
    }
}

@Composable
private fun SocialStatRow(label: String, value: String) {
    Row(modifier = Modifier.fillMaxWidth(), verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(8.dp)) {
        Box(
            modifier = Modifier.size(32.dp).clip(RoundedCornerShape(8.dp)).background(MochiColor.purple),
            contentAlignment = Alignment.Center
        ) {
            Icon(imageVector = Icons.Filled.Group, contentDescription = null, tint = Color.White, modifier = Modifier.size(16.dp))
        }
        Text(text = label, style = MochiFont.body(12.sp), color = MochiColor.textPrimary, modifier = Modifier.weight(1f))
        Text(text = value, style = MochiFont.heading(12.sp), color = MochiColor.textPrimary)
    }
}
