import Foundation

/// The four things Search can look for. `nil` (the "All" pill) means "any of these".
enum SearchContentType: String, CaseIterable, Identifiable, Hashable {
    case theme, font, creator
    var id: String { rawValue }
}

// MARK: - Result

/// One row in the results grid. Built by `SearchEngine` from a `SearchDocument`; carries the payload
/// each kind needs to navigate on tap (a full `KeyboardTheme` for Theme Detail, a font id for the
/// Fonts tab, a creator name for the profile route).
struct SearchResult: Identifiable, Hashable {
    enum Kind: Hashable { case theme, font, creator }

    let id: String
    let kind: Kind
    let name: String
    let label: String
    let subtitle: String
    let likeCount: Int
    let downloadCount: Int
    let isPremium: Bool
    let assetName: String
    /// Vertical crop anchor for a theme's background plate (`ThemePlateThumbnail`). 0.5 otherwise.
    let plateAnchor: Double
    /// The catalogue order this result sits at in its source list — the "Newest" sort key, since
    /// there are no real dates (newest = added last), mirroring `ThemesView`/`FontsView`.
    let catalogueIndex: Int

    var theme: KeyboardTheme? = nil
    var fontID: String? = nil
    var creatorName: String? = nil
    var themeCount: Int = 0

    init(theme: KeyboardTheme, plateAnchor: Double, catalogueIndex: Int) {
        self.id = "theme:\(theme.id)"
        self.kind = .theme
        self.name = theme.name
        self.label = "Theme"
        self.subtitle = ""
        self.likeCount = theme.likeCount
        self.downloadCount = theme.downloadCount
        self.isPremium = theme.isPremium
        self.assetName = theme.imageAssetName
        self.plateAnchor = plateAnchor
        self.catalogueIndex = catalogueIndex
        self.theme = theme
    }

    init(fontID: String, name: String, subtitle: String, assetName: String, isPremium: Bool, catalogueIndex: Int) {
        self.id = "font:\(fontID)"
        self.kind = .font
        self.name = name
        self.label = "Font"
        self.subtitle = subtitle
        self.likeCount = 0
        self.downloadCount = 0
        self.isPremium = isPremium
        self.assetName = assetName
        self.plateAnchor = 0.5
        self.catalogueIndex = catalogueIndex
        self.fontID = fontID
    }

    init(creatorName: String, themeCount: Int, catalogueIndex: Int) {
        self.id = "creator:\(creatorName)"
        self.kind = .creator
        self.name = creatorName
        self.label = "Creator"
        self.subtitle = themeCount > 0 ? "\(themeCount) theme\(themeCount == 1 ? "" : "s")" : "Creator"
        self.likeCount = 0
        self.downloadCount = 0
        self.isPremium = false
        self.assetName = ""
        self.plateAnchor = 0.5
        self.catalogueIndex = catalogueIndex
        self.creatorName = creatorName
        self.themeCount = themeCount
    }
}

// MARK: - Document

/// A catalogue item flattened into pre-tokenised, pre-lowercased fields plus the set of concepts it
/// evokes. Built once by `SearchCorpus`; the scorer only ever reads these, never the source model.
struct SearchDocument {
    let type: SearchContentType
    let displayName: String
    let nameTokens: [String]
    let tagTokens: [String]
    /// Category rawValue, lowercased — `nil` for `.other` (not a useful search term) and for creators.
    let categoryToken: String?
    /// Creator name tokens for a theme; empty otherwise.
    let extraTokens: [String]
    let concepts: Set<String>
    /// Like count (themes) / inverted popularity rank (fonts) / summed like count (creators). Used
    /// for the empty-query browse order and as a tie-break.
    let popularity: Int
    let isPremium: Bool
    let catalogueIndex: Int

    // Payload for `SearchResult`.
    let theme: KeyboardTheme?
    let fontID: String?
    let creatorThemeCount: Int
    let plateAnchor: Double
}

// MARK: - Corpus

/// Every searchable item in the app, built from the **real** catalogues — the built-in theme system
/// (`ThemeCatalog.all` + any published custom themes), the font collection (`MockData.fontCollection`),
/// and the set of theme authors. Cheap to build (~40 items), so `SearchViewModel` builds a fresh one
/// per screen open and newly published custom themes show up without a cache to invalidate.
struct SearchCorpus {
    let themeDocs: [SearchDocument]
    let fontDocs: [SearchDocument]
    let creatorDocs: [SearchDocument]

    func documents(for type: SearchContentType?) -> [SearchDocument] {
        switch type {
        case .theme: return themeDocs
        case .font: return fontDocs
        case .creator: return creatorDocs
        case nil: return themeDocs + fontDocs + creatorDocs
        }
    }

