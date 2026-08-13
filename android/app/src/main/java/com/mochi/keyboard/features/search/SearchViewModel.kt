package com.mochi.keyboard.features.search

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.mochi.keyboard.data.AuthRepository
import com.mochi.keyboard.data.FollowRepository
import com.mochi.keyboard.data.SearchHistoryRepository
import com.mochi.keyboard.data.ThemeCache
import com.mochi.keyboard.data.ThemeRepository
import com.mochi.keyboard.data.UserRepository
import com.mochi.keyboard.data.model.UserDocument
import com.mochi.keyboard.mockdata.MockData
import com.mochi.keyboard.model.FontItem
import com.mochi.keyboard.model.KeyboardTheme
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch

enum class SearchType(val label: String) { ALL("All"), THEME("Theme"), FONT("Font"), CREATORS("Creators") }

enum class ResultFilter(val label: String) { ALL_TYPES("All Types"), FREE_ONLY("Free Only"), PREMIUM("Premium"), NEWEST("Newest") }

data class SearchCreatorUi(val uid: String, val displayName: String, val themeCount: Int, val isFollowing: Boolean)

data class SearchUiState(
    val query: String = "",
    val selectedType: SearchType = SearchType.ALL,
    val activeFilter: ResultFilter = ResultFilter.ALL_TYPES,
    val recentSearches: List<String> = emptyList(),
    val themeResults: List<KeyboardTheme> = emptyList(),
    val fontResults: List<FontItem> = emptyList(),
    val creatorResults: List<SearchCreatorUi> = emptyList(),
    val poolsLoading: Boolean = true,
    val poolsError: String? = null
) {
    /** False = show the discovery sections (recent/trending/suggestions); true = show
     * filters+results, matching a real "browse" or "search" action rather than the landing state. */
    val isBrowsing: Boolean get() = query.isNotBlank() || selectedType != SearchType.ALL

    val resultCount: Int get() = when (selectedType) {
        SearchType.THEME -> themeResults.size
        SearchType.FONT -> fontResults.size
        SearchType.CREATORS -> creatorResults.size
        SearchType.ALL -> themeResults.size + fontResults.size
    }
}

/**
 * Backs Search's type chips (All/Theme/Font/Creators), text query, Free/Premium/Newest filters,
 * results grid, and local recent-search history. Firestore has no text-search operator and this
 * app has no budget for a paid search service, so this is: fetch a bounded pool of published
 * themes/users once (ThemeRepository.searchableThemes / UserRepository.searchableUsers), then
 * filter/sort it client-side per keystroke - the same "fetch bounded, filter client-side" shape
 * Community's Popular Creators already established. Font results come from MockData.fontCollection,
 * the same built-in catalog FontsScreen uses - fonts aren't Firestore documents in this app's
 * design, so there's no separate "real" font source to query. Trending Searches/Suggestions have
 * no backing schema at all (no per-user search-log or analytics collection anywhere in
 * firestore.rules) and stay curated/static - a documented gap, not an oversight, same as
 * Profile's other-user downloads/followers call.
 */
