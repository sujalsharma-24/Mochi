package com.mochi.keyboard.data

import androidx.compose.runtime.Composable
import androidx.compose.ui.platform.LocalContext
import androidx.lifecycle.ViewModel
import androidx.lifecycle.ViewModelProvider
import androidx.lifecycle.viewmodel.CreationExtras
import com.mochi.keyboard.MochiApplication
import com.mochi.keyboard.features.auth.AuthViewModel
import com.mochi.keyboard.features.community.CommunityViewModel
import com.mochi.keyboard.features.create.CreateThemeViewModel
import com.mochi.keyboard.features.home.HomeViewModel
import com.mochi.keyboard.features.leaderboard.LeaderboardViewModel
import com.mochi.keyboard.features.paywall.PaywallViewModel
import com.mochi.keyboard.features.search.SearchViewModel
import com.mochi.keyboard.features.settings.SettingsViewModel
import com.mochi.keyboard.features.themes.ThemesViewModel
import com.mochi.keyboard.features.wallpapers.WallpaperViewModel

/** One factory for every ViewModel, since there's no DI framework wiring `@Inject` constructors —
 * add a branch here whenever a new screen gets a ViewModel. Screens whose ViewModel needs a
 * per-navigation argument (e.g. ThemeDetailViewModel's themeId) don't fit this shared single-
 * instance-per-class factory and build their own inline factory instead - see ThemeDetailScreen.kt. */
class ViewModelFactory(private val container: AppContainer) : ViewModelProvider.Factory {
    @Suppress("UNCHECKED_CAST")
    override fun <T : ViewModel> create(modelClass: Class<T>, extras: CreationExtras): T =
        when (modelClass) {
            HomeViewModel::class.java -> HomeViewModel(container.themeRepository) as T
            AuthViewModel::class.java -> AuthViewModel(container.authRepository) as T
            ThemesViewModel::class.java -> ThemesViewModel(container.themeRepository) as T
            CommunityViewModel::class.java -> CommunityViewModel(
                container.themeRepository,
                container.likeRepository,
                container.followRepository,
                container.reportRepository,
                container.authRepository
            ) as T
            CreateThemeViewModel::class.java -> CreateThemeViewModel(
                container.createRepository,
                container.storageRepository,
                container.authRepository
            ) as T
            SettingsViewModel::class.java -> SettingsViewModel(
                container.settingsRepository,
                container.authRepository,
                container.userRepository
            ) as T
            PaywallViewModel::class.java -> PaywallViewModel(container.billingRepository) as T
            SearchViewModel::class.java -> SearchViewModel(
                container.themeRepository,
                container.userRepository,
                container.followRepository,
                container.searchHistoryRepository,
                container.authRepository
            ) as T
            LeaderboardViewModel::class.java -> LeaderboardViewModel(
                container.userRepository,
                container.followRepository,
                container.authRepository
            ) as T
            WallpaperViewModel::class.java -> WallpaperViewModel(
                container.wallpaperRepository,
                container.wallpaperLibraryRepository,
                container.billingRepository
            ) as T
            else -> throw IllegalArgumentException("Unknown ViewModel class: ${modelClass.name}")
        }
}

@Composable
fun rememberMochiViewModelFactory(): ViewModelFactory {
    val application = LocalContext.current.applicationContext as MochiApplication
    return ViewModelFactory(application.container)
}
