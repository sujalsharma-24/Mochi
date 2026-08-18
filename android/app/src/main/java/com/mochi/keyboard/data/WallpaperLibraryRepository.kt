package com.mochi.keyboard.data

import android.content.Context
import androidx.datastore.preferences.core.edit
import androidx.datastore.preferences.core.stringPreferencesKey
import androidx.datastore.preferences.preferencesDataStore
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.map

private val Context.wallpaperLibraryDataStore by preferencesDataStore(name = "mochi_wallpaper_library")

/**
 * Wallpapers' "Recently Downloaded" section - purely local/on-device, same shape as
 * SearchHistoryRepository's Recent Searches. `liveWallpapers` is admin-authored and read-only
 * (firestore.rules: `allow write: if false`), so there's no server-side download counter this
 * could write to even if one existed in the schema - this is the only honest "real" behavior
 * Download can have without inventing new backend infrastructure. Tracks wallpaper ids only, most-
 * recent-first, dedup-and-move-to-front.
 */
class WallpaperLibraryRepository(private val context: Context) {

    val downloadedIds: Flow<List<String>> = context.wallpaperLibraryDataStore.data.map { prefs ->
        prefs[KEY_DOWNLOADED]?.split(SEPARATOR)?.filter { it.isNotBlank() } ?: emptyList()
    }

    suspend fun markDownloaded(wallpaperId: String) {
        context.wallpaperLibraryDataStore.edit { prefs ->
            val existing = prefs[KEY_DOWNLOADED]?.split(SEPARATOR)?.filter { it.isNotBlank() } ?: emptyList()
            val updated = listOf(wallpaperId) + existing.filterNot { it == wallpaperId }
            prefs[KEY_DOWNLOADED] = updated.joinToString(SEPARATOR)
        }
    }

    private companion object {
        val KEY_DOWNLOADED = stringPreferencesKey("downloaded_wallpaper_ids")
        const val SEPARATOR = "␟"
    }
}
