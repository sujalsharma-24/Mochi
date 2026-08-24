import FirebaseFirestore

/// The Create screen's four tabs write one of these on Android (not yet built on iOS); the eventual
/// keyboard extension (out of this whole effort's scope) reads them back. Field shape mirrors
/// android/.../data/model/ThemeDocument.kt exactly, kept in sync by hand.
struct BackgroundConfig: Codable, Equatable {
    var solidColor: String = "#FFFFFF"
    var gradientStartColor: String = "#FFFFFF"
    var gradientEndColor: String = "#FFFFFF"
    var gradientDirection: String = "diagonal"
    var galleryImageUrl: String = ""
}

struct KeysConfig: Codable, Equatable {
    var shape: String = "rounded"
    var fillColor: String = "#FFFFFF"
    var borderWidth: Int = 0
    var borderColor: String = "#000000"
    var hasShadow: Bool = false
}

struct FontsConfig: Codable, Equatable {
    var fontId: String = "bubble-cute"
    var textColor: String = "#000000"
    var sizePercent: Int = 100
    var isBold: Bool = false
}

struct EffectsConfig: Codable, Equatable {
    var keyPressEffect: String = "none"
    var backgroundEffect: String = "none"
    var trailEffect: String = "none"
}

/// Mirrors the real `themes/{themeId}` schema enforced by firestore/firestore.rules — same shape
/// android/.../data/model/ThemeDocument.kt reads/writes. `id` is `@DocumentID` here (unlike
/// UserDocument.uid): the document body never stores its own id as a field, so there's no
/// name-collision risk the way UserDocument's `uid` field has.
struct ThemeDocument: Codable, Equatable {
    @DocumentID var id: String?
    var creatorUid: String = ""
    var creatorDisplayName: String = ""
    var creatorAvatarUrl: String = ""
    var name: String = ""
    var description: String = ""
    var hashtags: [String] = []
    var previewImageUrl: String = ""
    var isPremium: Bool = false
    var isPublished: Bool = false
    var moderationStatus: String = "pending"
    var likeCount: Int = 0
    var downloadCount: Int = 0
    var reportCount: Int = 0
    var backgroundType: String = "solid"
    var backgroundConfig: BackgroundConfig = BackgroundConfig()
    var keysConfig: KeysConfig = KeysConfig()
    var fontsConfig: FontsConfig = FontsConfig()
    var effectsConfig: EffectsConfig = EffectsConfig()
}

extension ThemeDocument {
    /// `imageAssetName` deliberately doesn't match any key in ThemeArt.swift's bundled-art set —
    /// real theme art (`previewImageUrl`) isn't wired to a remote-image loader yet (no such
    /// dependency exists in this project on either platform), so it falls back to the generated
    /// placeholder rather than rendering nothing. Matches android/.../ThemeDocument.kt's
    /// `toKeyboardTheme()` exactly, including the `"firestore:$id"` convention.
    func toKeyboardTheme() -> KeyboardTheme {
        KeyboardTheme(
            id: id ?? "",
            name: name,
            creatorName: creatorDisplayName,
            imageAssetName: "firestore:\(id ?? "")",
            likeCount: likeCount,
            isPremium: isPremium,
            hashtags: hashtags,
            description: description,
            creatorUid: creatorUid,
            downloadCount: downloadCount
        )
    }
}
