import SwiftUI

/// Everything one Home action card needs, held per-card. The two cards ("Custom Create" / "Choose
/// from Library") deliberately do NOT share these: their artwork has different proportions and
/// different transparent bleed — the palette is 1.21:1, the library stack 1.05:1 — so a single icon
/// size or offset that centres one leaves the other looking off. Title and subtitle are split for
/// the same reason: the design gives them different weights, and each needed its own vertical nudge
/// to sit right.
///
/// Only the outer box (ratio / gap / radius) is shared, over in `HomeMetrics` — the two cards must
/// stay identical in size, which was a bug worth fixing once already.
///
/// These numbers were dialled in against the design on a running build rather than derived, so they
/// are deliberately not round.
struct ActionCardTuning {
    var hPad: CGFloat
    var vPad: CGFloat

    var iconSize: CGFloat
    var iconHOffset: CGFloat
    var iconVOffset: CGFloat
    var iconTextGap: CGFloat

    var titleSize: CGFloat      // Inter SemiBold
    var titleVOffset: CGFloat
    var titleGap: CGFloat       // title -> subtitle

    var subtitleSize: CGFloat   // Inter Regular
    var subtitleVOffset: CGFloat

    var textColumnExtra: CGFloat
    var textVOffset: CGFloat

    var buttonWidth: CGFloat    // 332px in Figma
    var buttonHeight: CGFloat   // 115px
    var buttonTextSize: CGFloat
    var buttonVOffset: CGFloat

    static let customCreate = ActionCardTuning(
        hPad: 19,
        vPad: 9.5,
        iconSize: 52,
        iconHOffset: 0,
        iconVOffset: 2.5,
        iconTextGap: 17.5,
        titleSize: 9.5,
        titleVOffset: -9,
        titleGap: 2,
        subtitleSize: 8.5,
        subtitleVOffset: -6.5,
        textColumnExtra: 0,
        textVOffset: 0,
        buttonWidth: 68,
        buttonHeight: 22,
        buttonTextSize: 10,
        buttonVOffset: 0
    )

    static let chooseLibrary = ActionCardTuning(
        hPad: 24.5,
        vPad: 8.5,
        iconSize: 52,
        iconHOffset: 0,
        iconVOffset: 0.5,
        iconTextGap: 12.5,
        titleSize: 9.5,
        titleVOffset: -5.5,
        titleGap: 2,
        subtitleSize: 8.5,
        subtitleVOffset: 0,
        textColumnExtra: 0,
        textVOffset: 0,
        buttonWidth: 68,
        buttonHeight: 22,
        buttonTextSize: 10,
        buttonVOffset: 0
    )
}

/// Home-screen measurements. Most were taken off docs/figma/1.png — a 2169x3865px, i.e. 16:9,
/// canvas where px * 0.1853 = pt on a 402pt-wide screen — and the comments cite the raw px figure so
/// a value that later drifts can be traced back to what the design actually said. The rest were
/// dialled in on a running build.
///
/// Because iPhone 16 Pro is ~19.5:9 rather than the design's 16:9, reproducing the layout at true
/// width leaves ~80pt spare vertically. That surplus is spent on the flexible `Spacer(minLength:)`s
/// between sections in HomeView, so the page breathes evenly instead of dead-ending in a void above
/// the tab bar.
enum HomeMetrics {
    // MARK: Header
    /// Negative pulls the wordmark up toward the status bar; the safe-area inset already puts it
    /// ~59pt down, which reads lower than the design.
    static let headerTopPadding: CGFloat = -6
    static let logoSize: CGFloat = 44.5          // Fredoka, matched to the 619px wordmark
    static let createCustomIcon: CGFloat = 33    // 177px circle
    static let createCustomLabel: CGFloat = 9.5  // Inter Medium, "Create Custom" is 368px
    static let gapHeaderCarousel: CGFloat = 18

    // MARK: Top "recently applied" carousel
    static let carouselGap: CGFloat = 7          // 44px in Figma
    /// Figma art is 640x475px (1.35). Lower values make the cards taller, which is the only way to
    /// grow them — their width is already pinned by the screen margins.
    static let carouselArtRatio: CGFloat = 1.28
    static let carouselNameGap: CGFloat = 8      // 54px art bottom -> name cap
    static let themeNameSize: CGFloat = 10.5     // Inter Medium
    static let carouselArtRadius: CGFloat = 9    // 49px corner
    static let carouselNameReserve: CGFloat = 14
    static let gapCarouselCards: CGFloat = 22

    // MARK: Action cards — shared box; per-card values live in ActionCardTuning
    static let actionCardRatio: CGFloat = 1.73
    static let actionCardGap: CGFloat = 10.5     // 65px
    static let actionCardRadius: CGFloat = 13    // 72px corner
    static let gapCardsPills: CGFloat = 21

    // MARK: FONTS / THEMES toggle
    static let pillHeight: CGFloat = 27          // 138px in Figma = 25pt
    static let pillLabelSize: CGFloat = 15.5     // Inter Bold, "THEMES" is 331px
    static let pillExtraInset: CGFloat = 6       // Figma insets these 154px (28pt) per side
    static let pillGap: CGFloat = 11             // 61px
    static let gapPillsSection: CGFloat = 24

    // MARK: Section headers
    static let sectionHeaderSize: CGFloat = 10.5 // Inter Bold, "POPULAR THEMES" is 439px
    static let seeAllSize: CGFloat = 10          // Inter Regular, "see all" is 138px
    static let sectionHeaderGap: CGFloat = 10

    // MARK: Popular Themes row
    static let popularCardWidth: CGFloat = 158   // 779px = 144pt in Figma
    static let popularCardGap: CGFloat = 9       // 48px
    static let popularArtRadius: CGFloat = 13    // 70px corner
    static let gapThemesFonts: CGFloat = 22

    // MARK: Font Collection row
    static let fontCardWidth: CGFloat = 104      // 487px = 90pt in Figma
    static let fontCardRatio: CGFloat = 487.0 / 401.0
    static let fontCardGap: CGFloat = 9          // 48px
    static let fontCardRadius: CGFloat = 10      // 52px corner
    static let bottomGap: CGFloat = 41

    // MARK: Tab bar
    static let tabIconSize: CGFloat = 18         // Figma: 17.1pt palette, 15.9pt community
    static let tabKeyboardWidth: CGFloat = 23    // 122px badge
    static let tabLabelSize: CGFloat = 9         // Figma solves to ~7pt
    static let tabCreateSize: CGFloat = 50
}
