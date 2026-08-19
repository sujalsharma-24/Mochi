package com.mochi.keyboard.features.settings

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.mochi.keyboard.data.AuthRepository
import com.mochi.keyboard.data.SettingsRepository
import com.mochi.keyboard.data.UserRepository
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.combine
import kotlinx.coroutines.flow.stateIn
import kotlinx.coroutines.launch

data class SettingsUiState(
    val accountLabel: String = "",
    val autocorrectEnabled: Boolean = true,
    val swipeTypingEnabled: Boolean = true,
    val hapticFeedbackEnabled: Boolean = true,
    val keyClickSoundEnabled: Boolean = false,
    val notificationsEnabled: Boolean = true,
    val isDeletingAccount: Boolean = false,
    val errorMessage: String? = null
)

/**
 * Persists the 4 keyboard toggles to [SettingsRepository] (DataStore) - MochiInputMethodService
 * reads the same repository directly (no ViewModel there, it's a Service) to actually obey
 * haptic-feedback/key-click-sound at keypress time. Autocorrect/swipe-typing persist the same way
 * but have no runtime effect yet: neither engine exists in the IME (explicitly out of this whole
 * plan's scope, see the Android functional plan doc), so there's nothing beyond storage to wire
 * for those two today.
 */
class SettingsViewModel(
    private val settingsRepository: SettingsRepository,
    private val authRepository: AuthRepository,
    private val userRepository: UserRepository
) : ViewModel() {

    private val toggles = combine(
        settingsRepository.autocorrectEnabled,
        settingsRepository.swipeTypingEnabled,
        settingsRepository.hapticFeedbackEnabled,
        settingsRepository.keyClickSoundEnabled
    ) { autocorrect, swipeTyping, haptic, keyClick -> listOf(autocorrect, swipeTyping, haptic, keyClick) }
        .stateIn(viewModelScope, SharingStarted.WhileSubscribed(5000), listOf(true, true, true, false))

    // notificationsEnabled lives on users/{uid} in Firestore, not local DataStore - unlike the 4
    // keyboard toggles, functions/src/notifications.ts (a Cloud Function, not this device) needs to
    // read it before sending a push, so it has to be server-visible, not just on-device.
    private val _notificationsEnabled = MutableStateFlow(true)
    private val _errorMessage = MutableStateFlow<String?>(null)
    private val _isDeletingAccount = MutableStateFlow(false)

    init {
        val uid = authRepository.currentUser?.uid
        if (uid != null) {
            viewModelScope.launch {
                runCatching { userRepository.getUser(uid) }
                    .onSuccess { user -> _notificationsEnabled.value = user?.notificationsEnabled ?: true }
            }
        }
    }

    val uiState: StateFlow<SettingsUiState> = combine(
        toggles, _notificationsEnabled, _isDeletingAccount, _errorMessage
    ) { t, notifications, deleting, error ->
        SettingsUiState(
            accountLabel = accountLabel(),
            autocorrectEnabled = t[0],
            swipeTypingEnabled = t[1],
            hapticFeedbackEnabled = t[2],
            keyClickSoundEnabled = t[3],
            notificationsEnabled = notifications,
            isDeletingAccount = deleting,
            errorMessage = error
        )
    }.stateIn(viewModelScope, SharingStarted.WhileSubscribed(5000), SettingsUiState())

    private fun accountLabel(): String {
        val user = authRepository.currentUser ?: return "Not signed in"
        return user.email ?: user.phoneNumber ?: "Signed in"
    }

    fun setAutocorrectEnabled(enabled: Boolean) = viewModelScope.launch { settingsRepository.setAutocorrectEnabled(enabled) }
    fun setSwipeTypingEnabled(enabled: Boolean) = viewModelScope.launch { settingsRepository.setSwipeTypingEnabled(enabled) }
    fun setHapticFeedbackEnabled(enabled: Boolean) = viewModelScope.launch { settingsRepository.setHapticFeedbackEnabled(enabled) }
    fun setKeyClickSoundEnabled(enabled: Boolean) = viewModelScope.launch { settingsRepository.setKeyClickSoundEnabled(enabled) }

    fun setNotificationsEnabled(enabled: Boolean) {
        val uid = authRepository.currentUser?.uid ?: return
        _notificationsEnabled.value = enabled // optimistic, same pattern as Like/Follow toggles
        viewModelScope.launch {
            runCatching { userRepository.setNotificationsEnabled(uid, enabled) }
                .onFailure { _notificationsEnabled.value = !enabled } // revert on failure
        }
    }

    fun signOut() = authRepository.signOut()

    fun deleteAccount(onDeleted: () -> Unit) {
        _isDeletingAccount.value = true
        viewModelScope.launch {
            runCatching { authRepository.deleteAccount() }
                .onSuccess {
                    _isDeletingAccount.value = false
                    onDeleted()
                }
                .onFailure { e ->
                    _isDeletingAccount.value = false
                    _errorMessage.value = e.message ?: "Couldn't delete your account. Please try again."
                }
        }
    }

    fun clearError() {
        _errorMessage.value = null
    }
}
