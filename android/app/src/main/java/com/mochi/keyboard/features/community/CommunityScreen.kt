package com.mochi.keyboard.features.community

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
import androidx.compose.foundation.layout.aspectRatio
import androidx.compose.foundation.layout.fillMaxHeight
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
import androidx.compose.foundation.text.BasicTextField
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Favorite
import androidx.compose.material.icons.filled.MoreVert
import androidx.compose.material.icons.filled.Search
import androidx.compose.material.icons.filled.Verified
import androidx.compose.material3.AlertDialog
import androidx.compose.material3.Icon
import androidx.compose.material3.RadioButton
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
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
import androidx.compose.ui.platform.LocalDensity
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import androidx.lifecycle.viewmodel.compose.viewModel
import com.mochi.keyboard.R
import com.mochi.keyboard.components.CreatorAvatar
import com.mochi.keyboard.components.DownloadGlyph
import com.mochi.keyboard.components.KeyboardPreviewPlaceholder
import com.mochi.keyboard.components.SparkleField
import com.mochi.keyboard.data.rememberMochiViewModelFactory
import com.mochi.keyboard.designsystem.CommunityMetrics
import com.mochi.keyboard.designsystem.CommunityType
import com.mochi.keyboard.designsystem.MochiColor
import com.mochi.keyboard.designsystem.MochiFont
import com.mochi.keyboard.designsystem.MochiGradient
import com.mochi.keyboard.mockdata.MockData
import com.mochi.keyboard.model.CommunityPost
import com.mochi.keyboard.model.KeyboardTheme
import com.mochi.keyboard.model.TagPalette

@Preview(showBackground = true, widthDp = 393, heightDp = 2200)
@Composable
private fun CommunityScreenPreview() {
    CommunityScreenContent()
}

/** Figma spells the placeholder "serch themes, creators.." — kept verbatim, like the fourth
 * creator tile's "Choose" CTA. */
private val feedTabs = listOf("For you", "Popular", "Latest", "Following", "My Likes")

/** Ported from ios/MochiApp/Features/Community/CommunityView.swift against docs/figma/2.png.
 * Geometry lives in CommunityMetrics/CommunityType (designsystem/CommunityMetrics.kt), not here. */
@Composable
fun CommunityScreen(
    modifier: Modifier = Modifier,
    onProfileClick: () -> Unit = {},
    onCreatorClick: (String) -> Unit = {},
    onSearchClick: () -> Unit = {},
    onThemeClick: (KeyboardTheme) -> Unit = {},
    onLeaderboardClick: () -> Unit = {},
    viewModel: CommunityViewModel = viewModel(factory = rememberMochiViewModelFactory())
) {
    val uiState by viewModel.uiState.collectAsStateWithLifecycle()
    val data = uiState as? CommunityUiState.Data
    // Loading/Error fall back to MockData so the pixel-tuned layout never breaks (same convention
    // as Home/Themes); a genuinely-empty tab under Data (e.g. no follows yet on "Following") is
    // real data, not an error, so it's shown as-is rather than masked with MockData.
    CommunityScreenContent(
        modifier = modifier,
        topThemes = data?.feedThemes?.take(3) ?: MockData.communityTopThemes,
        latestThemes = data?.latestThemes,
        creators = data?.creators,
        onProfileClick = onProfileClick,
        onCreatorClick = onCreatorClick,
        onSearchClick = onSearchClick,
        onThemeClick = onThemeClick,
        onLeaderboardClick = onLeaderboardClick,
        onSelectTab = viewModel::selectTab,
        onToggleFollow = viewModel::toggleFollow,
        onReport = viewModel::reportTheme
    )
}

/** Split from CommunityScreen so @Preview can render this directly with MockData, without going
 * through rememberMochiViewModelFactory() - that factory casts LocalContext's application to
 * MochiApplication, which Preview's fake context isn't, and would crash the preview. Same pattern
 * as HomeScreen/ThemesScreen. `latestThemes`/`creators` are null in Preview (and during
 * Loading/Error) to signal "use MockData for this section" vs. a real, possibly-empty list. */
