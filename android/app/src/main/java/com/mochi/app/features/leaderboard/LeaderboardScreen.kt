package com.mochi.app.features.leaderboard

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
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material.icons.filled.EmojiEvents
import androidx.compose.material.icons.filled.Favorite
import androidx.compose.material.icons.filled.FilterList
import androidx.compose.material.icons.filled.Keyboard
import androidx.compose.material.icons.filled.Palette
import androidx.compose.material.icons.filled.PersonAdd
import androidx.compose.material.icons.filled.Search
import androidx.compose.material.icons.filled.Tune
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
import com.mochi.app.components.ThemeArt
import com.mochi.app.designsystem.MochiColor
import com.mochi.app.designsystem.MochiFont
import com.mochi.app.designsystem.MochiGradient
import com.mochi.app.designsystem.MochiRadius
import com.mochi.app.designsystem.MochiSpacing
import com.mochi.app.mockdata.MockData
import com.mochi.app.model.Creator

@Preview(showBackground = true, widthDp = 393, heightDp = 3300)
@Composable
private fun LeaderboardScreenPreview() {
    LeaderboardScreen()
}

private val periods = listOf("This Week", "This Month", "All Time")
private val medalColors = listOf(Color(0xFFDDA935), Color(0xFFB8B8C8), Color(0xFFB0793F))

/** Ported from docs/figma/9.png */
@Composable
fun LeaderboardScreen(modifier: Modifier = Modifier) {
    var selectedPeriod by remember { mutableStateOf("This Week") }
    val followState = remember { mutableStateOf(MockData.rankedCreators.associate { it.id to it.isFollowing }.toMutableMap()) }

    Box(modifier = modifier.fillMaxSize().background(MochiGradient.background)) {
        Column(
            modifier = Modifier
                .fillMaxSize()
                .verticalScroll(rememberScrollState())
                .padding(horizontal = MochiSpacing.md)
                .padding(top = MochiSpacing.md, bottom = 100.dp),
            verticalArrangement = Arrangement.spacedBy(MochiSpacing.lg)
        ) {
            LeaderboardHeader()
            PeriodTabsRow(selectedPeriod) { selectedPeriod = it }
            FollowCreatorsBanner()
            MockData.rankedCreators.forEachIndexed { index, creator ->
                val isFollowing = followState.value[creator.id] ?: false
                CreatorRankRow(
                    creator = creator,
                    rank = index + 1,
                    isFollowing = isFollowing,
                    onToggleFollow = { followState.value = followState.value.toMutableMap().apply { put(creator.id, !isFollowing) } }
                )
            }
            FooterBanner()
        }
    }
}

@Composable
private fun LeaderboardHeader() {
    Row(modifier = Modifier.fillMaxWidth(), verticalAlignment = Alignment.CenterVertically) {
        CircleIconButton(icon = Icons.AutoMirrored.Filled.ArrowBack)
        Column(modifier = Modifier.weight(1f).padding(horizontal = MochiSpacing.sm), horizontalAlignment = Alignment.CenterHorizontally) {
            Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(6.dp)) {
                Box(
                    modifier = Modifier.size(22.dp).clip(RoundedCornerShape(6.dp)).background(MochiColor.purple),
                    contentAlignment = Alignment.Center
                ) {
                    Icon(imageVector = Icons.Filled.EmojiEvents, contentDescription = null, tint = Color.White, modifier = Modifier.size(14.dp))
                }
                Text(text = "Ranked Creators", style = MochiFont.title(22.sp), color = MochiColor.purple)
            }
            Text(text = "Discover the most popular theme makers", style = MochiFont.caption(12.sp), color = MochiColor.textSecondary)
        }
        CircleIconButton(icon = Icons.Filled.Search)
    }
}

@Composable
private fun CircleIconButton(icon: androidx.compose.ui.graphics.vector.ImageVector) {
    Box(
        modifier = Modifier.size(44.dp).clip(CircleShape).background(MochiGradient.primaryButton),
        contentAlignment = Alignment.Center
    ) {
        Icon(imageVector = icon, contentDescription = null, tint = Color.White)
    }
}

