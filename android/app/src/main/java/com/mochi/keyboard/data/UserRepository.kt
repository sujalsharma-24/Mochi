package com.mochi.keyboard.data

import com.google.firebase.firestore.FieldPath
import com.google.firebase.firestore.FieldValue
import com.google.firebase.firestore.FirebaseFirestore
import com.google.firebase.firestore.Query
import com.mochi.keyboard.data.model.UserDocument
import kotlinx.coroutines.tasks.await

/**
 * Writes must match firestore/firestore.rules' users/{uid} `create` rule exactly (uid ==
 * request.auth.uid, subscriptionStatus starts "free", every counter starts 0, isDeleted false) or
 * the emulator/rules rejects the write. firestore/tests/rules.test.js encodes this same contract.
 */
class UserRepository(private val firestore: FirebaseFirestore) {

    /** `users/{uid}` is readable by any signed-in user (firestore.rules line 30), not just the
     * profile's owner - this is what makes viewing another user's profile possible at all. */
    suspend fun getUser(uid: String): UserDocument? =
        firestore.collection("users").document(uid).get().await().toObject(UserDocument::class.java)

    /** Search's Creators tab. No searchable-by-name index/service exists (same "no paid search
     * backend" constraint as ThemeRepository.searchableThemes) - fetch a bounded pool of profiles
     * and filter client-side by displayName/username substring. `users/{uid}` read is open to any
     * signed-in user per firestore.rules, and a plain collection `list` with no filter is allowed
     * by the same rule since it doesn't reference resource.data.
     *
     * Filters out docs with a blank `uid` field - a theme's creatorUid can get a partial `users/`
     * doc auto-created by a Cloud Function's counter fan-out (e.g. onLikeWritten incrementing a
     * creator's likesReceivedCount) targeting a creator who never actually completed sign-up, which
     * never wrote the literal `uid` field createUserProfile normally writes. Confirmed live against
     * this app's own seed data - seed.mjs's themes reference creatorUid "seed-creator-mochi-studio",
     * which has no real account, yet the emulator had a `users/seed-creator-mochi-studio` doc with
     * only counter fields. Trusting that doc's blank `uid` for a Follow action wrote a real
     * `follows/{uid}_` doc with an empty `followeeId` before this filter was added. */
    suspend fun searchableUsers(limit: Long = 200): List<UserDocument> =
        firestore.collection("users").limit(limit).get().await()
            .toObjects(UserDocument::class.java)
            .filter { !it.isDeleted && it.uid.isNotBlank() }

    /** Leaderboard's "This Week" tab. `weeklyStats/{weekId}/creators/{uid}` is a dedicated ranking
     * collection maintained only by functions/src/likes.ts' onLikeWritten fan-out (firestore.rules
     * blocks any client write to it) and holds nothing but a bare `likeCount` counter keyed by uid -
     * no display fields - so this returns just the ranked uid/likeCount pairs; the caller batch-
     * fetches matching users/{uid} docs via [getUsers] for display info. */
    suspend fun weeklyTopCreators(weekId: String, limit: Long = 50): List<Pair<String, Long>> =
        firestore.collection("weeklyStats").document(weekId).collection("creators")
            .orderBy("likeCount", Query.Direction.DESCENDING)
            .limit(limit)
            .get().await()
            .documents
            .map { it.id to (it.getLong("likeCount") ?: 0L) }

    /** Batch fetch by uid, keyed by the real document id rather than UserDocument.uid - a phantom
     * profile doc auto-created by a Cloud Function's counter fan-out (see searchableUsers' doc
     * comment) never got a real `uid` field written, so associating by `it.uid` would silently drop
     * exactly the creators [[LeaderboardViewModel]]'s "This Week" join most needs to resolve (their
     * doc exists only because they received likes). Same chunked-whereIn shape as
     * ThemeRepository.getThemesByIds - Firestore's whereIn caps at 30 values per query. */
    suspend fun getUsers(uids: List<String>): Map<String, UserDocument> {
        if (uids.isEmpty()) return emptyMap()
        return uids.chunked(30).flatMap { chunk ->
            firestore.collection("users")
                .whereIn(FieldPath.documentId(), chunk)
                .get().await()
                .documents
        }.associate { it.id to (it.toObject(UserDocument::class.java) ?: UserDocument()) }
    }

    suspend fun createUserProfile(uid: String) {
        val now = FieldValue.serverTimestamp()
        val profile = hashMapOf(
            "uid" to uid,
            "createdAt" to now,
            "updatedAt" to now,
            "subscriptionStatus" to "free",
            "followerCount" to 0,
            "followingCount" to 0,
            "themeCount" to 0,
            "likesGivenCount" to 0,
            "likesReceivedCount" to 0,
            "isDeleted" to false
        )
        firestore.collection("users").document(uid).set(profile).await()
    }
}
