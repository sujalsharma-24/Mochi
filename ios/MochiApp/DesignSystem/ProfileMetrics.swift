import SwiftUI

/// Built against docs/figma/3.png (the Profile frame), measured rather than eyeballed — the same
/// method HomeView uses against 1.png, CommunityView against 2.png, FontsView against 5.png and
/// ThemesView against 8.png.
///
/// Every raw figure quoted below is `measured px * 402/2169` (= 0.185339), the frame's own width
/// scale. That alone is not what ships, though: reproduced at pure width scale the page ends 100pt
/// short of where the design puts it above the Create button, and every element reads visibly
/// undersized, because the export is a **16:9** canvas being shown on a ~19.5:9 screen. Three
/// factors spend that surplus, and they are deliberately different from each other:
///
///  * `U` (1.155) scales **y positions**. Solved, not chosen: it is the value that lands the Go
///    Premium card's bottom edge 19.83pt above the Create button's top, which is exactly the gap
///    the frame draws (3401px to 3508px).
///  * `T` (1.18) scales **type, card bodies, and the banner / pair-card heights** — everything
///    whose size is set by the text inside it.
///  * `A` (1.10) scales **artwork**: the avatar, the two mascot discs, the back disc, the tile
///    thumbnails and the liked-row thumbnails. Held below `T` on purpose. Tile artwork is pinned to
///    86.55pt wide by the four-across grid, so growing its height past ~1.10 starts visibly cropping
///    the keyboard's left and right edges through `.fill`.
///
/// **Widths are never scaled.** This frame is horizontally saturated in a way the others are not:
/// four 86.55pt tiles plus three 8.71pt gutters fill the 372pt content width exactly, the two pair
/// cards plus their gutter fill it exactly, and both banners span it edge to edge. There is no room
/// to grow. That is also why the rows whose contents are driven by text width — the tile count
/// rows, the download tile's body, the downloads heading and its filter pills — are laid out as
/// flows in `ProfileView` rather than by absolute x: at `T` their runs are wide enough to collide
/// with the marks beside them, which is exactly what the first build did.
enum ProfileMetrics {
    /// px->pt for this export. Quoted so the raw Figma measurements below stay checkable.
    static let k: CGFloat = 402.0 / 2169.0

    /// **How this page adapts to a bigger phone.**
    ///
    /// Every figure below was solved on an iPhone 16 Pro (402x874pt) and was, until now, a baked
    /// constant. Widths already tracked the screen (`contentWidth`, `cardWidth`), but positions,
    /// type and artwork did not — so on an iPhone 16 Pro Max the same layout drew at 402-point
    /// sizes inside a 440-point screen and read uniformly small, with the leftover height pooling
    /// as dead space under the last card.
    ///
    /// `S` is the one factor that fixes that, and it is deliberately **uniform**: the page keeps
    /// its exact proportions and only grows into the extra room. It is the smaller of the width and
    /// height ratios, so a phone that is relatively taller (or shorter) than the design frame never
    /// gets a layout that overflows the other axis — which is what would make the page start
    /// scrolling for no reason. Clamped so an unusually small device shrinks a little rather than a
    /// lot, and a large one doesn't inflate past the design's own weight.
    static var S: CGFloat { ScreenScale.value }

    /// Every card, the back disc, the avatar and both card columns start on x=81px and the row ends
    /// on x=2087px — 2007px of content, i.e. 372.0pt, inside a 15.01pt margin.
    static let margin: CGFloat = 15.01
    /// Was a baked 372.0 (402pt less both margins). Measured from the real screen instead, so the
    /// banner and the card rows still end on the trailing margin on a wider device rather than
    /// stopping 38pt short of it — see `DesignGrid`.
    static var contentWidth: CGFloat { UIScreen.main.bounds.width - 2 * margin }

