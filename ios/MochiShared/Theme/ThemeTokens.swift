import CoreGraphics
import Foundation

// MARK: - Appearance

/// Which end of the light/dark spectrum the theme's surface sits at.
///
/// This is not decoration. The keyboard has to hand a `UIKeyboardAppearance`-shaped answer to a
/// few system-adjacent details (the caps-lock indicator, the selection colour of any accessory
/// row), and a theme with a near-black background needs the opposite treatment from a pastel one.
/// Deriving it from the background colour's luminance was the first approach and it was wrong for
/// art-backed themes, where the *art* is dark but the key caps are light — the author is the one
/// who knows which reading is intended, so it is an authored token.
enum ThemeAppearance: String, Codable, Equatable, CaseIterable {
    case light
    case dark
}

// MARK: - Fills

/// A fill for any themed surface: one colour is flat, two or more is a linear gradient.
///
/// Flat key caps are what makes a themed keyboard look cheap — the system keyboard's caps carry a
/// very slight vertical ramp, and matching that is most of the difference between "premium" and
/// "sticker pasted on a photo". Modelling solid as the one-stop case of a gradient means the
/// renderer has exactly one code path instead of a branch that will drift.
struct ThemeFill: Codable, Equatable {
    /// Top-to-bottom by default; see `angleDegrees`.
    var stops: [ThemeColor]
    /// 0° = left→right, 90° = top→bottom. Defaults to vertical, which is what key caps want.
    var angleDegrees: Double

    init(stops: [ThemeColor], angleDegrees: Double = 90) {
        self.stops = stops.isEmpty ? [ThemeColor(red: 0, green: 0, blue: 0, alpha: 0)] : stops
        self.angleDegrees = angleDegrees
    }

    init(_ solid: ThemeColor) {
        self.init(stops: [solid])
    }

    var isSolid: Bool { stops.count == 1 }

    /// The single colour a contrast check should treat this fill as. Uses the *last* stop rather
    /// than an average because these ramps run light-to-dark top-to-bottom, so the bottom stop is
    /// the worst case for a dark label — and a legibility check is only worth having if it
    /// measures the worst case.
    var contrastRepresentative: ThemeColor {
        stops.count == 1 ? stops[0] : (stops.min(by: { $0.relativeLuminance < $1.relativeLuminance }) ?? stops[0])
    }

    init(from decoder: Decoder) throws {
        // A bare hex string decodes as a solid fill, so the common case stays terse in JSON.
        if let single = try? decoder.singleValueContainer(), let color = try? single.decode(ThemeColor.self) {
            self.init(color)
            return
        }
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.init(
            stops: try container.decode([ThemeColor].self, forKey: .stops),
            angleDegrees: try container.decodeIfPresent(Double.self, forKey: .angleDegrees) ?? 90
        )
    }

    private enum CodingKeys: String, CodingKey { case stops, angleDegrees }
}

// MARK: - Key decoration

struct ThemeBorder: Codable, Equatable {
    var color: ThemeColor
    /// In points. Hairlines should be authored as `1.0 / 3.0`-ish values only if the intent is a
    /// true device pixel; the renderer does not snap this for you.
    var width: Double

    init(color: ThemeColor, width: Double) {
        self.color = color
        self.width = max(0, width)
    }
}

/// A drop shadow under a key cap.
///
/// Kept deliberately narrow — colour, opacity, radius, y-offset. No spread, no x-offset. A
/// keyboard is lit from directly above by convention on every platform, and every extra degree of
/// freedom here is one more way for a user-authored theme to produce something that reads as
/// broken rather than styled.
struct ThemeShadow: Codable, Equatable {
    var color: ThemeColor
    var opacity: Double
    var radius: Double
    var offsetY: Double

    init(color: ThemeColor, opacity: Double, radius: Double, offsetY: Double) {
        self.color = color
        self.opacity = opacity.clamped01
        self.radius = max(0, radius)
        self.offsetY = offsetY
    }

