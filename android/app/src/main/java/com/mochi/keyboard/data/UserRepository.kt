package com.mochi.keyboard.data

import com.google.firebase.firestore.FieldValue
import com.google.firebase.firestore.FirebaseFirestore
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