    static func build() -> SearchCorpus {
        SearchCorpus(
            themeDocs: buildThemeDocs(),
            fontDocs: buildFontDocs(),
            creatorDocs: buildCreatorDocs()
        )
    }

    // MARK: Builders

    private static func buildThemeDocs() -> [SearchDocument] {
        // Published customs first (so a theme the user made and published is findable), then the
        // built-in catalogue — the same base list `ThemesView` browses.
        let raw = CustomThemeStore.publishedCatalogueThemes() + ThemeCatalog.all
        var seen = Set<String>()
        let themes = raw.filter { seen.insert($0.id).inserted }

        return themes.enumerated().map { index, theme in
            let nameTokens = SearchText.tokenize(theme.name)
            // The theme's own subject/mood/colour vocabulary (`ThemeSemantics`) counts as tags, so
            // "cherry blossom", "pink" or "dinosaur" find the themes that actually look like that
            // even when none of those words appear in the title. Without this a search could only
            // ever match a name, which is what made the results feel thin.
            let semantics = ThemeSemantics.entry(for: theme.id)
            let tagTokens = (theme.hashtags + (semantics?.keywords ?? [])).flatMap(SearchText.tokenize)
            let categoryToken = theme.category == .other ? nil : theme.category.rawValue.lowercased()
            let creatorTokens = SearchText.tokenize(theme.creatorName)
            let blurbTokens = SearchText.tokenize(semantics?.blurb ?? "")
            let concepts = SearchText.concepts(from: nameTokens + tagTokens + creatorTokens + blurbTokens + [categoryToken].compactMap { $0 })

            return SearchDocument(
                type: .theme,
                displayName: theme.name,
                nameTokens: nameTokens,
                tagTokens: tagTokens,
                categoryToken: categoryToken,
                extraTokens: creatorTokens,
                concepts: concepts,
                popularity: theme.likeCount,
                isPremium: theme.isPremium,
                catalogueIndex: index,
                theme: theme,
                fontID: nil,
                creatorThemeCount: 0,
                plateAnchor: plateAnchor(for: theme)
            )
        }
    }

    private static func buildFontDocs() -> [SearchDocument] {
        MockData.fontCollection.enumerated().map { index, font in
            let nameTokens = SearchText.tokenize(font.name)
            let tagTokens = SearchText.tokenize(font.styleDescription)
            let categoryToken = font.category == .other ? nil : font.category.rawValue.lowercased()
            let concepts = SearchText.concepts(from: nameTokens + tagTokens + [categoryToken].compactMap { $0 })

            return SearchDocument(
                type: .font,
                displayName: font.name,
                nameTokens: nameTokens,
                tagTokens: tagTokens,
                categoryToken: categoryToken,
                extraTokens: [],
                concepts: concepts,
                // No like data on fonts — invert the hand-assigned popularity rank so the browse
                // order and "Most liked" sort still mean something (rank 1 → highest).
                popularity: max(0, 10_000 - font.popularityRank * 1_000),
                isPremium: font.isPremium,
                catalogueIndex: index,
                theme: nil,
                fontID: font.id,
                creatorThemeCount: 0,
                plateAnchor: 0.5
            )
        }
    }

    /// Creators, per the product decision, are **theme authors**: the distinct `creatorName` values
    /// across every theme pool the app ships. Each carries the tags/categories/names of the themes
    /// attributed to them, so "pink" or "cozy" can surface a creator, not just their literal name.
    ///
    /// Known thin: there is no creator↔theme join in the data (`KeyboardTheme.creatorUid` is empty
    /// everywhere) and these authors have no avatar assets, so the row renders a monogram. Tapping
    /// one opens `.profile(uid:)`, which is still MockData-backed — same as Community/Leaderboard.
    private static func buildCreatorDocs() -> [SearchDocument] {
        // One pool now: every screen's theme rows are slices of `ThemeCatalog.all`, so the old
        // union of MockData arrays would only have counted the same themes several times over.
        let pool = ThemeCatalog.all + CustomThemeStore.publishedCatalogueThemes()

        var byCreator: [String: [KeyboardTheme]] = [:]
        var order: [String] = []
        for theme in pool {
            let name = theme.creatorName
                .replacingOccurrences(of: #"^\s*by\s+"#, with: "", options: [.regularExpression, .caseInsensitive])
                .trimmingCharacters(in: .whitespacesAndNewlines)
            guard !name.isEmpty else { continue }
            if byCreator[name] == nil { order.append(name) }
            byCreator[name, default: []].append(theme)
        }

        return order.enumerated().map { index, name in
            let themes = byCreator[name] ?? []
            let nameTokens = SearchText.tokenize(name)
            let themeTokens = themes.flatMap { SearchText.tokenize($0.name) }
                + themes.flatMap { $0.hashtags.flatMap(SearchText.tokenize) }
            let categoryTokens = Set(themes.compactMap { $0.category == .other ? nil : $0.category.rawValue.lowercased() })
            let concepts = SearchText.concepts(from: nameTokens + themeTokens + Array(categoryTokens))
            let uniqueThemeCount = Set(themes.map { $0.id }).count

            return SearchDocument(
                type: .creator,
                displayName: name,
                nameTokens: nameTokens,
                tagTokens: Array(Set(themeTokens)),
                categoryToken: nil,
                extraTokens: [],
                concepts: concepts,
                popularity: themes.map { $0.likeCount }.reduce(0, +),
                isPremium: false,
                catalogueIndex: index,
                theme: nil,
                fontID: nil,
                creatorThemeCount: uniqueThemeCount,
                plateAnchor: 0.5
            )
        }
    }

    /// The built-in theme's own authored crop anchor, so a small tile keeps the same band of the
    /// plate the keyboard shows. Centre for a custom/Firestore theme with no bundled plate.
    private static func plateAnchor(for theme: KeyboardTheme) -> Double {
        BuiltInThemes.all.first { $0.id == theme.id }?
            .surface.backgroundImage?.verticalAnchor ?? 0.5
    }
}

// MARK: - Engine

enum SearchEngine {

