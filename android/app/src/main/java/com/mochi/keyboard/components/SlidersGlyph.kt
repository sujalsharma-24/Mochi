package com.mochi.keyboard.components

import androidx.compose.foundation.Canvas
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.geometry.CornerRadius
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.geometry.Size
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.Path
import androidx.compose.ui.graphics.PathFillType
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.graphics.drawscope.Fill
import androidx.compose.ui.graphics.drawscope.DrawStyle
import kotlin.math.min

/**
 * Ported from ios/MochiApp/Components/SlidersGlyph.swift — marks no Material icon comes close
 * enough to, so they're drawn directly against the same unit-space proportions measured off
 * Figma. Fonts and Themes pages share these (docs/figma/5.png, docs/figma/8.png).
 */

/** Line-then-knob on top, knob-then-line below — the sort/filter row's trailing round button. */
@Composable
fun SlidersGlyph(modifier: Modifier = Modifier, color: Color = Color.Black, strokeWidth: Float = 2f) {
    val cap = androidx.compose.ui.graphics.StrokeCap.Round
    Canvas(modifier = modifier) {
        val r = min(size.height * 0.22f, size.width * 0.14f)
        val yTop = r
        val yBottom = size.height - r

        val topKnobX = size.width - r
        drawLine(color = color, start = Offset(0f, yTop), end = Offset(topKnobX - r, yTop), strokeWidth = strokeWidth, cap = cap)
        drawCircle(color = color, radius = r, center = Offset(topKnobX, yTop), style = Stroke(strokeWidth))

        val bottomKnobX = r * 2
        drawCircle(color = color, radius = r, center = Offset(bottomKnobX, yBottom), style = Stroke(strokeWidth))
        drawLine(color = color, start = Offset(bottomKnobX + r, yBottom), end = Offset(size.width, yBottom), strokeWidth = strokeWidth, cap = cap)
    }
}

/** Symmetric funnel: full-width top edge, two diagonals converging to a neck, short spout. */
@Composable
fun FunnelGlyph(modifier: Modifier = Modifier, color: Color = Color.Black, style: DrawStyle = Fill) {
    Canvas(modifier = modifier) {
        fun p(x: Float, y: Float) = Offset(size.width * x, size.height * y)
        val path = Path().apply {
            moveTo(p(0.00f, 0.00f).x, p(0.00f, 0.00f).y)
            lineTo(p(1.00f, 0.00f).x, p(1.00f, 0.00f).y)
            lineTo(p(0.60f, 0.55f).x, p(0.60f, 0.55f).y)
            lineTo(p(0.60f, 0.86f).x, p(0.60f, 0.86f).y)
            lineTo(p(0.42f, 1.00f).x, p(0.42f, 1.00f).y)
            lineTo(p(0.42f, 0.55f).x, p(0.42f, 0.55f).y)
            close()
        }
        drawPath(path, color, style = style)
    }
}

/** The disc mark on every theme tile: a down arrow dropping into an open-topped tray. */
@Composable
fun DownloadGlyph(modifier: Modifier = Modifier, color: Color = Color.Black, strokeWidth: Float = 2f) {
    Canvas(modifier = modifier) {
        fun p(x: Float, y: Float) = Offset(size.width * x, size.height * y)
        val stem = Path().apply {
            moveTo(p(0.48f, 0.00f).x, p(0.48f, 0.00f).y)
            lineTo(p(0.48f, 0.5625f).x, p(0.48f, 0.5625f).y)
        }
        val arrow = Path().apply {
            moveTo(p(0.16f, 0.375f).x, p(0.16f, 0.375f).y)
            lineTo(p(0.48f, 0.5625f).x, p(0.48f, 0.5625f).y)
            lineTo(p(0.81f, 0.375f).x, p(0.81f, 0.375f).y)
        }
        val corner = 0.14f
        val tray = Path().apply {
            moveTo(p(0.00f, 0.656f).x, p(0.00f, 0.656f).y)
            lineTo(p(0.00f, 1.0f - corner).x, p(0.00f, 1.0f - corner).y)
            quadraticTo(p(0.00f, 1.00f).x, p(0.00f, 1.00f).y, p(corner, 1.00f).x, p(corner, 1.00f).y)
            lineTo(p(1.0f - corner, 1.00f).x, p(1.0f - corner, 1.00f).y)
            quadraticTo(p(1.00f, 1.00f).x, p(1.00f, 1.00f).y, p(1.00f, 1.0f - corner).x, p(1.00f, 1.0f - corner).y)
            lineTo(p(1.00f, 0.656f).x, p(1.00f, 0.656f).y)
        }
        val stroke = Stroke(width = strokeWidth, cap = androidx.compose.ui.graphics.StrokeCap.Round, join = androidx.compose.ui.graphics.StrokeJoin.Round)
        drawPath(stem, color, style = stroke)
        drawPath(arrow, color, style = stroke)
        drawPath(tray, color, style = stroke)
    }
}

