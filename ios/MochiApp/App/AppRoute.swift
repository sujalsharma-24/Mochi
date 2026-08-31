import Foundation

/// Every screen that is pushed on top of the tab bar, as a value.
///
/// Mirrors the routes in android/.../ui/AppNavHost.kt (`themeDetail/{themeId}`, `profile?uid=`,
/// `settings`, `paywall`, `search`, `leaderboard`, `wallpapers`). `KeyboardTheme` is `Hashable`, so
/// Theme Detail carries the whole value rather than an id that then has to be looked up.
enum AppRoute: Hashable {
    case themeDetail(KeyboardTheme)
    /// `nil` uid = the signed-in user's own profile; a non-nil uid = another creator's.
    case profile(uid: String?)
    case search
    case settings
    case paywall
    case leaderboard
    case wallpapers
}
