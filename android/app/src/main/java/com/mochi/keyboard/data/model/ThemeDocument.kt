package com.mochi.keyboard.data.model

import com.google.firebase.firestore.DocumentId
import com.mochi.keyboard.model.KeyboardTheme

/**
 * Mirrors the real `themes/{themeId}` schema enforced by firestore/firestore.rules — only the
 * fields Home currently needs to display are modeled; backgroundConfig/keysConfig/fontsConfig/
 * effectsConfig are added when Create/Theme-Detail wiring picks them up. All defaults are required
 * for Firestore's reflection-based toObject() (needs a no-arg constructor).
 */
data class ThemeDocument(
    @DocumentId val id: String = "",
    val creatorUid: String = "",
    val creatorDisplayName: String = "",
    val creatorAvatarUrl: String = "",
    val name: String = "",
    val description: String = "",
    val hashtags: List<String> = emptyList(),
    val previewImageUrl: String = "",
    val isPremium: Boolean = false,
    val isPublished: Boolean = false,
    val moderationStatus: String = "pending",
    val likeCount: Long = 0,
    val downloadCount: Long = 0,
    val reportCount: Long = 0
)

/**
 * imageAssetName intentionally doesn't match any key in ThemeArt.kt's bundled-art maps — real
 * theme art (previewImageUrl) isn't wired to a loader yet, so this falls back to the existing
 * generated KeyboardPreviewPlaceholder rather than rendering nothing.
 */
fun ThemeDocument.toKeyboardTheme(): KeyboardTheme = KeyboardTheme(
    id = id,
    name = name,
    creatorName = creatorDisplayName,
    imageAssetName = "firestore:$id",
    likeCount = likeCount.toInt(),
    isPremium = isPremium,
    hashtags = hashtags,
    description = description
)
