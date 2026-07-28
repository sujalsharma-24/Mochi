import SwiftUI

/// Built against docs/figma/5.png (the Fonts frame), measured rather than eyeballed — the same
/// method HomeView uses against 1.png and CommunityView against 2.png.
///
/// The export is a 2161x3840px **16:9** canvas; an iPhone 16 Pro is 402x874pt, roughly 19.5:9.
/// As on Community that mismatch needs two factors rather than one:
///
///  * **Widths** come straight from `measured px * 402/2161` (= 0.18602). Every raw px figure
///    quoted below is that number's source. Horizontally the page is already at the screen's
///    limit — the grid is three 119.06pt cards in 373pt of gutter-to-gutter space and the letter
///    grid is thirteen 18.8pt cells across the same span — so widths are reproduced exactly and
///    cannot grow without dropping a column.
///  * **Element heights and type** are then multiplied by `S`. Width-scaling alone lands the
///    design's 638pt of content in a ~780pt content box, which reads ~22% small and pools the
///    difference as dead space above the tab bar.
///
/// **Gaps between elements are the one vertical dimension `S` is NOT applied to** — enlarging the
/// elements *and* the air between them overruns the screen. Artwork aspect ratios stay pinned to
/// their measured values (the tiles are 640x442px crops), so the extra height goes to the white
/// card bodies, which is exactly where the enlarged type needs it.
/// 1.22 left the downloads row finishing ~67pt above the tab bar where Figma leaves 35pt, i.e. the
/// page still under-filled the screen by about that much. 1.27 spends the difference on the
/// elements and lands the last card where the design puts it.
private let S: CGFloat = 1.27

/// The filter pills get a smaller lift than everything else. All seven have to span the content
/// width exactly — Figma ends "Other" flush with the right margin — and seven labels at the full
/// `S` overrun that by about a pill's worth, pushing "Other" off-screen. 1.13 is the largest factor
/// that still fits the row at credible padding, so the pills read only slightly smaller than the
/// rest of the page rather than losing a category off the end of it.
private let SPill: CGFloat = 1.13

/// Same story in the downloaded strip, for the same reason: the five cards are width-bound at
/// 67.5pt each, and a name set at the full `S` no longer clears its "Free"/"Pro" chip, so every
/// card wrapped ("Bubble / Cute") where Figma wraps only "Handwritten Elegant".
private let SDownload: CGFloat = 1.10

private enum Metrics {
    /// px->pt for this export. Quoted so the raw Figma measurements below stay checkable.
    static let k: CGFloat = 402.0 / 2161.0

    /// Left edge of the header, the pill bar, the card grid and both panels all land on 75-80px.
    /// One margin, and it is 14.3 rather than the app's usual 16 — those extra 1.7pt per side are
    /// what let three 119.06pt cards sit fully inside the screen.
    static let margin: CGFloat = 14.32
    /// Figma's frame has no status bar: its y=0 is the literal top of the screen, so the back
    /// button's 14.9pt inset is measured from there. Pulling back into the 59pt safe area keeps the
    /// header riding as high as the design does without putting it behind the clock.
    static let contentTop: CGFloat = -8

    /// Every outline on this page — pills, both panels, the card buttons, the type field, the two
    /// sort-row controls — is a single 1px line in a 2161px-wide export, i.e. 0.19pt. Reproducing
    /// that literally gives a sub-pixel line that Core Animation greys out, so it is drawn at the
    /// thinnest weight that still resolves cleanly at 3x. Everything shares this one value; the
    /// design uses no heavier stroke anywhere.
    static let hairline: CGFloat = 0.5

    // MARK: Header — 150px circles, a 60px "Aa" chip, then the title block centred on the page.
    static let circleButton: CGFloat = 27.9 * S
    static let headerTop: CGFloat = 14.9
    /// 65x61px, so very slightly wider than tall rather than square.
    static let badge: CGSize = CGSize(width: 12.1 * S, height: 11.3 * S)
    static let badgeRadius: CGFloat = 2.6 * S
    static let badgeToTitle: CGFloat = 4.1     // 22px, chip-right to "F"-left
    static let titleToSubtitle: CGFloat = 1.0  // 20px of ink gap, less Inter's own leading
    static let headerToPills: CGFloat = 10.0   // 69px, less leading

    // MARK: Filter pills — a single white capsule bar, 2001x100px, holding seven 56px-tall pills
    // 60px apart. The bar scrolls: "Other" ends flush with the right margin in Figma.
    static let pillBarHeight: CGFloat = 18.6 * S
    static let pillHeight: CGFloat = 10.4 * S
    /// The bar spans the full content width, so the seven pills have to span it too — with the
    /// labels held at `SPill` these three values are what take up the slack. Set from the type
    /// rather than from Figma's own 37/60px: reproducing those left ~43pt of bare white after
    /// "Other", which is exactly the gap they close.
    static let pillBarInset: CGFloat = 6.0
    static let pillGap: CGFloat = 9.0
    static let pillPad: CGFloat = 6.2
    static let pillIconGap: CGFloat = 2.4
    static let pillsToSort: CGFloat = 6.6      // 35px

