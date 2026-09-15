import CoreGraphics
#if canImport(UIKit)
import UIKit
#endif

/// A colour as a theme document stores it: sRGB channels plus alpha, serialised as a hex string.
///
/// This is deliberately *not* `UIColor`. A theme is a document that gets written by the Create
/// screen, stored in Firestore, synced through an App Group and re-read by a different process —
/// it has to round-trip through JSON losslessly and compare equal afterwards. `UIColor` is a
/// class with colour-space behaviour that does neither.
///
/// Everything is sRGB. Not P3: the same theme has to look identical in the in-app preview and in
/// the keyboard extension across every device, and pinning one colour space is the only way to
/// guarantee that. A wide-gamut theme would also make the contrast maths below wrong.
struct ThemeColor: Codable, Equatable, Hashable {
    /// 0…1, sRGB, **not** premultiplied.
    var red: Double
    var green: Double
    var blue: Double
    var alpha: Double

    /// Channels are quantised to 8 bits on the way in.
    ///
    /// Not a rounding convenience — a correctness requirement. Themes are stored as hex, which is
    /// 8-bit, so an unquantised `alpha: 0.94` becomes `0.9412` after a save/load cycle and the
    /// value the extension renders stops being equal to the value the app wrote. That breaks
    /// document equality, breaks "did the theme change?" checks, and makes round-trip tests
    /// unfalsifiable. Quantising at construction makes every `ThemeColor` exactly representable in
    /// its own storage format. Displays are 8-bit per channel anyway, so nothing visible is lost.
    init(red: Double, green: Double, blue: Double, alpha: Double = 1) {
        func quantise(_ value: Double) -> Double {
            (value.clamped01 * 255).rounded() / 255
        }
        self.red = quantise(red)
        self.green = quantise(green)
        self.blue = quantise(blue)
        self.alpha = quantise(alpha)
    }

    /// `#RRGGBB` or `#RRGGBBAA`. The leading `#` is optional and case does not matter.
    init?(hex: String) {
        var raw = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if raw.hasPrefix("#") { raw.removeFirst() }
        guard raw.count == 6 || raw.count == 8, let value = UInt64(raw, radix: 16) else { return nil }

        let hasAlpha = raw.count == 8
        let shift = hasAlpha ? 8 : 0
        self.init(
            red: Double((value >> (16 + shift)) & 0xFF) / 255,
            green: Double((value >> (8 + shift)) & 0xFF) / 255,
            blue: Double((value >> shift) & 0xFF) / 255,
            alpha: hasAlpha ? Double(value & 0xFF) / 255 : 1
        )
    }

    var hexString: String {
        let channels = [red, green, blue, alpha].map { UInt8(($0 * 255).rounded()) }
        return alpha >= 1
            ? String(format: "#%02X%02X%02X", channels[0], channels[1], channels[2])
            : String(format: "#%02X%02X%02X%02X", channels[0], channels[1], channels[2], channels[3])
    }

    // MARK: - Codable

    /// Encoded as a bare hex string rather than an object, so a theme document stays readable and
    /// diffable by a human — `"tint": "#2B1B4Fcc"` instead of four floats. Decoding accepts the
    /// object form too, because that is what a colour picker most naturally produces and there is
    /// no reason to make the Create screen convert before it can save a draft.
    init(from decoder: Decoder) throws {
        if let single = try? decoder.singleValueContainer(), let hex = try? single.decode(String.self) {
            guard let parsed = ThemeColor(hex: hex) else {
                throw DecodingError.dataCorruptedError(
                    in: single,
                    debugDescription: "'\(hex)' is not #RRGGBB or #RRGGBBAA"
                )
            }
            self = parsed
            return
        }
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.init(
            red: try container.decode(Double.self, forKey: .red),
            green: try container.decode(Double.self, forKey: .green),
            blue: try container.decode(Double.self, forKey: .blue),
            alpha: try container.decodeIfPresent(Double.self, forKey: .alpha) ?? 1
        )
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(hexString)
    }

    private enum CodingKeys: String, CodingKey { case red, green, blue, alpha }
}

// MARK: - Platform bridging

/// Guarded so the theme model — including the contrast maths below, which is the part most worth
/// testing — compiles and runs on any platform with plain Foundation. `Tools/validate-themes.swift`
/// relies on this to check every built-in theme without a simulator.
#if canImport(UIKit)
extension ThemeColor {
    var uiColor: UIColor {
        UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }

    /// Opaque `CGColor` in sRGB. Used for layer fills where the alpha is carried by the layer's
    /// own `opacity` instead, so that a single animatable property drives press feedback.
    var cgColor: CGColor {
        uiColor.cgColor
    }

    /// The other direction of the bridge above — for reading back whatever a system colour control
    /// (SwiftUI's `ColorPicker`, which includes a real eyedropper tool) handed the Create screen.
    init(uiColor: UIColor) {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        uiColor.getRed(&r, green: &g, blue: &b, alpha: &a)
        self.init(red: Double(r), green: Double(g), blue: Double(b), alpha: Double(a))
    }
}
#endif

