package com.mochi.keyboard.features.wallpapers

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
import androidx.compose.foundation.text.BasicTextField
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material.icons.filled.CheckCircle
import androidx.compose.material.icons.filled.ChevronRight
import androidx.compose.material.icons.filled.Download
import androidx.compose.material.icons.filled.Lock
import androidx.compose.material.icons.filled.LocalFireDepartment
import androidx.compose.material.icons.filled.NightsStay
import androidx.compose.material.icons.filled.Palette
import androidx.compose.material.icons.filled.Park
import androidx.compose.material.icons.filled.PublicOff
import androidx.compose.material.icons.filled.Schedule
import androidx.compose.material.icons.filled.Search
import androidx.compose.material.icons.filled.SentimentSatisfied
import androidx.compose.material3.CircularProgressIndicator
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
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import androidx.lifecycle.viewmodel.compose.viewModel
import com.mochi.keyboard.R
import com.mochi.keyboard.data.model.WallpaperDocument
import com.mochi.keyboard.data.rememberMochiViewModelFactory
import com.mochi.keyboard.designsystem.MochiColor
import com.mochi.keyboard.designsystem.MochiFont
import com.mochi.keyboard.designsystem.MochiGradient
import com.mochi.keyboard.designsystem.MochiRadius
import com.mochi.keyboard.designsystem.MochiSpacing

@Preview(showBackground = true, widthDp = 393, heightDp = 3000)
@Composable
private fun WallpaperExploreScreenPreview() {
    WallpaperExploreScreenContent(wallpapers = mockWallpapers, recentlyDownloaded = mockWallpapers.take(2))
}

private data class WallpaperCategory(val label: String, val icon: ImageVector)
private val categories = listOf(
    WallpaperCategory("Popular", Icons.Filled.LocalFireDepartment),
    WallpaperCategory("Latest", Icons.Filled.Schedule),
    WallpaperCategory("Cute", Icons.Filled.SentimentSatisfied),
    WallpaperCategory("Dark", Icons.Filled.NightsStay),
    WallpaperCategory("Nature", Icons.Filled.Park),
    WallpaperCategory("Space", Icons.Filled.PublicOff)
)

/** Shown while real data loads and if the load fails - reuses the same bundled art keys as
 * [wallpaperArt] so the fallback and real states look identical, matching every other screen's
 * MockData-fallback convention. `liveWallpapers` has no likeCount field in its real schema, so
 * unlike Themes'/Community's card art these never show a like count. */
internal val mockWallpapers = listOf(
    WallpaperDocument(id = "wallpaper_cloudy_day", name = "Cloudy Day", isPremium = true),
    WallpaperDocument(id = "wallpaper_sakura_dream_wp", name = "Sakura Dream", isPremium = false),
    WallpaperDocument(id = "wallpaper_galaxy_explorer", name = "Galaxy Explorer", isPremium = true),
    WallpaperDocument(id = "wallpaper_pastel_dreams", name = "Pastel Dreams", isPremium = true),
    WallpaperDocument(id = "wallpaper_rainbow_bliss", name = "Rainbow Bliss", isPremium = false)
)

private val wallpaperArt: Map<String, Int> = mapOf(
    "wallpaper_moonlight_night" to R.drawable.wallpaper_moonlight_night,
    "wallpaper_cloudy_day" to R.drawable.wallpaper_cloudy_day,
    "wallpaper_sakura_dream_wp" to R.drawable.wallpaper_sakura_dream_wp,
    "wallpaper_galaxy_explorer" to R.drawable.wallpaper_galaxy_explorer,
    "wallpaper_pastel_dreams" to R.drawable.wallpaper_pastel_dreams,
    "wallpaper_night_vibes" to R.drawable.wallpaper_night_vibes,
    "wallpaper_nature_escape" to R.drawable.wallpaper_nature_escape,
    "wallpaper_rainbow_bliss" to R.drawable.wallpaper_rainbow_bliss,
    "wallpaper_evening_glow" to R.drawable.wallpaper_evening_glow,
    "wallpaper_cozy_town" to R.drawable.wallpaper_cozy_town
)

@Composable
private fun WallpaperArtImage(wallpaperId: String, modifier: Modifier = Modifier) {
    val resId = wallpaperArt[wallpaperId]
    if (resId != null) {
        Image(painter = painterResource(resId), contentDescription = null, contentScale = ContentScale.Crop, modifier = modifier)
    } else {
        Box(modifier = modifier.background(MochiColor.purple.copy(alpha = 0.12f)))
    }
}

