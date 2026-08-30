import UIKit

/// Loads and caches the per-key illustrations.
///
/// A themed keyboard with per-key art asks for ~33 images at once, which is the single largest
/// allocation the extension makes after the background plate. Three things keep that affordable
/// under a ~30–48 MB ceiling:
///
/// 1. **Lazy.** Nothing loads until a key actually asks for it, so a plane the user never opens
///    costs nothing.
/// 2. **Downsampled to the drawn size.** The catalogue stores art at roughly 3× the largest
///    supported cap; a key on a smaller device decodes smaller.
/// 3. **Purgeable.** `NSCache` evicts under pressure on its own, and `releaseAll()` drops
///    everything on a memory warning. Every entry is reconstructible from the bundle, so eviction
///    is never lossy.
final class KeyArtStore {
    static let shared = KeyArtStore()

    private let cache = NSCache<NSString, UIImage>()

    private init() {
        // Bounded by pixel count rather than entry count: 33 letter caps and one space-bar
        // panorama are wildly different sizes, so "40 images" would be a meaningless limit.
        // ~6 MB of decoded RGBA, comfortably inside budget.
        cache.totalCostLimit = 6 * 1024 * 1024
    }

    /// - Parameters:
    ///   - identity: `KeyDefinition.artIdentity`.
    ///   - targetSize: the size the artwork will be drawn at, in points.
    /// - Returns: `nil` when the theme has no art set, or the asset is missing.
    ///
    /// A missing asset is a completely normal state, not an error: illustrations are delivered per
    /// theme and a set can be incomplete while it is still being produced. The key simply renders
    /// without art.
    func image(
        identity: String,
        artSet: KeyArtSet,
        targetSize: CGSize,
        scale: CGFloat
    ) -> UIImage? {
        guard targetSize.width > 1, targetSize.height > 1 else { return nil }
        let assetName = artSet.assetName(for: identity)
        let key = "\(assetName)@\(Int(targetSize.width))x\(Int(targetSize.height))@\(Int(scale))" as NSString

        if let cached = cache.object(forKey: key) { return cached }
        guard let source = UIImage(named: assetName) else { return nil }

        let scaled = Self.downsample(source, to: targetSize, scale: scale)
        let cost = Int(scaled.size.width * scale * scaled.size.height * scale * 4)
        cache.setObject(scaled, forKey: key, cost: cost)
        return scaled
    }

    /// Redraws at the target size when the source is meaningfully larger.
    ///
    /// Unlike the background plate, these come from the asset catalogue, which `ImageIO` cannot
    /// downsample directly — so this is decode-then-redraw. That is acceptable here only because
    /// the sources are small (a letter illustration is ~140px wide); doing the same to a 1320px
    /// background is exactly the allocation spike `ThemeImageLoader` exists to avoid.
    private static func downsample(_ image: UIImage, to targetSize: CGSize, scale: CGFloat) -> UIImage {
        let sourcePixelWidth = image.size.width * image.scale
        guard sourcePixelWidth > targetSize.width * scale * 1.15 else { return image }

        let aspect = image.size.height / max(image.size.width, 1)
        let drawSize = CGSize(width: targetSize.width, height: targetSize.width * aspect)

        let format = UIGraphicsImageRendererFormat.preferred()
        format.scale = scale
        // Illustrations are cut-outs; an opaque context would fill the transparent area black.
        format.opaque = false
        return UIGraphicsImageRenderer(size: drawSize, format: format).image { _ in
            image.draw(in: CGRect(origin: .zero, size: drawSize))
        }
    }

    func releaseAll() {
        cache.removeAllObjects()
    }
}
