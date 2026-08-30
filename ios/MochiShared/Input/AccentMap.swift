import Foundation

/// Alternate characters shown when a key is held.
///
/// Matches the US-English system keyboard's set, in the system's order — users reach these by
/// muscle memory (hold `e`, slide one right, get `é`) and reordering them is a subtle way to make
/// a keyboard feel wrong without anyone being able to say why.
enum AccentMap {
    static func alternates(for character: String) -> [String] {
        table[character.lowercased()] ?? []
    }

    static func hasAlternates(for character: String) -> Bool {
        !alternates(for: character).isEmpty
    }

    private static let table: [String: [String]] = [
        "a": ["à", "á", "â", "ä", "æ", "ã", "å", "ā"],
        "c": ["ç", "ć", "č"],
        "e": ["è", "é", "ê", "ë", "ē", "ė", "ę"],
        "i": ["î", "ï", "í", "ī", "į", "ì"],
        "l": ["ł"],
        "n": ["ñ", "ń"],
        "o": ["ô", "ö", "ò", "ó", "œ", "ø", "ō", "õ"],
        "s": ["ß", "ś", "š"],
        "u": ["û", "ü", "ù", "ú", "ū"],
        "y": ["ÿ"],
        "z": ["ž", "ź", "ż"],

        // Punctuation alternates from the numeric and symbol planes. Included because a user who
        // has learned to hold `?` for `¿` on the system keyboard will try it here.
        "-": ["–", "—", "•"],
        "/": ["\\"],
        "$": ["₹", "€", "£", "¥", "₩"],
        "&": ["§"],
        "\"": ["“", "”", "„", "«", "»"],
        "'": ["’", "‘", "`"],
        ".": ["…"],
        "?": ["¿"],
        "!": ["¡"],
        "%": ["‰"],
        "=": ["≠", "≈"]
    ]
}
