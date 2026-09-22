package com.mochi.keyboard.features.wallpapers

import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.horizontalScroll
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.BoxWithConstraints
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.aspectRatio
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.layout.windowInsetsPadding
import androidx.compose.foundation.layout.WindowInsets
import androidx.compose.foundation.layout.statusBars
import androidx.compose.foundation.layout.navigationBars
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.BasicTextField
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material.icons.automirrored.filled.KeyboardArrowRight
import androidx.compose.material.icons.filled.AutoAwesome
import androidx.compose.material.icons.filled.Check
import androidx.compose.material.icons.filled.CheckCircle
import androidx.compose.material.icons.filled.Close
import androidx.compose.material.icons.filled.Diamond
import androidx.compose.material.icons.filled.Download
import androidx.compose.material.icons.filled.Favorite
import androidx.compose.material.icons.filled.FavoriteBorder
import androidx.compose.material.icons.filled.Groups
import androidx.compose.material.icons.filled.Home
import androidx.compose.material.icons.filled.MoreHoriz
import androidx.compose.material.icons.filled.Photo
import androidx.compose.material.icons.filled.Search
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.Icon
import androidx.compose.material3.ModalBottomSheet
import androidx.compose.material3.Text
import androidx.compose.material3.rememberModalBottomSheetState
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableFloatStateOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.blur
import androidx.compose.ui.draw.clip
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.ColorFilter
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import androidx.lifecycle.viewmodel.compose.viewModel
import com.mochi.keyboard.R
import com.mochi.keyboard.components.KeyboardPreviewPlaceholder
import com.mochi.keyboard.components.SparkleField
import com.mochi.keyboard.data.WallpaperApplier
import com.mochi.keyboard.data.WallpaperCatalog
import com.mochi.keyboard.data.rememberMochiViewModelFactory
import com.mochi.keyboard.designsystem.MochiColor
import com.mochi.keyboard.designsystem.MochiFont
import com.mochi.keyboard.designsystem.MochiGradient
import com.mochi.keyboard.designsystem.WallpaperMetrics
import com.mochi.keyboard.model.WallpaperCategory
import com.mochi.keyboard.model.WallpaperCollection
import com.mochi.keyboard.model.WallpaperCropAnchor
import com.mochi.keyboard.model.WallpaperFilter
import com.mochi.keyboard.model.WallpaperItem
import com.mochi.keyboard.model.WallpaperPage
import com.mochi.keyboard.model.WallpaperSection
import kotlinx.coroutines.launch

@Preview(showBackground = true, widthDp = 393, heightDp = 900)
@Composable
private fun WallpaperExploreScreenPreview() {
    WallpaperExploreContent(
        page = WallpaperPage.Discover,
        query = "",
        downloadedIds = emptyList(),
        appliedId = null,
        isUserPremium = false
    )
}

/**
 * Ported from `ios/MochiApp/Features/Wallpapers/WallpapersView.swift`: a fixed left nav rail plus a
 * content pane whose body swaps between discovery/theme/section/collection pages - one screen, many
 * pages, exactly like iOS, not a re-adaptation into a single scrolling column (unlike most other
 * screens in this app, this one's rail+pane structure *is* part of what the user explicitly asked to
 * port, not incidental layout iOS happened to pick).
 *
 * The 75-wallpaper bundled catalogue ([WallpaperCatalog]) is the primary content, matching iOS's own
 * (now backend-free) design. Android's pre-existing, already-verified live Firestore wallpapers
 * feature ([WallpaperViewModel]/`WallpaperRepository`) is folded in as one more rail/chip entry
 * ([WallpaperFilter.COMMUNITY]) rather than removed - additive preservation, the same call Session 27
 * made for Themes' built-in catalogue vs. its existing Firestore-backed grid.
 *
 * Apply sets the device wallpaper directly via [com.mochi.keyboard.data.WallpaperApplier]
 * (`WallpaperManager`) - a real capability iOS has no public API for, so this deliberately does not
 * copy iOS's save-to-Photos-then-share-sheet workaround (Session 28, confirmed with Sujal).
 */
@Composable
fun WallpaperExploreScreen(
    modifier: Modifier = Modifier,
    onBack: () -> Unit = {},
    onUnlockPremium: () -> Unit = {},
    viewModel: WallpaperExploreViewModel = viewModel(factory = rememberMochiViewModelFactory()),
    communityViewModel: WallpaperViewModel = viewModel(factory = rememberMochiViewModelFactory())
) {
    val downloadedIds by viewModel.downloadedIds.collectAsStateWithLifecycle()
    val appliedId by viewModel.appliedWallpaperId.collectAsStateWithLifecycle()
    val isUserPremium by viewModel.isUserPremium.collectAsStateWithLifecycle()
    val communityState by communityViewModel.uiState.collectAsStateWithLifecycle()

    var query by remember { mutableStateOf("") }
    var stack by remember { mutableStateOf(listOf<WallpaperPage>()) }
    var previewItem by remember { mutableStateOf<WallpaperItem?>(null) }
    var moreSheet by remember { mutableStateOf(false) }

    val page = stack.lastOrNull() ?: WallpaperPage.Discover
    val isSearching = query.isNotBlank()

    fun push(destination: WallpaperPage) {
        query = ""
        stack = stack + destination
    }

    fun goBack() {
        when {
            isSearching -> query = ""
            stack.isEmpty() -> onBack()
            else -> stack = stack.dropLast(1)
        }
    }

    fun selectFilter(filter: WallpaperFilter) {
        query = ""
        stack = when (filter) {
            WallpaperFilter.MORE -> { moreSheet = true; stack }
            WallpaperFilter.ALL -> emptyList()
            WallpaperFilter.POPULAR -> listOf(WallpaperPage.Section(WallpaperSection.POPULAR))
            WallpaperFilter.LATEST -> listOf(WallpaperPage.Section(WallpaperSection.TRENDING))
            WallpaperFilter.COMMUNITY -> listOf(WallpaperPage.Community)
            else -> filter.category?.let { listOf(WallpaperPage.Theme(it)) } ?: emptyList()
        }
    }

    WallpaperExploreContent(
        page = page,
        query = query,
        onQueryChange = { query = it },
        isSearching = isSearching,
        downloadedIds = downloadedIds,
        appliedId = appliedId,
        isUserPremium = isUserPremium,
        onBack = ::goBack,
        onPush = ::push,
        onSelectFilter = ::selectFilter,
        onOpenPreview = { previewItem = it },
        onToggleDownload = { item -> viewModel.toggleDownload(item, item.id in downloadedIds) },
        onUnlockPremium = onUnlockPremium,
        moreSheetOpen = moreSheet,
        onMoreSheetDismiss = { moreSheet = false },
        communityWallpapers = communityState.allWallpapers,
        communityLoading = communityState.isLoading && communityState.allWallpapers.isEmpty()
    )

    previewItem?.let { item ->
        WallpaperPreviewOverlay(
            item = item,
            isDownloaded = item.id in downloadedIds,
            onToggleDownload = { viewModel.toggleDownload(item, item.id in downloadedIds) },
            onApply = { target -> viewModel.apply(item, target) },
            onSaveToGallery = { viewModel.saveToGallery(item) },
            onClose = { previewItem = null }
        )
    }
}

