import Foundation

/// The one place the App Group identifier is written down.
///
/// It has to match the `com.apple.security.application-groups` entitlement on **both** targets
/// (declared in `project.yml`, which generates each target's .entitlements file). When the two
/// disagree, `UserDefaults(suiteName:)` returns nil and every call site quietly falls back to its
/// own process-local `.standard` — the app and the keyboard extension then read and write two
/// unrelated stores, so applying a theme or a font appears to work in the app and never reaches
/// the real keyboard, with nothing logged and nothing thrown. That failure is invisible in the
/// Simulator and in the in-app preview (both run in the app's own process), which is exactly why
/// this string lives in one file instead of being repeated at each store.
///
/// App Group identifiers are globally unique across all Apple developer accounts, so this cannot
/// be a generic name — `group.com.mochi.app` was already registered to someone else's team and
/// Apple refused to provision it (see `project.yml`'s note on the bundle identifiers).
enum AppGroup {
    static let identifier = "group.com.tanmaysingh.mochi"
}
