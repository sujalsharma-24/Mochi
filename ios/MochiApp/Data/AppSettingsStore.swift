import Foundation
import SwiftUI

/// The 4 keyboard toggles + the notifications preference, as they appear on the Settings screen.
///
/// The keyboard toggles are written to the **App Group** `UserDefaults`, not `.standard` — on iOS
/// the keyboard is a separate process (unlike Android, where `SettingsRepository`'s comment notes
/// the IME is same-process), so the extension has to read them from the shared container keyed by
/// the same identifier `ThemeStore` uses. `.standard` here would silently not reach the keyboard.
///
/// `notificationsEnabled` mirrors android: it lives on `users/{uid}` in Firestore (a Cloud Function
/// reads it before sending a push), so it's forwarded to `UserRepository` when a backend exists and
/// otherwise just held locally.
@MainActor
final class AppSettingsStore: ObservableObject {
    static let shared = AppSettingsStore()

    private let defaults: UserDefaults =
        UserDefaults(suiteName: AppGroup.identifier) ?? .standard

    private enum Key {
        static let autocorrect = "mochi.settings.autocorrect"
        static let swipeTyping = "mochi.settings.swipeTyping"
        static let haptic = "mochi.settings.hapticFeedback"
        static let keyClick = "mochi.settings.keyClickSound"
        static let notifications = "mochi.settings.notifications"
    }

    @Published var autocorrectEnabled: Bool { didSet { defaults.set(autocorrectEnabled, forKey: Key.autocorrect) } }
    @Published var swipeTypingEnabled: Bool { didSet { defaults.set(swipeTypingEnabled, forKey: Key.swipeTyping) } }
    @Published var hapticFeedbackEnabled: Bool { didSet { defaults.set(hapticFeedbackEnabled, forKey: Key.haptic) } }
    @Published var keyClickSoundEnabled: Bool { didSet { defaults.set(keyClickSoundEnabled, forKey: Key.keyClick) } }
    @Published var notificationsEnabled: Bool {
        didSet {
            defaults.set(notificationsEnabled, forKey: Key.notifications)
            if let container = AppContainer.shared,
               let uid = container.authRepository.currentUser?.uid {
                let enabled = notificationsEnabled
                Task { try? await container.userRepository.setNotificationsEnabled(uid: uid, enabled: enabled) }
            }
        }
    }

    private init() {
        // Defaults match android's SettingsUiState: everything on except key-click sound.
        autocorrectEnabled = defaults.object(forKey: Key.autocorrect) as? Bool ?? true
        swipeTypingEnabled = defaults.object(forKey: Key.swipeTyping) as? Bool ?? true
        hapticFeedbackEnabled = defaults.object(forKey: Key.haptic) as? Bool ?? true
        keyClickSoundEnabled = defaults.object(forKey: Key.keyClick) as? Bool ?? false
        notificationsEnabled = defaults.object(forKey: Key.notifications) as? Bool ?? true
    }

    /// The identity line under ACCOUNT — email / phone / a neutral fallback.
    var accountLabel: String {
        guard let user = AppContainer.shared?.authRepository.currentUser else { return "Not signed in" }
        return user.email ?? "Signed in"
    }
}