/**
 * Ported from docs/figma/10.png. That frame uses a wide sidebar+content layout (tablet/desktop
 * style) unlike every other screen in this app, which are all phone-width single columns. Adapted
 * to the same phone-width convention here: the sidebar category list becomes the category icon
 * row already present in the main content, and "Recently Downloaded" + "Go Premium" move inline.
 *
 * WA4 slice 9: wired to real `liveWallpapers` data via WallpaperViewModel. Unlike Themes'/
 * Community's Popular/Collections/Trending, `liveWallpapers` has no likeCount/createdAt/category
 * field to derive distinct real groupings from (see WallpaperRepository) - the original three
 * identically-shaped mock grids collapse into one real "LIVE WALLPAPERS" grid rather than showing
 * the same handful of documents three times under fake labels. Category chips stay decorative
 * (no backing field), same documented-gap treatment as several other unspec'd affordances
 * elsewhere in this app. Download is real but local-only (WallpaperLibraryRepository) - the
 * collection is admin-authored/read-only per firestore.rules, and wiring a downloaded wallpaper
 * into Create > Background is a separate future integration, not part of this slice.
 */
@Composable
fun WallpaperExploreScreen(
    modifier: Modifier = Modifier,
    onBack: () -> Unit = {},
    onUnlockPremium: () -> Unit = {},
    viewModel: WallpaperViewModel = viewModel(factory = rememberMochiViewModelFactory())
) {
    val uiState by viewModel.uiState.collectAsStateWithLifecycle()
    val usingFallback = uiState.allWallpapers.isEmpty()
    val wallpapers = if (usingFallback) {
        mockWallpapers.filter { uiState.query.isBlank() || it.name.contains(uiState.query, ignoreCase = true) }
    } else {
        uiState.filteredWallpapers
    }
    val recentlyDownloaded = if (usingFallback) emptyList() else uiState.recentlyDownloaded

    WallpaperExploreScreenContent(
        modifier = modifier,
        wallpapers = wallpapers,
        recentlyDownloaded = recentlyDownloaded,
        query = uiState.query,
        onQueryChange = viewModel::onQueryChange,
        isUserPremium = uiState.isUserPremium,
        isLoading = uiState.isLoading && usingFallback,
        onBack = onBack,
        onWallpaperTap = { wallpaper ->
            if (wallpaper.isPremium && !uiState.isUserPremium) onUnlockPremium() else viewModel.download(wallpaper)
        },
        onUnlockPremium = onUnlockPremium
    )
}

@Composable
private fun WallpaperExploreScreenContent(
    modifier: Modifier = Modifier,
    wallpapers: List<WallpaperDocument> = mockWallpapers,
    recentlyDownloaded: List<WallpaperDocument> = emptyList(),
    query: String = "",
    onQueryChange: (String) -> Unit = {},
    isUserPremium: Boolean = false,
    isLoading: Boolean = false,
    onBack: () -> Unit = {},
    onWallpaperTap: (WallpaperDocument) -> Unit = {},
    onUnlockPremium: () -> Unit = {}
) {
    var selectedCategory by remember { mutableStateOf("Popular") }

    Box(modifier = modifier.fillMaxSize().background(MochiGradient.background)) {
        Column(
            modifier = Modifier
                .fillMaxSize()
                .verticalScroll(rememberScrollState())
                .padding(horizontal = MochiSpacing.md)
                .padding(top = MochiSpacing.md, bottom = 100.dp),
            verticalArrangement = Arrangement.spacedBy(MochiSpacing.lg)
        ) {
            WallpaperHeader(onBack)
            SearchBar(query, onQueryChange)
            FeaturedBanner()
            CategoryIconRow(selectedCategory) { selectedCategory = it }
            if (isLoading) {
                Box(modifier = Modifier.fillMaxWidth().height(120.dp), contentAlignment = Alignment.Center) {
                    CircularProgressIndicator(color = MochiColor.purple)
                }
            } else {
                WallpaperGridSection("LIVE WALLPAPERS", wallpapers, isUserPremium, onWallpaperTap)
            }
            if (recentlyDownloaded.isNotEmpty()) {
                RecentlyDownloadedSection(recentlyDownloaded)
            }
            GoPremiumBanner(onUnlockPremium)
        }
    }
}

