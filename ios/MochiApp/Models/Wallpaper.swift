import SwiftUI

// MARK: - Wallpapers (docs/figma/10.png)

/// The wallpaper "themes" section. Figma frame 10 draws this at phone width as a fixed left nav
/// rail + a content pane with three card rows (Popular / Collections / Trending). It is a distinct
/// area from keyboard themes — wallpaper art the user browses, keeps and applies — so it has its
/// own model and catalogue rather than reusing `KeyboardTheme`.

/// A wallpaper's single real category — one per bundled art folder under `~/Desktop/Wallpaper`.
/// `popular` / `latest` are *not* categories — they're views onto the whole set (see
/// `WallpaperFilter`) — so they don't live here.
///
/// `gradient` used to sit here with no art behind it, which made its rail row a dead end. It was
/// replaced by `y2k`, which has 10 real wallpapers, so every row in the rail now reaches a real
/// page.
enum WallpaperCategory: String, CaseIterable, Identifiable, Hashable {
    case cute, dark, nature, space, minimal, y2k
    var id: String { rawValue }

    /// Page title / rail label.
    var title: String {
        switch self {
        case .y2k: return "Y2K"
        default:   return rawValue.prefix(1).uppercased() + rawValue.dropFirst()
        }
    }

    /// The wallpaper that heads this category's own page. Each theme gets art drawn from its own
    /// set, so "Cute" opens on a cute banner and "Dark" on a dark one.
    var bannerID: String {
        switch self {
        case .cute:    return "wallpaper_rooftop_kittens"
        case .dark:    return "wallpaper_dark_14"
        case .nature:  return "wallpaper_nature_04"
        case .space:   return "wallpaper_space_10"
        case .minimal: return "wallpaper_minimal_11"
        case .y2k:     return "wallpaper_y2k_04"
        }
    }

    /// The one-line blurb under the banner title on this category's page.
    var tagline: String {
        switch self {
        case .cute:    return "Soft, sunlit scenes with kittens, pandas and storybook cottages."
        case .dark:    return "Low-light rooms, moonlit roads and quiet skies for OLED screens."
        case .nature:  return "Rivers, blossom paths and mountain mornings, painted in daylight."
        case .space:   return "Ringed planets, launches and quiet orbits far above the noise."
        case .minimal: return "Pastel skies, single subjects and clean shapes that stay out of the way."
        case .y2k:     return "Glossy chrome, checkerboard and cherry-red nostalgia from the 2000s."
        }
    }
}

/// The corner badge on a Trending card (Figma: "NEW", "NEW", "TRENDING").
enum WallpaperBadge: String, Hashable {
    case new, trending
    var label: String { self == .new ? "NEW" : "TRENDING" }
}

/// The chip row (content pane) and the nav list (rail) in Figma are two controls over the same
/// axis, with slightly different case sets. This is their union — one selection drives both.
enum WallpaperFilter: String, CaseIterable, Identifiable, Hashable {
    case all, popular, latest, cute, dark, nature, space, minimal, y2k, more
    var id: String { rawValue }

    /// Rail label. The chip row uses `chipLabel`.
    var label: String {
        switch self {
        case .all: return "All Themes"
        default:   return chipLabel
        }
    }

    /// Content-pane chip label — always one word.
    var chipLabel: String {
        if let category { return category.title }
        return rawValue.prefix(1).uppercased() + rawValue.dropFirst()
    }

    /// The mark shown in the chip / beside the rail label. Six of these are the exact icons traced
    /// off Figma (bundled as `icon_filter_<name>_w`, purple #9C28B1 strokes on a transparent
    /// ground — see `FilterIcon`); the rest have no Figma-traced art yet, so they fall back to an
    /// SF Symbol that reads the same at a glance. `y2k` reuses the glyph that sat in its rail slot
    /// when that row was "Gradient", so the rail's silhouette is unchanged.
    var icon: FilterIconKind {
        switch self {
        case .all:     return .system("house.fill")
        case .popular: return .custom("icon_filter_popular_w")
        case .latest:  return .custom("icon_filter_latest_w")
        case .cute:    return .custom("icon_filter_cute_w")
        case .dark:    return .custom("icon_filter_dark_w")
        case .nature:  return .custom("icon_filter_nature_w")
        case .space:   return .custom("icon_filter_space_w")
        case .minimal: return .system("sparkle")
        case .y2k:     return .system("diamond.fill")
        case .more:    return .system("ellipsis")
        }
    }

    /// The real category this filter narrows to, or nil when it spans the whole set.
    var category: WallpaperCategory? { WallpaperCategory(rawValue: rawValue) }

