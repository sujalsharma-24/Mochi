import Foundation

enum PublishUiState: Equatable {
    case idle
    case saving
    case success(published: Bool)
    case error(String)
}

private let keyShapeNames = ["square", "rounded", "circle", "hexagon"]
private let fontStyleIds = ["default", "rounded", "cute", "classic", "handwritten"]

/// Swift mirror of android/.../features/create/CreateThemeViewModel.kt — publishes/saves-drafts
/// CreateThemeView's local editor state via CreateRepository, matching the config schema
/// `ThemeDocument` mirrors. The screen's preset background tiles are bundled assets, not uploads —
/// there's nothing in Storage to point at, so they're encoded as `preset:{index}` in
/// backgroundConfig.galleryImageUrl, same bundled-asset convention `ThemeDocument.toKeyboardTheme()`
/// uses for `"firestore:$id"`. A picked gallery photo uses the real StorageRepository upload path
/// instead. description/isPremium have no UI control on this screen (neither did Android's) so
/// they're sent as blank/false.
@MainActor
final class CreateThemeViewModel: ObservableObject {
    @Published private(set) var publishState: PublishUiState = .idle

    private let createRepository: CreateRepository?
    private let storageRepository: StorageRepository?
    private let authRepository: AuthRepository?

    init(container: AppContainer?) {
        createRepository = container?.createRepository
        storageRepository = container?.storageRepository
        authRepository = container?.authRepository
    }

    func save(
        name: String,
        tags: [String],
        presetBackgroundIndex: Int?,
        galleryImageData: Data?,
        keyShapeIndex: Int,
        fontStyleIndex: Int,
        publish: Bool
    ) {
        guard let createRepository, let storageRepository, let authRepository,
              let user = authRepository.currentUser else {
            publishState = .error("Sign in to save a theme.")
            return
        }
        guard !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            publishState = .error("Give your theme a name first.")
            return
        }
        publishState = .saving
        Task {
            do {
                var galleryUrl: String?
                if let galleryImageData {
                    galleryUrl = try await storageRepository.uploadThemeImage(uid: user.uid, imageData: galleryImageData)
                }
                let backgroundConfig = BackgroundConfig(
                    galleryImageUrl: galleryUrl ?? "preset:\(presetBackgroundIndex ?? 0)"
                )
                let displayName = user.displayName.flatMap { $0.isEmpty ? nil : $0 } ?? "Mochi Creator"
                _ = try await createRepository.saveTheme(
                    creatorUid: user.uid,
                    creatorDisplayName: displayName,
                    creatorAvatarUrl: user.photoURL?.absoluteString ?? "",
                    name: name,
                    description: "",
                    hashtags: tags,
                    previewImageUrl: galleryUrl ?? "",
                    isPremium: false,
                    publish: publish,
                    backgroundType: "gallery",
                    backgroundConfig: backgroundConfig,
                    keysConfig: KeysConfig(shape: safeElement(keyShapeNames, keyShapeIndex) ?? "rounded"),
                    fontsConfig: FontsConfig(fontId: safeElement(fontStyleIds, fontStyleIndex) ?? "default"),
                    effectsConfig: EffectsConfig()
                )
                publishState = .success(published: publish)
            } catch {
                publishState = .error(error.localizedDescription)
            }
        }
    }

    func dismissStatus() {
        publishState = .idle
    }
}

private func safeElement(_ array: [String], _ index: Int) -> String? {
    array.indices.contains(index) ? array[index] : nil
}