@Composable
private fun WallpaperExploreContent(
    page: WallpaperPage,
    query: String,
    onQueryChange: (String) -> Unit = {},
    isSearching: Boolean = false,
    downloadedIds: List<String> = emptyList(),
    appliedId: String? = null,
    isUserPremium: Boolean = false,
    onBack: () -> Unit = {},
    onPush: (WallpaperPage) -> Unit = {},
    onSelectFilter: (WallpaperFilter) -> Unit = {},
    onOpenPreview: (WallpaperItem) -> Unit = {},
    onToggleDownload: (WallpaperItem) -> Unit = {},
    onUnlockPremium: () -> Unit = {},
    moreSheetOpen: Boolean = false,
    onMoreSheetDismiss: () -> Unit = {},
    communityWallpapers: List<com.mochi.keyboard.data.model.WallpaperDocument> = emptyList(),
    communityLoading: Boolean = false
) {
    val recentlyDownloaded = remember(downloadedIds) { downloadedIds.mapNotNull(WallpaperCatalog::wallpaper) }
    val activeFilter = remember(page, isSearching) {
        when {
            isSearching -> null
            page is WallpaperPage.Theme -> WallpaperFilter.entries.firstOrNull { it.category == page.category }
            page is WallpaperPage.Community -> WallpaperFilter.COMMUNITY
            page is WallpaperPage.Discover -> WallpaperFilter.ALL
            else -> null
        }
    }

    BoxWithConstraints(modifier = Modifier.fillMaxSize()) {
        val m = remember(maxWidth) { WallpaperMetrics(maxWidth.value) }

        Box(modifier = Modifier.fillMaxSize()) {
            Image(
                painter = painterResource(R.drawable.themes_background),
                contentDescription = null,
                contentScale = ContentScale.Crop,
                modifier = Modifier.fillMaxSize()
            )
            SparkleField(modifier = Modifier.fillMaxSize())

            ContentPane(
                m = m,
                page = page,
                query = query,
                onQueryChange = onQueryChange,
                isSearching = isSearching,
                downloadedIds = downloadedIds,
                appliedId = appliedId,
                onBack = onBack,
                onPush = onPush,
                onOpenPreview = onOpenPreview,
                communityWallpapers = communityWallpapers,
                communityLoading = communityLoading,
                railWidth = m.railWidth
            )

            Rail(
                m = m,
                page = page,
                activeFilter = activeFilter,
                recentlyDownloaded = recentlyDownloaded,
                isUserPremium = isUserPremium,
                onBack = onBack,
                onSelectFilter = onSelectFilter,
                onOpenPreview = onOpenPreview,
                onToggleDownload = onToggleDownload,
                onViewAllDownloads = { onPush(WallpaperPage.Section(WallpaperSection.DOWNLOADS)) },
                onUnlockPremium = onUnlockPremium,
                modifier = Modifier.width(m.railWidth)
            )
        }
    }

    if (moreSheetOpen) {
        MoreFilterSheet(
            onSelect = { category -> onSelectFilter(WallpaperFilter.entries.first { it.category == category }) },
            onDismiss = onMoreSheetDismiss
        )
    }
}

/** Approximates SwiftUI's `.minimumScaleFactor` for the rail title, which has just enough room for
 * "Wallpapers" at full size on some widths and not others - same technique `FontsScreen.kt`'s own
 * `ShrinkToFitText` uses, shrinking one step per recomposition until the single line fits rather
 * than truncating it mid-word. */
@Composable
private fun ShrinkToFitText(text: String, style: TextStyle, color: Color, minScale: Float, modifier: Modifier = Modifier) {
    var scale by remember(text) { mutableFloatStateOf(1f) }
    Text(
        text = text,
        style = style.copy(fontSize = style.fontSize * scale),
        color = color,
        maxLines = 1,
        softWrap = false,
        overflow = TextOverflow.Clip,
        modifier = modifier,
        onTextLayout = { result ->
            if (result.didOverflowWidth && scale > minScale) {
                scale = (scale - 0.05f).coerceAtLeast(minScale)
            }
        }
    )
}

// region Rail

private val railGradient = Brush.verticalGradient(
    colors = listOf(Color(0xFFC25EBF), Color(0xFFF7A8BF), Color(0xFFBD87DB), Color(0xFF7880DE))
)

@Composable
private fun Rail(
    m: WallpaperMetrics,
    page: WallpaperPage,
    activeFilter: WallpaperFilter?,
    recentlyDownloaded: List<WallpaperItem>,
    isUserPremium: Boolean,
    onBack: () -> Unit,
    onSelectFilter: (WallpaperFilter) -> Unit,
    onOpenPreview: (WallpaperItem) -> Unit,
    onToggleDownload: (WallpaperItem) -> Unit,
    onViewAllDownloads: () -> Unit,
    onUnlockPremium: () -> Unit,
    modifier: Modifier = Modifier
) {
    Column(
        modifier = modifier
            .fillMaxSize()
            .background(railGradient)
            .verticalScroll(rememberScrollState())
            .padding(horizontal = m.railPadH)
            .padding(top = m.railTop)
            .padding(bottom = 24.dp)
            .windowInsetsPadding(WindowInsets.statusBars),
        verticalArrangement = Arrangement.spacedBy(m.railGap)
    ) {
        RailHeader(m, onBack)
        RailNav(m, activeFilter, onSelectFilter)
        RailRecent(m, recentlyDownloaded, onOpenPreview, onToggleDownload)
        RailViewAll(m, onViewAllDownloads)
        Spacer(modifier = Modifier.height(m.railGap))
        GoPremiumCard(m, onUnlockPremium)
    }
}

@Composable
private fun RailHeader(m: WallpaperMetrics, onBack: () -> Unit) {
    Column(verticalArrangement = Arrangement.spacedBy(3.dp)) {
        Icon(
            imageVector = Icons.AutoMirrored.Filled.ArrowBack,
            contentDescription = "Back",
            tint = MochiColor.textPrimary,
            modifier = Modifier
                .clickable(onClick = onBack)
                .padding(end = 6.dp, top = 2.dp, bottom = 2.dp)
                .size(with(androidx.compose.ui.platform.LocalDensity.current) { (m.railTitle.toPx() * 0.7f).toDp() })
        )
        Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(5.dp), modifier = Modifier.fillMaxWidth()) {
            Box(
                modifier = Modifier
                    .size(m.railTitle.value.dp * 1.15f)
                    .clip(RoundedCornerShape(5.dp))
                    .background(Color.White),
                contentAlignment = Alignment.Center
            ) {
                Icon(
                    imageVector = Icons.Filled.Photo,
                    contentDescription = null,
                    tint = MochiColor.logoSolid,
                    modifier = Modifier.size(m.railTitle.value.dp * 0.65f)
                )
            }
            ShrinkToFitText(
                text = "Wallpapers",
                style = MochiFont.title(m.railTitle),
                color = MochiColor.textPrimary,
                minScale = 0.6f,
                modifier = Modifier.weight(1f, fill = false)
            )
        }
        Text(
            text = "Find the perfect wallpaper & theme for your device",
            style = MochiFont.caption(m.railSubtitle),
            color = MochiColor.textPrimary.copy(alpha = 0.75f)
        )
    }
}

