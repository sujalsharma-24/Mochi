import FirebaseFirestore

/// Writes must match firestore/firestore.rules' themes/{themeId} `create` rule exactly:
/// creatorUid == auth.uid, moderationStatus starts "pending", every counter starts 0. "Save Draft"
/// vs "Publish Theme" is just isPublished false/true — both still start moderationStatus "pending",
/// since every read query in ThemeRepository filters on moderationStatus == "approved" regardless of
/// isPublished, so a freshly-published theme is invisible in feeds either way until moderation
/// approves it. Real moderation (nsfwjs flips pending -> approved/rejected) is a Cloud Function, not
/// built yet — published themes sit invisibly pending until then. Same contract
/// android/.../data/CreateRepository.kt uses.
final class CreateRepository {
    private let firestore: Firestore

    init(firestore: Firestore) {
        self.firestore = firestore
    }

    func saveTheme(
        creatorUid: String,
        creatorDisplayName: String,
        creatorAvatarUrl: String,
        name: String,
        description: String,
        hashtags: [String],
        previewImageUrl: String,
        isPremium: Bool,
        publish: Bool,
        backgroundType: String,
        backgroundConfig: BackgroundConfig,
        keysConfig: KeysConfig,
        fontsConfig: FontsConfig,
        effectsConfig: EffectsConfig
    ) async throws -> String {
        let encoder = Firestore.Encoder()
        let theme: [String: Any] = [
            "creatorUid": creatorUid,
            "creatorDisplayName": creatorDisplayName,
            "creatorAvatarUrl": creatorAvatarUrl,
            "name": name,
            "description": description,
            "hashtags": hashtags,
            "previewImageUrl": previewImageUrl,
            "isPremium": isPremium,
            "isPublished": publish,
            "moderationStatus": "pending",
            "likeCount": 0,
            "downloadCount": 0,
            "reportCount": 0,
            "backgroundType": backgroundType,
            "backgroundConfig": try encoder.encode(backgroundConfig),
            "keysConfig": try encoder.encode(keysConfig),
            "fontsConfig": try encoder.encode(fontsConfig),
            "effectsConfig": try encoder.encode(effectsConfig),
            "createdAt": FieldValue.serverTimestamp(),
            "updatedAt": FieldValue.serverTimestamp()
        ]
        let ref = try await firestore.collection("themes").addDocument(data: theme)
        return ref.documentID
    }
}
