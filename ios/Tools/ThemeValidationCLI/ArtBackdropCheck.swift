import CoreGraphics
import Foundation
import ImageIO

/// Measures key legibility against the **real background art**, pixel by pixel.
///
/// `ThemeValidator` deliberately ignores background art: art has per-pixel luminance that cannot
/// be reduced to one number, so it validates against base + scrim only. That is the right default
/// — it is what lets a theme be checked before its art exists — but it leaves a real gap once art
/// is attached, because the scrim's job is precisely to bound what the art can do to legibility,
/// and nothing was checking that it actually does.
///
/// This closes that gap. It reproduces the renderer's aspect-fill crop and vertical anchor, lays
/// the scrim over it, then walks every pixel under every solved key frame and finds the *worst*
/// contrast anywhere beneath each cap. Worst-case, not average: a key is unreadable if any part of
/// it is, and averaging is how a bright lantern behind one corner of a key gets explained away.
///
/// It lives in the tool rather than the shipping renderer because it is a design-time check that
/// costs hundreds of thousands of pixel evaluations. The colour maths is the shared `ThemeColor`
/// code, so the numbers here and the numbers in `ThemeValidator` mean the same thing.
enum ArtBackdropCheck {
    /// The two criteria are deliberately different, and the difference is the point.
    ///
    /// **Labels are judged worst-case.** If any pixel of a letter sits on a cap that has lost
    /// contrast, that letter is hard to read. There is no averaging your way out of text.
    ///
    /// **Cap separation is judged by coverage** — what fraction of the cap's area clears 3:1.
    /// A per-pixel rule is stricter than the property actually being tested: WCAG's non-text
    /// contrast is about being able to identify a component's boundary, and a cap's boundary is
    /// also carried by its drop shadow and top highlight, neither of which this pixel test models.
    /// Demanding every pixel clear 3:1 over artwork forces a scrim heavy enough to flatten the art
    /// into a dark rectangle, which trades a real design for a number.
    ///
    /// So: 99% coverage required, worst case always printed. The worst case is reported precisely
    /// so that relaxing the rule cannot quietly hide a key that is bad across most of its face.
    static let requiredCapCoverage = 0.99

    struct KeyResult {
        var label: String
        var role: KeyRole
        var worstLabelContrast: Double
        var worstCapContrast: Double
        /// Fraction of the cap's area where cap-vs-backdrop clears `minimumCapContrast`.
        var capCoverage: Double
        var minBackdropLuminance: Double
        var maxBackdropLuminance: Double
    }

    /// - Parameters:
    ///   - width/height: the keyboard surface size in points to simulate.
    ///   - supersample: pixels sampled per point. 2 is plenty — this is looking for regions of the
    ///     art that are too bright or too dark, not for single-pixel speckle.
    /// - Parameter suggestionBarHeight: the strip above the keys. It matters here beyond bookkeeping:
    ///   it changes the surface's total height, which changes the aspect-fill crop of the artwork,
    ///   which changes what is behind every key. Measuring the key grid alone would sample a band
    ///   of art the user never actually sees under the keys.
    static func run(
        theme: MochiKeyboardTheme,
        artPath: String,
        width: CGFloat,
        keyGridHeight: CGFloat,
        suggestionBarHeight: CGFloat,
        supersample: Int = 2
    ) -> [KeyResult]? {
        let totalHeight = keyGridHeight + suggestionBarHeight
        guard let backdrop = renderBackdrop(
            theme: theme,
            artPath: artPath,
            width: width,
            height: totalHeight,
            supersample: supersample
        ) else { return nil }

        let metrics = KeyboardMetrics(availableWidth: width, isLandscape: false)
        let layout = KeyboardLayout.layout(for: .letters, includesNextKeyboardKey: true, metrics: metrics)
        let solved = KeyboardLayoutSolver.solve(
            layout: layout,
            metrics: metrics,
            in: CGSize(width: width, height: keyGridHeight)
        ).map { key in
            // The solver works in the key container's space; the container sits below the bar.
            SolvedKey(
                definition: key.definition,
                frame: key.frame.offsetBy(dx: 0, dy: suggestionBarHeight)
            )
        }

        return solved.map { key in
            let style = theme.style(for: key.definition.role)
            // The bottom stop — the darkest part of the cap gradient, and therefore the worst case
            // for the dark ink these themes use. Same choice `ThemeFill.contrastRepresentative`
            // makes, for the same reason.
            // Invisible ink is a design choice (the space bar's hidden label), not a defect.
            let labelIsHidden = style.labelColor.alpha == 0
            let capColor = style.fill.contrastRepresentative
            let labelColor = style.labelColor

            var worstLabel = Double.infinity
            var worstCap = Double.infinity
            var minLum = Double.infinity
            var maxLum = -Double.infinity
            var capClearing = 0
            var sampleCount = 0

            let s = CGFloat(supersample)
            let x0 = Int((key.frame.minX * s).rounded(.down))
            let x1 = Int((key.frame.maxX * s).rounded(.up))
            let y0 = Int((key.frame.minY * s).rounded(.down))
            let y1 = Int((key.frame.maxY * s).rounded(.up))

            for y in max(0, y0)..<min(backdrop.height, y1) {
                for x in max(0, x0)..<min(backdrop.width, x1) {
                    let local = backdrop.color(x: x, y: y)
                    let lum = local.relativeLuminance
                    minLum = Swift.min(minLum, lum)
                    maxLum = Swift.max(maxLum, lum)

                    let capHere = capColor.composited(over: local)
                    let labelHere = labelColor.composited(over: capHere)
                    if !labelIsHidden {
                        worstLabel = Swift.min(worstLabel, labelHere.contrastRatio(against: capHere))
                    }

                    let capContrast = capHere.contrastRatio(against: local)
                    worstCap = Swift.min(worstCap, capContrast)
                    if capContrast >= ThemeValidator.minimumCapContrast { capClearing += 1 }
                    sampleCount += 1
                }
            }

            return KeyResult(
                label: key.definition.label ?? key.definition.symbolName ?? "?",
                role: key.definition.role,
                worstLabelContrast: worstLabel,
                worstCapContrast: worstCap,
                capCoverage: sampleCount > 0 ? Double(capClearing) / Double(sampleCount) : 1,
                minBackdropLuminance: minLum,
                maxBackdropLuminance: maxLum
            )
        }
    }

