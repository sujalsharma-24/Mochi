package com.mochi.app.features.settings

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.ColumnScope
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material.icons.automirrored.filled.Assignment
import androidx.compose.material.icons.automirrored.filled.Chat
import androidx.compose.material.icons.automirrored.filled.InsertDriveFile
import androidx.compose.material.icons.filled.CleaningServices
import androidx.compose.material.icons.filled.Delete
import androidx.compose.material.icons.filled.DonutLarge
import androidx.compose.material.icons.filled.Email
import androidx.compose.material.icons.filled.Keyboard
import androidx.compose.material.icons.filled.Language
import androidx.compose.material.icons.filled.Notifications
import androidx.compose.material.icons.filled.Palette
import androidx.compose.material.icons.filled.Refresh
import androidx.compose.material.icons.filled.Settings
import androidx.compose.material.icons.filled.SupportAgent
import androidx.compose.material.icons.filled.VerifiedUser
import androidx.compose.material3.Icon
import androidx.compose.material3.Switch
import androidx.compose.material3.SwitchDefaults
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.mochi.app.designsystem.MochiColor
import com.mochi.app.designsystem.MochiFont
import com.mochi.app.designsystem.MochiGradient
import com.mochi.app.designsystem.MochiRadius
import com.mochi.app.designsystem.MochiSpacing

@Preview(showBackground = true, widthDp = 393, heightDp = 3600)
@Composable
private fun SettingsScreenPreview() {
    SettingsScreen()
}

/** Ported from docs/figma/7.png */
@Composable
fun SettingsScreen(modifier: Modifier = Modifier) {
    var isDark by remember { mutableStateOf(false) }
    var notificationsOn by remember { mutableStateOf(true) }

    Box(modifier = modifier.fillMaxSize().background(MochiGradient.background)) {
        Column(
            modifier = Modifier
                .fillMaxSize()
                .verticalScroll(rememberScrollState())
                .padding(horizontal = MochiSpacing.md)
                .padding(top = MochiSpacing.md, bottom = 100.dp),
            verticalArrangement = Arrangement.spacedBy(MochiSpacing.lg)
        ) {
            SettingsHeader()
            KeyboardSetupBanner()

            SettingsSection("APPEARANCE") {
                SettingsRow(Icons.Filled.Palette, "Theme Mode", "Choose your preferred theme") {
                    ThemeModeToggle(isDark) { isDark = it }
                }
                SettingsRow(Icons.Filled.Settings, "App Appearance", "Customize how the app looks") { ChevronIcon() }
            }

            SettingsSection("PREFERENCES") {
                SettingsRow(Icons.Filled.Language, "Language", "Choose app language") {
                    Text(text = "English (US)", style = MochiFont.body(13.sp), color = MochiColor.textSecondary)
                }
                SettingsRow(Icons.Filled.Notifications, "Notifications", "Manage notification preferences") {
                    Switch(
                        checked = notificationsOn,
                        onCheckedChange = { notificationsOn = it },
                        colors = SwitchDefaults.colors(checkedTrackColor = MochiColor.purple, checkedThumbColor = Color.White)
                    )
                }
                SettingsRow(Icons.Filled.Keyboard, "Default Keyboard", "Set Mochi as your default keyboard") { ChevronIcon() }
                SettingsRow(Icons.Filled.Refresh, "Reset to Default", "Reset all settings to default") { ChevronIcon() }
            }

            SettingsSection("STORAGE") {
                SettingsRow(Icons.Filled.CleaningServices, "Clear Cache", "Free up space by clearing cache") {
                    TrailingClear(value = "24.3 MB")
                }
                SettingsRow(Icons.Filled.Delete, "Clear Data", "Clear all app data (Reset app)") {
                    TrailingClear(value = "0.00 MB")
                }
                SettingsRow(Icons.Filled.DonutLarge, "Storage Usage", "Manage app storage") {
                    Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(4.dp)) {
                        Text(text = "158.7MB", style = MochiFont.body(13.sp), color = MochiColor.textSecondary)
                        ChevronIcon()
                    }
                }
            }

            SettingsSection("PRIVACY & DATA") {
                SettingsRow(Icons.Filled.VerifiedUser, "Privacy Policy", "Read our privacy policy") { ChevronIcon() }
                SettingsRow(Icons.AutoMirrored.Filled.InsertDriveFile, "Terms of Service", "Read our terms of service") { ChevronIcon() }
                SettingsRow(Icons.AutoMirrored.Filled.Assignment, "Manage Data", "Manage your data & privacy") { ChevronIcon() }
            }

            SettingsSection("HELP & SUPPORT") {
                SettingsRow(Icons.Filled.SupportAgent, "Help Center", "Get help with common questions") { ChevronIcon() }
                SettingsRow(Icons.AutoMirrored.Filled.Chat, "FAQS", "Frequently asked questions") { ChevronIcon() }
                SettingsRow(Icons.Filled.Email, "Contact Us", "We're here to help") { ChevronIcon() }
            }
        }
    }
}

