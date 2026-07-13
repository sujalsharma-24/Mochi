package com.mochi.app.features.wallpapers

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
import androidx.compose.material.icons.filled.ChevronRight
import androidx.compose.material.icons.filled.Download
import androidx.compose.material.icons.filled.Favorite
import androidx.compose.material.icons.filled.LocalFireDepartment
import androidx.compose.material.icons.filled.MoreHoriz
import androidx.compose.material.icons.filled.NightsStay
import androidx.compose.material.icons.filled.Palette
import androidx.compose.material.icons.filled.Park
import androidx.compose.material.icons.filled.PublicOff
import androidx.compose.material.icons.filled.Schedule
import androidx.compose.material.icons.filled.Search
import androidx.compose.material.icons.filled.SentimentSatisfied
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
import com.mochi.app.designsystem.MochiColor
import com.mochi.app.designsystem.MochiFont
import com.mochi.app.designsystem.MochiGradient
import com.mochi.app.designsystem.MochiRadius
import com.mochi.app.designsystem.MochiSpacing

@Preview(showBackground = true, widthDp = 393, heightDp = 3400)
@Composable
private fun WallpaperExploreScreenPreview() {
    WallpaperExploreScreen()
}

private data class WallpaperCategory(val label: String, val icon: ImageVector)
private val categories = listOf(
    WallpaperCategory("Popular", Icons.Filled.LocalFireDepartment),
    WallpaperCategory("Latest", Icons.Filled.Schedule),
    WallpaperCategory("Cute", Icons.Filled.SentimentSatisfied),
    WallpaperCategory("Dark", Icons.Filled.NightsStay),
    WallpaperCategory("Nature", Icons.Filled.Park),
    WallpaperCategory("Space", Icons.Filled.PublicOff),
    WallpaperCategory("More", Icons.Filled.MoreHoriz)
)

private data class WallpaperItem(val name: String, val likeCount: String, val assetName: String)
private val popularThemes = listOf(
    WallpaperItem("Cloudy Day", "12.5K", "wallpaper_cloudy_day"),
    WallpaperItem("Sakura Dream", "908", "wallpaper_sakura_dream_wp"),
    WallpaperItem("Galaxy Explorer", "12.5K", "wallpaper_galaxy_explorer")
)
private val collections = listOf(
    WallpaperItem("Pastel Dreams", "1.5K", "wallpaper_pastel_dreams"),
    WallpaperItem("Night Vibes", "505", "wallpaper_night_vibes"),
    WallpaperItem("Nature Escape", "13.5K", "wallpaper_nature_escape")
)
private val trendingNow = listOf(
    WallpaperItem("Rainbow Bliss", "15.3K", "wallpaper_rainbow_bliss"),
    WallpaperItem("Evening Glow", "10.2K", "wallpaper_evening_glow"),
    WallpaperItem("Cozy Town", "8.5K", "wallpaper_cozy_town")
)
private val recentlyDownloaded = listOf(
    WallpaperItem("Moonlight Night", "", "wallpaper_moonlight_night"),
    WallpaperItem("Sakura Dream", "", "wallpaper_sakura_dream_wp"),
    WallpaperItem("Forest Flow", "", "wallpaper_nature_escape"),
    WallpaperItem("Rainbow Bliss", "", "wallpaper_rainbow_bliss")
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

/**
 * Ported from docs/figma/10.png. That frame uses a wide sidebar+content layout (tablet/desktop
 * style) unlike every other screen in this app, which are all phone-width single columns. Adapted
 * to the same phone-width convention here: the sidebar category list becomes the category icon
 * row already present in the main content, and "Recently Downloaded" + "Go Premium" move inline.
 */
@Composable
fun WallpaperExploreScreen(modifier: Modifier = Modifier) {
    var query by remember { mutableStateOf("") }
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
            WallpaperHeader()
            SearchBar(query) { query = it }
            FeaturedBanner()
            CategoryIconRow(selectedCategory) { selectedCategory = it }
            WallpaperGridSection("POPULAR THEMES", popularThemes, trailingIcon = Icons.Filled.Download)
            WallpaperGridSection("COLLECTIONS", collections, trailingIcon = Icons.Filled.ChevronRight)
            WallpaperGridSection("TRENDING NOW", trendingNow, trailingIcon = Icons.Filled.Download)
            RecentlyDownloadedSection()
            GoPremiumBanner()
        }
    }
}

