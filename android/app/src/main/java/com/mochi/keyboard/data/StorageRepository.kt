package com.mochi.keyboard.data

import android.net.Uri
import com.google.firebase.storage.FirebaseStorage
import kotlinx.coroutines.tasks.await
import java.util.UUID

/**
 * Upload paths/limits must match storage.rules exactly: `avatars/{uid}/{fileName}` and
 * `themes/{uid}/{fileName}`, both capped in the rules themselves (5MB avatars, 10MB theme images,
 * images only) - those limits aren't re-validated here, an oversized/wrong-type upload is rejected
 * server-side by the rules and this call throws.
 */
class StorageRepository(private val storage: FirebaseStorage) {

    suspend fun uploadThemeImage(uid: String, imageUri: Uri): String {
        val ref = storage.reference.child("themes/$uid/${UUID.randomUUID()}.jpg")
        ref.putFile(imageUri).await()
        return ref.downloadUrl.await().toString()
    }

    suspend fun uploadAvatar(uid: String, imageUri: Uri): String {
        val ref = storage.reference.child("avatars/$uid/${UUID.randomUUID()}.jpg")
        ref.putFile(imageUri).await()
        return ref.downloadUrl.await().toString()
    }
}
