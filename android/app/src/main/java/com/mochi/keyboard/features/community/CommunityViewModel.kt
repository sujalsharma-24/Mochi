package com.mochi.keyboard.features.community

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.mochi.keyboard.data.AuthRepository
import com.mochi.keyboard.data.FollowRepository
import com.mochi.keyboard.data.LikeRepository
import com.mochi.keyboard.data.ReportRepository
import com.mochi.keyboard.data.ThemeCache
import com.mochi.keyboard.data.ThemeRepository
import com.mochi.keyboard.model.CommunityPost
import com.mochi.keyboard.model.KeyboardTheme
import com.mochi.keyboard.model.TagPalette
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import kotlin.math.abs

sealed interface CommunityUiState {
    data object Loading : CommunityUiState
    data class Data(
        val feedThemes: List<KeyboardTheme>,
        val latestThemes: List<KeyboardTheme>,
        val creators: List<CommunityCreatorUi>
    ) : CommunityUiState
    data class Error(val message: String) : CommunityUiState
}

/** No `isVerified`/avatar-photo field exists anywhere in this app's schema, so real creator tiles
 * never show a verified badge or a real photo (falls back to the same neutral avatar box every
 * unmatched CreatorAvatar id already renders) - not an oversight, there's nothing to source it from. */
data class CommunityCreatorUi(val uid: String, val name: String, val themeCount: Int, val isFollowing: Boolean)

/**
 * Backs Community's 5 feed tabs + Popular Creators + Latest Creations + follow/report actions.
 * ThemeRepository's getTopRanked/getPublishedThemes/getThemesByCreators/getThemesByIds map 1:1 onto
 * Popular/Latest/Following/My Likes (their doc comments were written anticipating this exact screen
 * in WA2). "For you" has no dedicated query of its own - stands in with getTopRanked until a real
 * personalized feed is in scope.
 *
 * Popular Creators has no dedicated backend query either (UserRepository can only create a profile,
 * not list/search them) - derived instead from the top-ranked themes batch, grouping by creatorUid
 * and counting appearances within that batch. That's a real-data approximation (not MockData), just
 * bounded to whichever creators show up in the top 20 themes, not a true global ranking.
 */
class CommunityViewModel(
    private val themeRepository: ThemeRepository,
    private val likeRepository: LikeRepository,
    private val followRepository: FollowRepository,
    private val reportRepository: ReportRepository,
    private val authRepository: AuthRepository
) : ViewModel() {

    private val _uiState = MutableStateFlow<CommunityUiState>(CommunityUiState.Loading)
    val uiState: StateFlow<CommunityUiState> = _uiState.asStateFlow()

    private var followedUids: Set<String> = emptySet()
    private var selectedTab: String = "For you"

    init {
        viewModelScope.launch {
            authRepository.currentUser?.uid?.let { uid ->
                runCatching { followRepository.followedUids(uid) }.onSuccess { followedUids = it.toSet() }
            }
            loadFeed()
        }
    }

    fun selectTab(tab: String) {
        if (tab == selectedTab) return
        selectedTab = tab
        loadFeed()
    }

    fun loadFeed() {
        viewModelScope.launch {
            val uid = authRepository.currentUser?.uid
            val feedResult = runCatching { fetchTab(selectedTab, uid) }
            val feedThemes = feedResult.getOrNull()
            if (feedThemes == null) {
                _uiState.value = CommunityUiState.Error(feedResult.exceptionOrNull()?.message ?: "Couldn't load community feed.")
                return@launch
            }
            val topRanked = runCatching { themeRepository.getTopRanked(20) }.getOrDefault(emptyList())
            val latest = runCatching { themeRepository.getPublishedThemes(10) }.getOrDefault(emptyList())
            ThemeCache.put(feedThemes)
            ThemeCache.put(topRanked)
            ThemeCache.put(latest)
            _uiState.value = CommunityUiState.Data(
                feedThemes = feedThemes,
                latestThemes = latest,
                creators = buildCreators(topRanked)
            )
        }
    }

    private suspend fun fetchTab(tab: String, uid: String?): List<KeyboardTheme> = when (tab) {
        "Popular" -> themeRepository.getTopRanked(20)
        "Latest" -> themeRepository.getPublishedThemes(20)
        "Following" -> themeRepository.getThemesByCreators(if (uid != null) followRepository.followedUids(uid) else emptyList())
        "My Likes" -> themeRepository.getThemesByIds(if (uid != null) likeRepository.likedThemeIds(uid) else emptyList())
        else -> themeRepository.getTopRanked(20) // "For you" - no dedicated query yet, see class doc
    }

    private fun buildCreators(themes: List<KeyboardTheme>): List<CommunityCreatorUi> =
        themes.filter { it.creatorUid.isNotBlank() }
            .groupBy { it.creatorUid }
            .map { (uid, group) ->
                CommunityCreatorUi(uid = uid, name = group.first().creatorName, themeCount = group.size, isFollowing = followedUids.contains(uid))
            }

    fun toggleFollow(creatorUid: String) {
        val uid = authRepository.currentUser?.uid ?: return
        if (uid == creatorUid) return
        val wasFollowing = followedUids.contains(creatorUid)
        followedUids = if (wasFollowing) followedUids - creatorUid else followedUids + creatorUid
        reapplyFollowState()
        viewModelScope.launch {
            runCatching { if (wasFollowing) followRepository.unfollow(uid, creatorUid) else followRepository.follow(uid, creatorUid) }
                .onFailure {
                    followedUids = if (wasFollowing) followedUids + creatorUid else followedUids - creatorUid
                    reapplyFollowState()
                }
        }
    }

    private fun reapplyFollowState() {
        val current = _uiState.value
        if (current is CommunityUiState.Data) {
            _uiState.value = current.copy(creators = current.creators.map { it.copy(isFollowing = followedUids.contains(it.uid)) })
        }
    }

    fun reportTheme(themeId: String, reason: String) {
        val uid = authRepository.currentUser?.uid ?: return
        viewModelScope.launch { runCatching { reportRepository.reportTheme(uid, themeId, reason) } }
    }
}

/** Community's card models carry a bit more than a bare theme (a fixed hashtag-chip color, a
 * summary line) that ThemeDocument has no direct field for - description doubles as the summary,
 * and the tag palette is deterministically derived from the theme id so a given theme always shows
 * the same chip color rather than flickering between reloads. */
internal fun KeyboardTheme.toCommunityPost(): CommunityPost = CommunityPost(
    id = id,
    name = name,
    creatorName = creatorName,
    thumbAssetName = imageAssetName,
    summary = description,
    likeCount = likeCount,
    hashtags = hashtags,
    tagPalette = TagPalette.entries[abs(id.hashCode()) % TagPalette.entries.size]
)
