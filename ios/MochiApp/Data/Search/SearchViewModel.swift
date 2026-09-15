import Foundation
import Combine

/// Free / premium axis for the FILTERS row.
enum SearchTierFilter: String, CaseIterable, Identifiable {
    case all = "All Types", free = "Free Only", premium = "Premium"
    var id: String { rawValue }

    func includes(_ result: SearchResult) -> Bool {
        switch self {
        case .all: return true
        case .free: return !result.isPremium
        case .premium: return result.isPremium
        }
    }
}

/// Ordering for the FILTERS row. "Relevance" keeps `SearchEngine`'s ranked order; the other two
/// re-sort it. "Newest" has no real dates, so — like `ThemesView`/`FontsView` — it means reverse
/// catalogue order (added last = newest).
enum SearchSortOption: String, CaseIterable, Identifiable {
    case relevance = "Relevance", newest = "Newest", mostLiked = "Most Liked"
    var id: String { rawValue }

    func apply(_ results: [SearchResult]) -> [SearchResult] {
        switch self {
        case .relevance:
            return results
        case .newest:
            return results.sorted { $0.catalogueIndex > $1.catalogueIndex }
        case .mostLiked:
            return results.sorted { $0.likeCount > $1.likeCount }
        }
    }
}

/// Drives the Search screen. The relevance work lives in `SearchEngine` (pure statics, so it stays
/// testable); this object just holds the query/filter state, recomputes `results` when any of it
/// changes, and owns the recent-search list.
@MainActor
final class SearchViewModel: ObservableObject {
    /// `nil` = the "All" pill.
    @Published var selectedType: SearchContentType?
    @Published var query: String = ""
    @Published var tierFilter: SearchTierFilter = .all
    @Published var sortOption: SearchSortOption = .relevance

    @Published private(set) var results: [SearchResult] = []
    @Published private(set) var recentSearches: [String] = RecentSearchStore.load()
    @Published private(set) var trendingSearches: [String]

    let suggestions: [String]

    /// The full trending set — `refreshTrending()` reshuffles the visible slice from it. Static
    /// content for now (per the brief); only the interaction is real.
    private static let trendingPool = [
        "pastel theme", "cute font", "aesthetic keyboard", "galaxy theme", "minimal",
        "anime theme", "typewriter font", "handwriting", "cozy cafe", "night sky",
        "sakura", "royal", "ocean", "gothic",
    ]

    init(corpus: SearchCorpus = .build()) {
        self.trendingSearches = Array(Self.trendingPool.prefix(8))
        self.suggestions = Self.deriveSuggestions(from: corpus)

        Publishers.CombineLatest4($query, $selectedType, $tierFilter, $sortOption)
            .map { [corpus] query, type, tier, sort in
                let ranked = SearchEngine.rank(query: query, type: type, corpus: corpus)
                return sort.apply(ranked.filter { tier.includes($0) })
            }
            .assign(to: &$results)
    }

    var hasQuery: Bool {
        !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var resultCountLabel: String {
        "\(results.count) Result\(results.count == 1 ? "" : "s")"
    }

    // MARK: - Intents

    /// Commit the current query to recents (called from `onSubmit`).
    func commitQuery() {
        guard hasQuery else { return }
        recentSearches = RecentSearchStore.record(query)
    }

    /// A recent / trending / suggestion chip was tapped — run it and record it.
    func runSearch(_ term: String) {
        query = term
        recentSearches = RecentSearchStore.record(term)
    }

    func clearQuery() {
        query = ""
    }

    func clearRecentSearches() {
        recentSearches = RecentSearchStore.clear()
    }

    func refreshTrending() {
        trendingSearches = Array(Self.trendingPool.shuffled().prefix(8))
    }

    // MARK: - Suggestions

    /// Built from the corpus rather than hardcoded: the two most common theme categories, plus two
    /// evergreen entries. Each row runs as a query on tap.
    private static func deriveSuggestions(from corpus: SearchCorpus) -> [String] {
        let categoryCounts = corpus.themeDocs
            .compactMap { $0.categoryToken }
            .reduce(into: [String: Int]()) { $0[$1, default: 0] += 1 }
        let topCategories = categoryCounts
            .sorted { $0.value > $1.value }
            .prefix(2)
            .map { "\($0.key.capitalized) Themes" }

        return Array((topCategories + ["Dark Themes", "Handwritten Fonts"]).prefix(4))
    }
}