class SearchViewModel(
    private val themeRepository: ThemeRepository,
    private val userRepository: UserRepository,
    private val followRepository: FollowRepository,
    private val searchHistoryRepository: SearchHistoryRepository,
    private val authRepository: AuthRepository
) : ViewModel() {

    private val _uiState = MutableStateFlow(SearchUiState())
    val uiState: StateFlow<SearchUiState> = _uiState.asStateFlow()

    private var popularThemePool: List<KeyboardTheme> = emptyList()
    private var newestThemePool: List<KeyboardTheme> = emptyList()
    private var userPool: List<UserDocument> = emptyList()
    private var followedUids: Set<String> = emptySet()

    init {
        viewModelScope.launch {
            searchHistoryRepository.recentSearches.collect { recent ->
                _uiState.value = _uiState.value.copy(recentSearches = recent)
            }
        }
        loadPools()
    }

    private fun loadPools() {
        viewModelScope.launch {
            val uid = authRepository.currentUser?.uid
            val result = runCatching {
                val popular = themeRepository.searchableThemes(200)
                val newest = themeRepository.getPublishedThemes(200)
                // Excludes the signed-in user's own doc - Creators results feed a Follow action,
                // and toggleFollow already no-ops on self-follow, so leaving self in would render
                // a Follow button that silently does nothing when tapped.
                val users = userRepository.searchableUsers(200).filter { it.uid != uid }
                val followed = uid?.let { followRepository.followedUids(it) }?.toSet() ?: emptySet()
                PoolsSnapshot(popular, newest, users, followed)
            }
            result.onSuccess { (popular, newest, users, followed) ->
                popularThemePool = popular
                newestThemePool = newest
                userPool = users
                followedUids = followed
                ThemeCache.put(popular)
                ThemeCache.put(newest)
                _uiState.value = _uiState.value.copy(poolsLoading = false, poolsError = null)
                applyFilters()
            }.onFailure { e ->
                _uiState.value = _uiState.value.copy(poolsLoading = false, poolsError = e.message ?: "Couldn't load search results.")
            }
        }
    }

    fun onQueryChange(query: String) {
        _uiState.value = _uiState.value.copy(query = query)
        applyFilters()
    }

    fun onSelectType(type: SearchType) {
        _uiState.value = _uiState.value.copy(selectedType = type)
        applyFilters()
    }

    fun onSelectFilter(filter: ResultFilter) {
        _uiState.value = _uiState.value.copy(activeFilter = filter)
        applyFilters()
    }

    /** Called when the user commits a query (search-icon tap, IME action, or picking a
     * recent/trending/suggestion chip) - recorded to local history, not on every keystroke. */
    fun submitSearch(query: String = _uiState.value.query) {
        if (query.isBlank()) return
        viewModelScope.launch { runCatching { searchHistoryRepository.record(query) } }
    }

    fun selectChip(text: String) {
        _uiState.value = _uiState.value.copy(query = text)
        applyFilters()
        submitSearch(text)
    }

    fun clearRecentSearches() {
        viewModelScope.launch { runCatching { searchHistoryRepository.clear() } }
    }

    private fun applyFilters() {
        val state = _uiState.value
        val q = state.query.trim()
        val filter = state.activeFilter

        val themePool = if (filter == ResultFilter.NEWEST) newestThemePool else popularThemePool
        val matchedThemes = themePool.filter { theme ->
            (q.isBlank() || theme.name.contains(q, ignoreCase = true) || theme.hashtags.any { it.contains(q, ignoreCase = true) }) &&
                when (filter) {
                    ResultFilter.FREE_ONLY -> !theme.isPremium
                    ResultFilter.PREMIUM -> theme.isPremium
                    else -> true
                }
        }

        val matchedFonts = MockData.fontCollection
            .filter { font -> q.isBlank() || font.name.contains(q, ignoreCase = true) || font.styleDescription.contains(q, ignoreCase = true) }
            .filter { font ->
                when (filter) {
                    ResultFilter.FREE_ONLY -> !font.isPremium
                    ResultFilter.PREMIUM -> font.isPremium
                    else -> true
                }
            }

        val matchedCreators = userPool
            .filter { user -> q.isBlank() || user.displayName.contains(q, ignoreCase = true) || user.username.contains(q, ignoreCase = true) }
            .map { it.toSearchCreatorUi(followedUids) }

        _uiState.value = state.copy(themeResults = matchedThemes, fontResults = matchedFonts, creatorResults = matchedCreators)
    }

    fun toggleFollow(creatorUid: String) {
        val uid = authRepository.currentUser?.uid ?: return
        if (uid == creatorUid) return
        val wasFollowing = followedUids.contains(creatorUid)
        followedUids = if (wasFollowing) followedUids - creatorUid else followedUids + creatorUid
        reapplyCreatorFollowState()
        viewModelScope.launch {
            runCatching { if (wasFollowing) followRepository.unfollow(uid, creatorUid) else followRepository.follow(uid, creatorUid) }
                .onFailure {
                    followedUids = if (wasFollowing) followedUids + creatorUid else followedUids - creatorUid
                    reapplyCreatorFollowState()
                }
        }
    }

    private fun reapplyCreatorFollowState() {
        _uiState.value = _uiState.value.copy(
            creatorResults = _uiState.value.creatorResults.map { it.copy(isFollowing = followedUids.contains(it.uid)) }
        )
    }
}

private data class PoolsSnapshot(
    val themesByLikes: List<KeyboardTheme>,
    val themesByDate: List<KeyboardTheme>,
    val users: List<UserDocument>,
    val followedUids: Set<String>
)

private fun UserDocument.toSearchCreatorUi(followedUids: Set<String>) = SearchCreatorUi(
    uid = uid,
    displayName = displayName.ifBlank { "Mochi Creator" },
    themeCount = themeCount.toInt(),
    isFollowing = followedUids.contains(uid)
)
