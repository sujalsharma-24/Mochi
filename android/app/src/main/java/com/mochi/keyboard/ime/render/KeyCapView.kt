package com.mochi.keyboard.ime.render

import android.content.Context
import android.graphics.Bitmap
import android.graphics.BlurMaskFilter
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.LinearGradient
import android.graphics.Paint
import android.graphics.Path
import android.graphics.PorterDuff
import android.graphics.PorterDuffXfermode
import android.graphics.RectF
import android.graphics.Shader
import android.util.TypedValue
import android.view.MotionEvent
import android.view.View
import android.widget.ImageView
import androidx.annotation.DrawableRes
import kotlin.math.cos
import kotlin.math.min
import kotlin.math.sin

/**
 * One themed key cap — ported from iOS's `KeyView`. Unlike the iOS version this does not need to
 * animate fill via `CALayer` properties for performance; Android's IME has no comparable memory/CPU
 * ceiling (`docs/IOS_CURRENT_STATE.md` §9), so a plain `Canvas.onDraw()` redraw on every press-state
 * change is simple and fast enough for a ~30-key grid.
 */
class KeyCapView(context: Context, val definition: KeyDefinition) : View(context) {

    var style: KeyStyle private set
    var metrics: KeyboardMetrics private set
    var typography: ThemeTypography private set
    private var artSet: KeyArtSet? = null
    private var artStore: KeyArtStore? = null

    /** Set true externally while shift is engaged, so the shift key can render its active style. */
    var shiftActive: Boolean = false
        set(value) { if (field != value) { field = value; invalidate() } }

    private var labelText: String? = definition.label
    @DrawableRes private var iconRes: Int? = definition.iconRes

    private val outline = RectF()
    private val path = Path()
    private val shadowPaint = Paint(Paint.ANTI_ALIAS_FLAG)
    private val fillPaint = Paint(Paint.ANTI_ALIAS_FLAG)
    private val borderPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply { this.style = Paint.Style.STROKE }
    private val glossPaint = Paint(Paint.ANTI_ALIAS_FLAG)
    private val bevelPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply { this.style = Paint.Style.STROKE }
    private val innerShadowPaint = Paint(Paint.ANTI_ALIAS_FLAG)
    private val artPaint = Paint(Paint.ANTI_ALIAS_FLAG or Paint.FILTER_BITMAP_FLAG)
    private val artOverlayPaint = Paint(Paint.ANTI_ALIAS_FLAG)
    private val textPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply { textAlign = Paint.Align.CENTER }

    private var iconDrawable: android.graphics.drawable.Drawable? = null

    constructor(
        context: Context,
        definition: KeyDefinition,
        style: KeyStyle,
        metrics: KeyboardMetrics,
        typography: ThemeTypography,
        artSet: KeyArtSet?,
        artStore: KeyArtStore?
    ) : this(context, definition) {
        this.style = style
        this.metrics = metrics
        this.typography = typography
        this.artSet = artSet
        this.artStore = artStore
        applyStyleInternal()
    }

    init {
        // Placeholder assignment satisfied by the secondary constructor in practice; kept
        // non-null for Kotlin's definite-assignment rules.
        style = MochiKeyboardTheme.lastResortStyle(ThemeAppearance.DARK)
        metrics = KeyboardMetrics(360f, false)
        typography = ThemeTypography()
        isClickable = true
        isFocusable = true
        if (needsShadowLayer()) setLayerType(LAYER_TYPE_SOFTWARE, null)
    }