@Composable
private fun PeriodTabsRow(selected: String, onSelect: (String) -> Unit) {
    Row(modifier = Modifier.fillMaxWidth(), verticalAlignment = Alignment.CenterVertically) {
        Row(
            modifier = Modifier.horizontalScroll(rememberScrollState()).weight(1f),
            horizontalArrangement = Arrangement.spacedBy(8.dp)
        ) {
            periods.forEach { period ->
                val isSelected = period == selected
                Box(
                    modifier = Modifier
                        .clip(RoundedCornerShape(MochiRadius.pill))
                        .then(
                            if (isSelected) Modifier.background(MochiGradient.primaryButton)
                            else Modifier.background(Color.White).border(1.dp, MochiColor.purple.copy(alpha = 0.25f), RoundedCornerShape(MochiRadius.pill))
                        )
                        .clickable { onSelect(period) }
                        .padding(horizontal = 14.dp, vertical = 10.dp)
                ) {
                    Text(text = period, style = MochiFont.heading(13.sp), color = if (isSelected) Color.White else MochiColor.textPrimary)
                }
            }
        }
        Spacer(modifier = Modifier.width(8.dp))
        Box(
            modifier = Modifier.size(36.dp).clip(CircleShape).border(1.dp, MochiColor.purple.copy(alpha = 0.25f), CircleShape),
            contentAlignment = Alignment.Center
        ) {
            Icon(imageVector = Icons.Filled.FilterList, contentDescription = "Filter", tint = MochiColor.textPrimary, modifier = Modifier.size(16.dp))
        }
        Spacer(modifier = Modifier.width(6.dp))
        Box(
            modifier = Modifier.size(36.dp).clip(CircleShape).border(1.dp, MochiColor.purple.copy(alpha = 0.25f), CircleShape),
            contentAlignment = Alignment.Center
        ) {
            Icon(imageVector = Icons.Filled.Tune, contentDescription = "Sort options", tint = MochiColor.textPrimary, modifier = Modifier.size(16.dp))
        }
    }
}

@Composable
private fun FollowCreatorsBanner() {
    Row(
        modifier = Modifier.fillMaxWidth().clip(RoundedCornerShape(MochiRadius.card)).background(Color.White).padding(MochiSpacing.md),
        verticalAlignment = Alignment.CenterVertically
    ) {
        Box(
            modifier = Modifier.size(44.dp).clip(RoundedCornerShape(12.dp)).background(MochiGradient.primaryButton),
            contentAlignment = Alignment.Center
        ) {
            Icon(imageVector = Icons.Filled.Keyboard, contentDescription = null, tint = Color.White, modifier = Modifier.size(20.dp))
        }
        Column(modifier = Modifier.weight(1f).padding(horizontal = MochiSpacing.sm)) {
            Text(text = "Follow creators whose style you love", style = MochiFont.heading(14.sp), color = MochiColor.purple)
            Text(text = "See their themes without opening a profile!", style = MochiFont.caption(11.sp), color = MochiColor.textSecondary)
        }
        Row(
            modifier = Modifier
                .clip(RoundedCornerShape(MochiRadius.pill))
                .border(1.dp, MochiColor.purple.copy(alpha = 0.3f), RoundedCornerShape(MochiRadius.pill))
                .padding(horizontal = 12.dp, vertical = 8.dp),
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.spacedBy(4.dp)
        ) {
            Text(text = "Explore Community", style = MochiFont.caption(11.sp), color = MochiColor.purple)
            Text(text = "›", style = MochiFont.heading(14.sp), color = MochiColor.purple)
        }
    }
}

