import SwiftUI
import UIKit

/// A theme's background plate, decoded **small** for a grid tile.
///
/// The Themes grid shows up to 28 `themebg_*` plates at once. Each is ~1440×1080px — about 6 MB of
/// decoded RGBA — so `Image("themebg_…")` across a full screen is ~150+ MB of bitmaps for art drawn
/// into a 119pt box. This view decodes each plate once at roughly the tile's pixel size (through a
/// shared cache) so the full-size bitmap never stays resident. It mirrors the discipline
/// `ThemeImageLoader` enforces in the keyboard extension, applied here to the marketplace grid.
///
/// Decodes are funnelled through one `actor` so that scrolling a fresh row into view schedules its
/// handful of plates one at a time rather than spawning a dozen concurrent `UIImage(named:)` calls
/// that contend on the asset catalogue's internal lock.
///
/// `verticalAnchor` places the crop the way the theme's own art intends — the plates are authored
/// ~1.29:1 to be cropped by a wide keyboard window, and a centred crop loses exactly the subject
/// (Fantasy Castle Night's crescent moon, for one). Callers pass the built-in theme's
/// `surface.backgroundImage?.verticalAnchor`, quantised here to top / centre / bottom.
struct ThemePlateThumbnail: View {
    let assetName: String
    /// 0 = top of the art, 1 = bottom. Quantised to `.top` / `.center` / `.bottom`.
    var verticalAnchor: Double = 0.5
    /// Longest-side pixel budget for the decode. ~119pt tile at up to @3x, with headroom.
    var maxPixelDimension: Int = 440

    @State private var image: UIImage?

    private var alignment: Alignment {
        switch verticalAnchor {
        case ..<0.34: return .top
        case 0.66...: return .bottom
        default: return .center
        }
    }

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                // Fallback under the art: a soft gradient so a missing/slow plate reads as
                // deliberate rather than as a blank tile.
                LinearGradient(
                    colors: [MochiColor.lavender, MochiColor.pink.opacity(0.35)],
                    startPoint: .top, endPoint: .bottom
                )

                if let image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: proxy.size.width, height: proxy.size.height, alignment: alignment)
                        .clipped()
                }
            }
        }
        .task(id: assetName) {
            guard !assetName.isEmpty, image == nil else { return }
            image = await ThemePlateLoader.shared.image(named: assetName, maxPixelDimension: maxPixelDimension)
        }
    }
}

/// Serialises plate downsampling and caches the results.
actor ThemePlateLoader {
    static let shared = ThemePlateLoader()

    private var cache: [String: UIImage] = [:]

    func image(named name: String, maxPixelDimension: Int) -> UIImage? {
        let key = "\(name)@\(maxPixelDimension)"
        if let hit = cache[key] { return hit }
        guard let downsized = Self.downsample(named: name, maxPixelDimension: maxPixelDimension) else {
            return nil
        }
        cache[key] = downsized
        return downsized
    }

    /// Mirrors `ThemeImageLoader.downsampledBundledImage` — decode the catalogue image, then redraw
    /// it once at the target size if it is meaningfully oversized so the full bitmap is released.
    private static func downsample(named name: String, maxPixelDimension: Int) -> UIImage? {
        guard let full = UIImage(named: name) else { return nil }
        let screenScale = UIScreen.main.scale
        let longestPx = max(full.size.width, full.size.height) * full.scale
        guard longestPx > CGFloat(maxPixelDimension) * 1.15 else { return full }

        let ratio = CGFloat(maxPixelDimension) / longestPx
        let targetPointSize = CGSize(
            width: (full.size.width * full.scale * ratio / screenScale).rounded(),
            height: (full.size.height * full.scale * ratio / screenScale).rounded()
        )
        let format = UIGraphicsImageRendererFormat.preferred()
        format.scale = screenScale
        format.opaque = true
        return UIGraphicsImageRenderer(size: targetPointSize, format: format).image { _ in
            full.draw(in: CGRect(origin: .zero, size: targetPointSize))
        }
    }
}

extension KeyboardTheme {
    /// The band of the plate a tile should keep, so the same theme is framed identically wherever
    /// it is shown — Themes' grid, Community's Top Themes row, anywhere else a plate is cropped.
    ///
    /// A built-in theme authors a `verticalAnchor` for its background, and the keyboard renders that
    /// band; a tile that centre-crops instead shows a different slice of the same art on each
    /// screen. Falls back to centre for a Firestore/custom theme with no bundled plate, and for a
    /// featured theme whose thumbnail is a full composited-keyboard mockup (framed to be shown
    /// whole, not cropped to a band).
    var plateVerticalAnchor: Double {
        if imageAssetName.hasPrefix("themethumb_") { return 0.5 }
        if imageAssetName.hasPrefix("theme_") { return 0.5 }
        return BuiltInThemes.all.first { $0.id == id }?
            .surface.backgroundImage?.verticalAnchor ?? 0.5
    }
}
