package com.mochi.keyboard.data

import android.content.Context
import androidx.datastore.preferences.core.edit
import androidx.datastore.preferences.core.stringPreferencesKey
import androidx.datastore.preferences.preferencesDataStore
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.map

private val Context.appliedThemeDataStore by preferencesDataStore(name = "mochi_applied_theme")

/**
 * The one marketplace theme the user has tapped Apply on — ported from iOS's `AppliedThemeStore`.
 * Simpler than iOS's version: iOS has to write into an App Group container and re-sync it on every
 * launch because the keyboard extension is a separate process that can only *read* that container.
 * Android's IME runs in the same process as the app (see [SettingsRepository]'s own note), so
 * `MochiInputMethodService` just reads this DataStore flow directly — no hand-off, no re-sync,
 * nothing to go silently stale.
 */
class AppliedThemeRepository(private val context: Context) {
    val appliedThemeId: Flow<String?> = context.appliedThemeDataStore.data.map { it[KEY_APPLIED] }

    suspend fun apply(themeId: String) {
        context.appliedThemeDataStore.edit { it[KEY_APPLIED] = themeId }
    }

    private companion object {
        val KEY_APPLIED = stringPreferencesKey("applied_theme_id")
    }
}
