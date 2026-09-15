import Foundation

/// The wallpaper catalogue — the single source of truth for the Wallpapers screen.
///
/// A hand-written literal, one entry per `wallpaper_*` imageset in `MochiApp/Assets.xcassets`.
/// Unlike `ThemeCatalog` (which *derives* from `BuiltInThemes.all` and so needs a side `Meta`
/// map), nothing generates wallpapers, so `likeCount` / `badge` sit inline on each entry rather
/// than splitting one source of truth into two.
///
/// **What is placeholder here** — same disclaimer `ThemeCatalog` carries: `likeCount` and `badge`
/// have no source of truth yet. The numbers are plausible constants; `likeCount` doubles as the
/// "Popular" sort key so it does one real job. Swap for real values once the backend lands.
///
/// **Art provenance.** 75 wallpapers across six themes, ingested from `~/Desktop/Wallpaper/<Theme>`
/// as `wallpaper_<theme>_<nn>.imageset` (JPEG, long edge capped at 1600px — they are browsed as
/// thumbnails and previewed at most 2622px tall on a 3× phone, so the full-res PNGs were ~10×
/// larger than anything the screen can show). The ten `cute` entries predate that pass and keep
/// their original descriptive ids.
///
/// **No wallpaper appears twice on the discovery page.** Featured / Popular / Collections /
/// Trending draw from disjoint id lists, so scrolling the page never shows one photo twice. A
/// collection's *members* may reach into those rows — that grouping is only ever seen after
/// tapping in — but a collection's cover never doubles as a Popular/Trending card.
///
/// **Adding wallpapers later:** drop the art in as `wallpaper_<slug>.imageset`, add a line below,
/// and add its id to whichever curated list(s) it belongs on. A theme page needs no wiring at all
/// — it renders every entry whose `category` matches.
enum WallpaperCatalog {

    static let all: [WallpaperItem] = cute + dark + nature + space + minimal + y2k

    // MARK: Cute (10)

    private static let cute: [WallpaperItem] = [
        WallpaperItem(id: "wallpaper_rooftop_kittens", name: "Rooftop Kittens", category: .cute,
                      likeCount: 15_300, cropAnchor: .top,
                      tagline: "Two curious kittens peeking over a sunlit, leaf-covered rooftop."),
        WallpaperItem(id: "wallpaper_sleepy_panda_meadow", name: "Sleepy Panda Meadow", category: .cute,
                      likeCount: 13_500),
        WallpaperItem(id: "wallpaper_sunset_cottage_lane", name: "Sunset Cottage Lane", category: .cute,
                      likeCount: 12_500),
        WallpaperItem(id: "wallpaper_windowsill_nap", name: "Windowsill Nap", category: .cute,
                      likeCount: 10_800),
        WallpaperItem(id: "wallpaper_meadow_picnic", name: "Meadow Picnic", category: .cute,
                      likeCount: 9_100),
        WallpaperItem(id: "wallpaper_kitten_cloud_party", name: "Kitten Cloud Party", category: .cute,
                      likeCount: 8_500, cropAnchor: .top),
        WallpaperItem(id: "wallpaper_sunny_doorstep", name: "Sunny Doorstep", category: .cute,
                      likeCount: 7_100, badge: .new),
        WallpaperItem(id: "wallpaper_postbox_peekaboo", name: "Postbox Peekaboo", category: .cute,
                      likeCount: 6_200, badge: .new, cropAnchor: .top),
        WallpaperItem(id: "wallpaper_dumpling_kitchen", name: "Dumpling Kitchen", category: .cute,
                      likeCount: 5_000, badge: .trending),
        WallpaperItem(id: "wallpaper_little_stone_bridge", name: "Little Stone Bridge", category: .cute,
                      likeCount: 4_500)
    ]

    // MARK: Dark (15)