    static let none = ThemeShadow(
        color: ThemeColor(red: 0, green: 0, blue: 0),
        opacity: 0,
        radius: 0,
        offsetY: 0
    )
}

/// The treatment that turns a rounded rectangle into a pane of glass.
///
/// A flat gradient plus a border reads as a coloured box no matter how well the colours are
/// chosen — which is exactly what the first pass of Fantasy Castle Night looked like. Real glass
/// is legible from two cues the fill cannot provide:
///
/// * an **inner bevel** — a bright hairline just inside the top edge, where the pane's thickness
///   catches light from above, fading as it wraps down the sides;
/// * an **inner shadow** at the bottom, where that same thickness occludes light.
///
/// Together they imply a solid with depth rather than a painted region. Both are drawn *over* the
/// key's artwork, because the edge of a pane is in front of whatever sits inside it.
struct KeyGlass: Codable, Equatable {
    var bevelColor: ThemeColor
    var bevelWidth: Double
    /// How far down the cap the bevel stays visible, as a fraction of height. Short values read as
    /// a sharp glint; longer ones as a thicker, softer pane.
    var bevelFalloff: Double
    var innerShadowColor: ThemeColor
    var innerShadowOpacity: Double
    var innerShadowRadius: Double

    init(
        bevelColor: ThemeColor,
        bevelWidth: Double = 1,
        bevelFalloff: Double = 0.55,
        innerShadowColor: ThemeColor,
        innerShadowOpacity: Double = 0.35,
        innerShadowRadius: Double = 3
    ) {
        self.bevelColor = bevelColor
        self.bevelWidth = max(0, bevelWidth)
        self.bevelFalloff = min(1, max(0.05, bevelFalloff))
        self.innerShadowColor = innerShadowColor
        self.innerShadowOpacity = innerShadowOpacity.clamped01
        self.innerShadowRadius = max(0, innerShadowRadius)
    }
}

// MARK: - Key roles and styles

/// The four visual roles a key can have. Layout decides which keys get which role; the theme
/// decides what each role looks like.
///
/// Four rather than one style per key, because a theme has to survive being applied to layouts it
/// was not authored against — a numeric plane, an emoji plane, a locale whose layout has an extra
/// key. Roles are stable across all of those; per-key styling would not be.
enum KeyRole: String, Codable, Equatable, CaseIterable {
    /// Letters, digits, punctuation — the keys that insert text.
    case input
    /// Shift, backspace, plane switch (`123` / `ABC`), globe, dictation.
    case system
    /// Return / Go / Search. The one key the system tints as primary.
    case action
    /// The space bar. Its own role because it is the widest surface on the keyboard and the one
    /// most likely to need a different treatment from a 32pt-wide letter cap.
    case space
}

/// The cap's outer silhouette.
///
/// Separate from `cornerRadiusOverride`, which only ever bends a rectangle rounder or squarer — a
/// hexagon is a different polygon, not an extreme radius, and needs its own mask rather than a
/// number. `KeyView` only allocates the extra `CAShapeLayer` masks a non-rectangular shape needs
/// when one is actually in play, so every existing rounded-rect theme (which is all of them today)
/// pays nothing for this case existing.
enum KeyCapShape: String, Codable, Equatable, CaseIterable {
    case roundedRect
    case hexagon
}

/// How one key role looks, in both its resting and pressed states.
struct KeyStyle: Codable, Equatable {
    var fill: ThemeFill
    var labelColor: ThemeColor

    /// Resolved to a darkened/lightened `fill` when absent — see `KeyStyle.resolvedPressedFill`.
    var pressedFill: ThemeFill?
    var pressedLabelColor: ThemeColor?

    var border: ThemeBorder?
    var shadow: ThemeShadow

    /// A one-point light line inset along the cap's top edge. This is the single cheapest thing
    /// that separates a premium key from a rounded rectangle: it reads as a bevel catching light
    /// and it costs one extra sublayer. `nil` disables it.
    var topHighlight: ThemeColor?

