package com.mochi.keyboard.data

import com.mochi.keyboard.model.WallpaperCategory
import com.mochi.keyboard.model.WallpaperCollection
import com.mochi.keyboard.model.WallpaperCropAnchor
import com.mochi.keyboard.model.WallpaperBadge
import com.mochi.keyboard.model.WallpaperFilter
import com.mochi.keyboard.model.WallpaperItem

/**
 * Ported 1:1 from `ios/MochiApp/Data/WallpaperCatalog.swift` - the single source of truth for the
 * Wallpapers screen. A hand-written literal, one entry per `wallpaper_*` asset in
 * `res/drawable-nodpi`. `likeCount` / `badge` have no source of truth yet (same disclaimer iOS's own
 * file carries) - plausible constants, swap for real values once a backend lands.
 *
 * **No wallpaper appears twice on the discovery page.** Featured / Popular / Collections / Trending
 * draw from disjoint id lists. A collection's *members* may reach into those rows - that grouping is
 * only ever seen after tapping in - but a collection's cover never doubles as a Popular/Trending card.
 */
object WallpaperCatalog {

    val all: List<WallpaperItem> by lazy { cute + dark + nature + space + minimal + y2k }

    // Cute (10)
    private val cute = listOf(
        WallpaperItem("wallpaper_rooftop_kittens", "Rooftop Kittens", WallpaperCategory.CUTE, 15_300,
            cropAnchor = WallpaperCropAnchor.TOP,
            tagline = "Two curious kittens peeking over a sunlit, leaf-covered rooftop."),
        WallpaperItem("wallpaper_sleepy_panda_meadow", "Sleepy Panda Meadow", WallpaperCategory.CUTE, 13_500),
        WallpaperItem("wallpaper_sunset_cottage_lane", "Sunset Cottage Lane", WallpaperCategory.CUTE, 12_500),
        WallpaperItem("wallpaper_windowsill_nap", "Windowsill Nap", WallpaperCategory.CUTE, 10_800),
        WallpaperItem("wallpaper_meadow_picnic", "Meadow Picnic", WallpaperCategory.CUTE, 9_100),
        WallpaperItem("wallpaper_kitten_cloud_party", "Kitten Cloud Party", WallpaperCategory.CUTE, 8_500,
            cropAnchor = WallpaperCropAnchor.TOP),
        WallpaperItem("wallpaper_sunny_doorstep", "Sunny Doorstep", WallpaperCategory.CUTE, 7_100, badge = WallpaperBadge.NEW),
        WallpaperItem("wallpaper_postbox_peekaboo", "Postbox Peekaboo", WallpaperCategory.CUTE, 6_200,
            badge = WallpaperBadge.NEW, cropAnchor = WallpaperCropAnchor.TOP),
        WallpaperItem("wallpaper_dumpling_kitchen", "Dumpling Kitchen", WallpaperCategory.CUTE, 5_000, badge = WallpaperBadge.TRENDING),
        WallpaperItem("wallpaper_little_stone_bridge", "Little Stone Bridge", WallpaperCategory.CUTE, 4_500)
    )

    // Dark (15)
    private val dark = listOf(
        WallpaperItem("wallpaper_dark_01", "Midnight Desk", WallpaperCategory.DARK, 11_900),
        WallpaperItem("wallpaper_dark_02", "Crescent Clouds", WallpaperCategory.DARK, 14_100),
        WallpaperItem("wallpaper_dark_03", "Night Study Nook", WallpaperCategory.DARK, 10_400),
        WallpaperItem("wallpaper_dark_04", "City Lights Sleep", WallpaperCategory.DARK, 9_800),
        WallpaperItem("wallpaper_dark_05", "Moth & Magnolia", WallpaperCategory.DARK, 8_700),
        WallpaperItem("wallpaper_dark_06", "After Hours Cafe", WallpaperCategory.DARK, 7_600),
        WallpaperItem("wallpaper_dark_07", "Lantern Terrace", WallpaperCategory.DARK, 8_200),
        WallpaperItem("wallpaper_dark_08", "Night Lotus Pond", WallpaperCategory.DARK, 6_900),
        WallpaperItem("wallpaper_dark_09", "Vinyl & Candlelight", WallpaperCategory.DARK, 7_300),
        WallpaperItem("wallpaper_dark_10", "Moonlit Meadow", WallpaperCategory.DARK, 9_200),
        WallpaperItem("wallpaper_dark_11", "Warm Lamp Corner", WallpaperCategory.DARK, 6_400),
        WallpaperItem("wallpaper_dark_12", "Stargazer Van", WallpaperCategory.DARK, 12_700, badge = WallpaperBadge.TRENDING),
        WallpaperItem("wallpaper_dark_13", "Road to the Peak", WallpaperCategory.DARK, 10_100),
        WallpaperItem("wallpaper_dark_14", "Milky Way Meadow", WallpaperCategory.DARK, 16_200,
            tagline = "The Milky Way rising over a meadow of blue wildflowers and pines."),
        WallpaperItem("wallpaper_dark_15", "Silent Swan Lake", WallpaperCategory.DARK, 13_000)
    )

