package com.mochi.keyboard.model

/**
 * Ported from `ios/MochiApp/Models/Wallpaper.swift`. The wallpaper "themes" section - wallpaper art
 * the user browses, keeps and applies - is a distinct area from keyboard themes, so it has its own
 * model and catalogue rather than reusing [KeyboardTheme].
 */
enum class WallpaperCategory(val id: String) {
    CUTE("cute"), DARK("dark"), NATURE("nature"), SPACE("space"), MINIMAL("minimal"), Y2K("y2k");

    /** Page title / rail label. */
    val title: String
        get() = when (this) {
            Y2K -> "Y2K"
            else -> id.replaceFirstChar { it.uppercase() }
        }

    /** The wallpaper that heads this category's own page - each theme gets art drawn from its own
     * set, so "Cute" opens on a cute banner and "Dark" on a dark one. */
    val bannerId: String
        get() = when (this) {
            CUTE -> "wallpaper_rooftop_kittens"
            DARK -> "wallpaper_dark_14"
            NATURE -> "wallpaper_nature_04"
            SPACE -> "wallpaper_space_10"
            MINIMAL -> "wallpaper_minimal_11"
            Y2K -> "wallpaper_y2k_04"
        }

    /** The one-line blurb under the banner title on this category's page. */
    val tagline: String
        get() = when (this) {
            CUTE -> "Soft, sunlit scenes with kittens, pandas and storybook cottages."
            DARK -> "Low-light rooms, moonlit roads and quiet skies for OLED screens."
            NATURE -> "Rivers, blossom paths and mountain mornings, painted in daylight."
            SPACE -> "Ringed planets, launches and quiet orbits far above the noise."
            MINIMAL -> "Pastel skies, single subjects and clean shapes that stay out of the way."
            Y2K -> "Glossy chrome, checkerboard and cherry-red nostalgia from the 2000s."
        }

    companion object {
        fun fromId(id: String): WallpaperCategory? = entries.firstOrNull { it.id == id }
    }
}

/** The corner badge on a Trending card. */
enum class WallpaperBadge { NEW, TRENDING;
    val label: String get() = if (this == NEW) "NEW" else "TRENDING"
}

/** The chip row (content pane) and the nav list (rail) in Figma are two controls over the same
 * axis, with slightly different case sets - this is their union, one selection drives both. Also
 * folds in [COMMUNITY], the additive Android-only entry point to the existing live Firestore
 * wallpapers feature (WA4 slice 9) - iOS has nothing to fold in since it dropped Firestore
 * entirely, but that feature already works and is kept, not removed, same call Session 27 made for
 * Themes' built-in catalog vs. its existing Firestore-backed grid. */
enum class WallpaperFilter(val id: String) {
    ALL("all"), POPULAR("popular"), LATEST("latest"), CUTE("cute"), DARK("dark"), NATURE("nature"),
    SPACE("space"), MINIMAL("minimal"), Y2K("y2k"), COMMUNITY("community"), MORE("more");

    /** Rail label. The chip row uses [chipLabel]. */
    val label: String
        get() = if (this == ALL) "All Themes" else chipLabel

    /** Content-pane chip label - always one word. */
    val chipLabel: String
        get() = category?.title ?: when (this) {
            COMMUNITY -> "Community"
            else -> id.replaceFirstChar { it.uppercase() }
        }

    /** The Figma-traced `icon_filter_<name>_w` drawable this filter uses, or null to fall back to a
     * Material icon (mapped in the UI layer - see `WallpaperExploreScreen.kt`'s `FilterIcon`). */
    val iconDrawableName: String?
        get() = when (this) {
            POPULAR -> "icon_filter_popular_w"
            LATEST -> "icon_filter_latest_w"
            CUTE -> "icon_filter_cute_w"
            DARK -> "icon_filter_dark_w"
            NATURE -> "icon_filter_nature_w"
            SPACE -> "icon_filter_space_w"
            else -> null
        }

    /** The real category this filter narrows to, or null when it spans the whole set. */
    val category: WallpaperCategory? get() = WallpaperCategory.fromId(id)

    companion object {
        /** Cases shown as chips in the content pane. */
        val chipCases = listOf(POPULAR, LATEST, CUTE, DARK, NATURE, SPACE, COMMUNITY, MORE)

        /** Cases shown in the rail nav list. */
        val railCases = listOf(ALL, CUTE, DARK, NATURE, SPACE, MINIMAL, Y2K, COMMUNITY, MORE)
    }
}

/** Where a wallpaper's subject sits vertically, for cropping a portrait 9:19.5 source into a
 * landscape frame (thumbnails, banners). Mirrors iOS's `UnitPoint` usage, which only ever varies on
 * the y-axis in this catalogue (`.top` or `.center`, never `.bottom` or an x-offset). */
enum class WallpaperCropAnchor { TOP, CENTER }

/** One wallpaper in the catalogue. */
data class WallpaperItem(
    val id: String,
    val name: String,
    val category: WallpaperCategory,
    /** Placeholder - same disclaimer `KeyboardTheme.likeCount` carries: no source of truth until a
     * backend lands. Drives the heart count shown on every card and the "Popular" ordering. */
    val likeCount: Int,
    /** Corner badge on the Trending row. Null for everything not currently trending. */
    val badge: WallpaperBadge? = null,
    /** Where a portrait 9:19.5 source sits inside a landscape crop - a few wallpapers put their
     * subject in the top fifth of the frame, so a centred crop would clip them. */
    val cropAnchor: WallpaperCropAnchor = WallpaperCropAnchor.CENTER,
    /** One-line description, shown only on the featured banner. */
    val tagline: String? = null
) {
    /** Bundled art key in `res/drawable-nodpi`; equals [id] by convention. */
    val assetName: String get() = id

    val likeCountText: String get() = likeCount.formattedCompact()
}

/** A curated set for the Collections row. No new art - the cover is one member's existing asset. */
data class WallpaperCollection(
    val id: String,
    val name: String,
    val coverId: String,
    val memberIds: List<String>,
    val likeCount: Int
) {
    val likeCountText: String get() = likeCount.formattedCompact()
}

/** Which content the Wallpapers pane is showing. The rail, the search bar and the chip row are the
 * same on every one of these - only the pane's body changes - which is what makes moving between
 * them read as one screen rather than a stack of pushed views. */
sealed interface WallpaperPage {
    /** "All Themes": the discovery page - featured banner, Popular / Collections / Trending /
     * Community. */
    data object Discover : WallpaperPage
    /** One theme's own page: that theme's banner, then only that theme's wallpapers. */
    data class Theme(val category: WallpaperCategory) : WallpaperPage
    /** A "see all" destination for one of the discovery rows. */
    data class Section(val section: WallpaperSection) : WallpaperPage
    /** One collection's members. */
    data class Collection(val id: String) : WallpaperPage
    /** The existing live Firestore wallpapers feature, folded in as its own page rather than
     * removed - see [WallpaperFilter.COMMUNITY]. */
    data object Community : WallpaperPage
}

/** The discovery rows that have their own "see all" page. */
enum class WallpaperSection {
    POPULAR, COLLECTIONS, TRENDING, DOWNLOADS;

    val title: String
        get() = when (this) {
            POPULAR -> "POPULAR THEMES"
            COLLECTIONS -> "COLLECTIONS"
            TRENDING -> "TRENDING NOW"
            DOWNLOADS -> "MY DOWNLOADS"
        }
}
