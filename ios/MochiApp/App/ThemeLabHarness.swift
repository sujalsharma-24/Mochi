import SwiftUI

/// A DEBUG-only screen for exercising the keyboard without installing the extension, enabling it
/// in Settings, and finding a text field.
///
/// It exists because that loop is slow enough that people stop doing it, and a keyboard whose
/// typing behaviour nobody exercises drifts immediately. Reached by launching with
/// `-MochiThemeLab 1`, so it costs the shipping app nothing but a compile in Debug.
///
/// The keyboard here is the production `KeyboardSurfaceView` driven by the production
/// `KeyboardInputEngine` — the only thing swapped out is the document being typed into.
#if DEBUG
struct ThemeLabHarness: View {
    static var isEnabled: Bool {
        UserDefaults.standard.bool(forKey: "MochiThemeLab")
    }

    /// `-MochiThemeLabPlane emoji|numbers|symbols`. Only reason this exists is command-line
    /// screenshots: there is no way to tap the emoji key from `simctl`.
    static var initialPlane: KeyboardPlane {
        guard let raw = UserDefaults.standard.string(forKey: "MochiThemeLabPlane") else { return .letters }
        return KeyboardPlane(rawValue: raw) ?? .letters
    }

    /// `-MochiThemeLabMode tweak` opens the illustration placement lab instead of the typing bench.
    /// A launch argument rather than an in-app toggle because the two are different jobs — one is
    /// "does typing work", the other is "does the art sit right" — and a control that switches
    /// between them costs space on a screen whose whole bottom half has to be the keyboard.
    static var isArtTweakMode: Bool {
        UserDefaults.standard.string(forKey: "MochiThemeLabMode") == "tweak"
    }

    @State private var typedText = ""
    /// `-MochiThemeLabTheme <id-suffix>` picks which built-in theme to exercise.
    private var theme: MochiKeyboardTheme {
        let wanted = UserDefaults.standard.string(forKey: "MochiThemeLabTheme") ?? ""
        return BuiltInThemes.all.first { $0.id.hasSuffix(wanted) && !wanted.isEmpty }
            ?? BuiltInThemes.default
    }

    private var report: ThemeValidator.Report { ThemeValidator.validate(theme) }

    var body: some View {
        if Self.isArtTweakMode {
            ArtTweakLab(theme: theme)
        } else {
            typingBench
        }
    }

    private var typingBench: some View {
        VStack(spacing: 0) {
            header
            typedOutput
            Spacer(minLength: 0)
            GeometryReader { proxy in
                KeyboardTestBench(theme: theme, typedText: $typedText, initialPlane: Self.initialPlane)
                    .frame(
                        width: proxy.size.width,
                        height: KeyboardTestBench.preferredHeight(for: theme, width: proxy.size.width)
                    )
            }
            .frame(height: KeyboardTestBench.preferredHeight(
                for: theme,
                width: UIScreen.main.bounds.width
            ))
        }
        .background(Color(white: 0.11).ignoresSafeArea())
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(theme.name)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(.white)
                Spacer()
                Text(report.isPublishable ? "AA ✓" : "\(report.errors.count) errors")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(report.isPublishable ? Color.green : Color.red)
            }

            // Printed beside the render so the numbers that justify each colour stay visible —
            // it is what stops someone "improving" a value that was chosen to clear a threshold.
            ForEach(KeyRole.allCases, id: \.self) { role in
                let style = theme.style(for: role)
                let backdrop = theme.surface.effectiveKeyBackdrop
                let cap = style.fill.contrastRepresentative.composited(over: backdrop)
                let label = style.labelColor.composited(over: cap)
                Text(String(
                    format: "%-7@ label %.2f:1   cap %.2f:1",
                    role.rawValue as NSString,
                    label.contrastRatio(against: cap),
                    cap.contrastRatio(against: backdrop)
                ))
                .font(.system(size: 10, design: .monospaced))
                .foregroundStyle(.white.opacity(0.6))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 16)
        .padding(.top, 12)
    }

    /// What has been typed, plus a reminder of the behaviours worth poking at. Both matter: the
    /// text proves insertion works, and the checklist is what stops a manual test from only ever
    /// exercising the letter keys.
    private var typedOutput: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(typedText.isEmpty ? "Type something…" : typedText)
                .font(.system(size: 17))
                .foregroundStyle(typedText.isEmpty ? .white.opacity(0.3) : .white)
                .frame(maxWidth: .infinity, minHeight: 54, alignment: .topLeading)
                .padding(10)
                .background(Color.white.opacity(0.07), in: RoundedRectangle(cornerRadius: 10))

            Text("""
                try: hold a vowel for accents · double-tap shift for caps lock · \
                hold ⌫ to repeat · double-space for a period · 😀 for emoji
                """)
                .font(.system(size: 10))
                .foregroundStyle(.white.opacity(0.45))
        }
        .padding(.horizontal, 16)
        .padding(.top, 10)
    }
}
#endif
