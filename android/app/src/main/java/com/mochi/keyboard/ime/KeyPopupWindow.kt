package com.mochi.keyboard.ime

import android.content.Context
import android.graphics.drawable.GradientDrawable
import android.util.TypedValue
import android.view.Gravity
import android.view.View
import android.view.ViewGroup
import android.widget.PopupWindow
import android.widget.TextView

/** Enlarged letter preview shown above a key while it's pressed, themed per [KeyboardVisualTheme]. */
class KeyPopupWindow(private val context: Context, theme: KeyboardVisualTheme) {

    private fun dp(value: Float) =
        TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, value, context.resources.displayMetrics)

    private val label = TextView(context).apply {
        textSize = 22f
        setTextColor(theme.popupTextColor)
        gravity = Gravity.CENTER
        val pad = dp(10f).toInt()
        setPadding(pad, pad, pad, pad)
        background = GradientDrawable().apply {
            shape = GradientDrawable.RECTANGLE
            cornerRadius = dp(theme.keyCornerRadiusDp)
            setColor(theme.popupFillColor)
        }
    }

    private val window = PopupWindow(
        label,
        ViewGroup.LayoutParams.WRAP_CONTENT,
        ViewGroup.LayoutParams.WRAP_CONTENT
    ).apply {
        isClippingEnabled = false
    }

    fun show(anchor: View, text: String) {
        label.text = text
        val location = IntArray(2)
        anchor.getLocationInWindow(location)
        val x = location[0] + anchor.width / 2 - dp(24f).toInt()
        val y = location[1] - anchor.height - dp(12f).toInt()
        if (window.isShowing) {
            window.update(x, y, -1, -1)
        } else {
            window.showAtLocation(anchor, Gravity.NO_GRAVITY, x, y)
        }
    }

    fun dismiss() {
        if (window.isShowing) window.dismiss()
    }
}
