import FirebaseAppCheck
import FirebaseAuth
import FirebaseCore
import FirebaseFirestore
import FirebaseFunctions
import FirebaseStorage

/// Mirrors android/.../MochiApplication.kt's role: configures the Firebase SDK once at app launch
/// and decides which backend (local emulator vs. the live `mochi-940bd` project) every repository
/// talks to.
///
/// Unlike Android — which defaults to the local Firebase Emulator Suite reached over `adb reverse`
/// from a physical test device on the same dev machine — this app has no such loop available: there
/// is no Mac/Simulator on this dev machine (see ios/README.md), and the eventual real-device test
/// (Sujal's friend's iPhone) cannot reach a `127.0.0.1` emulator running on this Windows machine at
/// all, the way `adb reverse` lets an Android phone do. `useLocalEmulator` therefore defaults to
/// **false** here — every build talks to the live Firebase project — the inverse of Android's
/// default. Flip it only if this code ever runs from a Mac that also has the emulator suite running
/// locally (e.g. a future contributor's machine).
enum FirebaseEnvironment {
    private static let useLocalEmulator = false
    private static let emulatorHost = "127.0.0.1"
    private static let useDebugAppCheck = true

    private(set) static var isConfigured = false

    /// No-ops (and leaves `isConfigured` false) if `GoogleService-Info.plist` isn't in the bundle
    /// yet — calling `FirebaseApp.configure()` without one is a hard crash, and this repo doesn't
    /// have that file committed until Sujal registers the iOS app in the Firebase console and hands
    /// it over (Android's equivalent, `google-services.json`, was delivered the same way — see
    /// [[project-mochi-accounts]]). Every screen that needs a real backend should check
    /// `FirebaseEnvironment.isConfigured` (via `AppContainer.shared`) and fall back to the existing
    /// mock-data presentation rather than touching `Auth.auth()`/`Firestore.firestore()` directly,
    /// which would crash unconditionally once this returns without configuring.
    @discardableResult
    static func configureIfPossible() -> Bool {
        guard Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") != nil else {
            return false
        }
        guard FirebaseApp.app() == nil else {
            isConfigured = true
            return true
        }

        FirebaseApp.configure()

        let providerFactory = useDebugAppCheck
            ? AppCheckDebugProviderFactory()
            : AppAttestProviderFactory()
        AppCheck.setAppCheckProviderFactory(providerFactory)

        if useLocalEmulator {
            Auth.auth().useEmulator(withHost: emulatorHost, port: 9099)
            let settings = Firestore.firestore().settings
            settings.host = "\(emulatorHost):8080"
            settings.isSSLEnabled = false
            settings.cacheSettings = MemoryCacheSettings()
            Firestore.firestore().settings = settings
            Functions.functions().useEmulator(withHost: emulatorHost, port: 5001)
            Storage.storage().useEmulator(withHost: emulatorHost, port: 9199)
        }

        isConfigured = true
        return true
    }
}
