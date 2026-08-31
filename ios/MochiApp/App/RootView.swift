import SwiftUI

/// The five-tab container. Every push (Theme Detail, Profile, Settings, Paywall, Leaderboard,
/// Wallpapers, Search) goes on the `NavigationStack` path owned by `AppRootView` — this view only
/// switches between the tabs and keeps `MochiTabBar` pinned over them, the same split Android's
/// `RootScreen` + `AppNavHost` uses.
struct RootView: View {
    @Binding var path: [AppRoute]
    @State private var selected: MochiTab = .fonts

    var body: some View {
        // GeometryReader + an exact .frame(width:height:) rather than a greedy fill — the greedy
        // version let each page's own content influence how much size the Group claimed, which
        // shifted MochiTabBar's bottom alignment by ~17pt between pages.
        GeometryReader { geo in
            ZStack(alignment: .bottom) {
                Group {
                    switch selected {
                    case .keyboard:
                        HomeView(
                            onThemeClick: { path.append(.themeDetail($0)) },
                            onGoToCreate: { selected = .create },
                            onGoToThemes: { selected = .themes },
                            onGoToFonts: { selected = .fonts }
                        )
                    case .fonts:
                        FontsView()
                    case .create:
                        CreateThemeView()
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
                            onLeaderboard: { path.append(.leaderboard) }
                        )
                    }
                }
                .frame(width: geo.size.width, height: geo.size.height)
                .ignoresSafeArea(edges: .bottom)

                MochiTabBar(selected: Binding(
                    get: { selected },
                    set: { if let tab = $0 { selected = tab } }
                ))
            }
        }
        .ignoresSafeArea(edges: .bottom)
    }
}

#Preview {
    RootView(path: .constant([]))
}
