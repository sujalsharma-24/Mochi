package com.mochi.app.features.community

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
import androidx.compose.material.icons.filled.Download
import androidx.compose.material.icons.filled.Favorite
import androidx.compose.material.icons.filled.MoreVert
import androidx.compose.material.icons.filled.Search
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
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.mochi.app.R
import com.mochi.app.components.CreatorAvatar
import com.mochi.app.components.GradientButton
import com.mochi.app.components.ThemeArt
import com.mochi.app.designsystem.MochiColor
import com.mochi.app.designsystem.MochiFont
import com.mochi.app.designsystem.MochiGradient
import com.mochi.app.designsystem.MochiRadius
import com.mochi.app.designsystem.MochiSpacing
import com.mochi.app.mockdata.MockData
import com.mochi.app.model.Creator
import com.mochi.app.model.KeyboardTheme

@Preview(showBackground = true, widthDp = 393, heightDp = 2200)
@Composable
private fun CommunityScreenPreview() {
    CommunityScreen()
}

private val feedTabs = listOf("For you", "Popular", "Latest", "Following", "My Likes")
private val medalColors = listOf(Color(0xFFDDA935), Color(0xFFB8B8C8), Color(0xFFB0793F))

/** Ported from docs/figma/2.png */
@Composable
fun CommunityScreen(
    modifier: Modifier = Modifier,
    onProfileClick: () -> Unit = {},
    onSearchClick: () -> Unit = {},
    onThemeClick: (KeyboardTheme) -> Unit = {},
    onLeaderboardClick: () -> Unit = {}
) {
    var selectedFeed by remember { mutableStateOf("For you") }

    Box(modifier = modifier.fillMaxSize().background(MochiGradient.background)) {
        Column(
            modifier = Modifier
                .fillMaxSize()
                .verticalScroll(rememberScrollState())
                .padding(horizontal = MochiSpacing.md)
                .padding(top = MochiSpacing.md, bottom = 100.dp),
            verticalArrangement = Arrangement.spacedBy(MochiSpacing.lg)
        ) {
            CommunityHeader(onProfileClick)
            SearchBar(onSearchClick)
            FeedTabs(selectedFeed) { selectedFeed = it }
            TopThemesSection(onThemeClick)
            PopularCreatorsSection(onLeaderboardClick)
            LatestCreationsSection(onThemeClick)
        }
    }
}

@Composable
private fun CommunityHeader(onProfileClick: () -> Unit) {
    Row(modifier = Modifier.fillMaxWidth(), verticalAlignment = Alignment.CenterVertically) {
        Text(text = "Mochi", style = MochiFont.logo(38.sp), color = MochiColor.logoSolid)
        Spacer(modifier = Modifier.weight(1f))
        Image(
            painter = painterResource(R.drawable.avatar_header_user),
            contentDescription = "Profile",
            modifier = Modifier.size(52.dp).clip(CircleShape).clickable(onClick = onProfileClick)
        )
    }
}

@Composable
private fun SearchBar(onSearchClick: () -> Unit) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .clip(RoundedCornerShape(MochiRadius.pill))
            .background(Color.White)
            .clickable(onClick = onSearchClick)
            .padding(horizontal = MochiSpacing.md, vertical = 14.dp),
        verticalAlignment = Alignment.CenterVertically
    ) {
        Text(
            text = "Search themes, creators..",
            style = MochiFont.body(14.sp),
            color = MochiColor.textSecondary,
            modifier = Modifier.weight(1f)
        )
        Icon(imageVector = Icons.Filled.Search, contentDescription = "Search", tint = MochiColor.textPrimary)
    }
}

@Composable
private fun FeedTabs(selected: String, onSelect: (String) -> Unit) {
    Row(
        modifier = Modifier.horizontalScroll(rememberScrollState()),
        horizontalArrangement = Arrangement.spacedBy(MochiSpacing.sm)
    ) {
        feedTabs.forEach { tab ->
            val isSelected = tab == selected
            Box(
                modifier = Modifier
                    .clip(RoundedCornerShape(MochiRadius.pill))
                    .then(
                        if (isSelected) Modifier.background(MochiGradient.primaryButton)
                        else Modifier.background(Color.White).border(1.dp, MochiColor.purple.copy(alpha = 0.2f), RoundedCornerShape(MochiRadius.pill))
                    )
                    .clickable { onSelect(tab) }
                    .padding(horizontal = 18.dp, vertical = 12.dp)
            ) {
                Text(text = tab, style = MochiFont.heading(14.sp), color = MochiColor.textPrimary)
            }
        }
    }
}

