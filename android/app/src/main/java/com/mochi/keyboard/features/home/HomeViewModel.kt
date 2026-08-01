package com.mochi.keyboard.features.home

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.mochi.keyboard.data.ThemeCache
import com.mochi.keyboard.data.ThemeRepository
import com.mochi.keyboard.model.KeyboardTheme
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch

sealed interface HomeUiState {
    data object Loading : HomeUiState
    data class Data(val recentlyApplied: List<KeyboardTheme>, val popular: List<KeyboardTheme>) : HomeUiState
    data object Empty : HomeUiState
    data class Error(val message: String) : HomeUiState
}

class HomeViewModel(private val themeRepository: ThemeRepository) : ViewModel() {

    private val _uiState = MutableStateFlow<HomeUiState>(HomeUiState.Loading)
    val uiState: StateFlow<HomeUiState> = _uiState.asStateFlow()

    init {
        load()
    }

    fun load() {
        viewModelScope.launch {
            _uiState.value = HomeUiState.Loading
            runCatching {
                val recentlyApplied = themeRepository.getPublishedThemes(limit = 3)
                val popular = themeRepository.getTopRanked(limit = 10)
                ThemeCache.put(recentlyApplied + popular)
                recentlyApplied to popular
            }.onSuccess { (recentlyApplied, popular) ->
                _uiState.value = if (recentlyApplied.isEmpty() && popular.isEmpty()) {
                    HomeUiState.Empty
                } else {
                    HomeUiState.Data(recentlyApplied, popular)
                }
            }.onFailure { e ->
                _uiState.value = HomeUiState.Error(e.message ?: "Couldn't load themes.")
            }
        }
    }
}
