import CoreGraphics
#if canImport(UIKit)
import UIKit
#endif

/// Every dimension the keyboard is drawn with, derived from the available width.
///
/// These are not invented numbers. They are fitted to measurements of the *system* keyboard, so
/// that a Mochi keyboard lands its keys where a user's thumbs already expect them. That matters
/// more than it sounds: typing accuracy on a phone keyboard is largely muscle memory against a
/// remembered grid, and a themed keyboard that shifts the grid by a few points feels subtly broken
/// in a way users report as "typos" rather than "wrong layout".
///
/// Sources for the fit: the per-device measurement tables in `zoul/ios-keyboards` and
/// `normnorm/norm-keyboard`, which independently agree on the anchor points used below.
struct KeyboardMetrics: Equatable {
    /// Width the metrics were computed for.
    let availableWidth: CGFloat

    let sideInset: CGFloat
    let topInset: CGFloat
    let bottomInset: CGFloat
    /// Horizontal gap between adjacent keys in a row.
    let columnGap: CGFloat
    /// Vertical gap between rows.
    let rowGap: CGFloat
    /// Width of a plain letter key. Every other width is expressed as a multiple of this.
    let standardKeyWidth: CGFloat
    let keyHeight: CGFloat
    let keyCornerRadius: CGFloat
    /// Point size for a letter label.
    let inputLabelPointSize: CGFloat
    /// Point size for `123` / `ABC` / `return` style word labels, which are set smaller than
    /// letters on the system keyboard.
    let systemLabelPointSize: CGFloat
    /// Height of the suggestion strip above the keys, when one is shown.
    let suggestionBarHeight: CGFloat

    /// Number of letter columns the top row is built from. Fixed at 10 for Latin QWERTY; kept as a
    /// property because the derivation below reads as arithmetic rather than a magic 10.
    static let topRowColumnCount: CGFloat = 10

    /// Total height the input view should request for `rowCount` rows.
    func totalHeight(rowCount: Int, includesSuggestionBar: Bool = false) -> CGFloat {
        let rows = CGFloat(max(1, rowCount))
        let keys = topInset + rows * keyHeight + (rows - 1) * rowGap + bottomInset
        return keys + (includesSuggestionBar ? suggestionBarHeight : 0)
    }

    /// - Parameters:
    ///   - width: the input view's width, which the system fixes to the screen width.
    ///   - isLandscape: landscape keyboards are much shorter, and not by the same proportion the
    ///     width grew, so it cannot be derived from width alone.
    init(availableWidth width: CGFloat, isLandscape: Bool) {
        availableWidth = max(240, width)

        // Fitted from the measured portrait key heights: 39pt @320, 43pt @375, 46pt @414. A single
        // linear fit reproduces all three to within a tenth of a point, which is why it is used
        // instead of a per-device table that would need a new entry for every iPhone Apple ships.
        let fittedHeight = 0.0727 * availableWidth + 15.727

        if isLandscape {
            // Landscape is not a scaled portrait keyboard — measured height collapses to ~33pt and
            // stays there across every device width, because the constraint is vertical screen
            // space, not width.
            keyHeight = 33
            topInset = 5
            bottomInset = 3
            rowGap = 6
        } else {
            keyHeight = fittedHeight.rounded(.toNearestOrEven)
            topInset = 10
            bottomInset = 4
            // Measured portrait row gap is ~24% of key height (10.3pt against a 43pt key @375).
            rowGap = (keyHeight * 0.24).rounded(.toNearestOrEven)
        }

        sideInset = availableWidth >= 400 ? 4 : 3
        columnGap = 6

        let usableWidth = availableWidth - sideInset * 2
        let totalGap = columnGap * (KeyboardMetrics.topRowColumnCount - 1)
        standardKeyWidth = (usableWidth - totalGap) / KeyboardMetrics.topRowColumnCount

        // The measured system radius is ~5–6pt, which belongs to a much flatter key than Mochi's
        // design language uses. This deliberately departs from the system value — it is the one
        // metric where matching iOS exactly would fight the product's identity, and unlike key
        // *position* it costs nothing in typing accuracy. Themes may override per role.
        keyCornerRadius = (keyHeight * 0.21).rounded(.toNearestOrEven)

        // Letters are set at roughly 55% of key height on the system keyboard (~23.5pt on a 43pt
        // key); word labels are noticeably smaller so that "return" fits a 1.5-width cap.
        inputLabelPointSize = (keyHeight * 0.55).rounded(.toNearestOrEven)
        systemLabelPointSize = (keyHeight * 0.38).rounded(.toNearestOrEven)

        // The system's own candidate bar is ~44pt portrait and collapses in landscape, where
        // vertical space is the binding constraint and the bar competes directly with the host
        // app's content.
        suggestionBarHeight = isLandscape ? 34 : 44
    }

    #if canImport(UIKit)
    /// Metrics for the current trait environment of a view.
    static func forView(_ view: UIView) -> KeyboardMetrics {
        let width = view.bounds.width > 0 ? view.bounds.width : UIScreen.main.bounds.width
        // `bounds.width > bounds.height` is unreliable on an input view whose height is still being
        // negotiated, so orientation comes from the screen the view is on.
        let screen = view.window?.windowScene?.screen ?? UIScreen.main
        let isLandscape = screen.bounds.width > screen.bounds.height
        return KeyboardMetrics(availableWidth: width, isLandscape: isLandscape)
    }
    #endif
}
