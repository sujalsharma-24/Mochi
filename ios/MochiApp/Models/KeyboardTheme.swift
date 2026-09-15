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
    /// Which pill this theme sits under on the Themes screen. Drives the category filter there.
    /// Defaulted (rather than required) so Firestore-backed themes and published custom themes,
    /// which carry no category yet, keep decoding and simply land in `.other` until one is assigned.
    /// Appended last so every existing labelled `KeyboardTheme(...)` call site keeps compiling.
    var category: ThemeCategory = .other
    /// Editorial ranking for the handful of themes showcased on Home, whose thumbnails are real
    /// composited-keyboard mockups rather than raw background plates. `nil` = not featured. The
    /// Themes grid's default ("Popular") sort floats these to the top in this order, ahead of the
    /// like-count ranking, so the first impression on that page matches Home's.
    var featuredRank: Int? = nil

    var likeCountFormatted: String {
        likeCount.formattedCompact
    }
}

/// The Themes screen's top category pills. `.all` is the pill that shows everything, so no theme is
/// ever assigned it. These replace the font-style labels the Figma frame copied from the Fonts
/// frame ("Handwritten" / "Bold" / "Minimal") with buckets that actually describe the built-in
/// theme catalogue — see `ThemeCatalog` for the per-theme assignment and why each label was chosen.
enum ThemeCategory: String, CaseIterable, Identifiable, Hashable {
    case all = "All", cute = "Cute", cozy = "Cozy", dreamy = "Dreamy"
    case nature = "Nature", elegant = "Elegant", space = "Space", other = "Other"
    var id: String { rawValue }
}

/// The Fonts screen's top category pills. `.all` is the pill that shows everything, so no
/// `FontItem` is ever assigned it. Cases and raw values match the pill labels in `FontsView`.
enum FontCategory: String, CaseIterable, Identifiable, Hashable {
    case all = "All", cute = "Cute", handwritten = "Handwritten", minimal = "Minimal"
    case bold = "Bold", elegant = "Elegant", other = "Other"
    var id: String { rawValue }
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
    /// Which category pill this style sits under on the Fonts screen. Drives the pill filter.
    var category: FontCategory = .other
    /// 1 = most popular. A hand-ranked placeholder until real apply/install telemetry exists —
    /// drives the Fonts screen's "Popular" sort. (There are no real dates, so "Newest" sorts by
    /// reverse position in `MockData.fontCollection` instead.)
    var popularityRank: Int = 99
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
    /// Up to 3 `theme_*` background plates shown as small previews on the Leaderboard row.
    /// Empty for callers that don't need them (e.g. Community's `topCreators` usage).
    var previewAssetNames: [String] = []
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

/// A row in Community's "Latest Creations" list. Carries its own wide (2.12:1) thumbnail asset,
/// which `KeyboardTheme` has no field for.
///
/// Chip tints are positional, not per-card: Figma gives every card the same green / blue / peach
/// run across its three hashtags, so the palette is chosen by the chip's index at render time
/// (`CommunityView.tagPalette(at:)`) rather than carried on the post.
struct CommunityPost: Identifiable, Hashable {
    enum TagPalette { case green, blue, peach }

    let id: String
    let name: String
    let creatorName: String
    let thumbAssetName: String
    let summary: String
    let likeCount: Int
    let hashtags: [String]
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
    /// The catalogue theme this tile shows, so tapping it opens that theme. `nil` for the Font tile,
    /// which has no theme behind it.
    var themeID: String?
    let name: String
    let kind: String
    let imageAssetName: String
    let likes: String
    let downloads: String
}

/// A row in the Liked Themes card. Counts stay strings for the reason `ProfileSummary` gives.
struct ProfileLikedTheme: Identifiable, Hashable {
    let id: String
    /// The catalogue theme this row shows, so tapping it opens that theme.
    var themeID: String?
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

// `WallpaperItem` / `WallpaperCategory` moved to `Models/Wallpaper.swift` — they back the
// Wallpapers screen and never had anything to do with keyboard themes.