    private static let dark: [WallpaperItem] = [
        WallpaperItem(id: "wallpaper_dark_01", name: "Midnight Desk", category: .dark, likeCount: 11_900),
        WallpaperItem(id: "wallpaper_dark_02", name: "Crescent Clouds", category: .dark, likeCount: 14_100),
        WallpaperItem(id: "wallpaper_dark_03", name: "Night Study Nook", category: .dark, likeCount: 10_400),
        WallpaperItem(id: "wallpaper_dark_04", name: "City Lights Sleep", category: .dark, likeCount: 9_800),
        WallpaperItem(id: "wallpaper_dark_05", name: "Moth & Magnolia", category: .dark, likeCount: 8_700),
        WallpaperItem(id: "wallpaper_dark_06", name: "After Hours Cafe", category: .dark, likeCount: 7_600),
        WallpaperItem(id: "wallpaper_dark_07", name: "Lantern Terrace", category: .dark, likeCount: 8_200),
        WallpaperItem(id: "wallpaper_dark_08", name: "Night Lotus Pond", category: .dark, likeCount: 6_900),
        WallpaperItem(id: "wallpaper_dark_09", name: "Vinyl & Candlelight", category: .dark, likeCount: 7_300),
        WallpaperItem(id: "wallpaper_dark_10", name: "Moonlit Meadow", category: .dark, likeCount: 9_200),
        WallpaperItem(id: "wallpaper_dark_11", name: "Warm Lamp Corner", category: .dark, likeCount: 6_400),
        WallpaperItem(id: "wallpaper_dark_12", name: "Stargazer Van", category: .dark, likeCount: 12_700, badge: .trending),
        WallpaperItem(id: "wallpaper_dark_13", name: "Road to the Peak", category: .dark, likeCount: 10_100),
        WallpaperItem(id: "wallpaper_dark_14", name: "Milky Way Meadow", category: .dark, likeCount: 16_200,
                      tagline: "The Milky Way rising over a meadow of blue wildflowers and pines."),
        WallpaperItem(id: "wallpaper_dark_15", name: "Silent Swan Lake", category: .dark, likeCount: 13_000)
    ]

    // MARK: Nature (10)

    private static let nature: [WallpaperItem] = [
        WallpaperItem(id: "wallpaper_nature_01", name: "Alpine Roadside", category: .nature, likeCount: 12_100),
        WallpaperItem(id: "wallpaper_nature_02", name: "Blossom Coast Path", category: .nature, likeCount: 14_800),
        WallpaperItem(id: "wallpaper_nature_03", name: "Torii Garden Walk", category: .nature, likeCount: 11_500),
        WallpaperItem(id: "wallpaper_nature_04", name: "Emerald River Boat", category: .nature, likeCount: 15_600,
                      tagline: "A little boat drifting down a clear emerald river under summer leaves."),
        WallpaperItem(id: "wallpaper_nature_05", name: "Hydrangea Platform", category: .nature, likeCount: 10_300),
        WallpaperItem(id: "wallpaper_nature_06", name: "Crystal Creek", category: .nature, likeCount: 9_400),
        WallpaperItem(id: "wallpaper_nature_07", name: "Willow Lake", category: .nature, likeCount: 8_800),
        WallpaperItem(id: "wallpaper_nature_08", name: "Overgrown Carriage", category: .nature, likeCount: 7_900, badge: .new),
        WallpaperItem(id: "wallpaper_nature_09", name: "Above the Clouds", category: .nature, likeCount: 13_200),
        WallpaperItem(id: "wallpaper_nature_10", name: "Fuji Sunrise", category: .nature, likeCount: 12_600)
    ]

    // MARK: Space (14)

    private static let space: [WallpaperItem] = [
        WallpaperItem(id: "wallpaper_space_01", name: "Orbital Station", category: .space, likeCount: 9_700),
        WallpaperItem(id: "wallpaper_space_02", name: "Planet Parade", category: .space, likeCount: 11_300),
        WallpaperItem(id: "wallpaper_space_03", name: "Liftoff", category: .space, likeCount: 10_600),
        WallpaperItem(id: "wallpaper_space_04", name: "Ringed Horizon", category: .space, likeCount: 12_900),
        WallpaperItem(id: "wallpaper_space_05", name: "Red Planet Dawn", category: .space, likeCount: 8_400),
        WallpaperItem(id: "wallpaper_space_06", name: "Earthrise Field", category: .space, likeCount: 13_800),
        WallpaperItem(id: "wallpaper_space_07", name: "Saturn Alone", category: .space, likeCount: 7_500),
        WallpaperItem(id: "wallpaper_space_08", name: "Gas Giants", category: .space, likeCount: 9_100),
        WallpaperItem(id: "wallpaper_space_09", name: "Saturn Shore", category: .space, likeCount: 11_800),
        WallpaperItem(id: "wallpaper_space_10", name: "Jupiter Cliffs", category: .space, likeCount: 14_500,
                      tagline: "A banded gas giant filling the sky above a lone figure on the cliffs."),
        WallpaperItem(id: "wallpaper_space_11", name: "Moon Swing", category: .space, likeCount: 12_200, badge: .new),
        WallpaperItem(id: "wallpaper_space_12", name: "Cosmic Cherries", category: .space, likeCount: 10_900),
        WallpaperItem(id: "wallpaper_space_13", name: "Asteroid Observatory", category: .space, likeCount: 8_100),
        WallpaperItem(id: "wallpaper_space_14", name: "Library in Orbit", category: .space, likeCount: 9_900)
    ]

    // MARK: Minimal (16)

