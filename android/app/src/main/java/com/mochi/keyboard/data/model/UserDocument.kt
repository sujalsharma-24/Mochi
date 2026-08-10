package com.mochi.keyboard.data.model

import com.mochi.keyboard.model.ProfileSummary

/**
 * Mirrors the real `users/{uid}` schema enforced by firestore/firestore.rules. `username` is
 * server-owned (written by the `reserveUsername` callable via the Admin SDK, never directly by a
 * client — see firestore.rules' update allowlist, which deliberately omits it) so it's often blank
 * today since no UI calls that callable yet. `isVerified` has no field anywhere in this schema
 * (same gap CommunityViewModel already documented for creator tiles) so it's never real.
 *
 * `uid` is a plain field, not `@DocumentId` (unlike ThemeDocument.id) - UserRepository.createUserProfile
 * writes a real "uid" field into the document body itself, and Firestore's deserializer throws if a
 * `@DocumentId`-annotated property's name collides with an actual field in the document data.
 */
data class UserDocument(
    val uid: String = "",
    val displayName: String = "",
    val username: String = "",
    val avatarUrl: String = "",
    val bio: String = "",
    val followerCount: Long = 0,
    val followingCount: Long = 0,
    val themeCount: Long = 0,
    val likesGivenCount: Long = 0,
    val likesReceivedCount: Long = 0,
    val isDeleted: Boolean = false
)

fun UserDocument.toProfileSummary(): ProfileSummary = ProfileSummary(
    displayName = displayName.ifBlank { "Mochi Creator" },
    handle = if (username.isNotBlank()) "@$username" else "",
    bio = bio,
    // No real avatar-upload path exists yet (avatarUrl is almost always blank) - empty falls
    // through ProfileArtImage's `?: return` the same way every other unmatched asset id does.
    avatarAssetName = "",
    isVerified = false,
    stats = listOf(
        ProfileSummary.Stat(themeCount.toInt(), "Creations"),
        ProfileSummary.Stat(followerCount.toInt(), "Followers"),
        ProfileSummary.Stat(followingCount.toInt(), "Following")
    )
)
