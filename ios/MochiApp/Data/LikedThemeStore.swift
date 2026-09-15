import Foundation

/// Which themes the user has hearted, stored on the device.
///
/// Liking already has a backend path (`LikeRepository` writes `likes/{uid}_{themeId}`), but that
/// path is inert until `GoogleService-Info.plist` exists and the user is signed in — which is the
/// state the app ships in today. Without a local record the heart looked like a button and did
/// nothing: it lit up, and the next time the screen was built it was grey again.
///
/// So this is the local half, written on every like regardless of backend state, and read by every
/// surface that shows a heart (Theme Detail, Community, Profile's Liked Themes). Same shape and
/// same suite as `DownloadedThemeStore`; when the backend lands this stays as the optimistic cache
/// in front of it rather than being replaced.
enum LikedThemeStore {
    private static var defaults: UserDefaults {
        UserDefaults(suiteName: AppGroup.identifier) ?? .standard
    }

    private static let key = "mochi.themes.likedThemeIDs"

    /// Liked ids, oldest first.
    static func likedThemeIDs() -> [String] {
        defaults.object(forKey: key) as? [String] ?? []
    }

    static func isLiked(_ themeID: String) -> Bool {
        likedThemeIDs().contains(themeID)
    }

    /// Returns the new state.
    @discardableResult
    static func toggle(_ themeID: String) -> Bool {
        guard !themeID.isEmpty else { return false }
        var ids = likedThemeIDs()
        if let index = ids.firstIndex(of: themeID) {
            ids.remove(at: index)
            defaults.set(ids, forKey: key)
            return false
        }
        ids.append(themeID)
        defaults.set(ids, forKey: key)
        return true
    }

    /// The liked themes as catalogue entries, newest first — what Profile's Liked Themes card lists.
    static func likedThemes() -> [KeyboardTheme] {
        likedThemeIDs().reversed().compactMap { ThemeCatalog.theme(id: $0) }
    }
}
