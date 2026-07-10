import SwiftUI

struct RootView: View {
    @State private var selected: MochiTab = .keyboard

    var body: some View {
        ZStack(alignment: .bottom) {
            Group {
                switch selected {
                case .keyboard: HomeView()
                case .fonts: FontsView()
                case .create: CreateThemeView()
                case .themes: ThemesView()
                case .community: CommunityView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .ignoresSafeArea(edges: .bottom)

            MochiTabBar(selected: $selected)
        }
    }
}

#Preview {
    RootView()
}
