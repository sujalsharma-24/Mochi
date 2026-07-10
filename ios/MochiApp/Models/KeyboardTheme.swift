import Foundation

struct KeyboardTheme: Identifiable, Hashable {
    let id: String
    let name: String
    let creatorName: String
    let imageAssetName: String
    let likeCount: Int
    let isPremium: Bool
    let hashtags: [String]

    var likeCountFormatted: String {
        likeCount.formattedCompact
    }
}

struct FontItem: Identifiable, Hashable {
    let id: String
    let name: String
    let styleDescription: String
    let isPremium: Bool
    let previewAssetName: String
}

struct Creator: Identifiable, Hashable {
    let id: String
    let displayName: String
    let handle: String
    let avatarAssetName: String
    let themeCount: Int
    let likeCount: Int
    let isFollowing: Bool
    let isVerified: Bool
}

extension Int {
    var formattedCompact: String {
        switch self {
        case 1_000_000...:
            return String(format: "%.1fM", Double(self) / 1_000_000)
        case 1_000...:
            return String(format: "%.1fK", Double(self) / 1_000)
        default:
            return "\(self)"
        }
    }
}