    // MARK: Sort row — two capsules and one 120x100px rounded container, all 100px tall. The
    // trailing control is a capsule wider than it is tall, not the circle it reads as at 1x.
    static let sortHeight: CGFloat = 18.6 * S
    static let settings: CGSize = CGSize(width: 22.3 * S, height: 18.6 * S)
    static let sortToGrid: CGFloat = 8.7       // 47px

    // MARK: Card grid — 640x640px cards (square, at width scale) 43px apart in both axes, 46px
    // corner. 442px of art over a 198px white body; only the body takes `S`.
    static let cardWidth: CGFloat = 119.06
    static let cardGap: CGFloat = 8.0          // 43px
    static let cardRadius: CGFloat = 8.6       // 46px
    static let cardArtAspect: CGFloat = 640.0 / 442.0
    /// The body is where `S`'s extra height lands, but it was taking more than the enlarged type
    /// needs and squeezing the artwork's share of the card. Figma gives the body 198 of the card's
    /// 640px — 31% — and this is the value that reproduces that split once `S` is applied to the
    /// body alone; anything larger and the buttons drift away from the subtitle.
    static let cardBodyHeight: CGFloat = 31.5 * S
    static let cardPad: CGFloat = 8.2          // 44px
    static let cardButtonHeight: CGFloat = 8.2 * S
    static let cardButtonGap: CGFloat = 14.1   // 76px
    /// 80px white disc, inset 44px from the art's right edge and 35px from its top.
    static let heart: CGFloat = 14.9 * S
    static let heartInset: CGFloat = 8.2
    static let heartTopInset: CGFloat = 6.5
    static let chipRadius: CGFloat = 2.5 * S
    static let gridToPanel: CGFloat = 8.8      // 47px

    // MARK: Font-preview panel — 2004x730px, 1pt #9C28B1 stroke, 8.4pt inner padding.
    static let panelRadius: CGFloat = 9.3
    static let panelPad: CGFloat = 8.4         // 45px
    /// Widened from Figma's measured 79.1pt. The field is width-bound but its placeholder is not —
    /// at `S` the label no longer fits and truncated to "Type somethin...". The panel has the room
    /// to its left, so the field takes it rather than the placeholder shrinking out of step with
    /// the rest of the page.
    static let fieldSize: CGSize = CGSize(width: 92.0, height: 11.3 * S)
    static let fieldRadius: CGFloat = 5.0 * S
    /// Thirteen cells across on a 27.7pt pitch; the width is fixed and the gap derived from it, so
    /// the row always ends flush with the panel's inner edge.
    static let letterColumns: Int = 13
    static let letterCell: CGFloat = 18.8      // 101px
    static let letterCellHeight: CGFloat = 14.9 * S
    static let letterRowGap: CGFloat = 8.2     // 44px
    static let letterCellRadius: CGFloat = 1.6 * S
    static let headingToGrid: CGFloat = 4.5
    static let gridToSlider: CGFloat = 6.0
    static let sliderKnob: CGFloat = 4.6 * S
    static let sliderTrack: CGFloat = 1.3 * S
    static let panelToApply: CGFloat = 10.0    // 54px

    // MARK: Apply panel — 2004x190px.
    static let applyPanelHeight: CGFloat = 35.3 * S
    static let applyButton: CGSize = CGSize(width: 64.7, height: 17.3 * S)
    static let applyToDownloads: CGFloat = 10.6

    // MARK: My downloaded fonts — five 363x332px cards 49px apart; 232px art over a 100px body.
    /// Back to Figma's measured 363px. These had been widened to stop the names wrapping, which
    /// left the row visibly larger than the design; `SDownload` handles the wrapping instead, so
    /// the cards can sit at their true width and the five again end flush with the right margin.
    static let downloadCard: CGFloat = 67.5
    static let downloadCardGap: CGFloat = 9.1  // 49px
    static let downloadArtAspect: CGFloat = 363.0 / 232.0
    static let downloadBodyHeight: CGFloat = 18.4 * S
    static let downloadRadius: CGFloat = 5.6
    static let headingToDownloads: CGFloat = 7.5
}

