import SwiftUI

struct SearchResult: Identifiable, Hashable {
    let id: String
    let name: String
    let label: String
    let likeCount: Int
    let downloadCount: Int
    let assetName: String
    let isFont: Bool
    let showMoreBadge: Bool
    /// The catalogue theme this result stands for, when it's a theme — tapping it opens Theme Detail.
    var theme: KeyboardTheme? = nil

    init(theme: KeyboardTheme) {
        self.id = "theme:\(theme.id)"
        self.name = theme.name
        self.label = "Theme"
        self.likeCount = theme.likeCount
        self.downloadCount = theme.downloadCount
        self.assetName = theme.imageAssetName
        self.isFont = false
        self.showMoreBadge = true
        self.theme = theme
    }

    init(font: FontItem) {
        self.id = "font:\(font.id)"
        self.name = font.name
        self.label = "Font"
        self.likeCount = 0
        self.downloadCount = 0
        self.assetName = font.artAssetName
        self.isFont = true
        self.showMoreBadge = true
        self.theme = nil
    }
}

private let typeFilters: [(name: String, icon: String)] = [
    ("All", "square.grid.2x2.fill"),
    ("Theme", "paintpalette.fill"),
    ("Font", ""),
    ("Creators", "person.fill")
]

private let recentSearches = ["cotton candy", "handwritten font", "neon night", "mochi studio"]
private let trendingSearches = ["pastel theme", "cute font", "aesthetic keyboard", "galaxy theme", "minimal", "anime theme", "typewriter font", "handwriting"]
private let suggestions = ["Cute Themes", "Dark Themes", "Handwritten Fonts", "Pixel Art Themes"]
private let filterDropdowns: [(label: String, icon: String, isSelected: Bool)] = [
    ("All Types", "square.grid.2x2.fill", true),
    ("Free Only", "calendar", false),
    ("Premium", "crown.fill", false),
    ("Newest", "clock", false)
]

/// Ported from docs/figma/6.png. Android's SearchScreen.kt (chunked(2)) uses a 2-column results
/// grid, but the Figma export clearly shows 4 columns — verified by cropping and inspecting the
/// export directly, so this diverges from the Android port on that one point.
///
/// Results are a live substring filter over the same catalogue the rest of the app browses
/// (`MockData`) — no Firestore text index exists and there's no budget for a search service, so
/// this is the same bounded-pool + client-side-filter shape Android's Search uses.
struct SearchView: View {
    var onBack: () -> Void = {}
    var onThemeClick: (KeyboardTheme) -> Void = { _ in }

    @State private var query = ""
    @State private var selectedType = "All"

    /// Catalogue → result rows, filtered by the query text and the selected type chip.
    private var results: [SearchResult] {
        let q = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()

        let themeRows: [SearchResult] = MockData.allThemes
            .filter { theme in
                guard !q.isEmpty else { return true }
                return theme.name.lowercased().contains(q)
                    || theme.creatorName.lowercased().contains(q)
                    || theme.hashtags.contains { $0.lowercased().contains(q) }
            }
            .map(SearchResult.init(theme:))

        let fontRows: [SearchResult] = MockData.fontCollection
            .filter { font in
                guard !q.isEmpty else { return true }
                return font.name.lowercased().contains(q)
                    || font.styleDescription.lowercased().contains(q)
            }
            .map(SearchResult.init(font:))

        switch selectedType {
        case "Theme": return themeRows
        case "Font": return fontRows
        case "Creators":
            guard !q.isEmpty else { return themeRows }
            return MockData.allThemes
                .filter { $0.creatorName.lowercased().contains(q) }
                .map(SearchResult.init(theme:))
        default: return themeRows + fontRows
        }
    }

