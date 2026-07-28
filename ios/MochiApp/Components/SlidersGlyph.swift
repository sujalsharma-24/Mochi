import SwiftUI

/// The mark inside the trailing round button of a sort/filter row: a line-then-knob on top,
/// knob-then-line below. No SF Symbol matches it — `slider.horizontal.3` has three rows and
/// centres both knobs — so it is drawn. Figma uses the identical glyph on the Fonts frame
/// (docs/figma/5.png) and the Themes frame (docs/figma/8.png), which is why it lives here rather
/// than privately in either view.
struct SlidersGlyph: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        let r = min(rect.height * 0.22, rect.width * 0.14)
        let yTop = rect.minY + r
        let yBottom = rect.maxY - r

        // Top: rail from the left edge, knob toward the right.
        let topKnobX = rect.maxX - r
        p.move(to: CGPoint(x: rect.minX, y: yTop))
        p.addLine(to: CGPoint(x: topKnobX - r, y: yTop))
        p.addEllipse(in: CGRect(x: topKnobX - r, y: yTop - r, width: r * 2, height: r * 2))

        // Bottom: knob toward the left, rail running out to the right edge.
        let bottomKnobX = rect.minX + r * 2
        p.addEllipse(in: CGRect(x: bottomKnobX - r, y: yBottom - r, width: r * 2, height: r * 2))
        p.move(to: CGPoint(x: bottomKnobX + r, y: yBottom))
        p.addLine(to: CGPoint(x: rect.maxX, y: yBottom))
        return p
    }
}

/// The mark inside the "Filter" capsule: a symmetric funnel — a full-width top edge, two diagonals
/// converging to a neck at 55% height, then a short parallel-sided spout with a foot that slants up
/// to the right. SF's `line.3.horizontal.decrease` is three stacked rules and reads nothing like it,
/// and no bundled symbol draws a funnel below iOS 17, so it is drawn.
struct FunnelGlyph: Shape {
    func path(in rect: CGRect) -> Path {
        func p(_ x: CGFloat, _ y: CGFloat) -> CGPoint {
            CGPoint(x: rect.minX + rect.width * x, y: rect.minY + rect.height * y)
        }
        var path = Path()
        path.move(to: p(0.00, 0.00))
        path.addLine(to: p(1.00, 0.00))
        path.addLine(to: p(0.60, 0.55))
        path.addLine(to: p(0.60, 0.86))
        path.addLine(to: p(0.42, 1.00))
        path.addLine(to: p(0.42, 0.55))
        path.closeSubpath()
        return path
    }
}

/// The disc button burnt into every theme tile in docs/figma/8.png: a down arrow dropping into an
/// open-topped tray. SF's `arrow.down.to.line` ends in a full-width rule and `square.and.arrow.down`
/// wraps the arrow in a closed box, so neither reads as this mark; it is drawn instead.
/// Proportions come off the 31x32px mark inside 8.png's 65px disc: the stem sits at 48% across and
/// runs the top 56% of the box, the arrow arms open to 16%..81% and meet the stem's foot, and the
/// tray is a full-width open-topped U starting at 66% with a 10px-deep rounded floor.
struct DownloadGlyph: Shape {
    func path(in rect: CGRect) -> Path {
        func p(_ x: CGFloat, _ y: CGFloat) -> CGPoint {
            CGPoint(x: rect.minX + rect.width * x, y: rect.minY + rect.height * y)
        }
        var path = Path()

        path.move(to: p(0.48, 0.00))
        path.addLine(to: p(0.48, 0.5625))

        path.move(to: p(0.16, 0.375))
        path.addLine(to: p(0.48, 0.5625))
        path.addLine(to: p(0.81, 0.375))

        let corner: CGFloat = 0.14
        path.move(to: p(0.00, 0.656))
        path.addLine(to: p(0.00, 1.0 - corner))
        path.addQuadCurve(to: p(corner, 1.00), control: p(0.00, 1.00))
        path.addLine(to: p(1.0 - corner, 1.00))
        path.addQuadCurve(to: p(1.00, 1.0 - corner), control: p(1.00, 1.00))
        path.addLine(to: p(1.00, 0.656))
        return path
    }
}