@Composable
private fun RailNav(m: WallpaperMetrics, activeFilter: WallpaperFilter?, onSelectFilter: (WallpaperFilter) -> Unit) {
    Column(
        verticalArrangement = Arrangement.spacedBy(m.railNavGap),
        modifier = Modifier.padding(top = m.railNavDrop)
    ) {
        WallpaperFilter.railCases.forEach { filter ->
            val isSelected = activeFilter == filter
            Row(
                verticalAlignment = Alignment.CenterVertically,
                horizontalArrangement = Arrangement.spacedBy(6.dp),
                modifier = Modifier
                    .fillMaxWidth()
                    .clip(CircleShape)
                    .then(if (isSelected) Modifier.background(Color.White) else Modifier)
                    .clickable { onSelectFilter(filter) }
                    .padding(
                        horizontal = if (isSelected) 10.dp else 0.dp,
                        vertical = if (isSelected) m.railPillH.value.dp * 0.28f else 0.dp
                    )
            ) {
                FilterIcon(filter = filter, size = m.railNav.value.dp * 0.95f, tint = MochiColor.textPrimary)
                Text(
                    text = filter.label,
                    style = MochiFont.body(m.railNav),
                    color = if (isSelected) MochiColor.logoSolid else MochiColor.textPrimary,
                    maxLines = 1
                )
            }
        }
    }
}

@Composable
private fun RailRecent(
    m: WallpaperMetrics,
    recentlyDownloaded: List<WallpaperItem>,
    onOpenPreview: (WallpaperItem) -> Unit,
    onToggleDownload: (WallpaperItem) -> Unit
) {
    Column(
        verticalArrangement = Arrangement.spacedBy(m.railNavGap.value.dp * 0.8f),
        modifier = Modifier.padding(top = m.railRecentDrop)
    ) {
        Text(text = "Recently Downloaded", style = MochiFont.heading(m.railSectionHeading), color = MochiColor.textPrimary, maxLines = 1)
        if (recentlyDownloaded.isEmpty()) {
            Text(
                text = "Downloads you keep show up here.",
                style = MochiFont.caption(m.railRecentName),
                color = MochiColor.textPrimary.copy(alpha = 0.6f)
            )
        } else {
            recentlyDownloaded.take(4).forEach { item ->
                Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(5.dp)) {
                    WallpaperArt(
                        assetName = item.assetName,
                        cropAnchor = item.cropAnchor,
                        modifier = Modifier
                            .size(m.railThumb)
                            .clip(RoundedCornerShape(3.dp))
                            .clickable { onOpenPreview(item) }
                    )
                    Text(
                        text = item.name,
                        style = MochiFont.body(m.railRecentName),
                        color = MochiColor.textPrimary,
                        maxLines = 1,
                        overflow = TextOverflow.Ellipsis,
                        modifier = Modifier.weight(1f)
                    )
                    Icon(
                        imageVector = Icons.Filled.CheckCircle,
                        contentDescription = "Remove",
                        tint = MochiColor.logoSolid,
                        modifier = Modifier
                            .size(m.railRecentName.value.dp * 1.3f)
                            .clip(CircleShape)
                            .background(Color.White)
                            .clickable { onToggleDownload(item) }
                            .padding(2.dp)
                    )
                }
            }
        }
    }
}

@Composable
private fun RailViewAll(m: WallpaperMetrics, onClick: () -> Unit) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .clip(CircleShape)
            .background(Color.White)
            .clickable(onClick = onClick)
            .padding(vertical = 7.dp, horizontal = 12.dp),
        horizontalArrangement = Arrangement.Center,
        verticalAlignment = Alignment.CenterVertically
    ) {
        Text(text = "View All Downloads", style = MochiFont.body(m.railButton), color = MochiColor.logoSolid, maxLines = 1)
        Icon(
            imageVector = Icons.AutoMirrored.Filled.KeyboardArrowRight,
            contentDescription = null,
            tint = MochiColor.logoSolid,
            modifier = Modifier.size(m.railButton.value.dp)
        )
    }
}

@Composable
private fun GoPremiumCard(m: WallpaperMetrics, onUnlockPremium: () -> Unit) {
    Column(
        modifier = Modifier
            .fillMaxWidth()
            .clip(RoundedCornerShape(m.goPremiumRadius))
            .background(Color.White)
            .padding(10.dp),
        verticalArrangement = Arrangement.spacedBy(4.dp)
    ) {
        Image(
            painter = painterResource(R.drawable.icon_premium_crown),
            contentDescription = null,
            modifier = Modifier.size(m.goPremiumTitle.value.dp * 2.1f)
        )
        Text(text = "GO PREMIUM", style = MochiFont.title(m.goPremiumTitle), color = MochiColor.logoSolid)
        Text(
            text = "Unlock premium themes, fonts, and exclusive collections.",
            style = MochiFont.caption(m.goPremiumBody),
            color = MochiColor.textPrimary.copy(alpha = 0.65f)
        )
        Row(
            modifier = Modifier
                .padding(top = 2.dp)
                .clip(CircleShape)
                .background(MochiGradient.primaryButton)
                .clickable(onClick = onUnlockPremium)
                .padding(vertical = 6.dp, horizontal = 14.dp)
        ) {
            Text(text = "Upgrade Now", style = MochiFont.body(m.goPremiumButton), color = Color.White)
        }
    }
}

// endregion

// region Content pane

@Composable
private fun ContentPane(
    m: WallpaperMetrics,
    page: WallpaperPage,
    query: String,
    onQueryChange: (String) -> Unit,
    isSearching: Boolean,
    downloadedIds: List<String>,
    appliedId: String?,
    onBack: () -> Unit,
    onPush: (WallpaperPage) -> Unit,
    onOpenPreview: (WallpaperItem) -> Unit,
    communityWallpapers: List<com.mochi.keyboard.data.model.WallpaperDocument>,
    communityLoading: Boolean,
    railWidth: androidx.compose.ui.unit.Dp
) {
    Column(
        modifier = Modifier
            .fillMaxSize()
            .verticalScroll(rememberScrollState())
            .windowInsetsPadding(WindowInsets.statusBars)
            .padding(start = railWidth + m.contentPadH, end = m.contentPadH)
            .padding(top = m.contentTop)
            .padding(bottom = 100.dp),
        verticalArrangement = Arrangement.spacedBy(m.sectionGap)
    ) {
        SearchBar(m, query, onQueryChange)
        if (isSearching) {
            SearchResultsBody(m, query, downloadedIds, appliedId, onOpenPreview)
        } else {
            when (page) {
                is WallpaperPage.Discover -> DiscoverBody(m, downloadedIds, appliedId, onOpenPreview, onPush)
                is WallpaperPage.Theme -> ThemeBody(m, page.category, downloadedIds, appliedId, onBack, onOpenPreview)
                is WallpaperPage.Section -> SectionBody(m, page.section, downloadedIds, appliedId, onBack, onOpenPreview)
                is WallpaperPage.Collection -> CollectionBody(m, page.id, downloadedIds, appliedId, onBack, onOpenPreview)
                is WallpaperPage.Community -> CommunityBody(m, communityWallpapers, communityLoading, onBack)
            }
        }
    }
}

@Composable
private fun SearchBar(m: WallpaperMetrics, query: String, onQueryChange: (String) -> Unit) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .height(m.searchHeight)
            .clip(RoundedCornerShape(m.searchRadius))
            .background(Color.White)
            .border(m.hairline, MochiColor.logoSolid.copy(alpha = 0.25f), RoundedCornerShape(m.searchRadius))
            .padding(horizontal = m.searchPadH),
        verticalAlignment = Alignment.CenterVertically,
        horizontalArrangement = Arrangement.spacedBy(6.dp)
    ) {
        BasicTextField(
            value = query,
            onValueChange = onQueryChange,
            textStyle = MochiFont.body(m.search).copy(color = MochiColor.textPrimary),
            singleLine = true,
            modifier = Modifier.weight(1f),
            decorationBox = { inner ->
                if (query.isEmpty()) {
                    Text(text = "Search wallpapers, collections…", style = MochiFont.body(m.search), color = MochiColor.textSecondary)
                }
                inner()
            }
        )
        if (query.isNotEmpty()) {
            Icon(
                imageVector = Icons.Filled.Close,
                contentDescription = "Clear",
                tint = MochiColor.textPrimary.copy(alpha = 0.5f),
                modifier = Modifier.clickable { onQueryChange("") }.size(m.search.value.dp * 1.3f)
            )
        } else {
            Icon(
                imageVector = Icons.Filled.Search,
                contentDescription = null,
                tint = MochiColor.textPrimary.copy(alpha = 0.6f),
                modifier = Modifier.size(m.search.value.dp * 1.3f)
            )
        }
    }
}