    /// The frame has no status bar: its y=0 is the literal top of the screen. On device the
    /// safe-area inset already puts the canvas ~59pt down, which would leave the back disc riding
    /// far below the design; this pulls it back up as far as it can go without putting the glyph
    /// behind the clock, landing the canvas origin ~32pt down.
    static let contentTop: CGFloat = -30

    /// Canvas top to the frame's own tab bar (3623px), carried through `U`.
    static var canvasHeight: CGFloat { (777.16 + extraBreathing) * S }

    /// The vertical room the spacing pass below adds: the profile block starts lower (clear of the
    /// back/settings row), the sections are spread a little, and Go Premium sits lower. Declared
    /// once here so `canvasHeight` grows with it and the page still ends before the tab bar rather
    /// than becoming scrollable.
    static let extraBreathing: CGFloat = 34

    /// Both banner outlines are the same 2px #8A4FA0 stroke, which is 0.37pt here. Drawn at 0.5 so
    /// it survives rasterisation on a 2x screen without reading as a heavier rule than Figma's. The
    /// pair cards and the tiles carry **no** stroke at all, only a soft shadow — confirmed by
    /// scanning for the stroke colour across all six card bands.
    static let hairline: CGFloat = 0.5

    // MARK: - Header

    static var backTop: CGFloat { 16.27 * S }          // 76px
    static var backDisc: CGFloat { 31.20 * S }         // 153px
    static var backArrowHeight: CGFloat { 10.60 * S }  // 52px, centred in the disc

    /// 347px circle whose left edge sits 2px inboard of the margin.
    static var avatar: CGFloat { 70.73 * S }
    static var avatarTop: CGFloat { (67.87 + 22) * S }        // 317px
    static var avatarLeading: CGFloat { 15.38 * S }    // 83px

    /// The camera badge overlaps the ring's lower-right, expressed as a fraction of the avatar so
    /// it tracks `A` rather than drifting off the artwork. It is baked into
    /// `avatar_mochi_creator` too — the crop is circle-masked, so only the inner half survives —
    /// and the disc drawn here is larger than that remnant, so it covers it rather than doubling.
    static var cameraBadge: CGFloat { 21.56 * S }      // 106px
    static let cameraCentreFraction = CGPoint(x: 0.7880, y: 0.8030)   // (364, 603)px on the ring
    static var cameraGlyph: CGFloat { 10.60 * S }

    /// "Mochi Creator"'s M starts at 543px, everything under it at 538px — a 5px optical inset on
    /// the cap rather than a real indent.
    static var nameX: CGFloat { 100.64 * S }           // 543px
    static var nameTop: CGFloat { (63.36 + 22) * S }          // 296px, cap top
    static var textColumnX: CGFloat { 99.71 * S }      // 538px

    /// The seal is `icon_verified`, lifted out of the frame with an alpha key rather than drawn
    /// with SF's `checkmark.seal.fill`: the design's badge has twelve broad scallops and a heavy
    /// white tick, where the SF symbol has finer, more numerous points and a much lighter stroke.
    /// It sits a measured 18.9pt clear of the name's last glyph — pinning it to the frame's own
    /// x instead would put it on top of the name now that the name is set at `T`.
    static var verified: CGFloat { 14.67 * S }         // 72px
    static var verifiedGap: CGFloat { 18.90 * S }      // 102px, name ink to seal
    static var handleTop: CGFloat { (88.62 + 22) * S }        // 414px
    static var bioTop: CGFloat { (103.62 + 22) * S }          // 484px
    static var bioLineGap: CGFloat { 9.41 * S }        // 44px cap-to-cap

