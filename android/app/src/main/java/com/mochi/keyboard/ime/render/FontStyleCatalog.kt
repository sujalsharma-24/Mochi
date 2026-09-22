package com.mochi.keyboard.ime.render

/**
 * A "font" in Mochi is **not** a typeface — ported from iOS's `FontStyleCatalog.swift`. An input
 * method can't register a custom font for text it inserts into someone else's app, so each style is
 * instead a table mapping `A-Z / a-z / 0-9` onto a run of Unicode "lookalike" code points (the same
 * trick "fancy text" keyboards use). That table *is* the font: what the Fonts screen previews is
 * exactly what the keyboard emits, because both read this one object.
 *
 * Caveats that come with the approach, not bugs: these are separate Unicode symbols rather than
 * real formatting, may not display in every app, and read poorly to screen readers.
 *
 * Unlike Swift's `Character` (a full grapheme cluster), Kotlin's `Char` is a single UTF-16 code
 * unit — most of these blocks (Mathematical Alphanumeric Symbols) live in the supplementary plane
 * and need a surrogate *pair*, so replacements are modelled as `String`, not `Char`.
 */
class FontStyle(val id: String, val displayName: String, internal val forward: Map<Char, String>) {
    fun styled(text: String): String {
        val sb = StringBuilder(text.length * 2)
        for (ch in text) sb.append(forward[ch] ?: ch.toString())
        return sb.toString()
    }
}

object FontStyleCatalog {
    private val scriptHoles: Map<Char, Int> = mapOf(
        'B' to 0x212C, 'E' to 0x2130, 'F' to 0x2131, 'H' to 0x210B,
        'I' to 0x2110, 'L' to 0x2112, 'M' to 0x2133, 'R' to 0x211B,
        'e' to 0x212F, 'g' to 0x210A, 'o' to 0x2134
    )

    private val frakturHoles: Map<Char, Int> = mapOf(
        'C' to 0x212D, 'H' to 0x210C, 'I' to 0x2111, 'R' to 0x211C, 'Z' to 0x2128
    )

    /** The six styles the Fonts screen ships with — `id` matches `MockData.fontCollection`. Each
     * names a complete Unicode block plus, where that block has reserved holes, the Letterlike-
     * Symbols substitutes for them (a documented property of the Script/Fraktur blocks — arithmetic
     * offsets alone would emit "tofu" for those letters). */
    val styles: List<FontStyle> = listOf(
        // Enclosed Alphanumerics — Ⓐ/ⓐ complete; digits are ⓪ then ①..⑨ (a different run).
        make(id = "bubble-cute", name = "Bubble Cute", upper = 0x24B6, lower = 0x24D0, digitZero = 0x24EA, digitOne = 0x2460),
        // Mathematical Script — eight reserved uppercase code points, three reserved lowercase.
        make(id = "handwritten-elegant", name = "Handwritten Elegant", upper = 0x1D49C, lower = 0x1D4B6, holes = scriptHoles),
        // Mathematical Monospace — complete, digits included.
        make(id = "typewriter-classic", name = "Typewriter Classic", upper = 0x1D670, lower = 0x1D68A, digitZero = 0x1D7F6),
        // Mathematical Sans-Serif Bold — complete, digits included.
        make(id = "bold-strong", name = "Bold Strong", upper = 0x1D5D4, lower = 0x1D5EE, digitZero = 0x1D7EC),
        // Mathematical Bold Script — fuller/flowing, no reserved holes, no digit block.
        make(id = "nature-flow", name = "Nature Flow", upper = 0x1D4D0, lower = 0x1D4EA),
        // Mathematical Fraktur — five reserved uppercase code points, lowercase complete.
        make(id = "gothic-dark", name = "Gothic Dark", upper = 0x1D504, lower = 0x1D51E, holes = frakturHoles)
    )

    fun style(id: String?): FontStyle? = styles.firstOrNull { it.id == id }

    /** Every style's map inverted into one table — the blocks never overlap, so a styled run
     * resolves to exactly one plain character. Keyed by the full replacement string (1 or 2 UTF-16
     * units) since a surrogate pair has to be looked up whole, not half at a time. */
    private val reverse: Map<String, Char> by lazy {
        val out = HashMap<String, Char>()
        for (style in styles) for ((plain, styledRun) in style.forward) out[styledRun] = plain
        out
    }

    /** Turns styled text back into plain ASCII, walking by Unicode code point so a surrogate-pair
     * replacement is matched whole. The keyboard runs the text-before-cursor context through this
     * before auto-capitalisation and the double-space period look at it — otherwise both silently
     * stop working the moment a style is applied. */
    fun normalize(text: String?): String {
        if (text.isNullOrEmpty()) return ""
        val sb = StringBuilder(text.length)
        var i = 0
        while (i < text.length) {
            val codePoint = text.codePointAt(i)
            val charCount = Character.charCount(codePoint)
            val unit = text.substring(i, i + charCount)
            sb.append(reverse[unit] ?: unit)
            i += charCount
        }
        return sb.toString()
    }

    private fun make(
        id: String, name: String, upper: Int, lower: Int,
        digitZero: Int? = null, digitOne: Int? = null, holes: Map<Char, Int> = emptyMap()
    ): FontStyle {
        val map = HashMap<Char, String>()
        "ABCDEFGHIJKLMNOPQRSTUVWXYZ".forEachIndexed { i, c -> map[c] = scalar(holes[c] ?: (upper + i)) }
        "abcdefghijklmnopqrstuvwxyz".forEachIndexed { i, c -> map[c] = scalar(holes[c] ?: (lower + i)) }
        if (digitZero != null) {
            map['0'] = scalar(digitZero)
            val one = digitOne ?: (digitZero + 1)
            "123456789".forEachIndexed { i, c -> map[c] = scalar(one + i) }
        }
        return FontStyle(id, name, map)
    }

    /** A full code point as a String — 1 UTF-16 unit in the BMP, 2 (a surrogate pair) in a
     * supplementary plane. Never a bare `Char`, which cannot hold the latter at all. */
    private fun scalar(value: Int): String = String(Character.toChars(value))
}
