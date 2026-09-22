package com.mochi.keyboard.data

import android.content.Context
import androidx.datastore.preferences.core.edit
import androidx.datastore.preferences.core.stringPreferencesKey
import androidx.datastore.preferences.core.stringSetPreferencesKey
import androidx.datastore.preferences.preferencesDataStore
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.map

private val Context.fontStyleDataStore by preferencesDataStore(name = "mochi_font_style")

/**
 * Where the applied keyboard font style lives, plus which styles the user "owns" — ported from
 * iOS's `FontStyleStore` (App Group `UserDefaults` there; local DataStore here, since Android's IME
 * runs in the same process as the app — same reasoning as [SettingsRepository]). The applied font is
 * deliberately independent of the active theme; nothing else should write [appliedStyleId] except a
 * future theme-apply flow, and only additively.
 */
class FontStyleRepository(private val context: Context) {

    /** The five styles Figma's MY DOWNLOADED FONTS strip ships with, in order — the first-run seed
     * so the strip is correct before the user has applied anything. */
    val seedOwnedStyleIds = listOf("bubble-cute", "handwritten-elegant", "bold-strong", "nature-flow", "gothic-dark")

    /** The style id the keyboard should transform typed text with, or null for plain text. */
    val appliedStyleId: Flow<String?> = context.fontStyleDataStore.data.map { it[KEY_APPLIED] }

    val ownedStyleIds: Flow<Set<String>> =
        context.fontStyleDataStore.data.map { it[KEY_OWNED] ?: seedOwnedStyleIds.toSet() }

    suspend fun apply(styleId: String?) {
        context.fontStyleDataStore.edit { prefs ->
            if (styleId != null) prefs[KEY_APPLIED] = styleId else prefs.remove(KEY_APPLIED)
        }
        if (styleId != null) addOwnedStyleId(styleId)
    }

    /** Adds a style to the owned set (idempotent). Applying a font also "downloads" it — there is
     * no separate download step, since a Unicode style has nothing to fetch. */
    suspend fun addOwnedStyleId(styleId: String) {
        context.fontStyleDataStore.edit { prefs ->
            val current = prefs[KEY_OWNED] ?: seedOwnedStyleIds.toSet()
            prefs[KEY_OWNED] = current + styleId
        }
    }

    private companion object {
        val KEY_APPLIED = stringPreferencesKey("applied_style_id")
        val KEY_OWNED = stringSetPreferencesKey("owned_style_ids")
    }
}
