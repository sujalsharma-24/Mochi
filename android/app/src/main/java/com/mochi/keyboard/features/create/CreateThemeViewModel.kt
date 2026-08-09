package com.mochi.keyboard.features.create

import android.net.Uri
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.mochi.keyboard.data.AuthRepository
import com.mochi.keyboard.data.CreateRepository
import com.mochi.keyboard.data.StorageRepository
import com.mochi.keyboard.data.model.BackgroundConfig
import com.mochi.keyboard.data.model.EffectsConfig
import com.mochi.keyboard.data.model.FontsConfig
import com.mochi.keyboard.data.model.KeysConfig
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch

sealed interface PublishUiState {
    data object Idle : PublishUiState
    data object Saving : PublishUiState
    data class Success(val published: Boolean) : PublishUiState
    data class Error(val message: String) : PublishUiState
}

private val keyShapeNames = listOf("square", "rounded", "circle", "hexagon")
private val fontStyleIds = listOf("default", "rounded", "cute", "classic", "handwritten")

/**
 * Publishes/saves-drafts CreateThemeScreen's local editor state via CreateRepository, matching
 * WA1's config schema. The screen's 4 preset background tiles are bundled drawables, not uploads —
 * there's nothing in Storage to point at, so they're encoded as `preset:{index}` in
 * backgroundConfig.galleryImageUrl, a bundled-asset identifier in the same spirit as
 * ThemeDocument.toKeyboardTheme()'s "firestore:$id" convention, not a real download URL. A picked
 * gallery photo uses the real StorageRepository upload path instead. description/isPremium have no
 * UI control on this screen (neither did iOS's CreateThemeView) so they're sent as blank/false —
 * nothing here forecloses adding real controls later, per ThemeDocument's own doc comment.
 */
class CreateThemeViewModel(
    private val createRepository: CreateRepository,
    private val storageRepository: StorageRepository,
    private val authRepository: AuthRepository
) : ViewModel() {

    private val _publishState = MutableStateFlow<PublishUiState>(PublishUiState.Idle)
    val publishState: StateFlow<PublishUiState> = _publishState.asStateFlow()

    fun save(
        name: String,
        tags: List<String>,
        presetBackgroundIndex: Int?,
        galleryImageUri: Uri?,
        keyShapeIndex: Int,
        fontStyleIndex: Int,
        publish: Boolean
    ) {
        val user = authRepository.currentUser
        if (user == null) {
            _publishState.value = PublishUiState.Error("Sign in to save a theme.")
            return
        }
        if (name.isBlank()) {
            _publishState.value = PublishUiState.Error("Give your theme a name first.")
            return
        }
        _publishState.value = PublishUiState.Saving
        viewModelScope.launch {
            runCatching {
                val galleryUrl = galleryImageUri?.let { storageRepository.uploadThemeImage(user.uid, it) }
                val backgroundConfig = BackgroundConfig(
                    galleryImageUrl = galleryUrl ?: "preset:${presetBackgroundIndex ?: 0}"
                )
                createRepository.saveTheme(
                    creatorUid = user.uid,
                    creatorDisplayName = user.displayName?.takeIf { it.isNotBlank() } ?: "Mochi Creator",
                    creatorAvatarUrl = user.photoUrl?.toString() ?: "",
                    name = name,
                    description = "",
                    hashtags = tags,
                    previewImageUrl = galleryUrl ?: "",
                    isPremium = false,
                    publish = publish,
                    backgroundType = "gallery",
                    backgroundConfig = backgroundConfig,
                    keysConfig = KeysConfig(shape = keyShapeNames.getOrElse(keyShapeIndex) { "rounded" }),
                    fontsConfig = FontsConfig(fontId = fontStyleIds.getOrElse(fontStyleIndex) { "default" }),
                    effectsConfig = EffectsConfig()
                )
            }.onSuccess {
                _publishState.value = PublishUiState.Success(published = publish)
            }.onFailure { e ->
                _publishState.value = PublishUiState.Error(e.message ?: "Couldn't save your theme.")
            }
        }
    }

    fun dismissStatus() {
        _publishState.value = PublishUiState.Idle
    }
}
