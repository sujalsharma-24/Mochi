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
    @State private var stage: AppStage
    @State private var path: [AppRoute] = []

    init() {
        let signedIn = AppContainer.shared?.authRepository.currentUser != nil
        let seenOnboarding = UserDefaults.standard.bool(forKey: "mochi.hasSeenOnboarding")
        // UI tests need the tab UI immediately, not the splash/onboarding flow.
        let skipForTests = ProcessInfo.processInfo.arguments.contains("UITEST_SKIP_ONBOARDING")
        _stage = State(initialValue: signedIn || seenOnboarding || skipForTests ? .main : .splash)
    }

    var body: some View {
        switch stage {
        case .splash:
            SplashView(onTimeout: { stage = .onboarding })
        case .onboarding:
            OnboardingView(onFinished: {
                hasSeenOnboarding = true
                stage = AppContainer.shared == nil ? .main : .auth
            })
        case .auth:
            AuthView(onBack: { stage = .onboarding }, onAuthenticated: { stage = .main })
        case .main:
            NavigationStack(path: $path) {
                RootView(path: $path)
                    .navigationBarHidden(true)
                    .navigationDestination(for: AppRoute.self) { route in
                        destination(for: route)
                            .navigationBarBackButtonHidden(true)
                            .toolbar(.hidden, for: .navigationBar)
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
                onThemeClick: { path.append(.themeDetail($0)) }
            )
        case .search:
            SearchView(onBack: pop, onThemeClick: { path.append(.themeDetail($0)) })
        case .settings:
            SettingsView(onBack: pop, onSignedOut: {
                path.removeAll()
                stage = AppContainer.shared == nil ? .main : .auth
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
        }
    }

    private func pop() {
        if !path.isEmpty { path.removeLast() }
    }
}

#Preview {
    AppRootView()
}