@Composable
private fun CommunityScreenContent(
    modifier: Modifier = Modifier,
    topThemes: List<KeyboardTheme> = MockData.communityTopThemes,
    latestThemes: List<KeyboardTheme>? = null,
    creators: List<CommunityCreatorUi>? = null,
    onProfileClick: () -> Unit = {},
    onCreatorClick: (String) -> Unit = {},
    onSearchClick: () -> Unit = {},
    onThemeClick: (KeyboardTheme) -> Unit = {},
    onLeaderboardClick: () -> Unit = {},
    onSelectTab: (String) -> Unit = {},
    onToggleFollow: (String) -> Unit = {},
    onReport: (String, String) -> Unit = { _, _ -> }
) {
    var selectedTab by remember { mutableStateOf(feedTabs.first()) }
    var query by remember { mutableStateOf("") }
    var reportingTheme by remember { mutableStateOf<KeyboardTheme?>(null) }

    Box(modifier = modifier.fillMaxSize()) {
        Image(
            painter = painterResource(R.drawable.community_background),
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
                .padding(horizontal = CommunityMetrics.margin)
                .padding(bottom = 100.dp)
                .offset(y = CommunityMetrics.contentTop)
        ) {
            CommunityHeader(onProfileClick)

            Spacer(modifier = Modifier.height(CommunityMetrics.headerToSearch))
            SearchField(query, { query = it }, onSearchClick)

            Spacer(modifier = Modifier.height(CommunityMetrics.searchToPills))
            FilterPills(selected = selectedTab, onSelect = { selectedTab = it; onSelectTab(it) })

            Spacer(modifier = Modifier.height(CommunityMetrics.pillsToHeading))
            SectionHeading("Top Themes")
            Spacer(modifier = Modifier.height(maxOf(0.dp, CommunityMetrics.headingToTopThemes - CommunityMetrics.rankBadge / 2)))
            TopThemesRow(topThemes, onThemeClick)

            Spacer(modifier = Modifier.height(CommunityMetrics.contentToHeading))
            SectionHeading("Popular Creators", onSeeAllClick = onLeaderboardClick)
            Spacer(modifier = Modifier.height(CommunityMetrics.headingToContent))
            CreatorsRow(creators, onToggleFollow, onCreatorClick)

            Spacer(modifier = Modifier.height(CommunityMetrics.contentToHeading))
            SectionHeading("Latest Creations")
            Spacer(modifier = Modifier.height(CommunityMetrics.headingToContent))
            LatestCreations(latestThemes, onThemeClick, onReport = { theme -> reportingTheme = theme }, onCreatorClick = onCreatorClick)
        }
    }

    reportingTheme?.let { theme ->
        ReportDialog(
            onDismiss = { reportingTheme = null },
            onConfirm = { reason ->
                onReport(theme.id, reason)
                reportingTheme = null
            }
        )
    }
}

// region Header / search / pills

@Composable
private fun CommunityHeader(onProfileClick: () -> Unit) {
    Row(modifier = Modifier.fillMaxWidth(), verticalAlignment = Alignment.CenterVertically) {
        Text(text = "Mochi", style = MochiFont.logo(CommunityType.logo), color = MochiColor.logoSolid)
        Spacer(modifier = Modifier.weight(1f))
        Image(
            painter = painterResource(R.drawable.avatar_user),
            contentDescription = "Profile",
            contentScale = ContentScale.Crop,
            modifier = Modifier
                .size(CommunityMetrics.avatar)
                .clip(CircleShape)
                .clickable(onClick = onProfileClick)
        )
    }
}

/** A live text field rather than a static label: the design is a search affordance and there's
 * already a SearchScreen in the app, so wiring the text through costs nothing. */
