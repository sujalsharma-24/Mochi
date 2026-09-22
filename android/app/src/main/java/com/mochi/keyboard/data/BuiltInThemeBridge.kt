package com.mochi.keyboard.data

import com.mochi.keyboard.ime.render.BuiltInThemeThumbnails
import com.mochi.keyboard.ime.render.BuiltInThemes
import com.mochi.keyboard.model.KeyboardTheme

/**
 * Bridges the real keyboard-rendering catalog (`ime/render/BuiltInThemes`, 140 themes with real
 * background art, per-key illustrations and live-typable preview) into the app's display model, so
 * the Themes grid can show them as real, tappable, fully-previewable cards — not just Firestore
 * community submissions or `MockData`.
 *
 * The 3 hand-authored themes (Cozy Sakura Café, Fantasy Castle Night, Dreamy Castle) are excluded:
 * they're already present in `MockData` under their own ids, and including both would duplicate
 * them in the grid.
 */
object BuiltInThemeBridge {
    val catalog: List<KeyboardTheme> by lazy {
        BuiltInThemes.all
            .filter { BuiltInThemeThumbnails.byId.containsKey(it.id) }
            .map { theme ->
                KeyboardTheme(
                    id = theme.id,
                    name = theme.name,
                    creatorName = theme.authorName ?: "Mochi",
                    imageAssetName = BuiltInThemeThumbnails.byId.getValue(theme.id),
                    likeCount = 0,
                    isPremium = false,
                    hashtags = emptyList()
                )
            }
    }
}
