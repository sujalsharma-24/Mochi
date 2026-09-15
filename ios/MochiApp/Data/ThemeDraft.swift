import Foundation

/// The Create screen's single source of truth.
///
/// Every editor control mutates one field on this value; nothing downstream — the live preview,
/// `CustomThemeStore`, the eventual Firestore write — ever touches a `MochiKeyboardTheme` or a
/// `ThemeDocument` directly. Both are *derived* below, forward-only.
///
/// That is deliberate, not incidental. If the draft stored a `MochiKeyboardTheme` instead, every
/// control would need an inverse — a stored `ThemeColor` back into a hue/saturation/brightness knob
/// position, a `cornerRadiusOverride` back into which of four chips is selected — and those inverses
/// are exactly where a slider and the theme it is supposed to represent drift apart. Storing intent
/// and deriving forward means there is only ever one direction for a bug to hide in.
struct ThemeDraft: Codable, Equatable, Identifiable {
    /// `"custom.<uuid>"` — namespaced so `RenderableTheme` recognises a custom theme's id on sight
    /// and it can never collide with a `BuiltInThemes` id or a Firestore document id.
    var id: String
    var name: String = ""
    var tags: [String] = []

    var background: BackgroundChoice = .gradient(.dawn)

    // HSB rather than a stored `ThemeColor`, for the same reason the type doc gives: the saturation
    // square and hue rail are HSB controls, and a hex round-trip would lose the exact knob position
    // on every reload. Letter colour lands the knobs exactly where 4.png draws them (`MochiColor.
    // pickerHue` is H 0.79). Key colour deliberately departs from the frame: a fresh custom theme
    // should start from a white keyboard, not the frame's lavender swatch, so saturation is 0 and
    // brightness is a true 1.0 (not the frame's 0.97, which reads as off-white next to real white).
    // Hue stays 0.79 — inert at zero saturation, and it's what the user gets the instant they raise it.
    var keyHue: Double = 0.79
    var keySaturation: Double = 0.0
    var keyBrightness: Double = 1.0
    var letterHue: Double = 0.74
    var letterSaturation: Double = 0.62
    var letterBrightness: Double = 0.22

    /// Most-recent-first, hex, capped at 6 — backs the RECENT swatch grid. Local editing history,
    /// not part of the published theme.
    var recentKeyColors: [String] = []

    var keyShape: KeyShapeOption = .rounded
    var typography: TypographyOption = .default
    var effect: EffectOption = .none
    var effectIntensity: Double = 0.5

    var createdAt: Date = Date()
    var updatedAt: Date = Date()
    /// Set once `CustomThemeStore.publish` succeeds locally. A draft's own persisted flag, distinct
    /// from Firestore's `moderationStatus` — this is "live in the app's own theme system", not
    /// "approved by moderation", which nothing on this build can grant anyway (see
    /// `CreateThemeViewModel`).
    var isPublished: Bool = false

    init(id: String = "custom.\(UUID().uuidString.lowercased())") {
        self.id = id
    }
}

// MARK: - Background

enum BackgroundChoice: Codable, Equatable {
    case gradient(GradientPreset)
    case solid(hue: Double, saturation: Double, brightness: Double)
    /// One of the real `themebg_*` plates shipped in `SharedAssets/KeyboardArt.xcassets` — every one
    /// of which already backs an authored, validated `BuiltInThemes` entry. `displayName` is carried
    /// alongside the asset name purely so the gallery can render a caption without a second lookup.
    case plate(assetName: String, displayName: String)
    /// Relative to `CustomThemeStore.mediaRootURL` — a user photo, downsampled and copied there by
    /// `CustomThemeStore.storePhoto`.
    case photo(relativePath: String)

