package com.mochi.keyboard.ime.render

/** Long-press accent alternates, in the system keyboard's own order — ported from iOS's
 * `AccentMap.swift` so users reach these by the same muscle memory. */
object AccentMap {
    private val map: Map<String, List<String>> = mapOf(
        "a" to listOf("à", "á", "â", "ä", "æ", "ã", "å", "ā"),
        "e" to listOf("è", "é", "ê", "ë", "ē", "ė", "ę"),
        "i" to listOf("ì", "í", "î", "ï", "ī", "į"),
        "o" to listOf("ò", "ó", "ô", "ö", "õ", "ø", "ō"),
        "u" to listOf("ù", "ú", "û", "ü", "ū"),
        "y" to listOf("ý", "ÿ"),
        "n" to listOf("ñ", "ń"),
        "c" to listOf("ç", "ć", "č"),
        "s" to listOf("ś", "š", "ß"),
        "z" to listOf("ž", "ź", "ż"),
        "l" to listOf("ł"),
        "g" to listOf("ğ"),
        "0" to listOf("°"),
        "1" to listOf("¹"),
        "2" to listOf("²"),
        "3" to listOf("³"),
        "-" to listOf("–", "—"),
        "'" to listOf("'", "'", "`"),
        "\"" to listOf("“", "”"),
        "?" to listOf("¿"),
        "!" to listOf("¡"),
        "$" to listOf("€", "£", "¥", "¢")
    )

    fun alternates(character: String): List<String> = map[character.lowercase()] ?: emptyList()
}
