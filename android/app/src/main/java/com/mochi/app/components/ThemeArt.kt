package com.mochi.app.components

import androidx.compose.foundation.Image
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.unit.Dp
import com.mochi.app.R
import com.mochi.app.designsystem.MochiRadius

/**
 * Real art cropped from the client's Figma export (docs/figma/1.png) for the themes/fonts that
 * appear there. Anything not in this map falls back to the generated KeyboardPreviewPlaceholder
 * until the client provides isolated assets for the rest of the 250-theme catalog.
 */
private val knownThemeArt: Map<String, Int> = mapOf(
    "theme_fantasy_castle_night" to R.drawable.theme_fantasy_castle_night,
    "theme_space_vibe" to R.drawable.theme_space_vibe,
    "theme_dreamy_castle" to R.drawable.theme_dreamy_castle,
    "theme_pastel_pink_sky" to R.drawable.theme_pastel_pink_sky,
    "theme_forest" to R.drawable.theme_forest,
    "theme_cozy_sakura_cafe" to R.drawable.theme_cozy_sakura_cafe,
    "theme_pastel_rainbow" to R.drawable.theme_pastel_rainbow,
    "theme_sakura_train" to R.drawable.theme_sakura_train,
    "theme_kawaii_boba" to R.drawable.theme_kawaii_boba
)

private val knownFontArt: Map<String, Int> = mapOf(
    "font_bubble_cute" to R.drawable.font_bubble_cute,
    "font_handwritten_elegant" to R.drawable.font_handwritten_elegant,
    "font_typewriter_classic" to R.drawable.font_typewriter_classic,
    "font_bold_strong" to R.drawable.font_bold_strong
)

@Composable
fun ThemeArt(assetName: String, seed: String, modifier: Modifier = Modifier, cornerRadius: Dp = MochiRadius.card) {
    val resId = knownThemeArt[assetName]
    if (resId != null) {
        Image(
            painter = painterResource(resId),
            contentDescription = null,
            contentScale = ContentScale.Crop,
            modifier = modifier.fillMaxSize().clip(RoundedCornerShape(cornerRadius))
        )
    } else {
        KeyboardPreviewPlaceholder(seed = seed, modifier = modifier, cornerRadius = cornerRadius)
    }
}

@Composable
fun FontArtCard(assetName: String, modifier: Modifier = Modifier, cornerRadius: Dp = MochiRadius.card, content: @Composable () -> Unit) {
    val resId = knownFontArt[assetName]
    if (resId != null) {
        Image(
            painter = painterResource(resId),
            contentDescription = null,
            contentScale = ContentScale.Crop,
            modifier = modifier.clip(RoundedCornerShape(cornerRadius))
        )
    } else {
        content()
    }
}
