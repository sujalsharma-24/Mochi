package com.mochi.keyboard.features.wallpapers

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.mochi.keyboard.data.BillingRepository
import com.mochi.keyboard.data.WallpaperApplier
import com.mochi.keyboard.data.WallpaperLibraryRepository
import com.mochi.keyboard.model.WallpaperItem
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.stateIn
import kotlinx.coroutines.launch

/**
 * Backs the bundled-catalog Wallpapers page (`WallpaperExploreScreen`'s rail + content pane, ported
 * from iOS's `WallpapersView`). Page-stack/search/preview-sheet visibility stay as local `remember`
 * state in the Composable, same as `ThemeDetailScreen`'s `showTrySheet` - only the persisted bits
 * (downloaded ids, the last-applied wallpaper, and the actions that touch them) live here, since
 * those need to survive recomposition and outlive a single page's lifecycle.
 */
class WallpaperExploreViewModel(
    private val wallpaperLibraryRepository: WallpaperLibraryRepository,
    private val wallpaperApplier: WallpaperApplier,
    billingRepository: BillingRepository
) : ViewModel() {

    val downloadedIds: StateFlow<List<String>> = wallpaperLibraryRepository.downloadedIds
        .stateIn(viewModelScope, SharingStarted.WhileSubscribed(5_000), emptyList())

    val appliedWallpaperId: StateFlow<String?> = wallpaperApplier.appliedWallpaperId
        .stateIn(viewModelScope, SharingStarted.WhileSubscribed(5_000), null)

    val isUserPremium: StateFlow<Boolean> = billingRepository.isPremium

    fun toggleDownload(item: WallpaperItem, currentlyDownloaded: Boolean) {
        viewModelScope.launch {
            if (currentlyDownloaded) wallpaperLibraryRepository.removeDownloaded(item.id)
            else wallpaperLibraryRepository.markDownloaded(item.id)
        }
    }

    suspend fun apply(item: WallpaperItem, target: WallpaperApplier.Target): WallpaperApplier.Outcome =
        wallpaperApplier.apply(item, target)

    suspend fun saveToGallery(item: WallpaperItem): WallpaperApplier.Outcome =
        wallpaperApplier.saveToGallery(item)
}