    // MARK: - Backdrop rendering

    private struct Bitmap {
        var width: Int
        var height: Int
        var pixels: [UInt8]

        func color(x: Int, y: Int) -> ThemeColor {
            let i = (y * width + x) * 4
            return ThemeColor(
                red: Double(pixels[i]) / 255,
                green: Double(pixels[i + 1]) / 255,
                blue: Double(pixels[i + 2]) / 255,
                alpha: 1
            )
        }
    }

    /// Reproduces layers 1–3 of `KeyboardSurfaceView`: base fill, art (aspect-fill + anchor), scrim.
    private static func renderBackdrop(
        theme: MochiKeyboardTheme,
        artPath: String,
        width: CGFloat,
        height: CGFloat,
        supersample: Int
    ) -> Bitmap? {
        let pixelWidth = Int(width) * supersample
        let pixelHeight = Int(height) * supersample

        guard let source = CGImageSourceCreateWithURL(URL(fileURLWithPath: artPath) as CFURL, nil),
              let art = CGImageSourceCreateImageAtIndex(source, 0, nil) else { return nil }

        let colorSpace = CGColorSpace(name: CGColorSpace.sRGB)!
        guard let context = CGContext(
            data: nil,
            width: pixelWidth,
            height: pixelHeight,
            bitsPerComponent: 8,
            bytesPerRow: pixelWidth * 4,
            space: colorSpace,
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else { return nil }

        // Layer 1 — base fill. Approximated by its darkest stop, which is only visible at all
        // through cap translucency and where art is absent.
        let base = theme.surface.baseFill.contrastRepresentative
        context.setFillColor(base.cgColorSRGB)
        context.fill(CGRect(x: 0, y: 0, width: pixelWidth, height: pixelHeight))

        // Layer 2 — art, aspect-filled with the theme's vertical anchor, matching
        // `KeyboardSurfaceView.applyVerticalAnchor`.
        if let background = theme.surface.backgroundImage {
            let artW = CGFloat(art.width)
            let artH = CGFloat(art.height)
            let scale = CGFloat(pixelWidth) / artW
            let scaledHeight = artH * scale

            if scaledHeight > CGFloat(pixelHeight) {
                let visibleFraction = CGFloat(pixelHeight) / scaledHeight
                let originY = (1 - visibleFraction) * CGFloat(background.verticalAnchor)
                // CoreGraphics' origin is bottom-left; the renderer's contentsRect is top-left.
                let cropY = (1 - visibleFraction - originY) * artH
                if let cropped = art.cropping(to: CGRect(
                    x: 0,
                    y: cropY,
                    width: artW,
                    height: visibleFraction * artH
                )) {
                    context.draw(cropped, in: CGRect(x: 0, y: 0, width: pixelWidth, height: pixelHeight))
                }
            } else {
                context.draw(art, in: CGRect(x: 0, y: 0, width: pixelWidth, height: pixelHeight))
            }
        }

        // Layer 3 — the scrim, drawn per row so the gradient is exact rather than stepped.
        let top = theme.surface.scrim.topColor
        let bottom = theme.surface.scrim.bottomColor
        for row in 0..<pixelHeight {
            // Row 0 of the context is the *bottom*, so t runs from the bottom colour upward.
            let t = Double(row) / Double(max(1, pixelHeight - 1))
            let color = bottom.blended(toward: top, amount: t)
            context.setFillColor(color.cgColorSRGB)
            context.fill(CGRect(x: 0, y: row, width: pixelWidth, height: 1))
        }

        guard let data = context.data else { return nil }
        let buffer = data.bindMemory(to: UInt8.self, capacity: pixelWidth * pixelHeight * 4)
        var pixels = [UInt8](repeating: 0, count: pixelWidth * pixelHeight * 4)
        for i in 0..<(pixelWidth * pixelHeight * 4) { pixels[i] = buffer[i] }

        // Flip to top-left origin so y indices match the layout solver's frames.
        var flipped = [UInt8](repeating: 0, count: pixels.count)
        let rowBytes = pixelWidth * 4
        for y in 0..<pixelHeight {
            let srcStart = (pixelHeight - 1 - y) * rowBytes
            let dstStart = y * rowBytes
            flipped.replaceSubrange(dstStart..<(dstStart + rowBytes), with: pixels[srcStart..<(srcStart + rowBytes)])
        }

        return Bitmap(width: pixelWidth, height: pixelHeight, pixels: flipped)
    }
}

private extension ThemeColor {
    /// A CoreGraphics colour without going through UIKit, so this runs on the host.
    var cgColorSRGB: CGColor {
        CGColor(
            colorSpace: CGColorSpace(name: CGColorSpace.sRGB)!,
            components: [CGFloat(red), CGFloat(green), CGFloat(blue), CGFloat(alpha)]
        )!
    }
}
