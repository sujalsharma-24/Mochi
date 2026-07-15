package com.mochi.app.features.search

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
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material.icons.automirrored.filled.TrendingUp
import androidx.compose.material.icons.filled.CalendarMonth
import androidx.compose.material.icons.filled.Download
import androidx.compose.material.icons.filled.Favorite
import androidx.compose.material.icons.filled.GridView
import androidx.compose.material.icons.filled.History
import androidx.compose.material.icons.filled.MoreVert
import androidx.compose.material.icons.filled.NorthEast
import androidx.compose.material.icons.filled.Palette
import androidx.compose.material.icons.filled.Person
import androidx.compose.material.icons.filled.Refresh
import androidx.compose.material.icons.filled.Schedule
import androidx.compose.material.icons.filled.Search
import androidx.compose.material.icons.filled.TextFields
import androidx.compose.material.icons.filled.WorkspacePremium
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
import androidx.compose.ui.layout.ContentScale
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

@Preview(showBackground = true, widthDp = 393, heightDp = 3800)
@Composable
private fun SearchScreenPreview() {
    SearchScreen()
}

private val typeFilters = listOf("All", "Theme", "Font", "Creators")
private val recentSearches = listOf("cotton candy", "handwritten font", "neon night", "mochi studio")
private val trendingSearches = listOf("pastel theme", "cute font", "aesthetic keyboard", "galaxy theme", "minimal", "anime theme", "typwriter font", "handwriting")
private val suggestions = listOf("Cute Themes", "Dark Themes", "Handwritten Fonts", "Pixel Art Themes")
private val filterDropdowns = listOf(Triple("All Types", Icons.Filled.GridView, true), Triple("Free Only", Icons.Filled.CalendarMonth, false), Triple("Premium", Icons.Filled.WorkspacePremium, false), Triple("Newest", Icons.Filled.Schedule, false))

private data class ResultItem(val name: String, val label: String, val likeCount: String, val downloadCount: String, val assetName: String, val isFont: Boolean = false)

private val searchResults = listOf(
    ResultItem("Pastel Rainbow", "Theme", "12.5K", "3.4K", "theme_pastel_rainbow"),
    ResultItem("Forest Theme", "Theme", "908", "2.6K", "theme_forest"),
    ResultItem("Pastel Pink Sky", "Theme", "12.5K", "3.1K", "theme_pastel_pink_sky"),
    ResultItem("Typewriter Classic", "Font", "755", "1.8K", "font_shop_typewriter_classic", isFont = true),
    ResultItem("Sakura Train", "Theme", "10K", "2.4K", "theme_sakura_train"),
    ResultItem("Space vibe", "Theme", "805", "1.6K", "theme_space_vibe"),
    ResultItem("Bold Strong", "Font", "10K", "2.1K", "font_shop_bold_strong", isFont = true),
    ResultItem("Gothic Dark", "Font", "650", "1K", "font_shop_gothic_dark", isFont = true)
)

/** Ported from docs/figma/6.png */
@Composable
fun SearchScreen(modifier: Modifier = Modifier, onBack: () -> Unit = {}) {
    var query by remember { mutableStateOf("") }
    var selectedType by remember { mutableStateOf("All") }

    Box(modifier = modifier.fillMaxSize().background(MochiGradient.background)) {
        Column(
            modifier = Modifier
                .fillMaxSize()
                .verticalScroll(rememberScrollState())
                .padding(horizontal = MochiSpacing.md)
                .padding(top = MochiSpacing.md, bottom = 100.dp),
            verticalArrangement = Arrangement.spacedBy(MochiSpacing.lg)
        ) {
            SearchHeader(query, onQueryChange = { query = it }, onBack = onBack)
            TypeFilterChips(selectedType) { selectedType = it }
            RecentSearchesSection()
            TrendingSearchesSection()
            SuggestionsSection()
            FiltersSection()
            SearchResultsSection()
            NoResultsCard()
        }
    }
}