    /// Three stat columns, measured at each run's own left edge — Figma does not space them evenly.
    /// The two type sizes below are the **only** ones on the page `T` is not applied to: the row was
    /// signed off at these sizes and deliberately held there. That does leave it a little small
    /// against the name above it — Figma sets the figures at 0.77x the name, where holding them here
    /// makes it 0.68x — so if the row ever starts reading undersized, `T` is the lever.
    static var statNumberTop: CGFloat { (132.07 + 22) * S }   // 617px
    static var statLabelTop: CGFloat { (147.9 + 22) * S }    // 691px
    static var statNumberX: [CGFloat] { [100.08 * S, 145.86 * S, 197.20 * S] }  // 540, 787, 1064px
    static var statLabelX: [CGFloat] { [99.71 * S, 145.49 * S, 197.02 * S] }    // 538, 785, 1063px

    /// White capsule with a 2px #621570 outline, its right edge flush with the content's — which is
    /// how the frame places it (2087px, the same x every card ends on). It is sized from its
    /// contents rather than pinned to the frame's 345px width, so the pencil and the label stay
    /// centred inside it at `T` instead of overflowing as they did when the width was fixed.
    static var editPillTop: CGFloat { (132.72 + 22) * S }     // 620px
    static var editPillHeight: CGFloat { 17.94 * S }   // 82px
    static var editPillLeadPad: CGFloat { 6.86 * S }   // 37px, capsule edge to the pencil
    static var editPillTrailPad: CGFloat { 8.20 * S }  // 44px, label to the capsule's edge
    static var editPencil: CGSize { CGSize(width: 11.70 * S, height: 9.86 * S) }   // 70x59px, trimmed a touch
    static var editIconGap: CGFloat { 3.30 * S }       // pencil to "E"

    // MARK: - Mochi Pro / Go Premium banners
    //
    // Both are 2007x318px with a 67px corner and the same #8A4FA0 hairline. Figures are relative to
    // the banner's own top-left. They differ in where the mascot and the text column sit: Pro insets
    // the disc 129px and its title 439px, Premium 43px and 352px. That asymmetry is in the frame
    // rather than in the measurement — both were re-read off clean rows.

    static var bannerHeight: CGFloat { 69.50 * S }     // 318px
    static var bannerRadius: CGFloat { 12.41 * S }     // 67px
    static var proTop: CGFloat { (166.54 + 24) * S }          // 778px
    static var premiumTop: CGFloat { (660.14 + 46) * S }      // 3084px

    static var bannerMascot: CGFloat { 48.11 * S }     // 236px disc
    static var bannerMascotTop: CGFloat { 7.70 * S }   // 36px
    static var proMascotX: CGFloat { 23.89 * S }       // 129px
    static var premiumMascotX: CGFloat { 7.97 * S }    // 43px

    static var proTitle: CGPoint { CGPoint(x: 81.36 * S, y: 16.91 * S) }      // 439, 79px
    static var proSubtitle: CGPoint { CGPoint(x: 81.55 * S, y: 37.88 * S) }   // 440, 177px
    static var premiumTitle: CGPoint { CGPoint(x: 65.24 * S, y: 21.62 * S) }  // 352, 101px
    static var premiumSubtitle: CGPoint { CGPoint(x: 65.98 * S, y: 42.60 * S) }

    /// The capsule is laid out as a flow — crown, label, chevron — inside these paddings, and then
    /// pinned by its **right** edge, which is the measurement the two banners actually share a
    /// pattern with. Fixing its width instead left the chevron sitting on the capsule's own edge.
    static var upgradePillHeight: CGFloat { 17.94 * S }   // 82px
    static var upgradePillTop: CGFloat { 25.26 * S }      // 118px
    static var upgradePillLeadPad: CGFloat { 5.37 * S }   // 29px
    static var upgradePillTrailPad: CGFloat { 6.30 * S }  // clear of the capsule's right edge
    /// Figma leaves this pill 32pt inboard of the Pro banner's right edge where the Go Premium one
    /// sits 13pt in, which read as the pill crowding the left of the card. Both share the same right
    /// inset now, so the pill sits where the eye expects it on both banners.
    static var proPillRight: CGFloat { contentWidth - 13 * S }
    static var premiumPillRight: CGFloat { contentWidth - 13 * S }
    static var upgradeCrown: CGSize { CGSize(width: 12.85 * S, height: 8.15 * S) }   // 63x40px
    static var upgradeCrownGap: CGFloat { 5.56 * S }      // crown to "U"
    static var upgradeChevronGap: CGFloat { 3.70 * S }    // "n" to the chevron
    static var upgradeChevron: CGFloat { 6.93 * S }

