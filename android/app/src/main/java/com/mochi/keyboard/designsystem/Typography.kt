package com.mochi.keyboard.designsystem

import androidx.compose.ui.text.ExperimentalTextApi
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.Font
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontVariation
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.TextUnit
import androidx.compose.ui.unit.sp
import com.mochi.keyboard.R

/**
 * Ported from ios/MochiApp/DesignSystem/Typography.swift. Figma's UI text (everything except the
 * "Mochi" wordmark) is Inter — inter_regular/medium/semibold/bold.ttf are the same static TTFs
 * bundled in ios/MochiApp/Fonts/, OFL-licensed (see android/licenses/Inter-OFL.txt). The wordmark
 * alone stays on Fredoka (variable font, `wght` axis dialed to 600 to match Figma's SemiBold look —
 * the font ships no named "Bold" instance, so FontWeight.Bold alone resolves to the wrong weight).
 */
private val interRegular = FontFamily(Font(R.font.inter_regular, FontWeight.Normal))
private val interMedium = FontFamily(Font(R.font.inter_medium, FontWeight.Medium))
private val interSemiBold = FontFamily(Font(R.font.inter_semibold, FontWeight.SemiBold))
private val interBold = FontFamily(Font(R.font.inter_bold, FontWeight.Bold))

@OptIn(ExperimentalTextApi::class)
private val fredokaLogo = FontFamily(
    Font(R.font.fredoka, FontWeight.SemiBold, variationSettings = FontVariation.Settings(FontVariation.weight(600)))
)

object MochiFont {
    /** Fredoka, wght 600 — the one style that stays off Inter. */
    fun logo(size: TextUnit = 34.sp) = TextStyle(fontSize = size, fontWeight = FontWeight.SemiBold, fontFamily = fredokaLogo)

    /** Bold — section headings ("POPULAR THEMES") and pill labels ("FONTS" / "THEMES"). */
    fun title(size: TextUnit = 22.sp) = TextStyle(fontSize = size, fontWeight = FontWeight.Bold, fontFamily = interBold)

    /** SemiBold — card titles ("Custom Create", "Choose from Library"). */
    fun heading(size: TextUnit = 17.sp) = TextStyle(fontSize = size, fontWeight = FontWeight.SemiBold, fontFamily = interSemiBold)

    /** Medium — item/theme/carousel names ("Fantasy Castle Night"). */
    fun itemName(size: TextUnit = 14.sp) = TextStyle(fontSize = size, fontWeight = FontWeight.Medium, fontFamily = interMedium)

    /** Regular — descriptions / body copy / "see all" links. */
    fun body(size: TextUnit = 15.sp) = TextStyle(fontSize = size, fontWeight = FontWeight.Normal, fontFamily = interRegular)

    /** Medium — nav bar labels and secondary/caption text. */
    fun caption(size: TextUnit = 13.sp) = TextStyle(fontSize = size, fontWeight = FontWeight.Medium, fontFamily = interMedium)

    /** SemiBold — buttons and pill CTAs. */
    fun button(size: TextUnit = 16.sp) = TextStyle(fontSize = size, fontWeight = FontWeight.SemiBold, fontFamily = interSemiBold)
}
