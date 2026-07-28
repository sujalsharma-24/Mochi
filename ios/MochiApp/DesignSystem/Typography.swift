import SwiftUI
import CoreText

/// Fredoka.ttf (bundled, OFL-licensed — see ios/licenses/) is a variable font that ships only a
/// single named instance ("Fredoka-Light"), so `Font.custom("Fredoka-Bold", size:)` never resolves
/// — there is no such PostScript name — and SwiftUI silently falls back to the system font instead
/// of crashing, which is how this went unnoticed. Reaching the actual bold weight requires dialing
/// the font's `wght` variation axis directly via CoreText, the same technique android/.../
/// Typography.kt uses via `FontVariation.weight(...)`. Only the "Mochi" logo uses this path —
/// every other text style is Inter (see MochiFont below).
private enum VariableFont {
    /// OpenType axis tag 'wght' packed as a four-char code (0x77='w', 0x67='g', 0x68='h', 0x74='t').
    private static let wghtAxis: UInt32 = 0x77676874

    /// Every SwiftUI body re-evaluation (this view has several GeometryReaders, so that's often)
    /// was rebuilding a brand-new UIFontDescriptor + UIFont from CoreText's variation-axis path on
    /// every single Text — observed in practice to be flaky under that churn: identical builds
    /// produced correct glyphs on one launch and corrupted "tofu" glyphs or wrong metrics (causing
    /// spurious line-wraps) on the next. Resolving each (name, weight, size) combination once and
    /// reusing the same Font value removes the repeated CoreText instantiation entirely.
    private static var cache: [String: Font] = [:]

    static func resolve(postScriptName: String, weight: CGFloat, size: CGFloat) -> Font {
        let key = "\(postScriptName)-\(weight)-\(size)"
        if let cached = cache[key] {
            return cached
        }
        guard let base = UIFont(name: postScriptName, size: size) else {
            let fallback = Font.system(size: size, weight: .regular, design: .rounded)
            cache[key] = fallback
            return fallback
        }
        let variationKey = UIFontDescriptor.AttributeName(rawValue: kCTFontVariationAttribute as String)
        let descriptor = base.fontDescriptor.addingAttributes([variationKey: [wghtAxis: weight]])
        let resolved = Font(UIFont(descriptor: descriptor, size: size))
        cache[key] = resolved
        return resolved
    }
}

/// Figma's UI text (everything except the "Mochi" wordmark) is set in Inter. Weight is assigned
/// per element role, matching Figma exactly rather than a single blanket weight:
///   Regular  (400) — descriptions, "See all" links
///   Medium   (500) — item/theme/carousel names, nav bar labels, secondary text
///   SemiBold (600) — card titles ("Custom Create", "Choose from Library")
///   Bold     (700) — major section headings ("POPULAR THEMES", "FONT COLLECTION") and pill labels
/// Inter 4.1 (OFL — see ios/licenses/Inter-OFL.txt) is bundled in ios/MochiApp/Fonts/ and declared
/// in Info.plist's UIAppFonts. It was NOT bundled for a long stretch, and because
/// `Font.custom(_:size:)` — unlike raw `UIFont(name:)` — silently falls back to the system font
/// rather than failing, every style below was quietly rendering in SF Pro instead. That is why the
/// app's text kept reading "wrong" against Figma in ways no size tweak could fix. If text ever
/// looks like SF again, check UIAppFonts first: the PostScript names must stay exactly
/// Inter-Regular / Inter-Medium / Inter-SemiBold / Inter-Bold.
enum MochiFont {
    /// Figma's "Mochi" wordmark is Fredoka SemiBold (600 on the `wght` axis) — the one text style
    /// that stays off Inter.
    static func logo(_ size: CGFloat = 34) -> Font {
        VariableFont.resolve(postScriptName: "Fredoka-Light", weight: 600, size: size)
    }

    /// Bold — major section headings ("POPULAR THEMES", "FONT COLLECTION", page titles) and pill
    /// labels ("FONTS" / "THEMES" toggle).
    static func title(_ size: CGFloat = 22) -> Font {
        .custom("Inter-Bold", size: size)
    }

    /// SemiBold — card titles ("Custom Create", "Choose from Library").
    static func heading(_ size: CGFloat = 17) -> Font {
        .custom("Inter-SemiBold", size: size)
    }

    /// Medium — item/theme/carousel names (e.g. "Fantasy Castle Night", "Cozy Sakura Café").
    static func itemName(_ size: CGFloat = 14) -> Font {
        .custom("Inter-Medium", size: size)
    }

    /// Regular — descriptions / body copy / "See all" links.
    static func body(_ size: CGFloat = 15) -> Font {
        .custom("Inter-Regular", size: size)
    }

    /// Medium — nav bar labels and secondary/caption text.
    static func caption(_ size: CGFloat = 13) -> Font {
        .custom("Inter-Medium", size: size)
    }

    /// SemiBold — buttons and pill CTAs (e.g. "Create" / "Choose").
    static func button(_ size: CGFloat = 16) -> Font {
        .custom("Inter-SemiBold", size: size)
    }
}
