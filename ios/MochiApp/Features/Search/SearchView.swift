import SwiftUI

/// Ported from docs/figma/6.png.
///
/// The screen is a real search over the app's **own** catalogues — the built-in theme system
/// (`ThemeCatalog.all` + published custom themes), the font collection (`MockData.fontCollection`),
/// and the set of theme authors. There is no Firestore text index and no budget for a search
/// service, so relevance is done client-side by `SearchEngine`: a small hand-authored concept
/// lexicon (`SearchConcepts`) lets "night" surface the dark themes, "shiny" the glow/aurora ones,
/// and so on, without every item needing the literal word in its title.
///
/// The results grid is 4 columns — Android's `SearchScreen.kt` uses `chunked(2)`, but the Figma
/// export clearly shows four, verified by cropping the export directly.
struct SearchView: View {
    var onBack: () -> Void = {}
    var onThemeClick: (KeyboardTheme) -> Void = { _ in }
    /// A font result was tapped — pop to the Fonts tab with this style selected.
    var onFontClick: (String) -> Void = { _ in }
    /// A creator result was tapped — push their profile.
    var onCreatorClick: (String) -> Void = { _ in }

    @StateObject private var vm = SearchViewModel()
    @FocusState private var queryFocused: Bool

    private let typeFilters: [(type: SearchContentType?, name: String, icon: String)] = [
        (nil, "All", "square.grid.2x2.fill"),
        (.theme, "Theme", "paintpalette.fill"),
        (.font, "Font", ""),
        (.creator, "Creator", "person.fill")
    ]

    var body: some View {
        ZStack {
            MochiGradient.background.ignoresSafeArea()
            ScrollView {
                VStack(spacing: MochiSpacing.lg) {
                    header
                    typeFilterChips
                    if !vm.recentSearches.isEmpty {
                        recentSearchesSection
                    }
                    trendingSearchesSection
                    if !vm.hasQuery {
                        suggestionsSection
                    }
                    filtersSection
                    if vm.results.isEmpty {
                        noResultsCard
                    } else {
                        searchResultsSection
                    }
                }
                .padding(.horizontal, MochiSpacing.md)
                .padding(.top, MochiSpacing.md)
                // RootView keeps MochiTabBar (bar ~84pt + the Create FAB overhanging ~40pt above
                // it) drawn over this screen, so the last section needs clearance to scroll fully
                // clear of it.
                .padding(.bottom, 140)
            }
            .scrollIndicators(.hidden)
            .scrollDismissesKeyboard(.interactively)
        }
    }

    // MARK: - Header

