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
    val keyElevationDp: Float = 2f
)

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
}