    /// Field weights for a direct token hit. A name hit outranks a tag hit outranks a category /
    /// creator hit outranks a description hit; prefix hits score a little under exact.
    private enum Weight {
        static let nameExact = 10.0
        static let namePrefix = 6.0
        static let tagExact = 7.0
        static let tagPrefix = 4.0
        static let creatorExact = 6.0
        static let category = 5.0
        static let fuzzy = 2.5
        /// A query token whose *concept* (not the word itself) lands on the document.
        static let concept = 5.0
    }

    /// Rank the corpus against `query`, limited to `type` (or all types when `nil`). Type words in
    /// the query ("cute font") narrow the type themselves when the pill is on "All".
    static func rank(query: String, type: SearchContentType?, corpus: SearchCorpus) -> [SearchResult] {
        let parsed = parse(query)
        let effectiveType = type ?? parsed.typeHint
        let documents = corpus.documents(for: effectiveType)

        // Empty / meaningless query → browse the type, most popular first.
        guard !parsed.tokens.isEmpty else {
            return documents
                .sorted { lhs, rhs in
                    if lhs.popularity != rhs.popularity { return lhs.popularity > rhs.popularity }
                    return lhs.displayName.localizedCaseInsensitiveCompare(rhs.displayName) == .orderedAscending
                }
                .map(makeResult)
        }

        let scored: [(doc: SearchDocument, score: Double)] = documents.compactMap { doc in
            let s = score(doc, tokens: parsed.tokens)
            return s > 0 ? (doc, s) : nil
        }
        guard let top = scored.map(\.score).max() else { return [] }

        // Relative cutoff — an absolute one returns nothing the moment scores run low. Relax it if
        // that still leaves almost nothing (a deliberately vague query like "shiny").
        let primaryCutoff = Swift.max(2.5, 0.20 * top)
        var kept = scored.filter { $0.score >= primaryCutoff }
        if kept.count < 3 {
            kept = scored.filter { $0.score >= 1.5 }
        }

        return kept
            .sorted { lhs, rhs in
                if lhs.score != rhs.score { return lhs.score > rhs.score }
                if lhs.doc.popularity != rhs.doc.popularity { return lhs.doc.popularity > rhs.doc.popularity }
                return lhs.doc.displayName.localizedCaseInsensitiveCompare(rhs.doc.displayName) == .orderedAscending
            }
            .map { makeResult($0.doc) }
    }

    // MARK: Query parsing

    struct ParsedQuery {
        var tokens: [String]
        var typeHint: SearchContentType?
    }

    static func parse(_ query: String) -> ParsedQuery {
        var tokens: [String] = []
        var typeHint: SearchContentType?
        for token in SearchText.tokenize(query) {
            if let hinted = SearchConcepts.typeWords[token] {
                typeHint = hinted
                continue
            }
            if SearchConcepts.stopWords.contains(token) { continue }
            tokens.append(token)
        }
        return ParsedQuery(tokens: tokens, typeHint: typeHint)
    }

    // MARK: Scoring

