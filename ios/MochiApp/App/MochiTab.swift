import Foundation

enum MochiTab: String, CaseIterable, Identifiable {
    case keyboard
    case fonts
    case create
    case themes
    case community

    var id: String { rawValue }

    var title: String {
        switch self {
        case .keyboard: return "Keyboard"
        case .fonts: return "Fonts"
        case .create: return "Create"
        case .themes: return "Themes"
        case .community: return "Community"
        }
    }

    var systemImage: String {
        switch self {
        case .keyboard: return "keyboard.fill"
        case .fonts: return "textformat"
        case .create: return "wand.and.stars"
        case .themes: return "paintpalette.fill"
        case .community: return "person.3.fill"
        }
    }
}