@Composable
private fun SettingsHeader() {
    Column(horizontalAlignment = Alignment.CenterHorizontally, modifier = Modifier.fillMaxWidth()) {
        Box(modifier = Modifier.fillMaxWidth()) {
            Box(
                modifier = Modifier
                    .align(Alignment.CenterStart)
                    .size(44.dp)
                    .clip(CircleShape)
                    .background(MochiGradient.primaryButton),
                contentAlignment = Alignment.Center
            ) {
                Icon(imageVector = Icons.AutoMirrored.Filled.ArrowBack, contentDescription = "Back", tint = Color.White)
            }
            Row(modifier = Modifier.align(Alignment.Center), verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(6.dp)) {
                Box(
                    modifier = Modifier.size(24.dp).clip(RoundedCornerShape(6.dp)).background(MochiGradient.primaryButton),
                    contentAlignment = Alignment.Center
                ) {
                    Icon(imageVector = Icons.Filled.Settings, contentDescription = null, tint = Color.White, modifier = Modifier.size(14.dp))
                }
                Text(text = "Setting", style = MochiFont.title(26.sp), color = MochiColor.purple)
            }
        }
        Text(text = "Manage your app preferences", style = MochiFont.caption(12.sp), color = MochiColor.textSecondary)
    }
}

@Composable
private fun KeyboardSetupBanner() {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .clip(RoundedCornerShape(MochiRadius.card))
            .background(Color.White)
            .padding(MochiSpacing.md),
        verticalAlignment = Alignment.CenterVertically
    ) {
        IconTile(Icons.Filled.Keyboard)
        Column(modifier = Modifier.weight(1f).padding(horizontal = MochiSpacing.sm)) {
            Text(text = "Keyboard Setup Guide", style = MochiFont.heading(15.sp), color = MochiColor.purple)
            Text(text = "Learn how to set up Mochi as your default keyboard", style = MochiFont.caption(11.sp), color = MochiColor.textSecondary)
        }
        Row(
            modifier = Modifier
                .clip(RoundedCornerShape(MochiRadius.pill))
                .background(Color.White)
                .padding(horizontal = 4.dp)
                .then(Modifier),
            verticalAlignment = Alignment.CenterVertically
        ) {
            Row(
                modifier = Modifier
                    .clip(RoundedCornerShape(MochiRadius.pill))
                    .background(Color.White)
                    .padding(horizontal = 14.dp, vertical = 8.dp)
                    .then(Modifier),
                verticalAlignment = Alignment.CenterVertically,
                horizontalArrangement = Arrangement.spacedBy(4.dp)
            ) {
                Text(text = "Start Guide", style = MochiFont.caption(12.sp), color = MochiColor.purple)
                ChevronIcon()
            }
        }
    }
}

@Composable
private fun SettingsSection(title: String, content: @Composable ColumnScope.() -> Unit) {
    Column(verticalArrangement = Arrangement.spacedBy(MochiSpacing.sm)) {
        Text(text = title, style = MochiFont.heading(13.sp), color = MochiColor.textPrimary)
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .clip(RoundedCornerShape(MochiRadius.card))
                .background(Color.White)
                .padding(vertical = 4.dp),
            content = content
        )
    }
}

@Composable
private fun SettingsRow(icon: ImageVector, title: String, subtitle: String, trailing: @Composable () -> Unit) {
    Column {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .clickable {}
                .padding(horizontal = MochiSpacing.md, vertical = 12.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            IconTile(icon)
            Column(modifier = Modifier.weight(1f).padding(horizontal = MochiSpacing.sm)) {
                Text(text = title, style = MochiFont.heading(14.sp), color = MochiColor.textPrimary)
                Text(text = subtitle, style = MochiFont.caption(11.sp), color = MochiColor.textSecondary)
            }
            trailing()
        }
        androidx.compose.material3.HorizontalDivider(color = MochiColor.purple.copy(alpha = 0.08f), modifier = Modifier.padding(start = 68.dp))
    }
}

@Composable
private fun IconTile(icon: ImageVector) {
    Box(
        modifier = Modifier.size(40.dp).clip(RoundedCornerShape(10.dp)).background(MochiGradient.primaryButton),
        contentAlignment = Alignment.Center
    ) {
        Icon(imageVector = icon, contentDescription = null, tint = Color.White, modifier = Modifier.size(18.dp))
    }
}

@Composable
private fun ChevronIcon() {
    Text(text = "›", style = MochiFont.heading(18.sp), color = MochiColor.purple)
}

@Composable
private fun TrailingClear(value: String) {
    Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(8.dp)) {
        Text(text = value, style = MochiFont.body(13.sp), color = MochiColor.textSecondary)
        Row(
            modifier = Modifier
                .clip(RoundedCornerShape(MochiRadius.pill))
                .background(Color.White)
                .then(Modifier)
        ) {
            Box(
                modifier = Modifier
                    .clip(RoundedCornerShape(MochiRadius.pill))
                    .background(Color.White)
                    .padding(horizontal = 14.dp, vertical = 6.dp)
            ) {
                Text(text = "Clear", style = MochiFont.caption(12.sp), color = MochiColor.purple)
            }
        }
    }
}

@Composable
private fun ThemeModeToggle(isDark: Boolean, onChange: (Boolean) -> Unit) {
    Row(
        modifier = Modifier
            .clip(RoundedCornerShape(MochiRadius.pill))
            .background(MochiGradient.primaryButton)
            .padding(3.dp),
        verticalAlignment = Alignment.CenterVertically
    ) {
        ToggleOption(label = "Light", isSelected = !isDark) { onChange(false) }
        ToggleOption(label = "Dark", isSelected = isDark) { onChange(true) }
    }
}

@Composable
private fun ToggleOption(label: String, isSelected: Boolean, onClick: () -> Unit) {
    Box(
        modifier = Modifier
            .clip(RoundedCornerShape(MochiRadius.pill))
            .then(if (isSelected) Modifier.background(Color.White) else Modifier)
            .clickable(onClick = onClick)
            .padding(horizontal = 10.dp, vertical = 6.dp)
    ) {
        Text(text = label, style = MochiFont.caption(11.sp), color = if (isSelected) MochiColor.purple else Color.White)
    }
}
