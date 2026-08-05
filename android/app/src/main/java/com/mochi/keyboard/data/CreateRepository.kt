package com.mochi.keyboard.data

import com.google.firebase.firestore.FieldValue
import com.google.firebase.firestore.FirebaseFirestore
import com.mochi.keyboard.data.model.BackgroundConfig
import com.mochi.keyboard.data.model.EffectsConfig
import com.mochi.keyboard.data.model.FontsConfig
import com.mochi.keyboard.data.model.KeysConfig
import kotlinx.coroutines.tasks.await

/**
 * Writes must match firestore/firestore.rules' themes/{themeId} `create` rule exactly:
 * creatorUid == auth.uid, moderationStatus starts "pending", every counter starts 0. "Save Draft"
 * vs "Publish Theme" is just isPublished false/true - both still start moderationStatus "pending",
 * since every read query in ThemeRepository filters on moderationStatus == "approved" regardless of
 * isPublished, so a freshly-published theme is invisible in feeds either way until moderation
 * approves it. Real moderation (Vision API flips pending -> approved/rejected) is a Cloud Function,
 * WA3, not built yet - published themes sit invisibly pending until then.
 */
class CreateRepository(private val firestore: FirebaseFirestore) {

    suspend fun saveTheme(
        creatorUid: String,
        creatorDisplayName: String,
        creatorAvatarUrl: String,
        name: String,
        description: String,
        hashtags: List<String>,
        previewImageUrl: String,
        isPremium: Boolean,
        publish: Boolean,
        backgroundType: String,
        backgroundConfig: BackgroundConfig,
        keysConfig: KeysConfig,
        fontsConfig: FontsConfig,
        effectsConfig: EffectsConfig
    ): String {
        val now = FieldValue.serverTimestamp()
        val theme = hashMapOf(
            "creatorUid" to creatorUid,
            "creatorDisplayName" to creatorDisplayName,
            "creatorAvatarUrl" to creatorAvatarUrl,
            "name" to name,
            "description" to description,
            "hashtags" to hashtags,
            "previewImageUrl" to previewImageUrl,
            "isPremium" to isPremium,
            "isPublished" to publish,
            "moderationStatus" to "pending",
            "likeCount" to 0,
            "downloadCount" to 0,
            "reportCount" to 0,
            "backgroundType" to backgroundType,
            "backgroundConfig" to backgroundConfig,
            "keysConfig" to keysConfig,
            "fontsConfig" to fontsConfig,
            "effectsConfig" to effectsConfig,
            "createdAt" to now,
            "updatedAt" to now
        )
        return firestore.collection("themes").add(theme).await().id
    }
}
