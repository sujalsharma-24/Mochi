import Foundation

enum PublishUiState: Equatable {
    case idle
    case saving
    case success(published: Bool)
    case error(String)
}

/// Owns the Create screen's single source of truth (`draft`) and everything that reads or writes
/// it: loading the last-active draft on appear, debounced autosave on every edit, Reset All, and
/// the two action buttons.
///
/// **Why autosave rather than a dirty flag + confirmation dialog.** Every meaningful edit is
/// persisted to `CustomThemeStore` within `autosaveDebounce` of the user pausing, so there is
/// essentially never unsaved work for a Back tap to lose — which is the actual product goal point
/// 14 asks for ("don't silently lose the user's work"), achieved without a discard/keep prompt this
/// session has no simulator to verify the interaction of. `flushPendingSave()` makes that guarantee
/// synchronous at the one moment it has to be watertight: the instant before navigating away.
@MainActor
final class CreateThemeViewModel: ObservableObject {
    @Published var draft: ThemeDraft
    @Published private(set) var publishState: PublishUiState = .idle

    private let createRepository: CreateRepository?
    private let storageRepository: StorageRepository?
    private let authRepository: AuthRepository?

    private var autosaveTask: Task<Void, Never>?
    private let autosaveDebounce: Duration = .milliseconds(500)

    init(container: AppContainer?) {
        createRepository = container?.createRepository
        storageRepository = container?.storageRepository
        authRepository = container?.authRepository

        if let activeID = CustomThemeStore.activeDraftID, let resumed = CustomThemeStore.loadDraft(id: activeID) {
            draft = resumed
        } else {
            draft = ThemeDraft()
        }
    }

    // MARK: - Persistence

    /// Call after any field mutation. Coalesces bursts (a colour drag fires this dozens of times a
    /// second) into one write roughly `autosaveDebounce` after the user stops moving the knob —
    /// frequent enough that "leave and come back" always finds the latest state, infrequent enough
    /// that dragging a slider never contends with the encoder/disk on every frame.
    func scheduleAutosave() {
        autosaveTask?.cancel()
        let snapshot = draft
        autosaveTask = Task { [autosaveDebounce] in
            try? await Task.sleep(for: autosaveDebounce)
            guard !Task.isCancelled else { return }
            CustomThemeStore.saveDraft(snapshot)
        }
    }

    /// Saves immediately, bypassing the debounce. Called before navigating away and before either
    /// action button runs, so neither can race a still-pending autosave.
    func flushPendingSave() {
        autosaveTask?.cancel()
        autosaveTask = nil
        draft = CustomThemeStore.saveDraft(draft)
    }

    /// Replaces the draft with a fresh one carrying the same id, so Reset All clears every field —
    /// including ones a visual-only reset would miss — without abandoning the draft record itself or
    /// its place in `CustomThemeStore`'s resume history.
    func resetAll() {
        autosaveTask?.cancel()
        draft = CustomThemeStore.saveDraft(ThemeDraft(id: draft.id))
        publishState = .idle
    }

    // MARK: - Background photo

    func applyPickedPhoto(data: Data) {
        guard let relativePath = CustomThemeStore.storePhoto(data: data, draftID: draft.id) else {
            publishState = .error("Couldn't use that photo — try a different one.")
            return
        }
        draft.background = .photo(relativePath: relativePath)
        scheduleAutosave()
    }

    // MARK: - Validation

    var validation: ThemeValidator.Report { ThemeValidator.validate(draft.renderTheme) }

    // MARK: - Save / Publish

    func save(publish: Bool) {
        NSLog("DIAG save(publish: %@) called, name='%@'", publish ? "true" : "false", draft.name)
        flushPendingSave()

        guard !draft.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            publishState = .error("Give your theme a name first.")
            return
        }
        if publish {
            let report = validation
            guard report.isPublishable else {
                let detail = report.errors.first?.message ?? "This theme isn't legible enough to publish yet."
                publishState = .error(detail)
                return
            }
        }

        publishState = .saving
        draft = publish ? CustomThemeStore.publish(draft) : CustomThemeStore.saveDraft(draft)
        // Local persistence is the result the user sees — it is real and immediate regardless of
        // backend availability. The Firestore write below is best-effort on top of that, per
        // `CustomThemeStore`'s own doc comment on why local-first is correct here.
        publishState = .success(published: publish)

        fireRemoteWriteBestEffort(publish: publish)
    }

    /// Fires the existing Firestore path when a real backend is configured, and quietly does nothing
    /// otherwise. Its outcome never overwrites `publishState` — a user who just saw "Published!"
    /// should not have that flip to an error a second later because this device has no
    /// `GoogleService-Info.plist`, which is the overwhelmingly common case on this build.
    private func fireRemoteWriteBestEffort(publish: Bool) {
        guard let createRepository, let storageRepository, let authRepository,
              let user = authRepository.currentUser else { return }
        let draft = draft
        Task {
            do {
                var previewImageUrl = ""
                if case .photo(let relativePath) = draft.background {
                    let url = CustomThemeStore.mediaRootURL.appendingPathComponent(relativePath)
                    if let data = try? Data(contentsOf: url) {
                        previewImageUrl = (try? await storageRepository.uploadThemeImage(uid: user.uid, imageData: data)) ?? ""
                    }
                }
                let displayName = user.displayName.flatMap { $0.isEmpty ? nil : $0 } ?? "Mochi Creator"
                _ = try await createRepository.saveTheme(
                    creatorUid: user.uid,
                    creatorDisplayName: displayName,
                    creatorAvatarUrl: user.photoURL?.absoluteString ?? "",
                    name: draft.name,
                    description: "",
                    hashtags: draft.tags,
                    previewImageUrl: previewImageUrl,
                    isPremium: false,
                    publish: publish,
                    backgroundType: backgroundType(for: draft.background),
                    backgroundConfig: draft.backgroundConfig,
                    keysConfig: draft.keysConfig,
                    fontsConfig: draft.fontsConfig,
                    effectsConfig: draft.effectsConfig
                )
            } catch {
                // Best-effort: the local publish already succeeded and is what the rest of the app
                // sees. Nothing else to do with a remote failure until there's a retry queue worth
                // building, which needs a real backend to test against in the first place.
            }
        }
    }

    private func backgroundType(for choice: BackgroundChoice) -> String {
        switch choice {
        case .gradient: return "gradient"
        case .solid: return "solid"
        case .plate: return "gallery"
        case .photo: return "gallery"
        }
    }

    func dismissStatus() {
        publishState = .idle
    }
}