/// Sizes were solved the way Home's and Community's were — render the bundled Inter TTF at the
/// run's weight, measure the ink, and scale until it matches the run's width in the export — so
/// each size is only valid for the weight beside it. Changing one means re-solving the other.
/// `S` lifts the whole set together.
/// Weights were re-read off the export at 6x rather than inferred from each run's role, and most of
/// this page is **lighter** than the app's other screens. Only four runs are actually Bold — the
/// two "FONT PREVIEW" labels, the apply-panel heading and "MY DOWNLOADED FONTS" — plus the single
/// leading letterforms inside the Minimal/Bold/Elegant pills, which are Bold marks beside Regular
/// labels. Everything else, including the "Fonts" page title, is Regular or Medium.
private enum Type {
    static let pageTitle: CGFloat = 14.42 * S      // Medium;   "Fonts" 206px
    static let pageSubtitle: CGFloat = 6.60 * S    // Regular;  full subtitle 722px
    static let badgeGlyph: CGFloat = 5.40 * S      // Medium;   "Aa" 35px
    static let pill: CGFloat = 6.60 * SPill        // Regular;  "Handwritten" 205px
    static let sort: CGFloat = 7.35 * S            // Regular;  "Sort by" 135px / "Popular" 143px
    static let cardTitle: CGFloat = 7.35 * S       // Medium;   "Bubble Cute" 231px
    static let cardSubtitle: CGFloat = 5.49 * S    // Medium;   "Rounded & Playful" 256px
    static let chip: CGFloat = 5.49 * S            // Medium;   "Free" 61px
    static let cardButton: CGFloat = 5.30 * S      // Regular;  "Preview" 109px
    static let panelHeading: CGFloat = 8.84 * S    // Bold;     "FONT PREVIEW" 361px
    static let placeholder: CGFloat = 6.42 * S     // Regular;  "Type something..."
    /// Kaushan Script — see `LetterGrid`. This is the one size on the page taken from Figma's
    /// Design panel rather than solved from ink: it reads "Kaushan Script Regular 22". Rendering
    /// the bundled TTF and matching its "A"/"C" against the export lands on 44px, which fixes the
    /// frame at 1080pt wide (44/22 = 2x export) and so puts 1 Figma unit at 402/1080 = 0.372pt.
    /// Every solved size elsewhere in this table checks out against that ratio.
    static let letter: CGFloat = 8.19 * S
    static let sliderLabel: CGFloat = 6.6 * S      // Bold;     the repeated "FONT PREVIEW"
    static let percent: CGFloat = 7.16 * S         // Regular;  "100%" 99px
    static let applyHeading: CGFloat = 8.84 * S    // Bold;     923px
    static let applySubtitle: CGFloat = 6.42 * S   // Regular;  646px
    static let applyButton: CGFloat = 7.0 * S      // Medium;   "Apply Font"
    static let sectionTitle: CGFloat = 8.84 * S    // Bold;     "MY DOWNLOADED FONTS" 614px
    static let seeAll: CGFloat = 8.65 * S          // Regular;  "see all" 139px
    static let downloadName: CGFloat = 5.49 * SDownload // Regular; "Bubble Cute" 174px
    static let downloadChip: CGFloat = 4.00 * SDownload // Regular; "Pro" 33px
}

struct FontsView: View {
    /// Figma spells the sort control "Soft by" — kept verbatim, like Community's "serch themes".
    private enum Category: String, CaseIterable, Identifiable {
        case all = "All", cute = "Cute", handwritten = "Handwritten", minimal = "Minimal"
        case bold = "Bold", elegant = "Elegant", other = "Other"
        var id: String { rawValue }
    }

