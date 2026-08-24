import Foundation

/// Mirrors the real `users/{uid}` schema enforced by firestore/firestore.rules — same document
/// shape android/.../data/model/UserDocument.kt already reads/writes, kept in sync by hand since
/// there's no shared schema codegen between the two clients. `uid` is a plain field, not
/// `@DocumentID`: `UserRepository.createUserProfile` writes a real "uid" field into the document
/// body itself, and the Android client hit a real crash from that exact collision with its
/// equivalent of `@DocumentID` — kept as a plain field here on the same precedent rather than
/// re-discovering the same bug on this platform.
struct UserDocument: Codable, Equatable {
    var uid: String = ""
    var displayName: String = ""
    var username: String = ""
    var avatarUrl: String = ""
    var bio: String = ""
    var followerCount: Int = 0
    var followingCount: Int = 0
    var themeCount: Int = 0
    var likesGivenCount: Int = 0
    var likesReceivedCount: Int = 0
    var isDeleted: Bool = false
    var fcmToken: String = ""
    var notificationsEnabled: Bool = true
}
