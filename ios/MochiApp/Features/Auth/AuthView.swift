import AuthenticationServices
import SwiftUI

/// Port of android/.../features/auth/AuthScreen.kt to SwiftUI. Same hand-designed gradients/shape
/// (no Figma source exists for Auth — see [[project-mochi-decisions]]), same Email/Phone-OTP flow
/// against the same Cloud Functions callables. Unlike Android, the Apple button here is real Sign
/// in with Apple rather than a stub notice — Apple requires it wherever Google Sign-In is offered.
///
/// When `AppContainer.shared` is nil (no GoogleService-Info.plist yet), the screen runs in **mock
/// mode**: every sign-in action immediately calls `onAuthenticated` so the user can still explore
/// the app. Once the plist is added this switches to the real Firebase flow automatically.
struct AuthView: View {
    var onBack: () -> Void = {}
    var onAuthenticated: () -> Void = {}

    /// nil when Firebase isn't configured — every action just calls `onAuthenticated` directly.
    @StateObject private var viewModel: AuthViewModel = {
        if let container = AppContainer.shared {
            return AuthViewModel(authRepository: container.authRepository)
        } else {
            return AuthViewModel(authRepository: nil)
        }
    }()

    private var isMockMode: Bool { AppContainer.shared == nil }

    private enum Mode { case signIn, signUp }
    private enum Method { case email, phone }

    @State private var mode: Mode = .signIn
    @State private var method: Method = .email
    @State private var emailOrPhone = ""
    @State private var password = ""
    @State private var passwordVisible = false
    @State private var otpCode = ""

    private var codeSent: Bool { viewModel.uiState.otpPhoneNumber != nil }

    private static let headerGradient = LinearGradient(
        colors: [
            Color(red: 0.565, green: 0.071, blue: 0.655),
            Color(red: 0.808, green: 0.463, blue: 0.859),
            Color(red: 0.886, green: 0.498, blue: 0.800),
            Color(red: 0.561, green: 0.486, blue: 0.914)
        ],
        startPoint: .top, endPoint: .bottom
    )

