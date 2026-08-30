import CoreGraphics
import CoreImage
import ImageIO
import UIKit
import UniformTypeIdentifiers

/// Loads a theme's background art at the size it will actually be drawn, and never larger.
///
/// This is the single most important piece of memory discipline in the extension. A keyboard runs
/// under a dirty-memory ceiling in the ~30–48 MB range (TRD budgets to 30 MB; community
/// measurements put the hard kill nearer 48–77 MB depending on iOS version), and the process is
/// killed silently with no crash log when it is exceeded.
///
/// `UIImage(named:)` decodes at the asset's full pixel size. A 2000×1500 background is ~12 MB of
/// decoded RGBA before anything else has been allocated — a third of the budget for an image that
/// is about to be drawn into a 393×291 pt window. `CGImageSourceCreateThumbnailAtIndex` decodes
/// straight to the target size instead, so the full-size bitmap never exists at all. That is a
/// different thing from decoding-then-resizing, which briefly allocates the full bitmap and is
/// exactly the spike that kills the extension.
enum ThemeImageLoader {
    /// Loads and prepares background art for a specific draw size.
    ///
    /// - Parameters:
    ///   - image: the theme's background token.
    ///   - targetSize: the size in **points** the art will be drawn at.
    ///   - scale: the display scale. Passing the real scale matters — decoding a @3x-sized bitmap
    ///     for a @2x screen wastes over half the budget for no visible gain.
    ///   - containerURL: App Group container root, needed only for `.appGroupFile` sources.
    /// - Returns: a decoded image, or `nil` if the art is unavailable — a case the caller must
    ///   handle by falling back to `ThemeSurface.baseColor` rather than showing nothing.
    static func loadBackground(
        _ image: ThemeBackgroundImage,
        targetSize: CGSize,
        scale: CGFloat,
        containerURL: URL?
    ) -> UIImage? {
        guard targetSize.width > 0, targetSize.height > 0 else { return nil }
        let maxPixelDimension = Int((max(targetSize.width, targetSize.height) * scale).rounded(.up))

        let decoded: UIImage?
        switch image.source {
        case .bundled(let name):
            decoded = downsampledBundledImage(named: name, maxPixelDimension: maxPixelDimension, scale: scale)
        case .appGroupFile(let relativePath):
            guard let containerURL else { return nil }
            decoded = downsample(
                url: containerURL.appendingPathComponent(relativePath),
                maxPixelDimension: maxPixelDimension,
                scale: scale
            )
        }

        guard let decoded else { return nil }
        guard image.blurRadius > 0 else { return decoded }
        return blurred(decoded, radius: image.blurRadius * scale) ?? decoded
    }

    // MARK: - Downsampling

    static func downsample(url: URL, maxPixelDimension: Int, scale: CGFloat) -> UIImage? {
        // `kCGImageSourceShouldCache: false` keeps ImageIO from holding the full decoded bitmap in
        // its own cache after we have taken the thumbnail — without it the memory this whole
        // function exists to avoid gets retained anyway, just somewhere less obvious.
        let sourceOptions = [kCGImageSourceShouldCache: false] as CFDictionary
        guard let source = CGImageSourceCreateWithURL(url as CFURL, sourceOptions) else { return nil }
        return thumbnail(from: source, maxPixelDimension: maxPixelDimension, scale: scale)
    }

    static func downsample(data: Data, maxPixelDimension: Int, scale: CGFloat) -> UIImage? {
        let sourceOptions = [kCGImageSourceShouldCache: false] as CFDictionary
        guard let source = CGImageSourceCreateWithData(data as CFData, sourceOptions) else { return nil }
        return thumbnail(from: source, maxPixelDimension: maxPixelDimension, scale: scale)
    }

    private static func thumbnail(from source: CGImageSource, maxPixelDimension: Int, scale: CGFloat) -> UIImage? {
        let options: [CFString: Any] = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceShouldCacheImmediately: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceThumbnailMaxPixelSize: maxPixelDimension
        ]
        guard let cgImage = CGImageSourceCreateThumbnailAtIndex(source, 0, options as CFDictionary) else {
            return nil
        }
        return UIImage(cgImage: cgImage, scale: scale, orientation: .up)
    }

    /// Asset-catalog images have to be located before they can be downsampled, because ImageIO
    /// works on data and `UIImage(named:)` works on the compiled catalog. Round-tripping through
    /// PNG data would defeat the purpose, so bundled art is decoded normally and then redrawn at
    /// target size if it is meaningfully oversized.
    ///
    /// This is why `BuiltInThemes` prefers `.appGroupFile` art for anything large: the bundled
    /// path cannot get the same guarantee. Small bundled art (previews, particle sprites) is fine.
    private static func downsampledBundledImage(named name: String, maxPixelDimension: Int, scale: CGFloat) -> UIImage? {
        guard let image = UIImage(named: name) else { return nil }
        let pixelWidth = image.size.width * image.scale
        let pixelHeight = image.size.height * image.scale
        let longestSide = max(pixelWidth, pixelHeight)
        guard longestSide > CGFloat(maxPixelDimension) * 1.15 else { return image }

        let ratio = CGFloat(maxPixelDimension) / longestSide
        let targetPointSize = CGSize(
            width: (pixelWidth * ratio / scale).rounded(),
            height: (pixelHeight * ratio / scale).rounded()
        )
        let format = UIGraphicsImageRendererFormat.preferred()
        format.scale = scale
        format.opaque = true
        return UIGraphicsImageRenderer(size: targetPointSize, format: format).image { _ in
            image.draw(in: CGRect(origin: .zero, size: targetPointSize))
        }
    }

    // MARK: - Blur

    /// One-shot Gaussian blur, applied at load and then thrown away.
    ///
    /// Deliberately **not** a `UIVisualEffectView`. A blur view re-samples its backdrop every
    /// frame, and a keyboard redraws on every keystroke; more importantly a `UIVisualEffectView`
    /// inside a keyboard extension cannot sample the host app's content at all — the extension
    /// draws into a separate remote window with no access to that hierarchy — so the "frosted over
    /// the app" look people expect from it is simply not available here. Blurring our own art once,
    /// at decode, gives the same visual result for a fixed cost.
    private static func blurred(_ image: UIImage, radius: CGFloat) -> UIImage? {
        guard radius > 0, let inputCG = image.cgImage else { return nil }
        let context = CIContext(options: [.useSoftwareRenderer: false])
        let input = CIImage(cgImage: inputCG)

        guard let filter = CIFilter(name: "CIGaussianBlur") else { return nil }
        filter.setValue(input, forKey: kCIInputImageKey)
        filter.setValue(radius, forKey: kCIInputRadiusKey)
        // Gaussian blur grows the extent and leaves transparent edges; clamping to the original
        // extent is what keeps the art from developing soft translucent borders where it meets the
        // edge of the keyboard.
        guard let output = filter.outputImage?.cropped(to: input.extent),
              let result = context.createCGImage(output, from: input.extent) else { return nil }
        return UIImage(cgImage: result, scale: image.scale, orientation: .up)
    }
}