    // MARK: - Section headings

    static var creationsHeadingTop: CGFloat { (251.52 + 26) * S }   // 1175px
    static var seeAllTop: CGFloat { (250.67 + 26) * S }             // 1171px
    /// Not flush with the content's right edge: Figma ends the run at 2010px where the tiles under
    /// it end at 2087px, so it is pinned to its own right edge rather than trailing-aligned.
    /// Kept at its designed 0.85pt past the content edge, but measured from it rather than baked
    /// at the 402pt frame's 372.85, so it tracks the right margin on a wider screen.
    static var seeAllRight: CGFloat { contentWidth + 0.85 }
    static var downloadsHeadingTop: CGFloat { (392.82 + 30) * S }   // 1835px

    // MARK: - MY CREATIONS / MY DOWNLOADS rows
    //
    // Four 467px columns 47px apart, filling the content width exactly (4 x 86.55 + 3 x 8.71 =
    // 372.3pt). Artwork carries `A`, the white body under it `T`.

    static var cardGap: CGFloat { 8.71 * S }               // 47px
    /// Was a baked 86.55 (467px), the width that made these four columns span 402pt exactly.
    static var cardWidth: CGFloat {
        DesignGrid.columnWidth(columns: 4, margin: margin, gap: cardGap)
    }
    static var cardRadius: CGFloat { 11.12 * S }           // 60px, solved off the corner's inset profile
    static var cardPad: CGFloat { 5.56 * S }               // 30px

    static var creationsTop: CGFloat { (269.51 + 26) * S }        // 1259px
    static var creationArtHeight: CGFloat { 62.79 * S }    // 308px
    static var creationBodyHeight: CGFloat { 44.39 * S }   // 203px
    static var creationNameTop: CGFloat { 5.69 * S }       // cap top, from the body's top edge
    static var creationTagTop: CGFloat { 17.94 * S }
    static var creationCountTop: CGFloat { 32.58 * S }
    static var creationHeart: CGSize { CGSize(width: 4.69 * S, height: 4.08 * S) }   // 23x20px
    static var creationDownload: CGFloat { 5.30 * S }      // 26px
    static var creationCountGap: CGFloat { 2.60 * S }      // mark to figure

    static var downloadsTop: CGFloat { (411.53 + 30) * S }        // 1922px
    static var downloadArtHeight: CGFloat { 63.00 * S }    // 309px
    static var downloadBodyHeight: CGFloat { 20.34 * S }   // 93px
    static var downloadNameTop: CGFloat { 5.69 * S }
    static var downloadHeart: CGSize { CGSize(width: 4.49 * S, height: 3.87 * S) }   // 22x19px

    /// 70px disc, inset 35px from the artwork's right edge and 31px from its top. The same disc is
    /// baked into the artwork underneath; drawing it at this size and offset covers that copy.
    static var cardBadge: CGFloat { 14.27 * S }            // 70px
    static var cardBadgeTrailing: CGFloat { 6.49 * S }     // 35px
    static var cardBadgeTop: CGFloat { 5.74 * S }          // 31px

    /// Theme is a solid #9C28B1 capsule with a white label; Font is the same height, transparent
    /// with a #9C28B1 outline and a #9C28B1 label. Both are sized from their labels plus 40px of
    /// lead-in per side, and the pair follows the heading rather than sitting at a fixed x — at `T`
    /// the heading is wide enough to reach the frame's own capsule position.
    static var filterPillTop: CGFloat { (390.89 + 30) * S }       // 1826px
    static var filterPillHeight: CGFloat { 14.43 * S }     // 66px
    static var filterPillPad: CGFloat { 7.41 * S }         // 40px per side
    static var filterPillGap: CGFloat { 5.00 * S }         // 27px between the two
    static var headingToFilterPill: CGFloat { 5.56 * S }   // 30px, "S" to the capsule

