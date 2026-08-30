import SwiftUI

@main
struct MochiApp: App {
    init() {
        // No-ops until GoogleService-Info.plist is added to the bundle — see FirebaseEnvironment.
        FirebaseEnvironment.configureIfPossible()
    }

    var body: some Scene {
        WindowGroup {
            #if DEBUG
            if ThemeLabHarness.isEnabled {
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
