package com.mochi.keyboard.ime.render

/**
 * Token model ported from iOS's `MochiShared/Theme/ThemeTokens.swift`. A theme describes tokens,
 * never pixels, so the same document renders correctly at any keyboard width and in any plane —
 * see `docs/keyboard-theme-system.md`. This slice ports the tokens needed to render a built-in
 * theme; JSON (de)serialisation for a future Create-screen/Firestore round-trip is not built yet.
 */
enum class ThemeAppearance { LIGHT, DARK }

/** A fill for any themed surface: one colour is flat, two or more is a linear gradient. Modelling
 * solid as the one-stop case of a gradient keeps the renderer on a single code path. */
class ThemeFill(stops: List<ThemeColor>, val angleDegrees: Double = 90.0) {
    val stops: List<ThemeColor> = if (stops.isEmpty()) listOf(ThemeColor(0.0, 0.0, 0.0, 0.0)) else stops

    constructor(solid: ThemeColor) : this(listOf(solid))

    val isSolid: Boolean get() = stops.size == 1

    /** The single colour a contrast check should treat this fill as — the *darkest* stop, since
     * these ramps run light-to-dark top-to-bottom and that is the worst case for a dark label. */
    val contrastRepresentative: ThemeColor
        get() = if (stops.size == 1) stops[0] else stops.minByOrNull { it.relativeLuminance } ?: stops[0]
}

class ThemeBorder(val color: ThemeColor, width: Double) {
    val width: Double = maxOf(0.0, width)
}

/** A drop shadow under a key cap. Colour, opacity, radius, y-offset only — no spread, no x-offset. */
class ThemeShadow(val color: ThemeColor, opacity: Double, radius: Double, val offsetY: Double) {
    val opacity: Double = opacity.coerceIn(0.0, 1.0)
    val radius: Double = maxOf(0.0, radius)

    companion object {
        val NONE = ThemeShadow(ThemeColor(0.0, 0.0, 0.0), 0.0, 0.0, 0.0)
    }
}

/** The treatment that turns a rounded rectangle into a pane of glass: an inner bevel (bright
 * hairline near the top edge) plus an inner shadow at the bottom. Both draw over the key's artwork. */
class KeyGlass(
    val bevelColor: ThemeColor,
    bevelWidth: Double = 1.0,
    bevelFalloff: Double = 0.55,
    val innerShadowColor: ThemeColor,
    innerShadowOpacity: Double = 0.35,
    innerShadowRadius: Double = 3.0
) {
    val bevelWidth: Double = maxOf(0.0, bevelWidth)
    val bevelFalloff: Double = bevelFalloff.coerceIn(0.05, 1.0)
    val innerShadowOpacity: Double = innerShadowOpacity.coerceIn(0.0, 1.0)
    val innerShadowRadius: Double = maxOf(0.0, innerShadowRadius)
}

/** The four visual roles a key can have — stable across every layout a theme might be applied to,
 * unlike per-key styling. */
enum class KeyRole { INPUT, SYSTEM, ACTION, SPACE }

enum class KeyCapShape { ROUNDED_RECT, HEXAGON }

/** How one key role looks, resting and pressed. */
class KeyStyle(
    val fill: ThemeFill,
    val labelColor: ThemeColor,
    val pressedFill: ThemeFill? = null,
    val pressedLabelColor: ThemeColor? = null,
    val border: ThemeBorder? = null,
    val shadow: ThemeShadow = ThemeShadow.NONE,
    val topHighlight: ThemeColor? = null,
    val cornerRadiusOverrideDp: Double? = null,
    val glass: KeyGlass? = null,
    val capShape: KeyCapShape = KeyCapShape.ROUNDED_RECT
) {
    /** The pressed appearance, derived when the theme does not author one. Moves *toward the
     * background*: a light cap darkens, a dark cap lightens, so feedback stays visible either way. */
    val resolvedPressedFill: ThemeFill
        get() {
            pressedFill?.let { return it }
            val isDarkCap = fill.contrastRepresentative.relativeLuminance < 0.5
            val target = ThemeColor(
                red = if (isDarkCap) 1.0 else 0.0,
                green = if (isDarkCap) 1.0 else 0.0,
                blue = if (isDarkCap) 1.0 else 0.0,
                alpha = fill.contrastRepresentative.alpha
            )
            return ThemeFill(fill.stops.map { it.blended(target, 0.18) }, fill.angleDegrees)
        }

    val resolvedPressedLabelColor: ThemeColor get() = pressedLabelColor ?: labelColor
}

/** Where a theme's background art comes from. Only `bundled` is used until a Create-screen upload
 * path exists (iOS's `appGroupFile` case has no Android equivalent since the IME runs in-process). */
class ThemeBackgroundImage(
    /** Android drawable resource name, e.g. "themebg_cozy_sakura_cafe". */
    val bundledName: String,
    val scalesToFill: Boolean = true,
    verticalAnchor: Double = 0.5
) {
    val verticalAnchor: Double = verticalAnchor.coerceIn(0.0, 1.0)
}