@Composable
private fun SearchField(query: String, onQueryChange: (String) -> Unit, onSearchClick: () -> Unit) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .height(CommunityMetrics.searchHeight)
            .clip(RoundedCornerShape(CommunityMetrics.searchRadius))
            .background(Color.White)
            .border(CommunityMetrics.hairline, MochiColor.outline, RoundedCornerShape(CommunityMetrics.searchRadius))
            .padding(horizontal = CommunityMetrics.searchInset),
        verticalAlignment = Alignment.CenterVertically
    ) {
        Box(modifier = Modifier.weight(1f)) {
            BasicTextField(
                value = query,
                onValueChange = onQueryChange,
                singleLine = true,
                textStyle = MochiFont.caption(CommunityType.searchPlaceholder).copy(color = MochiColor.textPrimary),
                modifier = Modifier.fillMaxWidth()
            )
            if (query.isEmpty()) {
                Text(text = "serch themes, creators..", style = MochiFont.caption(CommunityType.searchPlaceholder), color = MochiColor.textMuted)
            }
        }
        Icon(
            imageVector = Icons.Filled.Search,
            contentDescription = "Search",
            tint = MochiColor.textMuted,
            modifier = Modifier.size(CommunityMetrics.searchIcon).clickable(onClick = onSearchClick)
        )
    }
}

/** The five pills divide the content width exactly in Figma, so they're equal flexible columns
 * rather than sized to their labels — which is also why "My Likes" and "Latest" end up the same
 * width despite the length gap. */
@Composable
private fun FilterPills(selected: String, onSelect: (String) -> Unit) {
    Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.spacedBy(CommunityMetrics.pillGap)) {
        feedTabs.forEach { tab ->
            val isSelected = tab == selected
            Box(
                modifier = Modifier
                    .weight(1f)
                    .height(CommunityMetrics.pillHeight)
                    .clip(RoundedCornerShape(CommunityMetrics.pillRadius))
                    .then(
                        if (isSelected) Modifier.background(MochiGradient.softButton)
                        else Modifier.background(Color.White).border(CommunityMetrics.hairline, MochiColor.creatorLink, RoundedCornerShape(CommunityMetrics.pillRadius))
                    )
                    .clickable { onSelect(tab) },
                contentAlignment = Alignment.Center
            ) {
                Text(
                    text = tab,
                    style = if (isSelected) MochiFont.itemName(CommunityType.pillSelected) else MochiFont.body(CommunityType.pillIdle),
                    color = MochiColor.textPrimary,
                    maxLines = 1,
                    overflow = TextOverflow.Ellipsis
                )
            }
        }
    }
}

/** [onSeeAllClick] is null for sections with no real "see all" destination (Top Themes, Latest
 * Creations - both already show a bounded feed with no separate full-list screen), so "see all"
 * stays decorative there, same as before. Popular Creators is the one exception - the feature spec
 * nests the Leaderboard ("Ranked Creators") under Community, so its "see all" is this app's only
 * entry point into that screen. */
@Composable
private fun SectionHeading(title: String, onSeeAllClick: (() -> Unit)? = null) {
    Row(modifier = Modifier.fillMaxWidth(), verticalAlignment = Alignment.CenterVertically) {
        Text(text = title.uppercase(), style = MochiFont.title(CommunityType.sectionTitle), color = MochiColor.textPrimary)
        Spacer(modifier = Modifier.weight(1f))
        Text(
            text = "see all",
            style = MochiFont.body(CommunityType.seeAll),
            color = MochiColor.textPrimary,
            modifier = if (onSeeAllClick != null) Modifier.clickable(onClick = onSeeAllClick) else Modifier
        )
    }
}

// endregion

// region Top Themes

@Composable
private fun TopThemesRow(themes: List<KeyboardTheme>, onThemeClick: (KeyboardTheme) -> Unit) {
    Row(
        modifier = Modifier.horizontalScroll(rememberScrollState()).padding(top = CommunityMetrics.rankBadge / 2),
        horizontalArrangement = Arrangement.spacedBy(CommunityMetrics.themeCardGap)
    ) {
        themes.forEachIndexed { index, theme ->
            TopThemeCard(theme, rank = index + 1, onClick = { onThemeClick(theme) })
        }
    }
}

private val rankBadgeRes = listOf(R.drawable.badge_rank_1, R.drawable.badge_rank_2, R.drawable.badge_rank_3)