    private var header: some View {
        HStack(spacing: MochiSpacing.sm) {
            Button(action: onBack) {
                Image(systemName: "arrow.left")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 44, height: 44)
                    .background(MochiGradient.primaryButton)
                    .clipShape(Circle())
            }
            .accessibilityIdentifier("search.back")

            HStack(spacing: MochiSpacing.sm) {
                TextField("", text: $vm.query, prompt: Text("Search themes, creators..").foregroundColor(MochiColor.textSecondary))
                    .font(MochiFont.body(14))
                    .foregroundStyle(MochiColor.textPrimary)
                    .focused($queryFocused)
                    .submitLabel(.search)
                    .autocorrectionDisabled()
                    .onSubmit { vm.commitQuery() }
                    .accessibilityIdentifier("search.field")

                if vm.hasQuery {
                    Button {
                        vm.clearQuery()
                        queryFocused = true
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(MochiColor.textSecondary)
                    }
                    .accessibilityIdentifier("search.field.clear")
                } else {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(MochiColor.textPrimary)
                }
            }
            .padding(.horizontal, MochiSpacing.md)
            .padding(.vertical, 14)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: MochiRadius.pill, style: .continuous))
        }
    }

    // MARK: - Type pills

    /// Four equal-width pills spanning the content width — no horizontal scroll. Figma's pills are
    /// content-sized and run off the right edge; the brief asks for all four to fit cleanly on one
    /// screen, so they're distributed evenly here while keeping the pill / gradient-selected look.
    private var typeFilterChips: some View {
        HStack(spacing: MochiSpacing.sm) {
            ForEach(typeFilters, id: \.name) { filter in
                let isSelected = filter.type == vm.selectedType
                Button {
                    vm.selectedType = filter.type
                } label: {
                    HStack(spacing: 5) {
                        if filter.name == "Font" {
                            Text("Aa")
                                .font(.system(size: 13, weight: .bold, design: .rounded))
                        } else {
                            Image(systemName: filter.icon)
                                .font(.system(size: 12))
                        }
                        Text(filter.name)
                            .font(MochiFont.heading(13))
                            .lineLimit(1)
                            .minimumScaleFactor(0.75)
                    }
                    .foregroundStyle(isSelected ? .white : MochiColor.textPrimary)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 10)
                    .background {
                        if isSelected {
                            MochiGradient.primaryButton
                        } else {
                            Color.white
                        }
                    }
                    .clipShape(RoundedRectangle(cornerRadius: MochiRadius.pill, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: MochiRadius.pill, style: .continuous)
                            .strokeBorder(isSelected ? Color.clear : MochiColor.purple.opacity(0.25))
                    )
                }
                .accessibilityIdentifier("search.type.\(filter.name)")
            }
        }
    }

    // MARK: - Recent searches

    private var recentSearchesSection: some View {
        SearchSectionCard {
            HStack {
                Text("RECENT SEARCHES")
                    .font(MochiFont.title(13))
                    .foregroundStyle(MochiColor.textPrimary)
                Spacer()
                Button {
                    vm.clearRecentSearches()
                } label: {
                    Text("Clear All")
                        .font(MochiFont.caption(12))
                        .foregroundStyle(MochiColor.textSecondary)
                }
                .accessibilityIdentifier("search.recent.clearAll")
            }
            FlowLayout(spacing: 8) {
                ForEach(vm.recentSearches, id: \.self) { term in
                    PillChip(label: term, icon: "clock") { vm.runSearch(term) }
                        .accessibilityIdentifier("search.recent.\(term)")
                }
            }
        }
    }

    // MARK: - Trending searches

    private var trendingSearchesSection: some View {
        SearchSectionCard {
            HStack {
                HStack(spacing: 4) {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .font(.system(size: 13))
                        .foregroundStyle(MochiColor.textPrimary)
                    Text("TRENDING SEARCHES")
                        .font(MochiFont.title(13))
                        .foregroundStyle(MochiColor.textPrimary)
                }
                Spacer()
                Button {
                    vm.refreshTrending()
                } label: {
                    HStack(spacing: 4) {
                        Text("Refresh")
                            .font(MochiFont.caption(12))
                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 11))
                    }
                    .foregroundStyle(MochiColor.textSecondary)
                }
                .accessibilityIdentifier("search.trending.refresh")
            }
            FlowLayout(spacing: 8) {
                ForEach(vm.trendingSearches, id: \.self) { term in
                    PillChip(label: term, icon: "chart.line.uptrend.xyaxis") { vm.runSearch(term) }
                        .accessibilityIdentifier("search.trending.\(term)")
                }
            }
        }
    }

    // MARK: - Suggestions

    private var suggestionsSection: some View {
        SearchSectionCard {
            Text("SUGGESTIONS")
                .font(MochiFont.title(13))
                .foregroundStyle(MochiColor.textPrimary)
            ForEach(vm.suggestions, id: \.self) { suggestion in
                Button {
                    vm.runSearch(suggestion)
                } label: {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 14))
                            .foregroundStyle(MochiColor.textSecondary)
                        Text(suggestion)
                            .font(MochiFont.body(13))
                            .foregroundStyle(MochiColor.textSecondary)
                            .padding(.horizontal, 8)
                        Spacer()
                        Image(systemName: "arrow.up.right")
                            .font(.system(size: 12))
                            .foregroundStyle(MochiColor.textSecondary)
                    }
                    .padding(.vertical, 6)
                    .contentShape(Rectangle())
                }
                .accessibilityIdentifier("search.suggestion.\(suggestion)")
            }
        }
    }

    // MARK: - Filters

    private var filtersSection: some View {
        VStack(alignment: .leading, spacing: MochiSpacing.sm) {
            Text("FILTERS")
                .font(MochiFont.title(13))
                .foregroundStyle(MochiColor.textPrimary)
            HStack(spacing: 8) {
                Menu {
                    Picker("Type", selection: $vm.tierFilter) {
                        ForEach(SearchTierFilter.allCases) { Text($0.rawValue).tag($0) }
                    }
                } label: {
                    filterChipLabel(text: vm.tierFilter.rawValue,
                                    icon: "line.3.horizontal.decrease",
                                    isActive: vm.tierFilter != .all)
                }
                .accessibilityIdentifier("search.filter.tier")

                Menu {
                    Picker("Sort", selection: $vm.sortOption) {
                        ForEach(SearchSortOption.allCases) { Text($0.rawValue).tag($0) }
                    }
                } label: {
                    filterChipLabel(text: vm.sortOption.rawValue,
                                    icon: "arrow.up.arrow.down",
                                    isActive: vm.sortOption != .relevance)
                }
                .accessibilityIdentifier("search.filter.sort")

                Spacer(minLength: 0)
            }
        }
    }

    private func filterChipLabel(text: String, icon: String, isActive: Bool) -> some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 12))
            Text(text)
                .font(MochiFont.caption(12))
            Image(systemName: "chevron.down")
                .font(.system(size: 10))
        }
        .foregroundStyle(isActive ? .white : MochiColor.textPrimary)
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(isActive ? AnyView(MochiGradient.primaryButton) : AnyView(Color.white))
        .clipShape(RoundedRectangle(cornerRadius: MochiRadius.pill, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: MochiRadius.pill, style: .continuous)
                .strokeBorder(isActive ? Color.clear : MochiColor.purple.opacity(0.25))
        )
    }

    // MARK: - Results

    private var searchResultsSection: some View {
        VStack(alignment: .leading, spacing: MochiSpacing.sm) {
            HStack {
                Text("SEARCH RESULTS")
                    .font(MochiFont.title(13))
                    .foregroundStyle(MochiColor.textPrimary)
                Spacer()
                Text(vm.resultCountLabel)
                    .font(MochiFont.caption(12))
                    .foregroundStyle(MochiColor.textSecondary)
                    .accessibilityIdentifier("search.results.count")
            }
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: MochiSpacing.sm), count: 4), spacing: MochiSpacing.md) {
                ForEach(vm.results) { item in
                    Button {
                        handleTap(item)
                    } label: {
                        ResultCard(item: item)
                    }
                    .buttonStyle(.plain)
                    .accessibilityIdentifier("search.result.\(item.id)")
                }
            }
        }
    }

    private func handleTap(_ item: SearchResult) {
        switch item.kind {
        case .theme:
            if let theme = item.theme { onThemeClick(theme) }
        case .font:
            if let fontID = item.fontID { onFontClick(fontID) }
        case .creator:
            if let name = item.creatorName { onCreatorClick(name) }
        }
    }

    private var noResultsCard: some View {
        VStack(spacing: MochiSpacing.sm) {
            HStack {
                Text("NO RESULTS")
                    .font(MochiFont.title(13))
                    .foregroundStyle(MochiColor.textPrimary)
                Spacer()
            }
            Image("icon_sad_mochi")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 72, height: 72)
                .clipShape(Circle())
            Text(vm.hasQuery ? "No results found for “\(vm.query)”" : "Nothing matches this filter")
                .font(MochiFont.heading(15))
                .foregroundStyle(MochiColor.purple)
                .multilineTextAlignment(.center)
            Text("Try different keywords or browse categories instead.")
                .font(MochiFont.body(12))
                .lineSpacing(2)
                .foregroundStyle(MochiColor.textSecondary)
                .multilineTextAlignment(.center)
            if vm.hasQuery {
                Button {
                    vm.clearQuery()
                } label: {
                    Text("Clear Search")
                        .font(MochiFont.button(13))
                        .foregroundStyle(MochiColor.purple)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .overlay(
                            RoundedRectangle(cornerRadius: MochiRadius.pill, style: .continuous)
                                .strokeBorder(MochiColor.purple.opacity(0.3))
                        )
                }
                .accessibilityIdentifier("search.noResults.clear")
            } else if vm.tierFilter != .all {
                Button {
                    vm.tierFilter = .all
                } label: {
                    Text("Reset Filters")
                        .font(MochiFont.button(13))
                        .foregroundStyle(MochiColor.purple)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .overlay(
                            RoundedRectangle(cornerRadius: MochiRadius.pill, style: .continuous)
                                .strokeBorder(MochiColor.purple.opacity(0.3))
                        )
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(MochiSpacing.md)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: MochiRadius.card, style: .continuous))
    }
}

