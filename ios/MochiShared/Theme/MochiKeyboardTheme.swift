import Foundation

/// A complete keyboard theme, as a document.
///
/// One type is read by four different consumers — the Create screen writes it, Firestore stores
/// it, the in-app preview renders it, and the keyboard extension renders it in a different
/// process. That is the reason it is a plain `Codable` value type with no behaviour beyond
/// resolution: anything stateful or UIKit-flavoured here would have to be duplicated or faked in
/// at least one of those four places.
///
/// A theme describes **tokens, not pixels**. It never contains a rendered keyboard image. The
/// artwork it references is a background layer that the renderer composites keys on top of, which
/// is what allows one theme to be correct on every device size, in both key planes, and at any
/// system text size — none of which a baked screenshot can do.
struct MochiKeyboardTheme: Codable, Equatable, Identifiable {
    /// Bumped only for a **breaking** shape change. Adding an optional field with a default is not
    /// breaking and must not bump this, or every older client stops reading newer themes for no
    /// reason. `ThemeStore` refuses to decode a document from a future major version rather than
    /// rendering it wrong.
    static let currentSchemaVersion = 1

    var schemaVersion: Int
    var id: String
    var name: String
    var authorName: String?
    var appearance: ThemeAppearance
    var surface: ThemeSurface
    /// Styles by role. Stored as a dictionary rather than four named properties so that decoding a
    /// theme authored against a future role set degrades to "that role falls back" instead of
    /// failing outright.
    var keyStyles: [KeyRole: KeyStyle]
    var typography: ThemeTypography
    /// Non-key surfaces. Defaulted from `appearance` when a document omits it, so themes authored
    /// before the suggestion bar and emoji panel existed keep decoding unchanged.
    var chrome: ThemeChrome
    /// Per-key illustrations. `nil` for themes that style keys with colour alone.
    var keyArt: KeyArtSet?
    var effects: ThemeEffects

    init(
        schemaVersion: Int = MochiKeyboardTheme.currentSchemaVersion,
        id: String,
        name: String,
        authorName: String? = nil,
        appearance: ThemeAppearance,
        surface: ThemeSurface,
        keyStyles: [KeyRole: KeyStyle],
        typography: ThemeTypography = ThemeTypography(),
        chrome: ThemeChrome? = nil,
        keyArt: KeyArtSet? = nil,
        effects: ThemeEffects = .none
    ) {
        self.schemaVersion = schemaVersion
        self.id = id
        self.name = name
        self.authorName = authorName
        self.appearance = appearance
        self.surface = surface
        self.keyStyles = keyStyles
        self.typography = typography
        self.chrome = chrome ?? .default(for: appearance)
        self.keyArt = keyArt
        self.effects = effects
    }

    /// The style for a role, falling back to `.input` and finally to a legible last-resort style.
    ///
    /// The renderer must never be able to fail to draw a key. A theme missing its `.action` style
    /// should produce a keyboard with a plain-looking return key, not a crash or an invisible one.
    func style(for role: KeyRole) -> KeyStyle {
        keyStyles[role] ?? keyStyles[.input] ?? MochiKeyboardTheme.lastResortStyle(for: appearance)
    }

    static func lastResortStyle(for appearance: ThemeAppearance) -> KeyStyle {
        let isDark = appearance == .dark
        return KeyStyle(
            fill: ThemeFill(ThemeColor(
                red: isDark ? 0.42 : 1,
                green: isDark ? 0.42 : 1,
                blue: isDark ? 0.44 : 1
            )),
            labelColor: ThemeColor(
                red: isDark ? 1 : 0,
                green: isDark ? 1 : 0,
                blue: isDark ? 1 : 0
            )
        )
    }
}

// MARK: - Codable

extension MochiKeyboardTheme {
    private enum CodingKeys: String, CodingKey {
        case schemaVersion, id, name, authorName, appearance, surface, keyStyles, typography, chrome, keyArt, effects
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let version = try container.decodeIfPresent(Int.self, forKey: .schemaVersion)
            ?? MochiKeyboardTheme.currentSchemaVersion
        guard version <= MochiKeyboardTheme.currentSchemaVersion else {
            throw ThemeDecodingError.unsupportedSchemaVersion(
                found: version,
                supported: MochiKeyboardTheme.currentSchemaVersion
            )
        }

        // Roles decode leniently: an unrecognised role key is skipped rather than failing the whole
        // document, so a theme authored by a newer client still renders on an older one.
        var styles: [KeyRole: KeyStyle] = [:]
        let rawStyles = try container.decodeIfPresent([String: KeyStyle].self, forKey: .keyStyles) ?? [:]
        for (rawRole, style) in rawStyles {
            if let role = KeyRole(rawValue: rawRole) { styles[role] = style }
        }

        self.init(
            schemaVersion: version,
            id: try container.decode(String.self, forKey: .id),
            name: try container.decode(String.self, forKey: .name),
            authorName: try container.decodeIfPresent(String.self, forKey: .authorName),
            appearance: try container.decodeIfPresent(ThemeAppearance.self, forKey: .appearance) ?? .light,
            surface: try container.decode(ThemeSurface.self, forKey: .surface),
            keyStyles: styles,
            typography: try container.decodeIfPresent(ThemeTypography.self, forKey: .typography)
                ?? ThemeTypography(),
            chrome: try container.decodeIfPresent(ThemeChrome.self, forKey: .chrome),
            keyArt: try container.decodeIfPresent(KeyArtSet.self, forKey: .keyArt),
            effects: try container.decodeIfPresent(ThemeEffects.self, forKey: .effects) ?? .none
        )
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(schemaVersion, forKey: .schemaVersion)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encodeIfPresent(authorName, forKey: .authorName)
        try container.encode(appearance, forKey: .appearance)
        try container.encode(surface, forKey: .surface)
        try container.encode(
            Dictionary(uniqueKeysWithValues: keyStyles.map { ($0.key.rawValue, $0.value) }),
            forKey: .keyStyles
        )
        try container.encode(typography, forKey: .typography)
        try container.encode(chrome, forKey: .chrome)
        try container.encodeIfPresent(keyArt, forKey: .keyArt)
        try container.encode(effects, forKey: .effects)
    }
}

enum ThemeDecodingError: LocalizedError, Equatable {
    case unsupportedSchemaVersion(found: Int, supported: Int)

    var errorDescription: String? {
        switch self {
        case .unsupportedSchemaVersion(let found, let supported):
            return "Theme uses schema version \(found); this build understands up to \(supported)."
        }
    }
}