@Composable
private fun WallpaperHeader(onBack: () -> Unit) {
    Column {
        Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(8.dp)) {
            Box(
                modifier = Modifier
                    .size(32.dp)
                    .clip(CircleShape)
                    .background(Color.White)
                    .clickable(onClick = onBack),
                contentAlignment = Alignment.Center
            ) {
                Icon(imageVector = Icons.AutoMirrored.Filled.ArrowBack, contentDescription = "Back", tint = MochiColor.purple, modifier = Modifier.size(16.dp))
            }
            Box(
                modifier = Modifier.size(28.dp).clip(RoundedCornerShape(8.dp)).background(Color.White).border(1.dp, MochiColor.purple.copy(alpha = 0.3f), RoundedCornerShape(8.dp)),
                contentAlignment = Alignment.Center
            ) {
                Icon(imageVector = Icons.Filled.Palette, contentDescription = null, tint = MochiColor.purple, modifier = Modifier.size(16.dp))
            }
            Text(text = "Wallpapers", style = MochiFont.title(24.sp), color = MochiColor.textPrimary)
        }
        Text(text = "Find the perfect wallpaper for your keyboard", style = MochiFont.caption(12.sp), color = MochiColor.textSecondary)
    }
}

@Composable
private fun SearchBar(text: String, onTextChange: (String) -> Unit) {
    Row(
        modifier = Modifier.fillMaxWidth().clip(RoundedCornerShape(MochiRadius.pill)).background(Color.White).padding(horizontal = MochiSpacing.md, vertical = 14.dp),
        verticalAlignment = Alignment.CenterVertically
    ) {
        BasicTextField(
            value = text,
            onValueChange = onTextChange,
            textStyle = MochiFont.body(14.sp).copy(color = MochiColor.textPrimary),
            modifier = Modifier.weight(1f),
            decorationBox = { inner ->
                if (text.isEmpty()) {
                    Text(text = "Search wallpapers..", style = MochiFont.body(14.sp), color = MochiColor.textSecondary)
                }
                inner()
            }
        )
        Icon(imageVector = Icons.Filled.Search, contentDescription = "Search", tint = MochiColor.textPrimary)
    }
}

@Composable
private fun FeaturedBanner() {
    Box(
        modifier = Modifier
            .fillMaxWidth()
            .aspectRatio(1.6f)
            .clip(RoundedCornerShape(MochiRadius.card))
    ) {
        Image(
            painter = painterResource(R.drawable.wallpaper_moonlight_night),
            contentDescription = "Moonlight Night",
            contentScale = ContentScale.Crop,
            modifier = Modifier.fillMaxSize()
        )
    }
}

@Composable
private fun CategoryIconRow(selected: String, onSelect: (String) -> Unit) {
    Row(
        modifier = Modifier.horizontalScroll(rememberScrollState()),
        horizontalArrangement = Arrangement.spacedBy(MochiSpacing.sm)
    ) {
        categories.forEach { category ->
            val isSelected = category.label == selected
            Column(
                modifier = Modifier
                    .size(64.dp)
                    .clip(RoundedCornerShape(MochiRadius.card))
                    .background(Color.White)
                    .border(1.dp, if (isSelected) MochiColor.purple else MochiColor.purple.copy(alpha = 0.15f), RoundedCornerShape(MochiRadius.card))
                    .clickable { onSelect(category.label) }
                    .padding(6.dp),
                horizontalAlignment = Alignment.CenterHorizontally,
                verticalArrangement = Arrangement.Center
            ) {
                Icon(imageVector = category.icon, contentDescription = null, tint = MochiColor.purple, modifier = Modifier.size(18.dp))
                Spacer(modifier = Modifier.height(2.dp))
                Text(text = category.label, style = MochiFont.caption(9.sp), color = MochiColor.textPrimary)
            }
        }
    }
}

@Composable
private fun WallpaperGridSection(title: String, items: List<WallpaperDocument>, isUserPremium: Boolean, onTap: (WallpaperDocument) -> Unit) {
    Column(verticalArrangement = Arrangement.spacedBy(MochiSpacing.sm)) {
        Text(text = title, style = MochiFont.heading(13.sp), color = MochiColor.textPrimary)
        if (items.isEmpty()) {
            Text(text = "No wallpapers found.", style = MochiFont.caption(12.sp), color = MochiColor.textSecondary)
        } else {
            items.chunked(3).forEach { row ->
                Row(horizontalArrangement = Arrangement.spacedBy(MochiSpacing.md)) {
                    row.forEach { item -> WallpaperCard(item, isUserPremium, Modifier.weight(1f), onTap) }
                    repeat(3 - row.size) { Spacer(modifier = Modifier.weight(1f)) }
                }
            }
        }
    }
}

