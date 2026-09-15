import Foundation
import os

/// Which marketplace themes the user has **downloaded** — the Themes screen's "MY DOWNLOADED
/// THEMES" strip.
///
/// This is deliberately a third piece of theme state, separate from the two that already exist:
///
///  * `AppliedThemeStore.appliedThemeId` — the *one* theme currently on the keyboard.
///  * `ThemeStore.writeActiveTheme` — the App Group hand-off of that one theme's render document.
///
/// "Downloaded" is a *set* the user curates for quick access, which neither of those models. It
/// mirrors `FontStyleStore`'s owned-id list (same suite, same idempotent add, same one-way
/// app-writes contract) with two intentional differences, both because themes are not fonts:
///
///  1. **No first-run seed.** `FontStyleStore.seedOwnedStyleIDs` exists because Figma's downloaded-
///     fonts strip and the screenshot tests needed five tiles on a clean install. A Mochi font is a
///     Unicode transform with nothing to fetch, so "owning" all five costs nothing and is roughly
///     true. A theme is a real thing the user chooses to keep, so the honest empty state is empty —
///     the strip shows a prompt until the user downloads or applies something.
///  2. **Two writers.** The Themes card's download disc calls `add(_:)` directly, and
///     `AppliedThemeStore.apply(_:)` also calls it — applying a theme implies keeping it, the same
///     rule `FontStyleStore` documents for fonts.
///
/// Ids are the canonical `mochi.<slug>` / `custom.<uuid>` / Firestore ids that `ThemeCatalog` and
/// `RenderableTheme` already key on, so a theme downloaded from one screen is recognised on every
/// other.
enum DownloadedThemeStore {
    private static let logger = Logger(subsystem: "com.mochi.app", category: "DownloadedThemeStore")

    private static var defaults: UserDefaults {
        UserDefaults(suiteName: AppGroup.identifier) ?? .standard
    }

    private enum Key {
        static let owned = "mochi.themes.downloadedThemeIDs"
    }

    /// The downloaded ids, oldest first (append order). No seed — an absent key means the user has
    /// downloaded nothing yet, which the strip renders as its empty state.
    static func loadDownloadedThemeIDs() -> [String] {
        defaults.object(forKey: Key.owned) as? [String] ?? []
    }

    /// Adds a theme to the downloaded set (idempotent). Called by the card's download disc and by
    /// `AppliedThemeStore.apply(_:)`.
    static func add(_ themeID: String) {
        guard !themeID.isEmpty else { return }
        var ids = loadDownloadedThemeIDs()
        guard !ids.contains(themeID) else { return }
        ids.append(themeID)
        defaults.set(ids, forKey: Key.owned)
        logger.info("Downloaded theme: \(themeID, privacy: .public)")
    }

    /// Removes a theme from the downloaded set (idempotent). Backs the card disc's toggle-off and
    /// the strip tile's "remove" affordance.
    static func remove(_ themeID: String) {
        var ids = loadDownloadedThemeIDs()
        guard let index = ids.firstIndex(of: themeID) else { return }
        ids.remove(at: index)
        defaults.set(ids, forKey: Key.owned)
        logger.info("Removed downloaded theme: \(themeID, privacy: .public)")
    }

    static func isDownloaded(_ themeID: String) -> Bool {
        loadDownloadedThemeIDs().contains(themeID)
    }

    @discardableResult
    static func toggle(_ themeID: String) -> Bool {
        if isDownloaded(themeID) {
            remove(themeID)
            return false
        } else {
            add(themeID)
            return true
        }
    }
}
