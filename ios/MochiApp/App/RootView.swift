import SwiftUI

struct RootView: View {
    @State private var selected: MochiTab = .fonts
    /// Profile is not a tab — docs/figma/3.png draws it with a back button and with every tab in
    /// the bar unselected, i.e. as a screen pushed *over* the tabs. It is presented in their place
    /// and keeps the bar visible; picking any tab dismisses it.
    @State private var showProfile = false
    /// Theme Detail covers everything, including Profile, the same way Android's nav graph pushes
    /// `themeDetail/{themeId}` as its own destination rather than nesting it under a tab.
    @State private var selectedTheme: KeyboardTheme?

    var body: some View {
        // GeometryReader + an exact .frame(width:height:) rather than
        // .frame(maxWidth: .infinity, maxHeight: .infinity) — the greedy-fill version let each
        // page's own content (a ScrollView vs a plain VStack) influence how much size the Group
        // actually claimed, which shifted MochiTabBar's "alignment: .bottom" position by ~17pt
        // between pages. An explicit size removes that ambiguity so the bar sits identically on
        // every tab regardless of what that tab contains.
        GeometryReader { geo in
            ZStack(alignment: .bottom) {
                Group {
                    if let theme = selectedTheme {
                        ThemeDetailView(theme: theme, onBack: { selectedTheme = nil })
                    } else if showProfile {
                        ProfileView(onBack: { showProfile = false })
                    } else {
                        switch selected {
                        case .keyboard: HomeView(onThemeClick: { theme in selectedTheme = theme })
                        case .fonts: FontsView()
                        case .create: CreateThemeView()
                        case .themes: ThemesView()
                        case .community: CommunityView(onOpenProfile: { showProfile = true })
                        }
                    }
                }
                .frame(width: geo.size.width, height: geo.size.height)
                .ignoresSafeArea(edges: .bottom)

                if selectedTheme == nil {
                    MochiTabBar(selected: Binding(
                        get: { showProfile ? nil : selected },
                        set: { tab in
                            if let tab {
                                selected = tab
                                showProfile = false
                            }
                        }
                    ))
                }

            }
        }
        .ignoresSafeArea(edges: .bottom)
    }
}

#Preview {
    RootView()
}