    // Nature (10)
    private val nature = listOf(
        WallpaperItem("wallpaper_nature_01", "Alpine Roadside", WallpaperCategory.NATURE, 12_100),
        WallpaperItem("wallpaper_nature_02", "Blossom Coast Path", WallpaperCategory.NATURE, 14_800),
        WallpaperItem("wallpaper_nature_03", "Torii Garden Walk", WallpaperCategory.NATURE, 11_500),
        WallpaperItem("wallpaper_nature_04", "Emerald River Boat", WallpaperCategory.NATURE, 15_600,
            tagline = "A little boat drifting down a clear emerald river under summer leaves."),
        WallpaperItem("wallpaper_nature_05", "Hydrangea Platform", WallpaperCategory.NATURE, 10_300),
        WallpaperItem("wallpaper_nature_06", "Crystal Creek", WallpaperCategory.NATURE, 9_400),
        WallpaperItem("wallpaper_nature_07", "Willow Lake", WallpaperCategory.NATURE, 8_800),
        WallpaperItem("wallpaper_nature_08", "Overgrown Carriage", WallpaperCategory.NATURE, 7_900, badge = WallpaperBadge.NEW),
        WallpaperItem("wallpaper_nature_09", "Above the Clouds", WallpaperCategory.NATURE, 13_200),
        WallpaperItem("wallpaper_nature_10", "Fuji Sunrise", WallpaperCategory.NATURE, 12_600)
    )

    // Space (14)
    private val space = listOf(
        WallpaperItem("wallpaper_space_01", "Orbital Station", WallpaperCategory.SPACE, 9_700),
        WallpaperItem("wallpaper_space_02", "Planet Parade", WallpaperCategory.SPACE, 11_300),
        WallpaperItem("wallpaper_space_03", "Liftoff", WallpaperCategory.SPACE, 10_600),
        WallpaperItem("wallpaper_space_04", "Ringed Horizon", WallpaperCategory.SPACE, 12_900),
        WallpaperItem("wallpaper_space_05", "Red Planet Dawn", WallpaperCategory.SPACE, 8_400),
        WallpaperItem("wallpaper_space_06", "Earthrise Field", WallpaperCategory.SPACE, 13_800),
        WallpaperItem("wallpaper_space_07", "Saturn Alone", WallpaperCategory.SPACE, 7_500),
        WallpaperItem("wallpaper_space_08", "Gas Giants", WallpaperCategory.SPACE, 9_100),
        WallpaperItem("wallpaper_space_09", "Saturn Shore", WallpaperCategory.SPACE, 11_800),
        WallpaperItem("wallpaper_space_10", "Jupiter Cliffs", WallpaperCategory.SPACE, 14_500,
            tagline = "A banded gas giant filling the sky above a lone figure on the cliffs."),
        WallpaperItem("wallpaper_space_11", "Moon Swing", WallpaperCategory.SPACE, 12_200, badge = WallpaperBadge.NEW),
        WallpaperItem("wallpaper_space_12", "Cosmic Cherries", WallpaperCategory.SPACE, 10_900),
        WallpaperItem("wallpaper_space_13", "Asteroid Observatory", WallpaperCategory.SPACE, 8_100),
        WallpaperItem("wallpaper_space_14", "Library in Orbit", WallpaperCategory.SPACE, 9_900)
    )