    private static let minimal: [WallpaperItem] = [
        WallpaperItem(id: "wallpaper_minimal_01", name: "Grass Nap", category: .minimal, likeCount: 8_600),
        WallpaperItem(id: "wallpaper_minimal_02", name: "Dare to Illuminate", category: .minimal, likeCount: 7_200),
        WallpaperItem(id: "wallpaper_minimal_03", name: "Wake Up Terminal", category: .minimal, likeCount: 9_500),
        WallpaperItem(id: "wallpaper_minimal_04", name: "Window Seat Earth", category: .minimal, likeCount: 11_100),
        WallpaperItem(id: "wallpaper_minimal_05", name: "Pinch of Mochi", category: .minimal, likeCount: 13_400),
        WallpaperItem(id: "wallpaper_minimal_06", name: "Blossom Sky", category: .minimal, likeCount: 12_000),
        WallpaperItem(id: "wallpaper_minimal_07", name: "Dusk Ferris Wheel", category: .minimal, likeCount: 10_200),
        WallpaperItem(id: "wallpaper_minimal_08", name: "Little Duck Heart", category: .minimal, likeCount: 11_700, badge: .new),
        WallpaperItem(id: "wallpaper_minimal_09", name: "Hearts Pattern", category: .minimal, likeCount: 6_800),
        WallpaperItem(id: "wallpaper_minimal_10", name: "Sakura Tram Stop", category: .minimal, likeCount: 10_700),
        WallpaperItem(id: "wallpaper_minimal_11", name: "Pastel Cloud Drift", category: .minimal, likeCount: 14_300,
                      tagline: "Soft pink clouds and a scatter of birds at the quiet end of the day."),
        WallpaperItem(id: "wallpaper_minimal_12", name: "Time To Grow", category: .minimal, likeCount: 9_000),
        WallpaperItem(id: "wallpaper_minimal_13", name: "Soft Heart Blur", category: .minimal, likeCount: 7_800),
        WallpaperItem(id: "wallpaper_minimal_14", name: "Red Vinyl Spin", category: .minimal, likeCount: 8_300),
        WallpaperItem(id: "wallpaper_minimal_15", name: "Tulip Kittens", category: .minimal, likeCount: 12_400),
        WallpaperItem(id: "wallpaper_minimal_16", name: "Cow Print", category: .minimal, likeCount: 6_500)
    ]

    // MARK: Y2K (10)

    private static let y2k: [WallpaperItem] = [
        WallpaperItem(id: "wallpaper_y2k_01", name: "Lucky Eight", category: .y2k, likeCount: 10_500),
        WallpaperItem(id: "wallpaper_y2k_02", name: "I Am Loved", category: .y2k, likeCount: 12_800),
        WallpaperItem(id: "wallpaper_y2k_03", name: "Everything I Desire", category: .y2k, likeCount: 13_600),
        WallpaperItem(id: "wallpaper_y2k_04", name: "Checker Stars", category: .y2k, likeCount: 15_000,
                      tagline: "Pink and black checkerboard with glossy chrome stars — peak 2003."),
        WallpaperItem(id: "wallpaper_y2k_05", name: "Bigger Dreams", category: .y2k, likeCount: 9_300),
        WallpaperItem(id: "wallpaper_y2k_06", name: "Cherry Coke Club", category: .y2k, likeCount: 11_400, badge: .trending),
        WallpaperItem(id: "wallpaper_y2k_07", name: "Pink Disc Diary", category: .y2k, likeCount: 8_900),
        WallpaperItem(id: "wallpaper_y2k_08", name: "Cherry Cherry Lady", category: .y2k, likeCount: 10_000),
        WallpaperItem(id: "wallpaper_y2k_09", name: "Trust The Universe", category: .y2k, likeCount: 7_700),
        WallpaperItem(id: "wallpaper_y2k_10", name: "Amor Amor Collage", category: .y2k, likeCount: 9_600)
    ]

    // MARK: Curated rows

    /// POPULAR THEMES — the most-liked wallpaper from each of the six themes, so the row is a
    /// cross-section of the catalogue rather than six near-identical cute cards. Excludes the
    /// featured banner and every Collections cover / Trending card.
    private static let popularIDs = [
        "wallpaper_sleepy_panda_meadow", "wallpaper_dark_02", "wallpaper_nature_02",
        "wallpaper_space_06", "wallpaper_minimal_05", "wallpaper_y2k_03",
        "wallpaper_sunset_cottage_lane", "wallpaper_dark_15", "wallpaper_nature_09",
        "wallpaper_space_04", "wallpaper_minimal_06", "wallpaper_y2k_02"
    ]

    /// TRENDING NOW — the badged wallpapers, opening on the NEW / NEW / TRENDING trio Figma draws.
    private static let trendingIDs = [
        "wallpaper_sunny_doorstep", "wallpaper_postbox_peekaboo", "wallpaper_dumpling_kitchen",
        "wallpaper_space_11", "wallpaper_minimal_08", "wallpaper_nature_08",
        "wallpaper_dark_12", "wallpaper_y2k_06"
    ]

