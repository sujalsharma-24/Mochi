package com.mochi.keyboard.data

import com.google.firebase.firestore.FirebaseFirestore
import kotlinx.coroutines.tasks.await

/**
 * `follows/{followerId}_{followeeId}` docs are client-writable, but `users/{uid}`'s
 * followerCount/followingCount fields are not (see firestore.rules) - those are maintained by a
 * Cloud Function fan-out trigger (WA3, not built yet). Same optimistic-UI caveat as LikeRepository.
 */
class FollowRepository(private val firestore: FirebaseFirestore) {

    private fun followDocId(followerId: String, followeeId: String) = "${followerId}_$followeeId"

    suspend fun isFollowing(followerId: String, followeeId: String): Boolean =
        firestore.collection("follows").document(followDocId(followerId, followeeId)).get().await().exists()

    suspend fun follow(followerId: String, followeeId: String) {
        val follow = hashMapOf("followerId" to followerId, "followeeId" to followeeId)
        firestore.collection("follows").document(followDocId(followerId, followeeId)).set(follow).await()
    }

    suspend fun unfollow(followerId: String, followeeId: String) {
        firestore.collection("follows").document(followDocId(followerId, followeeId)).delete().await()
    }

    /** Creator uids the given user follows - used to build the "Following" community feed tab. */
    suspend fun followedUids(followerId: String): List<String> =
        firestore.collection("follows")
            .whereEqualTo("followerId", followerId)
            .get()
            .await()
            .documents
            .mapNotNull { it.getString("followeeId") }
}
