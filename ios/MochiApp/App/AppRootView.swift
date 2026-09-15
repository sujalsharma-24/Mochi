import SwiftUI

private enum AppStage {
    case splash
    case onboarding
    case auth
    case main
}

/// Top-level flow gate + the app's single `NavigationStack`. Mirrors android/.../ui/AppNavHost.kt's
/// Splash → Onboarding → Auth → Main graph and its pushed destinations
/// (`themeDetail`, `profile`, `settings`, `paywall`, `search`, `leaderboard`, `wallpapers`).
///
/// Onboarding is shown once per install (tracked by `hasSeenOnboarding`), then the app opens
/// straight to Main. When `AppContainer.shared` is non-nil and a user is already signed in, Splash
/// and Onboarding are skipped exactly like Android. Auth is only reached from the onboarding
/// "Get Started" and stays a dead-end until `GoogleService-Info.plist` exists — until then Main is
/// reachable regardless so the app is fully explorable on mock data.
struct AppRootView: View {
    @AppStorage("mochi.hasSeenOnboarding") private var hasSeenOnboarding = false
    @AppStorage("mochi.hasCompletedAuth") private var hasCompletedAuth = false
    @State private var stage: AppStage
    @State private var path: [AppRoute] = []
    /// The selected tab and the Fonts tab's browsing cursor live here (not in `RootView`) so a
    /// pushed screen — Search's font results — can pop back to the Fonts tab on a specific style.
    @State private var selectedTab: MochiTab = .keyboard
    @State private var fontsSelection: String = "handwritten-elegant"

    init() {
        let signedIn = AppContainer.shared?.authRepository.currentUser != nil
        let seenOnboarding = UserDefaults.standard.bool(forKey: "mochi.hasSeenOnboarding")
        let completedAuth = UserDefaults.standard.bool(forKey: "mochi.hasCompletedAuth")
        // UI tests need the tab UI immediately, not the splash/onboarding flow.
        let skipForTests = ProcessInfo.processInfo.arguments.contains("UITEST_SKIP_ONBOARDING")
        let initial: AppStage
        if skipForTests || signedIn || (seenOnboarding && completedAuth) {
            initial = .main
        } else if seenOnboarding {
            initial = .auth
        } else {
            initial = .splash
        }
        _stage = State(initialValue: initial)
        // QA: `-QA_OPEN_WALLPAPERS` launches straight into the Wallpapers screen.
        if ProcessInfo.processInfo.arguments.contains("QA_OPEN_WALLPAPERS") {
            _stage = State(initialValue: .main)
            _path = State(initialValue: [.wallpapers])
        }
        if ProcessInfo.processInfo.arguments.contains("QA_OPEN_THEME_DETAIL") {
            _stage = State(initialValue: .main)
            _path = State(initialValue: [.themeDetail(MockData.popularThemes.first!)])
        }
        // QA: `-QA_OPEN_PROFILE` and `-QA_OPEN_TAB themes|fonts|community|create` open a screen
        // straight from the command line, which is the only way to screenshot one without a device
        // in hand — the same reason `QA_OPEN_WALLPAPERS` exists.
        if ProcessInfo.processInfo.arguments.contains("QA_OPEN_PROFILE") {
            _stage = State(initialValue: .main)
            _path = State(initialValue: [.profile(uid: nil)])
        }
        switch UserDefaults.standard.string(forKey: "QA_OPEN_TAB") {
        case "themes":    _stage = State(initialValue: .main); _selectedTab = State(initialValue: .themes)
        case "fonts":     _stage = State(initialValue: .main); _selectedTab = State(initialValue: .fonts)
        case "community": _stage = State(initialValue: .main); _selectedTab = State(initialValue: .community)
        case "create":    _stage = State(initialValue: .main); _selectedTab = State(initialValue: .create)
        default: break
        }
    }

    var body: some View {
        switch stage {
        case .splash:
            SplashView(onTimeout: { stage = .onboarding })
        case .onboarding:
            OnboardingView(onFinished: {
                hasSeenOnboarding = true
                stage = .auth
            })
        case .auth:
            AuthView(onBack: { stage = .onboarding }, onAuthenticated: {
                hasCompletedAuth = true
                stage = .main
            })
        case .main:
            NavigationStack(path: $path) {
                RootView(path: $path, selectedTab: $selectedTab, fontsSelection: $fontsSelection)
                    .navigationBarHidden(true)
                    .navigationDestination(for: AppRoute.self) { route in
                        destination(for: route)
                            .navigationBarBackButtonHidden(true)
                            .toolbar(.hidden, for: .navigationBar)
                    }
            }
            .onAppear {
                if ProcessInfo.processInfo.arguments.contains("QA_OPEN_THEME_DETAIL") {
                    path = [.themeDetail(MockData.popularThemes.first!)]
                }
            }
        }
    }

    @ViewBuilder
    private func destination(for route: AppRoute) -> some View {
        switch route {
        case .themeDetail(let theme):
            ThemeDetailView(
                theme: theme,
                onBack: pop,
                onUnlockPremium: { path.append(.paywall) },
                onCreatorClick: { path.append(.profile(uid: $0)) }
            )
        case .profile(let uid):
            ProfileView(
                uid: uid,
                onBack: pop,
                onSettings: { path.append(.settings) },
                onPaywall: { path.append(.paywall) },
                onThemeClick: { path.append(.themeDetail($0)) },
                onSeeAll: { path.append(.themeCollection($0)) }
            )
        case .search:
            SearchView(
                onBack: pop,
                onThemeClick: { path.append(.themeDetail($0)) },
                onFontClick: { fontID in
                    fontsSelection = fontID
                    selectedTab = .fonts
                    path.removeAll()
                },
                onCreatorClick: { path.append(.profile(uid: $0)) }
            )
        case .settings:
            SettingsView(onBack: pop, onSignedOut: {
                path.removeAll()
                hasCompletedAuth = false
                stage = .auth
            })
        case .paywall:
            PaywallView(onClose: pop)
        case .leaderboard:
            LeaderboardView(
                onBack: pop,
                onSearch: { path.append(.search) },
                onCreatorClick: { path.append(.profile(uid: $0)) }
            )
        case .wallpapers:
            WallpapersView(onBack: pop, onUnlockPremium: { path.append(.paywall) })
        case .downloadedFonts:
            DownloadedFontsView(onBack: pop, onOpenPaywall: { path.append(.paywall) })
        case .themeCollection(let kind):
            ThemeCollectionView(
                kind: kind,
                onBack: pop,
                onThemeClick: { path.append(.themeDetail($0)) }
            )
        }
    }

    private func pop() {
        if !path.isEmpty { path.removeLast() }
    }
}

#Preview {
    AppRootView()
}