@Composable
private fun TopThemeCard(theme: KeyboardTheme, rank: Int, onClick: () -> Unit) {
    Box {
        Column(
            modifier = Modifier
                .width(CommunityMetrics.themeCard)
                .shadow(5.dp, RoundedCornerShape(CommunityMetrics.cardRadius), ambientColor = MochiColor.purpleDark.copy(alpha = 0.13f), spotColor = MochiColor.purpleDark.copy(alpha = 0.13f))
                .clip(RoundedCornerShape(CommunityMetrics.cardRadius))
                .background(Color.White)
                .clickable(onClick = onClick)
        ) {
            CommunityArtImage(
                assetName = theme.imageAssetName,
                seed = theme.id,
                modifier = Modifier.width(CommunityMetrics.themeCard).height(CommunityMetrics.themeArtHeight)
            )
            Box(modifier = Modifier.width(CommunityMetrics.themeCard).height(CommunityMetrics.themeBodyHeight)) {
                Column(modifier = Modifier.padding(start = 8.dp, top = 4.dp, bottom = 4.dp, end = 4.dp)) {
                    Text(text = theme.name, style = MochiFont.body(CommunityType.themeName), color = MochiColor.textPrimary, maxLines = 1, overflow = TextOverflow.Ellipsis)
                    Spacer(modifier = Modifier.weight(1f))
                    Text(text = "by ${theme.creatorName}", style = MochiFont.itemName(CommunityType.themeByline), color = MochiColor.creatorLink, maxLines = 1, overflow = TextOverflow.Ellipsis)
                    Spacer(modifier = Modifier.weight(1f))
                    Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(3.dp)) {
                        Icon(imageVector = Icons.Filled.Favorite, contentDescription = null, tint = MochiColor.heart, modifier = Modifier.size((CommunityType.themeLikes.value * 1.25f).dp))
                        Text(text = theme.likeCountFormatted, style = MochiFont.body(CommunityType.themeLikes), color = MochiColor.textPrimary)
                    }
                }
            }
        }
        CommunityDownloadButton(
            diameter = CommunityMetrics.downloadButton,
            modifier = Modifier.align(Alignment.BottomEnd).padding(end = 8.5.dp, bottom = 5.dp)
        )
        Image(
            painter = painterResource(rankBadgeRes[(rank - 1).coerceIn(0, 2)]),
            contentDescription = null,
            modifier = Modifier
                .align(Alignment.TopStart)
                .size(CommunityMetrics.rankBadge)
                .offset(y = -CommunityMetrics.rankBadge / 2 + 0.7.dp)
        )
    }
}

// endregion

// region Popular Creators

/** `creators == null` means Loading/Error (or Preview) - render MockData's static, non-interactive
 * tiles. A non-null (possibly empty) list means real Firestore data - each tile's follow button is
 * live, backed by [onToggleFollow]. */
@Composable
private fun CreatorsRow(creators: List<CommunityCreatorUi>?, onToggleFollow: (String) -> Unit, onCreatorClick: (String) -> Unit) {
    Row(
        modifier = Modifier.horizontalScroll(rememberScrollState()),
        horizontalArrangement = Arrangement.spacedBy(CommunityMetrics.creatorCardGap)
    ) {
        if (creators == null) {
            MockData.communityCreators.forEach { creator ->
                CreatorTile(
                    name = creator.name,
                    avatarAssetName = creator.avatarAssetName,
                    themeCount = creator.themeCount,
                    isVerified = creator.isVerified,
                    ctaLabel = creator.ctaTitle,
                    onCtaClick = null,
                    onCreatorClick = {}
                )
            }
        } else {
            creators.forEach { creator ->
                CreatorTile(
                    name = creator.name,
                    avatarAssetName = "",
                    themeCount = creator.themeCount,
                    isVerified = false,
                    ctaLabel = if (creator.isFollowing) "Following" else "Follow",
                    onCtaClick = { onToggleFollow(creator.uid) },
                    onCreatorClick = { onCreatorClick(creator.uid) }
                )
            }
        }
    }
}

