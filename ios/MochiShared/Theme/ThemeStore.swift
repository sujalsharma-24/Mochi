import Foundation
import os

/// Moves the active theme from the app into the keyboard extension.
///
/// ## Why it is one-directional
///
/// A custom keyboard's sandbox lets it **read** the shared App Group container but not **write**
/// to it unless the user has granted Full Access. Rather than treat that as a limitation to work
/// around, the whole design leans on it: the app is the only writer, the extension is a pure
/// reader, and Mochi never has to ask for Full Access to theme a keyboard.
///
/// That is worth real money and real review risk. App Review guideline 4.4.1 requires a keyboard
/// to remain fully functional *without* Full Access, and the Full Access permission sheet — which
/// warns the user that the keyboard may transmit everything they type — is the single biggest drop
/// -off point in any keyboard app's onboarding. A theme system that needs it is a theme system
/// most users never see.
///
/// ## Propagation timing
///
/// There is no push channel into a keyboard extension. The extension picks up a new theme the next
/// time it is activated, which in practice means the next time the user taps a text field. Design
/// for "app writes, extension reads on next activation" — not for instant propagation.
enum ThemeStore {
    /// Must match the App Group capability on **both** targets. Changing this string without
    /// changing the entitlements silently disables theme sync — the extension keeps rendering the
    /// built-in default and nothing errors.
    static let appGroupIdentifier = "group.com.mochi.app"

    private static let activeThemeFilename = "active-theme.json"
    private static let logger = Logger(subsystem: "com.mochi.app", category: "ThemeStore")

    /// The shared container, or `nil` when the App Group is not provisioned.
    ///
    /// `nil` is a completely normal state today: the project has no signing team configured yet,
    /// so the entitlement does not exist and this returns nothing. Every caller therefore has to
    /// have a working answer without it, which is why `loadActiveTheme()` falls back to a built-in
    /// theme rather than failing. The keyboard must render *something* correct on first launch.
    static var containerURL: URL? {
        FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupIdentifier)
    }

    private static var activeThemeURL: URL? {
        containerURL?.appendingPathComponent(activeThemeFilename)
    }

    // MARK: - Reading (app + extension)

    /// The theme the keyboard should render right now.
    ///
    /// Never throws and never returns nil. A keyboard that fails to load its theme has to fall
    /// back to a good-looking default, not to a blank view — the user is mid-sentence in someone
    /// else's app and has no way to react to an error.
    static func loadActiveTheme() -> MochiKeyboardTheme {
        guard let url = activeThemeURL else {
            logger.info("App Group unavailable; using built-in default theme.")
            return BuiltInThemes.default
        }
        do {
            let data = try Data(contentsOf: url)
            return try JSONDecoder().decode(MochiKeyboardTheme.self, from: data)
        } catch let error as ThemeDecodingError {
            // A theme written by a newer build of the app. Rendering it with an older decoder would
            // produce something subtly wrong, which is worse than showing the known-good default.
            logger.error("Stored theme is unreadable: \(error.localizedDescription, privacy: .public)")
            return BuiltInThemes.default
        } catch let error as CocoaError where error.code == .fileReadNoSuchFile {
            // Expected before the user has ever applied a theme.
            return BuiltInThemes.default
        } catch {
            logger.error("Failed to load active theme: \(error.localizedDescription, privacy: .public)")
            return BuiltInThemes.default
        }
    }

    // MARK: - Writing (app only)

    /// Persists the active theme. **Call from the containing app only** — this fails silently in
    /// the extension without Full Access, by design.
    @discardableResult
    static func writeActiveTheme(_ theme: MochiKeyboardTheme) -> Bool {
        guard let url = activeThemeURL else {
            logger.error("Cannot write active theme: App Group container unavailable.")
            return false
        }
        do {
            let encoder = JSONEncoder()
            // Sorted, pretty output: this file is read by a second process and by whoever is
            // debugging why a theme looks wrong. The size cost is irrelevant next to being able to
            // `cat` it and see the problem.
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            let data = try encoder.encode(theme)
            // Atomic, so the extension can never observe a half-written document. Without this,
            // the failure is rare, timing-dependent, and shows up as a keyboard that occasionally
            // launches unthemed.
            try data.write(to: url, options: .atomic)
            return true
        } catch {
            logger.error("Failed to write active theme: \(error.localizedDescription, privacy: .public)")
            return false
        }
    }
}
