package com.mochi.keyboard.data

import android.app.WallpaperManager
import android.content.ContentValues
import android.content.Context
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.os.Build
import android.provider.MediaStore
import androidx.datastore.preferences.core.edit
import androidx.datastore.preferences.core.stringPreferencesKey
import androidx.datastore.preferences.preferencesDataStore
import com.mochi.keyboard.model.WallpaperItem
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.map
import kotlinx.coroutines.withContext

private val Context.appliedWallpaperDataStore by preferencesDataStore(name = "mochi_applied_wallpaper")

/**
 * Sets the device wallpaper directly via `WallpaperManager` - Android's real equivalent of iOS's
 * `WallpaperExporter`/`AppliedWallpaperStore`, but deliberately *not* a copy of iOS's save-to-
 * Photos-then-share-sheet workaround: iOS has no public API to set the Lock/Home Screen wallpaper,
 * Android does, so Apply uses it directly (Session 28 - confirmed with Sujal rather than assumed,
 * since silently doing something iOS can't is worth flagging even when it's strictly better).
 * `saveToGallery` is kept as a separate action for users who just want the file, matching iOS's
 * still-useful "Download" button.
 */
class WallpaperApplier(private val context: Context) {

    enum class Target { HOME, LOCK, BOTH }

    sealed interface Outcome {
        data object Applied : Outcome
        data object Saved : Outcome
        data class Failed(val message: String) : Outcome
    }

    /** The one wallpaper last applied via [apply] - drives the preview/grid "Applied" checkmark.
     * Purely a UI-state record; re-applying (or the user changing it from outside the app) doesn't
     * flow back here, same honesty-about-staleness tradeoff `AppliedThemeRepository` documents. */
    val appliedWallpaperId: Flow<String?> = context.appliedWallpaperDataStore.data.map { it[KEY_APPLIED] }

    /** Sets the wallpaper immediately - no app-switching, no share sheet. */
    suspend fun apply(item: WallpaperItem, target: Target): Outcome = withContext(Dispatchers.IO) {
        val bitmap = decodeBitmap(item.assetName)
            ?: return@withContext Outcome.Failed("That wallpaper's artwork is missing from the app.")
        runCatching {
            val manager = WallpaperManager.getInstance(context)
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                val flags = when (target) {
                    Target.HOME -> WallpaperManager.FLAG_SYSTEM
                    Target.LOCK -> WallpaperManager.FLAG_LOCK
                    Target.BOTH -> WallpaperManager.FLAG_SYSTEM or WallpaperManager.FLAG_LOCK
                }
                manager.setBitmap(bitmap, null, true, flags)
            } else {
                manager.setBitmap(bitmap)
            }
        }.fold(
            onSuccess = {
                context.appliedWallpaperDataStore.edit { it[KEY_APPLIED] = item.id }
                Outcome.Applied
            },
            onFailure = { e -> Outcome.Failed(e.localizedMessage ?: "Couldn't set wallpaper.") }
        )
    }

    /** Saves a copy into the device's gallery via MediaStore - scoped storage, no runtime
     * permission needed on API 29+ ([AndroidManifest.xml]'s `WRITE_EXTERNAL_STORAGE` only covers
     * the API 26-28 gap below that, per its own `maxSdkVersion`). */
    suspend fun saveToGallery(item: WallpaperItem): Outcome = withContext(Dispatchers.IO) {
        val bitmap = decodeBitmap(item.assetName)
            ?: return@withContext Outcome.Failed("That wallpaper's artwork is missing from the app.")
        runCatching {
            val resolver = context.contentResolver
            val values = ContentValues().apply {
                put(MediaStore.Images.Media.DISPLAY_NAME, "${item.id}.jpg")
                put(MediaStore.Images.Media.MIME_TYPE, "image/jpeg")
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                    put(MediaStore.Images.Media.RELATIVE_PATH, "Pictures/Mochi")
                }
            }
            val uri = resolver.insert(MediaStore.Images.Media.EXTERNAL_CONTENT_URI, values)
                ?: error("Couldn't create a gallery entry.")
            val opened = resolver.openOutputStream(uri)?.use { out ->
                bitmap.compress(Bitmap.CompressFormat.JPEG, 95, out)
            }
            if (opened != true) error("Couldn't save the image data.")
        }.fold(
            onSuccess = { Outcome.Saved },
            onFailure = { e -> Outcome.Failed(e.localizedMessage ?: "Couldn't save to gallery.") }
        )
    }

    private fun decodeBitmap(assetName: String): Bitmap? {
        val resId = context.resources.getIdentifier(assetName, "drawable", context.packageName)
        if (resId == 0) return null
        return BitmapFactory.decodeResource(context.resources, resId)
    }

    private companion object {
        val KEY_APPLIED = stringPreferencesKey("applied_wallpaper_id")
    }
}
