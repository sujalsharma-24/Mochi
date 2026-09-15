import SwiftUI
import UIKit

/// Built against `docs/figma/10.png`.
///
/// **That export is a phone frame, not a desktop one.** It carries black export padding — 7px
/// left, 201px top — so its real artboard is x∈[7,2167] y∈[201,4041] → **2161×3841**, the same
/// canvas as frames 4–7/9. The designer drew a fixed left nav rail + content pane *at phone
/// width*, so every size started life as a Figma px measurement scaled by `402/2161`. Those
/// numbers all live in `WallpaperMetrics` now — see that file for why they moved off the old
/// in-app tweak panel without the layout shifting, and how they rescale for non-402pt devices.
///
/// **One screen, many pages.** The rail, the search field and the chip row are identical on every
/// destination; only the pane's body changes (`WallpaperPage`). Moving between All Themes, a
/// theme, a "see all" row and a collection is a content swap inside this view rather than a
/// pushed `NavigationStack` destination, which is what keeps the whole section feeling like one
/// application instead of a stack of separate screens.
struct WallpapersView: View {
    var onBack: () -> Void = {}
    var onUnlockPremium: () -> Void = {}

    @State private var query = ""
    /// Page history. Empty means the discovery page; the rail's chevron pops one level and only
    /// leaves the Wallpapers section from the root.
    @State private var stack: [WallpaperPage] = []
    @State private var downloadedIDs: [String] = DownloadedWallpaperStore.loadDownloadedWallpaperIDs()
    @State private var moreSheet = false
    @State private var preview: WallpaperItem?

    private var page: WallpaperPage { stack.last ?? .discover }
    private var trimmedQuery: String { query.trimmingCharacters(in: .whitespacesAndNewlines) }
    private var isSearching: Bool { !trimmedQuery.isEmpty }

    private var recentlyDownloaded: [WallpaperItem] {
        downloadedIDs.reversed().compactMap { WallpaperCatalog.wallpaper(id: $0) }
    }

    /// The rail row / chip drawn as selected. A theme page selects its own theme; everything else
    /// falls back to All Themes.
    private var activeFilter: WallpaperFilter? {
        guard !isSearching else { return nil }
        if case .theme(let category) = page { return WallpaperFilter(rawValue: category.rawValue) }
        return stack.isEmpty ? .all : nil
    }

