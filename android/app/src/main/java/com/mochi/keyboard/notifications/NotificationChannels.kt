package com.mochi.keyboard.notifications

import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Context

/** Single general-purpose channel for every push category (WA5's spec lists 4 categories - new
 * theme from a followed creator, weekly leaderboard, announcements, subscription reminders - but
 * none has shipped a per-category settings UI yet, so one channel keeps the system Settings page
 * matching what's actually configurable today; splitting into per-category channels is a
 * non-breaking addition later if that UI gets built). */
object NotificationChannels {
    const val GENERAL_CHANNEL_ID = "general"

    fun ensureCreated(context: Context) {
        val manager = context.getSystemService(NotificationManager::class.java) ?: return
        manager.createNotificationChannel(
            NotificationChannel(GENERAL_CHANNEL_ID, "Mochi", NotificationManager.IMPORTANCE_DEFAULT).apply {
                description = "New themes, community, and account updates"
            }
        )
    }
}
