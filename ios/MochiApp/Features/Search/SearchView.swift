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
private let searchResults: [SearchResult] = [
    SearchResult(id: "pastel-rainbow", name: "Pastel Rainbow", label: "Theme", likeCount: 12_500, downloadCount: 3_400, assetName: "theme_pastel_rainbow", isFont: false, showMoreBadge: true),
    SearchResult(id: "forest-theme", name: "Forest Theme", label: "Theme", likeCount: 908, downloadCount: 2_600, assetName: "theme_forest", isFont: false, showMoreBadge: true),
    SearchResult(id: "pastel-pink-sky", name: "Pastel Pink Sky", label: "Theme", likeCount: 12_500, downloadCount: 3_100, assetName: "theme_pastel_pink_sky", isFont: false, showMoreBadge: true),
    SearchResult(id: "sweet-handwriting", name: "Sweet Handwriting", label: "Font", likeCount: 755, downloadCount: 1_800, assetName: "font_typewriter_classic", isFont: true, showMoreBadge: true),
    SearchResult(id: "sakura-train", name: "Sakura Train", label: "Theme", likeCount: 10_000, downloadCount: 2_400, assetName: "theme_sakura_train", isFont: false, showMoreBadge: false),
    SearchResult(id: "space-vibe", name: "Space vibe", label: "Theme", likeCount: 805, downloadCount: 1_600, assetName: "theme_space_vibe", isFont: false, showMoreBadge: false),
    SearchResult(id: "bold-strong", name: "Bold Strong", label: "Font", likeCount: 10_000, downloadCount: 2_100, assetName: "font_bold_strong", isFont: true, showMoreBadge: false),
    SearchResult(id: "gothic-dark", name: "Gothic Dark", label: "Font", likeCount: 650, downloadCount: 1_000, assetName: "font_gothic_dark", isFont: true, showMoreBadge: false)
]

struct SearchView: View {
    var onBack: () -> Void = {}

    @State private var query = ""
    @State private var selectedType = "All"

    var body: some View {
        ZStack {
            MochiGradient.background.ignoresSafeArea()
            ScrollView {
                VStack(spacing: MochiSpacing.lg) {
                    header
                    typeFilterChips
                    recentSearchesSection
                    trendingSearchesSection
                    suggestionsSection
                    filtersSection
                    searchResultsSection
                    noResultsCard
                }
                .padding(.horizontal, MochiSpacing.md)
                .padding(.top, MochiSpacing.md)
                .padding(.bottom, 100)
            }
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
                Text("128 Results")
                    .font(MochiFont.caption(12))
                    .foregroundStyle(MochiColor.textSecondary)
            }
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: MochiSpacing.sm), count: 4), spacing: MochiSpacing.md) {
                ForEach(searchResults) { item in
                    ResultCard(item: item)
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
            Text("No results found for \"dreamy night\"")
                .font(MochiFont.heading(15))
                .foregroundStyle(MochiColor.purple)
            Text("Try different keywords or browse categories instead.")
                .font(MochiFont.body(12))
                .lineSpacing(2)
                .foregroundStyle(MochiColor.textSecondary)
                .multilineTextAlignment(.center)
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
