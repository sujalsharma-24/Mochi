import SwiftUI
import UIKit

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
/// The design's own lift, multiplied by `ScreenScale` so the page holds its proportions on a
/// larger phone rather than drawing 402-point sizes into a 440-point screen.
private var S: CGFloat { 1.22 * ScreenScale.value }

/// The category bar is the one block that takes **no** vertical lift at all. Its seven pills span
/// the content width exactly in Figma, and that budget is pure width, so there is no headroom to
/// give the labels. 1.0 keeps all seven visible and flush, exactly as the frame draws them. The bar
/// still scrolls, as a safety valve for larger Dynamic Type.
private var SPill: CGFloat { ScreenScale.value }

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
    static let headerToPills: CGFloat = 16.68 + 5.0 * ScreenScale.spacing   // 90px, disc-bottom to bar-top

    // MARK: Category bar — one white capsule, 2007x104px, outlined in #9C28B1 like the pills inside
    // it, holding seven pills. See `SPill`: this block is drawn at 1.0.
    //
    // The bar is a touch taller than Figma's measured 104px (19.28pt) and the pills sit inside it
    // with real vertical padding: at the measured height a selected pill's fill and an unselected
    // pill's 0.5pt stroke were both being shaved by the bar's own edge — the "cut off along the
    // bottom" the row showed. `pillBarVPad` gives the pills breathing room and the extra ~2pt of
    // bar height keeps a small, even gap between the pill outline and the bar outline.
    static let pillBarHeight: CGFloat = 21.5 * SPill
    static let pillBarVPad: CGFloat = 2.6 * SPill
    static let pillHeight: CGFloat = 14.08 * SPill      // 76px
    static let pillBarInset: CGFloat = 7.41 * SPill     // 40px, bar-left to first pill
    static let pillGap: CGFloat = 9.5 * SPill
    static let pillPad: CGFloat = 6.0 * SPill           // label inset inside each pill
    static let pillIconGap: CGFloat = 3.00 * SPill      // 14-22px depending on the mark
    static let pillsToFilter: CGFloat = 7.4 + 3.0 * ScreenScale.spacing             // 36px + the bar's 2pt of extra height

    // MARK: Filter row — a 234x104px capsule and a 133x104px one, both white with a #9C28B1
    // outline, ending flush with the right margin. Unlike the grid this row has slack to its left,
    // so `S` is applied to both axes and the two shapes keep their measured proportions.
    static let filterHeight: CGFloat = 19.28 * S
    static let filterToGrid: CGFloat = 6.67 + 4.0 * ScreenScale.spacing     // 36px
    /// Both marks are small relative to the capsules that hold them — 39x36px and 44x36px inside
    /// shapes 104px tall — and both are stroked at 4px, which is 0.74pt before the lift.
    static let glyphStroke: CGFloat = 0.74 * S

    // MARK: Card grid — 640x640px cards (square at width scale) 44px apart in both axes, 56px
    // corner. 440px of art over a 200px white body; only the body takes `S`.
    /// Was a baked 118.62 — the value that made three cards plus two gaps span a 402pt screen
    /// exactly. See `DesignGrid` for why that has to be computed instead.
    static var cardWidth: CGFloat {
        DesignGrid.columnWidth(columns: 3, margin: margin, gap: cardGap)
    }
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
    static let gridToHeading: CGFloat = 64.49 + 6.0 * ScreenScale.spacing
    /// The heading row is inset a further 86px on both sides than the tiles under it — "MY" starts
    /// at 166px where the first tile starts at 80px, and "see all" ends at 2007px where the last
    /// tile ends at 2088px. Symmetric, so it is deliberate rather than a stray nudge.
    static let headingInset: CGFloat = 15.94
    static let headingToStrip: CGFloat = 4.18   // 38px ink-to-art, less the heading's descent
    static let seeAllGap: CGFloat = 2.60
    /// Four 461x402px tiles 53px apart; 308px art over a 94px body. Four fill the row exactly — so
    /// the expanded "see all" state is literally this row wrapped, `chunked(into: 4)`.
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

/// How the theme grid is ordered. The architecture is real; "Popular" ranks by `likeCount`, which
/// is a documented placeholder on `ThemeCatalog` until real telemetry exists. "Newest" has no real
/// dates either, so it sorts by reverse position in `ThemeCatalog.all` (newest = added last).
private enum ThemeSortOption: String, CaseIterable, Identifiable {
    case popular = "Popular", newest = "Newest", nameAsc = "A–Z"
    var id: String { rawValue }

