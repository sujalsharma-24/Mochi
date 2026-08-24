import SwiftUI

/// Port of android/.../features/onboarding/OnboardingScreen.kt's SplashScreen — no Figma source
/// exists for this screen (see [[project-mochi-decisions]]'s Figma Ground Truth note), so this
/// follows Android's already-designed version rather than inventing a second one.
struct SplashView: View {
    var onTimeout: () -> Void = {}

    @State private var scale: CGFloat = 0.95

    var body: some View {
        ZStack {
            MochiGradient.background.ignoresSafeArea()
            VStack(spacing: MochiSpacing.sm) {
                Text("Mochi")
                    .font(MochiFont.logo(56))
                    .foregroundStyle(MochiColor.logoSolid)
                    .scaleEffect(scale)
                Text("Type with personality")
                    .font(MochiFont.body(15))
                    .foregroundStyle(MochiColor.textSecondary)
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.1).repeatForever(autoreverses: true)) {
                scale = 1.05
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                onTimeout()
            }
        }
    }
}

private struct OnboardingPageData: Identifiable {
    let id = UUID()
    let imageAssetName: String
    let title: String
    let body: String
    let badgeText: String
}

private let onboardingPages: [OnboardingPageData] = [
    OnboardingPageData(
        imageAssetName: "onboarding_themes",
        title: "Discover Beautiful Themes",
        body: "Browse 250+ handcrafted keyboard themes, from cozy pastels to bold neon and animated styles.",
        badgeText: "250+ THEMES"
    ),
    OnboardingPageData(
        imageAssetName: "onboarding_fonts",
        title: "Express Yourself With Fonts",
        body: "Type in playful custom fonts that make every chat, bio, and caption feel uniquely yours.",
        badgeText: "CUSTOM FONTS"
    ),
    OnboardingPageData(
        imageAssetName: "onboarding_create",
        title: "Create & Share Studio",
        body: "Design your own custom keyboard with wallpapers, key shapes, fonts, and share with the community.",
        badgeText: "DIY CREATOR"
    ),
    OnboardingPageData(
        imageAssetName: "onboarding_setup",
        title: "Enable Mochi Keyboard",
        body: "One quick step so Mochi can replace your default system keyboard and unlock full customization.",
        badgeText: "EASY SETUP"
    )
]

struct OnboardingView: View {
    var onFinished: () -> Void = {}

    @State private var currentPage = 0

    private var isLastPage: Bool { currentPage == onboardingPages.count - 1 }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.980, green: 0.961, blue: 1.0),
                    Color(red: 0.953, green: 0.910, blue: 1.0),
                    Color(red: 0.929, green: 0.914, blue: 0.988)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                HStack {
                    Text("Mochi")
                        .font(MochiFont.logo(28))
                        .foregroundStyle(Color(red: 0.486, green: 0.227, blue: 0.929))

                    Spacer()

                    if !isLastPage {
                        Button {
                            withAnimation { currentPage = onboardingPages.count - 1 }
                        } label: {
                            Text("Skip")
                                .font(MochiFont.button(14))
                                .foregroundStyle(Color(red: 0.545, green: 0.361, blue: 0.965))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                        }
                    }
                }
                .frame(height: 48)
                .padding(.horizontal, MochiSpacing.lg)

                Spacer(minLength: MochiSpacing.sm)

                TabView(selection: $currentPage) {
                    ForEach(Array(onboardingPages.enumerated()), id: \.element.id) { index, page in
                        (index == onboardingPages.count - 1
                            ? AnyView(KeyboardSetupPage(page: page))
                            : AnyView(FeaturePage(page: page)))
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))

                Spacer(minLength: MochiSpacing.md)

                VStack(spacing: MochiSpacing.lg) {
                    PageIndicator(pageCount: onboardingPages.count, currentPage: currentPage)

                    Button {
                        if isLastPage {
                            onFinished()
                        } else {
                            withAnimation { currentPage += 1 }
                        }
                    } label: {
                        HStack(spacing: 8) {
                            Text(isLastPage ? "Get Started" : "Continue")
                                .font(MochiFont.button(16))
                                .fontWeight(.bold)
                            Image(systemName: "arrow.right")
                        }
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(
                            LinearGradient(
                                colors: [
                                    Color(red: 0.486, green: 0.227, blue: 0.929),
                                    Color(red: 0.545, green: 0.361, blue: 0.965),
                                    Color(red: 0.925, green: 0.286, blue: 0.6)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 27))
                        .shadow(radius: 8, y: 4)
                    }
                }
                .padding(.horizontal, MochiSpacing.lg)
                .padding(.bottom, MochiSpacing.md)
            }
        }
    }
}

private struct FeaturePage: View {
    let page: OnboardingPageData

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            Badge(text: page.badgeText, textColor: Color(red: 0.486, green: 0.227, blue: 0.929), background: Color(red: 0.933, green: 0.914, blue: 0.996))