// region Page bodies

@Composable
private fun DiscoverBody(
    m: WallpaperMetrics,
    downloadedIds: List<String>,
    appliedId: String?,
    onOpenPreview: (WallpaperItem) -> Unit,
    onPush: (WallpaperPage) -> Unit
) {
    Column(verticalArrangement = Arrangement.spacedBy(m.sectionGap)) {
        Banner(m, WallpaperCatalog.featured, WallpaperCatalog.featured.tagline, onOpenPreview)
        ChipRow(m, activeFilter = WallpaperFilter.ALL, onSelectFilter = { filter ->
            when (filter) {
                WallpaperFilter.POPULAR -> onPush(WallpaperPage.Section(WallpaperSection.POPULAR))
                WallpaperFilter.LATEST -> onPush(WallpaperPage.Section(WallpaperSection.TRENDING))
                WallpaperFilter.COMMUNITY -> onPush(WallpaperPage.Community)
                else -> filter.category?.let { onPush(WallpaperPage.Theme(it)) }
            }
        })
        WallpaperSectionHeader(m, WallpaperSection.POPULAR.title, onSeeAll = { onPush(WallpaperPage.Section(WallpaperSection.POPULAR)) })
        CardGrid(m, WallpaperCatalog.popular.take(m.popularColumns * m.popularRows), downloadedIds, onOpenPreview)
        WallpaperSectionHeader(m, WallpaperSection.COLLECTIONS.title, onSeeAll = { onPush(WallpaperPage.Section(WallpaperSection.COLLECTIONS)) })
        CollectionsRow(m) { collection -> onPush(WallpaperPage.Collection(collection.id)) }
        WallpaperSectionHeader(m, WallpaperSection.TRENDING.title, onSeeAll = { onPush(WallpaperPage.Section(WallpaperSection.TRENDING)) })
        CardRow(m, WallpaperCatalog.trending, downloadedIds, onOpenPreview)
    }
}

@Composable
private fun ThemeBody(
    m: WallpaperMetrics,
    category: WallpaperCategory,
    downloadedIds: List<String>,
    appliedId: String?,
    onBack: () -> Unit,
    onOpenPreview: (WallpaperItem) -> Unit
) {
    val items = remember(category) { WallpaperCatalog.wallpapers(inCategory = category) }
    Column(verticalArrangement = Arrangement.spacedBy(m.sectionGap)) {
        WallpaperCatalog.wallpaper(category.bannerId)?.let { Banner(m, it, category.tagline, onOpenPreview) }
        ChipRow(m, activeFilter = WallpaperFilter.entries.firstOrNull { it.category == category }, onSelectFilter = {})
        PageHeading(m, "${category.title.uppercase()} WALLPAPERS", items.size, hasBack = true, onBack = onBack)
        TileGrid(m, items, downloadedIds, onOpenPreview)
    }
}

@Composable
private fun SectionBody(
    m: WallpaperMetrics,
    section: WallpaperSection,
    downloadedIds: List<String>,
    appliedId: String?,
    onBack: () -> Unit,
    onOpenPreview: (WallpaperItem) -> Unit
) {
    val recentlyDownloaded = remember(downloadedIds) { downloadedIds.mapNotNull(WallpaperCatalog::wallpaper) }
    val items = remember(section, recentlyDownloaded) {
        when (section) {
            WallpaperSection.POPULAR -> WallpaperCatalog.popular
            WallpaperSection.TRENDING -> WallpaperCatalog.trending
            WallpaperSection.DOWNLOADS -> recentlyDownloaded
            WallpaperSection.COLLECTIONS -> WallpaperCatalog.collections.mapNotNull { WallpaperCatalog.wallpaper(it.coverId) }
        }
    }
    val bannerArt = remember(section, recentlyDownloaded) {
        when (section) {
            WallpaperSection.POPULAR -> WallpaperCatalog.popular.firstOrNull()
            WallpaperSection.TRENDING -> WallpaperCatalog.trending.firstOrNull()
            WallpaperSection.COLLECTIONS -> WallpaperCatalog.collections.firstOrNull()?.let { WallpaperCatalog.wallpaper(it.coverId) }
            WallpaperSection.DOWNLOADS -> recentlyDownloaded.firstOrNull()
        }
    }
    val tagline = when (section) {
        WallpaperSection.POPULAR -> "The most-loved wallpapers, pulled from every theme in the catalogue."
        WallpaperSection.TRENDING -> "New arrivals and what everyone is downloading right now."
        WallpaperSection.COLLECTIONS -> "${WallpaperCatalog.collections.size} hand-picked sets, grouped by mood."
        WallpaperSection.DOWNLOADS -> "Everything you've kept, ready to apply again."
    }

    Column(verticalArrangement = Arrangement.spacedBy(m.sectionGap)) {
        bannerArt?.let { Banner(m, it, tagline, onOpenPreview, titleOverride = section.title.lowercase().replaceFirstChar { it.uppercase() }) }
        PageHeading(m, section.title, items.size, hasBack = true, onBack = onBack)
        if (items.isEmpty()) {
            EmptyState(m, if (section == WallpaperSection.DOWNLOADS) "Downloads you keep show up here." else "New wallpapers are on the way.")
        } else if (section == WallpaperSection.COLLECTIONS) {
            CollectionsGrid(m) { }
        } else {
            TileGrid(m, items, downloadedIds, onOpenPreview)
        }
    }
}

@Composable
private fun CollectionBody(
    m: WallpaperMetrics,
    id: String,
    downloadedIds: List<String>,
    appliedId: String?,
    onBack: () -> Unit,
    onOpenPreview: (WallpaperItem) -> Unit
) {
    val collection = remember(id) { WallpaperCatalog.collection(id) } ?: return
    val items = remember(collection) { WallpaperCatalog.members(collection) }
    Column(verticalArrangement = Arrangement.spacedBy(m.sectionGap)) {
        WallpaperCatalog.wallpaper(collection.coverId)?.let {
            Banner(m, it, "${items.size} wallpapers in ${collection.name}.", onOpenPreview, titleOverride = collection.name)
        }
        PageHeading(m, collection.name.uppercase(), items.size, hasBack = true, onBack = onBack)
        TileGrid(m, items, downloadedIds, onOpenPreview)
    }
}

@Composable
private fun SearchResultsBody(
    m: WallpaperMetrics,
    query: String,
    downloadedIds: List<String>,
    appliedId: String?,
    onOpenPreview: (WallpaperItem) -> Unit
) {
    val items = remember(query) { WallpaperCatalog.search(query) }
    Column(verticalArrangement = Arrangement.spacedBy(m.sectionGap)) {
        PageHeading(m, "RESULTS", items.size, hasBack = false, onBack = {})
        if (items.isEmpty()) EmptyState(m, "No wallpapers match “$query”.") else TileGrid(m, items, downloadedIds, onOpenPreview)
    }
}

/** Android's existing, already-verified live Firestore wallpapers feature, folded into the new
 * rail/pane structure rather than removed - see the file-level doc comment. Reuses the tile-grid
 * look so it doesn't read as a bolted-on different design. */
