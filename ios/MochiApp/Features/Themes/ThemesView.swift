import SwiftUI

/// Built against docs/figma/8.png (the Themes frame), measured rather than eyeballed — the same
/// method HomeView uses against 1.png, CommunityView against 2.png and FontsView against 5.png.
///
/// 8.png carries a "Pastel Pink Sky" preview popup over the lower half. It occludes only the white
/// card bodies of the third grid row; every artwork, every gutter and the whole downloaded strip
/// are clear, so all the figures below come off the export directly. The two card bodies it does
/// cover (Sakura Train, kawaii boba tea) are read off the un-occluded variant of the same frame.
///
/// The export is a 2169x3853px **16:9** canvas; an iPhone 16 Pro is 402x874pt, roughly 19.5:9.
/// As on Community and Fonts that mismatch needs two factors rather than one:
///
///  * **Widths** come straight from `measured px * 402/2169` (= 0.185339). Every raw px figure
///    quoted below is that number's source. Horizontally the page is at the screen's limit — three
///    118.62pt cards plus two 8.15pt gutters exactly fill the 372.16pt content width — so widths
///    are reproduced exactly and cannot grow without dropping a column.
///  * **Element heights and type** are then multiplied by `S`, for the reason FontsView documents:
///    width-scaling alone lands the frame's 670pt of content in an 874pt content box and reads
///    ~22% small.
///
/// **Gaps between elements are the one vertical dimension `S` is NOT applied to.** Artwork aspect
/// ratios also stay pinned to their measured values (the tiles are 640x440px crops), so the extra
/// height goes to the white card bodies, which is where the enlarged type needs it.
private let S: CGFloat = 1.22

/// The category bar is the one block that takes **no** vertical lift at all. Its seven pills span
/// the content width exactly in Figma — 40px inset, seven pills, six 59.5px gaps, 44px inset, and
/// 2008px of content to hold them — and that budget is pure width, so there is no headroom to give
/// the labels. Fonts settled for 1.13 and let "Other" scroll off; here 1.0 keeps all seven visible
/// and flush, exactly as the frame draws them. The bar still scrolls, as a safety valve for larger
/// Dynamic Type.
private let SPill: CGFloat = 1.0

private enum Metrics {
    /// px->pt for this export. Quoted so the raw Figma measurements below stay checkable.
    static let k: CGFloat = 402.0 / 2169.0

    /// The header discs, the category bar, the card grid and the downloaded tiles all start on
    /// 80px and end on 2088px. One margin, 14.83rather than the app's usual 16 — those extra
    /// 1.2pt per side are what let three 118.62pt cards sit fully inside the screen.
    static let margin: CGFloat = 14.83
    /// Figma's frame has no status bar: its y=0 is the literal top of the screen, so the discs'
    /// 13.9pt inset is measured from there. Pulling back into the 59pt safe area keeps the header
    /// riding as high as the design does without putting it behind the clock.
    static let contentTop: CGFloat = -6

    // MARK: Header — two 154px discs, a 77px palette chip, then the title block centred on the page.
    static let headerTop: CGFloat = 13.90       // 75px
    static let circleButton: CGFloat = 28.54 * S
    static let badge: CGFloat = 14.27 * S       // 77px
    static let badgeRadius: CGFloat = 2.97 * S  // 16px
    static let badgeGlyph: CGFloat = 9.27 * S   // 50px, centred in the chip
    static let badgeToTitle: CGFloat = 4.26     // 23px, chip-right to "T"-left
    static let titleToSubtitle: CGFloat = 2.0   // 37px of ink gap, less Inter's own leading
    static let headerToPills: CGFloat = 16.68   // 90px, disc-bottom to bar-top