    /// Overrides `KeyboardMetrics.keyCornerRadius` when set. Themes should usually leave this nil
    /// and inherit the metrics value, which is device-adaptive; set it only when the theme's
    /// identity genuinely depends on a rounder or squarer cap.
    var cornerRadiusOverride: Double?

    /// Bevel and inner shadow. `nil` leaves the cap flat, which is right for themes whose keys are
    /// meant to read as paint rather than glass.
    var glass: KeyGlass?

    /// `nil` decodes as `.roundedRect` — see `resolvedCapShape`. Optional rather than defaulted in
    /// a custom decoder so every existing stored theme (none of which have ever heard of a
    /// non-rectangular cap) keeps decoding through the compiler-synthesised `Codable` unchanged.
    var capShape: KeyCapShape?

    var resolvedCapShape: KeyCapShape { capShape ?? .roundedRect }

    init(
        fill: ThemeFill,
        labelColor: ThemeColor,
        pressedFill: ThemeFill? = nil,
        pressedLabelColor: ThemeColor? = nil,
        border: ThemeBorder? = nil,
        shadow: ThemeShadow = .none,
        topHighlight: ThemeColor? = nil,
        cornerRadiusOverride: Double? = nil,
        glass: KeyGlass? = nil,
        capShape: KeyCapShape? = nil
    ) {
        self.fill = fill
        self.labelColor = labelColor
        self.pressedFill = pressedFill
        self.pressedLabelColor = pressedLabelColor
        self.border = border
        self.shadow = shadow
        self.topHighlight = topHighlight
        self.cornerRadiusOverride = cornerRadiusOverride
        self.glass = glass
        self.capShape = capShape
    }

    /// The pressed appearance, derived when the theme does not author one.
    ///
    /// The system keyboard's pressed state moves *toward the background* — a light cap on a light
    /// keyboard darkens, a dark cap lightens. Deriving it from the cap's own luminance rather than
    /// always darkening is what keeps the feedback visible on a theme with near-black caps, where
    /// "darker" would be no feedback at all.
    var resolvedPressedFill: ThemeFill {
        if let pressedFill { return pressedFill }
        let isDarkCap = fill.contrastRepresentative.relativeLuminance < 0.5
        let target = ThemeColor(
            red: isDarkCap ? 1 : 0,
            green: isDarkCap ? 1 : 0,
            blue: isDarkCap ? 1 : 0,
            alpha: fill.contrastRepresentative.alpha
        )
        return ThemeFill(
            stops: fill.stops.map { $0.blended(toward: target, amount: 0.18) },
            angleDegrees: fill.angleDegrees
        )
    }

    var resolvedPressedLabelColor: ThemeColor { pressedLabelColor ?? labelColor }
}

// MARK: - Surface

/// Where a theme's background art comes from.
///
/// Split into two cases because they have different failure modes and different memory costs.
/// A bundled asset ships with the app and cannot go missing; a file lives in the App Group
/// container, was downloaded or created by the user, and absolutely can be missing when the
/// keyboard tries to draw — which is why `ThemeSurface.baseColor` is not optional.
enum ThemeImageSource: Codable, Equatable {
    /// An `Assets.xcassets` image name compiled into both targets.
    case bundled(name: String)
    /// A path relative to the App Group container root, e.g. `themes/cozy-sakura-cafe/bg@3x.heic`.
    case appGroupFile(relativePath: String)

    private enum CodingKeys: String, CodingKey { case kind, value }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let kind = try container.decode(String.self, forKey: .kind)
        let value = try container.decode(String.self, forKey: .value)
        switch kind {
        case "bundled": self = .bundled(name: value)
        case "appGroupFile": self = .appGroupFile(relativePath: value)
        default:
            throw DecodingError.dataCorruptedError(
                forKey: .kind,
                in: container,
                debugDescription: "unknown image source '\(kind)'"
            )
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .bundled(let name):
            try container.encode("bundled", forKey: .kind)
            try container.encode(name, forKey: .value)
        case .appGroupFile(let path):
            try container.encode("appGroupFile", forKey: .kind)
            try container.encode(path, forKey: .value)
        }
    }
}

