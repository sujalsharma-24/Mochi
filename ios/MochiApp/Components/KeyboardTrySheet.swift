import SwiftUI

/// A bottom sheet that drops the **real** Mochi keyboard on screen for a marketplace theme and lets
/// the user type on it. Same `KeyboardTestBench` / `KeyboardSurfaceView` / `KeyboardInputEngine` the
/// shipping extension runs — nothing here is a mock of the keyboard.
///
/// Presented from Theme Detail (and the Themes grid's Preview) as the payoff of tapping a theme:
/// "Apply" opens it with the applied banner, "Preview" opens it without.
struct KeyboardTrySheet: View {
    let marketplaceTheme: KeyboardTheme
    /// `true` when reached via Apply — shows the confirmation banner.
    var applied: Bool = false

    @Environment(\.dismiss) private var dismiss
    @State private var typedText = ""

    private var resolved: RenderableTheme.Resolved {
        RenderableTheme.resolve(for: marketplaceTheme)
    }

    var body: some View {
        VStack(spacing: 0) {
            handle

            if applied {
                banner(
                    icon: "checkmark.circle.fill",
                    tint: MochiColor.purple,
                    text: "“\(marketplaceTheme.name)” is now your Mochi keyboard."
                )
            }

            if !resolved.isExact {
                banner(
                    icon: "paintbrush.pointed.fill",
                    tint: MochiColor.textSecondary,
                    text: "Preview shown with a matching Mochi theme — this design’s own artwork is still in production."
                )
            }

            typedField

            Spacer(minLength: 8)

            GeometryReader { proxy in
                KeyboardTestBench(theme: resolved.theme, typedText: $typedText)
                    .frame(
                        width: proxy.size.width,
                        height: KeyboardTestBench.preferredHeight(
                            for: resolved.theme,
                            width: proxy.size.width
                        )
                    )
            }
            .frame(height: KeyboardTestBench.preferredHeight(
                for: resolved.theme,
                width: UIScreen.main.bounds.width
            ))
        }
        .background(Color(white: 0.10).ignoresSafeArea())
    }

    private var handle: some View {
        ZStack {
            Capsule()
                .fill(Color.white.opacity(0.25))
                .frame(width: 40, height: 5)
            HStack {
                Spacer()
                Button("Done") { dismiss() }
                    .font(MochiFont.button(15))
                    .foregroundStyle(.white)
            }
        }
        .padding(.horizontal, MochiSpacing.md)
        .padding(.top, 10)
        .padding(.bottom, 6)
    }

    private func banner(icon: String, tint: Color, text: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon).foregroundStyle(tint)
            Text(text)
                .font(MochiFont.caption(12))
                .foregroundStyle(.white.opacity(0.85))
                .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: 0)
        }
        .padding(.horizontal, MochiSpacing.md)
        .padding(.vertical, 8)
    }

    private var typedField: some View {
        Text(typedText.isEmpty ? "Tap the keys to try this theme…" : typedText)
            .font(.system(size: 17))
            .foregroundStyle(typedText.isEmpty ? .white.opacity(0.35) : .white)
            .frame(maxWidth: .infinity, minHeight: 56, alignment: .topLeading)
            .padding(12)
            .background(Color.white.opacity(0.07), in: RoundedRectangle(cornerRadius: 12))
            .padding(.horizontal, MochiSpacing.md)
            .padding(.top, 6)
    }
}
