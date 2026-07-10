import SwiftUI

struct ThemesView: View {
    var body: some View {
        ZStack {
            MochiGradient.background.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: MochiSpacing.md) {
                    Text("Themes")
                        .font(MochiFont.title())
                        .foregroundStyle(MochiColor.textPrimary)
                    Text("Browse and apply beautiful themes")
                        .font(MochiFont.caption())
                        .foregroundStyle(MochiColor.textSecondary)

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: MochiSpacing.md) {
                        ForEach(MockData.allThemes) { theme in
                            ThemeCard(theme: theme)
                        }
                    }

                    Spacer(minLength: 90)
                }
                .padding(.horizontal, MochiSpacing.md)
                .padding(.top, MochiSpacing.md)
            }
        }
    }
}

#Preview {
    ThemesView()
}
