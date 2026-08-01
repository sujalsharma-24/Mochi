package com.mochi.keyboard.components

import androidx.compose.foundation.Canvas
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.geometry.Size
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.Outline
import androidx.compose.ui.graphics.Path
import androidx.compose.ui.graphics.Shape
import androidx.compose.ui.graphics.drawscope.Fill
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.unit.Density
import androidx.compose.ui.unit.LayoutDirection
import kotlin.math.cos
import kotlin.math.min
import kotlin.math.sin

/**
 * Ported from ios/MochiApp/Components/CreateGlyphs.swift — marks on the Create Custom Theme frame
 * (docs/figma/4.png) no Material icon comes close enough to.
 */

/** The twelve-wedge flat color wheel inside the BACKGROUND card's "Colors" chip — hard wedge
 * boundaries, not a continuous conic sweep. Read off figma/4.png wedge by wedge starting just
 * clockwise of twelve o'clock. */
@Composable
fun ColorWheelGlyph(modifier: Modifier = Modifier) {
    val wedges = remember12Wedges()
    Canvas(modifier = modifier) {
        val r = min(size.width, size.height) / 2
        val c = Offset(size.width / 2, size.height / 2)
        wedges.forEachIndexed { index, color ->
            val path = Path().apply {
                moveTo(c.x, c.y)
                arcTo(
                    rect = androidx.compose.ui.geometry.Rect(c.x - r, c.y - r, c.x + r, c.y + r),
                    startAngleDegrees = index * 30f - 90f,
                    sweepAngleDegrees = 30f,
                    forceMoveTo = false
                )
                close()
            }
            drawPath(path, color, style = Fill)
        }
    }
}

private fun remember12Wedges(): List<Color> = listOf(
    Color(0xFFFAD917), Color(0xFFF7A81C), Color(0xFFF2731F),
    Color(0xFFE6382E), Color(0xFFD32B4C), Color(0xFFA83377),
    Color(0xFF783D99), Color(0xFF384FA6), Color(0xFF22788C),
    Color(0xFF249461), Color(0xFF4CAD40), Color(0xFF94C233)
)

/** SwiftUI has no hexagon primitive; SF's `hexagon` is rounded/point-up — this is flat-topped with
 * sharp vertices, points on the horizontal axis. Used as a clip/background Shape. */
class HexagonShape : Shape {
    override fun createOutline(size: Size, layoutDirection: LayoutDirection, density: Density): Outline {
        val w = size.width
        val h = size.height
        val path = Path().apply {
            moveTo(w * 0.25f, 0f)
            lineTo(w * 0.75f, 0f)
            lineTo(w, h / 2f)
            lineTo(w * 0.75f, h)
            lineTo(w * 0.25f, h)
            lineTo(0f, h / 2f)
            close()
        }
        return Outline.Generic(path)
    }
}

/** The Save Draft button's mark: a stroked classic floppy disc — clipped top-left corner, shutter
 * across the top, label panel below. SF's `square.and.arrow.down` reads as an entirely different
 * object at this size. */
@Composable
fun FloppyGlyph(modifier: Modifier = Modifier, color: Color = Color.Black, strokeWidth: Float = 1.5f) {
    Canvas(modifier = modifier) {
        val w = size.width
        val h = size.height
        val corner = w * 0.22f
        val body = Path().apply {
            moveTo(corner, 0f)
            lineTo(w, 0f)
            lineTo(w, h)
            lineTo(0f, h)
            lineTo(0f, corner)
            close()
        }
        val stroke = Stroke(strokeWidth)
        drawPath(body, color, style = stroke)
        drawRect(color, topLeft = Offset(w * 0.26f, h * 0.10f), size = Size(w * 0.48f, h * 0.28f), style = stroke)
        drawRect(color, topLeft = Offset(w * 0.20f, h * 0.52f), size = Size(w * 0.60f, h * 0.48f), style = stroke)
    }
}

/** The "Keys" tab mark: a solid rounded keycap with a four-point sparkle punched out of it. */
@Composable
fun KeycapGlyph(modifier: Modifier = Modifier, fillColor: Color = Color(0xFF9C28B1), sparkleColor: Color = Color.White) {
    Canvas(modifier = modifier) {
        val w = size.width
        val h = size.height
        drawRoundRect(
            color = fillColor,
            size = size,
            cornerRadius = androidx.compose.ui.geometry.CornerRadius(h * 0.28f, h * 0.28f)
        )
        val sparkleSize = w * 0.42f
        val sparkleTopLeft = Offset((w - sparkleSize) / 2, (h - sparkleSize) / 2)
        drawSparkle(sparkleColor, sparkleTopLeft, sparkleSize)
    }
}

private fun androidx.compose.ui.graphics.drawscope.DrawScope.drawSparkle(color: Color, topLeft: Offset, s: Float) {
    val c = Offset(topLeft.x + s / 2, topLeft.y + s / 2)
    val r = s / 2
    val waist = r * 0.24f
    val path = Path().apply {
        moveTo(c.x, c.y - r)
        quadraticTo(c.x + waist, c.y - waist, c.x + r, c.y)
        quadraticTo(c.x + waist, c.y + waist, c.x, c.y + r)
        quadraticTo(c.x - waist, c.y + waist, c.x - r, c.y)
        quadraticTo(c.x - waist, c.y - waist, c.x, c.y - r)
        close()
    }
    drawPath(path, color, style = Fill)
}