    // MARK: Category bar — one white capsule, 2007x104px, outlined in #9C28B1 like the pills inside
    // it, holding seven 76px-tall pills 59.5px apart. See `SPill`: this block is drawn at 1.0.
    static let pillBarHeight: CGFloat = 19.28 * SPill   // 104px
    static let pillHeight: CGFloat = 14.08 * SPill      // 76px
    static let pillBarInset: CGFloat = 7.41 * SPill     // 40px, bar-left to first pill
    static let pillGap: CGFloat = 11.03 * SPill         // 59.5px
    static let pillIconGap: CGFloat = 3.00 * SPill      // 14-22px depending on the mark
    static let pillsToFilter: CGFloat = 6.67            // 36px

    // MARK: Filter row — a 234x104px capsule and a 133x104px one, both white with a #9C28B1
    // outline, ending flush with the right margin. Unlike the grid this row has slack to its left,
    // so `S` is applied to both axes and the two shapes keep their measured proportions.
    static let filterHeight: CGFloat = 19.28 * S
    static let filterWidth: CGFloat = 43.37 * S
    static let slidersWidth: CGFloat = 24.65 * S
    static let filterGap: CGFloat = 8.34 * S    // 45px
    static let filterToGrid: CGFloat = 6.67     // 36px
    /// Both marks are small relative to the capsules that hold them — 39x36px and 44x36px inside
    /// shapes 104px tall — and both are stroked at 4px, which is 0.74pt before the lift.
    static let funnelGlyph = CGSize(width: 7.23 * S, height: 6.67 * S)
    static let slidersGlyph = CGSize(width: 8.15 * S, height: 6.67 * S)
    static let glyphStroke: CGFloat = 0.74 * S

    // MARK: Card grid — 640x640px cards (square at width scale) 44px apart in both axes, 56px
    // corner. 440px of art over a 200px white body; only the body takes `S`.
    static let cardWidth: CGFloat = 118.62
    static let cardGap: CGFloat = 8.15          // 44px
    static let cardRadius: CGFloat = 10.38      // 56px
    static let cardArtAspect: CGFloat = 640.0 / 440.0
    static let cardBodyHeight: CGFloat = 37.07 * S
    static let cardPad: CGFloat = 6.90
    /// 65px white disc, inset 35px from the art's right edge and 25px from its top. It sits on the
    /// artwork, which is not lifted, so neither is it.
    static let download: CGFloat = 12.05
    static let downloadTrailing: CGFloat = 6.49
    static let downloadTop: CGFloat = 4.63

    // Card body, top to bottom: 27px to the title's cap, 52px cap-to-cap between the two text
    // lines, 27px to the buttons, 50px of button, 16px to the card's foot. These are ink-to-ink
    // distances; the values below are those minus Inter's own leading, solved against the render
    // rather than assumed, which is why they are not simply `27 * k * S`.
    static let bodyTopToTitle: CGFloat = 4.50
    static let titleToByline: CGFloat = 3.00
    static let bylineToButtons: CGFloat = 4.50
    static let cardButtonHeight: CGFloat = 9.27 * S
    static let cardButtonGap: CGFloat = 17.79   // 96px
    static let bodyBottom: CGFloat = 2.97 * S   // 16px
    static let heartToCount: CGFloat = 2.60     // 14px
    static let heart = CGSize(width: 5.19 * S, height: 4.63 * S)   // 28x25px

    // MARK: Downloaded strip. Figma leaves a genuine 362px void between the grid's foot and this
    // heading — the un-occluded frame shows the same gap, so it is not the popup's doing.
    /// 362px card-foot to heading-cap. 2.6pt of that is the heading's own internal leading, so the
    /// layout gap is the measurement less that.
    static let gridToHeading: CGFloat = 64.49
    /// The heading row is inset a further 86px on both sides than the tiles under it — "MY" starts
    /// at 166px where the first tile starts at 80px, and "see all" ends at 2007px where the last
    /// tile ends at 2088px. Symmetric, so it is deliberate rather than a stray nudge.
    static let headingInset: CGFloat = 15.94
    static let headingToStrip: CGFloat = 4.18   // 38px ink-to-art, less the heading's descent
    static let seeAllGap: CGFloat = 2.60
    /// Four 461x402px tiles 53px apart; 308px art over a 94px body. Four fill the row exactly.
    static let downloadCard: CGFloat = 85.43
    static let downloadCardGap: CGFloat = 9.82  // 53px
    static let downloadArtAspect: CGFloat = 461.0 / 308.0
    static let downloadBodyHeight: CGFloat = 17.42 * S
    static let downloadRadius: CGFloat = 7.60   // 41px
    static let downloadNamePad: CGFloat = 3.52  // 19px
    static let ellipsisDisc: CGFloat = 12.97    // 70px
    static let ellipsisTrailing: CGFloat = 5.56
    static let ellipsisTop: CGFloat = 5.93