extension ThemeColor {
    /// `hue`/`saturation`/`brightness` in 0...1 (hue wraps — pass anything and it is normalised into
    /// range). Added for the Create screen's saturation-square-and-hue-rail picker, which is an HSB
    /// control by construction; everywhere else in the theme system stays sRGB, so this is the one
    /// conversion boundary rather than a second colour representation spreading through the model.
    init(hue: Double, saturation: Double, brightness: Double, alpha: Double = 1) {
        let h = hue - floor(hue)
        let s = saturation.clamped01
        let v = brightness.clamped01
        let sector = Int(h * 6)
        let fraction = h * 6 - Double(sector)
        let p = v * (1 - s)
        let q = v * (1 - fraction * s)
        let t = v * (1 - (1 - fraction) * s)
        let (r, g, b): (Double, Double, Double)
        switch sector % 6 {
        case 0: (r, g, b) = (v, t, p)
        case 1: (r, g, b) = (q, v, p)
        case 2: (r, g, b) = (p, v, t)
        case 3: (r, g, b) = (p, q, v)
        case 4: (r, g, b) = (t, p, v)
        default: (r, g, b) = (v, p, q)
        }
        self.init(red: r, green: g, blue: b, alpha: alpha)
    }

    /// The inverse of the initialiser above. Used to seed a picker's knob position from a colour
    /// that arrived by some other route (the system colour picker's eyedropper, a tapped RECENT
    /// swatch), so the square and rail always agree with whatever colour is actually current instead
    /// of silently resetting to wherever they last were.
    var hsbComponents: (hue: Double, saturation: Double, brightness: Double) {
        let maxC = max(red, green, blue)
        let minC = min(red, green, blue)
        let delta = maxC - minC
        let brightness = maxC
        let saturation = maxC <= 0 ? 0 : delta / maxC
        guard delta > 0.0001 else { return (0, saturation, brightness) }

        var hue: Double
        if maxC == red {
            hue = ((green - blue) / delta).truncatingRemainder(dividingBy: 6)
        } else if maxC == green {
            hue = (blue - red) / delta + 2
        } else {
            hue = (red - green) / delta + 4
        }
        hue /= 6
        if hue < 0 { hue += 1 }
        return (hue, saturation, brightness)
    }

    func withAlpha(_ newAlpha: Double) -> ThemeColor {
        ThemeColor(red: red, green: green, blue: blue, alpha: newAlpha)
    }

    /// Linear interpolation toward another colour in sRGB. Good enough for the small nudges the
    /// renderer makes (a pressed key darkening, a gradient's second stop); anything larger should
    /// be authored as an explicit token rather than computed.
    func blended(toward other: ThemeColor, amount: Double) -> ThemeColor {
        let t = amount.clamped01
        return ThemeColor(
            red: red + (other.red - red) * t,
            green: green + (other.green - green) * t,
            blue: blue + (other.blue - blue) * t,
            alpha: alpha + (other.alpha - alpha) * t
        )
    }
}

// MARK: - Contrast

extension ThemeColor {
    /// WCAG 2.1 relative luminance. This exact formula is what Apple's own "Sufficient Contrast"
    /// App Store accessibility criterion is defined against, so using anything else here would
    /// let a theme pass our validator and still fail Apple's.
    var relativeLuminance: Double {
        func linearise(_ channel: Double) -> Double {
            channel <= 0.03928 ? channel / 12.92 : pow((channel + 0.055) / 1.055, 2.4)
        }
        return 0.2126 * linearise(red) + 0.7152 * linearise(green) + 0.0722 * linearise(blue)
    }

    /// WCAG contrast ratio, 1…21. Both colours must already be opaque — see `composited(over:)`.
    ///
    /// Passing a translucent colour here is the classic way to get a number that looks fine and
    /// describes nothing, because the ratio would be computed against a colour the user never
    /// sees. `ThemeValidator` always flattens first.
    func contrastRatio(against other: ThemeColor) -> Double {
        let a = relativeLuminance
        let b = other.relativeLuminance
        let lighter = max(a, b)
        let darker = min(a, b)
        return (lighter + 0.05) / (darker + 0.05)
    }

    /// Flattens `self` onto an opaque backdrop using source-over, producing the colour actually
    /// shown on screen. Every contrast check in the theme system runs on the output of this.
    func composited(over backdrop: ThemeColor) -> ThemeColor {
        guard alpha < 1 else { return self }
        let a = alpha
        return ThemeColor(
            red: red * a + backdrop.red * (1 - a),
            green: green * a + backdrop.green * (1 - a),
            blue: blue * a + backdrop.blue * (1 - a),
            alpha: 1
        )
    }
}

private extension Double {
    var clamped01: Double { Swift.min(1, Swift.max(0, self)) }
}