    private enum CodingKeys: String, CodingKey { case kind, gradient, hue, saturation, brightness, assetName, displayName, relativePath }
    private enum Kind: String, Codable { case gradient, solid, plate, photo }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        switch try container.decode(Kind.self, forKey: .kind) {
        case .gradient:
            self = .gradient(try container.decode(GradientPreset.self, forKey: .gradient))
        case .solid:
            self = .solid(
                hue: try container.decode(Double.self, forKey: .hue),
                saturation: try container.decode(Double.self, forKey: .saturation),
                brightness: try container.decode(Double.self, forKey: .brightness)
            )
        case .plate:
            self = .plate(
                assetName: try container.decode(String.self, forKey: .assetName),
                displayName: try container.decode(String.self, forKey: .displayName)
            )
        case .photo:
            self = .photo(relativePath: try container.decode(String.self, forKey: .relativePath))
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .gradient(let preset):
            try container.encode(Kind.gradient, forKey: .kind)
            try container.encode(preset, forKey: .gradient)
        case .solid(let hue, let saturation, let brightness):
            try container.encode(Kind.solid, forKey: .kind)
            try container.encode(hue, forKey: .hue)
            try container.encode(saturation, forKey: .saturation)
            try container.encode(brightness, forKey: .brightness)
        case .plate(let assetName, let displayName):
            try container.encode(Kind.plate, forKey: .kind)
            try container.encode(assetName, forKey: .assetName)
            try container.encode(displayName, forKey: .displayName)
        case .photo(let relativePath):
            try container.encode(Kind.photo, forKey: .kind)
            try container.encode(relativePath, forKey: .relativePath)
        }
    }

    /// The `(appearance, surface)` this background resolves to.
    ///
    /// A `.plate` reuses the exact `ThemeSurface` — background image *and* its hand-tuned, validator
    /// -passed scrim — off whichever `BuiltInThemes` entry already ships that plate, rather than
    /// guessing a new scrim per custom theme. Every plate the gallery offers comes from
    /// `BackgroundChoice.availablePlates`, which only ever lists plates `BuiltInThemes.all` actually
    /// has, so the lookup below is not allowed to miss — the fallback exists only for a plate asset
    /// added to the catalogue without a matching authored theme, which `validate-themes.sh` would
    /// itself flag long before a user ever saw it.
    var resolvedSurface: (appearance: ThemeAppearance, surface: ThemeSurface) {
        switch self {
        case .gradient(let preset):
            return (preset.appearance, ThemeSurface(
                baseFill: ThemeFill(stops: preset.stops, angleDegrees: 90),
                backgroundImage: nil,
                scrim: .none
            ))

        case .solid(let hue, let saturation, let brightness):
            let color = ThemeColor(hue: hue, saturation: saturation, brightness: brightness)
            let appearance: ThemeAppearance = color.relativeLuminance < 0.45 ? .dark : .light
            return (appearance, ThemeSurface(baseFill: ThemeFill(color), backgroundImage: nil, scrim: .none))

        case .plate(let assetName, _):
            if let authored = BuiltInThemes.all.first(where: {
                $0.surface.backgroundImage?.source == .bundled(name: assetName)
            }) {
                return (authored.appearance, authored.surface)
            }
            // Defensive only — see the doc comment above.
            return (.dark, ThemeSurface(
                baseFill: ThemeFill(stops: [ThemeColor(hex: "#221342")!, ThemeColor(hex: "#4E2C68")!]),
                backgroundImage: ThemeBackgroundImage(source: .bundled(name: assetName), scalesToFill: true),
                scrim: ThemeScrim(
                    topColor: ThemeColor(hex: "#1A0E30")!.withAlpha(0.6),
                    bottomColor: ThemeColor(hex: "#140A28")!.withAlpha(0.5)
                )
            ))

        case .photo(let relativePath):
            // A user photo's content is unknowable ahead of time, so this scrim is deliberately the
            // strongest of any background choice — safer to darken a bright photo a little too much
            // than to publish a custom theme that turns out illegible over some users' pictures.
            return (.dark, ThemeSurface(
                baseFill: ThemeFill(stops: [ThemeColor(hex: "#241338")!, ThemeColor(hex: "#3A2354")!]),
                backgroundImage: ThemeBackgroundImage(
                    source: .appGroupFile(relativePath: relativePath),
                    scalesToFill: true,
                    verticalAnchor: 0.5
                ),
                scrim: ThemeScrim(
                    topColor: ThemeColor(hex: "#160B26")!.withAlpha(0.62),
                    bottomColor: ThemeColor(hex: "#120920")!.withAlpha(0.54)
                )
            ))
        }
    }

    /// Every plate the Background gallery can honestly offer: derived from `BuiltInThemes.all`
    /// itself rather than a second hand-maintained list, so a theme added to that catalogue shows up
    /// here automatically and one that's removed can't leave a dangling gallery tile.
    static var availablePlates: [(assetName: String, displayName: String)] {
        BuiltInThemes.all.compactMap { theme in
            guard case .bundled(let name) = theme.surface.backgroundImage?.source else { return nil }
            return (name, theme.name)
        }
    }
}

