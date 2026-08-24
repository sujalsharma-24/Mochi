import FirebaseFirestore

/// `follows/{followerId}_{followeeId}` docs are client-writable, but `users/{uid}`'s
/// followerCount/followingCount fields are not — those are maintained by `onFollowWritten`
/// (functions/src/follows.ts). Same optimistic-UI caveat as LikeRepository, same contract
/// android/.../data/FollowRepository.kt uses.
final class FollowRepository {
    private let firestore: Firestore

    init(firestore: Firestore) {
        self.firestore = firestore
    }

    private func followDocId(followerId: String, followeeId: String) -> String { "\(followerId)_\(followeeId)" }

    func isFollowing(followerId: String, followeeId: String) async throws -> Bool {
        try await firestore.collection("follows").document(followDocId(followerId: followerId, followeeId: followeeId)).getDocument().exists
    }

    func follow(followerId: String, followeeId: String) async throws {
        try await firestore.collection("follows").document(followDocId(followerId: followerId, followeeId: followeeId))
            .setData(["followerId": followerId, "followeeId": followeeId])
    }

    func unfollow(followerId: String, followeeId: String) async throws {
        try await firestore.collection("follows").document(followDocId(followerId: followerId, followeeId: followeeId)).delete()
    }

    /// Creator uids the given user follows — used to build the "Following" community feed tab.
    func followedUids(followerId: String) async throws -> [String] {
        let snapshot = try await firestore.collection("follows").whereField("followerId", isEqualTo: followerId).getDocuments()
        return snapshot.documents.compactMap { $0.data()["followeeId"] as? String }
    }
}
