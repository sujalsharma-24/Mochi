package com.mochi.keyboard.notifications

import android.app.PendingIntent
import android.content.Intent
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import com.google.firebase.messaging.FirebaseMessagingService
import com.google.firebase.messaging.RemoteMessage
import com.mochi.keyboard.MainActivity
import com.mochi.keyboard.MochiApplication
import com.mochi.keyboard.R
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch

/**
 * Cloud Functions (functions/src/notifications.ts) sends data-only messages, never a "notification"
 * payload - this keeps foreground and backgrounded/killed-app delivery going through the exact same
 * path (onMessageReceived building the notification by hand) instead of two different display
 * mechanisms to keep in sync.
 */
class MochiFirebaseMessagingService : FirebaseMessagingService() {

    private val scope = CoroutineScope(Dispatchers.IO)

    /** Firebase mints a new token on first install and again on rare refresh events (e.g. the
     * previous token was invalidated) - independent of sign-in state, so this can fire before any
     * user is signed in, in which case there's nothing to attach it to yet (AuthRepository.
     * syncFcmToken() covers that case right after a successful sign-in instead). */
    override fun onNewToken(token: String) {
        super.onNewToken(token)
        val container = (application as MochiApplication).container
        scope.launch {
            runCatching { container.authRepository.updateFcmToken(token) }
        }
    }

    override fun onMessageReceived(message: RemoteMessage) {
        super.onMessageReceived(message)
        val title = message.data["title"] ?: return
        val body = message.data["body"].orEmpty()
        showNotification(title, body)
    }

    private fun showNotification(title: String, body: String) {
        NotificationChannels.ensureCreated(this)

        val openAppIntent = Intent(this, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
        }
        val pendingIntent = PendingIntent.getActivity(
            this,
            0,
            openAppIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        val notification = NotificationCompat.Builder(this, NotificationChannels.GENERAL_CHANNEL_ID)
            .setSmallIcon(R.drawable.ic_notification)
            .setContentTitle(title)
            .setContentText(body)
            .setAutoCancel(true)
            .setContentIntent(pendingIntent)
            .build()

        // Posting without POST_NOTIFICATIONS granted (API 33+, denied/not-yet-requested) throws
        // SecurityException on some OEMs rather than silently no-op'ing - areNotificationsEnabled()
        // covers both "permission denied" and "user disabled notifications in system settings".
        if (!NotificationManagerCompat.from(this).areNotificationsEnabled()) return
        runCatching {
            NotificationManagerCompat.from(this).notify(System.currentTimeMillis().toInt(), notification)
        }
    }
}
