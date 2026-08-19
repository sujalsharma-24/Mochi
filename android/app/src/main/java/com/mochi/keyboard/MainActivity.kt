package com.mochi.keyboard

import android.Manifest
import android.content.pm.PackageManager
import android.graphics.Color
import android.os.Build
import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.SystemBarStyle
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.activity.result.contract.ActivityResultContracts
import androidx.core.content.ContextCompat
import com.mochi.keyboard.ui.AppNavHost

class MainActivity : ComponentActivity() {

    private val requestNotificationPermission =
        registerForActivityResult(ActivityResultContracts.RequestPermission()) { /* no-op either way - a
            denial just means MochiFirebaseMessagingService's areNotificationsEnabled() check skips
            display later, nothing to react to here */ }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // Default enableEdgeToEdge() leaves a semi-opaque scrim behind a 3-button nav bar (Google's
        // default for legibility) even though the status bar goes fully transparent - forcing both
        // to transparent so the app background bleeds behind the nav bar the same way it already
        // does behind the status bar.
        enableEdgeToEdge(
            statusBarStyle = SystemBarStyle.auto(Color.TRANSPARENT, Color.TRANSPARENT),
            navigationBarStyle = SystemBarStyle.auto(Color.TRANSPARENT, Color.TRANSPARENT)
        )
        requestNotificationPermissionIfNeeded()
        setContent {
            AppNavHost()
        }
    }

    /** POST_NOTIFICATIONS only exists as a runtime permission from API 33 - minSdk 26 means this
     * must be guarded, and it's a no-op prompt-once request (no rationale UI) since there's exactly
     * one notification category live today (WA5 slice 1); revisit if/when a per-category
     * notification-settings screen makes "ask again later" meaningful. */
    private fun requestNotificationPermissionIfNeeded() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.TIRAMISU) return
        val granted = ContextCompat.checkSelfPermission(this, Manifest.permission.POST_NOTIFICATIONS) ==
            PackageManager.PERMISSION_GRANTED
        if (!granted) requestNotificationPermission.launch(Manifest.permission.POST_NOTIFICATIONS)
    }
}
