package com.mochi.keyboard.data.model

import com.google.firebase.firestore.DocumentId
import com.mochi.keyboard.model.KeyboardTheme

/**
 * The Create screen's four tabs (Background/Keys/Fonts/Effects, see CreateThemeScreen.kt) each
 * write one of these; the eventual keyboard renderer (not yet wired - excluded from this pass by
 * design) reads the same maps back. Field names/shape are freely chosen (Firestore stores them as
 * plain untyped maps; firestore.rules only constrains the five top-level document keys, not what's
 * inside them), but every string enum here (shape/effect ids etc.) must line up with whatever
 * CreateThemeScreen's UI actually offers once that screen is wired to write real values instead of
 * a local Int tab-index - see project plan WA4 step 4.
 */
enum class BackgroundType { SOLID, GRADIENT, GALLERY }

data class BackgroundConfig(
    val solidColor: String = "#FFFFFF",
    val gradientStartColor: String = "#FFFFFF",
    val gradientEndColor: String = "#FFFFFF",
    val gradientDirection: String = "diagonal",
    val galleryImageUrl: String = ""
)

/** shape matches Figma/CreateThemeScreen's actual 4 options (square/rounded/circle/hexagon), not
 * the written feature spec's differing list (rounded/sharp/pill/square) - Figma wins per standing
 * project convention. */
data class KeysConfig(
    val shape: String = "rounded",
    val fillColor: String = "#FFFFFF",
    val borderWidth: Int = 0,
    val borderColor: String = "#000000",
    val hasShadow: Boolean = false
)

data class FontsConfig(
    val fontId: String = "bubble-cute",
    val textColor: String = "#000000",
    val sizePercent: Int = 100,
    val isBold: Boolean = false
)

data class EffectsConfig(
    val keyPressEffect: String = "none",
    val backgroundEffect: String = "none",
    val trailEffect: String = "none"
)

/**
 * Mirrors the real `themes/{themeId}` schema enforced by firestore/firestore.rules — every field
 * the rules' create/update allowlists reference now has a matching property here.
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
    val reportCount: Long = 0,
    val backgroundType: String = BackgroundType.SOLID.name.lowercase(),
    val backgroundConfig: BackgroundConfig = BackgroundConfig(),
    val keysConfig: KeysConfig = KeysConfig(),
    val fontsConfig: FontsConfig = FontsConfig(),
    val effectsConfig: EffectsConfig = EffectsConfig()
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
    description = description,
    creatorUid = creatorUid
)