    func orders(_ a: KeyboardTheme, _ b: KeyboardTheme) -> Bool {
        switch self {
        case .popular:
            // Featured themes (the ones Home showcases, with real composited thumbnails) come
            // first, in their editorial order; everything else falls back to the like-count rank.
            if a.featuredRank != b.featuredRank {
                return (a.featuredRank ?? .max) < (b.featuredRank ?? .max)
            }
            return a.likeCount > b.likeCount
        case .newest:
            let index = { (t: KeyboardTheme) in ThemeCatalog.all.firstIndex(of: t) ?? 0 }
            return index(a) > index(b)
        case .nameAsc:
            return a.name.localizedCaseInsensitiveCompare(b.name) == .orderedAscending
        }
    }
}

/// The Filter control — the free/premium axis. Category is handled by the pills.
private enum ThemeTierFilter: String, CaseIterable, Identifiable {
    case all = "All Themes", free = "Free Only", premium = "Premium Only"
    var id: String { rawValue }

    func includes(_ theme: KeyboardTheme) -> Bool {
        switch self {
        case .all: return true
        case .free: return !theme.isPremium
        case .premium: return theme.isPremium
        }
    }
}

struct ThemesView: View {
    var onOpenSearch: () -> Void = {}
    var onThemeClick: (KeyboardTheme) -> Void = { _ in }
    var onWallpapers: () -> Void = {}

    @StateObject private var viewModel = ThemesViewModel(container: AppContainer.shared)

    @State private var category: ThemeCategory = .all
    @State private var sortOption: ThemeSortOption = .popular
    @State private var tierFilter: ThemeTierFilter = .all

    /// Published Create Custom Theme drafts, loaded once on appear rather than re-read from disk on
    /// every `body` evaluation — the pills and the two menus re-evaluate `body` on every tap, and
    /// `CustomThemeStore.publishedCatalogueThemes()` walks `index.json` plus one file per theme.
    @State private var publishedCustoms: [KeyboardTheme] = []
    /// Mirrors `DownloadedThemeStore` — the "MY DOWNLOADED THEMES" strip, and the per-card
    /// download-disc state. Kept in `@State` so a tap refreshes the UI.
    @State private var downloadedIDs: [String] = DownloadedThemeStore.loadDownloadedThemeIDs()
    /// Mirrors `AppliedThemeStore.appliedThemeId` so a card's Apply button can show "Applied".
    @AppStorage(AppliedThemeStore.defaultsKey) private var appliedThemeId: String = ""

    /// The downloaded strip switches from a horizontal scroller to a full inline grid on the same
    /// page when this is set — Figma's "see all", kept on-page rather than pushed as a route.
    @State private var showAllDownloaded = false

    /// Real Firestore data only replaces the grid once it's actually loaded — Loading/Empty/Error
    /// fall back to the real built-in catalogue (`ThemeCatalog.all`), same convention as
    /// ThemesScreen.kt (this screen always shows *something*).
    ///
    /// Published custom themes are prepended regardless of that backend state, newest first — this
    /// is the local-first path point 13 asks for: publishing has to make a theme show up in the
    /// application's actual theme system even before/without a Firestore backend.
    private var baseThemes: [KeyboardTheme] {
        let backend: [KeyboardTheme]
        if case .data(let themes) = viewModel.uiState { backend = themes } else { backend = ThemeCatalog.all }
        return publishedCustoms + backend
    }

    /// The grid contents after the pills, the Filter and the Sort control have been applied.
    private var displayedThemes: [KeyboardTheme] {
        baseThemes
            .filter { category == .all || $0.category == category }
            .filter { tierFilter.includes($0) }
            .sorted { sortOption.orders($0, $1) }
    }

