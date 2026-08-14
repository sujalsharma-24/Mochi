package com.mochi.keyboard.features.leaderboard

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.mochi.keyboard.data.AuthRepository
import com.mochi.keyboard.data.FollowRepository
import com.mochi.keyboard.data.UserRepository
import com.mochi.keyboard.data.model.UserDocument
import com.mochi.keyboard.util.isoWeekId
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch

sealed interface LeaderboardUiState {
    data object Loading : LeaderboardUiState
    data class Data(val creators: List<LeaderboardCreatorUi>) : LeaderboardUiState
    data class Error(val message: String) : LeaderboardUiState
}

/** No `isVerified`/avatar-photo field exists anywhere in this app's schema (same documented gap as
 * CommunityCreatorUi/UserDocument.toProfileSummary), so real rows never show a verified badge or a
 * real photo. */
data class LeaderboardCreatorUi(
    val uid: String,
    val displayName: String,
    val handle: String,
    val themeCount: Int,
    val likeCount: Int,
    val isFollowing: Boolean
)

/**
 * Backs the 3 period tabs. "This Week" queries `weeklyStats/{isoWeekId}/creators` - a dedicated
 * leaderboard collection maintained only by functions/src/likes.ts' onLikeWritten fan-out (see
 * firestore.rules, clients can't write it directly) - joined against `users/{uid}` for display
 * fields since the weeklyStats doc itself only carries a bare likeCount. "All Time" sorts
 * UserRepository.searchableUsers' bounded pool by likesReceivedCount client-side, the same "no paid
 * ranking service" shape as every other bounded-pool feature on this app (Search, Community's
 * Popular Creators). "This Month" has no backing aggregate anywhere in the schema (only weekly and
 * all-time counters exist) - it reuses the All Time ranking rather than mislabeling a different
 * time window's data as monthly; a real monthly rollup would need new Cloud Functions work, out of
 * this slice's scope.
 */
class LeaderboardViewModel(
    private val userRepository: UserRepository,
    private val followRepository: FollowRepository,
    private val authRepository: AuthRepository
) : ViewModel() {

    private val _uiState = MutableStateFlow<LeaderboardUiState>(LeaderboardUiState.Loading)
    val uiState: StateFlow<LeaderboardUiState> = _uiState.asStateFlow()

    private var followedUids: Set<String> = emptySet()
    private var selectedPeriod: String = "This Week"

    init {
        viewModelScope.launch {
            authRepository.currentUser?.uid?.let { uid ->
                runCatching { followRepository.followedUids(uid) }.onSuccess { followedUids = it.toSet() }
            }
            loadPeriod()
        }
    }

    fun selectPeriod(period: String) {
        if (period == selectedPeriod) return
        selectedPeriod = period
        loadPeriod()
    }

    fun loadPeriod() {
        viewModelScope.launch {
            _uiState.value = LeaderboardUiState.Loading
            val result = runCatching { fetchPeriod(selectedPeriod) }
            val creators = result.getOrNull()
            if (creators == null) {
                _uiState.value = LeaderboardUiState.Error(result.exceptionOrNull()?.message ?: "Couldn't load rankings.")
                return@launch
            }
            _uiState.value = LeaderboardUiState.Data(creators)
        }
    }

    private suspend fun fetchPeriod(period: String): List<LeaderboardCreatorUi> = when (period) {
        "This Week" -> fetchWeekly()
        else -> fetchAllTime() // "This Month" and "All Time" - see class doc
    }

    private suspend fun fetchWeekly(): List<LeaderboardCreatorUi> {
        val ranked = userRepository.weeklyTopCreators(isoWeekId(), 50)
        if (ranked.isEmpty()) return emptyList()
        val usersByUid = userRepository.getUsers(ranked.map { it.first })
        return ranked.mapNotNull { (uid, likeCount) ->
            usersByUid[uid]?.toLeaderboardUi(uid = uid, likeCount = likeCount.toInt())
        }
    }

    private suspend fun fetchAllTime(): List<LeaderboardCreatorUi> =
        userRepository.searchableUsers(200)
            .sortedByDescending { it.likesReceivedCount }
            .take(50)
            .map { it.toLeaderboardUi(uid = it.uid, likeCount = it.likesReceivedCount.toInt()) }

    private fun UserDocument.toLeaderboardUi(uid: String, likeCount: Int): LeaderboardCreatorUi = LeaderboardCreatorUi(
        uid = uid,
        displayName = displayName.ifBlank { "Mochi Creator" },
        handle = if (username.isNotBlank()) "@$username" else "",
        themeCount = themeCount.toInt(),
        likeCount = likeCount,
        isFollowing = followedUids.contains(uid)
    )

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
        if (current is LeaderboardUiState.Data) {
            _uiState.value = current.copy(creators = current.creators.map { it.copy(isFollowing = followedUids.contains(it.uid)) })
        }
    }
}