    // Minimal (16)
    private val minimal = listOf(
        WallpaperItem("wallpaper_minimal_01", "Grass Nap", WallpaperCategory.MINIMAL, 8_600),
        WallpaperItem("wallpaper_minimal_02", "Dare to Illuminate", WallpaperCategory.MINIMAL, 7_200),
        WallpaperItem("wallpaper_minimal_03", "Wake Up Terminal", WallpaperCategory.MINIMAL, 9_500),
        WallpaperItem("wallpaper_minimal_04", "Window Seat Earth", WallpaperCategory.MINIMAL, 11_100),
        WallpaperItem("wallpaper_minimal_05", "Pinch of Mochi", WallpaperCategory.MINIMAL, 13_400),
        WallpaperItem("wallpaper_minimal_06", "Blossom Sky", WallpaperCategory.MINIMAL, 12_000),
        WallpaperItem("wallpaper_minimal_07", "Dusk Ferris Wheel", WallpaperCategory.MINIMAL, 10_200),
        WallpaperItem("wallpaper_minimal_08", "Little Duck Heart", WallpaperCategory.MINIMAL, 11_700, badge = WallpaperBadge.NEW),
        WallpaperItem("wallpaper_minimal_09", "Hearts Pattern", WallpaperCategory.MINIMAL, 6_800),
        WallpaperItem("wallpaper_minimal_10", "Sakura Tram Stop", WallpaperCategory.MINIMAL, 10_700),
        WallpaperItem("wallpaper_minimal_11", "Pastel Cloud Drift", WallpaperCategory.MINIMAL, 14_300,
            tagline = "Soft pink clouds and a scatter of birds at the quiet end of the day."),
        WallpaperItem("wallpaper_minimal_12", "Time To Grow", WallpaperCategory.MINIMAL, 9_000),
        WallpaperItem("wallpaper_minimal_13", "Soft Heart Blur", WallpaperCategory.MINIMAL, 7_800),
        WallpaperItem("wallpaper_minimal_14", "Red Vinyl Spin", WallpaperCategory.MINIMAL, 8_300),
        WallpaperItem("wallpaper_minimal_15", "Tulip Kittens", WallpaperCategory.MINIMAL, 12_400),
        WallpaperItem("wallpaper_minimal_16", "Cow Print", WallpaperCategory.MINIMAL, 6_500)
    )

    // Y2K (10)
    private val y2k = listOf(
        WallpaperItem("wallpaper_y2k_01", "Lucky Eight", WallpaperCategory.Y2K, 10_500),
        WallpaperItem("wallpaper_y2k_02", "I Am Loved", WallpaperCategory.Y2K, 12_800),
        WallpaperItem("wallpaper_y2k_03", "Everything I Desire", WallpaperCategory.Y2K, 13_600),
        WallpaperItem("wallpaper_y2k_04", "Checker Stars", WallpaperCategory.Y2K, 15_000,
            tagline = "Pink and black checkerboard with glossy chrome stars - peak 2003."),
        WallpaperItem("wallpaper_y2k_05", "Bigger Dreams", WallpaperCategory.Y2K, 9_300),
        WallpaperItem("wallpaper_y2k_06", "Cherry Coke Club", WallpaperCategory.Y2K, 11_400, badge = WallpaperBadge.TRENDING),
        WallpaperItem("wallpaper_y2k_07", "Pink Disc Diary", WallpaperCategory.Y2K, 8_900),
        WallpaperItem("wallpaper_y2k_08", "Cherry Cherry Lady", WallpaperCategory.Y2K, 10_000),
        WallpaperItem("wallpaper_y2k_09", "Trust The Universe", WallpaperCategory.Y2K, 7_700),
        WallpaperItem("wallpaper_y2k_10", "Amor Amor Collage", WallpaperCategory.Y2K, 9_600)
    )

    // Curated rows

    /** The most-liked wallpaper from each of the six themes, so the row is a cross-section of the
     * catalogue rather than six near-identical cute cards. */
    private val popularIds = listOf(
        "wallpaper_sleepy_panda_meadow", "wallpaper_dark_02", "wallpaper_nature_02",
        "wallpaper_space_06", "wallpaper_minimal_05", "wallpaper_y2k_03",
        "wallpaper_sunset_cottage_lane", "wallpaper_dark_15", "wallpaper_nature_09",
        "wallpaper_space_04", "wallpaper_minimal_06", "wallpaper_y2k_02"
    )

    /** The badged wallpapers, opening on the NEW / NEW / TRENDING trio. */
    private val trendingIds = listOf(
        "wallpaper_sunny_doorstep", "wallpaper_postbox_peekaboo", "wallpaper_dumpling_kitchen",
        "wallpaper_space_11", "wallpaper_minimal_08", "wallpaper_nature_08",
        "wallpaper_dark_12", "wallpaper_y2k_06"
    )

