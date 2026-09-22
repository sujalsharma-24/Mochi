package com.mochi.keyboard.ime

import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.ColorFilter
import android.graphics.Paint
import android.graphics.PixelFormat
import android.graphics.Rect
import android.graphics.drawable.Drawable

/**
 * A hand-rolled nine-slice stretch, used instead of Android's `.9.png` format because a manually
 * authored nine-patch (1px black border markers) silently failed to be recognized as stretchable
 * by the resource pipeline and rendered as a tiny unstretched sliver - this draws the same 3x3
 * corner/edge/center split directly with Canvas.drawBitmap, so behavior doesn't depend on aapt
 * correctly parsing a hand-edited PNG border.
 *
 * [insetLeft]/[insetTop]/[insetRight]/[insetBottom] mark, in the source bitmap's own pixels, how
 * far the stretchable middle region is from each edge - the corners outside that inset are drawn
 * at native size (so rounded corners/borders never distort), while edges and the center stretch to
 * fill whatever bounds the drawable is given.
 */
class NineSliceDrawable(
    private val bitmap: Bitmap,
    private val insetLeft: Int,
    private val insetTop: Int,
    private val insetRight: Int,
    private val insetBottom: Int
) : Drawable() {

    private val paint = Paint(Paint.ANTI_ALIAS_FLAG or Paint.FILTER_BITMAP_FLAG)
    private val srcRects = Array(9) { Rect() }
    private val dstRects = Array(9) { Rect() }

    override fun onBoundsChange(bounds: Rect) {
        super.onBoundsChange(bounds)
        val w = bitmap.width
        val h = bitmap.height
        val l = insetLeft
        val t = insetTop
        val r = w - insetRight
        val b = h - insetBottom

        val sx = intArrayOf(0, l, r, w)
        val sy = intArrayOf(0, t, b, h)
        // Corners keep their native pixel size in the destination too, so a wider/taller key only
        // stretches the middle band instead of scaling the border art out of proportion.
        val dx = intArrayOf(bounds.left, bounds.left + l, bounds.right - insetRight, bounds.right)
        val dy = intArrayOf(bounds.top, bounds.top + t, bounds.bottom - insetBottom, bounds.bottom)

        var i = 0
        for (row in 0..2) {
            for (col in 0..2) {
                srcRects[i].set(sx[col], sy[row], sx[col + 1], sy[row + 1])
                dstRects[i].set(dx[col], dy[row], dx[col + 1], dy[row + 1])
                i++
            }
        }
    }

    override fun draw(canvas: Canvas) {
        for (i in 0 until 9) {
            if (dstRects[i].width() > 0 && dstRects[i].height() > 0) {
                canvas.drawBitmap(bitmap, srcRects[i], dstRects[i], paint)
            }
        }
    }

    override fun setAlpha(alpha: Int) {
        paint.alpha = alpha
    }

    override fun setColorFilter(colorFilter: ColorFilter?) {
        paint.colorFilter = colorFilter
    }

    @Deprecated("Deprecated in Java", ReplaceWith("PixelFormat.TRANSLUCENT"))
    override fun getOpacity(): Int = PixelFormat.TRANSLUCENT
}
