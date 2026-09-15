import UIKit

/// Column widths for the Figma-derived grids.
///
/// Every screen in this app is a pixel port of a Figma frame measured against a 402pt-wide device
/// (an iPhone 16 Pro — the Simulator everything was built in), and each grid's column width was
/// baked as the literal point value that made its columns plus gaps span that 402pt exactly.
///
/// On any wider device that literal is simply too small: the block keeps its 402pt width, stays
/// pinned to the leading edge, and leaves the difference as dead space on the right — 38pt of it
/// on a 16 Pro Max, which is the "everything has shifted left" the design looked like on device.
/// The margins and gaps are design decisions and stay exactly as drawn; only the columns, which
/// were always just "whatever divides the leftover evenly", are computed from the real width.
enum DesignGrid {
    /// Width of one column when `columns` of them, separated by `gap`, span the content area
    /// inside `margin` on both sides.
    static func columnWidth(
        columns: Int,
        margin: CGFloat,
        gap: CGFloat,
        screenWidth: CGFloat = UIScreen.main.bounds.width
    ) -> CGFloat {
        (screenWidth - 2 * margin - CGFloat(columns - 1) * gap) / CGFloat(columns)
    }
}
