import Foundation

enum ThemesUiState {
    case loading
    case data([KeyboardTheme])
    case empty
    case error(String)
}

/// Swift mirror of android/.../features/themes/ThemesViewModel.kt — same Loading/Data/Empty/Error
/// shape and the same "any non-Data state falls back to MockData" convention ThemesScreen.kt uses
/// (unlike Home, which shows a real empty row for `.empty` — Themes always shows *something*).
@MainActor
final class ThemesViewModel: ObservableObject {
    @Published private(set) var uiState: ThemesUiState = .loading

    private let themeRepository: ThemeRepository?

    /// `nil` container (no GoogleService-Info.plist yet) means there's no real backend to query —
    /// same as every other screen, this degrades to permanently showing MockData.
    init(container: AppContainer?) {
        themeRepository = container?.themeRepository
        load()
    }

    func load() {
        guard let themeRepository else { return }
        uiState = .loading
        Task {
            do {
                let themes = try await themeRepository.getPublishedThemes(limit: 30)
                uiState = themes.isEmpty ? .empty : .data(themes)
            } catch {
                uiState = .error(error.localizedDescription)
            }
        }
    }
}
