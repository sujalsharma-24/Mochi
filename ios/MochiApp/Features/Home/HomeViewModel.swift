import Foundation

enum HomeUiState {
    case loading
    case data(recentlyApplied: [KeyboardTheme], popular: [KeyboardTheme])
    case empty
    case error(String)
}

/// Swift mirror of android/.../features/home/HomeViewModel.kt — same Loading/Data/Empty/Error shape,
/// same MockData-fallback convention every other screen in this app follows (Loading/Error render
/// the existing mock content rather than a spinner/error view designed nowhere in the Figma export;
/// only a genuinely empty catalog shows real empty state).
@MainActor
final class HomeViewModel: ObservableObject {
    @Published private(set) var uiState: HomeUiState = .loading

    private let themeRepository: ThemeRepository?

    /// `nil` container (no GoogleService-Info.plist yet) means there's no real backend to query at
    /// all — same as every other screen, this degrades to permanently showing MockData rather than
    /// attempting a Firestore call that would crash without configuration.
    init(container: AppContainer?) {
        themeRepository = container?.themeRepository
        load()
    }

    func load() {
        guard let themeRepository else { return }
        uiState = .loading
        Task {
            do {
                async let recentlyAppliedTask = themeRepository.getPublishedThemes(limit: 3)
                async let popularTask = themeRepository.getTopRanked(limit: 10)
                let (recentlyApplied, popular) = try await (recentlyAppliedTask, popularTask)
                uiState = (recentlyApplied.isEmpty && popular.isEmpty)
                    ? .empty
                    : .data(recentlyApplied: recentlyApplied, popular: popular)
            } catch {
                uiState = .error(error.localizedDescription)
            }
        }
    }
}