    /// Every outline on the page — the bar, the pills, both filter shapes and each Preview capsule
    /// — is the same 2px #9C28B1 stroke, which is 0.37pt here. Drawn at 0.5 so it survives
    /// rasterisation on a 2x screen without reading as a heavier rule than Figma's.
    static let hairline: CGFloat = 0.5
}

/// Sizes were solved the way Home's, Community's and Fonts' were — render the bundled Inter TTF at
/// the run's weight, measure the ink, and scale until it matches the run's width in the export.
/// The weight beside each size is not a guess either: at the matched width, ink coverage and stem
/// width were compared against all four bundled weights, and **this page is almost entirely Medium
/// and Regular**. Only the page title and the strip heading are Bold. Setting card titles, buttons
/// or bylines heavier than this is the single most visible way the page drifts off the design.
/// Each size is only valid for the weight beside it; changing one means re-solving the other.
private enum Type {
    static let pageTitle: CGFloat = 14.58 * S       // Bold;     "Themes" 305px
    static let pageSubtitle: CGFloat = 6.65 * S     // Medium;   full subtitle 600px
    static let pill: CGFloat = 6.63 * SPill         // Regular;  "Cute" 76px
    static let filter: CGFloat = 7.47 * S           // Medium;   "Filter" 93px
    static let cardTitle: CGFloat = 6.71 * S        // Medium;   "Fantasy Castle Night" 355px
    static let cardByline: CGFloat = 5.52 * S       // Medium;   "by Mochi Studio" 227px
    static let likeCount: CGFloat = 4.43 * S        // Medium;   "12.5K" 61px
    static let previewButton: CGFloat = 5.44 * S    // Regular;  "Preview" 108px
    static let applyButton: CGFloat = 5.42 * S      // Regular;  "Apply" 78px
    static let sectionTitle: CGFloat = 8.81 * S     // Bold;     "MY DOWNLOADED THEMES" 650px
    static let seeAll: CGFloat = 8.84 * S           // Regular;  "see all" 138px
    static let downloadName: CGFloat = 5.53 * S     // Medium;   "Pastel Rainbow" 215px
}

struct ThemesView: View {
    /// The same seven categories the Fonts frame uses, with the same marks.
    private enum Category: String, CaseIterable, Identifiable {
        case all = "All", cute = "Cute", handwritten = "Handwritten", minimal = "Minimal"
        case bold = "Bold", elegant = "Elegant", other = "Other"
        var id: String { rawValue }

        /// Each pill's width is measured rather than derived from its content. Letting the labels
        /// size the pills put the row ~11pt over the content width and pushed "Other" off-screen,
        /// because Inter's advance widths and the SF marks do not add up to the same padding Figma
        /// used on each of the seven. These seven plus six 11.03pt gaps and the bar's two insets
        /// come to 372.15pt — the content width to within a rounding error — so the row lands flush
        /// at both ends exactly as the frame draws it.
        var width: CGFloat {
            switch self {
            case .all:         return 36.14   // 195px
            case .cute:        return 37.99   // 205px
            case .handwritten: return 60.61   // 327px
            case .minimal:     return 45.41   // 245px
            case .bold:        return 33.55   // 181px
            case .elegant:     return 43.55   // 235px
            case .other:       return 33.18   // 179px
            }
        }

