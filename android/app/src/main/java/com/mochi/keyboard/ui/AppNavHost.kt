package com.mochi.keyboard.ui

import androidx.compose.runtime.Composable
import androidx.compose.runtime.remember
import androidx.navigation.NavType
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.rememberNavController
import androidx.navigation.navArgument
import com.google.firebase.auth.FirebaseAuth
import com.mochi.keyboard.data.ThemeCache
import com.mochi.keyboard.features.auth.AuthScreen
import com.mochi.keyboard.features.leaderboard.LeaderboardScreen
import com.mochi.keyboard.features.onboarding.OnboardingScreen
import com.mochi.keyboard.features.onboarding.SplashScreen
import com.mochi.keyboard.features.paywall.PaywallScreen
import com.mochi.keyboard.features.profile.ProfileScreen
import com.mochi.keyboard.features.search.SearchScreen
import com.mochi.keyboard.features.settings.SettingsScreen
import com.mochi.keyboard.features.themedetail.ThemeDetailScreen
import com.mochi.keyboard.features.wallpapers.WallpaperExploreScreen
import com.mochi.keyboard.mockdata.MockData

private object Route {
    const val SPLASH = "splash"
    const val ONBOARDING = "onboarding"
    const val AUTH = "auth"
    const val MAIN = "main"
    const val THEME_DETAIL = "themeDetail/{themeId}"
    const val PAYWALL = "paywall"
    const val PROFILE = "profile"
    const val SETTINGS = "settings"
    const val SEARCH = "search"
    const val LEADERBOARD = "leaderboard"
    const val WALLPAPERS = "wallpapers"
}

/** Real click-through navigation graph tying every screen together, so the app can be run and
 * tapped through end-to-end instead of only viewed one @Preview at a time. */
@Composable
fun AppNavHost() {
    val navController = rememberNavController()
    // Firebase Auth persists its session locally already - an already-signed-in user skips
    // Splash/Onboarding/Auth entirely on relaunch rather than replaying them every time.
    val startDestination = remember {
        if (FirebaseAuth.getInstance().currentUser != null) Route.MAIN else Route.SPLASH
    }

    NavHost(navController = navController, startDestination = startDestination) {
        composable(Route.SPLASH) {
            SplashScreen(onTimeout = {
                navController.navigate(Route.ONBOARDING) { popUpTo(Route.SPLASH) { inclusive = true } }
            })
        }
        composable(Route.ONBOARDING) {
            OnboardingScreen(onFinished = {
                navController.navigate(Route.AUTH) { popUpTo(Route.ONBOARDING) { inclusive = true } }
            })
        }
        composable(Route.AUTH) {
            AuthScreen(onAuthenticated = {
                navController.navigate(Route.MAIN) { popUpTo(Route.AUTH) { inclusive = true } }
            })
        }
        composable(Route.MAIN) {
            RootScreen(
                onThemeClick = { theme -> navController.navigate("themeDetail/${theme.id}") },
                onProfileClick = { navController.navigate(Route.PROFILE) },
                onSearchClick = { navController.navigate(Route.SEARCH) },
                onLeaderboardClick = { navController.navigate(Route.LEADERBOARD) },
                onWallpapersClick = { navController.navigate(Route.WALLPAPERS) }
            )
        }
        composable(
            Route.THEME_DETAIL,
            arguments = listOf(navArgument("themeId") { type = NavType.StringType })
        ) { backStackEntry ->
            val themeId = backStackEntry.arguments?.getString("themeId")
            // Real Firestore-backed themes (from Home) live in ThemeCache, not MockData -
            // check there first and fall back to MockData for screens not yet converted off it.
            val theme = themeId?.let(ThemeCache::get)
                ?: MockData.allThemes.firstOrNull { it.id == themeId }
                ?: MockData.popularThemes.first()
            ThemeDetailScreen(
                theme = theme,
                onBack = { navController.popBackStack() },
                onUnlockPremium = { navController.navigate(Route.PAYWALL) }
            )
        }
        composable(Route.PAYWALL) {
            PaywallScreen(onClose = { navController.popBackStack() })
        }
        composable(Route.PROFILE) {
            ProfileScreen(
                onBack = { navController.popBackStack() },
                onSettingsClick = { navController.navigate(Route.SETTINGS) },
                onPaywallClick = { navController.navigate(Route.PAYWALL) }
            )
        }
        composable(Route.SETTINGS) {
            SettingsScreen(onBack = { navController.popBackStack() })
        }
        composable(Route.SEARCH) {
            SearchScreen(onBack = { navController.popBackStack() })
        }
        composable(Route.LEADERBOARD) {
            LeaderboardScreen(
                onBack = { navController.popBackStack() },
                onSearchClick = { navController.navigate(Route.SEARCH) }
            )
        }
        composable(Route.WALLPAPERS) {
            WallpaperExploreScreen()
        }
    }
}
