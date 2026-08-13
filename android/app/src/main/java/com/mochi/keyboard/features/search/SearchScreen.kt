package com.mochi.keyboard.features.search

import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.horizontalScroll
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.ExperimentalLayoutApi
import androidx.compose.foundation.layout.FlowRow
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
import androidx.compose.foundation.text.BasicTextField
import androidx.compose.foundation.text.KeyboardActions
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material.icons.automirrored.filled.TrendingUp
import androidx.compose.material.icons.filled.CalendarMonth
import androidx.compose.material.icons.filled.Download
import androidx.compose.material.icons.filled.Favorite
import androidx.compose.material.icons.filled.GridView
import androidx.compose.material.icons.filled.History
import androidx.compose.material.icons.filled.KeyboardArrowDown
import androidx.compose.material.icons.filled.NorthEast
import androidx.compose.material.icons.filled.Palette
import androidx.compose.material.icons.filled.Person
import androidx.compose.material.icons.filled.Refresh
import androidx.compose.material.icons.filled.Schedule
import androidx.compose.material.icons.filled.Search
import androidx.compose.material.icons.filled.WorkspacePremium
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.input.ImeAction
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import androidx.lifecycle.viewmodel.compose.viewModel
import com.mochi.keyboard.R
import com.mochi.keyboard.components.CreatorAvatar
import com.mochi.keyboard.components.FontArtCard
import com.mochi.keyboard.components.ThemeArt
import com.mochi.keyboard.data.rememberMochiViewModelFactory
import com.mochi.keyboard.designsystem.MochiColor
import com.mochi.keyboard.designsystem.MochiFont
import com.mochi.keyboard.designsystem.MochiGradient
import com.mochi.keyboard.designsystem.MochiRadius
import com.mochi.keyboard.designsystem.MochiSpacing
import com.mochi.keyboard.model.FontItem
import com.mochi.keyboard.model.KeyboardTheme
import com.mochi.keyboard.model.formattedCompact

@Preview(showBackground = true, widthDp = 393, heightDp = 3800)
@Composable
private fun SearchScreenPreview() {
    SearchScreenContent(uiState = SearchUiState())
}

/** Curated, not analytics-driven - no per-user search-log or trending-query collection exists
 * anywhere in firestore.rules, so there's nothing real to source these from (same documented gap
 * as Profile's other-user downloads/followers). Still real interactions: tapping any of these
 * chips runs a real search via SearchViewModel.selectChip, same as typing the text by hand. */
private val trendingSearches = listOf("pastel theme", "cute font", "aesthetic keyboard", "galaxy theme", "minimal", "anime theme", "typwriter font", "handwriting")
private val suggestions = listOf("Cute Themes", "Dark Themes", "Handwritten Fonts", "Pixel Art Themes")

private data class FilterOption(val filter: ResultFilter, val icon: ImageVector)
private val filterDropdowns = listOf(
    FilterOption(ResultFilter.ALL_TYPES, Icons.Filled.GridView),
    FilterOption(ResultFilter.FREE_ONLY, Icons.Filled.CalendarMonth),
    FilterOption(ResultFilter.PREMIUM, Icons.Filled.WorkspacePremium),
    FilterOption(ResultFilter.NEWEST, Icons.Filled.Schedule)
)

private sealed interface SearchCard {
    data class ThemeCard(val theme: KeyboardTheme) : SearchCard
    data class FontCard(val font: FontItem) : SearchCard
}

/** Ported from docs/figma/6.png, wired to real data (Session 20, WA4 slice 7). */
@Composable
fun SearchScreen(
    modifier: Modifier = Modifier,
    onBack: () -> Unit = {},
    onThemeClick: (KeyboardTheme) -> Unit = {},
    onCreatorClick: (String) -> Unit = {},
    viewModel: SearchViewModel = viewModel(factory = rememberMochiViewModelFactory())
) {
    val uiState by viewModel.uiState.collectAsStateWithLifecycle()
    SearchScreenContent(
        modifier = modifier,
        uiState = uiState,
        onBack = onBack,
        onThemeClick = onThemeClick,
        onCreatorClick = onCreatorClick,
        onQueryChange = viewModel::onQueryChange,
        onSubmitSearch = { viewModel.submitSearch() },
        onSelectType = viewModel::onSelectType,
        onSelectFilter = viewModel::onSelectFilter,
        onSelectChip = viewModel::selectChip,
        onClearRecent = viewModel::clearRecentSearches,
        onToggleFollow = viewModel::toggleFollow
    )
}