    /// Cases shown as chips in the content pane (Figma: Popular/Latest/Cute/Dark/Nature/Space/More).
    static let chipCases: [WallpaperFilter] = [.popular, .latest, .cute, .dark, .nature, .space, .more]

    /// Cases shown in the rail nav list. Same eight rows Figma draws; the last theme row is Y2K
    /// rather than the art-less Gradient.
    static let railCases: [WallpaperFilter] = [.all, .cute, .dark, .nature, .space, .minimal, .y2k, .more]
}

/// One wallpaper in the catalogue.
struct WallpaperItem: Identifiable, Hashable {
    let id: String
    let name: String
    let category: WallpaperCategory
    /// Placeholder — carries the same disclaimer as `ThemeCatalog`: no source of truth until the
    /// backend lands. Drives the heart count shown on every card and the "Popular" ordering.
    let likeCount: Int
    /// Corner badge on the Trending row. Nil for everything not currently trending.
    var badge: WallpaperBadge? = nil
    /// Where a portrait 9:19.5 source sits inside a landscape crop. A few wallpapers put their
    /// subject in the top fifth of the frame (kittens on a roof / a ridge), so a centred crop
    /// would clip them — those are anchored `.top`.
    var cropAnchor: UnitPoint = .center
    /// One-line description, shown only on the featured banner. Nil for wallpapers that never take
    /// the featured slot — see `WallpaperCatalog.featuredID`.
    var tagline: String? = nil

    /// Bundled art key in `MochiApp/Assets.xcassets`; equals `id` by convention.
    var assetName: String { id }

    /// "12.5K" for four digits and up, plain otherwise. Figma is internally inconsistent
    /// ("12.5K" vs "13.5k"); normalised to uppercase K here.
    var likeCountText: String {
        guard likeCount >= 1000 else { return "\(likeCount)" }
        return String(format: "%.1fK", Double(likeCount) / 1000)
    }
}

enum FilterIconKind {
    case system(String)
    case custom(String)
}

/// Renders a `WallpaperFilter.icon` at a given size, tinted `color` — an SF Symbol via
/// `Image(systemName:)`, or one of the Figma-traced marks via `.renderingMode(.template)` so the
/// same tint applies either way (`.custom` assets are transparent-background, single-colour
/// #9C28B1 strokes, drawn to be tinted like a symbol, not shown at their own fixed colour).
struct FilterIcon: View {
    let kind: FilterIconKind
    var size: CGFloat
    var color: Color

    var body: some View {
        switch kind {
        case .system(let name):
            Image(systemName: name)
                .font(.system(size: size))
                .foregroundStyle(color)
        case .custom(let name):
            Image(name)
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .frame(width: size * 1.6, height: size * 1.6)
                .foregroundStyle(color)
        }
    }
}

/// A curated set for the Collections row. No new art — the cover is one member's existing asset.
struct WallpaperCollection: Identifiable, Hashable {
    let id: String
    let name: String
    let coverID: String
    let memberIDs: [String]
    /// Placeholder, same disclaimer as `WallpaperItem.likeCount`.
    let likeCount: Int

    var likeCountText: String {
        guard likeCount >= 1000 else { return "\(likeCount)" }
        return String(format: "%.1fK", Double(likeCount) / 1000)
    }
}

// MARK: - In-screen navigation

/// Which content the Wallpapers pane is showing. The rail, the search bar and the chip row are the
/// same on every one of these — only the pane's body changes — which is what makes moving between
/// them read as one screen rather than a stack of pushed views.
enum WallpaperPage: Hashable {
    /// "All Themes": the discovery page — featured banner, Popular / Collections / Trending.
    case discover
    /// One theme's own page: that theme's banner, then only that theme's wallpapers.
    case theme(WallpaperCategory)
    /// A "see all" destination for one of the discovery rows.
    case section(WallpaperSection)
    /// One collection's members.
    case collection(String)

    var title: String {
        switch self {
        case .discover:          return "All Themes"
        case .theme(let c):      return c.title
        case .section(let s):    return s.title
        case .collection(let id):
            return WallpaperCatalog.collections.first { $0.id == id }?.name ?? "Collection"
        }
    }
}

/// The discovery rows that have their own "see all" page.
enum WallpaperSection: String, Hashable, CaseIterable {
    case popular, collections, trending, downloads

    /// Heading as drawn on the discovery page (and at the top of the section's own page).
    var title: String {
        switch self {
        case .popular:     return "POPULAR THEMES"
        case .collections: return "COLLECTIONS"
        case .trending:    return "TRENDING NOW"
        case .downloads:   return "MY DOWNLOADS"
        }
    }
}