        /// Ink width of the mark left of the label, so the SF symbols and the bow artwork are set
        /// to the size Figma draws them at rather than to whatever their glyph metrics imply.
        var iconWidth: CGFloat {
            switch self {
            case .all:         return 6.12    // 33px
            case .cute:        return 9.82    // 53px
            case .handwritten: return 6.86    // 37px
            case .minimal:     return 7.97    // 43px
            case .bold:        return 3.89    // 21px
            case .elegant:     return 3.52    // 19px
            case .other:       return 5.75    // 31px
            }
        }
    }

    @State private var category: Category = .all

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {
                Color.clear.frame(height: Metrics.headerTop)
                header

                Color.clear.frame(height: Metrics.headerToPills)
                categoryBar

                Color.clear.frame(height: Metrics.pillsToFilter)
                filterRow

                Color.clear.frame(height: Metrics.filterToGrid)
                cardGrid

                Color.clear.frame(height: Metrics.gridToHeading)
                downloadedSection
            }
            .padding(.horizontal, Metrics.margin)
            .padding(.top, Metrics.contentTop)
            .padding(.bottom, 100) // clears MochiTabBar, which overlays this view edge-to-edge
        }
        // Applied as a background rather than as a ZStack sibling, for the same reason Community
        // and Fonts do it: a sibling that ignores the safe area drags the whole stack up under the
        // status bar and takes the header with it.
        .background(alignment: .top) {
            ZStack(alignment: .top) {
                // Reconstructed from 8.png's own gutters row by row, not reused from Fonts: this
                // frame runs orchid at the very top, through pale pink across the middle third,
                // to lavender at the foot, and its right edge is consistently cooler than its
                // left. fonts_background reads noticeably pinker across the whole lower half.
                Image("themes_background")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                SparkleField()
            }
            .ignoresSafeArea()
        }
    }

    // MARK: - Header

    private var header: some View {
        ZStack {
            HStack(spacing: 0) {
                circleButton(systemName: "arrow.left")
                Spacer(minLength: 0)
                circleButton(systemName: "magnifyingglass")
            }

            VStack(spacing: Metrics.titleToSubtitle) {
                HStack(spacing: Metrics.badgeToTitle) {
                    Image("icon_palette_outline")
                        .resizable()
                        .renderingMode(.template)
                        .scaledToFit()
                        .foregroundStyle(MochiColor.textPrimary)
                        .frame(width: Metrics.badgeGlyph, height: Metrics.badgeGlyph)
                        .frame(width: Metrics.badge, height: Metrics.badge)
                        .background(
                            MochiGradient.themeBadge,
                            in: RoundedRectangle(cornerRadius: Metrics.badgeRadius, style: .continuous)
                        )

                    Text("Themes")
                        .font(MochiFont.title(Type.pageTitle))
                        .foregroundStyle(MochiColor.logoSolid)
                }

                Text("Browse and apply beautiful themes")
                    .font(MochiFont.caption(Type.pageSubtitle))
                    .foregroundStyle(MochiColor.textGreyWarm)
            }
        }
        .frame(height: Metrics.circleButton)
    }

    /// Both discs are the same ramp under a black glyph. On the Fonts frame the search button is a
    /// flat `logoSolid` disc with a white glyph; here it is not, so they really are a matched pair.
    private func circleButton(systemName: String) -> some View {
        Image(systemName: systemName)
            .font(.system(size: Metrics.circleButton * 0.40, weight: .semibold))
            .foregroundStyle(MochiColor.textPrimary)
            .frame(width: Metrics.circleButton, height: Metrics.circleButton)
            .background(Circle().fill(MochiGradient.themeCircleButton))
    }

    // MARK: - Category pills

    /// One outlined white capsule holding the whole row, which then scrolls inside it. The bar's
    /// own inset is applied as content padding rather than to the ScrollView, so pills can scroll
    /// under the rounded ends instead of stopping short of them.
    private var categoryBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: Metrics.pillGap) {
                ForEach(Category.allCases) { item in
                    categoryPill(item)
                }
            }
            .padding(.horizontal, Metrics.pillBarInset)
        }
        .frame(height: Metrics.pillBarHeight)
        .background(Color.white, in: Capsule())
        .overlay(Capsule().stroke(MochiColor.logoSolid, lineWidth: Metrics.hairline))
    }

    private func categoryPill(_ item: Category) -> some View {
        let isSelected = category == item

        return Button {
            category = item
        } label: {
            HStack(spacing: Metrics.pillIconGap) {
                categoryIcon(item)
                Text(item.rawValue)
                    .font(MochiFont.body(Type.pill))
                    .fixedSize()
            }
            .foregroundStyle(MochiColor.textPrimary)
            .frame(width: item.width, height: Metrics.pillHeight)
            .background {
                if isSelected {
                    Capsule().fill(MochiGradient.themeButton)
                } else {
                    Capsule().stroke(MochiColor.logoSolid, lineWidth: Metrics.hairline)
                }
            }
        }
        .buttonStyle(.plain)
    }

    /// Figma gives each category a different kind of mark: three are set in type ("Aa", "B", "E"),
    /// three are line icons, and "Cute" is a rendered purple bow that is artwork rather than a
    /// glyph — so it is the one that has to come out of the asset catalog.
    @ViewBuilder
    private func categoryIcon(_ item: Category) -> some View {
        Group {
            switch item {
            case .all:
                Image(systemName: "square.grid.2x2.fill").font(.system(size: item.iconWidth * 0.95))
            case .cute:
                Image("icon_bow").resizable().scaledToFit()
            case .handwritten:
                PencilGlyph()
                    .stroke(MochiColor.textPrimary,
                            style: StrokeStyle(lineWidth: 0.55, lineCap: .round, lineJoin: .round))
                    .frame(width: item.iconWidth, height: item.iconWidth)   // 37x37px
            case .minimal:
                Text("Aa").font(MochiFont.heading(Type.pill)).fixedSize()
            case .bold:
                Text("B").font(MochiFont.title(Type.pill)).fixedSize()
            case .elegant:
                Text("E").font(MochiFont.heading(Type.pill)).fixedSize()
            case .other:
                TripleDot()
                    .fill(MochiColor.textPrimary)
                    .frame(width: item.iconWidth, height: 1.48)   // 31x8px
            }
        }
        .frame(width: item.iconWidth)
    }

    // MARK: - Filter row

    /// Right-aligned; unlike the Fonts frame there is no "Soft by" capsule on the left of it.
    private var filterRow: some View {
        HStack(spacing: 0) {
            Spacer(minLength: 0)

            HStack(spacing: Metrics.filterHeight * 0.16) {
                FunnelGlyph()
                    .stroke(MochiColor.logoSolid,
                            style: StrokeStyle(lineWidth: Metrics.glyphStroke, lineJoin: .round))
                    .frame(width: Metrics.funnelGlyph.width, height: Metrics.funnelGlyph.height)
                Text("Filter").font(MochiFont.caption(Type.filter))
            }
            .foregroundStyle(MochiColor.logoSolid)
            .frame(width: Metrics.filterWidth, height: Metrics.filterHeight)
            .background(Color.white, in: Capsule())
            .overlay(Capsule().stroke(MochiColor.logoSolid, lineWidth: Metrics.hairline))

            Color.clear.frame(width: Metrics.filterGap)

            SlidersGlyph()
                .stroke(MochiColor.logoSolid,
                        style: StrokeStyle(lineWidth: Metrics.glyphStroke, lineCap: .round))
                .frame(width: Metrics.slidersGlyph.width, height: Metrics.slidersGlyph.height)
                .frame(width: Metrics.slidersWidth, height: Metrics.filterHeight)
                .background(Color.white, in: Capsule())
                .overlay(Capsule().stroke(MochiColor.logoSolid, lineWidth: Metrics.hairline))
        }
    }

    // MARK: - Card grid

    private var cardGrid: some View {
        VStack(spacing: Metrics.cardGap) {
            ForEach(Array(MockData.themesGrid.chunked(into: 3).enumerated()), id: \.offset) { _, row in
                HStack(spacing: Metrics.cardGap) {
                    ForEach(row) { theme in
                        themeCard(theme)
                    }
                }
            }
        }
    }

    private func themeCard(_ theme: KeyboardTheme) -> some View {
        VStack(spacing: 0) {
            Image(theme.imageAssetName)
                .resizable()
                .scaledToFill()
                .frame(width: Metrics.cardWidth,
                       height: Metrics.cardWidth / Metrics.cardArtAspect)
                .clipped()
                // The disc is already in the crop (it sits over the artwork in Figma, so it comes
                // along with it). Drawing the live control at exactly the measured position covers
                // the baked one pixel-for-pixel and makes it tappable.
                .overlay(alignment: .topTrailing) {
                    Button {} label: {
                        DownloadGlyph()
                            .stroke(MochiColor.downloadGlyph,
                                    style: StrokeStyle(lineWidth: Metrics.download * 0.046,
                                                       lineCap: .round, lineJoin: .round))
                            .frame(width: Metrics.download * 0.477, height: Metrics.download * 0.492)
                            .frame(width: Metrics.download, height: Metrics.download)
                            .background(Circle().fill(.white))
                    }
                    .buttonStyle(.plain)
                    .padding(.trailing, Metrics.downloadTrailing)
                    .padding(.top, Metrics.downloadTop)
                }

            VStack(alignment: .leading, spacing: 0) {
                Color.clear.frame(height: Metrics.bodyTopToTitle)

                // The heart and its count are right-aligned against the *pair* of text lines, not
                // against either one: in Figma the heart's centre lands on the midpoint between the
                // title's cap and the byline's baseline.
                HStack(alignment: .center, spacing: 0) {
                    VStack(alignment: .leading, spacing: Metrics.titleToByline) {
                        // Deliberately no `minimumScaleFactor` on either line. The longest name in
                        // the grid ("Fantasy Castle Night") needs 80.3pt of an ~81pt column, and
                        // at that margin SwiftUI took *any* permitted shrink rather than none —
                        // even `layoutPriority` and a 0.85 floor left the title 12% under size with
                        // clear space beside it. Truncation on an overlong name is the honest
                        // failure here; silently off-size type is not, and Figma sets no shrunk
                        // text anywhere on the page.
                        Text(theme.name)
                            .font(MochiFont.caption(Type.cardTitle))
                            .foregroundStyle(MochiColor.textPrimary)
                            .lineLimit(1)

                        Text(theme.creatorName)
                            .font(MochiFont.caption(Type.cardByline))
                            .foregroundStyle(MochiColor.creatorLink)
                            .lineLimit(1)
                    }
                    // Without this the `Spacer` competes with the text column for the row's slack
                    // and SwiftUI resolves the tie by letting `minimumScaleFactor` shrink the title
                    // — it came out 12% under its set size with 11pt of clear space still to its
                    // right. The priority makes the column take its ideal width first and the
                    // Spacer absorb only what is genuinely left over.
                    .layoutPriority(1)

                    Spacer(minLength: 1)

                    // The heart is pinned to its measured 5.19x4.63pt ink box. Left to its own
                    // advance width, SF's `heart.fill` claims several points more than it draws,
                    // and that surplus came straight off the title's share of the row — enough for
                    // `minimumScaleFactor` to shrink "Fantasy Castle Night" by 12%.
                    HStack(spacing: Metrics.heartToCount) {
                        Image(systemName: "heart.fill")
                            .font(.system(size: Type.likeCount * 1.20))
                            .foregroundStyle(MochiColor.heart)
                            .frame(width: Metrics.heart.width, height: Metrics.heart.height)
                        Text(theme.likeCountFormatted)
                            .font(MochiFont.caption(Type.likeCount))
                            .foregroundStyle(MochiColor.textPrimary)
                            .fixedSize()
                    }
                    .fixedSize()
                }

                Color.clear.frame(height: Metrics.bylineToButtons)

                HStack(spacing: Metrics.cardButtonGap) {
                    Text("Preview")
                        .font(MochiFont.body(Type.previewButton))
                        .foregroundStyle(MochiColor.textPrimary)
                        .frame(maxWidth: .infinity)
                        .frame(height: Metrics.cardButtonHeight)
                        .background(Color.white, in: Capsule())
                        .overlay(Capsule().stroke(MochiColor.logoSolid, lineWidth: Metrics.hairline))

                    Text("Apply")
                        .font(MochiFont.body(Type.applyButton))
                        .foregroundStyle(MochiColor.textPrimary)
                        .frame(maxWidth: .infinity)
                        .frame(height: Metrics.cardButtonHeight)
                        .background(MochiGradient.themeButton, in: Capsule())
                }

                Color.clear.frame(height: Metrics.bodyBottom)
            }
            .padding(.horizontal, Metrics.cardPad)
            .frame(width: Metrics.cardWidth, height: Metrics.cardBodyHeight)
            .background(Color.white)
        }
        .frame(width: Metrics.cardWidth)
        .clipShape(RoundedRectangle(cornerRadius: Metrics.cardRadius, style: .continuous))
    }

    // MARK: - My downloaded themes

    private var downloadedSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 0) {
                Text("MY DOWNLOADED THEMES")
                    .font(MochiFont.title(Type.sectionTitle))
                    .foregroundStyle(MochiColor.textPrimary)
                Spacer(minLength: 4)
                HStack(spacing: Metrics.seeAllGap) {
                    Text("see all").font(MochiFont.body(Type.seeAll))
                    Image(systemName: "chevron.right")
                        .font(.system(size: Type.seeAll * 0.80, weight: .regular))
                }
                .foregroundStyle(MochiColor.logoSolid)
            }
            .padding(.horizontal, Metrics.headingInset)

            Color.clear.frame(height: Metrics.headingToStrip)

            // Bleeds back out of the page gutter so the fourth tile reaches the right margin
            // exactly as it does in Figma, then scrolls beyond it.
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Metrics.downloadCardGap) {
                    ForEach(MockData.downloadedThemes) { theme in
                        downloadCard(theme)
                    }
                }
                .padding(.horizontal, Metrics.margin)
            }
            .padding(.horizontal, -Metrics.margin)
        }
    }

    private func downloadCard(_ theme: KeyboardTheme) -> some View {
        VStack(spacing: 0) {
            Image(theme.imageAssetName)
                .resizable()
                .scaledToFill()
                .frame(width: Metrics.downloadCard,
                       height: Metrics.downloadCard / Metrics.downloadArtAspect)
                .clipped()
                .overlay(alignment: .topTrailing) {
                    Image(systemName: "ellipsis")
                        .font(.system(size: Metrics.ellipsisDisc * 0.44, weight: .semibold))
                        .foregroundStyle(MochiColor.textPrimary)
                        .frame(width: Metrics.ellipsisDisc, height: Metrics.ellipsisDisc)
                        .background(Circle().fill(.white))
                        .padding(.trailing, Metrics.ellipsisTrailing)
                        .padding(.top, Metrics.ellipsisTop)
                }

            Text(theme.name)
                .font(MochiFont.caption(Type.downloadName))
                .foregroundStyle(MochiColor.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .padding(.horizontal, Metrics.downloadNamePad)
                .frame(width: Metrics.downloadCard, height: Metrics.downloadBodyHeight,
                       alignment: .leading)
                .background(Color.white)
        }
        .frame(width: Metrics.downloadCard)
        .clipShape(RoundedRectangle(cornerRadius: Metrics.downloadRadius, style: .continuous))
    }
}

private extension Array {
    /// Fixed-width rows for the card grid. `LazyVGrid` would also lay this out, but the grid needs
    /// each card to keep its measured 118.62pt width rather than share the row equally, and a
    /// `.fixed()` column set plus a trailing `Spacer` reproduces that less directly than this does.
    func chunked(into size: Int) -> [[Element]] {
        stride(from: 0, to: count, by: size).map { Array(self[$0 ..< Swift.min($0 + size, count)]) }
    }
}

#Preview {
    ThemesView()
}
