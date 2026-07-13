package com.mochi.app.model

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

data class FontItem(
    val id: String,
    val name: String,
    val styleDescription: String,
    val isPremium: Boolean,
    val previewAssetName: String
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

fun Int.formattedCompact(): String = when {
    this >= 1_000_000 -> "%.1fM".format(this / 1_000_000.0)
    this >= 1_000 -> "%.1fK".format(this / 1_000.0)
    else -> "$this"
}