    /// The "MY DOWNLOADED THEMES" strip, resolved from the id list — a published custom theme first,
    /// then the built-in catalogue. Order follows the id list (most-recently-downloaded last).
    private var downloadedThemeItems: [KeyboardTheme] {
        downloadedIDs.compactMap { id in
            publishedCustoms.first { $0.id == id } ?? ThemeCatalog.theme(id: id)
        }
    }

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
        .onAppear {
            publishedCustoms = CustomThemeStore.publishedCatalogueThemes()
            downloadedIDs = DownloadedThemeStore.loadDownloadedThemeIDs()
        }
    }

    // MARK: - Header

    private var header: some View {
        ZStack {
            HStack(spacing: 0) {
                circleButton(systemName: "arrow.left")
                Spacer(minLength: 0)
                Button(action: onOpenSearch) {
                    circleButton(systemName: "magnifyingglass")
                }
                .accessibilityIdentifier("themes.openSearch")
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
    /// under the rounded ends instead of stopping short of them, and the pills carry vertical
    /// padding so their outline clears the bar's — see `Metrics.pillBarVPad`.
    /// The pills are laid out to **fill** the bar rather than to hug their own labels.
    ///
    /// Sized to content they left a wide empty stretch inside the capsule's right end, which read as
    /// the row having run out rather than as a deliberate gap. `ViewThatFits` takes the spread
    /// layout — even gaps flowing to the bar's own inset on both sides — whenever it fits, and falls
    /// back to the scrolling row on a narrow screen or at large Dynamic Type, so nothing is ever
    /// clipped. The eighth pill (Space) also earns its place: 25 of the catalogue's themes are
    /// cosmic ones that previously had nowhere of their own to sit and landed under "Other".
    private var categoryBar: some View {
        ViewThatFits(in: .horizontal) {
            HStack(spacing: 0) {
                ForEach(Array(ThemeCategory.allCases.enumerated()), id: \.element.id) { index, item in
                    if index > 0 { Spacer(minLength: Metrics.pillGap * 0.45) }
                    categoryPill(item, compact: true)
                }
            }
            .padding(.horizontal, Metrics.pillBarInset)
            .padding(.vertical, Metrics.pillBarVPad)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Metrics.pillGap) {
                    ForEach(ThemeCategory.allCases) { item in
                        categoryPill(item)
                    }
                }
                .padding(.horizontal, Metrics.pillBarInset)
                .padding(.vertical, Metrics.pillBarVPad)
            }
        }
        .frame(height: Metrics.pillBarHeight)
        .background(Color.white, in: Capsule())
        .clipShape(Capsule())
        .overlay(Capsule().stroke(MochiColor.logoSolid, lineWidth: Metrics.hairline))
        .accessibilityIdentifier("themes.categoryBar")
    }

    /// `compact` is the spread layout's pill: the eight of them plus the bar's own insets come to
    /// within a point or two of the content width, so in that layout the label is allowed to shrink
    /// a hair rather than push the last pill under the capsule's rounded end.
    private func categoryPill(_ item: ThemeCategory, compact: Bool = false) -> some View {
        let isSelected = category == item

        return Button {
            category = item
        } label: {
            HStack(spacing: compact ? Metrics.pillIconGap * 0.8 : Metrics.pillIconGap) {
                categoryIcon(item)
                Text(item.rawValue)
                    .font(MochiFont.body(Type.pill))
                    .lineLimit(1)
                    .minimumScaleFactor(compact ? 0.82 : 1.0)
                    .fixedSize(horizontal: !compact, vertical: false)
            }
            .foregroundStyle(MochiColor.textPrimary)
            .padding(.horizontal, compact ? Metrics.pillPad * 0.82 : Metrics.pillPad)
            .frame(height: Metrics.pillHeight)
            .background {
                if isSelected {
                    Capsule().fill(MochiGradient.themeButton)
                } else {
                    Capsule().stroke(MochiColor.logoSolid, lineWidth: Metrics.hairline)
                }
            }
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("themes.category.\(item.rawValue)")
    }

    /// Each category gets a small line/solid mark left of its label. "Cute" keeps the rendered
    /// purple bow from the asset catalog (the one mark that is artwork, not a glyph); the rest are
    /// SF Symbols chosen to read the category at a glance — a cup for Cozy, moon-and-stars for
    /// Dreamy, a leaf for Nature, sparkles for Elegant.
    @ViewBuilder
    private func categoryIcon(_ item: ThemeCategory) -> some View {
        Group {
            switch item {
            case .all:
                Image(systemName: "square.grid.2x2.fill").font(.system(size: Type.pill * 0.95))
            case .cute:
                Image("icon_bow").resizable().scaledToFit().frame(height: Metrics.pillHeight * 0.62)
            case .cozy:
                Image(systemName: "cup.and.saucer.fill").font(.system(size: Type.pill * 0.95))
            case .dreamy:
                Image(systemName: "moon.stars.fill").font(.system(size: Type.pill * 0.95))
            case .nature:
                Image(systemName: "leaf.fill").font(.system(size: Type.pill * 0.95))
            case .elegant:
                Image(systemName: "sparkles").font(.system(size: Type.pill * 1.0))
            case .space:
                Image(systemName: "globe.americas.fill").font(.system(size: Type.pill * 0.95))
            case .other:
                TripleDot()
                    .fill(MochiColor.textPrimary)
                    .frame(width: Type.pill * 0.95, height: 1.48)
            }
        }
    }

    // MARK: - Filter row

    /// Right-aligned; unlike the Fonts frame there is no "Sort by" capsule on the left of it. The
    /// "Wallpapers" pill on the left is not in the Figma frame — it's the entry point to the
    /// Wallpapers screen (Android surfaces it from Themes too). The two right-hand capsules are the
    /// **Filter** (free/premium) and **Sort** (Popular / Newest / A–Z) controls; both are real
    /// menus bound to state that the grid reads.
    private var filterRow: some View {
        HStack(spacing: 0) {
            Button(action: onWallpapers) {
                HStack(spacing: 4) {
                    Image(systemName: "photo.stack.fill").font(.system(size: Type.filter * 0.9))
                    Text("Wallpapers").font(MochiFont.caption(Type.filter))
                }
                .foregroundStyle(MochiColor.logoSolid)
                .padding(.horizontal, 10)
                .frame(height: Metrics.filterHeight)
                .background(Color.white, in: Capsule())
                .overlay(Capsule().stroke(MochiColor.logoSolid, lineWidth: Metrics.hairline))
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("themes.openWallpapers")

            Spacer(minLength: 0)

            Menu {
                Picker("Filter", selection: $tierFilter) {
                    ForEach(ThemeTierFilter.allCases) { Text($0.rawValue).tag($0) }
                }
            } label: {
                HStack(spacing: Metrics.filterHeight * 0.16) {
                    FunnelGlyph()
                        .stroke(MochiColor.logoSolid,
                                style: StrokeStyle(lineWidth: Metrics.glyphStroke, lineJoin: .round))
                        .frame(width: Type.filter * 0.95, height: Type.filter * 0.9)
                    Text(tierFilter == .all ? "Filter" : tierFilter.rawValue)
                        .font(MochiFont.caption(Type.filter))
                        .lineLimit(1)
                        .fixedSize()
                }
                .foregroundStyle(MochiColor.logoSolid)
                .padding(.horizontal, 9)
                .frame(height: Metrics.filterHeight)
                .background(Color.white, in: Capsule())
                .overlay(Capsule().stroke(MochiColor.logoSolid, lineWidth: Metrics.hairline))
            }
            .accessibilityIdentifier("themes.filter")

            Color.clear.frame(width: 8.34 * S)

            Menu {
                Picker("Sort by", selection: $sortOption) {
                    ForEach(ThemeSortOption.allCases) { Text($0.rawValue).tag($0) }
                }
                Picker("Category", selection: $category) {
                    ForEach(ThemeCategory.allCases) { Text($0.rawValue).tag($0) }
                }
            } label: {
                HStack(spacing: Metrics.filterHeight * 0.14) {
                    SlidersGlyph()
                        .stroke(MochiColor.logoSolid,
                                style: StrokeStyle(lineWidth: Metrics.glyphStroke, lineCap: .round))
                        .frame(width: Type.filter * 1.05, height: Type.filter * 0.9)
                    Text(sortOption.rawValue)
                        .font(MochiFont.caption(Type.filter))
                        .lineLimit(1)
                        .fixedSize()
                }
                .foregroundStyle(MochiColor.logoSolid)
                .padding(.horizontal, 9)
                .frame(height: Metrics.filterHeight)
                .background(Color.white, in: Capsule())
                .overlay(Capsule().stroke(MochiColor.logoSolid, lineWidth: Metrics.hairline))
            }
            .accessibilityIdentifier("themes.sort")
        }
    }

    // MARK: - Card grid

    @ViewBuilder
    private var cardGrid: some View {
        if displayedThemes.isEmpty {
            Text("No themes match this filter")
                .font(MochiFont.body(Type.cardTitle))
                .foregroundStyle(MochiColor.textGreyWarm)
                .frame(maxWidth: .infinity)
                .frame(height: Metrics.cardWidth / Metrics.cardArtAspect)
                .accessibilityIdentifier("themes.grid.empty")
        } else {
            // Lazy so only the visible rows of the up-to-28-card catalogue decode their plates.
            LazyVStack(spacing: Metrics.cardGap) {
                ForEach(Array(displayedThemes.chunked(into: 3).enumerated()), id: \.offset) { _, row in
                    HStack(spacing: Metrics.cardGap) {
                        ForEach(row) { theme in
                            themeCard(theme)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
    }

    private func themeCard(_ theme: KeyboardTheme) -> some View {
        let isDownloaded = downloadedIDs.contains(theme.id)
        let isApplied = appliedThemeId == theme.id

        return VStack(spacing: 0) {
            ThemePlateThumbnail(assetName: theme.imageAssetName,
                                verticalAnchor: plateAnchor(for: theme))
                .frame(width: Metrics.cardWidth,
                       height: Metrics.cardWidth / Metrics.cardArtAspect)
                .clipped()
                // Tap the artwork to open the theme. Applied *before* the download overlay so the
                // disc Button sits on top of this gesture and keeps its own tap in its corner.
                .contentShape(Rectangle())
                .onTapGesture { onThemeClick(theme) }
                .overlay(alignment: .topTrailing) {
                    Button {
                        let nowDownloaded = DownloadedThemeStore.toggle(theme.id)
                        downloadedIDs = DownloadedThemeStore.loadDownloadedThemeIDs()
                        if nowDownloaded {
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        }
                    } label: {
                        DownloadGlyph()
                            .stroke(isDownloaded ? MochiColor.logoSolid : MochiColor.downloadGlyph,
                                    style: StrokeStyle(lineWidth: Metrics.download * 0.046,
                                                       lineCap: .round, lineJoin: .round))
                            .frame(width: Metrics.download * 0.477, height: Metrics.download * 0.492)
                            .frame(width: Metrics.download + 10, height: Metrics.download + 10)
                            .background(Circle().fill(isDownloaded ? MochiColor.lavender : .white)
                                .frame(width: Metrics.download, height: Metrics.download))
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .padding(.trailing, Metrics.downloadTrailing - 5)
                    .padding(.top, Metrics.downloadTop - 5)
                    .accessibilityIdentifier("themes.card.\(theme.id).download")
                }

            VStack(alignment: .leading, spacing: 0) {
                Color.clear.frame(height: Metrics.bodyTopToTitle)

                HStack(alignment: .center, spacing: 0) {
                    VStack(alignment: .leading, spacing: Metrics.titleToByline) {
                        Text(theme.name)
                            .font(MochiFont.caption(Type.cardTitle))
                            .foregroundStyle(MochiColor.textPrimary)
                            .lineLimit(1)

                        Text(theme.creatorName)
                            .font(MochiFont.caption(Type.cardByline))
                            .foregroundStyle(MochiColor.creatorLink)
                            .lineLimit(1)
                    }
                    .layoutPriority(1)

                    Spacer(minLength: 1)

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
                        .contentShape(Capsule())
                        .onTapGesture { onThemeClick(theme) }
                        .accessibilityIdentifier("themes.card.\(theme.id).preview")

                    Text(isApplied ? "Applied" : "Apply")
                        .font(MochiFont.body(Type.applyButton))
                        .foregroundStyle(MochiColor.textPrimary)
                        .frame(maxWidth: .infinity)
                        .frame(height: Metrics.cardButtonHeight)
                        .background(MochiGradient.themeButton, in: Capsule())
                        .contentShape(Capsule())
                        .onTapGesture { applyTheme(theme) }
                        .accessibilityIdentifier("themes.card.\(theme.id).apply")
                }

                Color.clear.frame(height: Metrics.bodyBottom)
            }
            .padding(.horizontal, Metrics.cardPad)
            .frame(width: Metrics.cardWidth, height: Metrics.cardBodyHeight)
            .background(Color.white)
            .contentShape(Rectangle())
            .onTapGesture { onThemeClick(theme) }
        }
        .frame(width: Metrics.cardWidth)
        .clipShape(RoundedRectangle(cornerRadius: Metrics.cardRadius, style: .continuous))
        .overlay {
            if isApplied {
                RoundedRectangle(cornerRadius: Metrics.cardRadius, style: .continuous)
                    .stroke(MochiColor.logoSolid, lineWidth: Metrics.hairline * 4)
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("themes.card.\(theme.id)")
    }

    /// Applies `theme` through the app's one apply path (`AppliedThemeStore` → App Group hand-off),
    /// which also records it as downloaded. No parallel apply logic lives here.
    private func applyTheme(_ theme: KeyboardTheme) {
        AppliedThemeStore.apply(theme)
        appliedThemeId = theme.id
        downloadedIDs = DownloadedThemeStore.loadDownloadedThemeIDs()
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }

    /// The built-in theme's own authored `verticalAnchor`, so a 118pt tile keeps the same band of
    /// the plate the keyboard does. Shared with Community's Top Themes row — see
    /// `KeyboardTheme.plateVerticalAnchor`.
    private func plateAnchor(for theme: KeyboardTheme) -> Double {
        theme.plateVerticalAnchor
    }

    // MARK: - My downloaded themes

    private var downloadedSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 0) {
                Text("MY DOWNLOADED THEMES")
                    .font(MochiFont.title(Type.sectionTitle))
                    .foregroundStyle(MochiColor.textPrimary)
                Spacer(minLength: 4)

                // Only offered once there's more than one row's worth to reveal.
                if downloadedThemeItems.count > 4 {
                    Button {
                        withAnimation(.snappy) { showAllDownloaded.toggle() }
                    } label: {
                        HStack(spacing: Metrics.seeAllGap) {
                            Text(showAllDownloaded ? "show less" : "see all")
                                .font(MochiFont.body(Type.seeAll))
                            Image(systemName: "chevron.right")
                                .font(.system(size: Type.seeAll * 0.80, weight: .regular))
                                .rotationEffect(.degrees(showAllDownloaded ? 90 : 0))
                        }
                        .foregroundStyle(MochiColor.logoSolid)
                    }
                    .buttonStyle(.plain)
                    .accessibilityIdentifier("themes.downloaded.seeAll")
                }
            }
            .padding(.horizontal, Metrics.headingInset)

            Color.clear.frame(height: Metrics.headingToStrip)

            if downloadedThemeItems.isEmpty {
                Text("Tap the download icon on a theme to keep it here.")
                    .font(MochiFont.body(Type.downloadName))
                    .foregroundStyle(MochiColor.textGreyWarm)
                    .frame(maxWidth: .infinity, minHeight: Metrics.downloadCard / Metrics.downloadArtAspect,
                           alignment: .leading)
                    .padding(.horizontal, Metrics.headingInset)
                    .accessibilityIdentifier("themes.downloaded.empty")
            } else if showAllDownloaded {
                // The expanded state is the collapsed row wrapped: four tiles fill the content
                // width exactly, so `chunked(into: 4)` needs no new metrics. No gutter bleed here —
                // that is a horizontal-scroller trick and would hang the grid past both margins.
                LazyVStack(spacing: Metrics.downloadCardGap) {
                    ForEach(Array(downloadedThemeItems.chunked(into: 4).enumerated()), id: \.offset) { _, row in
                        HStack(spacing: Metrics.downloadCardGap) {
                            ForEach(row) { theme in
                                downloadCard(theme)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            } else {
                // Bleeds back out of the page gutter so the fourth tile reaches the right margin
                // exactly as it does in Figma, then scrolls beyond it.
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: Metrics.downloadCardGap) {
                        ForEach(downloadedThemeItems) { theme in
                            downloadCard(theme)
                        }
                    }
                    .padding(.horizontal, Metrics.margin)
                }
                .padding(.horizontal, -Metrics.margin)
            }
        }
    }

    private func downloadCard(_ theme: KeyboardTheme) -> some View {
        VStack(spacing: 0) {
            ThemePlateThumbnail(assetName: theme.imageAssetName,
                                verticalAnchor: plateAnchor(for: theme))
                .frame(width: Metrics.downloadCard,
                       height: Metrics.downloadCard / Metrics.downloadArtAspect)
                .clipped()
                .overlay(alignment: .topTrailing) {
                    Menu {
                        Button(role: .destructive) {
                            DownloadedThemeStore.remove(theme.id)
                            downloadedIDs = DownloadedThemeStore.loadDownloadedThemeIDs()
                        } label: {
                            Label("Remove from downloads", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                            .font(.system(size: Metrics.ellipsisDisc * 0.44, weight: .semibold))
                            .foregroundStyle(MochiColor.textPrimary)
                            .frame(width: Metrics.ellipsisDisc, height: Metrics.ellipsisDisc)
                            .background(Circle().fill(.white))
                            .padding(.trailing, Metrics.ellipsisTrailing)
                            .padding(.top, Metrics.ellipsisTop)
                    }
                    .accessibilityIdentifier("themes.downloadCard.\(theme.id).menu")
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
        .contentShape(RoundedRectangle(cornerRadius: Metrics.downloadRadius, style: .continuous))
        .onTapGesture { onThemeClick(theme) }
        .accessibilityIdentifier("themes.downloadCard.\(theme.id)")
    }
}

// `Array.chunked(into:)` for the card grid's fixed-width rows lives in the module-level
// extension in Data/ThemeRepository.swift and is shared across the app target.

#Preview {
    ThemesView()
}