@Composable
private fun CommunityBody(
    m: WallpaperMetrics,
    wallpapers: List<com.mochi.keyboard.data.model.WallpaperDocument>,
    isLoading: Boolean,
    onBack: () -> Unit
) {
    Column(verticalArrangement = Arrangement.spacedBy(m.sectionGap)) {
        PageHeading(m, "COMMUNITY", wallpapers.size, hasBack = true, onBack = onBack)
        if (isLoading) {
            Box(modifier = Modifier.fillMaxWidth().height(120.dp), contentAlignment = Alignment.Center) {
                Text(text = "Loading…", style = MochiFont.caption(m.cardMeta), color = MochiColor.textPrimary.copy(alpha = 0.6f))
            }
        } else if (wallpapers.isEmpty()) {
            EmptyState(m, "No community wallpapers yet.")
        } else {
            Column(verticalArrangement = Arrangement.spacedBy(m.gridGutter)) {
                wallpapers.chunked(m.gridColumns).forEach { row ->
                    Row(horizontalArrangement = Arrangement.spacedBy(m.gridGutter)) {
                        row.forEach { doc ->
                            Column(
                                modifier = Modifier
                                    .weight(1f)
                                    .clip(RoundedCornerShape(m.gridRadius))
                            ) {
                                WallpaperArt(
                                    assetName = doc.id,
                                    cropAnchor = WallpaperCropAnchor.CENTER,
                                    modifier = Modifier.fillMaxWidth().aspectRatio(m.tileAspect)
                                )
                                Column(modifier = Modifier.fillMaxWidth().background(Color.White).padding(horizontal = m.cardPadH * 0.8f, vertical = 5.dp)) {
                                    Text(text = doc.name, style = MochiFont.heading(m.cardName), color = MochiColor.textPrimary, maxLines = 1, overflow = TextOverflow.Ellipsis)
                                }
                            }
                        }
                        repeat(m.gridColumns - row.size) { Spacer(modifier = Modifier.weight(1f)) }
                    }
                }
            }
        }
    }
}

// endregion

// region Banner

@Composable
private fun Banner(
    m: WallpaperMetrics,
    item: WallpaperItem,
    tagline: String?,
    onOpenPreview: (WallpaperItem) -> Unit,
    titleOverride: String? = null
) {
    Box(
        modifier = Modifier
            .fillMaxWidth()
            .aspectRatio(m.bannerAspect)
            .clip(RoundedCornerShape(m.bannerRadius))
    ) {
        WallpaperArt(assetName = item.assetName, cropAnchor = item.cropAnchor, modifier = Modifier.fillMaxSize())
        Box(
            modifier = Modifier
                .fillMaxSize()
                .background(Brush.horizontalGradient(listOf(Color.Black.copy(alpha = 0.5f), Color.Black.copy(alpha = 0.05f), Color.Transparent)))
        )
        Column(
            modifier = Modifier.align(Alignment.CenterStart).padding(m.bannerPad),
            verticalArrangement = Arrangement.spacedBy(4.dp)
        ) {
            Text(text = titleOverride ?: item.name, style = MochiFont.title(m.bannerTitle), color = Color.White)
            if (tagline != null) {
                Text(text = tagline, style = MochiFont.caption(m.bannerDesc), color = Color.White.copy(alpha = 0.85f), maxLines = 2)
            }
            Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(4.dp), modifier = Modifier.padding(top = 1.dp)) {
                Icon(imageVector = Icons.Filled.Favorite, contentDescription = null, tint = MochiColor.heart, modifier = Modifier.size(m.bannerMeta.value.dp))
                Text(text = item.likeCountText, style = MochiFont.caption(m.bannerMeta), color = Color.White)
            }
            Row(
                verticalAlignment = Alignment.CenterVertically,
                horizontalArrangement = Arrangement.spacedBy(3.dp),
                modifier = Modifier
                    .padding(top = 3.dp)
                    .clip(CircleShape)
                    .background(Color.White)
                    .clickable { onOpenPreview(item) }
                    .padding(vertical = 5.dp, horizontal = 11.dp)
            ) {
                Text(text = "View Wallpaper", style = MochiFont.body(m.bannerButton), color = MochiColor.logoSolid)
                Icon(imageVector = Icons.AutoMirrored.Filled.KeyboardArrowRight, contentDescription = null, tint = MochiColor.logoSolid, modifier = Modifier.size(m.bannerButton.value.dp * 0.8f))
            }
        }
    }
}

// endregion

// region Chips

@Composable
private fun ChipRow(m: WallpaperMetrics, activeFilter: WallpaperFilter?, onSelectFilter: (WallpaperFilter) -> Unit) {
    Row(modifier = Modifier.horizontalScroll(rememberScrollState()), horizontalArrangement = Arrangement.spacedBy(m.chipGap)) {
        WallpaperFilter.chipCases.forEach { filter -> Chip(m, filter, activeFilter == filter, onSelectFilter) }
    }
}

@Composable
private fun Chip(m: WallpaperMetrics, filter: WallpaperFilter, isSelected: Boolean, onSelect: (WallpaperFilter) -> Unit) {
    Column(
        modifier = Modifier
            .width(m.chipW)
            .height(m.chipH)
            .clip(RoundedCornerShape(m.chipRadius))
            .background(if (isSelected) MochiColor.logoSolid.copy(alpha = 0.10f) else Color.White)
            .border(m.chipBorderWidth, MochiColor.logoSolid.copy(alpha = if (isSelected) 0.9f else 0.6f), RoundedCornerShape(m.chipRadius))
            .clickable { onSelect(filter) },
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.Center
    ) {
        FilterIcon(filter = filter, size = m.chipW.value.dp * 0.42f, tint = MochiColor.logoSolid)
        Text(text = filter.chipLabel, style = MochiFont.caption(m.chip), color = MochiColor.textPrimary, maxLines = 1)
    }
}

@Composable
private fun FilterIcon(filter: WallpaperFilter, size: androidx.compose.ui.unit.Dp, tint: Color) {
    val drawableName = filter.iconDrawableName
    if (drawableName != null) {
        val context = LocalContext.current
        val resId = remember(drawableName) { context.resources.getIdentifier(drawableName, "drawable", context.packageName).takeIf { it != 0 } }
        if (resId != null) {
            Image(
                painter = painterResource(resId),
                contentDescription = null,
                colorFilter = ColorFilter.tint(tint),
                modifier = androidx.compose.ui.Modifier.size(size * 1.6f)
            )
            return
        }
    }
    val icon = when (filter) {
        WallpaperFilter.ALL -> Icons.Filled.Home
        WallpaperFilter.MINIMAL -> Icons.Filled.AutoAwesome
        WallpaperFilter.Y2K -> Icons.Filled.Diamond
        WallpaperFilter.COMMUNITY -> Icons.Filled.Groups
        else -> Icons.Filled.MoreHoriz
    }
    Icon(imageVector = icon, contentDescription = null, tint = tint, modifier = Modifier.size(size))
}

// endregion

// region Headings / empty state

@Composable
private fun WallpaperSectionHeader(m: WallpaperMetrics, title: String, onSeeAll: () -> Unit) {
    Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceBetween, verticalAlignment = Alignment.CenterVertically) {
        Text(text = title, style = MochiFont.title(m.sectionTitle), color = MochiColor.textPrimary)
        Row(
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.spacedBy(2.dp),
            modifier = Modifier.clickable(onClick = onSeeAll)
        ) {
            Text(text = "see all", style = MochiFont.body(m.seeAll), color = MochiColor.logoSolid)
            Icon(imageVector = Icons.AutoMirrored.Filled.KeyboardArrowRight, contentDescription = null, tint = MochiColor.logoSolid, modifier = Modifier.size(m.seeAll.value.dp * 0.8f))
        }
    }
}