@Composable
private fun SearchHeader(query: String, onQueryChange: (String) -> Unit, onBack: () -> Unit) {
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
                modifier = Modifier.weight(1f),
                decorationBox = { inner ->
                    if (query.isEmpty()) {
                        Text(text = "Search themes, creators..", style = MochiFont.body(14.sp), color = MochiColor.textSecondary)
                    }
                    inner()
                }
            )
            Icon(imageVector = Icons.Filled.Search, contentDescription = "Search", tint = MochiColor.textPrimary)
        }
    }
}

@Composable
private fun TypeFilterChips(selected: String, onSelect: (String) -> Unit) {
    Row(
        modifier = Modifier.horizontalScroll(rememberScrollState()),
        horizontalArrangement = Arrangement.spacedBy(MochiSpacing.sm)
    ) {
        typeFilters.forEach { type ->
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
                val icon: ImageVector? = when (type) {
                    "Theme" -> Icons.Filled.Palette
                    "Font" -> Icons.Filled.TextFields
                    "Creators" -> Icons.Filled.Person
                    else -> null
                }
                if (icon != null) {
                    Icon(imageVector = icon, contentDescription = null, tint = if (isSelected) Color.White else MochiColor.textPrimary, modifier = Modifier.size(14.dp))
                }
                Text(text = type, style = MochiFont.heading(13.sp), color = if (isSelected) Color.White else MochiColor.textPrimary)
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
private fun RecentSearchesSection() {
    SectionCard {
        Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceBetween, verticalAlignment = Alignment.CenterVertically) {
            Text(text = "RECENT SEARCHES", style = MochiFont.heading(13.sp), color = MochiColor.textPrimary)
            Text(text = "Clear All", style = MochiFont.caption(12.sp), color = MochiColor.textSecondary)
        }
        Row(modifier = Modifier.horizontalScroll(rememberScrollState()), horizontalArrangement = Arrangement.spacedBy(8.dp)) {
            recentSearches.forEach { PillChip(it, Icons.Filled.History) }
        }
    }
}

@OptIn(ExperimentalLayoutApi::class)
@Composable
private fun TrendingSearchesSection() {
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
            trendingSearches.forEach { PillChip(it, Icons.AutoMirrored.Filled.TrendingUp) }
        }
    }
}

@Composable
private fun PillChip(label: String, icon: ImageVector) {
    Row(
        modifier = Modifier
            .clip(RoundedCornerShape(MochiRadius.pill))
            .background(Color.White)
            .border(1.dp, MochiColor.purple.copy(alpha = 0.25f), RoundedCornerShape(MochiRadius.pill))
            .padding(horizontal = 12.dp, vertical = 8.dp),
        verticalAlignment = Alignment.CenterVertically,
        horizontalArrangement = Arrangement.spacedBy(4.dp)
    ) {
        Icon(imageVector = icon, contentDescription = null, tint = MochiColor.textSecondary, modifier = Modifier.size(12.dp))
        Text(text = label, style = MochiFont.caption(12.sp), color = MochiColor.textPrimary)
    }
}

@Composable
private fun SuggestionsSection() {
    SectionCard {
        Text(text = "SUGGESTIONS", style = MochiFont.heading(13.sp), color = MochiColor.textPrimary)
        suggestions.forEach { suggestion ->
            Row(modifier = Modifier.fillMaxWidth().padding(vertical = 6.dp), verticalAlignment = Alignment.CenterVertically) {
                Icon(imageVector = Icons.Filled.Search, contentDescription = null, tint = MochiColor.textSecondary, modifier = Modifier.size(16.dp))
                Text(text = suggestion, style = MochiFont.body(13.sp), color = MochiColor.textSecondary, modifier = Modifier.weight(1f).padding(horizontal = 8.dp))
                Icon(imageVector = Icons.Filled.NorthEast, contentDescription = null, tint = MochiColor.textSecondary, modifier = Modifier.size(14.dp))
            }
        }
    }
}

