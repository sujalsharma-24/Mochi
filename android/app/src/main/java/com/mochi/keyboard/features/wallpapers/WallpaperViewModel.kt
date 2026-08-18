package com.mochi.keyboard.features.wallpapers

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.mochi.keyboard.data.BillingRepository
import com.mochi.keyboard.data.WallpaperLibraryRepository
import com.mochi.keyboard.data.WallpaperRepository
import com.mochi.keyboard.data.model.WallpaperDocument
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch

data class WallpaperUiState(
    val query: String = "",
    val allWallpapers: List<WallpaperDocument> = emptyList(),
    val downloadedIds: List<String> = emptyList(),
    val isUserPremium: Boolean = false,
    val isLoading: Boolean = true,
    val errorMessage: String? = null
) {
    val filteredWallpapers: List<WallpaperDocument> get() =
        if (query.isBlank()) allWallpapers
        else allWallpapers.filter { it.name.contains(query, ignoreCase = true) }

    /** Most-recent-first, per WallpaperLibraryRepository's ordering. */
    val recentlyDownloaded: List<WallpaperDocument> get() {
        val byId = allWallpapers.associateBy { it.id }
        return downloadedIds.mapNotNull { byId[it] }
    }
}

/**
 * Backs WallpaperExploreScreen. `liveWallpapers` is a small, admin-authored, read-only collection
 * (firestore.rules: `allow write: if false`) with no likeCount/createdAt/category fields, unlike
 * `themes` - so unlike Community/Search there's no real "Popular"/"Collections"/"Trending" grouping
 * to derive; every wallpaper is shown once in a single real grid, live-filtered by name as the user
 * types (same "fetch bounded, filter client-side" shape as Search). Category chips stay decorative
 * client-side selection state (no backing field to filter by), same documented-gap treatment as
 * Search's originally-static Trending/Suggestions chips.
 */
class WallpaperViewModel(
    private val wallpaperRepository: WallpaperRepository,
    private val wallpaperLibraryRepository: WallpaperLibraryRepository,
    private val billingRepository: BillingRepository
) : ViewModel() {

    private val _uiState = MutableStateFlow(WallpaperUiState())
    val uiState: StateFlow<WallpaperUiState> = _uiState.asStateFlow()

    init {
        viewModelScope.launch {
            billingRepository.isPremium.collect { premium ->
                _uiState.value = _uiState.value.copy(isUserPremium = premium)
            }
        }
        viewModelScope.launch {
            wallpaperLibraryRepository.downloadedIds.collect { ids ->
                _uiState.value = _uiState.value.copy(downloadedIds = ids)
            }
        }
        load()
    }

    fun load() {
        viewModelScope.launch {
            _uiState.value = _uiState.value.copy(isLoading = true, errorMessage = null)
            runCatching { wallpaperRepository.getAll() }
                .onSuccess { wallpapers ->
                    _uiState.value = _uiState.value.copy(isLoading = false, allWallpapers = wallpapers)
                }
                .onFailure { e ->
                    _uiState.value = _uiState.value.copy(isLoading = false, errorMessage = e.message ?: "Couldn't load wallpapers.")
                }
        }
    }

    fun onQueryChange(query: String) {
        _uiState.value = _uiState.value.copy(query = query)
    }

    /** Marks a wallpaper as downloaded in local history only - `liveWallpapers` is read-only per
     * firestore.rules, and applying a wallpaper into Create > Background is a separate, not-yet-
     * built integration (assetUrl isn't consumed anywhere yet), out of this screen's scope. */
    fun download(wallpaper: WallpaperDocument) {
        viewModelScope.launch { runCatching { wallpaperLibraryRepository.markDownloaded(wallpaper.id) } }
    }
}
