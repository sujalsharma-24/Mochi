package com.mochi.keyboard.ime.render

import android.content.Context
import android.graphics.Bitmap
import android.graphics.BitmapFactory

/**
 * Resolves and caches per-key illustration bitmaps by name — ported from iOS's `KeyArtStore`.
 * Resources are looked up once by name (a one-time `getIdentifier` cost, not per-frame) and the
 * decoded bitmap is cached until [releaseAll] is called, mirroring the extension's memory-warning
 * reclaim on iOS even though Android's IME has no comparable ceiling to defend.
 */
class KeyArtStore(private val context: Context) {
    private val resIdCache = HashMap<String, Int>()
    private val bitmapCache = HashMap<String, Bitmap?>()

    fun resIdFor(name: String): Int = resIdCache.getOrPut(name) {
        context.resources.getIdentifier(name, "drawable", context.packageName)
    }

    fun bitmapFor(name: String): Bitmap? = bitmapCache.getOrPut(name) {
        val resId = resIdFor(name)
        if (resId == 0) null else BitmapFactory.decodeResource(context.resources, resId)
    }

    fun releaseAll() {
        bitmapCache.clear()
    }
}
