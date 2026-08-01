package com.mochi.keyboard

import android.graphics.Color
import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.SystemBarStyle
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import com.mochi.keyboard.ui.AppNavHost

class MainActivity : ComponentActivity() {
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
        setContent {
            AppNavHost()
        }
    }
}
