package com.mochi.keyboard.features.leaderboard

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
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import androidx.lifecycle.viewmodel.compose.viewModel
import com.mochi.keyboard.R
import com.mochi.keyboard.components.CreatorAvatar
import com.mochi.keyboard.components.ThemeArt
import com.mochi.keyboard.data.rememberMochiViewModelFactory
import com.mochi.keyboard.designsystem.MochiColor
import com.mochi.keyboard.designsystem.MochiFont
import com.mochi.keyboard.designsystem.MochiGradient
import com.mochi.keyboard.designsystem.MochiRadius
import com.mochi.keyboard.designsystem.MochiSpacing
import com.mochi.keyboard.mockdata.MockData
import com.mochi.keyboard.model.KeyboardTheme

@Preview(showBackground = true, widthDp = 393, heightDp = 3300)
@Composable
private fun LeaderboardScreenPreview() {
    LeaderboardScreenContent()
}

private val periods = listOf("This Week", "This Month", "All Time")
private val medalColors = listOf(Color(0xFFDDA935), Color(0xFFB8B8C8), Color(0xFFB0793F))

/** Ported from docs/figma/9.png. No iOS screen exists for this - Android's is the only Leaderboard
 * ("Ranked Creators") implementation in this app, so there's no cross-platform source of truth to
 * diff against. */
@Composable
fun LeaderboardScreen(
    modifier: Modifier = Modifier,
    onBack: () -> Unit = {},
    onSearchClick: () -> Unit = {},
    onCreatorClick: (String) -> Unit = {},
    viewModel: LeaderboardViewModel = viewModel(factory = rememberMochiViewModelFactory())
) {
    val uiState by viewModel.uiState.collectAsStateWithLifecycle()
    val data = uiState as? LeaderboardUiState.Data
    // Loading/Error fall back to MockData so the pixel-tuned layout never breaks (same convention
    // as every other converted screen); a genuinely-empty real period (e.g. no likes yet this week)
    // is real data, not an error, so it renders as an empty list rather than masked with MockData.
    LeaderboardScreenContent(
        modifier = modifier,
        creators = data?.creators,
        onBack = onBack,
        onSearchClick = onSearchClick,
        onCreatorClick = onCreatorClick,
        onSelectPeriod = viewModel::selectPeriod,
        onToggleFollow = viewModel::toggleFollow
    )
}

/** Split from LeaderboardScreen so @Preview can render this directly with MockData, without going
 * through rememberMochiViewModelFactory() - same reason as every other converted screen's Content
 * split (HomeScreen, CommunityScreen, ...). `creators == null` means Loading/Error/Preview, render
 * MockData's static rows; a non-null (possibly empty) list is real data. */
@Composable
private fun LeaderboardScreenContent(
    modifier: Modifier = Modifier,
    creators: List<LeaderboardCreatorUi>? = null,
    onBack: () -> Unit = {},
    onSearchClick: () -> Unit = {},
    onCreatorClick: (String) -> Unit = {},
    onSelectPeriod: (String) -> Unit = {},
    onToggleFollow: (String) -> Unit = {}
) {
    var selectedPeriod by remember { mutableStateOf("This Week") }
    val mockFollowState = remember { mutableStateOf(MockData.rankedCreators.associate { it.id to it.isFollowing }.toMutableMap()) }

    Box(modifier = modifier.fillMaxSize().background(MochiGradient.background)) {
        Column(
            modifier = Modifier
                .fillMaxSize()
                .verticalScroll(rememberScrollState())
                .padding(horizontal = MochiSpacing.md)
                .padding(top = MochiSpacing.md, bottom = 100.dp),
            verticalArrangement = Arrangement.spacedBy(MochiSpacing.lg)
        ) {
            LeaderboardHeader(onBack, onSearchClick)
            PeriodTabsRow(selectedPeriod) { selectedPeriod = it; onSelectPeriod(it) }
            FollowCreatorsBanner()
            if (creators == null) {
                MockData.rankedCreators.forEachIndexed { index, creator ->
                    val isFollowing = mockFollowState.value[creator.id] ?: false
                    CreatorRankRow(
                        displayName = creator.displayName,
                        handle = creator.handle,
                        avatarAssetName = creator.avatarAssetName,
                        themeCount = creator.themeCount,
                        likeCount = creator.likeCount,
                        isVerified = creator.isVerified,
                        rank = index + 1,
                        isFollowing = isFollowing,
                        previewThemes = MockData.shopThemes.let { list -> List(3) { i -> list[((index + 1) * 3 + i) % list.size] } },
                        onToggleFollow = { mockFollowState.value = mockFollowState.value.toMutableMap().apply { put(creator.id, !isFollowing) } },
                        onClick = {}
                    )
                }
            } else {
                creators.forEachIndexed { index, creator ->
                    CreatorRankRow(
                        displayName = creator.displayName,
                        handle = creator.handle,
                        avatarAssetName = "",
                        themeCount = creator.themeCount,
                        likeCount = creator.likeCount,
                        isVerified = false,
                        rank = index + 1,
                        isFollowing = creator.isFollowing,
                        previewThemes = null,
                        onToggleFollow = { onToggleFollow(creator.uid) },
                        onClick = { onCreatorClick(creator.uid) }
                    )
                }
            }
            FooterBanner()
        }
    }
}

