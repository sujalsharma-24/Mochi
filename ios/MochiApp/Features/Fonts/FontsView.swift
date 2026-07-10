import SwiftUI

struct FontsView: View {
    var body: some View {
        ZStack {
            MochiGradient.background.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: MochiSpacing.md) {
                    Text("Fonts")
                        .font(MochiFont.title())
                        .foregroundStyle(MochiColor.textPrimary)
                    Text("Choose the perfect font for your keyboard")
                        .font(MochiFont.caption())
                        .foregroundStyle(MochiColor.textSecondary)

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: MochiSpacing.md) {
                        ForEach(MockData.fonts) { font in
                            VStack(spacing: 6) {
                                Text("Aa")
                                    .font(.system(size: 40, weight: .heavy, design: .rounded))
                                    .foregroundStyle(MochiColor.purple)
                                Text(font.name)
                                    .font(MochiFont.heading(14))
                                Text(font.isPremium ? "Pro" : "Free")
                                    .font(MochiFont.caption(11))
                                    .foregroundStyle(font.isPremium ? MochiColor.premiumTag : MochiColor.freeTag)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, MochiSpacing.lg)
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: MochiRadius.card, style: .continuous))
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
    FontsView()
}