@Composable
private fun WallpaperCard(item: WallpaperDocument, isUserPremium: Boolean, modifier: Modifier = Modifier, onTap: (WallpaperDocument) -> Unit) {
    val isLocked = item.isPremium && !isUserPremium
    Column(
        modifier = modifier.clip(RoundedCornerShape(MochiRadius.card)).background(Color.White).clickable { onTap(item) },
        verticalArrangement = Arrangement.spacedBy(4.dp)
    ) {
        Box {
            WallpaperArtImage(wallpaperId = item.id, modifier = Modifier.fillMaxWidth().aspectRatio(1f))
            if (item.isPremium) {
                Box(
                    modifier = Modifier
                        .align(Alignment.TopEnd)
                        .padding(6.dp)
                        .clip(RoundedCornerShape(MochiRadius.pill))
                        .background(MochiColor.premiumTag)
                        .padding(horizontal = 6.dp, vertical = 3.dp)
                ) {
                    Icon(imageVector = Icons.Filled.Lock, contentDescription = "Premium", tint = Color.White, modifier = Modifier.size(10.dp))
                }
            }
        }
        Column(modifier = Modifier.padding(horizontal = 8.dp, vertical = 4.dp)) {
            Text(text = item.name, style = MochiFont.heading(12.sp), color = MochiColor.textPrimary, maxLines = 1, overflow = TextOverflow.Ellipsis)
            Row(modifier = Modifier.fillMaxWidth(), verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.End) {
                Icon(
                    imageVector = if (isLocked) Icons.Filled.Lock else Icons.Filled.Download,
                    contentDescription = if (isLocked) "Locked" else "Download",
                    tint = MochiColor.purple,
                    modifier = Modifier.size(14.dp)
                )
            }
        }
    }
}

@Composable
private fun RecentlyDownloadedSection(items: List<WallpaperDocument>) {
    Column(verticalArrangement = Arrangement.spacedBy(MochiSpacing.sm)) {
        Text(text = "Recently Downloaded", style = MochiFont.heading(15.sp), color = MochiColor.textPrimary)
        items.forEach { item ->
            Row(
                modifier = Modifier.fillMaxWidth().clip(RoundedCornerShape(MochiRadius.card)).background(Color.White).padding(MochiSpacing.sm),
                verticalAlignment = Alignment.CenterVertically
            ) {
                WallpaperArtImage(wallpaperId = item.id, modifier = Modifier.size(40.dp).clip(RoundedCornerShape(8.dp)))
                Text(text = item.name, style = MochiFont.body(13.sp), color = MochiColor.textPrimary, modifier = Modifier.weight(1f).padding(horizontal = MochiSpacing.sm))
                Icon(imageVector = Icons.Filled.CheckCircle, contentDescription = "Downloaded", tint = MochiColor.purple, modifier = Modifier.size(18.dp))
            }
        }
    }
}

@Composable
private fun GoPremiumBanner(onUnlockPremium: () -> Unit) {
    Row(
        modifier = Modifier.fillMaxWidth().clip(RoundedCornerShape(MochiRadius.card)).background(Color.White).padding(MochiSpacing.md),
        verticalAlignment = Alignment.CenterVertically
    ) {
        Image(painter = painterResource(R.drawable.icon_premium_crown), contentDescription = null, modifier = Modifier.size(48.dp).clip(CircleShape))
        Column(modifier = Modifier.weight(1f).padding(horizontal = MochiSpacing.sm)) {
            Text(text = "Go Premium", style = MochiFont.heading(15.sp), color = MochiColor.purple)
            Text(text = "Unlock premium wallpapers and exclusive collections.", style = MochiFont.caption(11.sp), color = MochiColor.textSecondary)
        }
        Row(
            modifier = Modifier.clip(RoundedCornerShape(MochiRadius.pill)).background(MochiGradient.primaryButton).padding(horizontal = 14.dp, vertical = 8.dp).clickable(onClick = onUnlockPremium)
        ) {
            Text(text = "Upgrade Now", style = MochiFont.caption(12.sp), color = Color.White)
        }
    }
}
