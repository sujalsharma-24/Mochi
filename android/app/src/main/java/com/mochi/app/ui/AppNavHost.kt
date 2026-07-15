package com.mochi.app.ui

import androidx.compose.runtime.Composable
import androidx.navigation.NavType
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.rememberNavController
import androidx.navigation.navArgument
import com.mochi.app.features.auth.AuthScreen
import com.mochi.app.features.leaderboard.LeaderboardScreen
import com.mochi.app.features.onboarding.OnboardingScreen
import com.mochi.app.features.onboarding.SplashScreen
import com.mochi.app.features.paywall.PaywallScreen
import com.mochi.app.features.profile.ProfileScreen
import com.mochi.app.features.search.SearchScreen
import com.mochi.app.features.settings.SettingsScreen
import com.mochi.app.features.themedetail.ThemeDetailScreen
import com.mochi.app.features.wallpapers.WallpaperExploreScreen
import com.mochi.app.mockdata.MockData

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

    NavHost(navController = navController, startDestination = Route.SPLASH) {
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
            val theme = MockData.allThemes.firstOrNull { it.id == themeId } ?: MockData.popularThemes.first()
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