@Composable
private fun CreatorTile(
    name: String,
    avatarAssetName: String,
    themeCount: Int,
    isVerified: Boolean,
    ctaLabel: String,
    onCtaClick: (() -> Unit)?,
    onCreatorClick: () -> Unit
) {
    Column(
        modifier = Modifier
            .size(CommunityMetrics.creatorCard.width, CommunityMetrics.creatorCard.height)
            .shadow(5.dp, RoundedCornerShape(CommunityMetrics.cardRadius), ambientColor = MochiColor.purpleDark.copy(alpha = 0.13f), spotColor = MochiColor.purpleDark.copy(alpha = 0.13f))
            .clip(RoundedCornerShape(CommunityMetrics.cardRadius))
            .background(Color.White)
            .padding(top = 5.4.dp, bottom = 5.2.dp)
    ) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .clickable(onClick = onCreatorClick)
                .padding(start = CommunityMetrics.creatorInset, end = CommunityMetrics.creatorTrailing),
            horizontalArrangement = Arrangement.spacedBy(CommunityMetrics.creatorAvatarGap)
        ) {
            CreatorAvatar(
                assetName = avatarAssetName,
                modifier = Modifier.size(CommunityMetrics.creatorAvatar).clip(CircleShape)
            )
            Column(modifier = Modifier.padding(top = 6.dp)) {
                Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(2.dp)) {
                    Text(
                        text = name,
                        style = MochiFont.itemName(CommunityType.creatorName),
                        color = MochiColor.textPrimary,
                        maxLines = 1,
                        overflow = TextOverflow.Ellipsis
                    )
                    if (isVerified) {
                        Icon(imageVector = Icons.Filled.Verified, contentDescription = "Verified", tint = MochiColor.logoSolid, modifier = Modifier.size(CommunityMetrics.verifiedBadge))
                    }
                }
                Text(text = "$themeCount Themes", style = MochiFont.caption(CommunityType.creatorThemes), color = MochiColor.textMuted, maxLines = 1)
            }
        }

        Spacer(modifier = Modifier.weight(1f))

        Box(modifier = Modifier.fillMaxWidth(), contentAlignment = Alignment.Center) {
            Box(
                modifier = Modifier
                    .size(CommunityMetrics.followSize.width, CommunityMetrics.followSize.height)
                    .clip(CircleShape)
                    .background(MochiGradient.softButton)
                    .then(if (onCtaClick != null) Modifier.clickable(onClick = onCtaClick) else Modifier),
                contentAlignment = Alignment.Center
            ) {
                Text(text = ctaLabel, style = MochiFont.button(CommunityType.followLabel), color = MochiColor.textPrimary, maxLines = 1)
            }
        }
    }
}

// endregion

// region Latest Creations

/** `themes == null` means Loading/Error (or Preview) - render MockData's static cards, tap/report
 * both no-ops (matches this section's prior behavior, where onThemeClick was accepted but never
 * actually wired). A non-null list is real Firestore data - card tap opens the theme (resolved via
 * ThemeCache, populated by CommunityViewModel), the MoreVert icon opens the report dialog. */
@Composable
private fun LatestCreations(
    themes: List<KeyboardTheme>?,
    onThemeClick: (KeyboardTheme) -> Unit,
    onReport: (KeyboardTheme) -> Unit,
    onCreatorClick: (String) -> Unit
) {
    Column(verticalArrangement = Arrangement.spacedBy(CommunityMetrics.latestCardGap)) {
        if (themes == null) {
            MockData.communityLatest.forEach { post -> LatestCard(post, onClick = {}, onReport = {}, onCreatorClick = {}) }
        } else {
            themes.forEach { theme ->
                LatestCard(
                    theme.toCommunityPost(),
                    onClick = { onThemeClick(theme) },
                    onReport = { onReport(theme) },
                    onCreatorClick = { if (theme.creatorUid.isNotBlank()) onCreatorClick(theme.creatorUid) }
                )
            }
        }
    }
}