@Composable
private fun PageHeading(m: WallpaperMetrics, title: String, count: Int, hasBack: Boolean, onBack: () -> Unit) {
    Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(6.dp)) {
        if (hasBack) {
            Icon(
                imageVector = Icons.AutoMirrored.Filled.ArrowBack,
                contentDescription = "Back",
                tint = MochiColor.logoSolid,
                modifier = Modifier.clickable(onClick = onBack).size(m.sectionTitle.value.dp * 0.9f)
            )
        }
        Text(text = title, style = MochiFont.title(m.sectionTitle), color = MochiColor.textPrimary, maxLines = 1, modifier = Modifier.weight(1f))
        Text(text = "$count", style = MochiFont.caption(m.cardMeta), color = MochiColor.textPrimary.copy(alpha = 0.55f))
    }
}

@Composable
private fun EmptyState(m: WallpaperMetrics, message: String) {
    Text(
        text = message,
        style = MochiFont.caption(m.cardMeta),
        color = MochiColor.textPrimary.copy(alpha = 0.6f),
        modifier = Modifier.fillMaxWidth().height(m.cardW / m.cardArtAspect)
    )
}

// endregion

// region Grids / rows

@Composable
private fun TileGrid(m: WallpaperMetrics, items: List<WallpaperItem>, downloadedIds: List<String>, onOpenPreview: (WallpaperItem) -> Unit) {
    Column(verticalArrangement = Arrangement.spacedBy(m.gridGutter)) {
        items.chunked(m.gridColumns).forEach { row ->
            Row(horizontalArrangement = Arrangement.spacedBy(m.gridGutter)) {
                row.forEach { item -> Tile(m, item, item.id in downloadedIds, Modifier.weight(1f), onOpenPreview) }
                repeat(m.gridColumns - row.size) { Spacer(modifier = Modifier.weight(1f)) }
            }
        }
    }
}

@Composable
private fun Tile(m: WallpaperMetrics, item: WallpaperItem, isDownloaded: Boolean, modifier: Modifier, onOpenPreview: (WallpaperItem) -> Unit) {
    Column(modifier = modifier.clip(RoundedCornerShape(m.gridRadius)).clickable { onOpenPreview(item) }) {
        Box {
            WallpaperArt(assetName = item.assetName, cropAnchor = item.cropAnchor, modifier = Modifier.fillMaxWidth().aspectRatio(m.tileAspect))
            item.badge?.let { badge ->
                Text(
                    text = badge.label,
                    style = MochiFont.heading(m.badge),
                    color = MochiColor.textPrimary,
                    modifier = Modifier
                        .align(Alignment.TopStart)
                        .padding(m.badgeInset * 0.7f)
                        .clip(CircleShape)
                        .background(Color.White)
                        .padding(horizontal = 4.dp, vertical = 1.5.dp)
                )
            }
            if (isDownloaded) {
                Icon(
                    imageVector = Icons.Filled.CheckCircle,
                    contentDescription = "Downloaded",
                    tint = MochiColor.logoSolid,
                    modifier = Modifier.align(Alignment.BottomEnd).padding(m.badgeInset * 0.7f).size(m.cardMeta.value.dp * 1.4f)
                )
            }
        }
        Column(modifier = Modifier.fillMaxWidth().background(Color.White).padding(horizontal = m.cardPadH * 0.8f, vertical = 5.dp)) {
            Text(text = item.name, style = MochiFont.heading(m.cardName), color = MochiColor.textPrimary, maxLines = 1, overflow = TextOverflow.Ellipsis)
            Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(3.dp)) {
                Icon(imageVector = Icons.Filled.Favorite, contentDescription = null, tint = MochiColor.heart, modifier = Modifier.size(m.cardMeta.value.dp))
                Text(text = item.likeCountText, style = MochiFont.caption(m.cardMeta), color = MochiColor.textPrimary)
            }
        }
    }
}

@Composable
private fun CardRow(m: WallpaperMetrics, items: List<WallpaperItem>, downloadedIds: List<String>, onOpenPreview: (WallpaperItem) -> Unit) {
    Row(modifier = Modifier.horizontalScroll(rememberScrollState()), horizontalArrangement = Arrangement.spacedBy(m.cardGutter)) {
        items.forEach { item -> WallpaperCard(m, item, item.id in downloadedIds, m.cardW, m.cardArtAspect, onOpenPreview) }
    }
}

@Composable
private fun CardGrid(m: WallpaperMetrics, items: List<WallpaperItem>, downloadedIds: List<String>, onOpenPreview: (WallpaperItem) -> Unit) {
    Column(verticalArrangement = Arrangement.spacedBy(m.popularGutter)) {
        items.chunked(m.popularColumns).forEach { row ->
            Row(horizontalArrangement = Arrangement.spacedBy(m.popularGutter)) {
                row.forEach { item ->
                    Box(modifier = Modifier.weight(1f)) {
                        WallpaperCard(m, item, item.id in downloadedIds, null, m.popularCardArtAspect, onOpenPreview, fillWidth = true)
                    }
                }
                repeat(m.popularColumns - row.size) { Spacer(modifier = Modifier.weight(1f)) }
            }
        }
    }
}

@Composable
private fun WallpaperCard(
    m: WallpaperMetrics,
    item: WallpaperItem,
    isDownloaded: Boolean,
    width: androidx.compose.ui.unit.Dp?,
    artAspect: Float,
    onOpenPreview: (WallpaperItem) -> Unit,
    fillWidth: Boolean = false
) {
    Column(
        modifier = (if (width != null) Modifier.width(width) else if (fillWidth) Modifier.fillMaxWidth() else Modifier)
            .clip(RoundedCornerShape(m.cardRadius))
            .clickable { onOpenPreview(item) }
    ) {
        Box {
            WallpaperArt(assetName = item.assetName, cropAnchor = item.cropAnchor, modifier = Modifier.fillMaxWidth().aspectRatio(artAspect))
            item.badge?.let { badge ->
                Text(
                    text = badge.label,
                    style = MochiFont.heading(m.badge),
                    color = MochiColor.textPrimary,
                    modifier = Modifier
                        .align(Alignment.TopStart)
                        .padding(m.badgeInset)
                        .clip(CircleShape)
                        .background(Color.White)
                        .padding(horizontal = 5.dp, vertical = 2.dp)
                )
            }
        }
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .height(m.cardBodyH)
                .background(Color.White)
                .padding(horizontal = m.cardPadH),
            verticalArrangement = Arrangement.spacedBy(3.dp)
        ) {
            Text(text = item.name, style = MochiFont.heading(m.cardName), color = MochiColor.textPrimary, maxLines = 1, overflow = TextOverflow.Ellipsis)
            Row(verticalAlignment = Alignment.CenterVertically) {
                Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(3.dp)) {
                    Icon(imageVector = Icons.Filled.Favorite, contentDescription = null, tint = MochiColor.heart, modifier = Modifier.size(m.cardMeta.value.dp))
                    Text(text = item.likeCountText, style = MochiFont.caption(m.cardMeta), color = MochiColor.textPrimary)
                }
                Spacer(modifier = Modifier.weight(1f))
                Icon(
                    imageVector = if (isDownloaded) Icons.Filled.CheckCircle else Icons.Filled.Download,
                    contentDescription = if (isDownloaded) "Downloaded" else "Download",
                    tint = MochiColor.logoSolid,
                    modifier = Modifier.size(m.cardMeta.value.dp * 1.5f)
                )
            }
        }
    }
}