            Spacer().frame(height: MochiSpacing.md)

            HeroCard(assetName: page.imageAssetName, size: 270, borderColor: Color(red: 0.867, green: 0.839, blue: 0.996))

            Spacer().frame(height: MochiSpacing.xl)

            Text(page.title)
                .font(MochiFont.title(25))
                .fontWeight(.bold)
                .foregroundStyle(Color(red: 0.118, green: 0.106, blue: 0.294))
                .multilineTextAlignment(.center)

            Spacer().frame(height: MochiSpacing.sm)

            Text(page.body)
                .font(MochiFont.body(15))
                .foregroundStyle(Color(red: 0.42, green: 0.447, blue: 0.502))
                .multilineTextAlignment(.center)
                .padding(.horizontal, MochiSpacing.md)

            Spacer()
        }
        .padding(.horizontal, MochiSpacing.lg)
    }
}

private struct KeyboardSetupPage: View {
    let page: OnboardingPageData

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            Badge(text: page.badgeText, textColor: Color(red: 0.859, green: 0.153, blue: 0.467), background: Color(red: 0.988, green: 0.906, blue: 0.953))

            Spacer().frame(height: MochiSpacing.md)

            HeroCard(assetName: page.imageAssetName, size: 200, borderColor: Color(red: 0.984, green: 0.812, blue: 0.910))

            Spacer().frame(height: MochiSpacing.lg)

            Text(page.title)
                .font(MochiFont.title(24))
                .fontWeight(.bold)
                .foregroundStyle(Color(red: 0.118, green: 0.106, blue: 0.294))
                .multilineTextAlignment(.center)

            Spacer().frame(height: MochiSpacing.xs)

            Text(page.body)
                .font(MochiFont.body(14))
                .foregroundStyle(Color(red: 0.42, green: 0.447, blue: 0.502))
                .multilineTextAlignment(.center)
                .padding(.horizontal, MochiSpacing.md)

            Spacer().frame(height: MochiSpacing.md)

            VStack(alignment: .leading, spacing: MochiSpacing.sm) {
                InstructionStep(number: 1, text: "Open Settings → General → Keyboard")
                InstructionStep(number: 2, text: "Tap Keyboards → Add New Keyboard")
                InstructionStep(number: 3, text: "Enable Mochi and Allow Full Access")
            }
            .padding(MochiSpacing.md)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .shadow(color: .black.opacity(0.08), radius: 4, y: 2)

            Spacer()
        }
        .padding(.horizontal, MochiSpacing.lg)
    }
}

private struct Badge: View {
    let text: String
    let textColor: Color
    let background: Color

    var body: some View {
        Text(text)
            .font(MochiFont.caption(12))
            .fontWeight(.bold)
            .foregroundStyle(textColor)
            .padding(.horizontal, 14)
            .padding(.vertical, 6)
            .background(background)
            .clipShape(Capsule())
    }
}

private struct HeroCard: View {
    let assetName: String
    let size: CGFloat
    let borderColor: Color

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 32)
                .fill(Color.white)
                .overlay(RoundedRectangle(cornerRadius: 32).stroke(borderColor, lineWidth: 1.5))
                .shadow(color: .black.opacity(0.12), radius: 12, y: 6)

            if let uiImage = UIImage(named: assetName) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding(16)
            } else {
                Image(systemName: "sparkles")
                    .font(.system(size: size * 0.3))
                    .foregroundStyle(MochiColor.purple.opacity(0.5))
            }
        }
        .frame(width: size, height: size)
    }
}

private struct InstructionStep: View {
    let number: Int
    let text: String

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(LinearGradient(colors: [Color(red: 0.486, green: 0.227, blue: 0.929), Color(red: 0.925, green: 0.286, blue: 0.6)], startPoint: .leading, endPoint: .trailing))
                Text("\(number)")
                    .font(MochiFont.caption(12))
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
            }
            .frame(width: 26, height: 26)

            Text(text)
                .font(MochiFont.body(13))
                .fontWeight(.medium)
                .foregroundStyle(Color(red: 0.216, green: 0.255, blue: 0.318))
        }
    }
}

private struct PageIndicator: View {
    let pageCount: Int
    let currentPage: Int

    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<pageCount, id: \.self) { index in
                Capsule()
                    .fill(
                        index == currentPage
                            ? AnyShapeStyle(LinearGradient(colors: [Color(red: 0.486, green: 0.227, blue: 0.929), Color(red: 0.925, green: 0.286, blue: 0.6)], startPoint: .leading, endPoint: .trailing))
                            : AnyShapeStyle(Color(red: 0.796, green: 0.835, blue: 0.882))
                    )
                    .frame(width: index == currentPage ? 28 : 8, height: 8)
            }
        }
    }
}

#Preview {
    OnboardingView()
}