/// The mark on the "Handwritten" pill: an outlined pencil lying at 45°, tip to the lower left, with
/// a divider across it near the cap, over a full-width rule. SF's plain `pencil` is the body only —
/// the rule underneath is a visible part of Figma's mark, and `pencil.line` is iOS 17+ while this
/// target still ships to iOS 16.
struct PencilGlyph: Shape {
    /// Half the body's width, in unit space. Themes' pill mark is chunky at 0.135; Profile's "Edit
    /// Profile" capsule draws a visibly finer pencil, so it passes its own value rather than
    /// inheriting one tuned for a different frame.
    var bodyHalfWidth: CGFloat = 0.135

    func path(in rect: CGRect) -> Path {
        func p(_ x: CGFloat, _ y: CGFloat) -> CGPoint {
            CGPoint(x: rect.minX + rect.width * x, y: rect.minY + rect.height * y)
        }
        // Unit-space axis, tip to cap, and its perpendicular half-width.
        let tip = CGPoint(x: 0.10, y: 0.76)
        let cap = CGPoint(x: 0.82, y: 0.04)
        let dx = cap.x - tip.x, dy = cap.y - tip.y
        let len = (dx * dx + dy * dy).squareRoot()
        let ux = dx / len, uy = dy / len
        let hw = bodyHalfWidth
        let nx = -uy * hw, ny = ux * hw
        func at(_ t: CGFloat, _ side: CGFloat) -> CGPoint {
            p(tip.x + ux * len * t + nx * side, tip.y + uy * len * t + ny * side)
        }

        var path = Path()
        // Body outline: point at the tip, parallel sides, rounded cap.
        path.move(to: p(tip.x, tip.y))
        path.addLine(to: at(0.18, 1))
        path.addLine(to: at(0.94, 1))
        path.addQuadCurve(to: at(0.94, -1), control: p(cap.x, cap.y))
        path.addLine(to: at(0.18, -1))
        path.closeSubpath()
        // The divider between cap and body.
        path.move(to: at(0.68, 1))
        path.addLine(to: at(0.68, -1))
        // The rule the pencil sits on.
        path.move(to: p(0.04, 0.97))
        path.addLine(to: p(0.96, 0.97))
        return path
    }
}

/// The mark beside "APPLY THIS FONT TO YOUR KEYBOARD" in docs/figma/5.png: three solid four-pointed
/// stars — a large one upper-left, a mid one lower-right, a small one lower-left. SF's `sparkles`
/// arranges its three differently and draws much finer points, so it reads as another mark.
struct SparkleCluster: Shape {
    /// Each arm is a quadratic pulled back toward the centre, which is what gives the star its
    /// pinched waist; a four-point polygon would come out as a plain diamond.
    private func star(_ c: CGPoint, _ r: CGFloat, into path: inout Path) {
        let waist = r * 0.24
        path.move(to: CGPoint(x: c.x, y: c.y - r))
        path.addQuadCurve(to: CGPoint(x: c.x + r, y: c.y), control: CGPoint(x: c.x + waist, y: c.y - waist))
        path.addQuadCurve(to: CGPoint(x: c.x, y: c.y + r), control: CGPoint(x: c.x + waist, y: c.y + waist))
        path.addQuadCurve(to: CGPoint(x: c.x - r, y: c.y), control: CGPoint(x: c.x - waist, y: c.y + waist))
        path.addQuadCurve(to: CGPoint(x: c.x, y: c.y - r), control: CGPoint(x: c.x - waist, y: c.y - waist))
        path.closeSubpath()
    }

    func path(in rect: CGRect) -> Path {
        let s = min(rect.width, rect.height)
        var path = Path()
        star(CGPoint(x: rect.minX + s * 0.38, y: rect.minY + s * 0.32), s * 0.32, into: &path)
        star(CGPoint(x: rect.minX + s * 0.74, y: rect.minY + s * 0.70), s * 0.24, into: &path)
        star(CGPoint(x: rect.minX + s * 0.18, y: rect.minY + s * 0.80), s * 0.15, into: &path)
        return path
    }
}

/// The three dots on the "Other" pill. SF's `ellipsis` draws them far finer than Figma does — its
/// are 8px across on a 31px run, which is chunky enough that the symbol reads as a different mark.
struct TripleDot: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let d = rect.height
        let step = (rect.width - d) / 2
        for i in 0..<3 {
            path.addEllipse(in: CGRect(x: rect.minX + step * CGFloat(i), y: rect.minY,
                                       width: d, height: d))
        }
        return path
    }
}
