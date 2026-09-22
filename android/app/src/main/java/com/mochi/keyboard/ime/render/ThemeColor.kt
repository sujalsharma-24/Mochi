package com.mochi.keyboard.ime.render

import android.graphics.Color
import kotlin.math.max
import kotlin.math.min
import kotlin.math.pow
import kotlin.math.roundToInt

/**
 * A colour as a theme token stores it: sRGB channels plus alpha, quantised to 8 bits at
 * construction (mirrors iOS's `ThemeColor` exactly, including *why* it quantises: a colour that
 * round-trips through an 8-bit hex string must already be exactly representable in that format, or
 * "did the theme change?" comparisons and round-trip tests stop being meaningful). Values are
 * 0.0...1.0.
 */
class ThemeColor(red: Double, green: Double, blue: Double, alpha: Double = 1.0) {
    val red: Double = quantise(red)
    val green: Double = quantise(green)
    val blue: Double = quantise(blue)
    val alpha: Double = quantise(alpha)

    fun withAlpha(newAlpha: Double): ThemeColor = ThemeColor(red, green, blue, newAlpha)

    /** Linear interpolation toward another colour in sRGB — good enough for the small nudges the
     * renderer makes (a pressed key darkening, a gradient's second stop). */
    fun blended(toward: ThemeColor, amount: Double): ThemeColor {
        val t = amount.coerceIn(0.0, 1.0)
        return ThemeColor(
            red = red + (toward.red - red) * t,
            green = green + (toward.green - green) * t,
            blue = blue + (toward.blue - blue) * t,
            alpha = alpha + (toward.alpha - alpha) * t
        )
    }

    /** WCAG 2.1 relative luminance — the same formula Apple/W3C's "sufficient contrast" criteria are
     * defined against, so a theme that passes this also passes an external accessibility audit. */
    val relativeLuminance: Double
        get() {
            fun linearise(c: Double) = if (c <= 0.03928) c / 12.92 else ((c + 0.055) / 1.055).pow(2.4)
            return 0.2126 * linearise(red) + 0.7152 * linearise(green) + 0.0722 * linearise(blue)
        }

    /** WCAG contrast ratio, 1...21. Both colours must already be opaque — see [composited]. */
    fun contrastRatio(against: ThemeColor): Double {
        val a = relativeLuminance
        val b = against.relativeLuminance
        val lighter = max(a, b)
        val darker = min(a, b)
        return (lighter + 0.05) / (darker + 0.05)
    }

    /** Flattens this colour onto an opaque backdrop using source-over — the colour actually shown
     * on screen, and the only thing a contrast check should ever measure. */
    fun composited(over: ThemeColor): ThemeColor {
        if (alpha >= 1.0) return this
        val a = alpha
        return ThemeColor(
            red = red * a + over.red * (1 - a),
            green = green * a + over.green * (1 - a),
            blue = blue * a + over.blue * (1 - a),
            alpha = 1.0
        )
    }

    /** Android ARGB int, for `Paint`/`Drawable` APIs. */
    fun toArgb(): Int = Color.argb(
        (alpha * 255).roundToInt(),
        (red * 255).roundToInt(),
        (green * 255).roundToInt(),
        (blue * 255).roundToInt()
    )

    override fun equals(other: Any?): Boolean =
        other is ThemeColor && red == other.red && green == other.green &&
            blue == other.blue && alpha == other.alpha

    override fun hashCode(): Int = arrayOf(red, green, blue, alpha).contentHashCode()

    override fun toString(): String = "ThemeColor(${hexString()})"

    fun hexString(): String {
        fun ch(v: Double) = (v * 255).roundToInt().coerceIn(0, 255)
        val r = ch(red); val g = ch(green); val b = ch(blue); val a = ch(alpha)
        return if (a >= 255) "#%02X%02X%02X".format(r, g, b) else "#%02X%02X%02X%02X".format(r, g, b, a)
    }

    companion object {
        private fun quantise(v: Double): Double = (v.coerceIn(0.0, 1.0) * 255).roundToInt() / 255.0

        /** `#RRGGBB` or `#RRGGBBAA`. Leading `#` optional, case-insensitive. */
        fun hex(hex: String): ThemeColor {
            var raw = hex.trim().uppercase()
            if (raw.startsWith("#")) raw = raw.substring(1)
            require(raw.length == 6 || raw.length == 8) { "'$hex' is not #RRGGBB or #RRGGBBAA" }
            val value = raw.toLong(16)
            val hasAlpha = raw.length == 8
            val shift = if (hasAlpha) 8 else 0
            return ThemeColor(
                red = ((value shr (16 + shift)) and 0xFF) / 255.0,
                green = ((value shr (8 + shift)) and 0xFF) / 255.0,
                blue = ((value shr shift) and 0xFF) / 255.0,
                alpha = if (hasAlpha) (value and 0xFF) / 255.0 else 1.0
            )
        }

        /** hue/saturation/brightness in 0...1 (hue wraps). The one HSB entry point, for a future
         * Create-screen colour picker — everywhere else in the theme system stays sRGB. */
        fun hsb(hue: Double, saturation: Double, brightness: Double, alpha: Double = 1.0): ThemeColor {
            val h = hue - kotlin.math.floor(hue)
            val s = saturation.coerceIn(0.0, 1.0)
            val v = brightness.coerceIn(0.0, 1.0)
            val sector = (h * 6).toInt()
            val fraction = h * 6 - sector
            val p = v * (1 - s)
            val q = v * (1 - fraction * s)
            val t = v * (1 - (1 - fraction) * s)
            val (r, g, b) = when (sector % 6) {
                0 -> Triple(v, t, p)
                1 -> Triple(q, v, p)
                2 -> Triple(p, v, t)
                3 -> Triple(p, q, v)
                4 -> Triple(t, p, v)
                else -> Triple(v, p, q)
            }
            return ThemeColor(r, g, b, alpha)
        }
    }
}
