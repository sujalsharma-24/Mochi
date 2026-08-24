import FirebaseStorage
import Foundation

/// Upload paths/limits must match storage.rules exactly: `avatars/{uid}/{fileName}` and
/// `themes/{uid}/{fileName}`, both capped in the rules themselves (5MB avatars, 10MB theme images,
/// images only) — those limits aren't re-validated here, an oversized/wrong-type upload is rejected
/// server-side and this call throws. contentType is forced to "image/jpeg" rather than left to
/// inference, same contract android/.../data/StorageRepository.kt uses (a system photo picker's
/// data doesn't always carry a type Storage's rules recognize as `image/.*`).
final class StorageRepository {
    private let storage: Storage

    init(storage: Storage) {
        self.storage = storage
    }

    private func upload(_ imageData: Data, to path: String) async throws -> String {
        let ref = storage.reference().child(path)
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        _ = try await ref.putDataAsync(imageData, metadata: metadata)
        return try await ref.downloadURL().absoluteString
    }

    func uploadThemeImage(uid: String, imageData: Data) async throws -> String {
        try await upload(imageData, to: "themes/\(uid)/\(UUID().uuidString).jpg")
    }

    func uploadAvatar(uid: String, imageData: Data) async throws -> String {
        try await upload(imageData, to: "avatars/\(uid)/\(UUID().uuidString).jpg")
    }
}
