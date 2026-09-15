import Foundation

/// Bridges a marketplace `KeyboardTheme` (catalogue metadata — name, art asset, like count) to a
/// `MochiKeyboardTheme` (the render document the keyboard surface actually draws).
///
/// The whole `BuiltInThemes.all` catalogue (28 themes) ships as fully-authored render documents, so
/// resolution is: **custom id → built-in id → built-in name → mood fallback**. The first three
/// resolve `isExact == true`; only a theme that matches none of them (a Firestore entry with a
/// name no built-in shares, say) falls to the nearest built-in by mood, and `isExact` is `false` so
/// the UI can say the artwork is a stand-in.
///
/// The id and name indexes are both **derived from `BuiltInThemes.all`** rather than hand-listed,
/// so adding a theme there wires it in everywhere at once — Home, Community, Search and Themes all
/// funnel through this one function.
enum RenderableTheme {
    struct Resolved {
        let theme: MochiKeyboardTheme
        /// `true` when `theme` is this catalogue entry's own authored render document; `false` when
        /// it's a stand-in chosen by mood.
        let isExact: Bool
    }

    /// Canonical id (`mochi.<slug>`) → authored render document. `ThemeCatalog` entries carry the
    /// built-in id verbatim, so this is the path every Themes-screen tap takes.
    private static let byID: [String: MochiKeyboardTheme] =
        Dictionary(uniqueKeysWithValues: BuiltInThemes.all.map { ($0.id, $0) })

    /// Folded, lowercased name → authored render document. Catches themes that carry a legacy id
    /// convention (`themes-fantasy-castle-night`, a Firestore id, …) but the same display name as a
    /// built-in — which is every overlapping entry in `MockData`.
    private static let byName: [String: MochiKeyboardTheme] = Dictionary(
        BuiltInThemes.all.map { (nameKey($0.name), $0) },
        uniquingKeysWith: { first, _ in first }
    )

    /// Keywords that read as a dark/night theme — everything else falls to the daytime stand-in.
    private static let darkKeywords = [
        "night", "fantasy", "castle", "space", "galaxy", "cosmic", "midnight",
        "gothic", "dark", "noir", "star", "moon", "dream", "nebula"
    ]

    static func resolve(for theme: KeyboardTheme) -> Resolved {
        // A theme built in Create Custom Theme carries its own id (`"custom.<uuid>"`) rather than a
        // name that has to be pattern-matched — check that first so a published custom theme renders
        // the exact document the user built, not the nearest built-in by mood.
        if let custom = CustomThemeStore.renderTheme(forID: theme.id) {
            return Resolved(theme: custom, isExact: true)
        }

        if let exact = byID[theme.id] {
            return Resolved(theme: exact, isExact: true)
        }

        let key = nameKey(theme.name)
        if let exact = byName[key] {
            return Resolved(theme: exact, isExact: true)
        }

        let haystack = key + " " + theme.hashtags.joined(separator: " ").lowercased()
        let isDark = darkKeywords.contains { haystack.contains($0) }
        return Resolved(
            theme: isDark ? BuiltInThemes.fantasyCastleNight : BuiltInThemes.cozySakuraCafe,
            isExact: false
        )
    }

    /// The authored render document for a stored theme id, or `nil` when the id matches nothing.
    ///
    /// `resolve(for:)` needs a whole catalogue entry so it can fall back on name and mood. The
    /// launch-time re-sync has only the id that was persisted when the user tapped Apply, and an
    /// id that no longer resolves should write nothing rather than silently swap in a stand-in
    /// theme the user never chose.
    static func renderDocument(forID id: String) -> MochiKeyboardTheme? {
        CustomThemeStore.renderTheme(forID: id) ?? byID[id]
    }

    private static func nameKey(_ name: String) -> String {
        name.folding(options: .diacriticInsensitive, locale: .current)
            .lowercased()
            .trimmingCharacters(in: .whitespacesAndNewlines)
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
    /// the keyboard extension (a no-op today — see the type doc). Applying a theme also adds it to
    /// the downloaded set — keeping a theme you've put on your keyboard is implied, the same rule
    /// `FontStyleStore` documents for fonts.
    static func apply(_ theme: KeyboardTheme) {
        appliedThemeId = theme.id
        DownloadedThemeStore.add(theme.id)
        ThemeStore.writeActiveTheme(RenderableTheme.resolve(for: theme).theme)
    }

    /// Re-writes the applied theme's render document into the App Group container at launch.
    ///
    /// `apply(_:)` writes once and nothing ever checks again, so a single failed write is
    /// permanent: the keyboard keeps rendering `BuiltInThemes.default` while the app's own UI still
    /// shows the theme as applied, and neither side can tell. The extension has no way to report
    /// what it read, and the write itself only logs — so the mismatch is invisible from both ends.
    /// That is not hypothetical; it is the state a real device was found in, with `appliedThemeId`
    /// set and no `active-theme.json` in the container at all.
    ///
    /// Re-running the write on every launch makes the hand-off self-healing: whatever the original
    /// failure was — the App Group not yet provisioned, a transient I/O error, a container that
    /// moved — opening the app repairs it.
    static func syncToKeyboard() {
        guard let id = appliedThemeId,
              let document = RenderableTheme.renderDocument(forID: id) else { return }
        ThemeStore.writeActiveTheme(document)
    }
}
