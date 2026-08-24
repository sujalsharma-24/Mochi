import Foundation

struct KeyboardTheme: Identifiable, Hashable {
    let id: String
    let name: String
    let creatorName: String
    let imageAssetName: String
    let likeCount: Int
    let isPremium: Bool
    let hashtags: [String]
    /// Empty for every MockData-sourced theme (only Firestore-backed themes carry real copy) — Theme
    /// Detail hides its description block when this is empty, matching Android's `isNotBlank()` guard.
    var description: String = ""
    /// Empty for every MockData-sourced theme — screens that offer a Follow action on the creator
    /// (Theme Detail's CreatorRow) must guard on this being non-empty before calling FollowRepository,
    /// same rule android/.../ThemeDetailScreen.kt's CreatorRow enforces.
    var creatorUid: String = ""
    var downloadCount: Int = 0

    var likeCountFormatted: String {
        likeCount.formattedCompact
    }
}

struct FontItem: Identifiable, Hashable {
    let id: String
    let name: String
    let styleDescription: String
    let isPremium: Bool
    /// The composed tile Home's font row uses — artwork with the font's name already burnt into
    /// the image.
    let previewAssetName: String
    /// The art-only tile the Fonts page uses. Separate from `previewAssetName` because that page
    /// sets the name as live text under the artwork, so it needs a crop with no lettering in it.
    let artAssetName: String
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

/// A creator tile in Community's "Popular Creators" row. Separate from `Creator` (the profile
/// model) because the tile shows a different, smaller slice — avatar, name, theme count and one
/// CTA — and because Figma gives the fourth tile the label "Choose" rather than "Follow", so the
/// CTA copy has to be data rather than a computed constant.
struct CommunityCreator: Identifiable, Hashable {
    let id: String
    let name: String
    let avatarAssetName: String
    let themeCount: Int
    let isVerified: Bool
    let ctaTitle: String
}

/// A row in Community's "Latest Creations" list. Carries its own wide (2.12:1) thumbnail asset
/// and hashtag palette, neither of which `KeyboardTheme` has: Figma tints each card's hashtag
/// chips differently (green / blue / peach) rather than using one shared chip style.
struct CommunityPost: Identifiable, Hashable {
    enum TagPalette { case green, blue, peach }

    let id: String
    let name: String
    let creatorName: String
    let thumbAssetName: String
    let summary: String
    let likeCount: Int
    let hashtags: [String]
    let tagPalette: TagPalette
}

extension Int {
    /// A trailing ".0" is dropped, because Figma drops it: the Themes grid sets Pastel Rainbow's
    /// count as "8K", not "8.0K", while every other count on the page keeps its tenth ("12.5K",
    /// "5.8K"). Every existing caller already passes a value with a non-zero tenth, so this only
    /// changes the whole-thousand case.
    var formattedCompact: String {
        switch self {
        case 1_000_000...:
            return Self.trimmed(Double(self) / 1_000_000) + "M"
        case 1_000...:
            return Self.trimmed(Double(self) / 1_000) + "K"
        default:
            return "\(self)"
        }
    }

    private static func trimmed(_ value: Double) -> String {
        let text = String(format: "%.1f", value)
        return text.hasSuffix(".0") ? String(text.dropLast(2)) : text
    }
}

// MARK: - Profile (docs/figma/3.png)

/// The signed-in user as the Profile frame presents them. Distinct from `Creator`, which models
/// *another* creator as Community's list shows them: this one carries a bio and the three-column
/// stat strip, neither of which a creator tile has, and its counts are pre-formatted strings
/// because Figma writes "2.4K" beside a bare "128" and "156" — one column is abbreviated and two
/// are not, which no single number formatter reproduces.
struct ProfileSummary {
    struct Stat: Hashable {
        let value: String
        let label: String
    }

    let displayName: String
    let handle: String
    let bio: String
    let avatarAssetName: String
    let isVerified: Bool
    let stats: [Stat]
}

/// One tile in MY CREATIONS or MY DOWNLOADS. `kind` is the purple line under the name ("Theme" /
/// "Font"), which the downloads strip does not show — it is simply unused there rather than
/// modelled separately, because the two strips are otherwise the same record.
struct ProfileCreation: Identifiable, Hashable {
    let id: String
    let name: String
    let kind: String
    let imageAssetName: String
    let likes: String
    let downloads: String
}

/// A row in the Liked Themes card. Counts stay strings for the reason `ProfileSummary` gives.
struct ProfileLikedTheme: Identifiable, Hashable {
    let id: String
    let name: String
    let creatorName: String
    let imageAssetName: String
    let likes: String
}

/// A row in the right-hand card (Followers / Following).
struct ProfileFollowRow: Identifiable, Hashable {
    let id: String
    let label: String
    let value: String
}