@Composable
private fun LatestCard(post: CommunityPost, onClick: () -> Unit, onReport: () -> Unit, onCreatorClick: () -> Unit) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .height(CommunityMetrics.latestCardHeight)
            .shadow(5.dp, RoundedCornerShape(CommunityMetrics.cardRadius), ambientColor = MochiColor.purpleDark.copy(alpha = 0.13f), spotColor = MochiColor.purpleDark.copy(alpha = 0.13f))
            .clip(RoundedCornerShape(CommunityMetrics.cardRadius))
            .background(Color.White)
            .clickable(onClick = onClick)
            .padding(start = 8.dp, top = 6.dp, bottom = 6.dp, end = CommunityMetrics.latestTrailing),
        verticalAlignment = Alignment.CenterVertically
    ) {
        CommunityArtImage(
            assetName = post.thumbAssetName,
            seed = post.id,
            modifier = Modifier
                .size(CommunityMetrics.latestThumb.width, CommunityMetrics.latestThumb.height)
                .clip(RoundedCornerShape(CommunityMetrics.latestThumbRadius))
        )
        Spacer(modifier = Modifier.width(CommunityMetrics.latestThumbGap))

        Column(modifier = Modifier.weight(1f).fillMaxHeight()) {
            Text(text = post.name, style = MochiFont.itemName(CommunityType.latestTitle), color = MochiColor.textPrimary, maxLines = 1, overflow = TextOverflow.Ellipsis)

            Spacer(modifier = Modifier.height(4.dp))

            Row(
                verticalAlignment = Alignment.CenterVertically,
                horizontalArrangement = Arrangement.spacedBy(1.dp),
                modifier = Modifier.clickable(onClick = onCreatorClick)
            ) {
                Text(text = "By ${post.creatorName}", style = MochiFont.itemName(CommunityType.latestByline), color = MochiColor.textPrimary, maxLines = 1)
                Icon(imageVector = Icons.Filled.Verified, contentDescription = null, tint = MochiColor.logoSolid, modifier = Modifier.size(CommunityMetrics.verifiedBadge))
            }

            Spacer(modifier = Modifier.height(6.dp))

            Text(
                text = post.summary,
                style = MochiFont.body(CommunityType.latestSummary),
                color = MochiColor.textMuted,
                maxLines = 2,
                overflow = TextOverflow.Ellipsis
            )

            Spacer(modifier = Modifier.weight(1f))

            Row(horizontalArrangement = Arrangement.spacedBy(CommunityMetrics.tagGap)) {
                post.hashtags.forEach { tag ->
                    Box(
                        modifier = Modifier
                            .height(CommunityMetrics.tagHeight)
                            .clip(CircleShape)
                            .background(tagBackground(post.tagPalette))
                            .padding(horizontal = 3.5.dp),
                        contentAlignment = Alignment.Center
                    ) {
                        Text(text = "#$tag", style = MochiFont.caption(CommunityType.tag), color = tagForeground(post.tagPalette), maxLines = 1)
                    }
                }
            }
        }

        Row(verticalAlignment = Alignment.CenterVertically) {
            Icon(imageVector = Icons.Filled.Favorite, contentDescription = null, tint = MochiColor.heart, modifier = Modifier.size((CommunityType.latestLikes.value * 1.25f).dp))
            Spacer(modifier = Modifier.width(4.8.dp))
            Text(text = "${post.likeCount}", style = MochiFont.caption(CommunityType.latestLikes), color = MochiColor.textPrimary)
            Spacer(modifier = Modifier.width(10.7.dp))
            CommunityDownloadButton(diameter = CommunityMetrics.latestDownload)
            Spacer(modifier = Modifier.width(9.8.dp))
            Icon(
                imageVector = Icons.Filled.MoreVert,
                contentDescription = "Report",
                tint = MochiColor.textPrimary,
                modifier = Modifier.size(14.dp).clickable(onClick = onReport)
            )
        }
    }
}