    var body: some View {
        GeometryReader { geo in
            let m = WallpaperMetrics(width: geo.size.width)

            // The content pane spans the full screen width with its content inset by the rail's
            // width, so the rail can sit on top as the front layer and still take its own taps.
            ZStack(alignment: .topLeading) {
                contentPane(m)
                    .background(alignment: .top) { pageBackground(m) }

                rail(m)
                    .frame(width: m.railWidth)
                    .background(alignment: .top) { railBackground.ignoresSafeArea() }
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .onAppear { downloadedIDs = DownloadedWallpaperStore.loadDownloadedWallpaperIDs() }
        .sheet(isPresented: $moreSheet) { moreFilterSheet }
        .fullScreenCover(item: $preview) { item in
            WallpaperPreviewView(item: item,
                                 isDownloaded: isDownloaded(item),
                                 onToggleDownload: { toggleDownload(item) },
                                 onClose: { preview = nil })
        }
    }

    /// The page's own ground. Clipped to the screen: `scaledToFill` makes the image *larger* than
    /// its container by design, so without a clip it painted outside the pane and read as the
    /// whole screen having been zoomed in.
    private func pageBackground(_ m: WallpaperMetrics) -> some View {
        Image("themes_background")
            .resizable()
            .aspectRatio(contentMode: .fill)
            .clipped()
            .ignoresSafeArea()
    }

    private var railBackground: some View {
        LinearGradient(
            colors: [
                Color(red: 0.76, green: 0.37, blue: 0.75),
                Color(red: 0.97, green: 0.66, blue: 0.75),
                Color(red: 0.74, green: 0.53, blue: 0.86),
                Color(red: 0.47, green: 0.50, blue: 0.87)
            ],
            startPoint: .top, endPoint: .bottom
        )
        .overlay(alignment: .bottom) {
            Image("wp_rail_foot").resizable().scaledToFit()
        }
        .overlay { SparkleField().opacity(0.7) }
        .clipped()
    }

    // MARK: - Rail

    private func rail(_ m: WallpaperMetrics) -> some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: m.railGap) {
                railHeader(m)
                railNav(m)
                railRecent(m)
                railViewAll(m)
                Spacer(minLength: m.railGap)
                goPremiumCard(m)
                    .padding(.top, m.railPremiumDrop)
            }
            .padding(.horizontal, m.railPadH)
            .padding(.top, m.railTop)
            .padding(.bottom, 24)
        }
    }

    private func railHeader(_ m: WallpaperMetrics) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            // Back sits on its own line *above* the wordmark rather than inline with it, so the
            // icon + "Wallpapers" start flush with the rail's leading padding instead of being
            // pushed in by a chevron — and the chevron reads as "leave this section" rather than
            // as part of the title.
            Button(action: goBack) {
                Image(systemName: "chevron.left")
                    .font(.system(size: m.railTitle * 0.7, weight: .semibold))
                    .foregroundStyle(MochiColor.textPrimary)
                    .padding(.trailing, 6)
                    .padding(.vertical, 2)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("wallpapers.back")

            HStack(spacing: 5) {
                RoundedRectangle(cornerRadius: 5, style: .continuous)
                    .fill(Color.white)
                    .frame(width: m.railTitle * 1.15, height: m.railTitle * 1.15)
                    .overlay(Image(systemName: "photo.fill")
                        .font(.system(size: m.railTitle * 0.6))
                        .foregroundStyle(MochiColor.logoSolid))

                Text("Wallpapers")
                    .font(MochiFont.title(m.railTitle))
                    .foregroundStyle(MochiColor.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
            }
            Text("Find the perfect wallpaper & theme for your device")
                .font(MochiFont.caption(m.railSubtitle))
                .foregroundStyle(MochiColor.textPrimary.opacity(0.75))
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private func railNav(_ m: WallpaperMetrics) -> some View {
        VStack(alignment: .leading, spacing: m.railNavGap) {
            ForEach(WallpaperFilter.railCases) { filter in
                railNavRow(filter, m)
            }
        }
        .padding(.top, m.railGap + m.railNavDrop)
    }

    @ViewBuilder
    private func railNavRow(_ filter: WallpaperFilter, _ m: WallpaperMetrics) -> some View {
        let isSelected = activeFilter == filter
        Button {
            selectFilter(filter)
        } label: {
            HStack(spacing: 6) {
                FilterIcon(kind: filter.icon, size: m.railNav * 0.95, color: MochiColor.textPrimary)
                    .frame(width: m.railNav * 1.1)
                Text(filter.label)
                    .font(MochiFont.body(m.railNav))
                    .foregroundStyle(isSelected ? MochiColor.logoSolid : MochiColor.textPrimary)
                Spacer(minLength: 0)
            }
            .padding(.vertical, isSelected ? m.railPillH * 0.28 : 0)
            .padding(.horizontal, isSelected ? 10 : 0)
            .background {
                if isSelected {
                    Capsule().fill(Color.white)
                        .overlay(Capsule().stroke(MochiColor.logoSolid.opacity(m.railPillBorderOpacity),
                                                  lineWidth: m.chipBorderWidth))
                }
            }
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("wallpapers.category.\(filter.rawValue)")
    }

    private func railRecent(_ m: WallpaperMetrics) -> some View {
        VStack(alignment: .leading, spacing: m.railNavGap * 0.8) {
            Text("Recently Downloaded")
                .font(MochiFont.heading(m.railSectionHeading))
                .foregroundStyle(MochiColor.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.6)

            if recentlyDownloaded.isEmpty {
                Text("Downloads you keep show up here.")
                    .font(MochiFont.caption(m.railRecentName))
                    .foregroundStyle(MochiColor.textPrimary.opacity(0.6))
                    .fixedSize(horizontal: false, vertical: true)
            } else {
                ForEach(recentlyDownloaded.prefix(4)) { item in
                    HStack(spacing: 5) {
                        Button { preview = item } label: {
                            WallpaperArt(assetName: item.assetName, anchor: item.cropAnchor)
                                .frame(width: m.railThumb, height: m.railThumb)
                                .clipShape(RoundedRectangle(cornerRadius: 3, style: .continuous))
                        }
                        .buttonStyle(.plain)
                        Text(item.name)
                            .font(MochiFont.body(m.railRecentName))
                            .foregroundStyle(MochiColor.textPrimary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                        Spacer(minLength: 2)
                        Button {
                            toggleDownload(item)
                        } label: {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: m.railRecentName * 1.3))
                                .foregroundStyle(MochiColor.logoSolid)
                                .padding(2)
                                .background(Circle().fill(.white))
                        }
                        .buttonStyle(.plain)
                        .accessibilityIdentifier("wallpapers.recent.\(item.id).remove")
                    }
                }
            }
        }
        .padding(.top, m.railRecentDrop)
    }

    private func railViewAll(_ m: WallpaperMetrics) -> some View {
        Button {
            push(.section(.downloads))
        } label: {
            HStack(spacing: 3) {
                Text("View All Downloads")
                    .font(MochiFont.body(m.railButton))
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
                Image(systemName: "chevron.right").font(.system(size: m.railButton * 0.85, weight: .semibold))
            }
            .foregroundStyle(MochiColor.logoSolid)
            .padding(.vertical, 7)
            .padding(.horizontal, 12)
            .frame(maxWidth: .infinity)
            .background(Capsule().fill(.white))
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("wallpapers.viewAllDownloads")
    }

    private func goPremiumCard(_ m: WallpaperMetrics) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Image("icon_premium_crown").resizable().scaledToFit()
                .frame(width: m.goPremiumTitle * 2.1, height: m.goPremiumTitle * 2.1)
            Text("GO PREMIUM")
                .font(MochiFont.title(m.goPremiumTitle))
                .foregroundStyle(MochiColor.logoSolid)
            Text("Unlock premium themes, fonts, and exclusive collections.")
                .font(MochiFont.caption(m.goPremiumBody))
                .foregroundStyle(MochiColor.textPrimary.opacity(0.65))
                .fixedSize(horizontal: false, vertical: true)
            Button(action: onUnlockPremium) {
                Text("Upgrade Now")
                    .font(MochiFont.body(m.goPremiumButton))
                    .foregroundStyle(.white)
                    .padding(.vertical, 6)
                    .padding(.horizontal, 14)
                    .background(Capsule().fill(MochiGradient.primaryButton))
            }
            .buttonStyle(.plain)
            .padding(.top, 2)
            .accessibilityIdentifier("wallpapers.goPremium")
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: m.goPremiumRadius, style: .continuous).fill(.white))
    }

    // MARK: - Content pane

    private func contentPane(_ m: WallpaperMetrics) -> some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: m.sectionGap) {
                searchBar(m)
                if isSearching {
                    searchResults(m)
                } else {
                    switch page {
                    case .discover:           discoverBody(m)
                    case .theme(let c):       themeBody(c, m)
                    case .section(let s):     sectionBody(s, m)
                    case .collection(let id): collectionBody(id, m)
                    }
                }
            }
            .padding(.leading, m.railWidth + m.contentPadH)
            .padding(.trailing, m.contentPadH)
            .padding(.top, m.contentTop)
            .padding(.bottom, 40)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .animation(.snappy(duration: 0.28), value: stack)
    }

    // MARK: Page bodies

    @ViewBuilder
    private func discoverBody(_ m: WallpaperMetrics) -> some View {
        banner(WallpaperCatalog.featured, tagline: WallpaperCatalog.featured.tagline, m)
        chipRow(m)
        // POPULAR THEMES — the Figma card, 3 across and 3 down.
        section(.popular, m) {
            cardGrid(Array(WallpaperCatalog.popular.prefix(m.popularColumns * m.popularRows)), m)
        }
        section(.collections, m) { collectionsRow(m) }
        section(.trending, m) {
            cardRow(WallpaperCatalog.trending, showsBadge: true, m)
        }
    }

    @ViewBuilder
    private func themeBody(_ category: WallpaperCategory, _ m: WallpaperMetrics) -> some View {
        let items = WallpaperCatalog.wallpapers(in: category)
        if let bannerItem = WallpaperCatalog.wallpaper(id: category.bannerID) {
            banner(bannerItem, tagline: category.tagline, m)
        }
        chipRow(m)
        // A theme page is only ever its own wallpapers — Popular / Collections / Trending are
        // discovery rows and stay on the All Themes page.
        pageHeading("\(category.title.uppercased()) WALLPAPERS", count: items.count, m)
        tileGrid(items, columns: m.gridColumns, gutter: m.gridGutter, showsCaption: true, m)
    }

    @ViewBuilder
    private func sectionBody(_ kind: WallpaperSection, _ m: WallpaperMetrics) -> some View {
        let items = sectionItems(kind)
        // A "see all" page carries the same banner the discovery page does — same crop, same
        // gradient, same button — so arriving here reads as the section opening up rather than as
        // a different screen. Downloads is the exception: with nothing downloaded there is no art
        // to head it with.
        if let art = sectionBannerArt(kind) {
            banner(art, tagline: sectionTagline(kind), m, titleOverride: kind.title.capitalized)
        }
        pageHeading(kind.title, count: items.count, m)
        if items.isEmpty {
            emptyState(kind == .downloads
                       ? "Downloads you keep show up here."
                       : "New wallpapers are on the way.", m)
        } else if kind == .collections {
            collectionsGrid(m)
        } else {
            tileGrid(items, columns: m.gridColumns, gutter: m.gridGutter, showsCaption: true, m)
        }
    }

    @ViewBuilder
    private func collectionBody(_ id: String, _ m: WallpaperMetrics) -> some View {
        if let collection = WallpaperCatalog.collection(id: id) {
            let items = WallpaperCatalog.members(of: collection)
            if let cover = WallpaperCatalog.wallpaper(id: collection.coverID) {
                banner(cover, tagline: "\(items.count) wallpapers in \(collection.name).", m,
                       titleOverride: collection.name)
            }
            pageHeading(collection.name.uppercased(), count: items.count, m)
            tileGrid(items, columns: m.gridColumns, gutter: m.gridGutter, showsCaption: true, m)
        }
    }

    @ViewBuilder
    private func searchResults(_ m: WallpaperMetrics) -> some View {
        let items = WallpaperCatalog.search(trimmedQuery)
        pageHeading("RESULTS", count: items.count, m)
        if items.isEmpty {
            emptyState("No wallpapers match “\(trimmedQuery)”.", m)
        } else {
            tileGrid(items, columns: m.gridColumns, gutter: m.gridGutter, showsCaption: true, m)
        }
    }

    /// The wallpaper whose art heads a section page.
    private func sectionBannerArt(_ kind: WallpaperSection) -> WallpaperItem? {
        switch kind {
        case .popular:     return WallpaperCatalog.popular.first
        case .trending:    return WallpaperCatalog.trending.first
        case .collections: return WallpaperCatalog.collections.first
                .flatMap { WallpaperCatalog.wallpaper(id: $0.coverID) }
        case .downloads:   return recentlyDownloaded.first
        }
    }

    private func sectionTagline(_ kind: WallpaperSection) -> String {
        switch kind {
        case .popular:
            return "The most-loved wallpapers, pulled from every theme in the catalogue."
        case .trending:
            return "New arrivals and what everyone is downloading right now."
        case .collections:
            return "\(WallpaperCatalog.collections.count) hand-picked sets, grouped by mood."
        case .downloads:
            return "Everything you've kept, ready to apply again."
        }
    }

    private func sectionItems(_ kind: WallpaperSection) -> [WallpaperItem] {
        switch kind {
        case .popular:     return WallpaperCatalog.popular
        case .trending:    return WallpaperCatalog.trending
        case .downloads:   return recentlyDownloaded
        case .collections: return WallpaperCatalog.collections.compactMap {
            WallpaperCatalog.wallpaper(id: $0.coverID)
        }
        }
    }

    // MARK: Search

    private func searchBar(_ m: WallpaperMetrics) -> some View {
        HStack(spacing: 6) {
            TextField("", text: $query,
                      prompt: Text("Search wallpapers, collections…")
                        .foregroundColor(MochiColor.textSecondary))
                .font(MochiFont.body(m.search))
                .foregroundStyle(MochiColor.textPrimary)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .accessibilityIdentifier("wallpapers.search")
            if isSearching {
                Button { query = "" } label: {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(MochiColor.textPrimary.opacity(0.5))
                }
                .buttonStyle(.plain)
            } else {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: m.search * 1.15, weight: .semibold))
                    .foregroundStyle(MochiColor.textPrimary.opacity(0.6))
            }
        }
        .padding(.horizontal, m.searchPadH)
        .frame(height: m.searchHeight)
        .background(RoundedRectangle(cornerRadius: m.searchRadius, style: .continuous).fill(.white))
        .overlay(RoundedRectangle(cornerRadius: m.searchRadius, style: .continuous)
            .stroke(MochiColor.logoSolid.opacity(0.25), lineWidth: m.hairline))
        .padding(.top, m.searchPadH)
    }

    // MARK: Banner

    /// The featured banner, reused verbatim as every theme page's and collection page's header —
    /// same crop, same gradient, same button — so the structure stays familiar as pages change.
    private func banner(_ item: WallpaperItem, tagline: String?, _ m: WallpaperMetrics,
                        titleOverride: String? = nil) -> some View {
        WallpaperArt(assetName: item.assetName, anchor: item.cropAnchor, ratio: m.bannerAspect)
            .allowsHitTesting(false)
            .overlay {
                LinearGradient(colors: [.black.opacity(0.5), .black.opacity(0.05), .clear],
                               startPoint: .leading, endPoint: .trailing)
                .allowsHitTesting(false)
            }
            .overlay(alignment: .leading) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(titleOverride ?? item.name)
                        .font(MochiFont.title(m.bannerTitle))
                        .foregroundStyle(.white)
                    if let tagline {
                        Text(tagline)
                            .font(MochiFont.caption(m.bannerDesc))
                            .foregroundStyle(.white.opacity(0.85))
                            .lineLimit(2)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    HStack(spacing: 4) {
                        Image(systemName: "heart.fill").foregroundStyle(MochiColor.heart)
                        Text(item.likeCountText).foregroundStyle(.white)
                    }
                    .font(MochiFont.caption(m.bannerMeta))
                    .padding(.top, 1)
                    Button { preview = item } label: {
                        HStack(spacing: 3) {
                            Text("View Wallpaper")
                            Image(systemName: "chevron.right")
                                .font(.system(size: m.bannerButton * 0.8, weight: .semibold))
                        }
                        .font(MochiFont.body(m.bannerButton))
                        .foregroundStyle(MochiColor.logoSolid)
                        .padding(.vertical, 5).padding(.horizontal, 11)
                        .background(Capsule().fill(.white))
                    }
                    .accessibilityIdentifier("wallpapers.featured.view")
                    .buttonStyle(.plain)
                    .padding(.top, 3)
                }
                .padding(m.bannerPad)
            }
            .clipShape(RoundedRectangle(cornerRadius: m.bannerRadius, style: .continuous))
            .accessibilityElement(children: .contain)
            .accessibilityIdentifier("wallpapers.featured")
    }

    // MARK: Chip row

    private func chipRow(_ m: WallpaperMetrics) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: m.chipGap) {
                ForEach(WallpaperFilter.chipCases) { filter in
                    chip(filter, m)
                }
            }
            .padding(.horizontal, 1)
        }
    }

    private func chip(_ filter: WallpaperFilter, _ m: WallpaperMetrics) -> some View {
        let isSelected = activeFilter == filter
        return Button {
            selectFilter(filter)
        } label: {
            VStack(spacing: 2) {
                FilterIcon(kind: filter.icon, size: m.chipW * 0.42, color: MochiColor.logoSolid)
                Text(filter.chipLabel)
                    .font(MochiFont.caption(m.chip))
                    .foregroundStyle(MochiColor.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            .frame(width: m.chipW, height: m.chipH)
            .background(RoundedRectangle(cornerRadius: m.chipRadius, style: .continuous)
                .fill(isSelected ? MochiColor.logoSolid.opacity(0.10) : Color.white))
            .overlay(RoundedRectangle(cornerRadius: m.chipRadius, style: .continuous)
                .stroke(MochiColor.logoSolid.opacity(isSelected ? min(m.chipBorderOpacity + 0.3, 1) : m.chipBorderOpacity),
                        lineWidth: m.chipBorderWidth))
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("wallpapers.chip.\(filter.rawValue)")
    }

    // MARK: Sections and headings

    /// A discovery row: heading + "see all", then the row's own content. "see all" pushes that
    /// row's dedicated page rather than presenting a sheet.
    private func section<Content: View>(_ kind: WallpaperSection, _ m: WallpaperMetrics,
                                        @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .firstTextBaseline) {
                Text(kind.title)
                    .font(MochiFont.title(m.sectionTitle))
                    .foregroundStyle(MochiColor.textPrimary)
                Spacer(minLength: 4)
                Button { push(.section(kind)) } label: {
                    HStack(spacing: 2) {
                        Text("see all").font(MochiFont.body(m.seeAll))
                        Image(systemName: "chevron.right").font(.system(size: m.seeAll * 0.8, weight: .semibold))
                    }
                    .foregroundStyle(MochiColor.logoSolid)
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("wallpapers.seeAll.\(kind.rawValue)")
            }
            content()
        }
    }

    /// A sub-page's heading: the title, how many wallpapers are under it, and the way back.
    private func pageHeading(_ title: String, count: Int, _ m: WallpaperMetrics) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 6) {
            if !stack.isEmpty {
                Button(action: goBack) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: m.sectionTitle * 0.85, weight: .bold))
                        .foregroundStyle(MochiColor.logoSolid)
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("wallpapers.page.back")
            }
            Text(title)
                .font(MochiFont.title(m.sectionTitle))
                .foregroundStyle(MochiColor.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Spacer(minLength: 4)
            Text("\(count)")
                .font(MochiFont.caption(m.cardMeta))
                .foregroundStyle(MochiColor.textPrimary.opacity(0.55))
        }
        .accessibilityIdentifier("wallpapers.pageHeading")
    }

    private func emptyState(_ message: String, _ m: WallpaperMetrics) -> some View {
        Text(message)
            .font(MochiFont.caption(m.cardMeta))
            .foregroundStyle(MochiColor.textPrimary.opacity(0.6))
            .frame(maxWidth: .infinity, minHeight: m.cardW / m.cardArtAspect, alignment: .leading)
            .accessibilityIdentifier("wallpapers.grid.empty")
    }

    // MARK: Grids and rows

    /// The wallpaper-shaped grid used by every page below discovery, and by Popular Themes. Tiles
    /// keep the source's 9:19.5 portrait ratio so a thumbnail reads as a small wallpaper.
    private func tileGrid(_ items: [WallpaperItem], columns: Int, gutter: CGFloat,
                          showsCaption: Bool, _ m: WallpaperMetrics) -> some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: gutter), count: columns),
                  spacing: gutter) {
            ForEach(items) { item in
                Button { preview = item } label: {
                    VStack(spacing: 0) {
                        WallpaperArt(assetName: item.assetName, anchor: item.cropAnchor,
                                     ratio: m.tileAspect)
                            .overlay(alignment: .topLeading) {
                                if let badge = item.badge, showsCaption {
                                    Text(badge.label)
                                        .font(MochiFont.heading(m.badge))
                                        .foregroundStyle(MochiColor.textPrimary)
                                        .padding(.horizontal, 4).padding(.vertical, 1.5)
                                        .background(Capsule().fill(.white))
                                        .padding(m.badgeInset * 0.7)
                                }
                            }
                            .overlay(alignment: .bottomTrailing) {
                                if isDownloaded(item) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: m.cardMeta * 1.4))
                                        .foregroundStyle(.white, MochiColor.logoSolid)
                                        .padding(m.badgeInset * 0.7)
                                }
                            }
                        if showsCaption {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(item.name)
                                    .font(MochiFont.heading(m.cardName))
                                    .foregroundStyle(MochiColor.textPrimary)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.75)
                                HStack(spacing: 3) {
                                    Image(systemName: "heart.fill").foregroundStyle(MochiColor.heart)
                                    Text(item.likeCountText).foregroundStyle(MochiColor.textPrimary)
                                    Spacer(minLength: 0)
                                }
                                .font(MochiFont.caption(m.cardMeta))
                            }
                            .padding(.horizontal, m.cardPadH * 0.8)
                            .padding(.vertical, 5)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.white)
                        }
                    }
                    .clipShape(RoundedRectangle(cornerRadius: m.gridRadius, style: .continuous))
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("wallpapers.tile.\(item.id)")
            }
        }
    }

    /// The Figma card row — landscape crop, name and like count, a download disc. Kept for
    /// Trending Now so the discovery page still reads the way it was designed.
    private func cardRow(_ items: [WallpaperItem], showsBadge: Bool, _ m: WallpaperMetrics) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: m.cardGutter) {
                ForEach(items) { item in
                    wallpaperCard(item, badge: showsBadge ? item.badge : nil, m, width: m.cardW)
                }
            }
            .padding(.horizontal, 1)
        }
    }

    /// Popular Themes: the same card, laid out 3 across and 3 down. Its art crop is a little taller
    /// than the scrolling rows' (`popularCardArtAspect`), which is the only difference between them.
    private func cardGrid(_ items: [WallpaperItem], _ m: WallpaperMetrics) -> some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: m.popularGutter),
                                 count: m.popularColumns),
                  spacing: m.popularGutter) {
            ForEach(items) { item in
                wallpaperCard(item, badge: item.badge, m,
                              width: nil, artAspect: m.popularCardArtAspect)
            }
        }
    }

    private func wallpaperCard(_ item: WallpaperItem, badge: WallpaperBadge?, _ m: WallpaperMetrics,
                               width: CGFloat? = nil,
                               artAspect: CGFloat? = nil) -> some View {
        let downloaded = isDownloaded(item)
        let cardWidth = width ?? m.cardW
        return VStack(spacing: 0) {
            WallpaperArt(assetName: item.assetName, anchor: item.cropAnchor,
                         ratio: artAspect ?? m.cardArtAspect)
                .allowsHitTesting(false)
                .overlay(alignment: .topLeading) {
                    if let badge {
                        Text(badge.label)
                            .font(MochiFont.heading(m.badge))
                            .foregroundStyle(MochiColor.textPrimary)
                            .padding(.horizontal, 5).padding(.vertical, 2)
                            .background(Capsule().fill(.white))
                            .padding(m.badgeInset)
                    }
                }

            VStack(alignment: .leading, spacing: 3) {
                Text(item.name)
                    .font(MochiFont.heading(m.cardName))
                    .foregroundStyle(MochiColor.textPrimary)
                    .lineLimit(1)
                HStack(spacing: 0) {
                    HStack(spacing: 3) {
                        Image(systemName: "heart.fill").foregroundStyle(MochiColor.heart)
                        Text(item.likeCountText).foregroundStyle(MochiColor.textPrimary)
                    }
                    .font(MochiFont.caption(m.cardMeta))
                    Spacer(minLength: 2)
                    Button {
                        toggleDownload(item)
                    } label: {
                        Image(systemName: downloaded ? "checkmark.circle.fill" : "arrow.down.to.line")
                            .font(.system(size: m.cardMeta * 1.5, weight: .semibold))
                            .foregroundStyle(MochiColor.logoSolid)
                    }
                    .buttonStyle(.plain)
                    .accessibilityIdentifier("wallpapers.card.\(item.id).download")
                }
            }
            .padding(.horizontal, m.cardPadH)
            .frame(width: width == nil ? nil : cardWidth, height: m.cardBodyH, alignment: .leading)
            .frame(maxWidth: width == nil ? .infinity : nil, alignment: .leading)
            .background(Color.white)
        }
        .frame(width: width)
        .clipShape(RoundedRectangle(cornerRadius: m.cardRadius, style: .continuous))
        // The art opens the preview; the disc inside the body keeps its own download action.
        .contentShape(Rectangle())
        .onTapGesture { preview = item }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("wallpapers.card.\(item.id)")
    }

    private func collectionsRow(_ m: WallpaperMetrics) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: m.cardGutter) {
                ForEach(WallpaperCatalog.collections) { collection in
                    collectionCard(collection, m)
                }
            }
            .padding(.horizontal, 1)
        }
    }

    private func collectionsGrid(_ m: WallpaperMetrics) -> some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: m.gridGutter),
                                 count: m.gridColumns),
                  spacing: m.gridGutter) {
            ForEach(WallpaperCatalog.collections) { collection in
                Button { push(.collection(collection.id)) } label: {
                    VStack(spacing: 0) {
                        if let cover = WallpaperCatalog.wallpaper(id: collection.coverID) {
                            WallpaperArt(assetName: cover.assetName, anchor: cover.cropAnchor,
                                         ratio: m.tileAspect)
                        }
                        VStack(alignment: .leading, spacing: 2) {
                            Text(collection.name)
                                .font(MochiFont.heading(m.cardName))
                                .foregroundStyle(MochiColor.textPrimary)
                                .lineLimit(1)
                                .minimumScaleFactor(0.75)
                            Text("\(collection.memberIDs.count) wallpapers")
                                .font(MochiFont.caption(m.cardMeta))
                                .foregroundStyle(MochiColor.textPrimary.opacity(0.6))
                        }
                        .padding(.horizontal, m.cardPadH * 0.8)
                        .padding(.vertical, 5)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.white)
                    }
                    .clipShape(RoundedRectangle(cornerRadius: m.gridRadius, style: .continuous))
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("wallpapers.collectionTile.\(collection.id)")
            }
        }
    }

    private func collectionCard(_ collection: WallpaperCollection, _ m: WallpaperMetrics) -> some View {
        let cover = WallpaperCatalog.wallpaper(id: collection.coverID)
        return VStack(spacing: 0) {
            Group {
                if let cover {
                    WallpaperArt(assetName: cover.assetName, anchor: cover.cropAnchor, ratio: m.cardArtAspect)
                } else {
                    Color(white: 0.95).aspectRatio(m.cardArtAspect, contentMode: .fit)
                }
            }
            .allowsHitTesting(false)

            VStack(alignment: .leading, spacing: 3) {
                Text(collection.name)
                    .font(MochiFont.heading(m.cardName))
                    .foregroundStyle(MochiColor.textPrimary)
                    .lineLimit(1)
                HStack(spacing: 0) {
                    HStack(spacing: 3) {
                        Image(systemName: "heart.fill").foregroundStyle(MochiColor.heart)
                        Text(collection.likeCountText).foregroundStyle(MochiColor.textPrimary)
                    }
                    .font(MochiFont.caption(m.cardMeta))
                    Spacer(minLength: 2)
                    Image(systemName: "chevron.right")
                        .font(.system(size: m.cardMeta * 1.1, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: m.cardMeta * 2.2, height: m.cardMeta * 2.2)
                        .background(Circle().fill(MochiColor.logoSolid))
                }
            }
            .padding(.horizontal, m.cardPadH)
            .frame(width: m.cardW, height: m.cardBodyH, alignment: .leading)
            .background(Color.white)
        }
        .frame(width: m.cardW)
        .clipShape(RoundedRectangle(cornerRadius: m.cardRadius, style: .continuous))
        .contentShape(Rectangle())
        .onTapGesture { push(.collection(collection.id)) }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("wallpapers.collection.\(collection.id)")
    }

    // MARK: - Sheets

    private var moreFilterSheet: some View {
        NavigationStack {
            List(WallpaperCategory.allCases) { category in
                Button {
                    selectFilter(WallpaperFilter(rawValue: category.rawValue) ?? .all)
                    moreSheet = false
                } label: {
                    HStack {
                        FilterIcon(kind: WallpaperFilter(rawValue: category.rawValue)?.icon
                                   ?? .system("square"), size: 16, color: MochiColor.logoSolid)
                        Text(category.title)
                        Spacer()
                        Text("\(WallpaperCatalog.wallpapers(in: category).count)")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("All categories")
            .navigationBarTitleDisplayMode(.inline)
        }
        .presentationDetents([.medium])
    }

    // MARK: - Actions

    private func push(_ destination: WallpaperPage) {
        query = ""
        stack.append(destination)
    }

    private func goBack() {
        if isSearching { query = "" ; return }
        if stack.isEmpty { onBack() } else { stack.removeLast() }
    }

    /// A rail row or chip replaces the whole page history rather than deepening it — tapping
    /// "Nature" from three levels into Collections should land on Nature, not stack onto it.
    private func selectFilter(_ filter: WallpaperFilter) {
        query = ""
        switch filter {
        case .more:
            moreSheet = true
        case .all:
            stack = []
        case .popular:
            stack = [.section(.popular)]
        case .latest:
            stack = [.section(.trending)]
        default:
            if let category = filter.category { stack = [.theme(category)] } else { stack = [] }
        }
    }

    private func toggleDownload(_ item: WallpaperItem) {
        let added = DownloadedWallpaperStore.toggle(item.id)
        downloadedIDs = DownloadedWallpaperStore.loadDownloadedWallpaperIDs()
        if added { UIImpactFeedbackGenerator(style: .light).impactOccurred() }
    }

    private func isDownloaded(_ item: WallpaperItem) -> Bool { downloadedIDs.contains(item.id) }
}

/// A wallpaper source (portrait 9:19.5) drawn to fill whatever box it's given, anchored so the
/// subject isn't cropped out. With `ratio` set it constrains itself to that width:height; without
/// it, it fills the size the caller provides (fixed-frame thumbnails).
struct WallpaperArt: View {
    let assetName: String
    var anchor: UnitPoint = .center
    var ratio: CGFloat? = nil

    private var frameAlignment: Alignment {
        let h: HorizontalAlignment = anchor.x == 0 ? .leading : (anchor.x == 1 ? .trailing : .center)
        let v: VerticalAlignment = anchor.y == 0 ? .top : (anchor.y == 1 ? .bottom : .center)
        return Alignment(horizontal: h, vertical: v)
    }

    private var fill: some View {
        GeometryReader { geo in
            Image(assetName)
                .resizable()
                .scaledToFill()
                .frame(width: geo.size.width, height: geo.size.height, alignment: frameAlignment)
                .clipped()
        }
    }

    @ViewBuilder
    var body: some View {
        if let ratio {
            Color.clear
                .aspectRatio(ratio, contentMode: .fit)
                .overlay { fill }
                .clipped()
        } else {
            fill
        }
    }
}

#Preview {
    WallpapersView()
}