/** Outlined pencil at 45°, tip lower-left, divider near the cap, over a full-width rule. */
@Composable
fun PencilGlyph(modifier: Modifier = Modifier, color: Color = Color.Black, strokeWidth: Float = 1.5f, bodyHalfWidth: Float = 0.135f) {
    Canvas(modifier = modifier) {
        fun p(x: Float, y: Float) = Offset(size.width * x, size.height * y)
        val tip = Offset(0.10f, 0.76f)
        val cap = Offset(0.82f, 0.04f)
        val dx = cap.x - tip.x
        val dy = cap.y - tip.y
        val len = kotlin.math.sqrt(dx * dx + dy * dy)
        val ux = dx / len
        val uy = dy / len
        val hw = bodyHalfWidth
        val nx = -uy * hw
        val ny = ux * hw
        fun at(t: Float, side: Float) = p(tip.x + ux * len * t + nx * side, tip.y + uy * len * t + ny * side)

        val body = Path().apply {
            moveTo(p(tip.x, tip.y).x, p(tip.x, tip.y).y)
            lineTo(at(0.18f, 1f).x, at(0.18f, 1f).y)
            lineTo(at(0.94f, 1f).x, at(0.94f, 1f).y)
            quadraticTo(p(cap.x, cap.y).x, p(cap.x, cap.y).y, at(0.94f, -1f).x, at(0.94f, -1f).y)
            lineTo(at(0.18f, -1f).x, at(0.18f, -1f).y)
            close()
        }
        val divider = Path().apply {
            moveTo(at(0.68f, 1f).x, at(0.68f, 1f).y)
            lineTo(at(0.68f, -1f).x, at(0.68f, -1f).y)
        }
        val rule = Path().apply {
            moveTo(p(0.04f, 0.97f).x, p(0.04f, 0.97f).y)
            lineTo(p(0.96f, 0.97f).x, p(0.96f, 0.97f).y)
        }
        val stroke = Stroke(width = strokeWidth)
        drawPath(body, color, style = stroke)
        drawPath(divider, color, style = stroke)
        drawPath(rule, color, style = stroke)
    }
}

/** Three solid four-pointed stars beside "APPLY THIS FONT TO YOUR KEYBOARD" (figma/5.png). */
@Composable
fun SparkleCluster(modifier: Modifier = Modifier, color: Color = Color.White) {
    Canvas(modifier = modifier) {
        val s = min(size.width, size.height)
        fun star(c: Offset, r: Float, path: Path) {
            val waist = r * 0.24f
            path.moveTo(c.x, c.y - r)
            path.quadraticTo(c.x + waist, c.y - waist, c.x + r, c.y)
            path.quadraticTo(c.x + waist, c.y + waist, c.x, c.y + r)
            path.quadraticTo(c.x - waist, c.y + waist, c.x - r, c.y)
            path.quadraticTo(c.x - waist, c.y - waist, c.x, c.y - r)
            path.close()
        }
        val path = Path().apply { fillType = PathFillType.NonZero }
        star(Offset(s * 0.38f, s * 0.32f), s * 0.32f, path)
        star(Offset(s * 0.74f, s * 0.70f), s * 0.24f, path)
        star(Offset(s * 0.18f, s * 0.80f), s * 0.15f, path)
        drawPath(path, color, style = Fill)
    }
}

/** The three dots on the "Other" pill — chunkier than Material's ellipsis at this size. */
@Composable
fun TripleDot(modifier: Modifier = Modifier, color: Color = Color.Black) {
    Canvas(modifier = modifier) {
        val d = size.height
        val step = (size.width - d) / 2
        for (i in 0..2) {
            drawCircle(color, radius = d / 2, center = Offset(step * i + d / 2, d / 2))
        }
    }
}
