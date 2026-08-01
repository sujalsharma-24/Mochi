package com.mochi.keyboard.ime

import android.content.res.ColorStateList
import android.graphics.drawable.GradientDrawable
import android.graphics.drawable.StateListDrawable
import android.inputmethodservice.InputMethodService
import android.util.TypedValue
import android.view.Gravity
import android.view.KeyEvent
import android.view.MotionEvent
import android.view.View
import android.view.ViewGroup
import android.widget.FrameLayout
import android.widget.ImageView
import android.widget.LinearLayout
import android.widget.TextView
import com.mochi.keyboard.R

/**
 * Every visual surface here - key fills, text color, borders, shadows, the shift/backspace/enter
 * icons, the suggestion bar, and the key-press popup - reads from [theme] instead of hardcoding a
 * look, so swapping [MochiThemes.fantasyCastleNight] for a different [KeyboardVisualTheme] re-skins
 * the whole keyboard. Still no dictionary/autocorrect - the suggestion bar is a themed placeholder,
 * not a real predictive-text engine, and there's still only one hardcoded layout/theme (no
 * Firestore-backed switching yet).
 */
class MochiInputMethodService : InputMethodService() {

    private val theme = MochiThemes.fantasyCastleNight
    private lateinit var popup: KeyPopupWindow
    private val letterKeys = mutableListOf<TextView>()
    private lateinit var shiftKeyView: ImageView
    private var isShifted = false

