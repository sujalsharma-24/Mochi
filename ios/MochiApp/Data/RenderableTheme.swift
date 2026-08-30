import Foundation

/// Bridges a marketplace `KeyboardTheme` (catalogue metadata — name, art asset, like count) to a
/// `MochiKeyboardTheme` (the render document the keyboard surface actually draws).
///
/// Only two themes ship as fully-authored render documents today — Cozy Sakura Café and Fantasy
/// Castle Night (`BuiltInThemes.all`). Every other catalogue entry resolves to the closest of those
/// two by mood, and `isExact` is `false` so the UI can say so rather than implying the artwork is
/// final. When a catalogue theme grows its own authored `MochiKeyboardTheme` (or the Create screen
/// starts producing real ones), it gets added to `exactMatches` and starts resolving `isExact`.
enum RenderableTheme {
    struct Resolved {
        let theme: MochiKeyboardTheme
        /// `true` when `theme` is this catalogue entry's own authored render document; `false` when
        /// it's a stand-in chosen by mood.
        let isExact: Bool
    }

    /// Catalogue name (diacritic-insensitive, lowercased) → authored render document.
    private static let exactMatches: [String: MochiKeyboardTheme] = [
        "fantasy castle night": BuiltInThemes.fantasyCastleNight,
        "cozy sakura cafe": BuiltInThemes.cozySakuraCafe,
        "cozy sakura café": BuiltInThemes.cozySakuraCafe
    ]

    /// Keywords that read as a dark/night theme — everything else falls to the daytime stand-in.
    private static let darkKeywords = [
        "night", "fantasy", "castle", "space", "galaxy", "cosmic", "midnight",
        "gothic", "dark", "noir", "star", "moon", "dream", "nebula"
    ]

    static func resolve(for theme: KeyboardTheme) -> Resolved {
        let key = theme.name
            .folding(options: .diacriticInsensitive, locale: .current)
            .lowercased()
            .trimmingCharacters(in: .whitespacesAndNewlines)

        if let exact = exactMatches[key] {
            return Resolved(theme: exact, isExact: true)
        }

        let haystack = key + " " + theme.hashtags.joined(separator: " ").lowercased()
        let isDark = darkKeywords.contains { haystack.contains($0) }
        return Resolved(
            theme: isDark ? BuiltInThemes.fantasyCastleNight : BuiltInThemes.cozySakuraCafe,
            isExact: false
        )
    }
}

/// The one marketplace theme the user has tapped **Apply** on, persisted app-side so the UI can show
/// an "Applied" state across screens and relaunches.
///
/// This is intentionally separate from `ThemeStore` (the App Group hand-off to the keyboard
/// extension). `ThemeStore.writeActiveTheme` is still called on apply — it's a harmless no-op until
/// the App Group entitlement is provisioned, and starts working for free once it is — but the
/// in-app "which card is applied" state can't depend on a container that doesn't exist yet.
enum AppliedThemeStore {
    static let defaultsKey = "mochi.appliedThemeId"

    static var appliedThemeId: String? {
        get { UserDefaults.standard.string(forKey: defaultsKey) }
        set {
            if let newValue {
                UserDefaults.standard.set(newValue, forKey: defaultsKey)
            } else {
                UserDefaults.standard.removeObject(forKey: defaultsKey)
            }
        }
    }

    /// Records `theme` as applied and forwards its render document to the App Group container for
    /// the keyboard extension (a no-op today — see the type doc).
    static func apply(_ theme: KeyboardTheme) {
        appliedThemeId = theme.id
        ThemeStore.writeActiveTheme(RenderableTheme.resolve(for: theme).theme)
    }
}