@Composable
private fun TopThemesSection(onThemeClick: (KeyboardTheme) -> Unit) {
    Column(verticalArrangement = Arrangement.spacedBy(MochiSpacing.sm)) {
        Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceBetween) {
            Text(text = "TOP THEMES", style = MochiFont.heading(13.sp), color = MochiColor.textPrimary)
            Text(text = "see all", style = MochiFont.caption(13.sp), color = MochiColor.textPrimary)
        }
        Row(horizontalArrangement = Arrangement.spacedBy(MochiSpacing.md)) {
            MockData.topRankedThemes.forEachIndexed { index, theme ->
                TopThemeCard(theme, index + 1, Modifier.weight(1f)) { onThemeClick(theme) }
            }
        }
    }
}

@Composable
private fun TopThemeCard(theme: KeyboardTheme, rank: Int, modifier: Modifier = Modifier, onClick: () -> Unit = {}) {
    Column(
        modifier = modifier.clip(RoundedCornerShape(MochiRadius.card)).background(Color.White).clickable(onClick = onClick),
        verticalArrangement = Arrangement.spacedBy(4.dp)
    ) {
        Box {
            ThemeArt(assetName = theme.imageAssetName, seed = theme.id, modifier = Modifier.fillMaxWidth().aspectRatio(0.95f))
            Box(
                modifier = Modifier
                    .align(Alignment.TopStart)
                    .padding(6.dp)
                    .size(22.dp)
                    .clip(CircleShape)
                    .background(medalColors[(rank - 1).coerceIn(0, 2)]),
                contentAlignment = Alignment.Center
            ) {
                Text(text = rank.toString(), style = MochiFont.heading(11.sp), color = Color.White)
            }
        }
        Column(modifier = Modifier.padding(horizontal = 8.dp, vertical = 4.dp), verticalArrangement = Arrangement.spacedBy(2.dp)) {
            Text(text = theme.name, style = MochiFont.heading(12.sp), color = MochiColor.textPrimary, maxLines = 1)
            Text(text = "by ${theme.creatorName}", style = MochiFont.caption(10.sp), color = MochiColor.purple, maxLines = 1)
            Row(modifier = Modifier.fillMaxWidth(), verticalAlignment = Alignment.CenterVertically) {
                Icon(imageVector = Icons.Filled.Favorite, contentDescription = null, tint = MochiColor.pink, modifier = Modifier.size(10.dp))
                Spacer(modifier = Modifier.width(3.dp))
                Text(text = theme.likeCountFormatted, style = MochiFont.caption(10.sp), color = MochiColor.textSecondary, modifier = Modifier.weight(1f))
                Box(
                    modifier = Modifier.size(20.dp).clip(CircleShape).border(1.dp, MochiColor.purple.copy(alpha = 0.3f), CircleShape),
                    contentAlignment = Alignment.Center
                ) {
                    Icon(imageVector = Icons.Filled.Download, contentDescription = null, tint = MochiColor.purple, modifier = Modifier.size(11.dp))
                }
            }
            Spacer(modifier = Modifier.height(2.dp))
        }
    }
}

@Composable
private fun PopularCreatorsSection(onSeeAllClick: () -> Unit) {
    Column(verticalArrangement = Arrangement.spacedBy(MochiSpacing.sm)) {
        Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceBetween) {
            Text(text = "POPULAR CREATORS", style = MochiFont.heading(13.sp), color = MochiColor.textPrimary)
            Text(text = "see all", style = MochiFont.caption(13.sp), color = MochiColor.textPrimary, modifier = Modifier.clickable(onClick = onSeeAllClick))
        }
        Row(
            modifier = Modifier.horizontalScroll(rememberScrollState()),
            horizontalArrangement = Arrangement.spacedBy(MochiSpacing.sm)
        ) {
            MockData.topCreators.forEach { creator ->
                CreatorCard(creator)
            }
        }
    }
}

