package com.mochi.keyboard.data

import com.google.firebase.firestore.FirebaseFirestore
import kotlinx.coroutines.tasks.await

/**
 * `likes/{uid}_{themeId}` docs are client-writable (firestore.rules allows create/delete of your
 * own like), but the theme's `likeCount` field is NOT — only a Cloud Function (onLikeWrite,
 * WA3, not built yet) can increment/decrement it, since a client can't be trusted to self-report
 * its own like count. Until that function exists, liking/unliking here updates the `likes`
 * collection for real but the theme's stored likeCount won't move - screens should apply their own
 * optimistic +1/-1 in the UI layer rather than re-reading likeCount immediately after this call.
 */
class LikeRepository(private val firestore: FirebaseFirestore) {

    private fun likeDocId(uid: String, themeId: String) = "${uid}_$themeId"

    suspend fun isLiked(uid: String, themeId: String): Boolean =
        firestore.collection("likes").document(likeDocId(uid, themeId)).get().await().exists()

    suspend fun like(uid: String, themeId: String) {
        val like = hashMapOf("uid" to uid, "themeId" to themeId)
        firestore.collection("likes").document(likeDocId(uid, themeId)).set(like).await()
    }

    suspend fun unlike(uid: String, themeId: String) {
        firestore.collection("likes").document(likeDocId(uid, themeId)).delete().await()
    }

    /** Theme ids the given user has liked - used to build the "My Likes" community feed tab. */
    suspend fun likedThemeIds(uid: String): List<String> =
        firestore.collection("likes")
            .whereEqualTo("uid", uid)
            .get()
            .await()
            .documents
            .mapNotNull { it.getString("themeId") }
}
