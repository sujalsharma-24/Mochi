import FirebaseFirestore

/// Query shapes here must lead with isPublished/moderationStatus equality filters to match the
/// composite indexes in firestore/firestore.indexes.json — same constraint
/// android/.../data/ThemeRepository.kt documents, same query shapes mirrored 1:1.
final class ThemeRepository {
    private let firestore: Firestore

    init(firestore: Firestore) {
        self.firestore = firestore
    }

    private var themes: CollectionReference { firestore.collection("themes") }

    func getPublishedThemes(limit: Int = 20) async throws -> [KeyboardTheme] {
        let snapshot = try await themes
            .whereField("isPublished", isEqualTo: true)
            .whereField("moderationStatus", isEqualTo: "approved")
            .order(by: "createdAt", descending: true)
            .limit(to: limit)
            .getDocuments()
        return try snapshot.documents.map { try $0.data(as: ThemeDocument.self).toKeyboardTheme() }
    }

    func getTopRanked(limit: Int = 20) async throws -> [KeyboardTheme] {
        let snapshot = try await themes
            .whereField("isPublished", isEqualTo: true)
            .whereField("moderationStatus", isEqualTo: "approved")
            .order(by: "likeCount", descending: true)
            .limit(to: limit)
            .getDocuments()
        return try snapshot.documents.map { try $0.data(as: ThemeDocument.self).toKeyboardTheme() }
    }

    func getTheme(themeId: String) async throws -> ThemeDocument? {
        let snapshot = try await themes.document(themeId).getDocument()
        guard snapshot.exists else { return nil }
        return try snapshot.data(as: ThemeDocument.self)
    }

    /// Search's browsable pool. Firestore has no text-search operator and this app has no budget for
    /// a paid search service, so search fetches a bounded pool of published themes and filters/sorts
    /// it client-side — same shape Community's Popular Creators derivation uses.
    func searchableThemes(limit: Int = 200) async throws -> [KeyboardTheme] {
        let snapshot = try await themes
            .whereField("isPublished", isEqualTo: true)
            .whereField("moderationStatus", isEqualTo: "approved")
            .order(by: "likeCount", descending: true)
            .limit(to: limit)
            .getDocuments()
        return try snapshot.documents.map { try $0.data(as: ThemeDocument.self).toKeyboardTheme() }
    }

    /// Community's "Following" tab. Firestore's whereIn caps at 30 values, so a huge follow list
    /// only surfaces its first 30 creators' themes — acceptable for a feed, not a full archive.
    func getThemesByCreators(creatorUids: [String], limit: Int = 30) async throws -> [KeyboardTheme] {
        guard !creatorUids.isEmpty else { return [] }
        let snapshot = try await themes
            .whereField("isPublished", isEqualTo: true)
            .whereField("moderationStatus", isEqualTo: "approved")
            .whereField("creatorUid", in: Array(creatorUids.prefix(30)))
            .limit(to: limit)
            .getDocuments()
        return try snapshot.documents.map { try $0.data(as: ThemeDocument.self).toKeyboardTheme() }
    }

    /// Community's "My Likes" tab. Still filtered to isPublished/approved like every other feed
    /// query — firestore.rules' read rule only additionally allows a theme's *owner* to read their
    /// own unapproved theme, not an arbitrary liker, and Firestore rejects a whole `list` query
    /// outright if any potential result could fail the rule, so this can't relax the filter.
    func getThemesByIds(_ themeIds: [String]) async throws -> [KeyboardTheme] {
        guard !themeIds.isEmpty else { return [] }
        var results: [KeyboardTheme] = []
        for chunk in themeIds.chunked(into: 30) {
            let snapshot = try await themes
                .whereField("isPublished", isEqualTo: true)
                .whereField("moderationStatus", isEqualTo: "approved")
                .whereField(FieldPath.documentID(), in: chunk)
                .getDocuments()
            results.append(contentsOf: try snapshot.documents.map { try $0.data(as: ThemeDocument.self).toKeyboardTheme() })
        }
        return results
    }
}

extension Array {
    /// Firestore's `whereField(_:in:)` caps at 30 values per query — chunking a longer id list into
    /// batches this size is what lets getThemesByIds (and, later, similarly-shaped repository
    /// methods) accept an arbitrarily long list without the query itself failing outright.
    func chunked(into size: Int) -> [[Element]] {
        guard size > 0 else { return [self] }
        return stride(from: 0, to: count, by: size).map { Array(self[$0..<Swift.min($0 + size, count)]) }
    }
}
