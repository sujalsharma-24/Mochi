package com.mochi.keyboard.model

data class KeyboardTheme(
    val id: String,
    val name: String,
    val creatorName: String,
    val imageAssetName: String,
    val likeCount: Int,
    val isPremium: Boolean,
    val hashtags: List<String>,
    val description: String = ""
) {
    val likeCountFormatted: String get() = likeCount.formattedCompact()
}

/** `previewAssetName` is Home's small font-row tile; `artAssetName` is the larger Fonts-page grid
 * crop. Nature Flow and Gothic Dark have no composed small tile, so both names point at the same
 * art crop for them (see MockData.fontCollection). */
data class FontItem(
    val id: String,
    val name: String,
    val styleDescription: String,
    val isPremium: Boolean,
    val previewAssetName: String,
    val artAssetName: String
)

data class Creator(
    val id: String,
    val displayName: String,
    val handle: String,
    val avatarAssetName: String,
    val themeCount: Int,
    val likeCount: Int,
    val isFollowing: Boolean,
    val isVerified: Boolean
)

/** A creator tile in Community's "Popular Creators" row. Separate from `Creator` (the profile
 * model) since the tile shows a smaller slice (avatar, name, theme count, one CTA), and Figma
 * gives the fourth tile the label "Choose" rather than "Follow" — reproduced, not corrected. */
data class CommunityCreator(
    val id: String,
    val name: String,
    val avatarAssetName: String,
    val themeCount: Int,
    val isVerified: Boolean,
    val ctaTitle: String
)

enum class TagPalette { GREEN, BLUE, PEACH }

/** A row in Community's "Latest Creations" list. Carries its own wide (2.12:1) thumbnail asset and
 * hashtag palette — Figma tints each card's chips differently rather than using one shared style. */
data class CommunityPost(
    val id: String,
    val name: String,
    val creatorName: String,
    val thumbAssetName: String,
    val summary: String,
    val likeCount: Int,
    val hashtags: List<String>,
    val tagPalette: TagPalette
)

fun Int.formattedCompact(): String = when {
    this >= 1_000_000 -> "%.1fM".format(this / 1_000_000.0)
    this >= 1_000 -> "%.1fK".format(this / 1_000.0)
    else -> "$this"
}

// Profile (docs/figma/3.png)

/** The signed-in user as the Profile frame presents them. Counts are real numbers formatted at
 * render time via formattedCompact() (Figma writes "2.4K" beside a bare "128" and "156" — one
 * column abbreviated, two not, but that's a display choice, not a reason to store pre-formatted
 * strings — see KeyboardTheme.likeCountFormatted for the same pattern used elsewhere). */
data class ProfileSummary(
    val displayName: String,
    val handle: String,
    val bio: String,
    val avatarAssetName: String,
    val isVerified: Boolean,
    val stats: List<Stat>
) {
    data class Stat(val value: Int, val label: String)
}

/** One tile in MY CREATIONS or MY DOWNLOADS. `kind` is the purple line under the name
 * ("Theme"/"Font"); MY DOWNLOADS doesn't show it and `downloads` is null there. */
data class ProfileCreation(
    val id: String,
    val name: String,
    val kind: String,
    val imageAssetName: String,
    val likes: Int,
    val downloads: Int? = null
)

/** A row in the Liked Themes card. */
data class ProfileLikedTheme(
    val id: String,
    val name: String,
    val creatorName: String,
    val imageAssetName: String,
    val likes: Int
)

/** A row in the right-hand card (Followers / Following). */
data class ProfileFollowRow(val id: String, val label: String, val value: Int)
