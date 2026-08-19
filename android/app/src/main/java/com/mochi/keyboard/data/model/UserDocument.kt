package com.mochi.keyboard.data.model

import com.google.firebase.firestore.PropertyName
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
    // Same is-prefix getter-stripping footgun ThemeDocument.isPremium/isPublished hit (see that
    // file's comment) - without this, Firestore's mapper resolves the Kotlin `isDeleted` getter to
    // field "deleted", not the real document field "isDeleted" that createUserProfile/onAccountDelete
    // actually write, silently deserializing every user as never-deleted. Found incidentally while
    // adding WA5's fcmToken/notificationsEnabled fields to this same file, not part of that slice's
    // own scope, but a one-line fix for a real pre-existing bug (e.g. searchableUsers' `!it.isDeleted`
    // filter never actually excluded a deleted account).
    @get:PropertyName("isDeleted")
    val isDeleted: Boolean = false,
    val fcmToken: String = "",
    val notificationsEnabled: Boolean = true
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
