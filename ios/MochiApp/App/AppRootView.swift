import SwiftUI

private enum AppStage {
    case splash
    case onboarding
    case auth
    case main
}

/// Top-level flow gate, mirrors android/.../ui/AppNavHost.kt's Splash → Onboarding → Auth → Main
/// graph. Same "already-signed-in skips straight to Main" rule Android uses (Firebase Auth persists
/// its session locally, so there's no separate on-device "has seen onboarding" flag on either
/// platform — re-showing onboarding to a signed-out user on every relaunch is the accepted
/// behavior, not a bug).
///
/// If `AppContainer.shared` is nil (no GoogleService-Info.plist in the bundle yet — see
/// FirebaseEnvironment), this whole gate is skipped and RootView shows immediately, exactly like
/// the app behaved before this file existed. That keeps the CI screenshot pipeline
/// (.github/workflows/ios-screenshots.yml) green with zero special-casing until the plist lands.
struct AppRootView: View {
    @State private var stage: AppStage = AppContainer.shared == nil ? .main : (AppContainer.shared?.authRepository.currentUser != nil ? .main : .splash)

    var body: some View {
        switch stage {
        case .splash:
            SplashView(onTimeout: { stage = .onboarding })
        case .onboarding:
            OnboardingView(onFinished: { stage = .auth })
        case .auth:
            AuthView(onBack: { stage = .onboarding }, onAuthenticated: { stage = .main })
        case .main:
            RootView()
        }
    }
}

#Preview {
    AppRootView()
}