    @State private var category: Category = .all
    @State private var liked: Set<String> = Set(MockData.fontCollection.map(\.id))
    @State private var selectedFontID: String = "handwritten-elegant"
    @State private var sampleText: String = ""
    @State private var previewScale: Double = 0.45

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {
                Color.clear.frame(height: Metrics.headerTop)
                header

                Color.clear.frame(height: Metrics.headerToPills)
                categoryBar

                Color.clear.frame(height: Metrics.pillsToSort)
                sortRow

                Color.clear.frame(height: Metrics.sortToGrid)
                cardGrid

                Color.clear.frame(height: Metrics.gridToPanel)
                previewPanel

                Color.clear.frame(height: Metrics.panelToApply)
                applyPanel

                Color.clear.frame(height: Metrics.applyToDownloads)
                downloadedSection
            }
            .padding(.horizontal, Metrics.margin)
            .padding(.top, Metrics.contentTop)
            .padding(.bottom, 100) // clears MochiTabBar, which overlays this view edge-to-edge
        }
        // Applied as a background rather than as a ZStack sibling, for the same reason Community
        // does it: a sibling that ignores the safe area drags the whole stack up under the status
        // bar and takes the header with it.
        .background(alignment: .top) {
            ZStack(alignment: .top) {
                // Not Home's backdrop. Sampling 5.png's uncovered gutters row by row gives a
                // markedly paler field than 1.png/2.png do — orchid #E2A8F6 at the top, pale pink
                // #FCE2F3 through the middle, lavender #E4CCFC at the bottom — where Home's runs
                // hot pink to periwinkle. Reusing home_background here read far too saturated, so
                // this page carries its own reconstruction of that gradient.
                Image("fonts_background")
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
                circleButton(systemName: "arrow.left", filled: false)
                Spacer(minLength: 0)
                circleButton(systemName: "magnifyingglass", filled: true)
            }

            VStack(spacing: Metrics.titleToSubtitle) {
                HStack(spacing: Metrics.badgeToTitle) {
                    // The chip is a gradient, not the flat pink it reads as at 1x: #E481C6 on the
                    // left running to #B07EE5 on the right, the same ramp the page's buttons use.
                    Text("Aa")
                        .font(MochiFont.itemName(Type.badgeGlyph))
                        .foregroundStyle(MochiColor.textPrimary)
                        .frame(width: Metrics.badge.width, height: Metrics.badge.height)
                        .background(
                            MochiGradient.fontsAccent,
                            in: RoundedRectangle(cornerRadius: Metrics.badgeRadius, style: .continuous)
                        )

                    Text("Fonts")
                        .font(MochiFont.itemName(Type.pageTitle))
                        .foregroundStyle(MochiColor.logoSolid)
                }

                Text("Choose the perfect font for your keyboard")
                    .font(MochiFont.body(Type.pageSubtitle))
                    .foregroundStyle(MochiColor.textGreyWarm)
            }
        }
        .frame(height: Metrics.circleButton)
    }

    /// The back button is a pink->orchid ramp and the search button a flat `logoSolid` disc — they
    /// look like a pair in the export but they are not the same fill.
    private func circleButton(systemName: String, filled: Bool) -> some View {
        Image(systemName: systemName)
            .font(.system(size: Metrics.circleButton * 0.42, weight: .semibold))
            .foregroundStyle(filled ? Color.white : MochiColor.textPrimary)
            .frame(width: Metrics.circleButton, height: Metrics.circleButton)
            .background {
                if filled {
                    Circle().fill(MochiColor.logoSolid)
                } else {
                    Circle().fill(
                        LinearGradient(
                            colors: [MochiColor.backButtonStart, MochiColor.backButtonEnd],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                }
            }
    }

    // MARK: - Category pills

    /// One white capsule holding the whole row, which then scrolls inside it. The bar's own inset
    /// is applied as content padding rather than to the ScrollView, so pills can scroll under the
    /// rounded ends instead of stopping short of them.
    private var categoryBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: Metrics.pillGap) {
                ForEach(Category.allCases) { item in
                    categoryPill(item)
                }
            }
            .padding(.horizontal, Metrics.pillBarInset)
        }
        // Sizes the row to its content instead of to the bar, so the seven pills end where "Other"
        // ends. Left to fill, the ScrollView claimed the full width and parked a slab of empty
        // white after the last pill.
        .fixedSize(horizontal: false, vertical: true)
        .frame(height: Metrics.pillBarHeight)
        .background(Color.white, in: Capsule())
    }

    private func categoryPill(_ item: Category) -> some View {
        let isSelected = category == item

        return Button {
            category = item
        } label: {
            HStack(spacing: Metrics.pillIconGap) {
                categoryIcon(item, isSelected: isSelected)
                Text(item.rawValue)
                    .font(MochiFont.body(Type.pill))
                    .fixedSize()
            }
            .foregroundStyle(MochiColor.textPrimary)
            .padding(.horizontal, Metrics.pillPad)
            .frame(height: Metrics.pillHeight)
            .background {
                if isSelected {
                    Capsule().fill(MochiGradient.fontsAccent)
                } else {
                    Capsule().stroke(MochiColor.logoSolid, lineWidth: Metrics.hairline)
                }
            }
        }
        .buttonStyle(.plain)
    }

    /// Figma gives each category a different kind of mark: three are set in type ("Aa", "B", "E")
    /// and are the only Bold thing in the row, three are line icons, and "Cute" is a rendered
    /// purple bow that is artwork rather than a glyph — so it is the one that has to come out of
    /// the asset catalog.
    @ViewBuilder
    private func categoryIcon(_ item: Category, isSelected: Bool) -> some View {
        switch item {
        case .all:
            // Black on the gradient, not knocked out of it — the four squares stay dark when the
            // pill is selected, which is the opposite of the usual selected-pill treatment.
            Image(systemName: "square.grid.2x2.fill")
                .font(.system(size: Type.pill * 0.95))
                .foregroundStyle(MochiColor.textPrimary)
        case .cute:
            Image("icon_bow")
                .resizable()
                .scaledToFit()
                .frame(height: Metrics.pillHeight * 0.72)
        case .handwritten:
            // A pencil lying at 45° over a rule, not SF's bare `pencil` — and `pencil.line` is
            // iOS 17+, which this target does not require.
            PencilGlyph()
                .stroke(MochiColor.textPrimary, style: StrokeStyle(lineWidth: Metrics.hairline * 1.4, lineJoin: .round))
                .frame(width: Type.pill * 1.15, height: Type.pill * 1.15)
        case .minimal:
            Text("Aa").font(MochiFont.title(Type.pill))
        case .bold:
            Text("B").font(MochiFont.title(Type.pill * 1.05))
        case .elegant:
            Text("E").font(MochiFont.title(Type.pill * 1.05))
        case .other:
            TripleDot()
                .fill(MochiColor.textPrimary)
                .frame(width: Type.pill * 0.95, height: Type.pill * 0.26)
        }
    }

    // MARK: - Sort row

    private var sortRow: some View {
        HStack(spacing: 0) {
            // Figma sets this "Soft by". Corrected to "Sort by" — it is a straightforward typo in
            // the source file rather than intentional copy, unlike Community's "Choose" CTA.
            HStack(spacing: 6.5) {
                Text("Sort by")
                    .font(MochiFont.body(Type.sort))
                    .foregroundStyle(MochiColor.logoSolid)
                Text("Popular")
                    .font(MochiFont.body(Type.sort))
                    .foregroundStyle(MochiColor.textPrimary)
            }
            .padding(.horizontal, 7.0)
            .frame(height: Metrics.sortHeight)
            .background(Color.white, in: Capsule())
            .overlay(Capsule().stroke(MochiColor.logoSolid, lineWidth: Metrics.hairline))

            Spacer(minLength: 0)

            HStack(spacing: 3.5) {
                // A funnel. SF's "line.3.horizontal.decrease" is three stacked rules, which is a
                // different mark entirely, and SF has no plain funnel — so it is drawn.
                FunnelGlyph()
                    .stroke(MochiColor.logoSolid, style: StrokeStyle(lineWidth: Metrics.hairline * 1.6, lineJoin: .round))
                    .frame(width: Type.sort * 0.95, height: Type.sort * 0.95)
                Text("Filter").font(MochiFont.body(Type.sort))
            }
            .foregroundStyle(MochiColor.logoSolid)
            .padding(.horizontal, 8.0)
            .frame(height: Metrics.sortHeight)
            .background(Color.white, in: Capsule())
            .overlay(Capsule().stroke(MochiColor.logoSolid, lineWidth: Metrics.hairline))

            Color.clear.frame(width: 3.0)

            SlidersGlyph()
                .stroke(MochiColor.logoSolid, style: StrokeStyle(lineWidth: Metrics.hairline * 1.6, lineCap: .round))
                .frame(width: Metrics.settings.width * 0.42, height: Metrics.settings.height * 0.30)
                .frame(width: Metrics.settings.width, height: Metrics.settings.height)
                .background(Color.white, in: Capsule())
                .overlay(Capsule().stroke(MochiColor.logoSolid, lineWidth: Metrics.hairline))
        }
    }

    // MARK: - Card grid

    private var cardGrid: some View {
        VStack(spacing: Metrics.cardGap) {
            ForEach(Array(MockData.fontCollection.chunked(into: 3).enumerated()), id: \.offset) { _, row in
                HStack(spacing: Metrics.cardGap) {
                    ForEach(row) { font in
                        fontCard(font)
                    }
                }
            }
        }
    }

    private func fontCard(_ font: FontItem) -> some View {
        VStack(spacing: 0) {
            Image(font.artAssetName)
                .resizable()
                .scaledToFill()
                .frame(width: Metrics.cardWidth,
                       height: Metrics.cardWidth / Metrics.cardArtAspect)
                .clipped()
                // The heart is already in the crop (it sits over the artwork in Figma, so it comes
                // along with it). Drawing the live control at exactly the measured position covers
                // the baked one pixel-for-pixel and makes it tappable.
                .overlay(alignment: .topTrailing) {
                    Button {
                        if liked.contains(font.id) { liked.remove(font.id) } else { liked.insert(font.id) }
                    } label: {
                        Image(systemName: liked.contains(font.id) ? "heart.fill" : "heart")
                            .font(.system(size: Metrics.heart * 0.52, weight: .bold))
                            .foregroundStyle(MochiColor.logoSolid)
                            .frame(width: Metrics.heart, height: Metrics.heart)
                            .background(Circle().fill(.white))
                    }
                    .buttonStyle(.plain)
                    .padding(.trailing, Metrics.heartInset)
                    .padding(.top, Metrics.heartTopInset)
                }

            VStack(alignment: .leading, spacing: 0) {
                Color.clear.frame(height: 2.6)

                HStack(spacing: 2) {
                    Text(font.name)
                        .font(MochiFont.itemName(Type.cardTitle))
                        .foregroundStyle(MochiColor.textPrimary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.75)
                        .layoutPriority(1)
                    Spacer(minLength: 2)
                    tierChip(isPremium: font.isPremium, size: Type.chip)
                        .fixedSize()
                }

                Color.clear.frame(height: 1.4)

                Text(font.styleDescription)
                    .font(MochiFont.itemName(Type.cardSubtitle))
                    .foregroundStyle(MochiColor.logoSolid)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)

                Spacer(minLength: 0)

                HStack(spacing: Metrics.cardButtonGap) {
                    Text("Preview")
                        .font(MochiFont.body(Type.cardButton))
                        .foregroundStyle(MochiColor.textPrimary)
                        .frame(maxWidth: .infinity)
                        .frame(height: Metrics.cardButtonHeight)
                        .background(Color.white, in: Capsule())
                        .overlay(Capsule().stroke(MochiColor.logoSolid, lineWidth: Metrics.hairline))

                    Text("Apply")
                        .font(MochiFont.body(Type.cardButton))
                        .foregroundStyle(MochiColor.textPrimary)
                        .frame(maxWidth: .infinity)
                        .frame(height: Metrics.cardButtonHeight)
                        .background(MochiGradient.fontsAccent, in: Capsule())
                }

                Color.clear.frame(height: 3.4)
            }
            .padding(.horizontal, Metrics.cardPad)
            .frame(width: Metrics.cardWidth, height: Metrics.cardBodyHeight)
            .background(Color.white)
        }
        .frame(width: Metrics.cardWidth)
        .clipShape(RoundedRectangle(cornerRadius: Metrics.cardRadius, style: .continuous))
    }

    /// Figma's chip is 115x36px around a 61px label — so 27px of air each side, a shade under half
    /// the label's own width, and only 7px above and below it. It is a wide, shallow lozenge, not
    /// the evenly-padded tag the previous ratios produced.
    private func tierChip(isPremium: Bool, size: CGFloat) -> some View {
        Text(isPremium ? "Pro" : "Free")
            .font(MochiFont.itemName(size))
            .foregroundStyle(isPremium ? MochiColor.proChipText : MochiColor.freeChipText)
            .lineLimit(1)
            .padding(.horizontal, size * 0.82)
            .padding(.vertical, size * 0.11)
            .background(
                isPremium ? MochiColor.proChipBackground : MochiColor.freeChipBackground,
                in: RoundedRectangle(cornerRadius: Metrics.chipRadius, style: .continuous)
            )
    }

    // MARK: - Font preview panel

    private var previewPanel: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 0) {
                Text("FONT PREVIEW")
                    .font(MochiFont.title(Type.panelHeading))
                    .foregroundStyle(MochiColor.textPrimary)

                Spacer(minLength: 6)

                // A full capsule with the placeholder set left, not a centred rounded rect: the
                // field's 62px height against its 38px corner reads as a rounded box at 1x, but
                // at 6x the ends are plainly semicircular.
                TextField("Type something...", text: $sampleText)
                    .font(MochiFont.body(Type.placeholder))
                    .foregroundStyle(MochiColor.textPrimary)
                    .tint(MochiColor.purple)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .padding(.horizontal, Metrics.fieldSize.height * 0.42)
                    .frame(width: Metrics.fieldSize.width, height: Metrics.fieldSize.height)
                    .background(Color.white, in: Capsule())
                    .overlay(Capsule().stroke(MochiColor.logoSolid, lineWidth: Metrics.hairline))
            }

            Color.clear.frame(height: Metrics.headingToGrid)

            LetterGrid()

            Color.clear.frame(height: Metrics.gridToSlider)

            HStack(spacing: 0) {
                Text("FONT PREVIEW")
                    .font(MochiFont.title(Type.sliderLabel))
                    .foregroundStyle(MochiColor.textPrimary)
                    .fixedSize()

                Color.clear.frame(width: 6.0)

                // The two "A"s are the slider's min/max marks, so they are set in the page's own
                // face at two sizes rather than in the previewed script.
                Text("A")
                    .font(MochiFont.body(Type.sliderLabel * 1.25))
                    .foregroundStyle(MochiColor.textPrimary)

                Color.clear.frame(width: 3.0)

                // Not a `Slider`: UIKit's control brings a 27pt white knob and a thick track, which
                // at this size swamps the row. Figma's is a hairline rail with a small solid purple
                // knob, so it is drawn.
                ScaleSlider(value: $previewScale)
                    .frame(width: 129.1, height: Metrics.sliderKnob)

                Color.clear.frame(width: 3.0)

                Text("A")
                    .font(MochiFont.body(Type.sliderLabel * 2.1))
                    .foregroundStyle(MochiColor.textPrimary)

                Spacer(minLength: 4)

                Text("100%")
                    .font(MochiFont.body(Type.percent))
                    .foregroundStyle(MochiColor.textPrimary)
                    .fixedSize()
            }
        }
        .padding(Metrics.panelPad)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white, in: RoundedRectangle(cornerRadius: Metrics.panelRadius, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: Metrics.panelRadius, style: .continuous)
                .stroke(MochiColor.logoSolid, lineWidth: 0.8)
        )
    }

    // MARK: - Apply panel

    private var applyPanel: some View {
        HStack(spacing: 0) {
            // Three solid four-pointed stars — one large upper-left, one mid lower-right, one small
            // lower-left. SF's "sparkles" is a different arrangement with thinner points, so the
            // cluster is drawn.
            SparkleCluster()
                .fill(MochiColor.logoSolid)
                .frame(width: Type.applyHeading * 1.85, height: Type.applyHeading * 1.85)

            Color.clear.frame(width: 5.0)

            VStack(alignment: .leading, spacing: 1.5) {
                Text("APPLY THIS FONT TO YOUR KEYBOARD")
                    .font(MochiFont.title(Type.applyHeading))
                    .foregroundStyle(MochiColor.logoSolid)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                Text("You Can Change It Anytime In Settings")
                    .font(MochiFont.body(Type.applySubtitle))
                    .foregroundStyle(MochiColor.textGreyWarm)
                    .lineLimit(1)
                    .minimumScaleFactor(0.85)
            }

            Spacer(minLength: 4)

            // Measured off the 347x92px button in the export and expressed against its own height,
            // so the parts stay in proportion under `S`: a 22px corner (0.24 of height — a rounded
            // rectangle, not the capsule this was), a 56px white disc (0.61 of height, far larger
            // than it had been) held 38px in from the left, 22px of gap, then 48px after the label.
            HStack(spacing: Metrics.applyButton.height * 0.24) {
                // A white disc with a purple tick, not SF's `checkmark.circle.fill` — that draws
                // the tick knocked out of the disc, so on this gradient it reads as a hole.
                Image(systemName: "checkmark")
                    .font(.system(size: Metrics.applyButton.height * 0.30, weight: .bold))
                    .foregroundStyle(MochiColor.logoSolid)
                    .frame(width: Metrics.applyButton.height * 0.61,
                           height: Metrics.applyButton.height * 0.61)
                    .background(Circle().fill(.white))
                Text("Apply Font")
                    .font(MochiFont.itemName(Type.applyButton))
                    .foregroundStyle(MochiColor.textPrimary)
                    .fixedSize()
            }
            .padding(.leading, Metrics.applyButton.height * 0.41)
            .padding(.trailing, Metrics.applyButton.height * 0.52)
            .frame(height: Metrics.applyButton.height)
            .background(
                MochiGradient.fontsAccent,
                in: RoundedRectangle(cornerRadius: Metrics.applyButton.height * 0.24, style: .continuous)
            )
        }
        .padding(.horizontal, Metrics.panelPad)
        .frame(height: Metrics.applyPanelHeight)
        .frame(maxWidth: .infinity)
        .background(Color.white, in: RoundedRectangle(cornerRadius: Metrics.panelRadius, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: Metrics.panelRadius, style: .continuous)
                .stroke(MochiColor.logoSolid, lineWidth: 0.8)
        )
    }

    // MARK: - My downloaded fonts

    private var downloadedSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 0) {
                Text("MY DOWNLOADED FONTS")
                    .font(MochiFont.title(Type.sectionTitle))
                    .foregroundStyle(MochiColor.textPrimary)
                Spacer(minLength: 4)
                HStack(spacing: 2.5) {
                    Text("see all").font(MochiFont.body(Type.seeAll))
                    Image(systemName: "chevron.right")
                        .font(.system(size: Type.seeAll * 0.8, weight: .regular))
                }
                .foregroundStyle(MochiColor.logoSolid)
            }

            Color.clear.frame(height: Metrics.headingToDownloads)

            // Bleeds back out of the page gutter so the fifth card reaches the right margin
            // exactly as it does in Figma, then scrolls beyond it.
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Metrics.downloadCardGap) {
                    ForEach(MockData.downloadedFonts) { font in
                        downloadCard(font)
                    }
                }
                .padding(.horizontal, Metrics.margin)
            }
            .padding(.horizontal, -Metrics.margin)
        }
    }

    private func downloadCard(_ font: FontItem) -> some View {
        VStack(spacing: 0) {
            Image(font.artAssetName)
                .resizable()
                .scaledToFill()
                .frame(width: Metrics.downloadCard,
                       height: Metrics.downloadCard / Metrics.downloadArtAspect)
                .clipped()
                .overlay(alignment: .topTrailing) {
                    Image(systemName: "ellipsis")
                        .font(.system(size: Metrics.downloadCard * 0.10, weight: .bold))
                        .foregroundStyle(MochiColor.textPrimary)
                        .frame(width: Metrics.downloadCard * 0.19, height: Metrics.downloadCard * 0.19)
                        .background(Circle().fill(.white))
                        .padding(4.0)
                }

            // Figma wraps exactly one of these five ("Handwritten / Elegant") and keeps the other
            // four on one line. `minimumScaleFactor` rather than a smaller base size: it lets the
            // long name shrink a touch and break on its own space instead of forcing every card's
            // name down a size, and it stops "Bubble Cute" breaking after "Bubble".
            HStack(alignment: .top, spacing: 2) {
                Text(font.name)
                    .font(MochiFont.body(Type.downloadName))
                    .foregroundStyle(MochiColor.textPrimary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
                    .fixedSize(horizontal: false, vertical: true)
                    // Without this the HStack resolves the `Spacer` first and hands the name
                    // whatever is left, which wrapped all five ("Bubble / Cute"). The name is the
                    // element with a real width requirement here, so it gets to state it first.
                    .layoutPriority(1)
                Spacer(minLength: 1)
                tierChip(isPremium: font.isPremium, size: Type.downloadChip)
                    .fixedSize()
            }
            .padding(.horizontal, 3.4)
            .frame(width: Metrics.downloadCard, height: Metrics.downloadBodyHeight, alignment: .leading)
            .background(Color.white)
        }
        .frame(width: Metrics.downloadCard)
        .clipShape(RoundedRectangle(cornerRadius: Metrics.downloadRadius, style: .continuous))
    }
}

