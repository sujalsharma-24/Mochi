package com.mochi.keyboard.features.themedetail

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.mochi.keyboard.data.AuthRepository
import com.mochi.keyboard.data.LikeRepository
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch

/**
 * Liking writes a real `likes/{uid}_{themeId}` doc (verified against the local emulator - see
 * functions/test/integration.mjs). The theme's own stored likeCount only updates once the
 * onLikeWritten Cloud Function processes that write server-side, so [likeCount] here is a local
 * optimistic counter for instant feedback, not a read of the persisted field - it can drift from
 * the real value by however long that trigger takes to run, and isn't re-synced after.
 */
class ThemeDetailViewModel(
    private val likeRepository: LikeRepository,
    private val authRepository: AuthRepository,
    private val themeId: String,
    initialLikeCount: Int
) : ViewModel() {

    private val _isLiked = MutableStateFlow(false)
    val isLiked: StateFlow<Boolean> = _isLiked.asStateFlow()

    private val _likeCount = MutableStateFlow(initialLikeCount)
    val likeCount: StateFlow<Int> = _likeCount.asStateFlow()

    init {
        authRepository.currentUser?.uid?.let { uid ->
            viewModelScope.launch {
                runCatching { likeRepository.isLiked(uid, themeId) }.onSuccess { _isLiked.value = it }
            }
        }
    }

    fun toggleLike() {
        val uid = authRepository.currentUser?.uid ?: return
        val wasLiked = _isLiked.value
        _isLiked.value = !wasLiked
        _likeCount.value += if (wasLiked) -1 else 1
        viewModelScope.launch {
            runCatching {
                if (wasLiked) likeRepository.unlike(uid, themeId) else likeRepository.like(uid, themeId)
            }.onFailure {
                _isLiked.value = wasLiked
                _likeCount.value += if (wasLiked) 1 else -1
            }
        }
    }
}