    /// Curated sets for the Collections row. Each cover is a wallpaper not shown anywhere else on
    /// the discovery page; members may reach into Popular/Trending for the collection's own page.
    static let collections: [WallpaperCollection] = [
        WallpaperCollection(id: "collection_kitten_skies", name: "Kitten Skies",
                            coverID: "wallpaper_kitten_cloud_party",
                            memberIDs: ["wallpaper_kitten_cloud_party", "wallpaper_rooftop_kittens",
                                        "wallpaper_postbox_peekaboo", "wallpaper_minimal_15",
                                        "wallpaper_windowsill_nap", "wallpaper_nature_08"],
                            likeCount: 11_200),
        WallpaperCollection(id: "collection_cozy_meadow", name: "Cozy Meadow",
                            coverID: "wallpaper_meadow_picnic",
                            memberIDs: ["wallpaper_meadow_picnic", "wallpaper_sunset_cottage_lane",
                                        "wallpaper_sunny_doorstep", "wallpaper_nature_09",
                                        "wallpaper_minimal_01", "wallpaper_dark_10"],
                            likeCount: 8_400),
        WallpaperCollection(id: "collection_storybook_village", name: "Storybook Village",
                            coverID: "wallpaper_little_stone_bridge",
                            memberIDs: ["wallpaper_little_stone_bridge", "wallpaper_windowsill_nap",
                                        "wallpaper_dumpling_kitchen", "wallpaper_nature_05",
                                        "wallpaper_nature_03", "wallpaper_dark_06"],
                            likeCount: 6_700),
        WallpaperCollection(id: "collection_deep_field", name: "Deep Field",
                            coverID: "wallpaper_space_09",
                            memberIDs: ["wallpaper_space_09", "wallpaper_space_10", "wallpaper_space_02",
                                        "wallpaper_space_11", "wallpaper_dark_14", "wallpaper_space_14"],
                            likeCount: 9_800),
        WallpaperCollection(id: "collection_after_dark", name: "After Dark",
                            coverID: "wallpaper_dark_09",
                            memberIDs: ["wallpaper_dark_09", "wallpaper_dark_01", "wallpaper_dark_03",
                                        "wallpaper_dark_11", "wallpaper_dark_06", "wallpaper_minimal_14"],
                            likeCount: 7_300),
        WallpaperCollection(id: "collection_sugar_rush", name: "Sugar Rush",
                            coverID: "wallpaper_y2k_08",
                            memberIDs: ["wallpaper_y2k_08", "wallpaper_y2k_01", "wallpaper_y2k_06",
                                        "wallpaper_minimal_09", "wallpaper_minimal_13", "wallpaper_y2k_10"],
                            likeCount: 10_600)
    ]

    // MARK: Rows

    static var popular: [WallpaperItem] { popularIDs.compactMap(wallpaper(id:)) }
    static var trending: [WallpaperItem] { trendingIDs.compactMap(wallpaper(id:)) }

    // MARK: Lookups

    static let featuredID = "wallpaper_rooftop_kittens"

    static var featured: WallpaperItem { wallpaper(id: featuredID) ?? all[0] }

    private static let byID: [String: WallpaperItem] =
        Dictionary(uniqueKeysWithValues: all.map { ($0.id, $0) })

    static func wallpaper(id: String) -> WallpaperItem? { byID[id] }

    static func collection(id: String) -> WallpaperCollection? {
        collections.first { $0.id == id }
    }

    static func members(of collection: WallpaperCollection) -> [WallpaperItem] {
        collection.memberIDs.compactMap(wallpaper(id:))
    }

    /// Every wallpaper in one theme, most-liked first — the whole body of a theme page.
    static func wallpapers(in category: WallpaperCategory) -> [WallpaperItem] {
        all.filter { $0.category == category }.sorted { $0.likeCount > $1.likeCount }
    }

    /// The grid contents for a rail/chip selection.
    static func wallpapers(matching filter: WallpaperFilter) -> [WallpaperItem] {
        switch filter {
        case .all, .more:  return all
        case .popular:     return all.sorted { $0.likeCount > $1.likeCount }
        case .latest:      return all.reversed()
        default:
            guard let category = filter.category else { return all }
            return wallpapers(in: category)
        }
    }

    /// Name / theme substring match, used by the pane's search field.
    static func search(_ query: String) -> [WallpaperItem] {
        let q = query.lowercased()
        guard !q.isEmpty else { return all }
        return all.filter {
            $0.name.lowercased().contains(q) || $0.category.title.lowercased().contains(q)
        }
    }
}