    // MARK: - Liked Themes / Followers pair
    //
    // Two 983x634px cards 41px apart. 983 + 41 + 983 = 2007px, the content width exactly, so only
    // the height grows. Figures are relative to a card's own top-left.

    static var pairTop: CGFloat { (510.34 + 32) * S }             // 2384px
    /// Derived from the real content width rather than baked, so the two cards keep filling the row
    /// exactly (and keep their 7.60pt gutter) on any screen; only the height takes `S`.
    static var pairCard: CGSize { CGSize(width: (contentWidth - 7.60 * S) / 2, height: 138.65 * S) }
    static var pairRightX: CGFloat { contentWidth - pairCard.width }
    static var pairRadius: CGFloat { 11.68 * S }           // 63px
    static var pairHeart: CGSize { CGSize(width: 9.99 * S, height: 8.97 * S) }   // 49x44px
    static var pairHeartX: CGFloat { 7.41 * S }            // 40px
    static var pairHeartTop: CGFloat { 10.28 * S }         // 48px
    static var pairHeadingX: CGFloat { 25.76 * S }         // 139px
    static var pairHeadingTop: CGFloat { 11.34 * S }       // 53px
    static var pairSeeAllRight: CGFloat { 174.60 * S }     // 1008px, the run's own right edge
    static var pairChevron: CGFloat { 5.71 * S }

    /// Three rows on the left card, keyed to each thumbnail's top edge.
    static var likedRowTop: CGFloat { 28.25 * S }          // 132px
    static var likedRowPitch: CGFloat { 35.54 * S }        // 166px
    static var likedThumb: CGSize { CGSize(width: 31.20 * S, height: 26.09 * S) }   // 153x128px
    static var likedThumbX: CGFloat { 7.23 * S }           // 39px
    static var likedThumbRadius: CGFloat { 4.90 * S }      // 24px
    static var likedTextX: CGFloat { 44.30 * S }           // 239px
    static var likedNameTop: CGFloat { 5.36 * S }          // below the thumbnail's top
    static var likedBylineTop: CGFloat { 17.02 * S }       // 79px
    static var likedHeartX: CGFloat { 154.57 * S }         // 834px
    static var likedHeart: CGSize { CGSize(width: 5.91 * S, height: 5.30 * S) }     // 29x26px
    static var likedHeartTop: CGFloat { 10.07 * S }
    static var likedCountRight: CGFloat { 174.05 * S }     // 1022px, the run's own right edge
    static var likedCountTop: CGFloat { 10.28 * S }

    /// Two rows on the right card at a **different** pitch — 132px, not the left card's 166px.
    /// Re-read twice off the icon squares and again off the label cap-tops, which agree.
    static var followRowTop: CGFloat { 29.12 * S }         // 136px
    static var followRowPitch: CGFloat { 28.47 * S }       // 132.5px
    static var followIcon: CGFloat { 22.63 * S }           // 111px rounded square
    static var followIconX: CGFloat { 7.97 * S }           // 43px
    static var followIconRadius: CGFloat { 5.71 * S }      // 28px
    static var followGlyph: CGFloat { 12.65 * S }
    static var followTextX: CGFloat { 37.99 * S }          // 205px
    static var followLabelTop: CGFloat { 8.99 * S }        // 42px below the icon's top
    static var followValueRight: CGFloat { 173.11 * S }    // 934px, the chevron's right edge
    static var followChevron: CGFloat { 5.71 * S }
    static var followChevronGap: CGFloat { 1.85 * S }
}

