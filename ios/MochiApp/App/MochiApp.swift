import SwiftUI

@main
struct MochiApp: App {
    init() {
        // No-ops until GoogleService-Info.plist is added to the bundle — see FirebaseEnvironment.
        FirebaseEnvironment.configureIfPossible()
        // Repairs the keyboard's copy of the applied theme if the write at Apply time never landed.
        AppliedThemeStore.syncToKeyboard()
    }

    var body: some Scene {
        WindowGroup {
            #if DEBUG
            if ThemeSnapshotHarness.isEnabled {
                ThemeSnapshotHostView()
            } else if ThemeLabHarness.isEnabled {
                ThemeLabHarness()
            } else {
                AppRootView()
            }
            #else
            AppRootView()
            #endif
        }
    }
}
