import SwiftUI

struct HomeView: View {
    @State private var libraryTab: LibraryTab = .themes

    private enum LibraryTab { case fonts, themes }

    var body: some View {
        ZStack(alignment: .top) {
            MochiGradient.background.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: MochiSpacing.lg) {
                    header

                    recentlyAppliedRow

                    quickActionCards

                    libraryToggle

                    SectionHeader(title: "Popular Themes") {}
                    themesRow(MockData.popularThemes)

                    SectionHeader(title: "Font Collection") {}
                    fontsRow(MockData.fonts)

                    Spacer(minLength: 90)
                }
                .padding(.horizontal, MochiSpacing.md)
                .padding(.top, MochiSpacing.md)
            }
        }
    }

    private var header: some View {
        HStack {
            Text("Mochi")
                .font(MochiFont.logo())
                .foregroundStyle(MochiGradient.logoText)

            Spacer()

            VStack(spacing: 4) {
                ZStack {
                    Circle()
                        .fill(MochiGradient.primaryButton)
                        .frame(width: 44, height: 44)
                    Image(systemName: "plus.rectangle.on.folder.fill")
                        .foregroundStyle(.white)
                        .font(.system(size: 18))
                }
                Text("Create Custom")
                    .font(MochiFont.caption(11))
                    .foregroundStyle(MochiColor.textPrimary)
            }
        }
    }

    private var recentlyAppliedRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: MochiSpacing.md) {
                ForEach(MockData.popularThemes) { theme in
                    VStack(spacing: MochiSpacing.sm) {
                        KeyboardPreviewPlaceholder(seed: theme.id)
                            .frame(width: 150, height: 130)
                        Text(theme.name)
                            .font(MochiFont.body(13))
                            .foregroundStyle(MochiColor.textPrimary)
                            .multilineTextAlignment(.center)
                            .frame(width: 150)
                    }
                }
            }
        }
    }

    private var quickActionCards: some View {
        HStack(spacing: MochiSpacing.md) {
            actionCard(
                icon: "paintpalette.fill",
                title: "Custom Create",
                subtitle: "Design your own keyboard",
                buttonTitle: "Create"
            )
            actionCard(
                icon: "square.stack.fill",
                title: "Choose from Library",
                subtitle: "Pick a created keyboard",
                buttonTitle: "Choose"
            )
        }
    }

    private func actionCard(icon: String, title: String, subtitle: String, buttonTitle: String) -> some View {
        VStack(alignment: .leading, spacing: MochiSpacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 26))
                .foregroundStyle(MochiColor.purple)
            Text(title)
                .font(MochiFont.heading(15))
                .foregroundStyle(MochiColor.textPrimary)
            Text(subtitle)
                .font(MochiFont.caption(12))
                .foregroundStyle(MochiColor.textSecondary)
                .fixedSize(horizontal: false, vertical: true)

            GradientButton(title: buttonTitle) {}
        }
        .padding(MochiSpacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: MochiRadius.card, style: .continuous))
    }

    private var libraryToggle: some View {
        HStack(spacing: MochiSpacing.sm) {
            toggleButton(title: "Fonts", tab: .fonts)
            toggleButton(title: "Themes", tab: .themes)
        }
    }

    private func toggleButton(title: String, tab: LibraryTab) -> some View {
        Button {
            libraryTab = tab
        } label: {
            Text(title)
                .font(MochiFont.button())
                .foregroundStyle(libraryTab == tab ? .white : MochiColor.textPrimary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(libraryTab == tab ? AnyShapeStyle(MochiGradient.primaryButton) : AnyShapeStyle(Color.white))
                .clipShape(Capsule())
        }
    }

    private func themesRow(_ themes: [KeyboardTheme]) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: MochiSpacing.md) {
                ForEach(themes) { theme in
                    ThemeCard(theme: theme)
                        .frame(width: 150)
                }
            }
        }
    }

    private func fontsRow(_ fonts: [FontItem]) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: MochiSpacing.md) {
                ForEach(fonts) { font in
                    VStack(spacing: 6) {
                        Text("Aa")
                            .font(.system(size: 34, weight: .heavy, design: .rounded))
                            .foregroundStyle(MochiColor.purple)
                        Text(font.name)
                            .font(MochiFont.heading(13))
                            .foregroundStyle(MochiColor.textPrimary)
                        Text(font.styleDescription)
                            .font(MochiFont.caption(11))
                            .foregroundStyle(MochiColor.textSecondary)
                    }
                    .frame(width: 120, height: 130)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: MochiRadius.card, style: .continuous))
                }
            }
        }
    }
}

#Preview {
    HomeView()
}
