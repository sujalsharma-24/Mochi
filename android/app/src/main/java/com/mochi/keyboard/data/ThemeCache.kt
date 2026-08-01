package com.mochi.keyboard.data

import com.mochi.keyboard.model.KeyboardTheme

/**
 * ui/AppNavHost.kt's themeDetail/{themeId} route needs to resolve a real Firestore-backed theme by
 * id without re-fetching on every navigation. Populated as screens fetch themes; falls back to
 * MockData in the nav graph for anything not yet converted off mock data. Main-thread-only access
 * (Compose navigation), so a plain mutable map is enough — no synchronization needed.
 */
object ThemeCache {
    private val cache = mutableMapOf<String, KeyboardTheme>()

    fun put(themes: List<KeyboardTheme>) {
        themes.forEach { cache[it.id] = it }
    }

    fun get(id: String): KeyboardTheme? = cache[id]
}
