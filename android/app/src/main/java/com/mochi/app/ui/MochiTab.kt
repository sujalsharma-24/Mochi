package com.mochi.app.ui

import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.AutoAwesome
import androidx.compose.material.icons.filled.Group
import androidx.compose.material.icons.filled.Keyboard
import androidx.compose.material.icons.filled.Palette
import androidx.compose.material.icons.filled.TextFields
import androidx.compose.ui.graphics.vector.ImageVector

/** Ported from ios/MochiApp/App/MochiTab.swift */
enum class MochiTab(val title: String, val icon: ImageVector) {
    KEYBOARD("Keyboard", Icons.Filled.Keyboard),
    FONTS("Fonts", Icons.Filled.TextFields),
    CREATE("Create", Icons.Filled.AutoAwesome),
    THEMES("Themes", Icons.Filled.Palette),
    COMMUNITY("Community", Icons.Filled.Group)
}
