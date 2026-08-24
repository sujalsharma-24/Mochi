import SwiftUI

/// Real art from Assets.xcassets — either cropped from the client's Figma export or, since the
/// asset catalog landed, delivered directly by the client per-theme. Anything not in this set
/// falls back to the generated KeyboardPreviewPlaceholder until the client provides isolated
/// assets for the rest of the 250-theme catalog. Mirrors android/.../components/ThemeArt.kt's
/// knownThemeArt map.
private let knownThemeArt: Set<String> = [
    "theme_fantasy_castle_night", "theme_space_vibe", "theme_dreamy_castle",
    "theme_cozy_sakura_cafe", "theme_sakura_train", "theme_pastel_rainbow",
    // Cropped from docs/figma/2.png for Community's Top Themes row.
    "theme_kawaii_boba", "theme_pastel_pink_sky",
    // Added with the client's asset catalog delivery; used by Search's "Forest Theme" result.
    "theme_forest"
]

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
                    if knownThemeArt.contains(assetName) {
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