@Composable
private fun CreatorCard(creator: Creator) {
    Column(
        modifier = Modifier
            .width(150.dp)
            .clip(RoundedCornerShape(MochiRadius.card))
            .background(Color.White)
            .padding(MochiSpacing.sm),
        verticalArrangement = Arrangement.spacedBy(6.dp)
    ) {
        Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(8.dp)) {
            CreatorAvatar(assetName = creator.avatarAssetName, modifier = Modifier.size(44.dp).clip(CircleShape))
            Column {
                Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(2.dp)) {
                    Text(text = creator.displayName, style = MochiFont.heading(12.sp), color = MochiColor.textPrimary, maxLines = 1)
                    Icon(imageVector = Icons.Filled.Verified, contentDescription = "Verified", tint = MochiColor.purple, modifier = Modifier.size(12.dp))
                }
                Text(text = "${creator.themeCount} Themes", style = MochiFont.caption(10.sp), color = MochiColor.textSecondary)
            }
        }
        GradientButton(title = "Follow", modifier = Modifier.height(32.dp)) {}
    }
}

@Composable
private fun LatestCreationsSection(onThemeClick: (KeyboardTheme) -> Unit) {
    Column(verticalArrangement = Arrangement.spacedBy(MochiSpacing.sm)) {
        Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceBetween) {
            Text(text = "LATEST CREATIONS", style = MochiFont.heading(13.sp), color = MochiColor.textPrimary)
            Text(text = "see all", style = MochiFont.caption(13.sp), color = MochiColor.textPrimary)
        }
        Column(verticalArrangement = Arrangement.spacedBy(MochiSpacing.md)) {
            MockData.latestCreations.forEach { theme ->
                LatestCreationCard(theme) { onThemeClick(theme) }
            }
        }
    }
}

@Composable
private fun LatestCreationCard(theme: KeyboardTheme, onClick: () -> Unit = {}) {
    Column(
        modifier = Modifier
            .fillMaxWidth()
            .clip(RoundedCornerShape(MochiRadius.card))
            .background(Color.White)
            .clickable(onClick = onClick)
            .padding(MochiSpacing.sm),
        verticalArrangement = Arrangement.spacedBy(MochiSpacing.xs)
    ) {
        Row(horizontalArrangement = Arrangement.spacedBy(MochiSpacing.sm)) {
            ThemeArt(assetName = theme.imageAssetName, seed = theme.id, modifier = Modifier.width(140.dp).aspectRatio(1.35f))
            Column(modifier = Modifier.weight(1f), verticalArrangement = Arrangement.spacedBy(2.dp)) {
                Text(text = theme.name, style = MochiFont.heading(15.sp), color = MochiColor.textPrimary)
                Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(2.dp)) {
                    Text(text = "By ${theme.creatorName}", style = MochiFont.caption(11.sp), color = MochiColor.textSecondary)
                    Icon(imageVector = Icons.Filled.Verified, contentDescription = null, tint = MochiColor.purple, modifier = Modifier.size(11.dp))
                }
                Spacer(modifier = Modifier.height(2.dp))
                Text(text = theme.description, style = MochiFont.caption(10.sp), color = MochiColor.textSecondary, maxLines = 2)
                Spacer(modifier = Modifier.weight(1f))
                Row(verticalAlignment = Alignment.CenterVertically) {
                    Icon(imageVector = Icons.Filled.Favorite, contentDescription = null, tint = MochiColor.pink, modifier = Modifier.size(12.dp))
                    Spacer(modifier = Modifier.width(4.dp))
                    Text(text = theme.likeCountFormatted, style = MochiFont.caption(11.sp), color = MochiColor.textSecondary, modifier = Modifier.weight(1f))
                    Box(
                        modifier = Modifier.size(24.dp).clip(CircleShape).border(1.dp, MochiColor.purple.copy(alpha = 0.3f), CircleShape),
                        contentAlignment = Alignment.Center
                    ) {
                        Icon(imageVector = Icons.Filled.Download, contentDescription = null, tint = MochiColor.purple, modifier = Modifier.size(13.dp))
                    }
                    Spacer(modifier = Modifier.width(6.dp))
                    Icon(imageVector = Icons.Filled.MoreVert, contentDescription = null, tint = MochiColor.textSecondary, modifier = Modifier.size(18.dp))
                }
            }
        }
        Row(horizontalArrangement = Arrangement.spacedBy(6.dp)) {
            theme.hashtags.forEach { tag ->
                Text(text = "#$tag", style = MochiFont.caption(10.sp), color = MochiColor.purple)
            }
        }
    }
}