@Composable
private fun WallpaperHeader() {
    Column {
        Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(8.dp)) {
            Box(
                modifier = Modifier.size(28.dp).clip(RoundedCornerShape(8.dp)).background(Color.White).border(1.dp, MochiColor.purple.copy(alpha = 0.3f), RoundedCornerShape(8.dp)),
                contentAlignment = Alignment.Center
            ) {
                Icon(imageVector = Icons.Filled.Palette, contentDescription = null, tint = MochiColor.purple, modifier = Modifier.size(16.dp))
            }
            Text(text = "Themes", style = MochiFont.title(24.sp), color = MochiColor.textPrimary)
        }
        Text(text = "Find the perfect wallpaper & theme for your device", style = MochiFont.caption(12.sp), color = MochiColor.textSecondary)
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
                    Text(text = "Search themes, creators..", style = MochiFont.body(14.sp), color = MochiColor.textSecondary)
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
        // Figma bakes the title/description/button into this hero image; a transparent click
        // target sits over the "View Theme" button area so it stays a real tappable control.
        Box(
            modifier = Modifier
                .align(Alignment.BottomStart)
                .padding(MochiSpacing.md)
                .size(width = 130.dp, height = 36.dp)
                .clip(RoundedCornerShape(MochiRadius.pill))
                .clickable {}
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
private fun WallpaperGridSection(title: String, items: List<WallpaperItem>, trailingIcon: ImageVector) {
    Column(verticalArrangement = Arrangement.spacedBy(MochiSpacing.sm)) {
        Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceBetween) {
            Text(text = title, style = MochiFont.heading(13.sp), color = MochiColor.textPrimary)
            Text(text = "see all", style = MochiFont.caption(13.sp), color = MochiColor.purple)
        }
        Row(horizontalArrangement = Arrangement.spacedBy(MochiSpacing.md)) {
            items.forEach { item -> WallpaperCard(item, trailingIcon, Modifier.weight(1f)) }
        }
    }
}

@Composable
private fun WallpaperCard(item: WallpaperItem, trailingIcon: ImageVector, modifier: Modifier = Modifier) {
    Column(
        modifier = modifier.clip(RoundedCornerShape(MochiRadius.card)).background(Color.White),
        verticalArrangement = Arrangement.spacedBy(4.dp)
    ) {
        val resId = wallpaperArt[item.assetName]
        if (resId != null) {
            Image(painter = painterResource(resId), contentDescription = item.name, contentScale = ContentScale.Crop, modifier = Modifier.fillMaxWidth().aspectRatio(1f))
        }
        Column(modifier = Modifier.padding(horizontal = 8.dp, vertical = 4.dp)) {
            Text(text = item.name, style = MochiFont.heading(12.sp), color = MochiColor.textPrimary, maxLines = 1, overflow = TextOverflow.Ellipsis)
            Row(modifier = Modifier.fillMaxWidth(), verticalAlignment = Alignment.CenterVertically) {
                Icon(imageVector = Icons.Filled.Favorite, contentDescription = null, tint = MochiColor.pink, modifier = Modifier.size(10.dp))
                Spacer(modifier = Modifier.width(3.dp))
                Text(text = item.likeCount, style = MochiFont.caption(10.sp), color = MochiColor.textSecondary, modifier = Modifier.weight(1f))
                Icon(imageVector = trailingIcon, contentDescription = null, tint = MochiColor.purple, modifier = Modifier.size(14.dp))
            }
        }
    }
}

@Composable
private fun RecentlyDownloadedSection() {
    Column(verticalArrangement = Arrangement.spacedBy(MochiSpacing.sm)) {
        Text(text = "Recently Downloaded", style = MochiFont.heading(15.sp), color = MochiColor.textPrimary)
        recentlyDownloaded.forEach { item ->
            Row(
                modifier = Modifier.fillMaxWidth().clip(RoundedCornerShape(MochiRadius.card)).background(Color.White).padding(MochiSpacing.sm),
                verticalAlignment = Alignment.CenterVertically
            ) {
                val resId = wallpaperArt[item.assetName]
                if (resId != null) {
                    Image(painter = painterResource(resId), contentDescription = null, contentScale = ContentScale.Crop, modifier = Modifier.size(40.dp).clip(RoundedCornerShape(8.dp)))
                }
                Text(text = item.name, style = MochiFont.body(13.sp), color = MochiColor.textPrimary, modifier = Modifier.weight(1f).padding(horizontal = MochiSpacing.sm))
                Box(
                    modifier = Modifier.size(28.dp).clip(CircleShape).border(1.dp, MochiColor.purple.copy(alpha = 0.3f), CircleShape),
                    contentAlignment = Alignment.Center
                ) {
                    Icon(imageVector = Icons.Filled.Download, contentDescription = null, tint = MochiColor.purple, modifier = Modifier.size(14.dp))
                }
            }
        }
    }
}

@Composable
private fun GoPremiumBanner() {
    Row(
        modifier = Modifier.fillMaxWidth().clip(RoundedCornerShape(MochiRadius.card)).background(Color.White).padding(MochiSpacing.md),
        verticalAlignment = Alignment.CenterVertically
    ) {
        Image(painter = painterResource(R.drawable.icon_premium_crown), contentDescription = null, modifier = Modifier.size(48.dp).clip(CircleShape))
        Column(modifier = Modifier.weight(1f).padding(horizontal = MochiSpacing.sm)) {
            Text(text = "Go Premium", style = MochiFont.heading(15.sp), color = MochiColor.purple)
            Text(text = "Unlock premium themes and exclusive collections.", style = MochiFont.caption(11.sp), color = MochiColor.textSecondary)
        }
        Row(
            modifier = Modifier.clip(RoundedCornerShape(MochiRadius.pill)).background(MochiGradient.primaryButton).padding(horizontal = 14.dp, vertical = 8.dp)
        ) {
            Text(text = "Upgrade Now", style = MochiFont.caption(12.sp), color = Color.White)
        }
    }
}
