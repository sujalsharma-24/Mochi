import Foundation
import os

/// Local-first persistence for the Create screen's drafts and published themes.
///
/// Mirrors `ThemeStore`'s own shape deliberately — files under a shared root, atomic writes, never
/// throws to a caller — because this is solving the same problem for a different document: durable
/// state a UI can always read back, with no dependency on a backend that may not exist yet.
///
/// **Why local-first at all.** `AppContainer.shared` is `nil` on this build (no
/// `GoogleService-Info.plist`), so `CreateRepository`'s Firestore write is unreachable, and even a
/// successful one is invisible everywhere — every feed query filters `moderationStatus == "approved"`
/// and no moderation function exists yet to grant that. A "Publish" button whose only effect is a
/// write nobody can see is not a real feature. This store is what makes "Save Draft" and "Publish"
/// actually do something today: drafts round-trip, and a published theme becomes real inside this
/// app's own theme system immediately (`RenderableTheme`, `ThemesViewModel`) — while the Firestore
/// write still fires best-effort underneath, so nothing here needs to change again once the backend
/// lands.
enum CustomThemeStore {
    private static let logger = Logger(subsystem: "com.mochi.app", category: "CustomThemeStore")

    /// Prefers the App Group container — the same root `ThemeStore` writes the active theme into —
    /// so a user photo background is already sitting where the keyboard extension will eventually be
    /// able to read it from once the entitlement is provisioned. Falls back to this app's own
    /// Application Support directory, which exists unconditionally and needs no entitlement at all,
    /// so drafts work correctly today regardless of App Group status.
    static var mediaRootURL: URL {
        if let group = ThemeStore.containerURL { return group }
        let support = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
            ?? FileManager.default.temporaryDirectory
        return support.appendingPathComponent("MochiCustomThemes", isDirectory: true)
    }

    private static var rootURL: URL { mediaRootURL.appendingPathComponent("custom-themes", isDirectory: true) }
    private static var indexURL: URL { rootURL.appendingPathComponent("index.json") }
    private static func draftDirectory(_ id: String) -> URL { rootURL.appendingPathComponent(id, isDirectory: true) }
    private static func draftURL(_ id: String) -> URL { draftDirectory(id).appendingPathComponent("draft.json") }

    private static let activeDraftIDKey = "mochi.create.activeDraftID"

    // MARK: - Index

    struct Summary: Codable, Identifiable, Equatable {
        var id: String
        var name: String
        var updatedAt: Date
        var isPublished: Bool
    }

    /// Every known draft, most-recently-updated first. Never throws — a missing or corrupt index is
    /// treated as "no drafts yet" rather than an error the editor has to surface.
    static func loadIndex() -> [Summary] {
        guard let data = try? Data(contentsOf: indexURL) else { return [] }
        let summaries = (try? JSONDecoder.mochi.decode([Summary].self, from: data)) ?? []
        return summaries.sorted { $0.updatedAt > $1.updatedAt }
    }

    private static func writeIndex(_ summaries: [Summary]) {
        do {
            try ensureDirectoryExists(rootURL)
            let data = try JSONEncoder.mochi.encode(summaries)
            try data.write(to: indexURL, options: .atomic)
        } catch {
            logger.error("Failed to write custom-theme index: \(error.localizedDescription, privacy: .public)")
        }
    }

    private static func upsertIndex(for draft: ThemeDraft) {
        var summaries = loadIndex()
        let summary = Summary(id: draft.id, name: draft.name, updatedAt: draft.updatedAt, isPublished: draft.isPublished)
        if let index = summaries.firstIndex(where: { $0.id == draft.id }) {
            summaries[index] = summary
        } else {
            summaries.append(summary)
        }
        writeIndex(summaries)
    }

    // MARK: - Drafts

    static func loadDraft(id: String) -> ThemeDraft? {
        guard let data = try? Data(contentsOf: draftURL(id)) else { return nil }
        return try? JSONDecoder.mochi.decode(ThemeDraft.self, from: data)
    }

    /// Persists `draft` and records it as the one the editor should resume into next time it opens.
    /// Called on every meaningful edit (debounced by the caller), not just on an explicit save
    /// button, which is what makes "leave the screen and come back" restore correctly without the
    /// app needing a dedicated "open this draft" navigation entry point.
    @discardableResult
    static func saveDraft(_ draft: ThemeDraft) -> ThemeDraft {
        var draft = draft
        draft.updatedAt = Date()
        do {
            try ensureDirectoryExists(draftDirectory(draft.id))
            let data = try JSONEncoder.mochi.encode(draft)
            try data.write(to: draftURL(draft.id), options: .atomic)
            upsertIndex(for: draft)
            activeDraftID = draft.id
        } catch {
            logger.error("Failed to save draft \(draft.id, privacy: .public): \(error.localizedDescription, privacy: .public)")
        }
        return draft
    }

    static func deleteDraft(id: String) {
        try? FileManager.default.removeItem(at: draftDirectory(id))
        writeIndex(loadIndex().filter { $0.id != id })
        if activeDraftID == id { activeDraftID = nil }
    }