    /** Curated sets for the Collections row. Each cover is a wallpaper not shown anywhere else on
     * the discovery page; members may reach into Popular/Trending for the collection's own page. */
    val collections = listOf(
        WallpaperCollection("collection_kitten_skies", "Kitten Skies", coverId = "wallpaper_kitten_cloud_party",
            memberIds = listOf("wallpaper_kitten_cloud_party", "wallpaper_rooftop_kittens",
                "wallpaper_postbox_peekaboo", "wallpaper_minimal_15", "wallpaper_windowsill_nap", "wallpaper_nature_08"),
            likeCount = 11_200),
        WallpaperCollection("collection_cozy_meadow", "Cozy Meadow", coverId = "wallpaper_meadow_picnic",
            memberIds = listOf("wallpaper_meadow_picnic", "wallpaper_sunset_cottage_lane",
                "wallpaper_sunny_doorstep", "wallpaper_nature_09", "wallpaper_minimal_01", "wallpaper_dark_10"),
            likeCount = 8_400),
        WallpaperCollection("collection_storybook_village", "Storybook Village", coverId = "wallpaper_little_stone_bridge",
            memberIds = listOf("wallpaper_little_stone_bridge", "wallpaper_windowsill_nap",
                "wallpaper_dumpling_kitchen", "wallpaper_nature_05", "wallpaper_nature_03", "wallpaper_dark_06"),
            likeCount = 6_700),
        WallpaperCollection("collection_deep_field", "Deep Field", coverId = "wallpaper_space_09",
            memberIds = listOf("wallpaper_space_09", "wallpaper_space_10", "wallpaper_space_02",
                "wallpaper_space_11", "wallpaper_dark_14", "wallpaper_space_14"),
            likeCount = 9_800),
        WallpaperCollection("collection_after_dark", "After Dark", coverId = "wallpaper_dark_09",
            memberIds = listOf("wallpaper_dark_09", "wallpaper_dark_01", "wallpaper_dark_03",
                "wallpaper_dark_11", "wallpaper_dark_06", "wallpaper_minimal_14"),
            likeCount = 7_300),
        WallpaperCollection("collection_sugar_rush", "Sugar Rush", coverId = "wallpaper_y2k_08",
            memberIds = listOf("wallpaper_y2k_08", "wallpaper_y2k_01", "wallpaper_y2k_06",
                "wallpaper_minimal_09", "wallpaper_minimal_13", "wallpaper_y2k_10"),
            likeCount = 10_600)
    )

    // Rows
    val popular: List<WallpaperItem> get() = popularIds.mapNotNull(::wallpaper)
    val trending: List<WallpaperItem> get() = trendingIds.mapNotNull(::wallpaper)

    // Lookups
    const val FEATURED_ID = "wallpaper_rooftop_kittens"
    val featured: WallpaperItem get() = wallpaper(FEATURED_ID) ?: all[0]

    private val byId: Map<String, WallpaperItem> by lazy { all.associateBy { it.id } }

    fun wallpaper(id: String): WallpaperItem? = byId[id]

    fun collection(id: String): WallpaperCollection? = collections.firstOrNull { it.id == id }

    fun members(of: WallpaperCollection): List<WallpaperItem> = of.memberIds.mapNotNull(::wallpaper)

    /** Every wallpaper in one theme, most-liked first - the whole body of a theme page. */
    fun wallpapers(inCategory: WallpaperCategory): List<WallpaperItem> =
        all.filter { it.category == inCategory }.sortedByDescending { it.likeCount }

    /** The grid contents for a rail/chip selection. */
    fun wallpapers(matching: WallpaperFilter): List<WallpaperItem> = when (matching) {
        WallpaperFilter.ALL, WallpaperFilter.MORE, WallpaperFilter.COMMUNITY -> all
        WallpaperFilter.POPULAR -> all.sortedByDescending { it.likeCount }
        WallpaperFilter.LATEST -> all.reversed()
        else -> matching.category?.let(::wallpapers) ?: all
    }

    /** Name / theme substring match, used by the pane's search field. */
    fun search(query: String): List<WallpaperItem> {
        val q = query.trim().lowercase()
        if (q.isEmpty()) return all
        return all.filter { it.name.lowercase().contains(q) || it.category.title.lowercase().contains(q) }
    }
}
