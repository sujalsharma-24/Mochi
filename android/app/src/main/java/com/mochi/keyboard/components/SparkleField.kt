package com.mochi.keyboard.components

import androidx.compose.foundation.Canvas
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.Path
import androidx.compose.ui.graphics.drawscope.Fill

private data class Sparkle(val x: Float, val y: Float, val size: Float, val opacity: Float)

private val sparkles = listOf(
    Sparkle(0.06f, 0.02f, 10f, 0.55f),
    Sparkle(0.92f, 0.05f, 7f, 0.4f),
    Sparkle(0.88f, 0.14f, 12f, 0.5f),
    Sparkle(0.03f, 0.20f, 8f, 0.45f),
    Sparkle(0.5f, 0.235f, 6f, 0.4f),
    Sparkle(0.95f, 0.34f, 9f, 0.4f),
    Sparkle(0.05f, 0.40f, 7f, 0.35f),
    Sparkle(0.90f, 0.50f, 10f, 0.45f),
    Sparkle(0.04f, 0.58f, 8f, 0.4f),
    Sparkle(0.5f, 0.995f, 8f, 0.4f)
)

/**
 * Ported from ios/MochiApp/Components/SparkleField.swift — decorative ambient sparkles matching
 * Figma's star accents around the screen edges and between sections. Fixed relative positions (not
 * randomized per-render) so layout is stable across recompositions, sized as fractions of the
 * screen so it scales across devices.
 */
@Composable
fun SparkleField(modifier: Modifier = Modifier) {
    Canvas(modifier = modifier) {
        for (sparkle in sparkles) {
            val s = sparkle.size
            val center = Offset(size.width * sparkle.x, size.height * sparkle.y)
            val path = fourPointStar(center, s / 2)
            drawPath(path, Color.White.copy(alpha = sparkle.opacity), style = Fill)
        }
    }
}

private fun fourPointStar(c: Offset, r: Float): Path {
    val waist = r * 0.24f
    return Path().apply {
        moveTo(c.x, c.y - r)
        quadraticTo(c.x + waist, c.y - waist, c.x + r, c.y)
        quadraticTo(c.x + waist, c.y + waist, c.x, c.y + r)
        quadraticTo(c.x - waist, c.y + waist, c.x - r, c.y)
        quadraticTo(c.x - waist, c.y - waist, c.x, c.y - r)
        close()
    }
}