// MARK: - Letter grid

/// A-Z then a-z over four rows of thirteen, each in an outlined cell. The face is the *previewed*
/// font, not the UI font: Figma's Design panel gives it as **Kaushan Script Regular**, now bundled
/// alongside Inter (OFL, see ios/licenses/KaushanScript-OFL.txt). An earlier pass stood iOS's own
/// Snell Roundhand in for it, which was far more of a formal copperplate than Kaushan's brush hand
/// and gave several letters — Q, W, X — visibly the wrong shape.
private struct LetterGrid: View {
    private static let letters: [String] = {
        let upper = (65...90).map { String(UnicodeScalar($0)!) }
        let lower = (97...122).map { String(UnicodeScalar($0)!) }
        return upper + lower
    }()

    private var scriptFont: Font { .custom("KaushanScript-Regular", size: Type.letter) }

    var body: some View {
        // A fixed-count grid rather than an adaptive one: the thirteen columns are a measured
        // property of the design, and `.flexible()` lets the cells absorb the panel's rounding
        // error instead of the gaps doing it.
        LazyVGrid(
            columns: Array(repeating: GridItem(.flexible(), spacing: nil, alignment: .center),
                           count: Metrics.letterColumns),
            spacing: Metrics.letterRowGap
        ) {
            ForEach(Self.letters, id: \.self) { letter in
                Text(letter)
                    .font(scriptFont)
                    .foregroundStyle(MochiColor.textPrimary)
                    .frame(maxWidth: .infinity)
                    .frame(height: Metrics.letterCellHeight)
                    .background(
                        RoundedRectangle(cornerRadius: Metrics.letterCellRadius, style: .continuous)
                            .stroke(MochiColor.logoSolid, lineWidth: 0.6)
                    )
            }
        }
    }
}