@Composable
private fun CreatorRankRow(creator: Creator, rank: Int, isFollowing: Boolean, onToggleFollow: () -> Unit) {
    Column(
        modifier = Modifier.fillMaxWidth().clip(RoundedCornerShape(MochiRadius.card)).background(Color.White).padding(MochiSpacing.md),
        verticalArrangement = Arrangement.spacedBy(MochiSpacing.sm)
    ) {
        Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(MochiSpacing.sm)) {
            RankBadge(rank)
            CreatorAvatar(assetName = creator.avatarAssetName, modifier = Modifier.size(56.dp).clip(CircleShape))
            Column(modifier = Modifier.weight(1f)) {
                Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(4.dp)) {
                    Text(text = creator.displayName, style = MochiFont.heading(15.sp), color = MochiColor.textPrimary)
                    Icon(imageVector = Icons.Filled.Verified, contentDescription = "Verified", tint = MochiColor.purple, modifier = Modifier.size(13.dp))
                }
                Text(text = creator.handle, style = MochiFont.caption(12.sp), color = MochiColor.purple)
                Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(10.dp)) {
                    Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(3.dp)) {
                        Icon(imageVector = Icons.Filled.Palette, contentDescription = null, tint = MochiColor.textSecondary, modifier = Modifier.size(11.dp))
                        Text(text = "${creator.themeCount} Themes", style = MochiFont.caption(11.sp), color = MochiColor.textSecondary)
                    }
                    Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(3.dp)) {
                        Icon(imageVector = Icons.Filled.Favorite, contentDescription = null, tint = MochiColor.pink, modifier = Modifier.size(11.dp))
                        Text(text = creator.likeCount.let { if (it >= 1000) "${it / 1000}.${(it % 1000) / 100}K" else "$it" }, style = MochiFont.caption(11.sp), color = MochiColor.textSecondary)
                    }
                }
            }
            FollowButton(isFollowing = isFollowing, onClick = onToggleFollow)
        }
        Row(horizontalArrangement = Arrangement.spacedBy(MochiSpacing.sm)) {
            val previewThemes = MockData.shopThemes.let { list -> List(3) { i -> list[(rank * 3 + i) % list.size] } }
            previewThemes.forEach { theme ->
                ThemeArt(assetName = theme.imageAssetName, seed = theme.id, modifier = Modifier.weight(1f).aspectRatio(1f))
            }
        }
    }
}

@Composable
private fun RankBadge(rank: Int) {
    if (rank <= 3) {
        Box(
            modifier = Modifier.size(28.dp).clip(CircleShape).background(medalColors[rank - 1]),
            contentAlignment = Alignment.Center
        ) {
            Text(text = rank.toString(), style = MochiFont.heading(13.sp), color = Color.White)
        }
    } else {
        Box(modifier = Modifier.size(28.dp), contentAlignment = Alignment.Center) {
            Text(text = rank.toString(), style = MochiFont.title(18.sp), color = MochiColor.textPrimary)
        }
    }
}

@Composable
private fun FollowButton(isFollowing: Boolean, onClick: () -> Unit) {
    Row(
        modifier = Modifier
            .clip(RoundedCornerShape(MochiRadius.pill))
            .then(if (isFollowing) Modifier.background(MochiGradient.primaryButton) else Modifier.background(Color.White).border(1.dp, MochiColor.purple.copy(alpha = 0.3f), RoundedCornerShape(MochiRadius.pill)))
            .clickable(onClick = onClick)
            .padding(horizontal = 14.dp, vertical = 8.dp),
        verticalAlignment = Alignment.CenterVertically,
        horizontalArrangement = Arrangement.spacedBy(4.dp)
    ) {
        Icon(imageVector = Icons.Filled.PersonAdd, contentDescription = null, tint = if (isFollowing) Color.White else MochiColor.purple, modifier = Modifier.size(13.dp))
        Text(text = if (isFollowing) "Following" else "Follow", style = MochiFont.caption(12.sp), color = if (isFollowing) Color.White else MochiColor.purple)
    }
}

@Composable
private fun FooterBanner() {
    Row(
        modifier = Modifier.fillMaxWidth().clip(RoundedCornerShape(MochiRadius.card)).background(Color.White).padding(MochiSpacing.md),
        verticalAlignment = Alignment.CenterVertically
    ) {
        Image(painter = painterResource(R.drawable.icon_trophy_mochi), contentDescription = null, modifier = Modifier.size(56.dp).clip(CircleShape))
        Column(modifier = Modifier.padding(start = MochiSpacing.sm)) {
            Text(text = "Rankings update every Monday", style = MochiFont.heading(15.sp), color = MochiColor.purple)
            Text(text = "Keep creating amazing themes & climb the ranks!", style = MochiFont.caption(11.sp), color = MochiColor.textSecondary)
        }
    }
}