@Composable
private fun SearchScreenContent(
    modifier: Modifier = Modifier,
    uiState: SearchUiState,
    onBack: () -> Unit = {},
    onThemeClick: (KeyboardTheme) -> Unit = {},
    onCreatorClick: (String) -> Unit = {},
    onQueryChange: (String) -> Unit = {},
    onSubmitSearch: () -> Unit = {},
    onSelectType: (SearchType) -> Unit = {},
    onSelectFilter: (ResultFilter) -> Unit = {},
    onSelectChip: (String) -> Unit = {},
    onClearRecent: () -> Unit = {},
    onToggleFollow: (String) -> Unit = {}
) {
    Box(modifier = modifier.fillMaxSize().background(MochiGradient.background)) {
        Column(
            modifier = Modifier
                .fillMaxSize()
                .verticalScroll(rememberScrollState())
                .padding(horizontal = MochiSpacing.md)
                .padding(top = MochiSpacing.md, bottom = 100.dp),
            verticalArrangement = Arrangement.spacedBy(MochiSpacing.lg)
        ) {
            SearchHeader(uiState.query, onQueryChange = onQueryChange, onSearch = onSubmitSearch, onBack = onBack)
            TypeFilterChips(uiState.selectedType, onSelectType)

            if (uiState.isBrowsing) {
                FiltersSection(uiState.activeFilter, onSelectFilter)
                SearchResultsSection(uiState, onThemeClick, onCreatorClick, onToggleFollow, onClearSearch = { onQueryChange(""); onSelectType(SearchType.ALL) })
            } else {
                if (uiState.recentSearches.isNotEmpty()) {
                    RecentSearchesSection(uiState.recentSearches, onSelectChip, onClearRecent)
                }
                TrendingSearchesSection(onSelectChip)
                SuggestionsSection(onSelectChip)
            }
        }
    }
}

