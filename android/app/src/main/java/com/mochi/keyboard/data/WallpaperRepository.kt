package com.mochi.keyboard.data

import com.google.firebase.firestore.FirebaseFirestore
import com.mochi.keyboard.data.model.WallpaperDocument
import kotlinx.coroutines.tasks.await

/**
 * `liveWallpapers` is small (5 at launch per the locked feature spec) and admin-authored, so unlike
 * ThemeRepository there's no isPublished/moderationStatus filter or pagination limit to apply -
 * every document in the collection is meant to be shown.
 */
class WallpaperRepository(private val firestore: FirebaseFirestore) {

    private val wallpapers get() = firestore.collection("liveWallpapers")

    suspend fun getAll(): List<WallpaperDocument> =
        wallpapers.get().await().toObjects(WallpaperDocument::class.java)
}
