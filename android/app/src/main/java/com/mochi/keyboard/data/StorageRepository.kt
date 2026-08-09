package com.mochi.keyboard.data

import android.net.Uri
import com.google.firebase.storage.FirebaseStorage
import com.google.firebase.storage.storageMetadata
import kotlinx.coroutines.tasks.await
import java.util.UUID

/**
 * Upload paths/limits must match storage.rules exactly: `avatars/{uid}/{fileName}` and
 * `themes/{uid}/{fileName}`, both capped in the rules themselves (5MB avatars, 10MB theme images,
 * images only) - those limits aren't re-validated here, an oversized/wrong-type upload is rejected
 * server-side by the rules and this call throws. contentType is forced to "image/jpeg" rather than
 * left to putFile()'s automatic ContentResolver-based inference - a picked content:// Uri (e.g. from
 * the system photo picker) doesn't always resolve a type Storage's rules recognize as `image/.*`,
 * which the rules then reject as a permission error, not a type error (confirmed against the local
 * Storage emulator: an unresolved/generic contentType read back as "User does not have permission to
 * access this object", not a clearer type-mismatch message).
 */
class StorageRepository(private val storage: FirebaseStorage) {
    private val jpegMetadata = storageMetadata { contentType = "image/jpeg" }

    suspend fun uploadThemeImage(uid: String, imageUri: Uri): String {
        val ref = storage.reference.child("themes/$uid/${UUID.randomUUID()}.jpg")
        ref.putFile(imageUri, jpegMetadata).await()
        return ref.downloadUrl.await().toString()
    }

    suspend fun uploadAvatar(uid: String, imageUri: Uri): String {
        val ref = storage.reference.child("avatars/$uid/${UUID.randomUUID()}.jpg")
        ref.putFile(imageUri, jpegMetadata).await()
        return ref.downloadUrl.await().toString()
    }
}