// MARK: - Section card

private struct SearchSectionCard<Content: View>: View {
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: MochiSpacing.sm, content: { content })
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(MochiSpacing.md)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: MochiRadius.card, style: .continuous))
    }
}

// MARK: - Pill chip

private struct PillChip: View {
    let label: String
    let icon: String
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 11))
                    .foregroundStyle(MochiColor.textSecondary)
                Text(label)
                    .font(MochiFont.caption(12))
                    .foregroundStyle(MochiColor.textPrimary)
                    .lineLimit(1)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: MochiRadius.pill, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: MochiRadius.pill, style: .continuous)
                    .strokeBorder(MochiColor.purple.opacity(0.25))
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Result card

private struct ResultCard: View {
    let item: SearchResult

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            ZStack(alignment: .topTrailing) {
                artwork
                    .aspectRatio(1.35, contentMode: .fit)
                    .clipShape(RoundedRectangle(cornerRadius: MochiRadius.card, style: .continuous))

                Image(systemName: "ellipsis")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(width: 22, height: 22)
                    .background(Color.black.opacity(0.3))
                    .clipShape(Circle())
                    .padding(6)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(item.name)
                    .font(MochiFont.heading(11))
                    .foregroundStyle(MochiColor.textPrimary)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
                Text(item.label)
                    .font(MochiFont.caption(11))
                    .foregroundStyle(MochiColor.purple)
                statsRow
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 4)
            .padding(.bottom, 4)
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: MochiRadius.card, style: .continuous))
    }

    @ViewBuilder
    private var artwork: some View {
        switch item.kind {
        case .theme:
            ThemePlateThumbnail(assetName: item.assetName,
                                verticalAnchor: item.plateAnchor,
                                maxPixelDimension: 260)
        case .font:
            FontArtCard(assetName: item.assetName) {
                Color(red: 0.91, green: 0.949, blue: 0.988)
            }
        case .creator:
            ZStack {
                MochiGradient.primaryButton
                Text(initials(for: item.name))
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
            }
        }
    }

    @ViewBuilder
    private var statsRow: some View {
        switch item.kind {
        case .creator:
            HStack(spacing: 3) {
                Image(systemName: "square.grid.2x2.fill")
                    .font(.system(size: 8))
                    .foregroundStyle(MochiColor.textSecondary)
                Text(item.subtitle)
                    .font(MochiFont.caption(10))
                    .foregroundStyle(MochiColor.textSecondary)
            }
        case .theme, .font:
            if item.likeCount > 0 || item.downloadCount > 0 {
                HStack(spacing: 2) {
                    if item.likeCount > 0 {
                        Image(systemName: "heart.fill")
                            .font(.system(size: 9))
                            .foregroundStyle(MochiColor.pink)
                        Text(item.likeCount.formattedCompact)
                            .font(MochiFont.caption(10))
                            .foregroundStyle(MochiColor.textSecondary)
                    }
                    Spacer(minLength: 2)
                    if item.downloadCount > 0 {
                        Image(systemName: "arrow.down.to.line")
                            .font(.system(size: 9))
                            .foregroundStyle(MochiColor.textSecondary)
                        Text(item.downloadCount.formattedCompact)
                            .font(MochiFont.caption(10))
                            .foregroundStyle(MochiColor.textSecondary)
                    }
                }
            } else if !item.subtitle.isEmpty {
                Text(item.subtitle)
                    .font(MochiFont.caption(10))
                    .foregroundStyle(MochiColor.textSecondary)
                    .lineLimit(1)
            }
        }
    }

    private func initials(for name: String) -> String {
        let parts = name.split(separator: " ").prefix(2)
        let letters = parts.compactMap { $0.first }.map(String.init)
        return letters.joined().uppercased()
    }
}

/// Simple wrapping layout for the pill rows (Figma wraps to multiple lines; a plain HStack would
/// overflow instead).
private struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let width = proposal.width ?? .infinity
        var x: CGFloat = 0, y: CGFloat = 0, rowHeight: CGFloat = 0
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > width, x > 0 {
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
        return CGSize(width: width, height: y + rowHeight)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x = bounds.minX, y = bounds.minY, rowHeight: CGFloat = 0
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > bounds.maxX, x > bounds.minX {
                x = bounds.minX
                y += rowHeight + spacing
                rowHeight = 0
            }
            subview.place(at: CGPoint(x: x, y: y), proposal: .unspecified)
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
    }
}

#Preview {
    SearchView()
}