    private static func score(_ doc: SearchDocument, tokens: [String]) -> Double {
        var raw = 0.0
        var directMatches = 0
        var softCredit = 0.0

        for token in tokens {
            var best = 0.0

            if doc.nameTokens.contains(token) {
                best = Swift.max(best, Weight.nameExact)
            } else if token.count >= 3, doc.nameTokens.contains(where: { $0.hasPrefix(token) }) {
                best = Swift.max(best, Weight.namePrefix)
            }

            if doc.tagTokens.contains(token) {
                best = Swift.max(best, Weight.tagExact)
            } else if token.count >= 3, doc.tagTokens.contains(where: { $0.hasPrefix(token) }) {
                best = Swift.max(best, Weight.tagPrefix)
            }

            if doc.extraTokens.contains(token) {
                best = Swift.max(best, Weight.creatorExact)
            }
            if doc.categoryToken == token {
                best = Swift.max(best, Weight.category)
            }

            if best == 0, SearchText.fuzzyMatches(token, in: doc.nameTokens) || SearchText.fuzzyMatches(token, in: doc.tagTokens) {
                best = Weight.fuzzy
            }

            if best > 0 {
                directMatches += 1
                raw += best
                continue
            }

            // No literal hit — does this token's concept land on the document?
            var conceptStrength = 0.0
            for (concept, weight) in SearchConcepts.weightedConcepts(for: token) where doc.concepts.contains(concept) {
                conceptStrength = Swift.max(conceptStrength, weight)
            }
            if conceptStrength > 0 {
                softCredit += conceptStrength
                raw += Weight.concept * conceptStrength
            }
        }

        guard raw > 0 else { return 0 }

        // Coverage: reward matching more of what the user typed. Concept-only hits count half.
        let covered = Double(directMatches) + 0.5 * softCredit
        let coverage = Swift.min(covered / Double(tokens.count), 1.0)
        return raw * (0.5 + 0.5 * coverage)
    }

    // MARK: Result mapping

    private static func makeResult(_ doc: SearchDocument) -> SearchResult {
        switch doc.type {
        case .theme:
            return SearchResult(theme: doc.theme!, plateAnchor: doc.plateAnchor, catalogueIndex: doc.catalogueIndex)
        case .font:
            let font = MockData.fontCollection.first { $0.id == doc.fontID }
            return SearchResult(
                fontID: doc.fontID!,
                name: doc.displayName,
                subtitle: font?.styleDescription ?? "",
                assetName: font?.artAssetName ?? "",
                isPremium: doc.isPremium,
                catalogueIndex: doc.catalogueIndex
            )
        case .creator:
            return SearchResult(creatorName: doc.displayName, themeCount: doc.creatorThemeCount, catalogueIndex: doc.catalogueIndex)
        }
    }
}

// MARK: - Text utilities

enum SearchText {
    /// Lowercase, split on anything that isn't a letter or digit, drop empties.
    static func tokenize(_ string: String) -> [String] {
        string.lowercased()
            .split { !$0.isLetter && !$0.isNumber }
            .map(String.init)
            .filter { !$0.isEmpty }
    }

    /// The concepts a bag of words evokes directly (no adjacency) — used to index a document.
    static func concepts(from tokens: [String]) -> Set<String> {
        var out = Set<String>()
        for token in tokens {
            for concept in SearchConcepts.directConcepts(for: token) {
                out.insert(concept)
            }
        }
        return out
    }

    /// Bounded edit-distance match: ≤1 edit for 4–6 char tokens, ≤2 for ≥7. Only used as a
    /// last resort (a query token that matched nothing else), and only against name/tag tokens.
    static func fuzzyMatches(_ token: String, in candidates: [String]) -> Bool {
        guard token.count >= 4 else { return false }
        let budget = token.count >= 7 ? 2 : 1
        for candidate in candidates where abs(candidate.count - token.count) <= budget {
            if levenshtein(token, candidate, budget: budget) <= budget { return true }
        }
        return false
    }

    /// Standard DP edit distance with an early-out once the best possible score on a row exceeds
    /// `budget`. Inputs here are short (single words), so this stays cheap.
    static func levenshtein(_ a: String, _ b: String, budget: Int) -> Int {
        let a = Array(a), b = Array(b)
        if a.isEmpty { return b.count }
        if b.isEmpty { return a.count }
        var previous = Array(0...b.count)
        var current = [Int](repeating: 0, count: b.count + 1)
        for i in 1...a.count {
            current[0] = i
            var rowBest = current[0]
            for j in 1...b.count {
                let cost = a[i - 1] == b[j - 1] ? 0 : 1
                current[j] = Swift.min(
                    previous[j] + 1,
                    current[j - 1] + 1,
                    previous[j - 1] + cost
                )
                rowBest = Swift.min(rowBest, current[j])
            }
            if rowBest > budget { return budget + 1 }
            swap(&previous, &current)
        }
        return previous[b.count]
    }
}
