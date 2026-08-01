package com.mochi.keyboard.data

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
}
