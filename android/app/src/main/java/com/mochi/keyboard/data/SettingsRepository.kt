package com.mochi.keyboard.data

import android.content.Context
import androidx.datastore.preferences.core.Preferences
import androidx.datastore.preferences.core.booleanPreferencesKey
import androidx.datastore.preferences.core.edit
import androidx.datastore.preferences.core.stringPreferencesKey
import androidx.datastore.preferences.preferencesDataStore
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.map

private val Context.settingsDataStore by preferencesDataStore(name = "mochi_settings")

/**
 * Local-device keyboard/notification/language preferences. Read by both the Settings screen and
 * MochiInputMethodService - the IME runs in the same process as MainActivity (no android:process
 * override in the manifest), so a plain DataStore read is enough; no cross-process bridge (e.g.
 * iOS's App Group) is needed here. This is the source of truth WA6's toggle-enforcement work reads
 * from inside the IME.
 */
class SettingsRepository(private val context: Context) {

    val autocorrectEnabled: Flow<Boolean> = boolFlow(KEY_AUTOCORRECT, default = true)
    val swipeTypingEnabled: Flow<Boolean> = boolFlow(KEY_SWIPE_TYPING, default = true)
    val hapticFeedbackEnabled: Flow<Boolean> = boolFlow(KEY_HAPTIC_FEEDBACK, default = true)
    val keyClickSoundEnabled: Flow<Boolean> = boolFlow(KEY_CLICK_SOUND, default = false)
    val languagePreference: Flow<String> = context.settingsDataStore.data.map { it[KEY_LANGUAGE] ?: "en" }

    suspend fun setAutocorrectEnabled(enabled: Boolean) = setBool(KEY_AUTOCORRECT, enabled)
    suspend fun setSwipeTypingEnabled(enabled: Boolean) = setBool(KEY_SWIPE_TYPING, enabled)
    suspend fun setHapticFeedbackEnabled(enabled: Boolean) = setBool(KEY_HAPTIC_FEEDBACK, enabled)
    suspend fun setKeyClickSoundEnabled(enabled: Boolean) = setBool(KEY_CLICK_SOUND, enabled)

    suspend fun setLanguagePreference(languageCode: String) {
        context.settingsDataStore.edit { it[KEY_LANGUAGE] = languageCode }
    }

    private fun boolFlow(key: Preferences.Key<Boolean>, default: Boolean): Flow<Boolean> =
        context.settingsDataStore.data.map { it[key] ?: default }

    private suspend fun setBool(key: Preferences.Key<Boolean>, value: Boolean) {
        context.settingsDataStore.edit { it[key] = value }
    }

    private companion object {
        val KEY_AUTOCORRECT = booleanPreferencesKey("autocorrect_enabled")
        val KEY_SWIPE_TYPING = booleanPreferencesKey("swipe_typing_enabled")
        val KEY_HAPTIC_FEEDBACK = booleanPreferencesKey("haptic_feedback_enabled")
        val KEY_CLICK_SOUND = booleanPreferencesKey("key_click_sound_enabled")
        val KEY_LANGUAGE = stringPreferencesKey("language_preference")
    }
}
