import Foundation
import os

/// Where the **applied** keyboard font lives, plus which styles the user "owns" (the Fonts screen's
/// MY DOWNLOADED FONTS strip).
///
/// Mirrors `ThemeStore`'s one-way contract: the containing app writes, the keyboard extension reads
/// on activation. Backed by the App Group `UserDefaults` rather than a JSON file — it is one string
/// and a short id list, not a document.
///
/// The applied font is deliberately **independent** of the active theme's `fontsConfig`. If a
/// future theme-apply flow wants to carry a font, that path should call `FontStyleStore.apply(_:)`
/// — never the reverse, so applying a font can never silently rewrite the rest of a theme recipe.
enum FontStyleStore {
    private static let logger = Logger(subsystem: "com.mochi.app", category: "FontStyleStore")

    private static var defaults: UserDefaults {
        UserDefaults(suiteName: AppGroup.identifier) ?? .standard
    }

    private enum Key {
        static let applied = "mochi.fonts.appliedStyleID"
        static let owned = "mochi.fonts.ownedStyleIDs"
    }

    /// The five styles Figma's MY DOWNLOADED FONTS strip ships with, in its order. Used as the
    /// first-run seed so the strip — and the screenshot tests — are correct before the user has
    /// applied anything.
    static let seedOwnedStyleIDs = [
        "bubble-cute", "handwritten-elegant", "bold-strong", "nature-flow", "gothic-dark",
    ]

    // MARK: - Applied font (the extension reads this)

    /// The style id the keyboard should transform typed text with, or `nil` for plain text.
    static func loadAppliedStyleID() -> String? {
        defaults.string(forKey: Key.applied)
    }

    /// Persist the applied style. **App only** — the extension cannot write the App Group without
    /// Full Access, by design. Pass `nil` to return to plain text.
    static func apply(_ styleID: String?) {
        if let styleID {
            defaults.set(styleID, forKey: Key.applied)
        } else {
            defaults.removeObject(forKey: Key.applied)
        }
        logger.info("Applied font style: \(styleID ?? "none", privacy: .public)")
    }

    // MARK: - Owned / downloaded styles

    static func loadOwnedStyleIDs() -> [String] {
        defaults.object(forKey: Key.owned) as? [String] ?? seedOwnedStyleIDs
    }

    /// Adds a style to the owned set (idempotent). Applying a font also downloads it — there is no
    /// separate download step, because a Unicode style has nothing to fetch.
    static func addOwnedStyleID(_ styleID: String) {
        var ids = loadOwnedStyleIDs()
        guard !ids.contains(styleID) else { return }
        ids.append(styleID)
        defaults.set(ids, forKey: Key.owned)
    }

    static func isOwned(_ styleID: String) -> Bool {
        loadOwnedStyleIDs().contains(styleID)
    }
}