    private fun dp(value: Float): Float =
        TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, value, resources.displayMetrics)

    private fun dpInt(value: Float): Int = dp(value).toInt()

    override fun onCreateInputView(): View {
        popup = KeyPopupWindow(this, theme)
        letterKeys.clear()
        isShifted = false

        val root = FrameLayout(this)

        val background = ImageView(this).apply {
            setImageResource(theme.backgroundImageRes)
            scaleType = ImageView.ScaleType.CENTER_CROP
        }
        root.addView(
            background,
            FrameLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT)
        )

        val column = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            setPadding(dpInt(6f), dpInt(10f), dpInt(6f), dpInt(10f))
        }
        column.addView(suggestionBar())
        column.addView(letterRow("qwertyuiop"))
        column.addView(letterRow("asdfghjkl"))
        column.addView(middleRow())
        column.addView(bottomRow())

        root.addView(
            column,
            FrameLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT).apply {
                gravity = Gravity.BOTTOM
            }
        )

        return root
    }

    // --- Themed drawables -------------------------------------------------

    /** Fresh instance per key - sharing one Drawable across views would make them all repaint
     * together on press, since a Drawable's state belongs to the Drawable, not the View holding it. */
    private fun keyBackground(isSpecial: Boolean): StateListDrawable {
        fun rounded(fillColor: Int) = GradientDrawable().apply {
            shape = GradientDrawable.RECTANGLE
            cornerRadius = dp(theme.keyCornerRadiusDp)
            setColor(fillColor)
            setStroke(dpInt(theme.keyBorderWidthDp), theme.keyBorderColor)
        }
        val normalColor = if (isSpecial) theme.specialKeyFillColor else theme.keyFillColor
        val pressedColor = if (isSpecial) theme.specialKeyPressedFillColor else theme.keyPressedFillColor
        return StateListDrawable().apply {
            addState(intArrayOf(android.R.attr.state_pressed), rounded(pressedColor))
            addState(intArrayOf(), rounded(normalColor))
        }
    }

    // --- Rows ---------------------------------------------------------

    private fun suggestionBar(): View =
        LinearLayout(this).apply {
            orientation = LinearLayout.HORIZONTAL
            setBackgroundColor(theme.suggestionBarColor)
            setPadding(dpInt(12f), dpInt(8f), dpInt(12f), dpInt(8f))
            listOf("Mochi", "🌙", "Hello").forEach { placeholder ->
                addView(TextView(this@MochiInputMethodService).apply {
                    text = placeholder
                    setTextColor(theme.suggestionTextColor)
                    gravity = Gravity.CENTER
                    layoutParams = LinearLayout.LayoutParams(0, ViewGroup.LayoutParams.WRAP_CONTENT, 1f)
                })
            }
        }

    private fun letterRow(letters: String): LinearLayout =
        LinearLayout(this).apply {
            orientation = LinearLayout.HORIZONTAL
            letters.forEach { addView(letterKey(it)) }
        }

    private fun middleRow(): LinearLayout =
        LinearLayout(this).apply {
            orientation = LinearLayout.HORIZONTAL
            shiftKeyView = iconKey(R.drawable.ic_key_shift, weight = 1.5f, onRelease = { toggleShift() })
            addView(shiftKeyView)
            "zxcvbnm".forEach { addView(letterKey(it)) }
            addView(iconKey(R.drawable.ic_key_backspace, weight = 1.5f, onRelease = {
                currentInputConnection?.deleteSurroundingText(1, 0)
            }))
        }

    private fun bottomRow(): LinearLayout =
        LinearLayout(this).apply {
            orientation = LinearLayout.HORIZONTAL
            addView(specialTextKey("space", weight = 5f, onRelease = {
                currentInputConnection?.commitText(" ", 1)
            }))
            addView(iconKey(R.drawable.ic_key_enter, weight = 1.8f, onRelease = {
                sendDownUpKeyEvents(KeyEvent.KEYCODE_ENTER)
            }))
        }

    // --- Key builders ---------------------------------------------------

    private fun letterKey(letter: Char): TextView =
        TextView(this).apply {
            text = displayChar(letter)
            textSize = 18f
            gravity = Gravity.CENTER
            setTextColor(theme.keyTextColor)
            isClickable = true
            isFocusable = true
            background = keyBackground(isSpecial = false)
            elevation = dp(theme.keyElevationDp)
            layoutParams = keyLayoutParams(1f)
            setKeyTouchHandler(
                onDown = { popup.show(this, text.toString()) },
                onRelease = {
                    currentInputConnection?.commitText(text.toString(), 1)
                    // Gboard-style "shift once": a shifted letter auto-reverts after it's typed.
                    if (isShifted) toggleShift()
                }
            )
            letterKeys.add(this)
        }

    private fun specialTextKey(label: String, weight: Float, onRelease: () -> Unit): TextView =
        TextView(this).apply {
            text = label
            textSize = 16f
            gravity = Gravity.CENTER
            setTextColor(theme.keyTextColor)
            isClickable = true
            background = keyBackground(isSpecial = true)
            elevation = dp(theme.keyElevationDp)
            layoutParams = keyLayoutParams(weight)
            setKeyTouchHandler(onRelease = onRelease)
        }

    private fun iconKey(iconRes: Int, weight: Float, onRelease: () -> Unit): ImageView =
        ImageView(this).apply {
            setImageResource(iconRes)
            scaleType = ImageView.ScaleType.CENTER_INSIDE
            val pad = dpInt(14f)
            setPadding(pad, pad, pad, pad)
            imageTintList = ColorStateList.valueOf(theme.specialKeyIconTint)
            isClickable = true
            background = keyBackground(isSpecial = true)
            elevation = dp(theme.keyElevationDp)
            layoutParams = keyLayoutParams(weight)
            setKeyTouchHandler(onRelease = onRelease)
        }

    private fun keyLayoutParams(weight: Float): LinearLayout.LayoutParams =
        LinearLayout.LayoutParams(0, dpInt(KEY_HEIGHT_DP), weight).apply {
            val margin = dpInt(3f)
            setMargins(margin, margin, margin, margin)
        }

    /** Centralizes press-state + popup + release-inside-bounds handling so every key type (letter,
     * icon, space) gets the same pressed-color feedback and "drag off the key cancels it" behavior. */
    private fun View.setKeyTouchHandler(onDown: () -> Unit = {}, onRelease: () -> Unit) {
        setOnTouchListener { view, event ->
            when (event.actionMasked) {
                MotionEvent.ACTION_DOWN -> {
                    view.isPressed = true
                    onDown()
                }
                MotionEvent.ACTION_UP -> {
                    view.isPressed = false
                    popup.dismiss()
                    if (isInsideView(view, event)) onRelease()
                }
                MotionEvent.ACTION_CANCEL -> {
                    view.isPressed = false
                    popup.dismiss()
                }
            }
            true
        }
    }

    private fun isInsideView(view: View, event: MotionEvent): Boolean =
        event.x >= 0 && event.x <= view.width && event.y >= 0 && event.y <= view.height

    private fun displayChar(letter: Char): String =
        if (isShifted) letter.uppercaseChar().toString() else letter.toString()

    private fun toggleShift() {
        isShifted = !isShifted
        letterKeys.forEach { it.text = displayChar(it.text.first().lowercaseChar()) }
        shiftKeyView.imageTintList = ColorStateList.valueOf(
            if (isShifted) theme.specialKeyPressedFillColor else theme.specialKeyIconTint
        )
    }

    private companion object {
        const val KEY_HEIGHT_DP = 46f
    }
}
