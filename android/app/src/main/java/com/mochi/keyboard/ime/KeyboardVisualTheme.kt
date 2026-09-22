package com.mochi.keyboard.ime

import android.graphics.Color
import androidx.annotation.DrawableRes
import com.mochi.keyboard.R

/**
 * Every themed surface in the keyboard - key fills/pressed states, text color, borders, special-key
 * accents, the suggestion bar, and the key-press popup - reads from one of these instead of each
 * view hardcoding its own colors. Firestore's theme catalog (KeyboardTheme in model/) only carries
 * catalog metadata (name/creator/image/likes) today, not visual key-styling fields, so this is a
 * hand-authored stand-in for the one theme the spike ships with until that data exists server-side.
 */
data class KeyboardVisualTheme(
    @DrawableRes val backgroundImageRes: Int,
    val keyFillColor: Int,
    val keyPressedFillColor: Int,
    val keyTextColor: Int,
    val keyBorderColor: Int,
    val specialKeyFillColor: Int,
    val specialKeyPressedFillColor: Int,
    val specialKeyIconTint: Int,
    val suggestionBarColor: Int,
    val suggestionTextColor: Int,
    val popupFillColor: Int,
    val popupTextColor: Int,
    val keyCornerRadiusDp: Float = 10f,
    val keyBorderWidthDp: Float = 1f,
    val keyElevationDp: Float = 2f,
    /** Small decorative art (e.g. a lantern, a flower) drawn above the letter on every letter key -
     * a themed accent, distinct from [keyTextColor]/[specialKeyIconTint] which are tints applied to
     * single-color icons. Empty means no decorative icon layer (e.g. [fantasyCastleNight]). */
    val letterKeyIcons: List<Int> = emptyList(),
    val letterKeyIconSizeDp: Float = 22f,
    val letterKeyIconAlpha: Float = 1f,
    /** Shown behind [backgroundImageRes] wherever the image doesn't reach - the image is never
     * cropped to fill the keyboard (it's shown whole, anchored to the bottom row of keys), so on a
     * device whose keyboard is proportionally taller than the image, this fills the leftover strip
     * above it instead of leaving it blank. */
    val backgroundFallbackColor: Int = Color.BLACK,
    /** A stretchable (nine-patch) key card - when set, every key is built from this art instead of
     * the flat [keyFillColor] GradientDrawable, so a hand-drawn card design can be reused across
     * every key size (letter, spacebar, shift...) without needing one image per key. Null keeps the
     * flat-color look (e.g. [fantasyCastleNight]). */
    @DrawableRes val keyTextureRes: Int? = null,
    /** One-off art for keys that only ever appear once on the keyboard - unlike [letterKeyIcons]
     * these are shown exactly as drawn, never cycled. Null falls back to the generic tinted icon
     * (or "space" text) so themes without custom key art keep working unchanged. */
    @DrawableRes val shiftKeyArtRes: Int? = null,
    @DrawableRes val backspaceKeyArtRes: Int? = null,
    @DrawableRes val spacebarArtRes: Int? = null,
    @DrawableRes val enterKeyArtRes: Int? = null
) {
    /** Every letter gets a fixed icon from [letterKeyIcons] so the same theme always looks the same -
     * spread with a +3 step per QWERTY position so adjacent keys never repeat the same icon. */
    fun letterKeyIcon(letter: Char): Int? {
        if (letterKeyIcons.isEmpty()) return null
        val position = LETTER_ORDER.indexOf(letter.lowercaseChar())
        if (position < 0) return null
        return letterKeyIcons[(position * 7 + 3) % letterKeyIcons.size]
    }

    private companion object {
        const val LETTER_ORDER = "qwertyuiopasdfghjklzxcvbnm"
    }
}

object MochiThemes {
    val fantasyCastleNight = KeyboardVisualTheme(
        backgroundImageRes = R.drawable.theme_fantasy_castle_night,
        keyFillColor = Color.parseColor("#40FFFFFF"),
        keyPressedFillColor = Color.parseColor("#66C9B6FF"),
        keyTextColor = Color.parseColor("#FFF5F0FF"),
        keyBorderColor = Color.parseColor("#55FFFFFF"),
        specialKeyFillColor = Color.parseColor("#552E1065"),
        specialKeyPressedFillColor = Color.parseColor("#77452090"),
        specialKeyIconTint = Color.parseColor("#FFF5F0FF"),
        suggestionBarColor = Color.parseColor("#552A1B54"),
        suggestionTextColor = Color.parseColor("#FFE9E1FF"),
        popupFillColor = Color.parseColor("#EE3C1A66"),
        popupTextColor = Color.parseColor("#FFFFFFFF")
    )

    /** Second pass: hand-drawn key card art (see docs/research/keyboard-theming/) instead of flat
     * translucent glass - the wood/cream card is one stretchable image reused for every key, the
     * drink icon set cycles across letters, and the 4 special keys get their own one-off art.
     * keyElevationDp is 0 here since the card art already carries its own baked-in drop shadow -
     * Android's elevation shadow on top of that reads as a doubled, muddy edge. */
    val bubbleTea = KeyboardVisualTheme(
        backgroundImageRes = R.drawable.theme_bubble_tea,
        keyFillColor = Color.parseColor("#4DFFFFFF"),
        keyPressedFillColor = Color.parseColor("#80FF8FA6"),
        keyTextColor = Color.parseColor("#FF5A3A3A"),
        keyBorderColor = Color.parseColor("#66FFC1CC"),
        specialKeyFillColor = Color.parseColor("#59D97A93"),
        specialKeyPressedFillColor = Color.parseColor("#80C65C7A"),
        specialKeyIconTint = Color.parseColor("#FF5A3A3A"),
        suggestionBarColor = Color.parseColor("#59FFF0F3"),
        suggestionTextColor = Color.parseColor("#FF5A3A3A"),
        popupFillColor = Color.parseColor("#F2FFD7E1"),
        popupTextColor = Color.parseColor("#FF3D2626"),
        backgroundFallbackColor = Color.parseColor("#FF9F6142"),
        keyElevationDp = 0f,
        keyTextureRes = R.drawable.theme_bubble_tea_key_normal,
        shiftKeyArtRes = R.drawable.theme_bubble_tea_key_shift,
        backspaceKeyArtRes = R.drawable.theme_bubble_tea_key_backspace,
        spacebarArtRes = R.drawable.theme_bubble_tea_key_space,
        enterKeyArtRes = R.drawable.theme_bubble_tea_key_enter,
        letterKeyIconSizeDp = 42f,
        letterKeyIcons = listOf(
            R.drawable.ic_bt2_matcha,
            R.drawable.ic_bt2_strawberry,
            R.drawable.ic_bt2_taro1,
            R.drawable.ic_bt2_taro2,
            R.drawable.ic_bt2_mango,
            R.drawable.ic_bt2_classic1,
            R.drawable.ic_bt2_classic2,
            R.drawable.ic_bt2_vanilla,
            R.drawable.ic_bt2_blueberry1,
            R.drawable.ic_bt2_blueberry2,
            R.drawable.ic_bt2_peach,
            R.drawable.ic_bt2_lavender
        )
    )
}
