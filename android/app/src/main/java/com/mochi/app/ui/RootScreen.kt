package com.mochi.app.ui

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.tooling.preview.Preview
import com.mochi.app.components.MochiTabBar
import com.mochi.app.designsystem.MochiFont
import com.mochi.app.designsystem.MochiGradient
import com.mochi.app.features.community.CommunityScreen
import com.mochi.app.features.create.CreateThemeScreen
import com.mochi.app.features.fonts.FontsScreen
import com.mochi.app.features.home.HomeScreen
import com.mochi.app.features.themes.ThemesScreen
import com.mochi.app.model.KeyboardTheme

/** Ported from ios/MochiApp/App/RootView.swift */
@Composable
fun RootScreen(
    modifier: Modifier = Modifier,
    onThemeClick: (KeyboardTheme) -> Unit = {},
    onProfileClick: () -> Unit = {},
    onSearchClick: () -> Unit = {},
    onLeaderboardClick: () -> Unit = {},
    onWallpapersClick: () -> Unit = {}
) {
    var selected by remember { mutableStateOf(MochiTab.KEYBOARD) }

    Box(modifier = modifier.fillMaxSize()) {
        Box(modifier = Modifier.fillMaxSize()) {
            when (selected) {
                MochiTab.KEYBOARD -> HomeScreen(
                    onThemeClick = onThemeClick,
                    onCreateTabClick = { selected = MochiTab.CREATE },
                    onChooseTabClick = { selected = MochiTab.THEMES }
                )
                MochiTab.FONTS -> FontsScreen(onSearchClick = onSearchClick)
                MochiTab.THEMES -> ThemesScreen(onSearchClick = onSearchClick, onWallpapersClick = onWallpapersClick)
                MochiTab.COMMUNITY -> CommunityScreen(
                    onProfileClick = onProfileClick,
                    onSearchClick = onSearchClick,
                    onThemeClick = onThemeClick,
                    onLeaderboardClick = onLeaderboardClick
                )
                MochiTab.CREATE -> CreateThemeScreen()
                else -> ComingSoonScreen(selected)
            }
        }

        MochiTabBar(
            selected = selected,
            onSelect = { selected = it },
            modifier = Modifier.align(Alignment.BottomCenter)
        )
    }
}

@Preview(showBackground = true, widthDp = 393, heightDp = 852)
@Composable
private fun RootScreenPreview() {
    RootScreen()
}

/** Placeholder for tabs not yet ported from the iOS SwiftUI build — see project todo list. */
@Composable
private fun ComingSoonScreen(tab: MochiTab) {
    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(MochiGradient.background),
        verticalArrangement = androidx.compose.foundation.layout.Arrangement.Center,
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        Text(text = "${tab.title} — coming soon", style = MochiFont.heading())
    }
}