/// The background art layer.
struct ThemeBackgroundImage: Codable, Equatable {
    var source: ThemeImageSource
    /// `true` scales to fill and crops; `false` fits inside and lets `baseColor` show through.
    /// Fill is almost always right for a keyboard — the aspect ratio varies enough across devices
    /// that fit leaves visible bars on something.
    var scalesToFill: Bool
    /// Vertical focus point, 0 = top of the art, 1 = bottom. Because the keyboard is a wide, short
    /// window onto a taller image, *which* horizontal band survives the crop is the single most
    /// important framing decision, and it differs per artwork.
    var verticalAnchor: Double
    /// Gaussian blur applied once at decode time, in points at the final drawn size.
    ///
    /// Blurring the art is the honest way to buy legibility on a busy background. It is done at
    /// decode rather than with a live `UIVisualEffectView` because the extension only has to pay
    /// for it once per theme load instead of once per frame.
    var blurRadius: Double

    init(
        source: ThemeImageSource,
        scalesToFill: Bool = true,
        verticalAnchor: Double = 0.5,
        blurRadius: Double = 0
    ) {
        self.source = source
        self.scalesToFill = scalesToFill
        self.verticalAnchor = verticalAnchor.clamped01
        self.blurRadius = max(0, blurRadius)
    }
}

/// The layer between the background art and the keys.
///
/// This is the piece that makes an art-backed keyboard readable, and it is why this system is not
/// a wallpaper overlay. Without it, legibility is a property of whatever the artwork happens to
/// look like behind a given key; with it, legibility is a property of the theme and can be
/// validated before the theme ever ships.
struct ThemeScrim: Codable, Equatable {
    var topColor: ThemeColor
    var bottomColor: ThemeColor

    init(topColor: ThemeColor, bottomColor: ThemeColor) {
        self.topColor = topColor
        self.bottomColor = bottomColor
    }

    init(flat color: ThemeColor) {
        self.init(topColor: color, bottomColor: color)
    }

    static let none = ThemeScrim(flat: ThemeColor(red: 0, green: 0, blue: 0, alpha: 0))

    /// The scrim as a contrast check must treat it: the more transparent end, since that is where
    /// the background art shows through most and legibility is most at risk.
    var weakestColor: ThemeColor { topColor.alpha <= bottomColor.alpha ? topColor : bottomColor }
}

struct ThemeSurface: Codable, Equatable {
    /// Drawn under everything, always.
    ///
    /// A fill rather than a flat colour for two reasons. It doubles as the fallback when
    /// `backgroundImage` is missing, and a flat fallback looks like an error state where a gradient
    /// looks deliberate. It also means a theme can be genuinely good-looking with **no art at
    /// all** — which is what stops the system from degenerating into "pick a photo", and gives the
    /// Create screen a cheap, always-available starting point.
    var baseFill: ThemeFill
    var backgroundImage: ThemeBackgroundImage?
    var scrim: ThemeScrim

    init(baseFill: ThemeFill, backgroundImage: ThemeBackgroundImage? = nil, scrim: ThemeScrim = .none) {
        self.baseFill = baseFill
        self.backgroundImage = backgroundImage
        self.scrim = scrim
    }

    /// The opaque colour that sits immediately behind a key cap once base + scrim are composited.
    /// Background *art* is deliberately excluded: its local luminance varies per pixel and cannot
    /// be reduced to one number, which is the whole reason the scrim exists.
    var effectiveKeyBackdrop: ThemeColor {
        scrim.weakestColor.composited(over: baseFill.contrastRepresentative)
    }
}

// MARK: - Typography

