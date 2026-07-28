import SwiftUI

/// Marks on the Create Custom Theme frame (docs/figma/4.png) that no SF Symbol comes close enough
/// to. Everything else on that screen uses a system symbol; these four are drawn because the
/// design's version is either a different construction (the twelve-wedge colour wheel, the
/// hexagon) or has no system equivalent at all (the floppy disc, the keycap).

/// The twelve-wedge colour wheel inside the BACKGROUND card's "Colors" chip. Figma draws a flat
/// pie — twelve equal 30° wedges running red → orange → yellow → green → cyan → blue → violet →
/// magenta and back — not a continuous conic sweep, so the wedge boundaries stay hard.
struct ColorWheelGlyph: View {
    /// Read off the wheel in docs/figma/4.png wedge by wedge, starting at the one just clockwise
    /// of twelve o'clock and going clockwise.
    private static let wedges: [Color] = [
        Color(red: 0.98, green: 0.85, blue: 0.09),  // yellow
        Color(red: 0.97, green: 0.66, blue: 0.11),  // amber
        Color(red: 0.95, green: 0.45, blue: 0.13),  // orange
        Color(red: 0.90, green: 0.22, blue: 0.18),  // red
        Color(red: 0.83, green: 0.17, blue: 0.30),  // crimson
        Color(red: 0.66, green: 0.20, blue: 0.47),  // magenta
        Color(red: 0.47, green: 0.24, blue: 0.60),  // violet
        Color(red: 0.22, green: 0.31, blue: 0.65),  // indigo
        Color(red: 0.13, green: 0.47, blue: 0.55),  // teal
        Color(red: 0.14, green: 0.58, blue: 0.38),  // green
        Color(red: 0.30, green: 0.68, blue: 0.25),  // grass
        Color(red: 0.58, green: 0.76, blue: 0.20)   // lime
    ]

    var body: some View {
        GeometryReader { geo in
            let r = min(geo.size.width, geo.size.height) / 2
            let c = CGPoint(x: geo.size.width / 2, y: geo.size.height / 2)
            ZStack {
                ForEach(Array(Self.wedges.enumerated()), id: \.offset) { index, color in
                    Path { path in
                        path.move(to: c)
                        path.addArc(
                            center: c,
                            radius: r,
                            startAngle: .degrees(Double(index) * 30 - 90),
                            endAngle: .degrees(Double(index + 1) * 30 - 90),
                            clockwise: false
                        )
                        path.closeSubpath()
                    }
                    .fill(color)
                }
            }
        }
    }
}

/// The fourth key-shape option. SwiftUI has no hexagon primitive and SF's `hexagon` is a rounded,
/// point-up hex; Figma's is flat-topped with sharp vertices and its points on the horizontal axis.
struct HexagonShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width, h = rect.height
        // Flat top and bottom edges spanning the middle half of the width, points at mid-height.
        let points = [
            CGPoint(x: rect.minX + w * 0.25, y: rect.minY),
            CGPoint(x: rect.minX + w * 0.75, y: rect.minY),
            CGPoint(x: rect.maxX, y: rect.midY),
            CGPoint(x: rect.minX + w * 0.75, y: rect.maxY),
            CGPoint(x: rect.minX + w * 0.25, y: rect.maxY),
            CGPoint(x: rect.minX, y: rect.midY)
        ]
        _ = h
        path.addLines(points)
        path.closeSubpath()
        return path
    }
}

/// The Save Draft button's mark: a classic floppy disc, stroked not filled — outer body with the
/// write-protect corner clipped off, the shutter across the top and the label panel below it.
/// SF's nearest options (`square.and.arrow.down`, `externaldrive`) read as entirely different
/// objects at this size.
struct FloppyGlyph: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width, h = rect.height
        let corner = w * 0.22          // the clipped top-left corner

        path.move(to: CGPoint(x: rect.minX + corner, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + corner))
        path.closeSubpath()

        // Shutter — the metal slider across the disc's top third.
        path.addRect(CGRect(x: rect.minX + w * 0.26, y: rect.minY + h * 0.10,
                            width: w * 0.48, height: h * 0.28))
        // Label panel — the paper sticker across the bottom.
        path.addRect(CGRect(x: rect.minX + w * 0.20, y: rect.minY + h * 0.52,
                            width: w * 0.60, height: h * 0.48))
        return path
    }
}

/// The "Keys" tab mark: a solid rounded keycap with a four-point sparkle punched out of it.
struct KeycapGlyph: View {
    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width, h = geo.size.height
            RoundedRectangle(cornerRadius: h * 0.28, style: .continuous)
                .overlay(
                    Image(systemName: "sparkle")
                        .resizable()
                        .scaledToFit()
                        .frame(width: w * 0.42, height: w * 0.42)
                        .foregroundStyle(.white)
                )
        }
    }
}
