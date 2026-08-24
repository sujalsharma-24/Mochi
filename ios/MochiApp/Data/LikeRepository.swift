import FirebaseFirestore

/// `likes/{uid}_{themeId}` docs are client-writable (firestore.rules allows create/delete of your
/// own like), but the theme's `likeCount` field is not — only `onLikeWritten` (functions/src/likes.ts)
/// can move it. Liking here updates the `likes` collection for real; the theme's stored likeCount
/// only moves once that trigger runs server-side, so callers apply their own optimistic +1/-1 rather
/// than re-reading likeCount immediately after. Same contract android/.../data/LikeRepository.kt uses.
final class LikeRepository {
    private let firestore: Firestore

    init(firestore: Firestore) {
        self.firestore = firestore
    }

    private func likeDocId(uid: String, themeId: String) -> String { "\(uid)_\(themeId)" }

    func isLiked(uid: String, themeId: String) async throws -> Bool {
        try await firestore.collection("likes").document(likeDocId(uid: uid, themeId: themeId)).getDocument().exists
    }

    func like(uid: String, themeId: String) async throws {
        try await firestore.collection("likes").document(likeDocId(uid: uid, themeId: themeId))
            .setData(["uid": uid, "themeId": themeId])
    }

    func unlike(uid: String, themeId: String) async throws {
        try await firestore.collection("likes").document(likeDocId(uid: uid, themeId: themeId)).delete()
    }

    /// Theme ids the given user has liked — used to build the "My Likes" community feed tab.
    func likedThemeIds(uid: String) async throws -> [String] {
        let snapshot = try await firestore.collection("likes").whereField("uid", isEqualTo: uid).getDocuments()
        return snapshot.documents.compactMap { $0.data()["themeId"] as? String }
    }
}