struct ThemeTypography: Codable, Equatable {
    /// A family name registered by *both* targets, or `nil` for the system face.
    ///
    /// A custom font used by the keyboard must be listed in the **extension's** `UIAppFonts`, not
    /// only the app's — the two are separate bundles and the extension does not inherit the app's
    /// registrations. A missing family here falls back to the system face rather than failing.
    var fontFamily: String?
    /// UIFont.Weight raw value (-1…1). Stored as the raw double so the document does not depend on
    /// a UIKit enum's case names.
    var weightRawValue: Double
    /// Scales `KeyboardMetrics.inputLabelPointSize`. Clamped by the renderer so a theme cannot set
    /// a size that overflows the cap.
    var sizeMultiplier: Double

    init(fontFamily: String? = nil, weightRawValue: Double = 0, sizeMultiplier: Double = 1) {
        self.fontFamily = fontFamily
        self.weightRawValue = weightRawValue
        self.sizeMultiplier = min(1.35, max(0.75, sizeMultiplier))
    }
}

// MARK: - Key artwork

/// Nudges one illustration off the placement every other key in the set uses.
///
/// Thirty-three illustrations drawn by different passes of an image model do not share a common
/// margin, subject scale, or centre of mass, and no single set-wide `heightFraction` can be right
/// for all of them. This is the escape hatch for the handful that need it — and, unlike the rest of
/// the theme, it is genuinely per-key for the same reason `artIdentity` is: the whole point is that
/// `Q` gets a moon and `W` gets a castle, and a moon is not framed like a castle.
///
/// Every field is a **delta from the default placement**, so `.identity` is the no-op and a theme
/// only stores the keys someone actually moved. Offsets are fractions of the cap's own size rather
/// than points, so a placement authored on one device stays correct on every other width.
struct KeyArtPlacement: Codable, Equatable {
    /// Fraction of cap **width**. Positive moves the illustration right.
    var offsetX: Double
    /// Fraction of cap **height**. Positive moves it down.
    var offsetY: Double
    /// Multiplier on the art band's size. Above 1 pushes more of the illustration past the cap's
    /// edges, where the rounded clip trims it — which is the intended look, not an accident.
    var scale: Double
    /// Absolute opacity for this one key. `nil` inherits `KeyArtSet.opacity`, which is what keeps a
    /// placement that only moves a motif from silently pinning its opacity to whatever the set
    /// happened to be at the time it was authored.
    var opacity: Double?
    /// -1...1, 0 (or `nil`) is unchanged. Positive lightens the illustration (a white overlay,
    /// screen-like), negative darkens it (a black overlay, multiply-like). A cheap alpha-blend
    /// rather than a true Core Image brightness filter — this is a per-key cosmetic knob dialled
    /// once at authoring time, not a per-frame effect, and the extension's memory ceiling rules
    /// out routing every key through Core Image just for this.
    var brightness: Double?

    init(offsetX: Double = 0, offsetY: Double = 0, scale: Double = 1, opacity: Double? = nil, brightness: Double? = nil) {
        // Clamped rather than trusted. These come from a slider in the tweak lab and end up in a
        // stored document; a scale of 0 would silently delete an illustration and a scale of 40
        // would decode a bitmap large enough to matter under the extension's memory ceiling.
        self.offsetX = min(1, max(-1, offsetX))
        self.offsetY = min(1, max(-1, offsetY))
        self.scale = min(3, max(0.2, scale))
        self.opacity = opacity.map { min(1, max(0, $0)) }
        self.brightness = brightness.map { min(1, max(-1, $0)) }
    }

    static let identity = KeyArtPlacement()

    var isIdentity: Bool { self == .identity }
}