    private static let primaryButtonGradient = LinearGradient(
        stops: [
            .init(color: Color(red: 0.808, green: 0.463, blue: 0.859), location: 0.0),
            .init(color: Color(red: 0.886, green: 0.498, blue: 0.800), location: 0.32),
            .init(color: Color(red: 0.561, green: 0.486, blue: 0.914), location: 1.0)
        ],
        startPoint: .leading, endPoint: .trailing
    )

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                header
                form
            }
        }
        .background(Color.white)
        .ignoresSafeArea(edges: .top)
    }

    private var header: some View {
        ZStack(alignment: .top) {
            WaveHeaderShape()
                .fill(Self.headerGradient)
                .frame(height: 260)

            // Decorative ambient circles — matching Android's Canvas overlay
            Canvas { context, size in
                context.fill(
                    Path(ellipseIn: CGRect(
                        x: size.width * 0.1 - size.width * 0.4,
                        y: size.height * 0.2 - size.width * 0.4,
                        width: size.width * 0.8,
                        height: size.width * 0.8
                    )),
                    with: .color(.white.opacity(0.10))
                )
                context.fill(
                    Path(ellipseIn: CGRect(
                        x: size.width * 0.9 - size.width * 0.35,
                        y: size.height * 0.7 - size.width * 0.35,
                        width: size.width * 0.7,
                        height: size.width * 0.7
                    )),
                    with: .color(.white.opacity(0.08))
                )
            }
            .frame(height: 260)
            .allowsHitTesting(false)

            VStack(alignment: .center, spacing: 10) {
                HStack {
                    Button(action: onBack) {
                        Image(systemName: "chevron.left")
                            .foregroundStyle(.white)
                            .frame(width: 36, height: 36)
                    }
                    Spacer()
                }

                Spacer().frame(height: 4)

                // App Icon from Figma assets
                Image("app_icon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 64, height: 64)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(.white.opacity(0.3), lineWidth: 1)
                    )
                    .shadow(color: .black.opacity(0.2), radius: 10, y: 5)

                Text(mode == .signIn ? "Welcome" : "Create Account")
                    .font(MochiFont.title(28))
                    .fontWeight(.bold)
                    .foregroundStyle(.white)

                Text(mode == .signIn ? "Sign in to continue" : "Sign up to get started")
                    .font(MochiFont.body(14))
                    .foregroundStyle(.white.opacity(0.9))
            }
            .padding(.horizontal, MochiSpacing.lg)
            .padding(.top, MochiSpacing.md)
        }
    }

    private var form: some View {
        VStack(alignment: .center, spacing: 0) {
            if method == .email {
                emailFields
            } else if !codeSent {
                AuthTextField(text: $emailOrPhone, placeholder: "Phone number (e.g. +15551234567)", systemImage: "phone.fill", keyboardType: .phonePad)
            } else {
                AuthTextField(text: $otpCode, placeholder: "6-digit code", systemImage: nil, keyboardType: .numberPad)
                Spacer().frame(height: MochiSpacing.sm)
                HStack {
                    Spacer()
                    Button("Change number") {
                        otpCode = ""
                        viewModel.resetPhoneFlow()
                    }
                    .font(MochiFont.caption(13))
                    .fontWeight(.semibold)
                    .foregroundStyle(Color(red: 0.565, green: 0.071, blue: 0.655))
                }
            }

            if let errorMessage = viewModel.uiState.errorMessage {
                Spacer().frame(height: MochiSpacing.sm)
                Text(errorMessage)
                    .font(MochiFont.caption(12))
                    .foregroundStyle(Color(red: 0.937, green: 0.267, blue: 0.267))
                    .multilineTextAlignment(.center)
            }

            if viewModel.uiState.resetEmailSent {
                Spacer().frame(height: MochiSpacing.sm)
                Text("Password reset email sent - check your inbox.")
                    .font(MochiFont.caption(12))
                    .foregroundStyle(Color(red: 0.063, green: 0.725, blue: 0.506))
                    .multilineTextAlignment(.center)
            }

            Spacer().frame(height: MochiSpacing.lg)
            primaryButton
            Spacer().frame(height: MochiSpacing.lg)
            divider
            Spacer().frame(height: MochiSpacing.lg)
            socialButtons
            Spacer().frame(height: MochiSpacing.xl)
            modeSwitcher
            Spacer().frame(height: MochiSpacing.md)
            methodSwitcher
        }
        .padding(.horizontal, MochiSpacing.lg)
        .padding(.top, MochiSpacing.sm)
        .padding(.bottom, MochiSpacing.lg)
    }

    private var emailFields: some View {
        VStack(spacing: MochiSpacing.md) {
            AuthTextField(text: $emailOrPhone, placeholder: "Email or Phone", systemImage: "person.fill", keyboardType: .emailAddress)

            AuthTextField(text: $password, placeholder: "Password", systemImage: "lock.fill", isSecure: !passwordVisible, trailing: {
                Button {
                    passwordVisible.toggle()
                } label: {
                    Image(systemName: passwordVisible ? "eye.fill" : "eye.slash.fill")
                        .foregroundStyle(Color(red: 0.612, green: 0.639, blue: 0.686))
                }
            })

            if mode == .signIn {
                HStack {
                    Spacer()
                    Button("Forgot Password?") {
                        if isMockMode {
                            viewModel.showNotice("Add GoogleService-Info.plist to enable password reset.")
                        } else if emailOrPhone.isEmpty {
                            viewModel.showNotice("Enter your email address first.")
                        } else {
                            viewModel.sendPasswordReset(emailOrPhone)
                        }
                    }
                    .font(MochiFont.caption(13))
                    .fontWeight(.semibold)
                    .foregroundStyle(Color(red: 0.565, green: 0.071, blue: 0.655))
                }
            }
        }
    }

    private var primaryButton: some View {
        Button {
            if isMockMode {
                onAuthenticated()
                return
            }
            guard !viewModel.uiState.isLoading else { return }
            switch (method, codeSent) {
            case (.phone, true):
                if otpCode.isEmpty {
                    viewModel.showNotice("Enter the code sent to your phone.")
                } else {
                    viewModel.verifyPhoneCode(otpCode, onSuccess: onAuthenticated)
                }
            case (.phone, false):
                if emailOrPhone.isEmpty {
                    viewModel.showNotice("Enter your phone number.")
                } else {
                    viewModel.sendPhoneCode(emailOrPhone)
                }
            case (.email, _):
                if emailOrPhone.isEmpty || password.isEmpty {
                    viewModel.showNotice("Enter both email/phone and password.")
                } else if mode == .signIn {
                    viewModel.signIn(email: emailOrPhone, password: password, onSuccess: onAuthenticated)
                } else {
                    viewModel.signUp(email: emailOrPhone, password: password, onSuccess: onAuthenticated)
                }
            }
        } label: {
            Text(primaryButtonTitle)
                .font(MochiFont.button(16))
                .fontWeight(.bold)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(Self.primaryButtonGradient)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(radius: 6, y: 3)
        }
    }

    private var primaryButtonTitle: String {
        if viewModel.uiState.isLoading { return "Please wait..." }
        switch (method, codeSent) {
        case (.phone, true): return "Verify Code"
        case (.phone, false): return "Send OTP"
        case (.email, _): return mode == .signIn ? "Login" : "Sign Up"
        }
    }

    private var divider: some View {
        HStack {
            Rectangle().fill(Color(red: 0.898, green: 0.906, blue: 0.922)).frame(height: 1)
            Text("or continue with")
                .font(MochiFont.caption(12))
                .foregroundStyle(Color(red: 0.612, green: 0.639, blue: 0.686))
                .padding(.horizontal, MochiSpacing.sm)
                .fixedSize()
            Rectangle().fill(Color(red: 0.898, green: 0.906, blue: 0.922)).frame(height: 1)
        }
    }

    private var socialButtons: some View {
        HStack(spacing: 18) {
            // Real Google Logo Button — matching Android's ic_google_logo
            SocialIconButton(action: {
                if isMockMode {
                    onAuthenticated()
                } else {
                    guard let viewController = UIApplication.topViewController() else {
                        viewModel.showNotice("Couldn't start Google Sign-In from this screen.")
                        return
                    }
                    viewModel.signInWithGoogle(presenting: viewController, onSuccess: onAuthenticated)
                }
            }) {
                Image("ic_google_logo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 28, height: 28)
            }

            // Real Apple Logo Button — matching Android's ic_apple_logo
            SocialIconButton(action: {
                if isMockMode {
                    onAuthenticated()
                } else {
                    guard let anchor = UIApplication.keyWindow() else {
                        viewModel.showNotice("Couldn't start Apple Sign-In from this screen.")
                        return
                    }
                    viewModel.signInWithApple(presentationAnchor: anchor, onSuccess: onAuthenticated)
                }
            }) {
                Image("ic_apple_logo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 28, height: 28)
            }
        }
    }

    private var modeSwitcher: some View {
        HStack(spacing: 0) {
            Text(mode == .signIn ? "Don't have an account? " : "Already have an account? ")
                .font(MochiFont.body(14))
                .foregroundStyle(Color(red: 0.42, green: 0.447, blue: 0.502))
            Button(mode == .signIn ? "Sign up" : "Sign in") {
                mode = mode == .signIn ? .signUp : .signIn
            }
            .font(MochiFont.button(14))
            .fontWeight(.bold)
            .foregroundStyle(Color(red: 0.565, green: 0.071, blue: 0.655))
        }
    }

    private var methodSwitcher: some View {
        Button(method == .email ? "Use phone number instead" : "Use email instead") {
            if method == .phone {
                otpCode = ""
                viewModel.resetPhoneFlow()
            }
            method = method == .email ? .phone : .email
        }
        .font(MochiFont.caption(13))
        .foregroundStyle(Color(red: 0.612, green: 0.639, blue: 0.686))
    }
}

// MARK: - Custom MochiTreeLogo — pixel-matched to Android's Canvas drawing

/// The little leaf/tree logo drawn by Android's MochiTreeLogo composable — a filled leaf shape with
/// a white trunk and branch. Drawn in Canvas rather than SF Symbols to match Android's exact shape.
private struct MochiTreeLogo: View {
    var tint: Color

    var body: some View {
        Canvas { context, size in
            let w = size.width
            let h = size.height

            // Leaf shape
            var path = Path()
            path.move(to: CGPoint(x: w * 0.5, y: h * 0.1))
            path.addCurve(
                to: CGPoint(x: w * 0.5, y: h * 0.72),
                control1: CGPoint(x: w * 0.15, y: h * 0.15),
                control2: CGPoint(x: w * 0.1, y: h * 0.55)
            )
            path.addCurve(
                to: CGPoint(x: w * 0.5, y: h * 0.1),
                control1: CGPoint(x: w * 0.9, y: h * 0.55),
                control2: CGPoint(x: w * 0.85, y: h * 0.15)
            )
            path.closeSubpath()
            context.fill(path, with: .color(tint))

            // Trunk line
            context.stroke(
                Path { p in
                    p.move(to: CGPoint(x: w * 0.5, y: h * 0.35))
                    p.addLine(to: CGPoint(x: w * 0.5, y: h * 0.65))
                },
                with: .color(.white),
                lineWidth: w * 0.08
            )

            // Branch line
            context.stroke(
                Path { p in
                    p.move(to: CGPoint(x: w * 0.5, y: h * 0.45))
                    p.addLine(to: CGPoint(x: w * 0.68, y: h * 0.35))
                },
                with: .color(.white),
                lineWidth: w * 0.07
            )
        }
    }
}

private struct WaveHeaderShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width
        let height = rect.height
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: 0, y: height * 0.78))
        path.addCurve(
            to: CGPoint(x: width, y: height * 0.88),
            control1: CGPoint(x: width * 0.35, y: height * 1.05),
            control2: CGPoint(x: width * 0.65, y: height * 0.65)
        )
        path.addLine(to: CGPoint(x: width, y: 0))
        path.closeSubpath()
        return path
    }
}

