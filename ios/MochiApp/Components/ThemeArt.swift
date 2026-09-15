import SwiftUI
import UIKit

/// Whether the asset catalogue actually carries art under this name.
///
/// This replaces a hand-maintained `knownThemeArt` allowlist that named nine assets. Every theme
/// outside it fell through to the *generated* `KeyboardPreviewPlaceholder`, so 112 of the 121
/// built-in themes browsed as a seeded gradient that had nothing to do with the theme — which is
/// why thumbnails all over the app showed the wrong artwork. Each built-in carries its own
/// `themebg_*` plate (see `KeyboardTheme.init(builtIn:meta:)`), so asking the catalogue directly is
/// both correct and self-maintaining: art added later shows up without anyone editing a list.
///
/// Cached because `SwiftUI` re-evaluates `body` often and `UIImage(named:)` hits the catalogue
/// index each time; the answer for a given name never changes within a launch.
enum ThemeArtAvailability {
    private static var cache: [String: Bool] = [:]
    private static let lock = NSLock()

    static func hasArt(_ name: String) -> Bool {
        guard !name.isEmpty else { return false }
        lock.lock(); defer { lock.unlock() }
        if let known = cache[name] { return known }
        let exists = UIImage(named: name) != nil
        cache[name] = exists
        return exists
    }
}

private let knownFontArt: Set<String> = [
    "font_bubble_cute", "font_handwritten_elegant", "font_typewriter_classic", "font_bold_strong"
]

/// `ratio` is enforced by an invisible `Color.clear` spacer rather than by putting
/// `.aspectRatio(ratio, contentMode: .fit)` around the artwork directly. That direct form looks
/// correct but isn't: a `.fill` image reports a layout size *larger* than the proposal it was
/// given, and `.aspectRatio(_:contentMode: .fit)` returns its child's actual size — so each card
/// ended up as tall as its own source PNG's native ratio made it, which is why a row of three
/// cards rendered at three visibly different heights. Sizing `Color.clear` (which accepts any
/// proposal exactly) and hanging the artwork off it as an overlay pins every card to the same box.
struct KeyboardThemeArt: View {
    let assetName: String
    let seed: String
    var cornerRadius: CGFloat = MochiRadius.card
    /// Figma (docs/figma/1.png): top carousel art is 640x475px and Popular Themes art is 779x574px
    /// — both ≈1.35:1, not the 1.25 this used to assume.
    var ratio: CGFloat = 1.35

    var body: some View {
        Color.clear
            .aspectRatio(ratio, contentMode: .fit)
            .overlay(
                Group {
                    if ThemeArtAvailability.hasArt(assetName) {
                        Image(assetName)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } else {
                        KeyboardPreviewPlaceholder(seed: seed, cornerRadius: cornerRadius)
                    }
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .shadow(color: MochiColor.purpleDark.opacity(0.14), radius: 6, y: 3)
    }
}

struct FontArtCard<Content: View>: View {
    let assetName: String
    var cornerRadius: CGFloat = MochiRadius.card
    @ViewBuilder let content: Content

    var body: some View {
        Group {
            if knownFontArt.contains(assetName) {
                Image(assetName)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            } else {
                content
            }
        }
        .shadow(color: MochiColor.purpleDark.opacity(0.12), radius: 5, y: 2)
    }
}