    /// Marks a draft published and saves it. Publishing and saving a draft are the same file write —
    /// "published" is just `isPublished == true` plus showing up in `publishedCatalogueThemes()` —
    /// so there is exactly one persistence path for this whole screen to reason about, matching
    /// point 13's requirement that Publish use the *exact* current configuration, not a second one.
    @discardableResult
    static func publish(_ draft: ThemeDraft) -> ThemeDraft {
        var draft = draft
        draft.isPublished = true
        return saveDraft(draft)
    }

    /// The last draft edited in this session or a previous one — what the editor loads on appear
    /// when it isn't opening a specific id. Plain `UserDefaults`, not the App Group: this is a UI
    /// resume convenience local to this device's app, not theme data the keyboard extension needs.
    static var activeDraftID: String? {
        get { UserDefaults.standard.string(forKey: activeDraftIDKey) }
        set {
            if let newValue {
                UserDefaults.standard.set(newValue, forKey: activeDraftIDKey)
            } else {
                UserDefaults.standard.removeObject(forKey: activeDraftIDKey)
            }
        }
    }

    // MARK: - Theme-system integration

    /// The render document for a custom theme id, or `nil` if no such draft exists. Called by
    /// `RenderableTheme.resolve` before it falls back to mood-matching a built-in theme, so applying
    /// a published custom theme renders the exact thing the user built rather than a stand-in.
    static func renderTheme(forID id: String) -> MochiKeyboardTheme? {
        loadDraft(id: id)?.renderTheme
    }

    /// Published customs as marketplace catalogue entries, newest first — what `ThemesViewModel`
    /// prepends onto whatever it would otherwise show. `imageAssetName` is deliberately a sentinel
    /// (`"custom:<id>"`, mirroring `ThemeDocument.toKeyboardTheme()`'s own `"firestore:$id"`
    /// convention) rather than a bundled asset name: `KeyboardThemeArt` already has a real fallback
    /// for exactly this case — the generated `KeyboardPreviewPlaceholder` — which is the honest
    /// choice over inventing a static crop of a background that's actually user-chosen and dynamic.
    static func publishedCatalogueThemes() -> [KeyboardTheme] {
        loadIndex()
            .filter(\.isPublished)
            .compactMap { summary -> KeyboardTheme? in
                guard let draft = loadDraft(id: summary.id) else { return nil }
                return KeyboardTheme(
                    id: draft.id,
                    name: draft.name.isEmpty ? "Untitled Theme" : draft.name,
                    creatorName: "You",
                    imageAssetName: "custom:\(draft.id)",
                    likeCount: 0,
                    isPremium: false,
                    hashtags: draft.tags,
                    description: "Made in Create Custom Theme.",
                    creatorUid: "",
                    downloadCount: 0
                )
            }
    }

    // MARK: - Photo backgrounds

    /// Downsamples `data` to a size safe for the keyboard extension's memory ceiling and writes it
    /// under this draft's own subdirectory, returning the path `BackgroundChoice.photo` should store
    /// (relative to `mediaRootURL`, matching `ThemeImageSource.appGroupFile`'s own contract).
    ///
    /// Downsampling before writing, not after: a photo straight off the camera can be 12+ MP, and
    /// writing that to the container and decoding it at full size on every theme apply is exactly
    /// the allocation spike `ThemeImageLoader`'s own doc comment identifies as what kills the
    /// extension. 1600px longest side is generous for a window this small and cheap to keep around.
    static func storePhoto(data: Data, draftID: String) -> String? {
        guard let downsampled = ThemeImageLoader.downsample(data: data, maxPixelDimension: 1600, scale: 1) else {
            logger.error("Could not decode picked photo for draft \(draftID, privacy: .public).")
            return nil
        }
        guard let jpeg = downsampled.jpegData(compressionQuality: 0.85) else { return nil }
        let url = draftDirectory(draftID).appendingPathComponent("background.jpg")
        do {
            try ensureDirectoryExists(draftDirectory(draftID))
            try jpeg.write(to: url, options: .atomic)
            // Relative to `mediaRootURL`, matching `ThemeImageSource.appGroupFile`'s own contract —
            // not to `rootURL`, which is itself already one level under `mediaRootURL`.
            return "custom-themes/\(draftID)/background.jpg"
        } catch {
            logger.error("Failed to store photo for draft \(draftID, privacy: .public): \(error.localizedDescription, privacy: .public)")
            return nil
        }
    }

    // MARK: - Helpers

    private static func ensureDirectoryExists(_ url: URL) throws {
        var isDirectory: ObjCBool = false
        if FileManager.default.fileExists(atPath: url.path, isDirectory: &isDirectory), isDirectory.boolValue {
            return
        }
        try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
    }
}

private extension JSONEncoder {
    static let mochi: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.sortedKeys]
        return encoder
    }()
}

private extension JSONDecoder {
    static let mochi: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()
}