/** The layer between background art and keys — the piece that makes an art-backed keyboard
 * readable, and validated (not just guessed) before a theme ships. */
class ThemeScrim(val topColor: ThemeColor, val bottomColor: ThemeColor) {
    constructor(flat: ThemeColor) : this(flat, flat)

    /** The more transparent end — where background art shows through most and legibility is most
     * at risk. */
    val weakestColor: ThemeColor get() = if (topColor.alpha <= bottomColor.alpha) topColor else bottomColor

    companion object {
        val NONE = ThemeScrim(ThemeColor(0.0, 0.0, 0.0, 0.0))
    }
}

class ThemeSurface(
    val baseFill: ThemeFill,
    val backgroundImage: ThemeBackgroundImage? = null,
    val scrim: ThemeScrim = ThemeScrim.NONE
)

class ThemeTypography(
    /** Android Typeface family name, or null for the system default. */
    val fontFamily: String? = null,
    /** Mirrors iOS's `UIFont.Weight` raw value (-1...1, 0 = regular). Android's simpler `Typeface`
     * API has no continuous weight axis, so [KeyCapView] approximates it as bold above a threshold
     * rather than losing the distinction entirely. */
    val weightRawValue: Double = 0.0,
    sizeMultiplier: Double = 1.0
) {
    val sizeMultiplier: Double = sizeMultiplier.coerceIn(0.75, 1.35)
}

/** Nudges one illustration off the placement every other key in the set uses — every field is a
 * delta from the default, so `IDENTITY` is the no-op. */
class KeyArtPlacement(
    offsetX: Double = 0.0,
    offsetY: Double = 0.0,
    scale: Double = 1.0,
    val opacity: Double? = null,
    val brightness: Double? = null
) {
    val offsetX: Double = offsetX.coerceIn(-1.0, 1.0)
    val offsetY: Double = offsetY.coerceIn(-1.0, 1.0)
    val scale: Double = scale.coerceIn(0.2, 3.0)

    val isIdentity: Boolean
        get() = offsetX == 0.0 && offsetY == 0.0 && scale == 1.0 && opacity == null && brightness == null

    companion object { val IDENTITY = KeyArtPlacement() }
}

/** Per-key illustrations drawn inside the cap, beneath the label. Addressed by stable key identity
 * (`"q"`, `"shift"`, `"space"`) rather than role, because this is the one part of a theme that
 * genuinely is per-key. Assets resolve as `assetPrefix + identity` (an Android drawable name). */
class KeyArtSet(
    val assetPrefix: String,
    heightFraction: Double = 0.55,
    bottomInsetFraction: Double = 0.04,
    opacity: Double = 1.0,
    val fillKeys: Set<String> = setOf("space"),
    labelLiftFraction: Double = 0.07,
    val placements: Map<String, KeyArtPlacement> = emptyMap()
) {
    val heightFraction: Double = heightFraction.coerceIn(0.1, 1.0)
    val bottomInsetFraction: Double = bottomInsetFraction.coerceIn(0.0, 0.4)
    val opacity: Double = opacity.coerceIn(0.0, 1.0)
    val labelLiftFraction: Double = labelLiftFraction.coerceIn(0.0, 0.3)

    fun assetName(identity: String) = assetPrefix + identity
    fun placement(identity: String): KeyArtPlacement = placements[identity] ?: KeyArtPlacement.IDENTITY
    fun resolvedOpacity(identity: String): Double = placement(identity).opacity ?: opacity
    fun resolvedBrightness(identity: String): Double = placement(identity).brightness ?: 0.0
}

/** Styling for non-key surfaces: the suggestion bar and the long-press accent callout. */
class ThemeChrome(
    val inkColor: ThemeColor,
    val mutedInkColor: ThemeColor,
    val panelFill: ThemeFill,
    val highlightFill: ThemeFill
) {
    companion object {
        fun default(appearance: ThemeAppearance): ThemeChrome {
            val isDark = appearance == ThemeAppearance.DARK
            val ink = ThemeColor(if (isDark) 0.96 else 0.08, if (isDark) 0.94 else 0.07, if (isDark) 1.0 else 0.12)
            return ThemeChrome(
                inkColor = ink,
                mutedInkColor = ink.withAlpha(0.55),
                panelFill = ThemeFill(ThemeColor(if (isDark) 0.10 else 0.98, if (isDark) 0.06 else 0.97, if (isDark) 0.18 else 1.0, 0.55)),
                highlightFill = ThemeFill(ThemeColor(if (isDark) 1.0 else 0.0, if (isDark) 1.0 else 0.0, if (isDark) 1.0 else 0.0, 0.16))
            )
        }
    }
}

/** Declared for schema parity with iOS; the renderer does not draw particles in this slice. */
class ThemeEffects(val isEnabled: Boolean = false, val birthRate: Double = 0.0, val tint: ThemeColor? = null) {
    companion object { val NONE = ThemeEffects() }
}