@Composable
private fun SearchHeader(query: String, onQueryChange: (String) -> Unit, onSearch: () -> Unit, onBack: () -> Unit) {
    Row(modifier = Modifier.fillMaxWidth(), verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(MochiSpacing.sm)) {
        Box(
            modifier = Modifier.size(44.dp).clip(CircleShape).background(MochiGradient.primaryButton).clickable(onClick = onBack),
            contentAlignment = Alignment.Center
        ) {
            Icon(imageVector = Icons.AutoMirrored.Filled.ArrowBack, contentDescription = "Back", tint = Color.White)
        }
        Row(
            modifier = Modifier
                .weight(1f)
                .clip(RoundedCornerShape(MochiRadius.pill))
                .background(Color.White)
                .padding(horizontal = MochiSpacing.md, vertical = 14.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            BasicTextField(
                value = query,
                onValueChange = onQueryChange,
                textStyle = MochiFont.body(14.sp).copy(color = MochiColor.textPrimary),
                keyboardOptions = KeyboardOptions(imeAction = ImeAction.Search),
                keyboardActions = KeyboardActions(onSearch = { onSearch() }),
                modifier = Modifier.weight(1f),
                decorationBox = { inner ->
                    if (query.isEmpty()) {
                        Text(text = "Search themes, creators..", style = MochiFont.body(14.sp), color = MochiColor.textSecondary)
                    }
                    inner()
                }
            )
            Icon(
                imageVector = Icons.Filled.Search,
                contentDescription = "Search",
                tint = MochiColor.textPrimary,
                modifier = Modifier.clickable(onClick = onSearch)
            )
        }
    }
}

@Composable
private fun TypeFilterChips(selected: SearchType, onSelect: (SearchType) -> Unit) {
    Row(
        modifier = Modifier.horizontalScroll(rememberScrollState()),
        horizontalArrangement = Arrangement.spacedBy(MochiSpacing.sm)
    ) {
        SearchType.entries.forEach { type ->
            val isSelected = type == selected
            Row(
                modifier = Modifier
                    .clip(RoundedCornerShape(MochiRadius.pill))
                    .then(
                        if (isSelected) Modifier.background(MochiGradient.primaryButton)
                        else Modifier.background(Color.White).border(1.dp, MochiColor.purple.copy(alpha = 0.25f), RoundedCornerShape(MochiRadius.pill))
                    )
                    .clickable { onSelect(type) }
                    .padding(horizontal = 16.dp, vertical = 10.dp),
                verticalAlignment = Alignment.CenterVertically,
                horizontalArrangement = Arrangement.spacedBy(6.dp)
            ) {
                if (type == SearchType.FONT) {
                    // Figma draws "Aa" text here, not an icon.
                    Text(text = "Aa", style = MochiFont.heading(14.sp), color = if (isSelected) Color.White else MochiColor.textPrimary)
                } else {
                    val icon: ImageVector? = when (type) {
                        SearchType.ALL -> Icons.Filled.GridView
                        SearchType.THEME -> Icons.Filled.Palette
                        SearchType.CREATORS -> Icons.Filled.Person
                        else -> null
                    }
                    if (icon != null) {
                        Icon(imageVector = icon, contentDescription = null, tint = if (isSelected) Color.White else MochiColor.textPrimary, modifier = Modifier.size(14.dp))
                    }
                }
                Text(text = type.label, style = MochiFont.heading(13.sp), color = if (isSelected) Color.White else MochiColor.textPrimary)
            }
        }
    }
}

@Composable
private fun SectionCard(content: @Composable androidx.compose.foundation.layout.ColumnScope.() -> Unit) {
    Column(
        modifier = Modifier.fillMaxWidth().clip(RoundedCornerShape(MochiRadius.card)).background(Color.White).padding(MochiSpacing.md),
        verticalArrangement = Arrangement.spacedBy(MochiSpacing.sm),
        content = content
    )
}

@Composable
private fun RecentSearchesSection(recentSearches: List<String>, onSelectChip: (String) -> Unit, onClearAll: () -> Unit) {
    SectionCard {
        Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceBetween, verticalAlignment = Alignment.CenterVertically) {
            Text(text = "RECENT SEARCHES", style = MochiFont.heading(13.sp), color = MochiColor.textPrimary)
            Text(text = "Clear All", style = MochiFont.caption(12.sp), color = MochiColor.textSecondary, modifier = Modifier.clickable(onClick = onClearAll))
        }
        Row(modifier = Modifier.horizontalScroll(rememberScrollState()), horizontalArrangement = Arrangement.spacedBy(8.dp)) {
            recentSearches.forEach { PillChip(it, Icons.Filled.History, onClick = { onSelectChip(it) }) }
        }
    }
}

@OptIn(ExperimentalLayoutApi::class)
@Composable
private fun TrendingSearchesSection(onSelectChip: (String) -> Unit) {
    SectionCard {
        Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceBetween, verticalAlignment = Alignment.CenterVertically) {
            Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(4.dp)) {
                Icon(imageVector = Icons.AutoMirrored.Filled.TrendingUp, contentDescription = null, tint = MochiColor.textPrimary, modifier = Modifier.size(14.dp))
                Text(text = "TRENDING SEARCHES", style = MochiFont.heading(13.sp), color = MochiColor.textPrimary)
            }
            Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(4.dp)) {
                Text(text = "Refresh", style = MochiFont.caption(12.sp), color = MochiColor.textSecondary)
                Icon(imageVector = Icons.Filled.Refresh, contentDescription = null, tint = MochiColor.textSecondary, modifier = Modifier.size(12.dp))
            }
        }
        androidx.compose.foundation.layout.FlowRow(horizontalArrangement = Arrangement.spacedBy(8.dp), verticalArrangement = Arrangement.spacedBy(8.dp)) {
            trendingSearches.forEach { PillChip(it, Icons.AutoMirrored.Filled.TrendingUp, onClick = { onSelectChip(it) }) }
        }
    }
}