@Composable
private fun CollectionsRow(m: WallpaperMetrics, onOpen: (WallpaperCollection) -> Unit) {
    Row(modifier = Modifier.horizontalScroll(rememberScrollState()), horizontalArrangement = Arrangement.spacedBy(m.cardGutter)) {
        WallpaperCatalog.collections.forEach { collection -> CollectionCard(m, collection, onOpen) }
    }
}

@Composable
private fun CollectionsGrid(m: WallpaperMetrics, onOpen: (WallpaperCollection) -> Unit) {
    Column(verticalArrangement = Arrangement.spacedBy(m.gridGutter)) {
        WallpaperCatalog.collections.chunked(m.gridColumns).forEach { row ->
            Row(horizontalArrangement = Arrangement.spacedBy(m.gridGutter)) {
                row.forEach { collection ->
                    Column(modifier = Modifier.weight(1f).clip(RoundedCornerShape(m.gridRadius)).clickable { onOpen(collection) }) {
                        WallpaperCatalog.wallpaper(collection.coverId)?.let {
                            WallpaperArt(assetName = it.assetName, cropAnchor = it.cropAnchor, modifier = Modifier.fillMaxWidth().aspectRatio(m.tileAspect))
                        }
                        Column(modifier = Modifier.fillMaxWidth().background(Color.White).padding(horizontal = m.cardPadH * 0.8f, vertical = 5.dp)) {
                            Text(text = collection.name, style = MochiFont.heading(m.cardName), color = MochiColor.textPrimary, maxLines = 1, overflow = TextOverflow.Ellipsis)
                            Text(text = "${collection.memberIds.size} wallpapers", style = MochiFont.caption(m.cardMeta), color = MochiColor.textPrimary.copy(alpha = 0.6f))
                        }
                    }
                }
                repeat(m.gridColumns - row.size) { Spacer(modifier = Modifier.weight(1f)) }
            }
        }
    }
}

@Composable
private fun CollectionCard(m: WallpaperMetrics, collection: WallpaperCollection, onOpen: (WallpaperCollection) -> Unit) {
    val cover = remember(collection) { WallpaperCatalog.wallpaper(collection.coverId) }
    Column(modifier = Modifier.width(m.cardW).clip(RoundedCornerShape(m.cardRadius)).clickable { onOpen(collection) }) {
        if (cover != null) {
            WallpaperArt(assetName = cover.assetName, cropAnchor = cover.cropAnchor, modifier = Modifier.fillMaxWidth().aspectRatio(m.cardArtAspect))
        } else {
            Box(modifier = Modifier.fillMaxWidth().aspectRatio(m.cardArtAspect).background(Color(0xFFF2F2F2)))
        }
        Column(
            modifier = Modifier.width(m.cardW).height(m.cardBodyH).background(Color.White).padding(horizontal = m.cardPadH),
            verticalArrangement = Arrangement.spacedBy(3.dp)
        ) {
            Text(text = collection.name, style = MochiFont.heading(m.cardName), color = MochiColor.textPrimary, maxLines = 1, overflow = TextOverflow.Ellipsis)
            Row(verticalAlignment = Alignment.CenterVertically) {
                Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(3.dp)) {
                    Icon(imageVector = Icons.Filled.Favorite, contentDescription = null, tint = MochiColor.heart, modifier = Modifier.size(m.cardMeta.value.dp))
                    Text(text = collection.likeCountText, style = MochiFont.caption(m.cardMeta), color = MochiColor.textPrimary)
                }
                Spacer(modifier = Modifier.weight(1f))
                Icon(
                    imageVector = Icons.AutoMirrored.Filled.KeyboardArrowRight,
                    contentDescription = null,
                    tint = Color.White,
                    modifier = Modifier
                        .size(m.cardMeta.value.dp * 2.2f)
                        .clip(CircleShape)
                        .background(MochiColor.logoSolid)
                        .padding(3.dp)
                )
            }
        }
    }
}

// endregion

// region Filter sheet

@OptIn(ExperimentalMaterial3Api::class)
@Composable
private fun MoreFilterSheet(onSelect: (WallpaperCategory) -> Unit, onDismiss: () -> Unit) {
    ModalBottomSheet(onDismissRequest = onDismiss, sheetState = rememberModalBottomSheetState()) {
        Column(modifier = Modifier.padding(bottom = 24.dp)) {
            Text(text = "All categories", style = MochiFont.heading(17.sp), color = MochiColor.textPrimary, modifier = Modifier.padding(16.dp))
            WallpaperCategory.entries.forEach { category ->
                Row(
                    modifier = Modifier
                        .fillMaxWidth()
                        .clickable { onSelect(category); onDismiss() }
                        .padding(horizontal = 16.dp, vertical = 12.dp),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Text(text = category.title, style = MochiFont.body(15.sp), color = MochiColor.textPrimary, modifier = Modifier.weight(1f))
                    Text(
                        text = "${WallpaperCatalog.wallpapers(inCategory = category).size}",
                        style = MochiFont.caption(13.sp),
                        color = MochiColor.textSecondary
                    )
                }
            }
        }
    }
}

// endregion

// region Art

@Composable
private fun WallpaperArt(assetName: String, cropAnchor: WallpaperCropAnchor, modifier: Modifier = Modifier) {
    val context = LocalContext.current
    val resId = remember(assetName) { context.resources.getIdentifier(assetName, "drawable", context.packageName).takeIf { it != 0 } }
    if (resId != null) {
        Image(
            painter = painterResource(resId),
            contentDescription = null,
            contentScale = ContentScale.Crop,
            alignment = if (cropAnchor == WallpaperCropAnchor.TOP) Alignment.TopCenter else Alignment.Center,
            modifier = modifier
        )
    } else {
        KeyboardPreviewPlaceholder(seed = assetName, modifier = modifier, cornerRadius = 0.dp)
    }
}

// endregion

// region Full-screen preview

/**
 * Full-screen preview overlay, reached by tapping any thumbnail anywhere in the Wallpapers section -
 * ported from `WallpaperPreviewView.swift`, structurally similar to `ThemeDetailScreen`'s blurred-
 * background full-bleed card. Unlike iOS, Apply here actually sets the device wallpaper - see the
 * file-level doc comment - so it offers a Home/Lock/Both target choice iOS has no equivalent of.
 */