@Composable
private fun LeaderboardHeader(onBack: () -> Unit, onSearchClick: () -> Unit) {
    Row(modifier = Modifier.fillMaxWidth(), verticalAlignment = Alignment.CenterVertically) {
        CircleIconButton(icon = Icons.AutoMirrored.Filled.ArrowBack, onClick = onBack)
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
        CircleIconButton(icon = Icons.Filled.Search, onClick = onSearchClick)
    }
}

@Composable
private fun CircleIconButton(icon: androidx.compose.ui.graphics.vector.ImageVector, onClick: () -> Unit = {}) {
    Box(
        modifier = Modifier.size(44.dp).clip(CircleShape).background(MochiGradient.primaryButton).clickable(onClick = onClick),
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

/** "Explore Community" chevron is decorative, not wired to navigation - Community is a bottom-tab
 * selection inside RootScreen, not a standalone nav route, so reaching it from here would need a
 * tab-deep-link contract added to Route.MAIN. Left as-is, same undecided-scope treatment as the
 * Filter/Sort icons in PeriodTabsRow. */
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

/** `isVerified` never real for a Firestore-backed creator (no such field anywhere in this app's
 * schema - same documented gap as Community/Profile), so only the MockData path ever passes true.
 * `previewThemes == null` skips that whole row rather than attributing MockData thumbnails to a
 * specific real creator, same reasoning Profile's other-user view used to drop sections with no
 * backing data instead of faking them. */
@Composable
private fun CreatorRankRow(
    displayName: String,
    handle: String,
    avatarAssetName: String,
    themeCount: Int,
    likeCount: Int,
    isVerified: Boolean,
    rank: Int,
    isFollowing: Boolean,
    previewThemes: List<KeyboardTheme>?,
    onToggleFollow: () -> Unit,
    onClick: () -> Unit
) {
    Column(
        modifier = Modifier.fillMaxWidth().clip(RoundedCornerShape(MochiRadius.card)).background(Color.White).padding(MochiSpacing.md),
        verticalArrangement = Arrangement.spacedBy(MochiSpacing.sm)
    ) {
        Row(
            modifier = Modifier.clickable(onClick = onClick),
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.spacedBy(MochiSpacing.sm)
        ) {
            RankBadge(rank)
            CreatorAvatar(assetName = avatarAssetName, modifier = Modifier.size(56.dp).clip(CircleShape))
            Column(modifier = Modifier.weight(1f)) {
                Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(4.dp)) {
                    Text(text = displayName, style = MochiFont.heading(15.sp), color = MochiColor.textPrimary)
                    if (isVerified) {
                        Icon(imageVector = Icons.Filled.Verified, contentDescription = "Verified", tint = MochiColor.purple, modifier = Modifier.size(13.dp))
                    }
                }
                Text(text = handle, style = MochiFont.caption(12.sp), color = MochiColor.purple)
                Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(10.dp)) {
                    Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(3.dp)) {
                        Icon(imageVector = Icons.Filled.Palette, contentDescription = null, tint = MochiColor.textSecondary, modifier = Modifier.size(11.dp))
                        Text(text = "$themeCount Themes", style = MochiFont.caption(11.sp), color = MochiColor.textSecondary)
                    }
                    Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(3.dp)) {
                        Icon(imageVector = Icons.Filled.Favorite, contentDescription = null, tint = MochiColor.pink, modifier = Modifier.size(11.dp))
                        Text(text = likeCount.let { if (it >= 1000) "${it / 1000}.${(it % 1000) / 100}K" else "$it" }, style = MochiFont.caption(11.sp), color = MochiColor.textSecondary)
                    }
                }
            }
            FollowButton(isFollowing = isFollowing, onClick = onToggleFollow)
        }
        if (previewThemes != null) {
            Row(horizontalArrangement = Arrangement.spacedBy(MochiSpacing.sm)) {
                previewThemes.forEach { theme ->
                    ThemeArt(assetName = theme.imageAssetName, seed = theme.id, modifier = Modifier.weight(1f).aspectRatio(1f))
                }
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
