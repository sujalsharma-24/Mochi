package com.mochi.keyboard.features.themes

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.mochi.keyboard.data.ThemeCache
import com.mochi.keyboard.data.ThemeRepository
import com.mochi.keyboard.model.KeyboardTheme
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch

sealed interface ThemesUiState {
    data object Loading : ThemesUiState
    data class Data(val themes: List<KeyboardTheme>) : ThemesUiState
    data object Empty : ThemesUiState
    data class Error(val message: String) : ThemesUiState
}

class ThemesViewModel(private val themeRepository: ThemeRepository) : ViewModel() {

    private val _uiState = MutableStateFlow<ThemesUiState>(ThemesUiState.Loading)
    val uiState: StateFlow<ThemesUiState> = _uiState.asStateFlow()

    init {
        load()
    }

    fun load() {
        viewModelScope.launch {
            _uiState.value = ThemesUiState.Loading
            runCatching { themeRepository.getPublishedThemes(limit = 30) }
                .onSuccess { themes ->
                    ThemeCache.put(themes)
                    _uiState.value = if (themes.isEmpty()) ThemesUiState.Empty else ThemesUiState.Data(themes)
                }
                .onFailure { e -> _uiState.value = ThemesUiState.Error(e.message ?: "Couldn't load themes.") }
        }
    }
}
