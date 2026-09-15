import Foundation
import os

/// Which wallpapers the user has **downloaded** — backs the Wallpapers screen's "Recently
/// Downloaded" strip and the per-card download-disc state.
///
/// A near-exact copy of `DownloadedThemeStore`: a curated *set* of ids the user keeps for quick
/// access, persisted so the strip survives relaunch instead of being in-session theatre.
/// Same suite, same idempotent add / remove / toggle, same one-way app-writes contract, no
/// first-run seed (an absent key means the user has downloaded nothing, which the strip renders as
/// its empty state).
///
/// It uses the App Group suite for consistency with both sibling stores even though — unlike
/// themes and fonts — nothing in the keyboard extension reads wallpapers today. Keeping the suite
/// aligned costs nothing and means a future "use this wallpaper as a keyboard background"
/// integration has the data where every other shared preference already lives.
enum DownloadedWallpaperStore {
    private static let logger = Logger(subsystem: "com.mochi.app", category: "DownloadedWallpaperStore")

    private static var defaults: UserDefaults {
        UserDefaults(suiteName: AppGroup.identifier) ?? .standard
    }

    private enum Key {
        static let owned = "mochi.wallpapers.downloadedWallpaperIDs"
    }

    /// The downloaded ids, oldest first (append order). No seed.
    static func loadDownloadedWallpaperIDs() -> [String] {
        defaults.object(forKey: Key.owned) as? [String] ?? []
    }

    /// Adds a wallpaper to the downloaded set (idempotent).
    static func add(_ wallpaperID: String) {
        guard !wallpaperID.isEmpty else { return }
        var ids = loadDownloadedWallpaperIDs()
        guard !ids.contains(wallpaperID) else { return }
        ids.append(wallpaperID)
        defaults.set(ids, forKey: Key.owned)
        logger.info("Downloaded wallpaper: \(wallpaperID, privacy: .public)")
    }

    /// Removes a wallpaper from the downloaded set (idempotent).
    static func remove(_ wallpaperID: String) {
        var ids = loadDownloadedWallpaperIDs()
        guard let index = ids.firstIndex(of: wallpaperID) else { return }
        ids.remove(at: index)
        defaults.set(ids, forKey: Key.owned)
        logger.info("Removed downloaded wallpaper: \(wallpaperID, privacy: .public)")
    }

    static func isDownloaded(_ wallpaperID: String) -> Bool {
        loadDownloadedWallpaperIDs().contains(wallpaperID)
    }

    @discardableResult
    static func toggle(_ wallpaperID: String) -> Bool {
        if isDownloaded(wallpaperID) {
            remove(wallpaperID)
            return false
        } else {
            add(wallpaperID)
            return true
        }
    }
}
