package com.mochi.keyboard.ime.render

import android.content.Context
import android.graphics.Canvas
import android.graphics.LinearGradient
import android.graphics.Matrix
import android.graphics.Paint
import android.graphics.Shader
import android.os.Handler
import android.os.Looper
import android.util.TypedValue
import android.view.Gravity
import android.view.MotionEvent
import android.view.View
import android.view.ViewGroup
import android.widget.FrameLayout
import android.widget.ImageView
import android.widget.LinearLayout
import android.widget.PopupWindow
import android.widget.TextView

/**
 * The themed keyboard surface: background art, scrim, and the key grid — ported from iOS's
 * `KeyboardSurfaceView`. This one view renders both the live keyboard and (in a future slice) an
 * in-app preview, so the theme a user previews is the theme they get.
 *
 * Not built yet, tracked as follow-up slices rather than skipped silently: the emoji plane, a real
 * predictive-suggestion engine (iOS uses `UITextChecker`; Android's equivalent is a
 * `SpellCheckerSession`), and a drag-to-select long-press accent callout (this slice offers accents
 * as a tap list instead).
 */
class KeyboardSurfaceView(
    context: Context,
    theme: MochiKeyboardTheme,
    private var includesNextKeyboardKey: Boolean
) : FrameLayout(context) {

    var onAction: ((KeyAction) -> Unit)? = null
    var onInsertText: ((String) -> Unit)? = null

    var theme: MochiKeyboardTheme = theme
        private set
    var plane: KeyboardPlane = KeyboardPlane.LETTERS
        private set

    var shiftState: ShiftState = ShiftState.OFF
        set(value) {
            if (field != value) { field = value; updateShiftPresentation() }
        }

    /** Whether to reserve a strip above the keys for completions. Hidden on the emoji plane, same
     * as iOS — there's no text to complete there. Deliberately drawn with no backdrop of its own
     * (see [buildSuggestionBar]) so the background art and scrim read straight through it, matching
     * iOS's keyboard where the suggestion strip is part of the same continuous surface, not a
     * separate opaque bar. */
    var showsSuggestionBar: Boolean = true
        set(value) {
            if (field != value) { field = value; requestLayout() }
        }

    private val artStore = KeyArtStore(context)
    private val backgroundView = ImageView(context)
    private val scrimView = ScrimView(context)
    private val suggestionBar = buildSuggestionBar(context)
    private val keyContainer = FrameLayout(context)
    private var keyViews = mutableListOf<KeyCapView>()
    private var metrics = KeyboardMetrics(360f, false)

    private val handler = Handler(Looper.getMainLooper())
    private var repeatRunnable: Runnable? = null
    private var repeatTicks = 0
    private var calloutPopup: PopupWindow? = null

    private fun dp(value: Float): Float =
        TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, value, resources.displayMetrics)

    /** A row of completion labels with no backdrop of its own — see [showsSuggestionBar]'s doc for
     * why. Static placeholder content until a real completions engine exists (follow-up slice). */
    private fun buildSuggestionBar(context: Context): LinearLayout =
        LinearLayout(context).apply {
            orientation = LinearLayout.HORIZONTAL
            val padPx = TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, 10f, resources.displayMetrics).toInt()
            setPadding(padPx, 0, padPx, 0)
            listOf("Mochi", "🌙", "Hello").forEach { word ->
                addView(TextView(context).apply {
                    text = word
                    gravity = Gravity.CENTER
                    layoutParams = LinearLayout.LayoutParams(0, ViewGroup.LayoutParams.MATCH_PARENT, 1f)
                })
            }
        }

    init {
        addView(backgroundView, LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.MATCH_PARENT))
        backgroundView.scaleType = ImageView.ScaleType.MATRIX
        addView(scrimView, LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.MATCH_PARENT))
        // Suggestion bar and keys both sit above the scrim, on the same continuous background —
        // neither paints its own backdrop, so the art reads through both exactly as it does on iOS.
        addView(suggestionBar, LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.WRAP_CONTENT, Gravity.TOP))
        addView(keyContainer, LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.MATCH_PARENT))
        applyTheme(theme)
    }

    fun applyTheme(newTheme: MochiKeyboardTheme) {
        theme = newTheme
        artStore.releaseAll()

        val bg = newTheme.surface.backgroundImage
        if (bg != null) {
            val resId = artStore.resIdFor(bg.bundledName)
            if (resId != 0) {
                backgroundView.setImageResource(resId)
                backgroundView.visibility = View.VISIBLE
            } else {
                backgroundView.visibility = View.GONE
            }
        } else {
            backgroundView.visibility = View.GONE
        }
        backgroundView.setBackgroundColor(newTheme.surface.baseFill.contrastRepresentative.toArgb())

        scrimView.scrim = newTheme.surface.scrim
        scrimView.invalidate()

        applySuggestionBarChrome(newTheme.chrome)

        rebuildKeys()
        requestLayout()
    }

    private fun applySuggestionBarChrome(chrome: ThemeChrome) {
        for (i in 0 until suggestionBar.childCount) {
            (suggestionBar.getChildAt(i) as? TextView)?.setTextColor(chrome.inkColor.toArgb())
        }
    }

    fun setPlane(newPlane: KeyboardPlane) {
        if (newPlane == plane) return
        plane = newPlane
        shiftState = ShiftState.OFF
        dismissCallout()
        rebuildKeys()
        requestLayout()
    }

    fun preferredHeightDp(widthDp: Float, isLandscape: Boolean, showsSuggestionBar: Boolean): Float {
        val candidate = KeyboardMetrics(widthDp, isLandscape)
        val layout = KeyboardLayout.layout(plane, includesNextKeyboardKey, candidate)
        return candidate.totalHeightDp(layout.rows.size, showsSuggestionBar)
    }

    /** Whether the bar is actually shown right now — hidden on the emoji plane, same as iOS,
     * since there's no text to complete there. */
    private val showsBarNow: Boolean get() = showsSuggestionBar && plane != KeyboardPlane.EMOJI

    private fun rebuildKeys() {
        keyContainer.removeAllViews()
        keyViews = mutableListOf()

        suggestionBar.visibility = if (showsBarNow) View.VISIBLE else View.GONE
        val barHeightDp = if (showsBarNow) metrics.suggestionBarHeightDp else 0f
        (suggestionBar.layoutParams as? LayoutParams)?.height = dp(barHeightDp).toInt()
        (keyContainer.layoutParams as? LayoutParams)?.topMargin = dp(barHeightDp).toInt()

        val layout = KeyboardLayout.layout(plane, includesNextKeyboardKey, metrics)
        val solved = KeyboardLayoutSolver.solve(layout, metrics, metrics.availableWidthDp)

        for (solvedKey in solved) {
            val keyView = KeyCapView(
                context, solvedKey.definition, theme.style(solvedKey.definition.role),
                metrics, theme.typography, theme.keyArt, artStore
            )
            keyContainer.addView(keyView, layoutParamsFor(solvedKey))
            installTouchHandling(keyView, solvedKey.definition)
            keyViews.add(keyView)
        }
        updateShiftPresentation()
    }

    private fun layoutParamsFor(solved: SolvedKey): FrameLayout.LayoutParams {
        val slopDp = metrics.columnGapDp / 2
        val params = FrameLayout.LayoutParams(dp(solved.widthDp + slopDp * 2).toInt(), dp(solved.heightDp + metrics.rowGapDp).toInt())
        params.leftMargin = dp(solved.leftDp - slopDp).toInt()
        params.topMargin = dp(solved.topDp - metrics.rowGapDp / 2).toInt()
        return params
    }

    private fun installTouchHandling(keyView: KeyCapView, definition: KeyDefinition) {
        keyView.setOnTouchListener { view, event ->
            when (event.actionMasked) {
                MotionEvent.ACTION_DOWN -> {
                    view.isPressed = true
                    performHapticOnDown?.invoke()
                    if (definition.alternates.isNotEmpty()) {
                        longPressRunnable = Runnable { presentCallout(keyView, definition) }
                        handler.postDelayed(longPressRunnable!!, 450)
                    }
                    if (definition.repeatsWhenHeld) {
                        onAction?.invoke(definition.action)
                        startRepeating(definition)
                    }
                    true
                }
                MotionEvent.ACTION_MOVE -> {
                    if (!isInsideSlop(view, event)) {
                        view.isPressed = false
                        cancelPendingLongPress()
                        stopRepeating()
                    }
                    true
                }
                MotionEvent.ACTION_UP -> {
                    view.isPressed = false
                    cancelPendingLongPress()
                    val hadCallout = calloutPopup != null
                    dismissCallout()
                    stopRepeating()
                    if (!definition.repeatsWhenHeld && !hadCallout && isInsideSlop(view, event)) {
                        onAction?.invoke(definition.action)
                    }
                    true
                }
                MotionEvent.ACTION_CANCEL -> {
                    view.isPressed = false
                    cancelPendingLongPress()
                    dismissCallout()
                    stopRepeating()
                    true
                }
                else -> false
            }
        }
    }

    var performHapticOnDown: (() -> Unit)? = null

    private fun isInsideSlop(view: View, event: MotionEvent): Boolean {
        val slop = dp((view as KeyCapView).touchSlopDp())
        return event.x >= -slop && event.x <= view.width + slop && event.y >= -slop && event.y <= view.height + slop
    }

    private var longPressRunnable: Runnable? = null
    private fun cancelPendingLongPress() {
        longPressRunnable?.let { handler.removeCallbacks(it) }
        longPressRunnable = null
    }

    // MARK: - Key repeat (backspace hold-to-delete, accelerating)

    private fun startRepeating(definition: KeyDefinition) {
        stopRepeating()
        repeatTicks = 0
        repeatRunnable = Runnable { repeatTick(definition, intervalMs = 90L) }
        handler.postDelayed(repeatRunnable!!, 450)
    }

    private fun repeatTick(definition: KeyDefinition, intervalMs: Long) {
        onAction?.invoke(definition.action)
        repeatTicks++
        val nextInterval = if (repeatTicks >= 11) 40L else intervalMs
        repeatRunnable = Runnable { repeatTick(definition, nextInterval) }
        handler.postDelayed(repeatRunnable!!, nextInterval)
    }

    private fun stopRepeating() {
        repeatRunnable?.let { handler.removeCallbacks(it) }
        repeatRunnable = null
        repeatTicks = 0
    }

    // MARK: - Long-press accent picker (tap list, not drag-to-select — see class doc)

    private fun presentCallout(keyView: KeyCapView, definition: KeyDefinition) {
        dismissCallout()
        val alternates = definition.alternates.let { if (shiftState.isUppercase) it.map { a -> a.uppercase() } else it }
        if (alternates.isEmpty()) return

        val row = LinearLayout(context).apply {
            orientation = LinearLayout.HORIZONTAL
            val pad = dp(6f).toInt()
            setPadding(pad, pad, pad, pad)
            background = android.graphics.drawable.GradientDrawable().apply {
                cornerRadius = dp(10f)
                setColor(theme.chrome.panelFill.contrastRepresentative.toArgb())
            }
            alternates.forEach { alt ->
                addView(TextView(context).apply {
                    text = alt
                    textSize = 20f
                    setTextColor(theme.chrome.inkColor.toArgb())
                    setPadding(dp(10f).toInt(), dp(6f).toInt(), dp(10f).toInt(), dp(6f).toInt())
                    setOnClickListener {
                        onInsertText?.invoke(alt)
                        dismissCallout()
                    }
                })
            }
        }
        val popup = PopupWindow(row, ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.WRAP_CONTENT).apply {
            isClippingEnabled = false
        }
        val location = IntArray(2)
        keyView.getLocationInWindow(location)
        popup.showAtLocation(keyView, Gravity.NO_GRAVITY, location[0], location[1] - dp(56f).toInt())
        calloutPopup = popup
    }

    private fun dismissCallout() {
        calloutPopup?.dismiss()
        calloutPopup = null
    }

    // MARK: - Shift presentation

    private fun updateShiftPresentation() {
        for (keyView in keyViews) {
            setLetterCaseUppercased(keyView, shiftState.isUppercase)
            if (keyView.definition.action == KeyAction.Shift) {
                keyView.shiftActive = shiftState.showsEngagedKey
                keyView.setIconRes(if (shiftState == ShiftState.LOCKED) com.mochi.keyboard.R.drawable.ic_key_capslock else com.mochi.keyboard.R.drawable.ic_key_shift)
            }
        }
    }

    private fun setLetterCaseUppercased(keyView: KeyCapView, uppercased: Boolean) {
        val action = keyView.definition.action
        if (action is KeyAction.Insert && action.text.length == 1 && action.text[0].isLetter()) {
            keyView.setLabelText(if (uppercased) action.text.uppercase() else action.text.lowercase())
        }
    }

    // MARK: - Layout

    override fun onMeasure(widthMeasureSpec: Int, heightMeasureSpec: Int) {
        val widthPx = MeasureSpec.getSize(widthMeasureSpec)
        val widthDp = widthPx / resources.displayMetrics.density
        val isLandscape = resources.configuration.orientation == android.content.res.Configuration.ORIENTATION_LANDSCAPE
        val newMetrics = KeyboardMetrics(widthDp, isLandscape)
        if (newMetrics != metrics) {
            metrics = newMetrics
            rebuildKeys()
        }
        val heightDp = metrics.totalHeightDp(KeyboardLayout.layout(plane, includesNextKeyboardKey, metrics).rows.size, showsBarNow)
        val heightPx = dp(heightDp).toInt()
        super.onMeasure(widthMeasureSpec, MeasureSpec.makeMeasureSpec(heightPx, MeasureSpec.EXACTLY))
    }

    override fun onLayout(changed: Boolean, left: Int, top: Int, right: Int, bottom: Int) {
        super.onLayout(changed, left, top, right, bottom)
        layoutBackground()
    }

    private fun layoutBackground() {
        val bg = theme.surface.backgroundImage ?: return
        val drawable = backgroundView.drawable ?: return
        val dw = drawable.intrinsicWidth.toFloat()
        val dh = drawable.intrinsicHeight.toFloat()
        if (dw <= 0 || dh <= 0 || width <= 0 || height <= 0) return

        val matrix = Matrix()
        if (bg.scalesToFill) {
            val scale = maxOf(width / dw, height / dh)
            val scaledW = dw * scale
            val scaledH = dh * scale
            val dx = (width - scaledW) / 2f
            val dy = -(scaledH - height) * bg.verticalAnchor.toFloat()
            matrix.setScale(scale, scale)
            matrix.postTranslate(dx, dy)
        } else {
            val scale = minOf(width / dw, height / dh)
            val dx = (width - dw * scale) / 2f
            val dy = (height - dh * scale) / 2f
            matrix.setScale(scale, scale)
            matrix.postTranslate(dx, dy)
        }
        backgroundView.imageMatrix = matrix
    }

    /** The themed vertical scrim between the background art and the keys. */
    private class ScrimView(context: Context) : View(context) {
        var scrim: ThemeScrim = ThemeScrim.NONE
        private val paint = Paint()

        override fun onDraw(canvas: Canvas) {
            if (width <= 0 || height <= 0) return
            paint.shader = LinearGradient(
                0f, 0f, 0f, height.toFloat(),
                scrim.topColor.toArgb(), scrim.bottomColor.toArgb(), Shader.TileMode.CLAMP
            )
            canvas.drawRect(0f, 0f, width.toFloat(), height.toFloat(), paint)
        }

        override fun onSizeChanged(w: Int, h: Int, oldw: Int, oldh: Int) {
            super.onSizeChanged(w, h, oldw, oldh)
            invalidate()
        }
    }
}
