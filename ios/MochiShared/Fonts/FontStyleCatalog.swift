import Foundation

/// A "font" in Mochi is **not** a typeface. An iOS keyboard extension cannot register or load a
/// custom font for the text it inserts (see docs/PRODUCTION_PLAN.md §1e), so each style is instead a
/// table that maps `A–Z / a–z / 0–9` onto a run of Unicode "lookalike" code points — the same trick
/// the "fancy text" keyboards use. That table *is* the font: it is what the Fonts screen previews
/// and what the keyboard emits once a style has been applied.
///
/// Lives in MochiShared (compiled into both targets, not linked as a framework) so the app — which
/// renders the preview and writes the applied style — and the extension — which transforms typed
/// characters — share one definition and can never disagree about what "Bubble Cute" looks like.
///
/// Caveats that come with the approach, not bugs: these are separate Unicode symbols rather than
/// real formatting, so they render at the system fallback weight (not pixel-matched to the Figma
/// card art), may not display in every app, and read poorly to screen readers.
struct FontStyle: Identifiable, Equatable {
    let id: String
    /// Human name, matches the `FontItem` of the same `id` in the app's catalogue.
    let displayName: String
    /// `plain character -> styled character`. Any character not present here (punctuation, emoji,
    /// accented letters, other scripts) passes through untouched.
    let forward: [Character: Character]

    /// Transforms a run of text into this style, one character at a time.
    func styled(_ text: String) -> String {
        String(text.map { forward[$0] ?? $0 })
    }
}

enum FontStyleCatalog {
    /// The six styles the Fonts screen ships with. `id` matches `MockData.fontCollection`.
    ///
    /// Each style names a complete Unicode block plus, where that block has reserved holes, the
    /// Letterlike-Symbols substitutes for them (the holes are a documented property of the Script
    /// and Fraktur blocks — arithmetic offsets alone would emit "tofu" for those letters).
    static let styles: [FontStyle] = [
        // Enclosed Alphanumerics — Ⓐ / ⓐ complete; digits are ⓪ then ①..⑨ (a different run).
        make(id: "bubble-cute", name: "Bubble Cute",
             upper: 0x24B6, lower: 0x24D0, digitZero: 0x24EA, digitOne: 0x2460),

        // Mathematical Script — eight reserved uppercase code points, three reserved lowercase.
        make(id: "handwritten-elegant", name: "Handwritten Elegant",
             upper: 0x1D49C, lower: 0x1D4B6, holes: scriptHoles),

        // Mathematical Monospace — complete, digits included.
        make(id: "typewriter-classic", name: "Typewriter Classic",
             upper: 0x1D670, lower: 0x1D68A, digitZero: 0x1D7F6),

        // Mathematical Sans-Serif Bold — complete, digits included.
        make(id: "bold-strong", name: "Bold Strong",
             upper: 0x1D5D4, lower: 0x1D5EE, digitZero: 0x1D7EC),

        // Mathematical Bold Script — a fuller, flowing hand than the thin Script above, and unlike
        // it has no reserved holes. No digit block, so 0–9 stay plain.
        make(id: "nature-flow", name: "Nature Flow",
             upper: 0x1D4D0, lower: 0x1D4EA),

        // Mathematical Fraktur — five reserved uppercase code points, lowercase complete.
        make(id: "gothic-dark", name: "Gothic Dark",
             upper: 0x1D504, lower: 0x1D51E, holes: frakturHoles),
    ]

    static func style(for id: String?) -> FontStyle? {
        guard let id else { return nil }
        return styles.first { $0.id == id }
    }

    // MARK: - Normalising back to plain text

    /// Every style's map inverted into one table. The blocks never overlap, so a styled character
    /// resolves to exactly one plain character.
    private static let reverse: [Character: Character] = {
        var out: [Character: Character] = [:]
        for style in styles {
            for (plain, styled) in style.forward { out[styled] = plain }
        }
        return out
    }()

    /// Turns styled text back into plain ASCII. The keyboard runs `documentContextBeforeInput`
    /// through this before auto-capitalisation, the double-space period and the suggestion engine
    /// look at it — otherwise every one of those silently stops working the moment a style is on.
    static func normalize(_ text: String?) -> String {
        guard let text else { return "" }
        return String(text.map { reverse[$0] ?? $0 })
    }

    // MARK: - Block construction

    /// Substitutes for the reserved code points in the Mathematical Script block, taken from
    /// Letterlike Symbols. Keyed by the plain letter they stand in for.
    private static let scriptHoles: [Character: UInt32] = [
        "B": 0x212C, "E": 0x2130, "F": 0x2131, "H": 0x210B,
        "I": 0x2110, "L": 0x2112, "M": 0x2133, "R": 0x211B,
        "e": 0x212F, "g": 0x210A, "o": 0x2134,
    ]

    /// Substitutes for the reserved code points in the Mathematical Fraktur block.
    private static let frakturHoles: [Character: UInt32] = [
        "C": 0x212D, "H": 0x210C, "I": 0x2111, "R": 0x211C, "Z": 0x2128,
    ]

    private static func make(id: String, name: String,
                             upper: UInt32, lower: UInt32,
                             digitZero: UInt32? = nil, digitOne: UInt32? = nil,
                             holes: [Character: UInt32] = [:]) -> FontStyle {
        var map: [Character: Character] = [:]

        for (i, c) in "ABCDEFGHIJKLMNOPQRSTUVWXYZ".enumerated() {
            map[c] = scalar(holes[c] ?? upper + UInt32(i))
        }
        for (i, c) in "abcdefghijklmnopqrstuvwxyz".enumerated() {
            map[c] = scalar(holes[c] ?? lower + UInt32(i))
        }
        if let digitZero {
            map["0"] = scalar(digitZero)
            let one = digitOne ?? digitZero + 1
            for (i, c) in "123456789".enumerated() {
                map[c] = scalar(one + UInt32(i))
            }
        }
        return FontStyle(id: id, displayName: name, forward: map)
    }

    private static func scalar(_ value: UInt32) -> Character {
        Character(UnicodeScalar(value) ?? " ")
    }
}