@Composable
private fun PillChip(label: String, icon: ImageVector, onClick: () -> Unit) {
    Row(
        modifier = Modifier
            .clip(RoundedCornerShape(MochiRadius.pill))
            .background(Color.White)
            .border(1.dp, MochiColor.purple.copy(alpha = 0.25f), RoundedCornerShape(MochiRadius.pill))
            .clickable(onClick = onClick)
            .padding(horizontal = 12.dp, vertical = 8.dp),
        verticalAlignment = Alignment.CenterVertically,
        horizontalArrangement = Arrangement.spacedBy(4.dp)
    ) {
        Icon(imageVector = icon, contentDescription = null, tint = MochiColor.textSecondary, modifier = Modifier.size(12.dp))
        Text(text = label, style = MochiFont.caption(12.sp), color = MochiColor.textPrimary)
    }
}

@Composable
private fun SuggestionsSection(onSelectChip: (String) -> Unit) {
    SectionCard {
        Text(text = "SUGGESTIONS", style = MochiFont.heading(13.sp), color = MochiColor.textPrimary)
        suggestions.forEach { suggestion ->
            Row(
                modifier = Modifier.fillMaxWidth().clickable { onSelectChip(suggestion) }.padding(vertical = 6.dp),
                verticalAlignment = Alignment.CenterVertically
            ) {
                Icon(imageVector = Icons.Filled.Search, contentDescription = null, tint = MochiColor.textSecondary, modifier = Modifier.size(16.dp))
                Text(text = suggestion, style = MochiFont.body(13.sp), color = MochiColor.textSecondary, modifier = Modifier.weight(1f).padding(horizontal = 8.dp))
                Icon(imageVector = Icons.Filled.NorthEast, contentDescription = null, tint = MochiColor.textSecondary, modifier = Modifier.size(14.dp))
            }
        }
    }
}

@Composable
private fun FiltersSection(active: ResultFilter, onSelectFilter: (ResultFilter) -> Unit) {
    Column(verticalArrangement = Arrangement.spacedBy(MochiSpacing.sm)) {
        Text(text = "FILTERS", style = MochiFont.heading(13.sp), color = MochiColor.textPrimary)
        Row(modifier = Modifier.horizontalScroll(rememberScrollState()), horizontalArrangement = Arrangement.spacedBy(8.dp)) {
            filterDropdowns.forEach { option ->
                val isSelected = option.filter == active
                Row(
                    modifier = Modifier
                        .clip(RoundedCornerShape(MochiRadius.pill))
                        .then(
                            if (isSelected) Modifier.background(MochiGradient.primaryButton)
                            else Modifier.background(Color.White).border(1.dp, MochiColor.purple.copy(alpha = 0.25f), RoundedCornerShape(MochiRadius.pill))
                        )
                        .clickable { onSelectFilter(option.filter) }
                        .padding(horizontal = 12.dp, vertical = 8.dp),
                    verticalAlignment = Alignment.CenterVertically,
                    horizontalArrangement = Arrangement.spacedBy(4.dp)
                ) {
                    Icon(imageVector = option.icon, contentDescription = null, tint = if (isSelected) Color.White else MochiColor.textPrimary, modifier = Modifier.size(13.dp))
                    Text(text = option.filter.label, style = MochiFont.caption(12.sp), color = if (isSelected) Color.White else MochiColor.textPrimary)
                    Icon(imageVector = Icons.Filled.KeyboardArrowDown, contentDescription = null, tint = if (isSelected) Color.White else MochiColor.textPrimary, modifier = Modifier.size(14.dp))
                }
            }
        }
    }
}