// MARK: - Preview scale slider

/// The size slider under the letter grid: a hairline rail, solid #9C28B1 to the left of the knob
/// and a pale tint to the right, with a small filled knob. Drawn rather than tinted from `Slider`
/// because UIKit's knob is fixed at 27pt and cannot be made this small.
private struct ScaleSlider: View {
    @Binding var value: Double

    var body: some View {
        GeometryReader { geo in
            let usable = max(geo.size.width - Metrics.sliderKnob, 1)
            let x = Metrics.sliderKnob / 2 + usable * CGFloat(value.clamped01)

            ZStack(alignment: .leading) {
                Capsule()
                    .fill(MochiColor.logoSolid.opacity(0.22))
                    .frame(height: Metrics.sliderTrack)

                Capsule()
                    .fill(MochiColor.logoSolid)
                    .frame(width: x, height: Metrics.sliderTrack)

                Circle()
                    .fill(MochiColor.logoSolid)
                    .frame(width: Metrics.sliderKnob, height: Metrics.sliderKnob)
                    .offset(x: x - Metrics.sliderKnob / 2)
            }
            .frame(height: geo.size.height)
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0).onChanged { g in
                    value = ((g.location.x - Metrics.sliderKnob / 2) / usable).clamped01
                }
            )
        }
    }
}

private extension Double {
    var clamped01: Double { Swift.min(Swift.max(self, 0), 1) }
}

private extension CGFloat {
    var clamped01: CGFloat { Swift.min(Swift.max(self, 0), 1) }
}

private extension Array {
    /// Fixed-width rows for the card grid. `LazyVGrid` would also lay this out, but the grid needs
    /// each card to keep its measured 119.06pt width rather than share the row equally, and a
    /// `.fixed()` column set plus a trailing `Spacer` reproduces that less directly than this does.
    func chunked(into size: Int) -> [[Element]] {
        stride(from: 0, to: count, by: size).map { Array(self[$0 ..< Swift.min($0 + size, count)]) }
    }
}

#Preview {
    FontsView()
}