@Composable
private fun FiltersSection() {
    Column(verticalArrangement = Arrangement.spacedBy(MochiSpacing.sm)) {
        Text(text = "FILTERS", style = MochiFont.heading(13.sp), color = MochiColor.textPrimary)
        Row(modifier = Modifier.horizontalScroll(rememberScrollState()), horizontalArrangement = Arrangement.spacedBy(8.dp)) {
            filterDropdowns.forEach { (label, icon, isSelected) ->
                Row(
                    modifier = Modifier
                        .clip(RoundedCornerShape(MochiRadius.pill))
                        .then(
                            if (isSelected) Modifier.background(MochiGradient.primaryButton)
                            else Modifier.background(Color.White).border(1.dp, MochiColor.purple.copy(alpha = 0.25f), RoundedCornerShape(MochiRadius.pill))
                        )
                        .padding(horizontal = 12.dp, vertical = 8.dp),
                    verticalAlignment = Alignment.CenterVertically,
                    horizontalArrangement = Arrangement.spacedBy(4.dp)
                ) {
                    Icon(imageVector = icon, contentDescription = null, tint = if (isSelected) Color.White else MochiColor.textPrimary, modifier = Modifier.size(13.dp))
                    Text(text = label, style = MochiFont.caption(12.sp), color = if (isSelected) Color.White else MochiColor.textPrimary)
                    Text(text = "⌄", style = MochiFont.caption(12.sp), color = if (isSelected) Color.White else MochiColor.textPrimary)
                }
            }
        }
    }
}

@Composable
private fun SearchResultsSection() {
    Column(verticalArrangement = Arrangement.spacedBy(MochiSpacing.sm)) {
        Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceBetween) {
            Text(text = "SEARCH RESULTS", style = MochiFont.heading(13.sp), color = MochiColor.textPrimary)
            Text(text = "128 Results", style = MochiFont.caption(12.sp), color = MochiColor.textSecondary)
        }
        Column(verticalArrangement = Arrangement.spacedBy(MochiSpacing.md)) {
            searchResults.chunked(2).forEach { row ->
                Row(horizontalArrangement = Arrangement.spacedBy(MochiSpacing.md)) {
                    row.forEach { item -> ResultCard(item, Modifier.weight(1f)) }
                    repeat(2 - row.size) { Spacer(modifier = Modifier.weight(1f)) }
                }
            }
        }
    }
}

@Composable
private fun ResultCard(item: ResultItem, modifier: Modifier = Modifier) {
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
                modifier = Modifier.align(Alignment.TopEnd).padding(6.dp).clip(CircleShape).background(Color.Black.copy(alpha = 0.3f)).size(22.dp)
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
private fun NoResultsCard() {
    Column(
        modifier = Modifier.fillMaxWidth().clip(RoundedCornerShape(MochiRadius.card)).background(Color.White).padding(MochiSpacing.md),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.spacedBy(MochiSpacing.sm)
    ) {
        Row(modifier = Modifier.fillMaxWidth()) {
            Text(text = "NO RESULTS", style = MochiFont.heading(13.sp), color = MochiColor.textPrimary)
        }
        Image(painter = painterResource(R.drawable.icon_sad_mochi), contentDescription = null, contentScale = ContentScale.Crop, modifier = Modifier.size(72.dp).clip(CircleShape))
        Text(text = "No results found for \"dreamy night\"", style = MochiFont.heading(15.sp), color = MochiColor.purple)
        Text(
            text = "Try different keywords or browse categories instead.",
            style = MochiFont.caption(12.sp),
            color = MochiColor.textSecondary
        )
        Row(
            modifier = Modifier
                .clip(RoundedCornerShape(MochiRadius.pill))
                .border(1.dp, MochiColor.purple.copy(alpha = 0.3f), RoundedCornerShape(MochiRadius.pill))
                .padding(horizontal = 16.dp, vertical = 10.dp)
        ) {
            Text(text = "Clear Search", style = MochiFont.caption(13.sp), color = MochiColor.purple)
        }
    }
}