/// Art-free backgrounds. Both ramps reuse colour values already measured and shipped elsewhere in
/// the theme system rather than inventing new hexes: `.dawn` is the app's own screen gradient
/// (`MochiGradient.background`) and `.dusk` is Cozy Sakura Café's own art-missing fallback ramp —
/// already proven legible by that theme's own validator pass.
enum GradientPreset: String, Codable, Equatable, CaseIterable, Identifiable {
    case dawn, dusk

    var id: String { rawValue }
    var displayName: String { self == .dawn ? "Dawn" : "Dusk" }
    var appearance: ThemeAppearance { self == .dawn ? .light : .dark }

    var stops: [ThemeColor] {
        switch self {
        case .dawn:
            return [
                ThemeColor(red: 0.988, green: 0.851, blue: 0.925),
                ThemeColor(red: 0.902, green: 0.784, blue: 0.949),
                ThemeColor(red: 0.804, green: 0.741, blue: 0.961)
            ]
        case .dusk:
            return [
                ThemeColor(hex: "#221342")!,
                ThemeColor(hex: "#35205E")!,
                ThemeColor(hex: "#4E2C68")!
            ]
        }
    }
}

// MARK: - Key shape

/// Matches the Figma frame's own four chips exactly — no substitution was needed once `KeyView`
/// grew a hexagon mask (see `MochiShared/Theme/ThemeTokens.swift`'s `KeyCapShape`).
enum KeyShapeOption: String, Codable, Equatable, CaseIterable, Identifiable {
    case square, rounded, circle, hexagon

    var id: String { rawValue }
    var displayName: String { rawValue.capitalized }

    /// `nil` inherits `KeyboardMetrics.keyCornerRadius`, which is device-adaptive — "Rounded" is the
    /// one option that should never pin a fixed number. `.circle`'s 999 is intentionally absurd:
    /// `CALayer.cornerRadius` clamps to half the shorter side on its own, so this reliably becomes a
    /// true stadium/circle at every cap size without this file needing to know any of them.
    var cornerRadiusOverride: Double? {
        switch self {
        case .square: return 0
        case .rounded: return nil
        case .circle: return 999
        case .hexagon: return nil
        }
    }

    var capShape: KeyCapShape { self == .hexagon ? .hexagon : .roundedRect }
}

// MARK: - Typography

/// Maps the Figma frame's five chips onto `ThemeTypography`, the token every theme in the app
/// already renders key labels through — see `KeyView.font(for:pointSize:)`. Four of five vary only
/// weight and size: every built-in theme deliberately keeps `fontFamily` `nil` (the system face) for
/// legibility at key-label size, and Create's own presets follow the same rule rather than
/// special-casing themselves out of it. "Handwritten" is the one genuine family change, and only
/// because `KaushanScript-Regular` is registered on **both** targets (see `project.yml`) — every
/// other bundled display face (Fredoka, Baloo2) is app-only, and naming one here would render
/// correctly in this screen's preview and silently fall back to the system face on the real keyboard,
/// which is exactly the "previewed ≠ got" failure this whole system exists to prevent.
enum TypographyOption: String, Codable, Equatable, CaseIterable, Identifiable {
    case `default`, rounded, cute, classic, handwritten

