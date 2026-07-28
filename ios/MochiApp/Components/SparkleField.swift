import SwiftUI

/// Scattered decorative sparkles matching Figma's ambient star accents around the screen edges
/// and between sections. Fixed relative positions (not randomized per-render) so the layout is
/// stable across redraws; sized/positioned as fractions of the screen so it scales across devices.
struct SparkleField: View {
    private struct Sparkle {
        let x: CGFloat // fraction of width
        let y: CGFloat // fraction of height
        let size: CGFloat
        let opacity: Double
    }

    private let sparkles: [Sparkle] = [
        Sparkle(x: 0.06, y: 0.02, size: 10, opacity: 0.55),
        Sparkle(x: 0.92, y: 0.05, size: 7, opacity: 0.4),
        Sparkle(x: 0.88, y: 0.14, size: 12, opacity: 0.5),
        Sparkle(x: 0.03, y: 0.20, size: 8, opacity: 0.45),
        Sparkle(x: 0.5, y: 0.235, size: 6, opacity: 0.4),
        Sparkle(x: 0.95, y: 0.34, size: 9, opacity: 0.4),
        Sparkle(x: 0.05, y: 0.40, size: 7, opacity: 0.35),
        Sparkle(x: 0.90, y: 0.50, size: 10, opacity: 0.45),
        Sparkle(x: 0.04, y: 0.58, size: 8, opacity: 0.4),
        Sparkle(x: 0.5, y: 0.995, size: 8, opacity: 0.4)
    ]

    var body: some View {
        GeometryReader { geo in
            ForEach(Array(sparkles.enumerated()), id: \.offset) { _, sparkle in
                Image(systemName: "sparkle")
                    .resizable()
                    .scaledToFit()
                    .frame(width: sparkle.size, height: sparkle.size)
                    .foregroundStyle(.white.opacity(sparkle.opacity))
                    .position(x: geo.size.width * sparkle.x, y: geo.size.height * sparkle.y)
            }
        }
        .allowsHitTesting(false)
    }
}
