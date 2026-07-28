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

    /// Every card, the back disc, the avatar and both card columns start on x=81px and the row ends
    /// on x=2087px — 2007px of content, i.e. 372.0pt, inside a 15.01pt margin.
    static let margin: CGFloat = 15.01
    static let contentWidth: CGFloat = 372.0

    /// The frame has no status bar: its y=0 is the literal top of the screen. On device the
    /// safe-area inset already puts the canvas ~59pt down, which would leave the back disc riding
    /// far below the design; this pulls it back up as far as it can go without putting the glyph
    /// behind the clock, landing the canvas origin ~32pt down.
    static let contentTop: CGFloat = -30

    /// Canvas top to the frame's own tab bar (3623px), carried through `U`.
    static let canvasHeight: CGFloat = 777.16

    /// Both banner outlines are the same 2px #8A4FA0 stroke, which is 0.37pt here. Drawn at 0.5 so
    /// it survives rasterisation on a 2x screen without reading as a heavier rule than Figma's. The
    /// pair cards and the tiles carry **no** stroke at all, only a soft shadow — confirmed by
    /// scanning for the stroke colour across all six card bands.
    static let hairline: CGFloat = 0.5

    // MARK: - Header

    static let backTop: CGFloat = 16.27          // 76px
    static let backDisc: CGFloat = 31.20         // 153px
    static let backArrowHeight: CGFloat = 10.60  // 52px, centred in the disc

    /// 347px circle whose left edge sits 2px inboard of the margin.
    static let avatar: CGFloat = 70.73
    static let avatarTop: CGFloat = 67.87        // 317px
    static let avatarLeading: CGFloat = 15.38    // 83px

    /// The camera badge overlaps the ring's lower-right, expressed as a fraction of the avatar so
    /// it tracks `A` rather than drifting off the artwork. It is baked into
    /// `avatar_mochi_creator` too — the crop is circle-masked, so only the inner half survives —
    /// and the disc drawn here is larger than that remnant, so it covers it rather than doubling.
    static let cameraBadge: CGFloat = 21.56      // 106px
    static let cameraCentreFraction = CGPoint(x: 0.7880, y: 0.8030)   // (364, 603)px on the ring
    static let cameraGlyph: CGFloat = 10.60

    /// "Mochi Creator"'s M starts at 543px, everything under it at 538px — a 5px optical inset on
    /// the cap rather than a real indent.
    static let nameX: CGFloat = 100.64           // 543px
    static let nameTop: CGFloat = 63.36          // 296px, cap top
    static let textColumnX: CGFloat = 99.71      // 538px

    /// The seal is `icon_verified`, lifted out of the frame with an alpha key rather than drawn
    /// with SF's `checkmark.seal.fill`: the design's badge has twelve broad scallops and a heavy
    /// white tick, where the SF symbol has finer, more numerous points and a much lighter stroke.
    /// It sits a measured 18.9pt clear of the name's last glyph — pinning it to the frame's own
    /// x instead would put it on top of the name now that the name is set at `T`.
    static let verified: CGFloat = 14.67         // 72px
    static let verifiedGap: CGFloat = 18.90      // 102px, name ink to seal
    static let handleTop: CGFloat = 88.62        // 414px
    static let bioTop: CGFloat = 103.62          // 484px
    static let bioLineGap: CGFloat = 9.41        // 44px cap-to-cap

    /// Three stat columns, measured at each run's own left edge — Figma does not space them evenly.
    /// The two type sizes below are the **only** ones on the page `T` is not applied to: the row was
    /// signed off at these sizes and deliberately held there. That does leave it a little small
    /// against the name above it — Figma sets the figures at 0.77x the name, where holding them here
    /// makes it 0.68x — so if the row ever starts reading undersized, `T` is the lever.
    static let statNumberTop: CGFloat = 132.07   // 617px
    static let statLabelTop: CGFloat = 147.90    // 691px
    static let statNumberX: [CGFloat] = [100.08, 145.86, 197.20]  // 540, 787, 1064px
    static let statLabelX: [CGFloat] = [99.71, 145.49, 197.02]    // 538, 785, 1063px

    /// White capsule with a 2px #621570 outline, its right edge flush with the content's — which is
    /// how the frame places it (2087px, the same x every card ends on). It is sized from its
    /// contents rather than pinned to the frame's 345px width, so the pencil and the label stay
    /// centred inside it at `T` instead of overflowing as they did when the width was fixed.
    static let editPillTop: CGFloat = 132.72     // 620px
    static let editPillHeight: CGFloat = 17.94   // 82px
    static let editPillLeadPad: CGFloat = 6.86   // 37px, capsule edge to the pencil
    static let editPillTrailPad: CGFloat = 8.20  // 44px, label to the capsule's edge
    static let editPencil = CGSize(width: 11.70, height: 9.86)   // 70x59px, trimmed a touch
    static let editIconGap: CGFloat = 3.30       // pencil to "E"

    // MARK: - Mochi Pro / Go Premium banners
    //
    // Both are 2007x318px with a 67px corner and the same #8A4FA0 hairline. Figures are relative to
    // the banner's own top-left. They differ in where the mascot and the text column sit: Pro insets
    // the disc 129px and its title 439px, Premium 43px and 352px. That asymmetry is in the frame
    // rather than in the measurement — both were re-read off clean rows.

    static let bannerHeight: CGFloat = 69.50     // 318px
    static let bannerRadius: CGFloat = 12.41     // 67px
    static let proTop: CGFloat = 166.54          // 778px
    static let premiumTop: CGFloat = 660.14      // 3084px

    static let bannerMascot: CGFloat = 48.11     // 236px disc
    static let bannerMascotTop: CGFloat = 7.70   // 36px
    static let proMascotX: CGFloat = 23.89       // 129px
    static let premiumMascotX: CGFloat = 7.97    // 43px

    static let proTitle = CGPoint(x: 81.36, y: 16.91)      // 439, 79px
    static let proSubtitle = CGPoint(x: 81.55, y: 37.88)   // 440, 177px
    static let premiumTitle = CGPoint(x: 65.24, y: 21.62)  // 352, 101px
    static let premiumSubtitle = CGPoint(x: 65.98, y: 42.60)

    /// The capsule is laid out as a flow — crown, label, chevron — inside these paddings, and then
    /// pinned by its **right** edge, which is the measurement the two banners actually share a
    /// pattern with. Fixing its width instead left the chevron sitting on the capsule's own edge.
    static let upgradePillHeight: CGFloat = 17.94   // 82px
    static let upgradePillTop: CGFloat = 25.26      // 118px
    static let upgradePillLeadPad: CGFloat = 5.37   // 29px
    static let upgradePillTrailPad: CGFloat = 6.30  // clear of the capsule's right edge
    static let proPillRight: CGFloat = 340.47       // 1912px, from the banner's left edge
    static let premiumPillRight: CGFloat = 358.99   // 2012px
    static let upgradeCrown = CGSize(width: 12.85, height: 8.15)   // 63x40px
    static let upgradeCrownGap: CGFloat = 5.56      // crown to "U"
    static let upgradeChevronGap: CGFloat = 3.70    // "n" to the chevron
    static let upgradeChevron: CGFloat = 6.93

    // MARK: - Section headings

    static let creationsHeadingTop: CGFloat = 251.52   // 1175px
    static let seeAllTop: CGFloat = 250.67             // 1171px
    /// Not flush with the content's right edge: Figma ends the run at 2010px where the tiles under
    /// it end at 2087px, so it is pinned to its own right edge rather than trailing-aligned.
    static let seeAllRight: CGFloat = 372.85           // 2010px
    static let downloadsHeadingTop: CGFloat = 392.82   // 1835px

    // MARK: - MY CREATIONS / MY DOWNLOADS rows
    //
    // Four 467px columns 47px apart, filling the content width exactly (4 x 86.55 + 3 x 8.71 =
    // 372.3pt). Artwork carries `A`, the white body under it `T`.

    static let cardWidth: CGFloat = 86.55            // 467px
    static let cardGap: CGFloat = 8.71               // 47px
    static let cardRadius: CGFloat = 11.12           // 60px, solved off the corner's inset profile
    static let cardPad: CGFloat = 5.56               // 30px

    static let creationsTop: CGFloat = 269.51        // 1259px
    static let creationArtHeight: CGFloat = 62.79    // 308px
    static let creationBodyHeight: CGFloat = 44.39   // 203px
    static let creationNameTop: CGFloat = 5.69       // cap top, from the body's top edge
    static let creationTagTop: CGFloat = 17.94
    static let creationCountTop: CGFloat = 32.58
    static let creationHeart = CGSize(width: 4.69, height: 4.08)   // 23x20px
    static let creationDownload: CGFloat = 5.30      // 26px
    static let creationCountGap: CGFloat = 2.60      // mark to figure

    static let downloadsTop: CGFloat = 411.53        // 1922px
    static let downloadArtHeight: CGFloat = 63.00    // 309px
    static let downloadBodyHeight: CGFloat = 20.34   // 93px
    static let downloadNameTop: CGFloat = 5.69
    static let downloadHeart = CGSize(width: 4.49, height: 3.87)   // 22x19px

    /// 70px disc, inset 35px from the artwork's right edge and 31px from its top. The same disc is
    /// baked into the artwork underneath; drawing it at this size and offset covers that copy.
    static let cardBadge: CGFloat = 14.27            // 70px
    static let cardBadgeTrailing: CGFloat = 6.49     // 35px
    static let cardBadgeTop: CGFloat = 5.74          // 31px

    /// Theme is a solid #9C28B1 capsule with a white label; Font is the same height, transparent
    /// with a #9C28B1 outline and a #9C28B1 label. Both are sized from their labels plus 40px of
    /// lead-in per side, and the pair follows the heading rather than sitting at a fixed x — at `T`
    /// the heading is wide enough to reach the frame's own capsule position.
    static let filterPillTop: CGFloat = 390.89       // 1826px
    static let filterPillHeight: CGFloat = 14.43     // 66px
    static let filterPillPad: CGFloat = 7.41         // 40px per side
    static let filterPillGap: CGFloat = 5.00         // 27px between the two
    static let headingToFilterPill: CGFloat = 5.56   // 30px, "S" to the capsule

    // MARK: - Liked Themes / Followers pair
    //
    // Two 983x634px cards 41px apart. 983 + 41 + 983 = 2007px, the content width exactly, so only
    // the height grows. Figures are relative to a card's own top-left.

    static let pairTop: CGFloat = 510.34             // 2384px
    static let pairCard = CGSize(width: 182.19, height: 138.65)
    static let pairRightX: CGFloat = 189.79          // 1105px, i.e. 7.60pt clear of the left card
    static let pairRadius: CGFloat = 11.68           // 63px
    static let pairHeart = CGSize(width: 9.99, height: 8.97)   // 49x44px
    static let pairHeartX: CGFloat = 7.41            // 40px
    static let pairHeartTop: CGFloat = 10.28         // 48px
    static let pairHeadingX: CGFloat = 25.76         // 139px
    static let pairHeadingTop: CGFloat = 11.34       // 53px
    static let pairSeeAllRight: CGFloat = 174.60     // 1008px, the run's own right edge
    static let pairChevron: CGFloat = 5.71

    /// Three rows on the left card, keyed to each thumbnail's top edge.
    static let likedRowTop: CGFloat = 28.25          // 132px
    static let likedRowPitch: CGFloat = 35.54        // 166px
    static let likedThumb = CGSize(width: 31.20, height: 26.09)   // 153x128px
    static let likedThumbX: CGFloat = 7.23           // 39px
    static let likedThumbRadius: CGFloat = 4.90      // 24px
    static let likedTextX: CGFloat = 44.30           // 239px
    static let likedNameTop: CGFloat = 5.36          // below the thumbnail's top
    static let likedBylineTop: CGFloat = 17.02       // 79px
    static let likedHeartX: CGFloat = 154.57         // 834px
    static let likedHeart = CGSize(width: 5.91, height: 5.30)     // 29x26px
    static let likedHeartTop: CGFloat = 10.07
    static let likedCountRight: CGFloat = 174.05     // 1022px, the run's own right edge
    static let likedCountTop: CGFloat = 10.28

    /// Two rows on the right card at a **different** pitch — 132px, not the left card's 166px.
    /// Re-read twice off the icon squares and again off the label cap-tops, which agree.
    static let followRowTop: CGFloat = 29.12         // 136px
    static let followRowPitch: CGFloat = 28.47       // 132.5px
    static let followIcon: CGFloat = 22.63           // 111px rounded square
    static let followIconX: CGFloat = 7.97           // 43px
    static let followIconRadius: CGFloat = 5.71      // 28px
    static let followGlyph: CGFloat = 12.65
    static let followTextX: CGFloat = 37.99          // 205px
    static let followLabelTop: CGFloat = 8.99        // 42px below the icon's top
    static let followValueRight: CGFloat = 173.11    // 934px, the chevron's right edge
    static let followChevron: CGFloat = 5.71
    static let followChevronGap: CGFloat = 1.85
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
    static let name: CGFloat = 17.11          // Medium;   "Mochi Creator" 534px
    static let handle: CGFloat = 7.73         // Medium;   "@mochicreator" 261px
    static let bio: CGFloat = 7.73            // Regular;  bio line 1 757px
    static let statNumber: CGFloat = 11.61    // Medium;   "128" 96px — held, not scaled by T
    static let statLabel: CGFloat = 6.64      // Regular;  "Creations" 163px — held, not scaled by T
    static let editProfile: CGFloat = 8.91    // Medium;   "Edit Profile" 213px

    static let bannerTitle: CGFloat = 17.11   // SemiBold; "Mochi Pro" 378px, "Go Premium" 461px
    static let bannerSubtitle: CGFloat = 7.73 // Regular;  Pro subtitle line 1 720px
    static let upgrade: CGFloat = 7.73        // Medium;   "Upgrade Plan" 227px

    static let sectionHeading: CGFloat = 10.09 // Bold;    "MY CREATIONS" 363px
    static let seeAll: CGFloat = 10.09        // Regular;  "see all" 139px
    static let filterPill: CGFloat = 7.32     // Medium;   "Theme" 115px

    static let cardTitle: CGFloat = 6.55      // Medium;   "Pastel Rainbow" 215px
    static let cardTag: CGFloat = 6.14        // Medium;   "Theme" 97px
    static let cardCount: CGFloat = 4.96      // Medium;   "12.5K" 61px
    static let downloadTitle: CGFloat = 6.55  // Regular;  "Fantasy Castle Night" 296px

    static let pairHeading: CGFloat = 6.55    // SemiBold; "Liked Themes" 209px
    static let pairSeeAll: CGFloat = 7.73     // SemiBold; "See all" 110px
    static let likedName: CGFloat = 7.73      // SemiBold; "Pastel Pink Sky" 257px
    static let likedByline: CGFloat = 7.32    // Regular;  "by Vibe Studio" 237px
    static let likedCount: CGFloat = 4.96     // Medium;   "2.1K" 46px
    static let followLabel: CGFloat = 6.55    // Medium;   "Followers" 157px
    static let followValue: CGFloat = 5.37    // Medium;   "2.1K" 53px
}