    var id: String { rawValue }
    var displayName: String { rawValue.capitalized }

    var typography: ThemeTypography {
        switch self {
        case .default:
            return ThemeTypography(fontFamily: nil, weightRawValue: 0, sizeMultiplier: 1.0)
        case .rounded:
            return ThemeTypography(fontFamily: nil, weightRawValue: 0.35, sizeMultiplier: 1.0)
        case .cute:
            return ThemeTypography(fontFamily: nil, weightRawValue: 0.15, sizeMultiplier: 1.12)
        case .classic:
            return ThemeTypography(fontFamily: nil, weightRawValue: -0.32, sizeMultiplier: 0.95)
        case .handwritten:
            return ThemeTypography(fontFamily: "KaushanScript-Regular", weightRawValue: 0, sizeMultiplier: 0.9)
        }
    }
}

// MARK: - Effects

/// `ThemeEffects` is rendered for real by `KeyboardSurfaceView`'s `CAEmitterLayer` (see that file) —
/// there is no preview-only stand-in here. Four options to match the visual rhythm of every other
/// 4-chip control on this screen.
enum EffectOption: String, Codable, Equatable, CaseIterable, Identifiable {
    case none, sparkle, snowfall, confetti

    var id: String { rawValue }
    var displayName: String { rawValue.capitalized }

    private var tint: ThemeColor? {
        switch self {
        case .none: return nil
        case .sparkle: return ThemeColor(hex: "#FFE9A8")
        case .snowfall: return ThemeColor(hex: "#F2F6FF")
        case .confetti: return ThemeColor(hex: "#FF5FA8")
        }
    }

    private var baseBirthRate: Double {
        switch self {
        case .none: return 0
        case .sparkle: return 5
        case .snowfall: return 8
        case .confetti: return 11
        }
    }

    /// `intensity` is 0...1 off the slider; `KeyboardSurfaceView.applyEffects` hard-caps the result
    /// again regardless, so nothing here can exceed the renderer's own memory-safe ceiling.
    func effects(intensity: Double) -> ThemeEffects {
        guard self != .none else { return .none }
        let clamped = min(1, max(0, intensity))
        return ThemeEffects(
            isEnabled: true,
            birthRate: baseBirthRate * (0.4 + clamped * 1.6),
            particleImageName: nil,
            tint: tint
        )
    }
}

// MARK: - Derivation

extension ThemeDraft {
    var keyColor: ThemeColor { ThemeColor(hue: keyHue, saturation: keySaturation, brightness: keyBrightness) }
    var letterColor: ThemeColor { ThemeColor(hue: letterHue, saturation: letterSaturation, brightness: letterBrightness) }