/// Sizes were solved the way Home's, Community's, Fonts' and Themes' were: render the bundled Inter
/// TTF **at the size the device rasterises it (3x, rounded to whole pixels)**, measure the ink, and
/// search for the point size whose width best matches the run's measured width in the export. That
/// last detail matters at this page's sizes — a naive continuous solve was off by up to 8%, because
/// a 5% size change can move every glyph's advance by a whole device pixel and the error compounds
/// across a fourteen-glyph run. The figure in the comment is the target width in export px; the
/// value is that solve, carried through `T`.
///
/// The weight beside each size is not a guess either — at the matched width, the median horizontal
/// ink-run length (the stem width) and the total ink coverage were compared against all four bundled
/// weights. **This page is mostly Medium and Regular.** Only the two section headings are Bold; the
/// banner titles, the pair-card headings and the liked-row names are SemiBold. "Mochi Creator" in
/// particular measures Medium (stem 9px, matching Inter Medium at the same width, where SemiBold
/// gives 10px and Bold 12px) and reads clearly wrong at anything heavier. Every size below is only
/// valid for the weight beside it.
enum ProfileType {
    /// Type also takes `ProfileMetrics.S`, so the page reads the same weight on every phone rather
    /// than shrinking inside a bigger screen.
    private static var S: CGFloat { ProfileMetrics.S }

    static var name: CGFloat { 17.11 * S }          // Medium;   "Mochi Creator" 534px
    /// The handle and the bio were the two runs that read too small to be comfortable — they sit at
    /// 0.45x the name where the frame's own ratio is closer to 0.5x. Lifted to that ratio (and no
    /// further: the bio is a two-line run whose breaks are authored, and a larger size re-breaks it).
    static var handle: CGFloat { 8.60 * S }         // Medium;   "@mochicreator"
    static var bio: CGFloat { 8.40 * S }            // Regular;  bio lines
    static var statNumber: CGFloat { 12.20 * S }    // Medium;   "128"
    static var statLabel: CGFloat { 7.20 * S }      // Regular;  "Creations"
    static var editProfile: CGFloat { 8.91 * S }    // Medium;   "Edit Profile" 213px

    static var bannerTitle: CGFloat { 17.11 * S }   // SemiBold; "Mochi Pro", "Go Premium"
    static var bannerSubtitle: CGFloat { 7.90 * S } // Regular;  banner subtitle lines
    static var upgrade: CGFloat { 7.73 * S }        // Medium;   "Upgrade Plan" 227px

    static var sectionHeading: CGFloat { 10.09 * S } // Bold;    "MY CREATIONS" 363px
    static var seeAll: CGFloat { 10.09 * S }        // Regular;  "see all" 139px
    static var filterPill: CGFloat { 7.32 * S }     // Medium;   "Theme" 115px

    static var cardTitle: CGFloat { 6.55 * S }      // Medium;   "Pastel Rainbow" 215px
    static var cardTag: CGFloat { 6.14 * S }        // Medium;   "Theme" 97px
    static var cardCount: CGFloat { 4.96 * S }      // Medium;   "12.5K" 61px
    static var downloadTitle: CGFloat { 6.55 * S }  // Regular;  "Fantasy Castle Night" 296px

    static var pairHeading: CGFloat { 6.55 * S }    // SemiBold; "Liked Themes" 209px
    static var pairSeeAll: CGFloat { 7.73 * S }     // SemiBold; "See all" 110px
    static var likedName: CGFloat { 7.73 * S }      // SemiBold; "Pastel Pink Sky" 257px
    static var likedByline: CGFloat { 7.32 * S }    // Regular;  "by Vibe Studio" 237px
    static var likedCount: CGFloat { 4.96 * S }     // Medium;   "2.1K" 46px
    static var followLabel: CGFloat { 6.55 * S }    // Medium;   "Followers" 157px
    static var followValue: CGFloat { 5.37 * S }    // Medium;   "2.1K" 53px
}