/// Per-key illustrations drawn inside the cap, beneath the label.
///
/// Addressed by a **stable key identity string** (`"q"`, `"shift"`, `"space"`) rather than by role,
/// because this is the one part of a theme that genuinely is per-key: the whole point is that `Q`
/// gets a moon and `W` gets a castle. Roles cannot express that.
///
/// Assets are resolved as `assetPrefix + identity`, so one theme's art lives under one prefix and
/// adding a theme never risks colliding with another's asset names.
struct KeyArtSet: Codable, Equatable {
    /// e.g. `"keyart_fcn_"`.
    var assetPrefix: String
    /// Fraction of the cap's height the artwork occupies, measured up from the bottom edge.
    ///
    /// The label is lifted by roughly half this when art is present — see `KeyView`. Art and ink
    /// sharing the same vertical centre is the fastest way to make a key illegible, and it is a
    /// failure the contrast validator cannot see, because it measures ink against the cap *fill*
    /// and knows nothing about a picture drawn in between.
    var heightFraction: Double
    /// Inset from the cap's bottom edge, as a fraction of cap height.
    var bottomInsetFraction: Double
    /// Global opacity. Below 1 lets the cap gradient show through the art, which is what stops the
    /// illustrations reading as stickers pasted on top.
    var opacity: Double
    /// Keys whose artwork fills the whole cap instead of being bottom-anchored. The space bar's
    /// panorama is the reason this exists.
    var fillKeys: Set<String>
    /// How far above centre the label sits, as a fraction of cap height, when this key has art.
    var labelLiftFraction: Double
    /// Per-key overrides, keyed by `KeyDefinition.artIdentity`. Absent keys use the set's defaults.
    ///
    /// Sparse on purpose — a theme stores only the illustrations someone actually moved, so reading
    /// this dictionary tells you which motifs needed special handling and which sat correctly on the
    /// set-wide values. Authored in the DEBUG art tweak lab and pasted back here as source.
    var placements: [String: KeyArtPlacement]

    init(
        assetPrefix: String,
        heightFraction: Double = 0.55,
        bottomInsetFraction: Double = 0.04,
        opacity: Double = 1.0,
        fillKeys: Set<String> = ["space"],
        labelLiftFraction: Double = 0.07,
        placements: [String: KeyArtPlacement] = [:]
    ) {
        self.assetPrefix = assetPrefix
        self.heightFraction = min(1, max(0.1, heightFraction))
        self.bottomInsetFraction = min(0.4, max(0, bottomInsetFraction))
        self.opacity = min(1, max(0, opacity))
        self.fillKeys = fillKeys
        self.labelLiftFraction = min(0.3, max(0, labelLiftFraction))
        // Identity entries are dropped rather than stored. A tweak session that opens a key, moves
        // it and moves it back would otherwise leave a no-op entry behind, and those accumulate into
        // a dictionary that implies intent where there is none.
        self.placements = placements.filter { !$0.value.isIdentity }
    }

    /// Decoded leniently so that themes authored before `placements` existed keep decoding — the
    /// same contract every other optional token in this document has.
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.init(
            assetPrefix: try container.decode(String.self, forKey: .assetPrefix),
            heightFraction: try container.decodeIfPresent(Double.self, forKey: .heightFraction) ?? 0.55,
            bottomInsetFraction: try container.decodeIfPresent(Double.self, forKey: .bottomInsetFraction) ?? 0.04,
            opacity: try container.decodeIfPresent(Double.self, forKey: .opacity) ?? 1.0,
            fillKeys: try container.decodeIfPresent(Set<String>.self, forKey: .fillKeys) ?? ["space"],
            labelLiftFraction: try container.decodeIfPresent(Double.self, forKey: .labelLiftFraction) ?? 0.07,
            placements: try container.decodeIfPresent([String: KeyArtPlacement].self, forKey: .placements) ?? [:]
        )
    }

    private enum CodingKeys: String, CodingKey {
        case assetPrefix, heightFraction, bottomInsetFraction, opacity, fillKeys, labelLiftFraction, placements
    }

    func assetName(for identity: String) -> String { assetPrefix + identity }

    /// The placement to draw `identity` with. Never `nil` — an untouched key draws at identity.
    func placement(for identity: String) -> KeyArtPlacement {
        placements[identity] ?? .identity
    }

    /// The opacity `identity` actually draws at, after any per-key override.
    func resolvedOpacity(for identity: String) -> Double {
        placement(for: identity).opacity ?? opacity
    }

    /// The brightness `identity` actually draws at. No set-wide default exists — every key is
    /// unadjusted (0) unless its own placement says otherwise.
    func resolvedBrightness(for identity: String) -> Double {
        placement(for: identity).brightness ?? 0
    }
}