    private fun dp(value: Float): Float =
        TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, value, resources.displayMetrics)

    fun apply(style: KeyStyle, metrics: KeyboardMetrics, typography: ThemeTypography, artSet: KeyArtSet?, artStore: KeyArtStore?) {
        this.style = style
        this.metrics = metrics
        this.typography = typography
        this.artSet = artSet
        this.artStore = artStore
        applyStyleInternal()
    }

    private fun needsShadowLayer(): Boolean = true

    private fun applyStyleInternal() {
        setLayerType(LAYER_TYPE_SOFTWARE, null)

        iconRes?.let {
            iconDrawable = androidx.core.content.ContextCompat.getDrawable(context, it)?.mutate()
        }

        val pointSizeSp = if (iconRes != null || isWordLabel()) metrics.systemLabelSizeSp
        else metrics.inputLabelSizeSp * typography.sizeMultiplier.toFloat()
        textPaint.textSize = TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_SP, pointSizeSp, resources.displayMetrics)
        // Android's Typeface has no continuous weight axis like iOS's UIFont.Weight; 0.3 is
        // roughly "semibold and up" in the raw-value scale these themes are authored against.
        textPaint.typeface = if (typography.weightRawValue >= 0.3) android.graphics.Typeface.DEFAULT_BOLD else android.graphics.Typeface.DEFAULT

        invalidate()
    }

    private fun isWordLabel(): Boolean = (labelText?.length ?: 0) > 1

    fun setLabelText(text: String) {
        if (iconRes != null) return
        labelText = text
        invalidate()
    }

    /** Swaps the icon glyph without rebuilding the view — used for shift -> caps lock. */
    fun setIconRes(@DrawableRes res: Int) {
        if (iconRes == res) return
        iconRes = res
        iconDrawable = androidx.core.content.ContextCompat.getDrawable(context, res)?.mutate()
        invalidate()
    }

    override fun onSizeChanged(w: Int, h: Int, oldw: Int, oldh: Int) {
        super.onSizeChanged(w, h, oldw, oldh)
        rebuildOutline()
    }

    private fun rebuildOutline() {
        val radius = (style.cornerRadiusOverrideDp?.toFloat() ?: metrics.keyCornerRadiusDp).let { dp(it) }
        val shadowPad = dp((style.shadow.radius + kotlin.math.abs(style.shadow.offsetY)).toFloat()) + 4f
        outline.set(shadowPad, shadowPad, width - shadowPad, height - shadowPad)
        path.reset()
        when (style.capShape) {
            KeyCapShape.ROUNDED_RECT -> path.addRoundRect(outline, radius, radius, Path.Direction.CW)
            KeyCapShape.HEXAGON -> buildHexagon(path, outline)
        }
    }

    private fun buildHexagon(path: Path, rect: RectF) {
        val w = rect.width()
        path.moveTo(rect.left + w * 0.25f, rect.top)
        path.lineTo(rect.left + w * 0.75f, rect.top)
        path.lineTo(rect.right, rect.centerY())
        path.lineTo(rect.left + w * 0.75f, rect.bottom)
        path.lineTo(rect.left + w * 0.25f, rect.bottom)
        path.lineTo(rect.left, rect.centerY())
        path.close()
    }

    override fun onTouchEvent(event: MotionEvent): Boolean {
        // Press/release visuals only — MochiInputMethodService installs its own touch handler for
        // the actual key action, tap-target slop, and repeat behaviour.
        return super.onTouchEvent(event)
    }

    override fun setPressed(pressed: Boolean) {
        val changed = isPressed != pressed
        super.setPressed(pressed)
        if (changed) invalidate()
    }

    override fun onDraw(canvas: Canvas) {
        if (outline.isEmpty) rebuildOutline()
        val radius = (style.cornerRadiusOverrideDp?.toFloat() ?: metrics.keyCornerRadiusDp).let { dp(it) }
        val showsPressed = isPressed || shiftActive
        val fill = if (showsPressed) style.resolvedPressedFill else style.fill
        val ink = if (showsPressed) style.resolvedPressedLabelColor else style.labelColor

        drawShadow(canvas)

        canvas.save()
        canvas.clipPath(path)

        drawFill(canvas, fill)
        drawArt(canvas)
        drawGlass(canvas, radius)
        drawGloss(canvas)

        canvas.restore()

        drawBorder(canvas)
        drawLabel(canvas, ink)
    }

    private fun drawShadow(canvas: Canvas) {
        val shadow = style.shadow
        if (shadow.opacity <= 0.0 || shadow.radius <= 0.0) return
        shadowPaint.color = shadow.color.toArgb()
        shadowPaint.alpha = (shadow.opacity * 255).toInt()
        shadowPaint.maskFilter = BlurMaskFilter(dp(shadow.radius.toFloat()).coerceAtLeast(1f), BlurMaskFilter.Blur.NORMAL)
        val radius = (style.cornerRadiusOverrideDp?.toFloat() ?: metrics.keyCornerRadiusDp).let { dp(it) }
        val shadowRect = RectF(outline)
        shadowRect.offset(0f, dp(shadow.offsetY.toFloat()))
        val shadowPath = Path()
        when (style.capShape) {
            KeyCapShape.ROUNDED_RECT -> shadowPath.addRoundRect(shadowRect, radius, radius, Path.Direction.CW)
            KeyCapShape.HEXAGON -> buildHexagon(shadowPath, shadowRect)
        }
        canvas.drawPath(shadowPath, shadowPaint)
    }

    private fun drawFill(canvas: Canvas, fill: ThemeFill) {
        val colors = if (fill.stops.size == 1) intArrayOf(fill.stops[0].toArgb(), fill.stops[0].toArgb())
        else fill.stops.map { it.toArgb() }.toIntArray()
        val radians = Math.toRadians(fill.angleDegrees)
        val dx = (cos(radians) / 2).toFloat()
        val dy = (sin(radians) / 2).toFloat()
        val cx = outline.centerX(); val cy = outline.centerY()
        // dx/dy are fractions of the full width/height (max magnitude 0.5, at angle 0/90), not of
        // the half-width — cos(0)/2 = 0.5 must span the cap's *entire* width edge-to-edge.
        val w = outline.width(); val h = outline.height()
        fillPaint.shader = LinearGradient(
            cx - dx * w, cy - dy * h, cx + dx * w, cy + dy * h,
            colors, null, Shader.TileMode.CLAMP
        )
        canvas.drawRect(outline, fillPaint)
    }

    private fun drawArt(canvas: Canvas) {
        val artSet = artSet ?: return
        val store = artStore ?: return
        val identity = definition.artIdentity ?: return
        val bitmap = store.bitmapFor(artSet.assetName(identity)) ?: return

        val fills = artSet.fillKeys.contains(identity)
        val band = RectF(
            if (fills) outline else RectF(
                outline.left,
                outline.bottom - outline.height() * (artSet.heightFraction + artSet.bottomInsetFraction).toFloat(),
                outline.right,
                outline.bottom - outline.height() * artSet.bottomInsetFraction.toFloat()
            )
        )
        val placement = artSet.placement(identity)
        val placed = placeArt(band, outline, placement)

        val opacity = artSet.resolvedOpacity(identity)
        val alpha = (opacity * 255).toInt().coerceIn(0, 255)

        val srcAspect = bitmap.width.toFloat() / bitmap.height.toFloat()
        val dstAspect = placed.width() / placed.height()
        // Aspect-fill: crop the bitmap so the illustration spans the whole band width/height and
        // bleeds off the edges, matching the reference art's treatment. `drawBitmap` has no RectF-src
        // overload, so the crop is rounded to integer pixels.
        val src = android.graphics.Rect(0, 0, bitmap.width, bitmap.height)
        if (srcAspect > dstAspect) {
            val visibleWidth = bitmap.height * dstAspect
            val excess = ((bitmap.width - visibleWidth) / 2)
            src.set(excess.toInt(), 0, (bitmap.width - excess).toInt(), bitmap.height)
        } else {
            val visibleHeight = bitmap.width / dstAspect
            val excess = ((bitmap.height - visibleHeight) / 2)
            src.set(0, excess.toInt(), bitmap.width, (bitmap.height - excess).toInt())
        }

        artPaint.alpha = alpha
        canvas.save()
        canvas.clipRect(outline)
        canvas.drawBitmap(bitmap, src, placed, artPaint)
        canvas.restore()

        val brightness = artSet.resolvedBrightness(identity)
        if (brightness != 0.0) {
            val overlayAlpha = (min(1.0, kotlin.math.abs(brightness)) * alpha).toInt().coerceIn(0, 255)
            artOverlayPaint.color = if (brightness > 0) Color.WHITE else Color.BLACK
            artOverlayPaint.alpha = overlayAlpha
            artOverlayPaint.xfermode = PorterDuffXfermode(PorterDuff.Mode.SRC_ATOP)
            val layer = canvas.saveLayer(placed, null)
            canvas.drawBitmap(bitmap, src, placed, artPaint)
            canvas.drawRect(placed, artOverlayPaint)
            canvas.restoreToCount(layer)
            artOverlayPaint.xfermode = null
        }
    }

    private fun placeArt(base: RectF, capBounds: RectF, placement: KeyArtPlacement): RectF {
        val scaledW = base.width() * placement.scale.toFloat()
        val scaledH = base.height() * placement.scale.toFloat()
        val cx = base.centerX() + capBounds.width() * placement.offsetX.toFloat()
        val cy = base.centerY() + capBounds.height() * placement.offsetY.toFloat()
        return RectF(cx - scaledW / 2, cy - scaledH / 2, cx + scaledW / 2, cy + scaledH / 2)
    }

    private fun drawGlass(canvas: Canvas, radius: Float) {
        val glass = style.glass ?: return
        // Bevel: a bright hairline fading down from the top edge.
        if (glass.bevelWidth > 0) {
            bevelPaint.strokeWidth = dp(glass.bevelWidth.toFloat())
            bevelPaint.shader = LinearGradient(
                0f, outline.top, 0f, outline.top + outline.height() * glass.bevelFalloff.toFloat(),
                glass.bevelColor.toArgb(), glass.bevelColor.withAlpha(0.0).toArgb(), Shader.TileMode.CLAMP
            )
            val inset = dp(glass.bevelWidth.toFloat()) / 2
            val bevelRect = RectF(outline.left + inset, outline.top + inset, outline.right - inset, outline.bottom - inset)
            val bevelPath = Path()
            when (style.capShape) {
                KeyCapShape.ROUNDED_RECT -> bevelPath.addRoundRect(bevelRect, radius - inset, radius - inset, Path.Direction.CW)
                KeyCapShape.HEXAGON -> buildHexagon(bevelPath, bevelRect)
            }
            canvas.drawPath(bevelPath, bevelPaint)
        }
        // Inner shadow: a soft dark gradient rising from the bottom edge, standing in for iOS's
        // even-odd ring technique — visually equivalent depth cue, cheaper to draw on Android.
        if (glass.innerShadowOpacity > 0) {
            val h = dp(glass.innerShadowRadius.toFloat() * 2.2f).coerceAtMost(outline.height() / 2)
            innerShadowPaint.shader = LinearGradient(
                0f, outline.bottom, 0f, outline.bottom - h,
                glass.innerShadowColor.withAlpha(glass.innerShadowOpacity).toArgb(),
                glass.innerShadowColor.withAlpha(0.0).toArgb(),
                Shader.TileMode.CLAMP
            )
            canvas.drawRect(outline.left, outline.bottom - h, outline.right, outline.bottom, innerShadowPaint)
        }
    }

    private fun drawGloss(canvas: Canvas) {
        val highlight = style.topHighlight ?: return
        val glossHeight = outline.height() * 0.45f
        glossPaint.shader = LinearGradient(
            0f, outline.top, 0f, outline.top + glossHeight,
            highlight.toArgb(), highlight.withAlpha(0.0).toArgb(), Shader.TileMode.CLAMP
        )
        canvas.drawRect(outline.left, outline.top, outline.right, outline.top + glossHeight, glossPaint)
    }

    private fun drawBorder(canvas: Canvas) {
        val border = style.border ?: return
        if (border.width <= 0) return
        val radius = (style.cornerRadiusOverrideDp?.toFloat() ?: metrics.keyCornerRadiusDp).let { dp(it) }
        borderPaint.color = border.color.toArgb()
        borderPaint.strokeWidth = dp(border.width.toFloat())
        val inset = dp(border.width.toFloat()) / 2
        val borderRect = RectF(outline.left + inset, outline.top + inset, outline.right - inset, outline.bottom - inset)
        val borderPath = Path()
        when (style.capShape) {
            KeyCapShape.ROUNDED_RECT -> borderPath.addRoundRect(borderRect, radius - inset, radius - inset, Path.Direction.CW)
            KeyCapShape.HEXAGON -> buildHexagon(borderPath, borderRect)
        }
        canvas.drawPath(borderPath, borderPaint)
    }

    private fun drawLabel(canvas: Canvas, ink: ThemeColor) {
        val artLift = if (artSet != null && definition.artIdentity != null) outline.height() * (artSet?.labelLiftFraction ?: 0.0).toFloat() else 0f
        val cx = outline.centerX()
        val cy = outline.centerY() - artLift

        val icon = iconDrawable
        if (icon != null) {
            icon.setTint(ink.toArgb())
            val size = dp(metrics.systemLabelSizeSp) * 1.15f
            icon.setBounds((cx - size / 2).toInt(), (cy - size / 2).toInt(), (cx + size / 2).toInt(), (cy + size / 2).toInt())
            icon.draw(canvas)
        } else {
            val text = labelText ?: return
            textPaint.color = ink.toArgb()
            val metricsPaint = textPaint.fontMetrics
            val textY = cy - (metricsPaint.ascent + metricsPaint.descent) / 2
            textPaint.textSize.let {
                var size = it
                // Shrink to fit, mirroring iOS's adjustsFontSizeToFitWidth for long word labels
                // ("return") on a narrow cap.
                while (textPaint.measureText(text) > outline.width() * 0.92f && size > it * 0.7f) {
                    size -= 1f
                    textPaint.textSize = size
                }
            }
            canvas.drawText(text, cx, textY, textPaint)
        }
    }

    /** Expands the tappable area into half the surrounding gap, matching the system keyboard so a
     * thumb landing in the gutter still hits the intended key. */
    fun touchSlopDp(): Float = metrics.columnGapDp / 2
}
