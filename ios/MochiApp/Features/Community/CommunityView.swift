import SwiftUI

struct CommunityView: View {
    private enum FeedTab: String, CaseIterable { case forYou = "For You", popular = "Popular", latest = "Latest", following = "Following", myLikes = "My Likes" }
    @State private var selectedTab: FeedTab = .forYou

    var body: some View {
        ZStack {
            MochiGradient.background.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: MochiSpacing.md) {
                    Text("Mochi")
                        .font(MochiFont.logo(28))
                        .foregroundStyle(MochiGradient.logoText)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: MochiSpacing.sm) {
                            ForEach(FeedTab.allCases, id: \.self) { tab in
                                Button {
                                    selectedTab = tab
                                } label: {
                                    Text(tab.rawValue)
                                        .font(MochiFont.button(14))
                                        .foregroundStyle(selectedTab == tab ? .white : MochiColor.textPrimary)
                                        .padding(.horizontal, MochiSpacing.md)
                                        .padding(.vertical, 10)
                                        .background(selectedTab == tab ? AnyShapeStyle(MochiGradient.primaryButton) : AnyShapeStyle(Color.white))
                                        .clipShape(Capsule())
                                }
                            }
                        }
                    }

                    SectionHeader(title: "Top Themes") {}
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: MochiSpacing.md) {
                        ForEach(MockData.allThemes.prefix(4)) { theme in
                            ThemeCard(theme: theme)
                        }
                    }

                    SectionHeader(title: "Popular Creators") {}
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: MochiSpacing.md) {
                            ForEach(MockData.topCreators) { creator in
                                VStack(spacing: 6) {
                                    Circle()
                                        .fill(MochiGradient.primaryButton)
                                        .frame(width: 56, height: 56)
                                        .overlay(Text(String(creator.displayName.prefix(1))).foregroundStyle(.white).font(MochiFont.heading()))
                                    Text(creator.displayName)
                                        .font(MochiFont.heading(12))
                                        .lineLimit(1)
                                    Text("\(creator.themeCount) Themes")
                                        .font(MochiFont.caption(10))
                                        .foregroundStyle(MochiColor.textSecondary)
                                }
                                .frame(width: 100)
                            }
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
    CommunityView()
}
