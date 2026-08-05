package com.mochi.keyboard.data

import com.google.firebase.firestore.FieldPath
import com.google.firebase.firestore.FirebaseFirestore
import com.google.firebase.firestore.Query
import com.mochi.keyboard.data.model.ThemeDocument
import com.mochi.keyboard.data.model.toKeyboardTheme
import com.mochi.keyboard.model.KeyboardTheme
import kotlinx.coroutines.tasks.await

/**
 * Query shapes here must lead with isPublished/moderationStatus equality filters to match the
 * composite indexes in firestore/firestore.indexes.json — dropping either filter works fine
 * against the lenient emulator but would require a missing index against a real project.
 */
class ThemeRepository(private val firestore: FirebaseFirestore) {

    private val themes get() = firestore.collection("themes")

    suspend fun getPublishedThemes(limit: Long = 20): List<KeyboardTheme> =
        themes
            .whereEqualTo("isPublished", true)
            .whereEqualTo("moderationStatus", "approved")
            .orderBy("createdAt", Query.Direction.DESCENDING)
            .limit(limit)
            .get()
            .await()
            .toObjects(ThemeDocument::class.java)
            .map { it.toKeyboardTheme() }

    suspend fun getTopRanked(limit: Long = 20): List<KeyboardTheme> =
        themes
            .whereEqualTo("isPublished", true)
            .whereEqualTo("moderationStatus", "approved")
            .orderBy("likeCount", Query.Direction.DESCENDING)
            .limit(limit)
            .get()
            .await()
            .toObjects(ThemeDocument::class.java)
            .map { it.toKeyboardTheme() }

    suspend fun getTheme(themeId: String): ThemeDocument? =
        themes.document(themeId).get().await().toObject(ThemeDocument::class.java)

    /** Community's "Following" tab. Firestore's whereIn caps at 30 values, so callers with a huge
     * follow list get their most-recently-followed 30 - acceptable for a feed, not a full archive. */
    suspend fun getThemesByCreators(creatorUids: List<String>, limit: Long = 30): List<KeyboardTheme> {
        if (creatorUids.isEmpty()) return emptyList()
        return themes
            .whereEqualTo("isPublished", true)
            .whereEqualTo("moderationStatus", "approved")
            .whereIn("creatorUid", creatorUids.take(30))
            .limit(limit)
            .get()
            .await()
            .toObjects(ThemeDocument::class.java)
            .map { it.toKeyboardTheme() }
    }

    /** Community's "My Likes" tab. Still filtered to isPublished/approved like every other feed
     * query - firestore.rules' read rule only additionally allows a theme's *owner* to read their
     * own unapproved theme, not an arbitrary liker, and Firestore rejects a whole `list` query
     * outright if any potential result could fail the rule, so this can't relax the filter without
     * risking the entire query being denied. A theme taken down after being liked will simply drop
     * out of this list, same as it drops out of every other feed. */
    suspend fun getThemesByIds(themeIds: List<String>): List<KeyboardTheme> {
        if (themeIds.isEmpty()) return emptyList()
        return themeIds.chunked(30).flatMap { chunk ->
            themes
                .whereEqualTo("isPublished", true)
                .whereEqualTo("moderationStatus", "approved")
                .whereIn(FieldPath.documentId(), chunk)
                .get()
                .await()
                .toObjects(ThemeDocument::class.java)
        }.map { it.toKeyboardTheme() }
    }
}