@Composable
private fun SearchResultsSection(
    uiState: SearchUiState,
    onThemeClick: (KeyboardTheme) -> Unit,
    onCreatorClick: (String) -> Unit,
    onToggleFollow: (String) -> Unit,
    onClearSearch: () -> Unit
) {
    if (uiState.selectedType == SearchType.CREATORS) {
        Column(verticalArrangement = Arrangement.spacedBy(MochiSpacing.sm)) {
            Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceBetween) {
                Text(text = "SEARCH RESULTS", style = MochiFont.heading(13.sp), color = MochiColor.textPrimary)
                Text(text = "${uiState.creatorResults.size} Results", style = MochiFont.caption(12.sp), color = MochiColor.textSecondary)
            }
            if (uiState.creatorResults.isEmpty()) {
                if (!uiState.poolsLoading) NoResultsCard(uiState.query, onClearSearch)
            } else {
                Column(verticalArrangement = Arrangement.spacedBy(MochiSpacing.sm)) {
                    uiState.creatorResults.forEach { creator ->
                        CreatorResultRow(creator, onClick = { onCreatorClick(creator.uid) }, onToggleFollow = { onToggleFollow(creator.uid) })
                    }
                }
            }
        }
        return
    }

    val cards: List<SearchCard> = when (uiState.selectedType) {
        SearchType.THEME -> uiState.themeResults.map { SearchCard.ThemeCard(it) }
        SearchType.FONT -> uiState.fontResults.map { SearchCard.FontCard(it) }
        else -> uiState.themeResults.map { SearchCard.ThemeCard(it) } + uiState.fontResults.map { SearchCard.FontCard(it) }
    }

    Column(verticalArrangement = Arrangement.spacedBy(MochiSpacing.sm)) {
        Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceBetween) {
            Text(text = "SEARCH RESULTS", style = MochiFont.heading(13.sp), color = MochiColor.textPrimary)
            Text(text = "${cards.size} Results", style = MochiFont.caption(12.sp), color = MochiColor.textSecondary)
        }
        if (cards.isEmpty()) {
            if (!uiState.poolsLoading) NoResultsCard(uiState.query, onClearSearch)
        } else {
            Column(verticalArrangement = Arrangement.spacedBy(MochiSpacing.md)) {
                cards.chunked(4).forEach { row ->
                    Row(horizontalArrangement = Arrangement.spacedBy(MochiSpacing.sm)) {
                        row.forEach { card -> ResultCard(card, onThemeClick, Modifier.weight(1f)) }
                        repeat(4 - row.size) { Spacer(modifier = Modifier.weight(1f)) }
                    }
                }
            }
        }
    }
}

@Composable
private fun ResultCard(card: SearchCard, onThemeClick: (KeyboardTheme) -> Unit, modifier: Modifier = Modifier) {
    Column(
        modifier = modifier
            .clip(RoundedCornerShape(MochiRadius.card))
            .background(Color.White)
            .then(if (card is SearchCard.ThemeCard) Modifier.clickable { onThemeClick(card.theme) } else Modifier),
        verticalArrangement = Arrangement.spacedBy(4.dp)
    ) {
        when (card) {
            is SearchCard.ThemeCard -> Box {
                ThemeArt(assetName = card.theme.imageAssetName, seed = card.theme.name, modifier = Modifier.fillMaxWidth().aspectRatio(1f))
                Icon(
                    imageVector = Icons.Filled.Download,
                    contentDescription = null,
                    tint = Color.White,
                    modifier = Modifier.align(Alignment.TopEnd).padding(6.dp).clip(CircleShape).background(Color.Black.copy(alpha = 0.3f)).size(22.dp).padding(4.dp)
                )
            }
            is SearchCard.FontCard -> FontArtCard(assetName = card.font.previewAssetName, modifier = Modifier.fillMaxWidth().aspectRatio(1f)) {
                Box(modifier = Modifier.fillMaxWidth().aspectRatio(1f).background(Color(0xFFE8F2FC)))
            }
        }
        Column(modifier = Modifier.padding(horizontal = 6.dp, vertical = 4.dp), verticalArrangement = Arrangement.spacedBy(2.dp)) {
            when (card) {
                is SearchCard.ThemeCard -> {
                    Text(text = card.theme.name, style = MochiFont.heading(11.sp), color = MochiColor.textPrimary, maxLines = 2, overflow = TextOverflow.Ellipsis)
                    Text(text = "Theme", style = MochiFont.caption(10.sp), color = MochiColor.purple)
                    Row(modifier = Modifier.fillMaxWidth(), verticalAlignment = Alignment.CenterVertically) {
                        Icon(imageVector = Icons.Filled.Favorite, contentDescription = null, tint = MochiColor.pink, modifier = Modifier.size(9.dp))
                        Spacer(modifier = Modifier.width(2.dp))
                        Text(text = card.theme.likeCountFormatted, style = MochiFont.caption(9.sp), color = MochiColor.textSecondary, modifier = Modifier.weight(1f), maxLines = 1)
                        Icon(imageVector = Icons.Filled.Download, contentDescription = null, tint = MochiColor.textSecondary, modifier = Modifier.size(9.dp))
                        Spacer(modifier = Modifier.width(2.dp))
                        Text(text = card.theme.downloadCount.formattedCompact(), style = MochiFont.caption(9.sp), color = MochiColor.textSecondary, maxLines = 1)
                    }
                }
                is SearchCard.FontCard -> {
                    Text(text = card.font.name, style = MochiFont.heading(11.sp), color = MochiColor.textPrimary, maxLines = 2, overflow = TextOverflow.Ellipsis)
                    Text(text = if (card.font.isPremium) "Font · Premium" else "Font · Free", style = MochiFont.caption(10.sp), color = MochiColor.purple)
                }
            }
        }
    }
}