    private var hasQuery: Bool {
        !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        ZStack {
            MochiGradient.background.ignoresSafeArea()
            ScrollView {
                VStack(spacing: MochiSpacing.lg) {
                    header
                    typeFilterChips
                    recentSearchesSection
                    trendingSearchesSection
                    if !hasQuery {
                        suggestionsSection
                    }
                    filtersSection
                    if results.isEmpty {
                        noResultsCard
                    } else {
                        searchResultsSection
                    }
                }
                .padding(.horizontal, MochiSpacing.md)
                .padding(.top, MochiSpacing.md)
                // RootView keeps MochiTabBar (bar ~84pt + the Create FAB overhanging ~40pt above
                // it) drawn over this screen, so the last section needs clearance to scroll fully
                // clear of it — 100 left the FILTERS row and results grid pinned behind the bar.
                .padding(.bottom, 140)
            }
            .scrollIndicators(.hidden)
        }
    }

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
                TextField("", text: $query, prompt: Text("Search themes, creators..").foregroundColor(MochiColor.textSecondary))
                    .font(MochiFont.body(14))
                    .foregroundStyle(MochiColor.textPrimary)
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(MochiColor.textPrimary)
            }
            .padding(.horizontal, MochiSpacing.md)
            .padding(.vertical, 14)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: MochiRadius.pill, style: .continuous))
        }
    }

    private var typeFilterChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: MochiSpacing.sm) {
                ForEach(typeFilters, id: \.name) { filter in
                    let isSelected = filter.name == selectedType
                    Button {
                        selectedType = filter.name
                    } label: {
                        HStack(spacing: 6) {
                            if filter.name == "Font" {
                                Text("Aa")
                                    .font(.system(size: 14, weight: .bold, design: .rounded))
                            } else {
                                Image(systemName: filter.icon)
                                    .font(.system(size: 13))
                            }
                            Text(filter.name)
                                .font(MochiFont.heading(13))
                        }
                        .foregroundStyle(isSelected ? .white : MochiColor.textPrimary)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(
                            Group {
                                if isSelected {
                                    MochiGradient.primaryButton
                                } else {
                                    Color.white
                                }
                            }
                        )
                        .clipShape(RoundedRectangle(cornerRadius: MochiRadius.pill, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: MochiRadius.pill, style: .continuous)
                                .strokeBorder(isSelected ? Color.clear : MochiColor.purple.opacity(0.25))
                        )
                    }
                }
            }
        }
    }

    private var recentSearchesSection: some View {
        SearchSectionCard {
            HStack {
                Text("RECENT SEARCHES")
                    .font(MochiFont.title(13))
                    .foregroundStyle(MochiColor.textPrimary)
                Spacer()
                Text("Clear All")
                    .font(MochiFont.caption(12))
                    .foregroundStyle(MochiColor.textSecondary)
            }
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(recentSearches, id: \.self) { term in
                        PillChip(label: term, icon: "clock")
                    }
                }
            }
        }
    }

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
                HStack(spacing: 4) {
                    Text("Refresh")
                        .font(MochiFont.caption(12))
                        .foregroundStyle(MochiColor.textSecondary)
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 11))
                        .foregroundStyle(MochiColor.textSecondary)
                }
            }
            FlowLayout(spacing: 8) {
                ForEach(trendingSearches, id: \.self) { term in
                    PillChip(label: term, icon: "chart.line.uptrend.xyaxis")
                }
            }
        }
    }

    private var suggestionsSection: some View {
        SearchSectionCard {
            Text("SUGGESTIONS")
                .font(MochiFont.title(13))
                .foregroundStyle(MochiColor.textPrimary)
            ForEach(suggestions, id: \.self) { suggestion in
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
            }
        }
    }

    private var filtersSection: some View {
        VStack(alignment: .leading, spacing: MochiSpacing.sm) {
            Text("FILTERS")
                .font(MochiFont.title(13))
                .foregroundStyle(MochiColor.textPrimary)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(filterDropdowns, id: \.label) { filter in
                        HStack(spacing: 4) {
                            Image(systemName: filter.icon)
                                .font(.system(size: 12))
                            Text(filter.label)
                                .font(MochiFont.caption(12))
                            Image(systemName: "chevron.down")
                                .font(.system(size: 10))
                        }
                        .foregroundStyle(filter.isSelected ? .white : MochiColor.textPrimary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(filter.isSelected ? AnyView(MochiGradient.primaryButton) : AnyView(Color.white))
                        .clipShape(RoundedRectangle(cornerRadius: MochiRadius.pill, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: MochiRadius.pill, style: .continuous)
                                .strokeBorder(filter.isSelected ? Color.clear : MochiColor.purple.opacity(0.25))
                        )
                    }
                }
            }
        }
    }

    private var searchResultsSection: some View {
        VStack(alignment: .leading, spacing: MochiSpacing.sm) {
            HStack {
                Text("SEARCH RESULTS")
                    .font(MochiFont.title(13))
                    .foregroundStyle(MochiColor.textPrimary)
                Spacer()
                Text("\(results.count) Result\(results.count == 1 ? "" : "s")")
                    .font(MochiFont.caption(12))
                    .foregroundStyle(MochiColor.textSecondary)
            }
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: MochiSpacing.sm), count: 4), spacing: MochiSpacing.md) {
                ForEach(results) { item in
                    ResultCard(item: item)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            if let theme = item.theme { onThemeClick(theme) }
                        }
                }
            }
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
            Text(hasQuery ? "No results found for “\(query)”" : "Nothing to show yet")
                .font(MochiFont.heading(15))
                .foregroundStyle(MochiColor.purple)
                .multilineTextAlignment(.center)
            Text("Try different keywords or browse categories instead.")
                .font(MochiFont.body(12))
                .lineSpacing(2)
                .foregroundStyle(MochiColor.textSecondary)
                .multilineTextAlignment(.center)
            if hasQuery {
                Button {
                    query = ""
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
            }
        }
        .frame(maxWidth: .infinity)
        .padding(MochiSpacing.md)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: MochiRadius.card, style: .continuous))
    }
}

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

private struct PillChip: View {
    let label: String
    let icon: String

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 11))
                .foregroundStyle(MochiColor.textSecondary)
            Text(label)
                .font(MochiFont.caption(12))
                .foregroundStyle(MochiColor.textPrimary)
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
}

private struct ResultCard: View {
    let item: SearchResult

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            ZStack(alignment: .topTrailing) {
                Group {
                    if item.isFont {
                        FontArtCard(assetName: item.assetName) {
                            Color(red: 0.91, green: 0.949, blue: 0.988)
                        }
                    } else {
                        KeyboardThemeArt(assetName: item.assetName, seed: item.name)
                    }
                }
                .aspectRatio(1.35, contentMode: .fit)

                Image(systemName: item.showMoreBadge ? "ellipsis" : "arrow.down")
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
                HStack(spacing: 2) {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 9))
                        .foregroundStyle(MochiColor.pink)
                    Text(item.likeCount.formattedCompact)
                        .font(MochiFont.caption(10))
                        .foregroundStyle(MochiColor.textSecondary)
                    Spacer(minLength: 2)
                    Image(systemName: "arrow.down.to.line")
                        .font(.system(size: 9))
                        .foregroundStyle(MochiColor.textSecondary)
                    Text(item.downloadCount.formattedCompact)
                        .font(MochiFont.caption(10))
                        .foregroundStyle(MochiColor.textSecondary)
                }
            }
            .padding(.horizontal, 4)
            .padding(.bottom, 4)
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: MochiRadius.card, style: .continuous))
    }
}

/// Simple wrapping layout for the trending-searches pill row (Figma wraps to multiple lines;
/// a plain HStack would overflow instead).
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