    /// The live `MochiKeyboardTheme` — fed straight to `SizedKeyboardThemePreview`, `ThemeStore`, and
    /// `CustomThemeStore`. Pure and cheap enough to call on every keystroke of a colour drag: no
    /// disk or network access happens in here.
    var renderTheme: MochiKeyboardTheme {
        let (appearance, surface) = background.resolvedSurface
        let fill = ThemeFill(keyColor)
        let ink = letterColor

        // Starts from Cozy Sakura Café's own `.input` style so a custom theme's shadow, gloss and
        // (when the shape leaves it on) corner treatment come from an already-authored cap rather
        // than a flat one — only the fields a control on this screen actually owns are overridden.
        var inputStyle = BuiltInThemes.cozySakuraCafe.style(for: .input)
        inputStyle.fill = fill
        inputStyle.labelColor = ink
        inputStyle.pressedFill = nil
        inputStyle.pressedLabelColor = nil
        inputStyle.cornerRadiusOverride = keyShape.cornerRadiusOverride
        inputStyle.capShape = keyShape.capShape
        // A thin rim in the label colour — the same "pale caps separate on their own, mid/dark caps
        // carry a rim" rule the docs on `BuiltInThemes` derive by hand for each authored theme.
        // Here the fill is whatever hue/saturation/brightness the user drags the picker to, which
        // can legitimately land close to the background's own luminance (a light cap over a light
        // background, say) — `ThemeValidator` only waives its cap-vs-background 3:1 check when a
        // border is present, so this is what keeps every colour combination the picker can produce
        // legible without the validator having to reject entire regions of the colour wheel.
        inputStyle.border = ThemeBorder(color: ink.withAlpha(0.5), width: 1.5)

        // System keys read as recessed against the input caps — nudged toward the surface's own
        // base colour rather than toward black/white, so the shift stays consistent whatever hue
        // the user picked.
        var systemStyle = inputStyle
        systemStyle.fill = ThemeFill(keyColor.blended(toward: surface.baseFill.contrastRepresentative, amount: 0.28))

        // The action (return) key gets the one accent nudge on the board: a touch more saturated and
        // shifted slightly around the wheel, the same "one warm key" idea Cozy Sakura Café's own
        // return key uses, just derived from the user's hue instead of hand-picked.
        var actionStyle = inputStyle
        let accentHue = (keyHue + 0.06).truncatingRemainder(dividingBy: 1)
        actionStyle.fill = ThemeFill(ThemeColor(
            hue: accentHue,
            saturation: min(1, keySaturation + 0.25),
            brightness: keyBrightness
        ))

        let spaceStyle = inputStyle

        return MochiKeyboardTheme(
            id: id,
            name: name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Untitled Theme" : name,
            authorName: nil,
            appearance: appearance,
            surface: surface,
            keyStyles: [.input: inputStyle, .system: systemStyle, .action: actionStyle, .space: spaceStyle],
            typography: typography.typography,
            chrome: nil,
            keyArt: nil,
            effects: effect.effects(intensity: effectIntensity)
        )
    }

    /// The legacy Firestore shape `CreateRepository`/`ThemeDocument` already understand. Kept
    /// alongside `renderTheme` (never derived *from* it) so the eventual backend write and the
    /// theme that's actually live in this app agree on what the user configured.
    var backgroundConfig: BackgroundConfig {
        switch background {
        case .gradient(let preset):
            let hex = preset.stops.map(\.hexString)
            return BackgroundConfig(
                gradientStartColor: hex.first ?? "#FFFFFF",
                gradientEndColor: hex.last ?? "#FFFFFF",
                gradientDirection: "vertical",
                galleryImageUrl: ""
            )
        case .solid(let hue, let saturation, let brightness):
            return BackgroundConfig(solidColor: ThemeColor(hue: hue, saturation: saturation, brightness: brightness).hexString)
        case .plate(let assetName, _):
            return BackgroundConfig(galleryImageUrl: "bundled:\(assetName)")
        case .photo(let relativePath):
            return BackgroundConfig(galleryImageUrl: "local:\(relativePath)")
        }
    }

    var keysConfig: KeysConfig {
        KeysConfig(shape: keyShape.rawValue, fillColor: keyColor.hexString, borderWidth: 0, borderColor: "#000000", hasShadow: true)
    }

    var fontsConfig: FontsConfig {
        FontsConfig(fontId: typography.rawValue, textColor: letterColor.hexString, sizePercent: 100, isBold: false)
    }

    var effectsConfig: EffectsConfig {
        EffectsConfig(
            keyPressEffect: "none",
            backgroundEffect: effect == .none ? "none" : effect.rawValue,
            trailEffect: "none"
        )
    }
}
