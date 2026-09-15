import SwiftUI

/// The Wallpapers screen's fixed layout, measured off `docs/figma/10.png`.
///
/// **This replaces the old in-app tweak panel (`WallpaperTweaks`) with no visual change.** Every
/// number below is the exact default that panel shipped with, and its per-element `scale`/`x`/`y`
/// adjustments were all identity — nothing had ever been dialled in and persisted — so the screen
/// renders byte-for-byte the way it did with the panel attached. The panel's `.scaleEffect(1)` /
/// `.offset(0, 0)` wrappers were render-time no-ops, not layout participants, so dropping them
/// moves nothing either. What *did* break earlier attempts at removing it is that the panel also
/// owned the real layout constants (`railWidth`, `contentPadH`, the whole type ramp) — delete the
/// file and those went with it, which is why the rail/content gap and every element size shifted.
/// They live here now, unchanged.
///
/// **Responsiveness.** Figma drew this at phone width and every measurement below was taken at
/// 402pt (iPhone 16 Pro). They used to be absolute points, so on any narrower device the fixed
/// 128.73pt rail ate a larger share of the screen and the content pane — sized for what was left
/// over — overflowed and clipped. `init(width:)` divides the real viewport by that 402pt baseline
/// and scales every dimension, so the composition is proportionally identical at any width instead
/// of cropping. At 402pt `s == 1` and the numbers are untouched.
struct WallpaperMetrics {

    /// The width every number here was measured at.
    static let baseWidth: CGFloat = 402

    /// Viewport width ÷ baseline, clamped. The floor keeps the smallest phones (SE, 320pt) legible
    /// rather than shrinking type to nothing; the ceiling stops an iPad blowing a phone-shaped
    /// layout up to cartoon size.
    let s: CGFloat

    init(width: CGFloat) {
        let raw = (width > 0 ? width : Self.baseWidth) / Self.baseWidth
        s = min(max(raw, 0.82), 1.30)
    }

    // MARK: Rail
    var railWidth: CGFloat { 128.73 * s }
    var railPadH: CGFloat { 14.3 * s }
    var railTop: CGFloat { 8 * s }
    var railGap: CGFloat { 18 * s }
    var railPillH: CGFloat { 23.2 * s }
    var railNavGap: CGFloat { 13.4 * s }
    var railThumb: CGFloat { 11.6 * s }
    var railPillBorderOpacity: Double { 0.6 }

    /// Extra breathing room above the three rail blocks, on top of `railGap`. These are the only
    /// numbers on this screen that are *not* straight off Figma — they are the spacing refinements
    /// asked for after the panel came out (nav area, Recently Downloaded and Go Premium each
    /// nudged down a little so the column reads less top-heavy).
    var railNavDrop: CGFloat { 12 * s }
    var railRecentDrop: CGFloat { 14 * s }
    var railPremiumDrop: CGFloat { 12 * s }

    // MARK: Content pane
    var contentPadH: CGFloat { 11.2 * s }
    var contentTop: CGFloat { 6 * s }
    var sectionGap: CGFloat { 15 * s }

    // MARK: Search
    var searchHeight: CGFloat { 29.5 * s }
    var searchRadius: CGFloat { 11.2 * s }
    var searchPadH: CGFloat { 12 * s }

    // MARK: Featured banner
    var bannerAspect: CGFloat { 2.257 }
    var bannerRadius: CGFloat { 10.4 * s }
    var bannerPad: CGFloat { 11 * s }

    // MARK: Chips
    var chipW: CGFloat { 26.98 * s }
    var chipH: CGFloat { 29.8 * s }
    var chipGap: CGFloat { 9.86 * s }
    var chipRadius: CGFloat { 6 * s }
    var chipBorderOpacity: Double { 0.6 }
    var chipBorderWidth: CGFloat { 1.0 }

    // MARK: Cards
    var cardW: CGFloat { 77.57 * s }
    var cardGutter: CGFloat { 7.81 * s }
    /// The Figma card's art crop — slightly wider than tall.
    var cardArtAspect: CGFloat { 1.109 }
    var cardBodyH: CGFloat { 30.9 * s }
    var cardRadius: CGFloat { 9 * s }
    var cardPadH: CGFloat { 6 * s }
    var badgeInset: CGFloat { 5 * s }

    var goPremiumRadius: CGFloat { 9 * s }
    var hairline: CGFloat { 0.5 }

    // MARK: Wallpaper-shaped grids
    /// Portrait tiles use the real source ratio (9:19.5) so a thumbnail is a small wallpaper rather
    /// than a letterboxed crop of one.
    var tileAspect: CGFloat { 9.0 / 19.5 }
    /// Popular Themes on the discovery page: the Figma card, unchanged, laid out 3 across and 3
    /// down instead of scrolling sideways.
    var popularColumns: Int { 3 }
    var popularRows: Int { 3 }
    var popularGutter: CGFloat { 7.81 * s }
    /// Popular's art crop only. Slightly taller than the `cardArtAspect` its row used to share
    /// (1.109 → 0.94, about +14pt of art at phone width) so the thumbnail reads as a portrait
    /// wallpaper rather than a landscape tile. Every other card on the page keeps the Figma crop.
    var popularCardArtAspect: CGFloat { 0.94 }
    /// The "see all" / theme / collection pages, where the pane is the same width but each tile
    /// carries its name and like count.
    var gridColumns: Int { 3 }
    var gridGutter: CGFloat { 7 * s }
    var gridRadius: CGFloat { 8 * s }

    // MARK: Type
    var railTitle: CGFloat { 18.3 * s }
    var railSubtitle: CGFloat { 7.8 * s }
    var railNav: CGFloat { 9.3 * s }
    var railSectionHeading: CGFloat { 8.5 * s }
    var railRecentName: CGFloat { 7.3 * s }
    var railButton: CGFloat { 7.6 * s }
    var goPremiumTitle: CGFloat { 9.3 * s }
    var goPremiumBody: CGFloat { 6.6 * s }
    var goPremiumButton: CGFloat { 7.6 * s }
    var search: CGFloat { 10.2 * s }
    var bannerTitle: CGFloat { 13.4 * s }
    var bannerDesc: CGFloat { 7.8 * s }
    var bannerMeta: CGFloat { 7.3 * s }
    var bannerButton: CGFloat { 8.3 * s }
    var chip: CGFloat { 5.0 * s }
    var sectionTitle: CGFloat { 11.0 * s }
    var seeAll: CGFloat { 10.2 * s }
    var cardName: CGFloat { 8.2 * s }
    var cardMeta: CGFloat { 6.8 * s }
    var badge: CGFloat { 6.1 * s }
}
