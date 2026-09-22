package com.mochi.keyboard.features.fonts

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.mochi.keyboard.data.FontStyleRepository
import com.mochi.keyboard.ime.render.FontStyleCatalog
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.stateIn
import kotlinx.coroutines.launch

/** Real backing for the previously pure-mock Fonts screen: which style is applied to the keyboard
 * right now (read by [com.mochi.keyboard.ime.MochiInputMethodService] via the same
 * [FontStyleRepository]) and which styles the user owns. */
class FontsViewModel(private val fontStyleRepository: FontStyleRepository) : ViewModel() {

    val appliedStyleId: StateFlow<String?> = fontStyleRepository.appliedStyleId
        .stateIn(viewModelScope, SharingStarted.WhileSubscribed(5000), null)

    val ownedStyleIds: StateFlow<Set<String>> = fontStyleRepository.ownedStyleIds
        .stateIn(viewModelScope, SharingStarted.WhileSubscribed(5000), fontStyleRepository.seedOwnedStyleIds.toSet())

    fun applyFont(id: String) {
        viewModelScope.launch { fontStyleRepository.apply(id) }
    }

    /** What the keyboard would actually emit for [text] under style [id] — the same table used by
     * [FontStyleCatalog], so this preview can never drift from what the keyboard does. */
    fun styledPreview(id: String, text: String): String = FontStyleCatalog.style(id)?.styled(text) ?: text
}
