import FirebaseFirestore

/// Writes must match firestore/firestore.rules' `users/{uid}` `create` rule exactly (uid ==
/// request.auth.uid, subscriptionStatus starts "free", every counter starts 0, isDeleted false),
/// same contract android/.../data/UserRepository.kt's createUserProfile encodes.
final class UserRepository {
    private let firestore: Firestore

    init(firestore: Firestore) {
        self.firestore = firestore
    }

    /// `users/{uid}` is readable by any signed-in user (firestore.rules), not just the profile's
    /// owner — this is what makes viewing another user's profile possible at all.
    func getUser(uid: String) async throws -> UserDocument? {
        let snapshot = try await firestore.collection("users").document(uid).getDocument()
        guard snapshot.exists else { return nil }
        return try snapshot.data(as: UserDocument.self)
    }

    func createUserProfile(uid: String) async throws {
        let profile: [String: Any] = [
            "uid": uid,
            "createdAt": FieldValue.serverTimestamp(),
            "updatedAt": FieldValue.serverTimestamp(),
            "subscriptionStatus": "free",
            "followerCount": 0,
            "followingCount": 0,
            "themeCount": 0,
            "likesGivenCount": 0,
            "likesReceivedCount": 0,
            "isDeleted": false
        ]
        try await firestore.collection("users").document(uid).setData(profile)
    }

    /// Called after every successful sign-in / on FCM token refresh — what
    /// functions/src/notifications.ts reads to know where to deliver a push.
    func updateFcmToken(uid: String, token: String) async throws {
        try await firestore.collection("users").document(uid).updateData(["fcmToken": token])
    }

    func setNotificationsEnabled(uid: String, enabled: Bool) async throws {
        try await firestore.collection("users").document(uid).updateData(["notificationsEnabled": enabled])
    }
}
