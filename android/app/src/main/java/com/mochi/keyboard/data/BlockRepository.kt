package com.mochi.keyboard.data

import com.google.firebase.firestore.FirebaseFirestore
import kotlinx.coroutines.tasks.await

/**
 * `blocks/{blockerUid}_{blockedUid}` docs are client-writable (firestore.rules lines 120-132),
 * readable only by the blocker - mirrors FollowRepository's shape exactly. No Cloud Function
 * reacts to this collection yet (no feed-filtering, no auto-unfollow); it only gates the block
 * status shown on a profile for now.
 */
class BlockRepository(private val firestore: FirebaseFirestore) {

    private fun blockDocId(blockerUid: String, blockedUid: String) = "${blockerUid}_$blockedUid"

    suspend fun isBlocked(blockerUid: String, blockedUid: String): Boolean =
        firestore.collection("blocks").document(blockDocId(blockerUid, blockedUid)).get().await().exists()

    suspend fun block(blockerUid: String, blockedUid: String) {
        val block = hashMapOf("blockerUid" to blockerUid, "blockedUid" to blockedUid)
        firestore.collection("blocks").document(blockDocId(blockerUid, blockedUid)).set(block).await()
    }

    suspend fun unblock(blockerUid: String, blockedUid: String) {
        firestore.collection("blocks").document(blockDocId(blockerUid, blockedUid)).delete().await()
    }
}