private struct AuthTextField<Trailing: View>: View {
    @Binding var text: String
    let placeholder: String
    var systemImage: String?
    var isSecure: Bool = false
    var keyboardType: UIKeyboardType = .default
    var trailing: () -> Trailing

    init(text: Binding<String>, placeholder: String, systemImage: String?, isSecure: Bool = false, keyboardType: UIKeyboardType = .default, @ViewBuilder trailing: @escaping () -> Trailing = { EmptyView() }) {
        self._text = text
        self.placeholder = placeholder
        self.systemImage = systemImage
        self.isSecure = isSecure
        self.keyboardType = keyboardType
        self.trailing = trailing
    }

    var body: some View {
        HStack(spacing: 12) {
            if let systemImage {
                Image(systemName: systemImage)
                    .foregroundStyle(Color(red: 0.565, green: 0.071, blue: 0.655))
                    .frame(width: 20)
            }
            Group {
                // Explicit grey prompt rather than the bare title string — the title inherits the
                // field's own foreground colour on some iOS versions and reads near-white here.
                let prompt = Text(placeholder).foregroundColor(MochiColor.textSecondary)
                if isSecure {
                    SecureField("", text: $text, prompt: prompt)
                } else {
                    TextField("", text: $text, prompt: prompt)
                }
            }
            .font(MochiFont.body(14))
            .keyboardType(keyboardType)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()

            trailing()
        }
        .padding(.horizontal, 16)
        .frame(height: 56)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color(red: 0.886, green: 0.910, blue: 0.941), lineWidth: 1))
    }
}

/// Social icon card — matches Android's SocialIconCard: bordered white rounded-rect with soft shadow.
private struct SocialIconButton<Content: View>: View {
    let action: () -> Void
    @ViewBuilder let content: () -> Content

    var body: some View {
        Button(action: action) {
            content()
                .frame(width: 76, height: 58)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 18))
                .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color(red: 0.886, green: 0.910, blue: 0.941), lineWidth: 1))
                .shadow(color: .black.opacity(0.06), radius: 3, y: 2)
        }
    }
}

extension UIApplication {
    static func keyWindow() -> UIWindow? {
        shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap(\.windows)
            .first(where: \.isKeyWindow)
    }

    static func topViewController(base: UIViewController? = UIApplication.keyWindow()?.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return topViewController(base: nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            return topViewController(base: tab.selectedViewController)
        }
        if let presented = base?.presentedViewController {
            return topViewController(base: presented)
        }
        return base
    }
}

#Preview {
    AuthView()
}
