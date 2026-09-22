package com.mochi.keyboard.ime.render

/**
 * A complete keyboard theme, as a document — ported from iOS's `MochiKeyboardTheme.swift`. Describes
 * tokens, never pixels, so one theme renders correctly on any device width and in any key plane.
 */
class MochiKeyboardTheme(
    val id: String,
    val name: String,
    val authorName: String? = null,
    val appearance: ThemeAppearance,
    val surface: ThemeSurface,
    /** Styles by role — a theme missing a role falls back rather than failing to render. */
    val keyStyles: Map<KeyRole, KeyStyle>,
    val typography: ThemeTypography = ThemeTypography(),
    chrome: ThemeChrome? = null,
    val keyArt: KeyArtSet? = null,
    val effects: ThemeEffects = ThemeEffects.NONE
) {
    val chrome: ThemeChrome = chrome ?: ThemeChrome.default(appearance)

    /** The style for a role, falling back to INPUT and finally to a legible last-resort style — the
     * renderer must never fail to draw a key. */
    fun style(role: KeyRole): KeyStyle =
        keyStyles[role] ?: keyStyles[KeyRole.INPUT] ?: lastResortStyle(appearance)

    companion object {
        fun lastResortStyle(appearance: ThemeAppearance): KeyStyle {
            val isDark = appearance == ThemeAppearance.DARK
            return KeyStyle(
                fill = ThemeFill(ThemeColor(if (isDark) 0.42 else 1.0, if (isDark) 0.42 else 1.0, if (isDark) 0.44 else 1.0)),
                labelColor = ThemeColor(if (isDark) 1.0 else 0.0, if (isDark) 1.0 else 0.0, if (isDark) 1.0 else 0.0)
            )
        }
    }
}
