import AuthenticationServices
import FirebaseAuth
import FirebaseFunctions
import FirebaseMessaging
import GoogleSignIn
import UIKit

enum AuthRepositoryError: LocalizedError {
    case missingUserId
    case appleSignInFailed
    case googleSignInNotConfigured

    var errorDescription: String? {
        switch self {
        case .missingUserId: return "Sign-in succeeded but no user id was returned."
        case .appleSignInFailed: return "Apple Sign-In failed. Please try again."
        case .googleSignInNotConfigured: return "Google Sign-In isn't set up yet."
        }
    }
}

/// Swift mirror of android/.../data/AuthRepository.kt, same backend contract (Firebase Auth +
/// the sendPhoneOtp/verifyPhoneOtp/onAccountDelete callables in functions/src/), swapping Android's
/// Credential Manager for GoogleSignIn-iOS and adding real Sign in with Apple (Android stubs that
/// one — see AppleSignInCoordinator).
final class AuthRepository {
    private let auth: Auth
    private let functions: Functions
    private let userRepository: UserRepository
    private let appleSignIn = AppleSignInCoordinator()

    init(auth: Auth, functions: Functions, userRepository: UserRepository) {
        self.auth = auth
        self.functions = functions
        self.userRepository = userRepository
    }

    var currentUser: User? { auth.currentUser }

    func addAuthStateListener(_ listener: @escaping (User?) -> Void) -> AuthStateDidChangeListenerHandle {
        auth.addStateDidChangeListener { _, user in listener(user) }
    }

    func removeAuthStateListener(_ handle: AuthStateDidChangeListenerHandle) {
        auth.removeStateDidChangeListener(handle)
    }

    func signUpWithEmail(email: String, password: String) async throws {
        let result = try await auth.createUser(withEmail: email, password: password)
        try await userRepository.createUserProfile(uid: result.user.uid)
    }

    func signInWithEmail(email: String, password: String) async throws {
        _ = try await auth.signIn(withEmail: email, password: password)
    }

    func sendPasswordReset(email: String) async throws {
        try await auth.sendPasswordReset(withEmail: email)
    }

    /// Reads the OAuth client ID Firebase already resolved from GoogleService-Info.plist
    /// (`FirebaseApp.options.clientID`) rather than hardcoding one — mirrors how the plist is the
    /// single source of truth on Android too (its `googleWebClientId` is copied out of
    /// google-services.json's `client_type: 3` entry once, by hand).
    @MainActor
    func signInWithGoogle(presenting viewController: UIViewController) async throws {
        guard let clientID = auth.app?.options.clientID else {
            throw AuthRepositoryError.googleSignInNotConfigured
        }
        GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: clientID)

        let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: viewController)
        guard let idToken = result.user.idToken?.tokenString else {
            throw AuthRepositoryError.googleSignInNotConfigured
        }
        let credential = GoogleAuthProvider.credential(
            withIDToken: idToken,
            accessToken: result.user.accessToken.tokenString
        )
        let authResult = try await auth.signIn(with: credential)
        try await createProfileIfNewUser(authResult)
    }

    @MainActor
    func signInWithApple(presentationAnchor: ASPresentationAnchor) async throws {
        let credential = try await appleSignIn.signIn(presentationAnchor: presentationAnchor)
        let authResult = try await auth.signIn(with: credential)
        try await createProfileIfNewUser(authResult)
    }

    /// Generates the code and sends it as a plain Twilio SMS server-side (functions/src/otp.ts) —
    /// no Twilio credential ever touches the client. Same callable Android's phone-OTP flow uses.
    func sendPhoneOtp(phoneNumber: String) async throws {
        _ = try await functions.httpsCallable("sendPhoneOtp").call(["phoneNumber": phoneNumber])
    }

    /// Verifies the code against otpRequests' stored hash server-side, mints a Firebase custom
    /// token (creating the Auth user on first use), and returns it for signInWithCustomToken —
    /// Twilio never talks to Firebase Auth directly.
    func verifyPhoneOtp(phoneNumber: String, code: String) async throws {
        let result = try await functions.httpsCallable("verifyPhoneOtp")
            .call(["phoneNumber": phoneNumber, "code": code])
        guard let data = result.data as? [String: Any], let token = data["token"] as? String else {
            throw AuthRepositoryError.missingUserId
        }
        let isNewUser = data["isNewUser"] as? Bool ?? false

        try await auth.signIn(withCustomToken: token)
        if isNewUser {
            guard let uid = auth.currentUser?.uid else { throw AuthRepositoryError.missingUserId }
            try await userRepository.createUserProfile(uid: uid)
        }
    }

    /// Sign-in and sign-up are the same call for every OAuth-style provider (Firebase creates the
    /// user on first use) — a repeat login must NOT re-run createUserProfile, or it would reset an
    /// existing user's counters back to 0 every time they sign in.
    private func createProfileIfNewUser(_ result: AuthDataResult) async throws {
        if result.additionalUserInfo?.isNewUser == true {
            try await userRepository.createUserProfile(uid: result.user.uid)
        }
    }

    /// Called after every successful sign-in (see AuthViewModel) — re-associates whatever FCM token
    /// already exists on-device (it can predate any signed-in account) with the uid that just
    /// signed in.
    func syncFcmToken() async throws {
        // FirebaseMessaging is Objective-C at its core and doesn't ship a native async token()
        // API (unlike Auth/Firestore/Functions above) — wrapped by hand rather than relying on
        // Swift's completion-handler-to-async auto-bridging, which isn't guaranteed here.
        let token = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<String, Error>) in
            Messaging.messaging().token { token, error in
                if let error {
                    continuation.resume(throwing: error)
                } else if let token {
                    continuation.resume(returning: token)
                } else {
                    continuation.resume(throwing: AuthRepositoryError.missingUserId)
                }
            }
        }
        try await updateFcmToken(token)
    }

    func updateFcmToken(_ token: String) async throws {
        guard let uid = auth.currentUser?.uid else { return }
        try await userRepository.updateFcmToken(uid: uid, token: token)
    }

    func signOut() throws {
        try auth.signOut()
    }

    /// Calls the onAccountDelete callable (functions/src/account.ts) — soft-deletes the Firestore
    /// profile, unpublishes the user's themes, and deletes the real Firebase Auth account
    /// server-side. The client never deletes users/{uid} directly.
    func deleteAccount() async throws {
        _ = try await functions.httpsCallable("onAccountDelete").call()
    }
}
