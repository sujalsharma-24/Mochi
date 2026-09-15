import SwiftUI

/// How much bigger (or smaller) this phone is than the phone the designs were measured on.
///
/// Every pixel-measured screen in this app — Home, Community, Fonts, Themes, Profile — was solved
/// against an **iPhone 16 Pro, 402x874pt**. Widths in those files already track the real screen
/// (`DesignGrid`), but sizes, type and vertical positions were baked, so on an iPhone 16 Pro Max the
/// same layout drew at 402-point sizes inside a 440-point screen: everything read slightly small and
/// the spare height pooled as dead space at the bottom of the page.
///
/// `value` is the single factor those files multiply by. It is deliberately **uniform** — one number
/// for both axes — because the alternative (stretching height independently) changes the proportions
/// the designs were signed off at. It takes the *smaller* of the two ratios so a phone that is
/// relatively taller or narrower than the design frame never gets a layout that overflows the other
/// axis, which is what would make a page start scrolling when it shouldn't. The clamp keeps a small
/// device from shrinking type past readability and a large one from inflating past the design's own
/// weight.
enum ScreenScale {
    static let baseline = CGSize(width: 402, height: 874)

    static var value: CGFloat {
        let size = UIScreen.main.bounds.size
        let ratio = min(size.width / baseline.width, size.height / baseline.height)
        return min(max(ratio, 0.92), 1.14)
    }

    /// Vertical breathing room scales a little harder than type does: the extra height on a bigger
    /// phone is best spent on the gaps between sections rather than on making every glyph larger.
    static var spacing: CGFloat { 1 + (value - 1) * 1.6 }
}
