package com.mochi.app.designsystem

import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.TextUnit
import androidx.compose.ui.unit.sp

/**
 * Ported from ios/MochiApp/DesignSystem/Typography.swift. iOS uses SF Rounded (`.design =
 * .rounded`); Compose has no built-in rounded family, so this falls back to the system font
 * for now. Swap in a Google Fonts rounded family (e.g. Baloo 2 / Fredoka) via
 * androidx.compose.ui.text.googlefonts to match the Figma look more closely.
 */
object MochiFont {
    fun logo(size: TextUnit = 34.sp) = TextStyle(fontSize = size, fontWeight = FontWeight.Black)
    fun title(size: TextUnit = 22.sp) = TextStyle(fontSize = size, fontWeight = FontWeight.Bold)
    fun heading(size: TextUnit = 17.sp) = TextStyle(fontSize = size, fontWeight = FontWeight.Bold)
    fun body(size: TextUnit = 15.sp) = TextStyle(fontSize = size, fontWeight = FontWeight.Medium)
    fun caption(size: TextUnit = 13.sp) = TextStyle(fontSize = size, fontWeight = FontWeight.Normal)
    fun button(size: TextUnit = 16.sp) = TextStyle(fontSize = size, fontWeight = FontWeight.Bold)
}
