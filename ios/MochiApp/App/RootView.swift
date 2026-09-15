import SwiftUI

/// The five-tab container. Every push (Theme Detail, Profile, Settings, Paywall, Leaderboard,
/// Wallpapers, Search) goes on the `NavigationStack` path owned by `AppRootView` — this view only
/// switches between the tabs and keeps `MochiTabBar` pinned over them, the same split Android's
/// `RootScreen` + `AppNavHost` uses.
struct RootView: View {
    @Binding var path: [AppRoute]
    /// Owned by `AppRootView` so a pushed screen (Search) can pop back to a specific tab / font.
    @Binding var selectedTab: MochiTab
    @Binding var fontsSelection: String

    var body: some View {
        // GeometryReader + an exact .frame(width:height:) rather than a greedy fill — the greedy
        // version let each page's own content influence how much size the Group claimed, which
        // shifted MochiTabBar's bottom alignment by ~17pt between pages.
        GeometryReader { geo in
            ZStack(alignment: .bottom) {
                Group {
                    switch selectedTab {
                    case .keyboard:
                        HomeView(
                            onThemeClick: { path.append(.themeDetail($0)) },
                            onGoToCreate: { selectedTab = .create },
                            onGoToThemes: { selectedTab = .themes },
                            onGoToFonts: { selectedTab = .fonts },
                            onFontClick: { fontsSelection = $0.id; selectedTab = .fonts }
                        )
                    case .fonts:
                        FontsView(
                            selectedFontID: $fontsSelection,
                            onOpenPaywall: { path.append(.paywall) },
                            onSeeAllDownloaded: { path.append(.downloadedFonts) }
                        )
                    case .create:
                        CreateThemeView(onBack: { selectedTab = .keyboard })
                    case .themes:
                        ThemesView(
                            onOpenSearch: { path.append(.search) },
                            onThemeClick: { path.append(.themeDetail($0)) },
                            onWallpapers: { path.append(.wallpapers) }
                        )
                    case .community:
                        CommunityView(
                            onOpenProfile: { path.append(.profile(uid: nil)) },
                            onThemeClick: { path.append(.themeDetail($0)) },
                            onCreatorClick: { path.append(.profile(uid: $0)) },
                            onLeaderboard: { path.append(.leaderboard) },
                            onSeeAllTopThemes: { path.append(.themeCollection(.topThemes)) },
                            onSeeAllLatest: { path.append(.themeCollection(.latest)) }
                        )
                    }
                }
                .frame(width: geo.size.width, height: geo.size.height)
                .ignoresSafeArea(edges: .bottom)

                MochiTabBar(selected: Binding(
                    get: { selectedTab },
                    set: { if let tab = $0 { selectedTab = tab } }
                ))
            }
        }
        .ignoresSafeArea(edges: .bottom)
    }
}

#Preview {
    RootView(path: .constant([]), selectedTab: .constant(.keyboard), fontsSelection: .constant("handwritten-elegant"))
}
