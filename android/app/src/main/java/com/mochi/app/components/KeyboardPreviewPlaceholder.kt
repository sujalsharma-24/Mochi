package com.mochi.app.components

import androidx.compose.foundation.Canvas
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.geometry.CornerRadius
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.geometry.Size
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.Dp
import com.mochi.app.designsystem.MochiRadius
import kotlin.math.abs

/**
 * Ported from ios/MochiApp/Components/KeyboardPreviewPlaceholder.swift — a vector stand-in for a
 * theme's rendered keyboard background until real art assets are dropped in.
 */
private val placeholderPalettes = listOf(
    listOf(Color(0xFF44379B), Color(0xFF8351BD)),
    listOf(Color(0xFFF9B4D4), Color(0xFF9273D3)),
    listOf(Color(0xFF315340), Color(0xFF4E7E66)),
    listOf(Color(0xFFFAD39D), Color(0xFFFAB482)),
    listOf(Color(0xFF2E2E66), Color(0xFF6B4A9E))
)

@Composable
fun KeyboardPreviewPlaceholder(
    seed: String,
    modifier: Modifier = Modifier,
    cornerRadius: Dp = MochiRadius.card
) {
    val palette = placeholderPalettes[abs(seed.hashCode()) % placeholderPalettes.size]

    Canvas(
        modifier = modifier
            .fillMaxSize()
            .clip(RoundedCornerShape(cornerRadius))
    ) {
        drawRect(
            brush = Brush.linearGradient(
                colors = palette,
                start = Offset(0f, 0f),
                end = Offset(size.width, size.height)
            )
        )

        val rowCount = 3
        val topInset = size.height * 0.55f
        val rowHeight = size.height * 0.11f
        val rowGap = size.height * 0.035f
        val sideInset = size.width * 0.06f

        for (row in 0 until rowCount) {
            val keyCount = if (row == 2) 7 else 9
            val gap = size.width * 0.02f
            val totalGap = gap * (keyCount - 1)
            val keyWidth = (size.width - sideInset * 2 - totalGap) / keyCount
            val y = topInset + row * (rowHeight + rowGap)
            for (col in 0 until keyCount) {
                val x = sideInset + col * (keyWidth + gap)
                drawRoundRect(
                    color = Color.White.copy(alpha = 0.22f),
                    topLeft = Offset(x, y),
                    size = Size(keyWidth, rowHeight),
                    cornerRadius = CornerRadius(3f, 3f)
                )
            }
        }
    }
}
