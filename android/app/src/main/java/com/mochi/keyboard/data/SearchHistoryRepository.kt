package com.mochi.keyboard.data

import android.content.Context
import androidx.datastore.preferences.core.edit
import androidx.datastore.preferences.core.stringPreferencesKey
import androidx.datastore.preferences.preferencesDataStore
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.map

private val Context.searchHistoryDataStore by preferencesDataStore(name = "mochi_search_history")

/**
 * Search's "RECENT SEARCHES" chips - purely local/on-device, no backend collection exists for
 * this (no per-user search-log schema anywhere in firestore.rules), unlike Trending/Suggestions
 * which have no real data source at all. Stored as a single delimited string rather than
 * stringSetPreferencesKey because DataStore's string-set type is unordered, and "most recent
 * first" is the whole point here.
 */
class SearchHistoryRepository(private val context: Context) {

    val recentSearches: Flow<List<String>> = context.searchHistoryDataStore.data.map { prefs ->
        prefs[KEY_HISTORY]?.split(SEPARATOR)?.filter { it.isNotBlank() } ?: emptyList()
    }

    suspend fun record(query: String) {
        val trimmed = query.trim()
        if (trimmed.isEmpty()) return
        context.searchHistoryDataStore.edit { prefs ->
            val existing = prefs[KEY_HISTORY]?.split(SEPARATOR)?.filter { it.isNotBlank() } ?: emptyList()
            val updated = (listOf(trimmed) + existing.filterNot { it.equals(trimmed, ignoreCase = true) }).take(MAX_ENTRIES)
            prefs[KEY_HISTORY] = updated.joinToString(SEPARATOR)
        }
    }

    suspend fun clear() {
        context.searchHistoryDataStore.edit { it.remove(KEY_HISTORY) }
    }

    private companion object {
        val KEY_HISTORY = stringPreferencesKey("recent_searches")
        const val SEPARATOR = "␟"
        const val MAX_ENTRIES = 8
    }
}
