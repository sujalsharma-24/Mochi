import AuthenticationServices
import FirebaseAuth
import Foundation
import UIKit

struct AuthUiState {
    var isLoading = false
    var errorMessage: String?
    var resetEmailSent = false
    /// nil = show the phone-number field; non-nil = the OTP was sent to this number via Twilio,
    /// show the code-entry field (also doubles as "which number to verify against").
    var otpPhoneNumber: String?
}

/// Swift mirror of android/.../features/auth/AuthViewModel.kt — same state shape and error-mapping
/// approach, adapted to Firebase's Swift error types.
@MainActor
final class AuthViewModel: ObservableObject {
    @Published private(set) var uiState = AuthUiState()

    private let authRepository: AuthRepository

    init(authRepository: AuthRepository) {
        self.authRepository = authRepository
    }

    func signUp(email: String, password: String, onSuccess: @escaping () -> Void) {
        runAuthAction(onSuccess: onSuccess) { try await self.authRepository.signUpWithEmail(email: email, password: password) }
    }

    func signIn(email: String, password: String, onSuccess: @escaping () -> Void) {
        runAuthAction(onSuccess: onSuccess) { try await self.authRepository.signInWithEmail(email: email, password: password) }
    }

    func signInWithGoogle(presenting viewController: UIViewController, onSuccess: @escaping () -> Void) {
        runAuthAction(onSuccess: onSuccess) { try await self.authRepository.signInWithGoogle(presenting: viewController) }
    }

    func signInWithApple(presentationAnchor: ASPresentationAnchor, onSuccess: @escaping () -> Void) {
        runAuthAction(onSuccess: onSuccess) { try await self.authRepository.signInWithApple(presentationAnchor: presentationAnchor) }
    }

    func sendPhoneCode(_ phoneNumber: String) {
        Task {
            uiState.isLoading = true
            uiState.errorMessage = nil
            do {
                try await authRepository.sendPhoneOtp(phoneNumber: phoneNumber)
                uiState.isLoading = false
                uiState.otpPhoneNumber = phoneNumber
            } catch {
                uiState.isLoading = false
                uiState.errorMessage = mapAuthError(error)
            }
        }
    }

    func verifyPhoneCode(_ code: String, onSuccess: @escaping () -> Void) {
        guard let phoneNumber = uiState.otpPhoneNumber else { return }
        runAuthAction(onSuccess: onSuccess) { try await self.authRepository.verifyPhoneOtp(phoneNumber: phoneNumber, code: code) }
    }

    func resetPhoneFlow() {
        uiState.otpPhoneNumber = nil
        uiState.errorMessage = nil
    }

    func sendPasswordReset(_ email: String) {
        Task {
            uiState.isLoading = true
            uiState.errorMessage = nil
            do {
                try await authRepository.sendPasswordReset(email: email)
                uiState.isLoading = false
                uiState.resetEmailSent = true
            } catch {
                uiState.isLoading = false
                uiState.errorMessage = mapAuthError(error)
            }
        }
    }

    func showNotice(_ message: String) {
        uiState.errorMessage = message
    }

    func clearMessages() {
        uiState.errorMessage = nil
        uiState.resetEmailSent = false
    }

    private func runAuthAction(onSuccess: @escaping () -> Void, block: @escaping () async throws -> Void) {
        Task {
            uiState.isLoading = true
            uiState.errorMessage = nil
            do {
                try await block()
                uiState.isLoading = false
                // Best-effort: a token-fetch failure shouldn't block sign-in from completing.
                try? await authRepository.syncFcmToken()
                onSuccess()
            } catch {
                uiState.isLoading = false
                uiState.errorMessage = mapAuthError(error)
            }
        }
    }

    private func mapAuthError(_ error: Error) -> String {
        if let authErrorCode = AuthErrorCode(rawValue: (error as NSError).code) {
            switch authErrorCode {
            case .weakPassword: return "Password is too weak - use at least 6 characters."
            case .wrongPassword, .invalidEmail, .invalidCredential: return "That email or password doesn't look right."
            case .emailAlreadyInUse: return "An account with that email already exists."
            case .userNotFound: return "No account found for that email."
            default: break
            }
        }
        if (error as? ASAuthorizationError)?.code == .canceled { return "Sign-in canceled." }
        // The phone-OTP callables' error message is already display-ready text from the callable's
        // own HttpsError (e.g. "That code is incorrect or expired."), so it falls through here too.
        return error.localizedDescription
    }
}
