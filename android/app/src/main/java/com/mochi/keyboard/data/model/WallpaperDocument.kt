package com.mochi.keyboard.data.model

import com.google.firebase.firestore.DocumentId
import com.google.firebase.firestore.PropertyName

/**
 * Mirrors the real `liveWallpapers/{wallpaperId}` schema documented in docs/TRD.md and enforced by
 * firestore/firestore.rules (`allow read: if true; allow write: if false;` - admin-authored only,
 * the client never writes here). Field list is exactly `name, previewUrl, assetUrl, isPremium`, no
 * more - unlike `themes/{id}` there's no likeCount/createdAt/category to sort or filter by.
 *
 * isPremium is pinned with @get:PropertyName pre-emptively - ThemeDocument.isPremium silently
 * deserialized to false for months (Session 19) because Firestore's Kotlin mapper strips a leading
 * "is" off is-prefixed boolean getters. Same footgun shape, fixed before it can bite here.
 */
data class WallpaperDocument(
    @DocumentId val id: String = "",
    val name: String = "",
    val previewUrl: String = "",
    val assetUrl: String = "",
    @get:PropertyName("isPremium")
    val isPremium: Boolean = false
)