/** Reasons kept short and generic on purpose - reportTheme() just stores whichever string is
 * picked verbatim (see ReportRepository); functions/src/reports.ts' auto-hide trigger only reads
 * themeId/status, not reason, so this list has no server-side contract to match. */
private val reportReasons = listOf("Spam", "Inappropriate content", "Copyright violation", "Other")

@Composable
private fun ReportDialog(onDismiss: () -> Unit, onConfirm: (String) -> Unit) {
    var selectedReason by remember { mutableStateOf(reportReasons.first()) }
    AlertDialog(
        onDismissRequest = onDismiss,
        title = { Text("Report theme") },
        text = {
            Column {
                reportReasons.forEach { reason ->
                    Row(
                        modifier = Modifier
                            .fillMaxWidth()
                            .clickable { selectedReason = reason },
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        RadioButton(selected = reason == selectedReason, onClick = { selectedReason = reason })
                        Text(text = reason)
                    }
                }
            }
        },
        confirmButton = {
            TextButton(onClick = { onConfirm(selectedReason) }) { Text("Report") }
        },
        dismissButton = {
            TextButton(onClick = onDismiss) { Text("Cancel") }
        }
    )
}

private fun tagForeground(palette: TagPalette): Color = when (palette) {
    TagPalette.GREEN -> Color(0xFF399213)
    TagPalette.BLUE -> Color(0xFF0E6BFA)
    TagPalette.PEACH -> Color(0xFFFB8D52)
}

private fun tagBackground(palette: TagPalette): Color = when (palette) {
    TagPalette.GREEN -> Color(0xFFF1F7E4)
    TagPalette.BLUE -> Color(0xFFF1EFFB)
    TagPalette.PEACH -> Color(0xFFFFF0E1)
}

// endregion

// region Shared bits

/** Same real-art catalog as ThemeArt's, drawn flat — this page applies its own whole-card shadow
 * (purpleDark 13%), not the shared component's. */
private val communityArt: Map<String, Int> = mapOf(
    "theme_kawaii_boba" to R.drawable.theme_kawaii_boba,
    "theme_sakura_train" to R.drawable.theme_sakura_train,
    "theme_pastel_pink_sky" to R.drawable.theme_pastel_pink_sky,
    "latest_cozy_sakura_cafe" to R.drawable.latest_cozy_sakura_cafe,
    "latest_space_vibe" to R.drawable.latest_space_vibe,
    "latest_dreamy_fantasy" to R.drawable.latest_dreamy_fantasy
)

/** Unlike ThemeArt.kt's fallback, this has no shadow/clip of its own (this page's cards apply one
 * whole-card shadow already) - same seeded-placeholder behavior for real Firestore themes whose
 * imageAssetName ("firestore:$id") never matches this bundled-only catalog. */
@Composable
private fun CommunityArtImage(assetName: String, seed: String, modifier: Modifier = Modifier) {
    val resId = communityArt[assetName]
    if (resId != null) {
        Image(painter = painterResource(resId), contentDescription = null, contentScale = ContentScale.Crop, modifier = modifier)
    } else {
        KeyboardPreviewPlaceholder(seed = seed, modifier = modifier, cornerRadius = 0.dp)
    }
}

/** White disc, hairline outline, drawn download glyph — reuses the same stem/arrow/tray path
 * Themes' grid cards use. */
@Composable
private fun CommunityDownloadButton(diameter: Dp, modifier: Modifier = Modifier) {
    val density = LocalDensity.current
    Box(
        modifier = modifier
            .shadow(2.dp, CircleShape, ambientColor = Color.Black.copy(alpha = 0.16f), spotColor = Color.Black.copy(alpha = 0.16f))
            .size(diameter)
            .clip(CircleShape)
            .background(Color.White)
            .border(CommunityMetrics.hairline, MochiColor.outline, CircleShape),
        contentAlignment = Alignment.Center
    ) {
        DownloadGlyph(
            color = MochiColor.logoSolid,
            strokeWidth = with(density) { (diameter * 0.095f).toPx() },
            modifier = Modifier.size(diameter * 0.68f)
        )
    }
}

// endregion
