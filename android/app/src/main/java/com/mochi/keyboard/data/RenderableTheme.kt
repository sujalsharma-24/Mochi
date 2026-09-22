package com.mochi.keyboard.data

import com.mochi.keyboard.ime.render.BuiltInThemes
import com.mochi.keyboard.ime.render.MochiKeyboardTheme
import com.mochi.keyboard.model.KeyboardTheme
import java.text.Normalizer

/**
 * Bridges a marketplace [KeyboardTheme] (catalogue metadata) to the real render document the
 * keyboard surface draws — ported from iOS's `RenderableTheme.swift`. Every catalogue entry
 * anywhere in the app (Home, Community, Search, Leaderboard, Profile, Themes) resolves to *some*
 * real, live-typable theme this way, not just the 137 that already carry a matching built-in id:
 * **exact id -> exact name -> mood fallback**, in that order.
 */
object RenderableTheme {
    class Resolved(val theme: MochiKeyboardTheme, val isExact: Boolean)

    private val byId: Map<String, MochiKeyboardTheme> by lazy { BuiltInThemes.all.associateBy { it.id } }
    private val byName: Map<String, MochiKeyboardTheme> by lazy {
        val out = LinkedHashMap<String, MochiKeyboardTheme>()
        for (theme in BuiltInThemes.all) out.putIfAbsent(nameKey(theme.name), theme)
        out
    }

    private val darkKeywords = listOf(
        "night", "fantasy", "castle", "space", "galaxy", "cosmic", "midnight",
        "gothic", "dark", "noir", "star", "moon", "dream", "nebula"
    )

    fun resolve(theme: KeyboardTheme): Resolved {
        byId[theme.id]?.let { return Resolved(it, isExact = true) }
        byName[nameKey(theme.name)]?.let { return Resolved(it, isExact = true) }

        val haystack = nameKey(theme.name) + " " + theme.hashtags.joinToString(" ").lowercase()
        val isDark = darkKeywords.any { haystack.contains(it) }
        return Resolved(if (isDark) BuiltInThemes.fantasyCastleNight else BuiltInThemes.cozySakuraCafe, isExact = false)
    }

    /** The authored render document for a stored theme id, or null when it matches nothing — used
     * when re-resolving a persisted [AppliedThemeRepository] id, which has no hashtags/name to fall
     * back on and shouldn't silently swap in a mood stand-in the user never chose. */
    fun renderDocument(id: String): MochiKeyboardTheme? = byId[id]

    private fun nameKey(name: String): String =
        Normalizer.normalize(name, Normalizer.Form.NFD)
            .replace(Regex("\\p{Mn}+"), "")
            .lowercase()
            .trim()
}
