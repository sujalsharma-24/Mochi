package com.mochi.keyboard.features.profile

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.mochi.keyboard.data.AuthRepository
import com.mochi.keyboard.data.BillingRepository
import com.mochi.keyboard.data.BlockRepository
import com.mochi.keyboard.data.FollowRepository
import com.mochi.keyboard.data.LikeRepository
import com.mochi.keyboard.data.ThemeCache
import com.mochi.keyboard.data.ThemeRepository
import com.mochi.keyboard.data.UserRepository
import com.mochi.keyboard.data.model.toProfileSummary
import com.mochi.keyboard.model.KeyboardTheme
import com.mochi.keyboard.model.ProfileSummary
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch

sealed interface ProfileUiState {
    data object Loading : ProfileUiState
    data class Data(
        val summary: ProfileSummary,
        val isOwnProfile: Boolean,
        val isFollowing: Boolean,
        val isBlocked: Boolean,
        val creations: List<KeyboardTheme>,
        val likedThemes: List<KeyboardTheme>
    ) : ProfileUiState
    data class Error(val message: String) : ProfileUiState
}

/**
 * Backs both the signed-in user's own Profile tab and any "view another user's profile" screen -
 * [profileUid] null means "whoever's signed in", matching how AppNavHost's own-profile route omits
 * the nav argument entirely. Creations reuse ThemeRepository.getThemesByCreators (built in WA2
 * anticipating exactly this) and Liked Themes reuses the same likedThemeIds+getThemesByIds pairing
 * CommunityViewModel's "My Likes" tab already established - both collections are readable for any
 * uid, not just your own (firestore.rules), which is what makes viewing someone else's profile
 * possible at all.
 *
 * MY DOWNLOADS stays on MockData in ProfileScreen - there is no per-user "themes I downloaded"
 * collection anywhere in firestore.rules (only likes/follows/blocks/reports/usernames exist), so
 * unlike Creations/Liked Themes there is no real data to wire it to. Documented gap, not an
 * oversight - same category as CreateThemeScreen's missing description/isPremium controls.
 */
class ProfileViewModel(
    private val userRepository: UserRepository,
    private val themeRepository: ThemeRepository,
    private val likeRepository: LikeRepository,
    private val followRepository: FollowRepository,
    private val blockRepository: BlockRepository,
    private val authRepository: AuthRepository,
    billingRepository: BillingRepository,
    private val profileUid: String?
) : ViewModel() {

    private val _uiState = MutableStateFlow<ProfileUiState>(ProfileUiState.Loading)
    val uiState: StateFlow<ProfileUiState> = _uiState.asStateFlow()

    // Own-profile only in practice (ProfileScreen never shows a premium banner for someone else's
    // profile), but re-exposing the whole flow costs nothing and needs no extra plumbing per-uid.
    val isPremium: StateFlow<Boolean> = billingRepository.isPremium

    private val targetUid: String? get() = profileUid ?: authRepository.currentUser?.uid

    init { load() }

    fun load() {
        val currentUid = authRepository.currentUser?.uid
        val uid = targetUid
        if (uid == null) {
            _uiState.value = ProfileUiState.Error("Sign in to view this profile.")
            return
        }
        _uiState.value = ProfileUiState.Loading
        viewModelScope.launch {
            val result = runCatching {
                val userDoc = userRepository.getUser(uid) ?: error("Profile not found.")
                val isOwn = uid == currentUid
                val isFollowing = if (!isOwn && currentUid != null) followRepository.isFollowing(currentUid, uid) else false
                val isBlocked = if (!isOwn && currentUid != null) blockRepository.isBlocked(currentUid, uid) else false
                val creations = themeRepository.getThemesByCreators(listOf(uid))
                val likedThemes = themeRepository.getThemesByIds(likeRepository.likedThemeIds(uid))
                ThemeCache.put(creations)
                ThemeCache.put(likedThemes)
                ProfileUiState.Data(
                    summary = userDoc.toProfileSummary(),
                    isOwnProfile = isOwn,
                    isFollowing = isFollowing,
                    isBlocked = isBlocked,
                    creations = creations,
                    likedThemes = likedThemes
                )
            }
            _uiState.value = result.getOrElse { ProfileUiState.Error(it.message ?: "Couldn't load this profile.") }
        }
    }

    fun toggleFollow() {
        val current = _uiState.value as? ProfileUiState.Data ?: return
        if (current.isOwnProfile) return
        val currentUid = authRepository.currentUser?.uid ?: return
        val uid = targetUid ?: return
        val wasFollowing = current.isFollowing
        _uiState.value = current.copy(isFollowing = !wasFollowing)
        viewModelScope.launch {
            runCatching { if (wasFollowing) followRepository.unfollow(currentUid, uid) else followRepository.follow(currentUid, uid) }
                .onFailure { _uiState.value = current }
        }
    }

    fun toggleBlock() {
        val current = _uiState.value as? ProfileUiState.Data ?: return
        if (current.isOwnProfile) return
        val currentUid = authRepository.currentUser?.uid ?: return
        val uid = targetUid ?: return
        val wasBlocked = current.isBlocked
        _uiState.value = current.copy(isBlocked = !wasBlocked)
        viewModelScope.launch {
            runCatching { if (wasBlocked) blockRepository.unblock(currentUid, uid) else blockRepository.block(currentUid, uid) }
                .onFailure { _uiState.value = current }
        }
    }
}
