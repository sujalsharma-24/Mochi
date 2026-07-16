package com.mochi.app.designsystem

import androidx.compose.ui.text.ExperimentalTextApi
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.Font
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontVariation
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.TextUnit
import androidx.compose.ui.unit.sp
import com.mochi.app.R

/**
 * Ported from ios/MochiApp/DesignSystem/Typography.swift. iOS uses SF Rounded (`.design =
 * .rounded`), a built-in Apple font; Compose has no equivalent bundled, so this uses Baloo 2
 * (Google Fonts, OFL-licensed — see android/licenses/Baloo2-OFL.txt) as the closest visual match
 * to Figma's rounded/bold display type for most text. `baloo2.ttf` is a single variable font
 * (weight axis), so each weight below points at the same file with a different FontVariation.
 *
 * The "Mochi" wordmark specifically uses Fredoka (also Google Fonts, OFL — see
 * android/licenses/Fredoka-OFL.txt) instead: Baloo 2 even at its heaviest weight still has
 * pointed letter peaks, while Figma's logo (docs/figma/13.png) is a much rounder, bubblier,
 * uniform-stroke bold that matches Fredoka's letterforms far more closely.
 */
@OptIn(ExperimentalTextApi::class)
private fun balooWeight(weight: Int) = FontFamily(
    Font(R.font.baloo2, FontWeight(weight), variationSettings = FontVariation.Settings(FontVariation.weight(weight)))
)

@OptIn(ExperimentalTextApi::class)
private fun fredokaWeight(weight: Int) = FontFamily(
    Font(R.font.fredoka, FontWeight(weight), variationSettings = FontVariation.Settings(FontVariation.weight(weight)))
)

object MochiFont {
    fun logo(size: TextUnit = 34.sp) = TextStyle(fontSize = size, fontWeight = FontWeight.Bold, fontFamily = fredokaWeight(700))
    fun title(size: TextUnit = 22.sp) = TextStyle(fontSize = size, fontWeight = FontWeight.Bold, fontFamily = balooWeight(700))
    fun heading(size: TextUnit = 17.sp) = TextStyle(fontSize = size, fontWeight = FontWeight.Bold, fontFamily = balooWeight(700))
    fun body(size: TextUnit = 15.sp) = TextStyle(fontSize = size, fontWeight = FontWeight.Medium, fontFamily = balooWeight(500))
    fun caption(size: TextUnit = 13.sp) = TextStyle(fontSize = size, fontWeight = FontWeight.Normal, fontFamily = balooWeight(400))
    fun button(size: TextUnit = 16.sp) = TextStyle(fontSize = size, fontWeight = FontWeight.Bold, fontFamily = balooWeight(700))
}