// MARK: - Chrome

/// Styling for the surfaces that are not keys: the suggestion bar, the emoji panel and its
/// category strip, and the accent callout.
///
/// These need their own tokens because their ink sits directly on the keyboard *surface*, not on a
/// key cap. A theme whose labels are near-black because its caps are pale would be illegible if
/// that same colour were reused for the suggestion bar, which has the dark background art behind
/// it instead. Every value defaults from `ThemeAppearance`, so themes authored before this existed
/// keep decoding and still look deliberate.
struct ThemeChrome: Codable, Equatable {
    /// Suggestion text, category icons, callout labels.
    var inkColor: ThemeColor
    /// Separators and the de-emphasised end of the category strip.
    var mutedInkColor: ThemeColor
    /// Fill behind the emoji panel and the accent callout. Usually translucent so the theme's
    /// background still reads through it.
    var panelFill: ThemeFill
    /// Behind the pressed suggestion and the selected emoji category.
    var highlightFill: ThemeFill

    init(
        inkColor: ThemeColor,
        mutedInkColor: ThemeColor,
        panelFill: ThemeFill,
        highlightFill: ThemeFill
    ) {
        self.inkColor = inkColor
        self.mutedInkColor = mutedInkColor
        self.panelFill = panelFill
        self.highlightFill = highlightFill
    }

    static func `default`(for appearance: ThemeAppearance) -> ThemeChrome {
        let isDark = appearance == .dark
        let ink = ThemeColor(
            red: isDark ? 0.96 : 0.08,
            green: isDark ? 0.94 : 0.07,
            blue: isDark ? 1.0 : 0.12
        )
        return ThemeChrome(
            inkColor: ink,
            mutedInkColor: ink.withAlpha(0.55),
            panelFill: ThemeFill(ThemeColor(
                red: isDark ? 0.10 : 0.98,
                green: isDark ? 0.06 : 0.97,
                blue: isDark ? 0.18 : 1.0,
                alpha: 0.55
            )),
            highlightFill: ThemeFill(ThemeColor(
                red: isDark ? 1 : 0,
                green: isDark ? 1 : 0,
                blue: isDark ? 1 : 0,
                alpha: 0.16
            ))
        )
    }
}

// MARK: - Effects

/// Ambient particle effects. Declared now, rendered later.
///
/// The token exists in v1 because adding a field to a stored document format after themes are in
/// users' hands is a migration, while leaving a documented, defaulted field unused costs nothing.
/// The renderer currently ignores everything here except `isEnabled == false`, which is the
/// default. TRD ADR-002 fixes the eventual implementation as `CAEmitterLayer`, not SpriteKit.
struct ThemeEffects: Codable, Equatable {
    var isEnabled: Bool
    /// Particles per second across the whole keyboard. Capped hard by the renderer when this is
    /// wired up; a keyboard has a ~30–48 MB budget and particle buffers are retained per emitter.
    var birthRate: Double
    var particleImageName: String?
    var tint: ThemeColor?

    init(isEnabled: Bool = false, birthRate: Double = 0, particleImageName: String? = nil, tint: ThemeColor? = nil) {
        self.isEnabled = isEnabled
        self.birthRate = max(0, birthRate)
        self.particleImageName = particleImageName
        self.tint = tint
    }

    static let none = ThemeEffects()
}

private extension Double {
    var clamped01: Double { Swift.min(1, Swift.max(0, self)) }
}