@Composable
private fun WallpaperPreviewOverlay(
    item: WallpaperItem,
    isDownloaded: Boolean,
    onToggleDownload: () -> Unit,
    onApply: suspend (WallpaperApplier.Target) -> WallpaperApplier.Outcome,
    onSaveToGallery: suspend () -> WallpaperApplier.Outcome,
    onClose: () -> Unit
) {
    val scope = rememberCoroutineScope()
    var busy by remember { mutableStateOf(false) }
    var toast by remember { mutableStateOf<String?>(null) }
    var showTargetPicker by remember { mutableStateOf(false) }

    LaunchedEffect(toast) {
        if (toast != null) {
            kotlinx.coroutines.delay(3200)
            toast = null
        }
    }

    Box(modifier = Modifier.fillMaxSize()) {
        val context = LocalContext.current
        val resId = remember(item.assetName) { context.resources.getIdentifier(item.assetName, "drawable", context.packageName).takeIf { it != 0 } }
        if (resId != null) {
            Image(
                painter = painterResource(resId),
                contentDescription = null,
                contentScale = ContentScale.Crop,
                modifier = Modifier.fillMaxSize().blur(40.dp)
            )
        }
        Box(modifier = Modifier.fillMaxSize().background(Color.Black.copy(alpha = 0.45f)))

        Column(modifier = Modifier.fillMaxSize()) {
            Row(modifier = Modifier.fillMaxWidth().windowInsetsPadding(WindowInsets.statusBars).padding(horizontal = 16.dp).padding(top = 12.dp)) {
                Icon(
                    imageVector = Icons.AutoMirrored.Filled.ArrowBack,
                    contentDescription = "Close",
                    tint = Color.White,
                    modifier = Modifier
                        .clip(CircleShape)
                        .background(Color.Black.copy(alpha = 0.35f))
                        .clickable(onClick = onClose)
                        .padding(10.dp)
                        .size(16.dp)
                )
            }

            Box(modifier = Modifier.weight(1f).fillMaxWidth().padding(horizontal = 28.dp), contentAlignment = Alignment.Center) {
                if (resId != null) {
                    Box {
                        Image(
                            painter = painterResource(resId),
                            contentDescription = item.name,
                            contentScale = ContentScale.Fit,
                            modifier = Modifier
                                .fillMaxWidth()
                                .clip(RoundedCornerShape(22.dp))
                                .border(1.dp, Color.White.copy(alpha = 0.25f), RoundedCornerShape(22.dp))
                        )
                        Icon(
                            imageVector = if (isDownloaded) Icons.Filled.Favorite else Icons.Filled.FavoriteBorder,
                            contentDescription = "Keep",
                            tint = if (isDownloaded) MochiColor.heart else Color.White,
                            modifier = Modifier
                                .align(Alignment.TopEnd)
                                .padding(12.dp)
                                .size(34.dp)
                                .clip(CircleShape)
                                .background(Color.Black.copy(alpha = 0.28f))
                                .clickable(onClick = onToggleDownload)
                                .padding(9.dp)
                        )
                    }
                }
            }

            Column(
                modifier = Modifier.fillMaxWidth().windowInsetsPadding(WindowInsets.navigationBars).padding(top = 18.dp, bottom = 34.dp),
                horizontalAlignment = Alignment.CenterHorizontally,
                verticalArrangement = Arrangement.spacedBy(20.dp)
            ) {
                Column(horizontalAlignment = Alignment.CenterHorizontally, verticalArrangement = Arrangement.spacedBy(4.dp)) {
                    Text(text = item.name, style = MochiFont.title(20.sp), color = Color.White)
                    Row(horizontalArrangement = Arrangement.spacedBy(10.dp), verticalAlignment = Alignment.CenterVertically) {
                        Icon(imageVector = Icons.Filled.Favorite, contentDescription = null, tint = MochiColor.heart, modifier = Modifier.size(11.dp))
                        Text(text = item.likeCountText, style = MochiFont.caption(11.sp), color = Color.White.copy(alpha = 0.9f))
                        Text(text = item.category.title.uppercase(), style = MochiFont.caption(11.sp), color = Color.White.copy(alpha = 0.7f))
                    }
                }

                Row(horizontalArrangement = Arrangement.spacedBy(10.dp), modifier = Modifier.fillMaxWidth().padding(horizontal = 20.dp)) {
                    PreviewActionButton(
                        title = if (isDownloaded) "Saved" else "Save to Gallery",
                        icon = if (isDownloaded) Icons.Filled.Check else Icons.Filled.Download,
                        filled = false,
                        enabled = !busy,
                        modifier = Modifier.weight(1f)
                    ) {
                        scope.launch {
                            busy = true
                            val outcome = onSaveToGallery()
                            busy = false
                            toast = when (outcome) {
                                is WallpaperApplier.Outcome.Saved -> { if (!isDownloaded) onToggleDownload(); "Saved to your gallery." }
                                is WallpaperApplier.Outcome.Failed -> outcome.message
                                else -> null
                            }
                        }
                    }
                    PreviewActionButton(
                        title = "Set Wallpaper",
                        icon = Icons.Filled.Home,
                        filled = true,
                        enabled = !busy,
                        modifier = Modifier.weight(1f)
                    ) { showTargetPicker = true }
                }
            }
        }

        toast?.let { message ->
            Text(
                text = message,
                style = MochiFont.body(13.sp),
                color = Color.White,
                modifier = Modifier
                    .align(Alignment.BottomCenter)
                    .padding(horizontal = 24.dp)
                    .padding(bottom = 130.dp)
                    .clip(CircleShape)
                    .background(Color.Black.copy(alpha = 0.75f))
                    .padding(horizontal = 16.dp, vertical = 10.dp)
            )
        }
    }

    if (showTargetPicker) {
        WallpaperTargetSheet(
            onPick = { target ->
                showTargetPicker = false
                scope.launch {
                    busy = true
                    val outcome = onApply(target)
                    busy = false
                    toast = when (outcome) {
                        is WallpaperApplier.Outcome.Applied -> "“${item.name}” is now your wallpaper."
                        is WallpaperApplier.Outcome.Failed -> outcome.message
                        else -> null
                    }
                }
            },
            onDismiss = { showTargetPicker = false }
        )
    }
}

@Composable
private fun PreviewActionButton(
    title: String,
    icon: androidx.compose.ui.graphics.vector.ImageVector,
    filled: Boolean,
    enabled: Boolean,
    modifier: Modifier = Modifier,
    onClick: () -> Unit
) {
    Row(
        modifier = modifier
            .clip(CircleShape)
            .then(if (filled) Modifier.background(MochiGradient.softButton) else Modifier.background(Color.White))
            .then(if (enabled) Modifier.clickable(onClick = onClick) else Modifier)
            .padding(vertical = 12.dp),
        horizontalArrangement = Arrangement.Center,
        verticalAlignment = Alignment.CenterVertically
    ) {
        Icon(imageVector = icon, contentDescription = null, tint = if (filled) Color.White else MochiColor.logoSolid, modifier = Modifier.size(13.dp))
        Spacer(modifier = Modifier.width(5.dp))
        Text(text = title, style = MochiFont.body(13.sp), color = if (filled) Color.White else MochiColor.logoSolid, maxLines = 1)
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
private fun WallpaperTargetSheet(onPick: (WallpaperApplier.Target) -> Unit, onDismiss: () -> Unit) {
    ModalBottomSheet(onDismissRequest = onDismiss, sheetState = rememberModalBottomSheetState()) {
        Column(modifier = Modifier.padding(horizontal = 16.dp).padding(bottom = 24.dp)) {
            Text(text = "Set wallpaper for", style = MochiFont.heading(17.sp), color = MochiColor.textPrimary, modifier = Modifier.padding(bottom = 8.dp))
            listOf(
                Triple("Home Screen", Icons.Filled.Home, WallpaperApplier.Target.HOME),
                Triple("Lock Screen", Icons.Filled.Photo, WallpaperApplier.Target.LOCK),
                Triple("Both", Icons.Filled.CheckCircle, WallpaperApplier.Target.BOTH)
            ).forEach { (label, icon, target) ->
                Row(
                    modifier = Modifier.fillMaxWidth().clickable { onPick(target) }.padding(vertical = 14.dp),
                    verticalAlignment = Alignment.CenterVertically,
                    horizontalArrangement = Arrangement.spacedBy(12.dp)
                ) {
                    Icon(imageVector = icon, contentDescription = null, tint = MochiColor.logoSolid)
                    Text(text = label, style = MochiFont.body(15.sp), color = MochiColor.textPrimary)
                }
            }
        }
    }
}

// endregion