@Composable
private fun CreatorResultRow(creator: SearchCreatorUi, onClick: () -> Unit, onToggleFollow: () -> Unit) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .clip(RoundedCornerShape(MochiRadius.card))
            .background(Color.White)
            .clickable(onClick = onClick)
            .padding(MochiSpacing.md),
        verticalAlignment = Alignment.CenterVertically,
        horizontalArrangement = Arrangement.spacedBy(MochiSpacing.sm)
    ) {
        CreatorAvatar(assetName = "", modifier = Modifier.size(44.dp).clip(CircleShape))
        Column(modifier = Modifier.weight(1f)) {
            Text(text = creator.displayName, style = MochiFont.heading(14.sp), color = MochiColor.textPrimary, maxLines = 1, overflow = TextOverflow.Ellipsis)
            Text(text = "${creator.themeCount} Themes", style = MochiFont.caption(12.sp), color = MochiColor.textSecondary)
        }
        Box(
            modifier = Modifier
                .clip(RoundedCornerShape(MochiRadius.pill))
                .then(
                    if (creator.isFollowing) Modifier.background(Color.White).border(1.dp, MochiColor.purple.copy(alpha = 0.3f), RoundedCornerShape(MochiRadius.pill))
                    else Modifier.background(MochiGradient.primaryButton)
                )
                .clickable(onClick = onToggleFollow)
                .padding(horizontal = 16.dp, vertical = 8.dp)
        ) {
            Text(
                text = if (creator.isFollowing) "Following" else "Follow",
                style = MochiFont.body(12.sp),
                color = if (creator.isFollowing) MochiColor.purple else Color.White
            )
        }
    }
}

@Composable
private fun NoResultsCard(query: String, onClearSearch: () -> Unit) {
    Column(
        modifier = Modifier.fillMaxWidth().clip(RoundedCornerShape(MochiRadius.card)).background(Color.White).padding(MochiSpacing.md),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.spacedBy(MochiSpacing.sm)
    ) {
        Row(modifier = Modifier.fillMaxWidth()) {
            Text(text = "NO RESULTS", style = MochiFont.heading(13.sp), color = MochiColor.textPrimary)
        }
        Image(painter = painterResource(R.drawable.icon_sad_mochi), contentDescription = null, contentScale = ContentScale.Crop, modifier = Modifier.size(72.dp).clip(CircleShape))
        Text(
            text = if (query.isBlank()) "No results found." else "No results found for \"$query\"",
            style = MochiFont.heading(15.sp),
            color = MochiColor.purple
        )
        Text(
            text = "Try different keywords or browse categories instead.",
            style = MochiFont.caption(12.sp),
            color = MochiColor.textSecondary,
            textAlign = androidx.compose.ui.text.style.TextAlign.Center
        )
        Row(
            modifier = Modifier
                .clip(RoundedCornerShape(MochiRadius.pill))
                .border(1.dp, MochiColor.purple.copy(alpha = 0.3f), RoundedCornerShape(MochiRadius.pill))
                .clickable(onClick = onClearSearch)
                .padding(horizontal = 16.dp, vertical = 10.dp)
        ) {
            Text(text = "Clear Search", style = MochiFont.caption(13.sp), color = MochiColor.purple)
        }
    }
}
