import SwiftUI

struct CreateThemeView: View {
    private enum CreateTab: String, CaseIterable { case background = "Background", keys = "Keys", fonts = "Fonts", effect = "Effect" }
    @State private var selectedTab: CreateTab = .background

    var body: some View {
        ZStack {
            MochiGradient.background.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: MochiSpacing.md) {
                    Text("Create Custom Theme")
                        .font(MochiFont.title())
                        .foregroundStyle(MochiColor.textPrimary)
                    Text("Design your own keyboard theme")
                        .font(MochiFont.caption())
                        .foregroundStyle(MochiColor.textSecondary)

                    KeyboardPreviewPlaceholder(seed: "live-preview")
                        .frame(height: 220)

                    tabSelector

                    tabContent

                    HStack(spacing: MochiSpacing.md) {
                        OutlineButton(title: "Save Draft") {}
                        GradientButton(title: "Publish Theme", systemImage: "paperplane.fill") {}
                    }

                    Spacer(minLength: 90)
                }
                .padding(.horizontal, MochiSpacing.md)
                .padding(.top, MochiSpacing.md)
            }
        }
    }

    private var tabSelector: some View {
        HStack(spacing: MochiSpacing.sm) {
            ForEach(CreateTab.allCases, id: \.self) { tab in
                Button {
                    selectedTab = tab
                } label: {
                    Text(tab.rawValue)
                        .font(MochiFont.button(13))
                        .foregroundStyle(selectedTab == tab ? .white : MochiColor.textPrimary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(selectedTab == tab ? AnyShapeStyle(MochiGradient.primaryButton) : AnyShapeStyle(Color.white))
                        .clipShape(Capsule())
                }
            }
        }
    }

    @ViewBuilder
    private var tabContent: some View {
        switch selectedTab {
        case .background: backgroundTab
        case .keys: keysTab
        case .fonts: fontsTab
        case .effect: effectTab
        }
    }

    private var swatchColors: [Color] = [MochiColor.lavender, MochiColor.pinkLight, MochiColor.purple, .black, .orange]

    private var backgroundTab: some View {
        VStack(alignment: .leading, spacing: MochiSpacing.md) {
            Text("BACKGROUND").font(MochiFont.heading(13))
            HStack(spacing: MochiSpacing.sm) {
                ForEach(Array(swatchColors.enumerated()), id: \.offset) { _, color in
                    Circle().fill(color).frame(width: 40, height: 40)
                        .overlay(Circle().stroke(.white, lineWidth: 2))
                }
            }
        }
        .padding(MochiSpacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: MochiRadius.card, style: .continuous))
    }

    private var keysTab: some View {
        VStack(alignment: .leading, spacing: MochiSpacing.md) {
            Text("KEY SHAPE").font(MochiFont.heading(13))
            HStack(spacing: MochiSpacing.sm) {
                ForEach(["square", "rectangle.roundedbottom", "circle", "hexagon"], id: \.self) { shape in
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(MochiColor.purple.opacity(0.4), lineWidth: 1)
                        .frame(width: 44, height: 44)
                        .overlay(Image(systemName: shape).foregroundStyle(MochiColor.purple))
                }
            }
        }
        .padding(MochiSpacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: MochiRadius.card, style: .continuous))
    }

    private var fontsTab: some View {
        VStack(alignment: .leading, spacing: MochiSpacing.md) {
            Text("FONT STYLE").font(MochiFont.heading(13))
            HStack(spacing: MochiSpacing.sm) {
                ForEach(MockData.fonts.prefix(4)) { font in
                    Text("Aa")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .frame(width: 50, height: 44)
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
        }
        .padding(MochiSpacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: MochiRadius.card, style: .continuous))
    }

    private var effectTab: some View {
        VStack(alignment: .leading, spacing: MochiSpacing.md) {
            Text("KEY-PRESS EFFECTS").font(MochiFont.heading(13))
            HStack(spacing: MochiSpacing.sm) {
                ForEach(["sparkles", "heart.fill", "circle.dashed", "moon.stars.fill"], id: \.self) { icon in
                    Image(systemName: icon)
                        .foregroundStyle(MochiColor.purple)
                        .frame(width: 44, height: 44)
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
            Text("Free plan includes Ripple only. Upgrade for all effects.")
                .font(MochiFont.caption(12))
                .foregroundStyle(MochiColor.textSecondary)
        }
        .padding(MochiSpacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: MochiRadius.card, style: .continuous))
    }
}

#Preview {
    CreateThemeView()
}
