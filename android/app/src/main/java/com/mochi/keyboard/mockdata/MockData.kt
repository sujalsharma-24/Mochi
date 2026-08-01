package com.mochi.keyboard.mockdata

import com.mochi.keyboard.model.Creator
import com.mochi.keyboard.model.FontItem
import com.mochi.keyboard.model.KeyboardTheme
import com.mochi.keyboard.model.ProfileCreation
import com.mochi.keyboard.model.ProfileFollowRow
import com.mochi.keyboard.model.ProfileLikedTheme
import com.mochi.keyboard.model.ProfileSummary

/** Ported from ios/MochiApp/MockData/MockData.swift — placeholder data until Firestore is wired up. */
object MockData {
    val popularThemes = listOf(
        KeyboardTheme("fantasy-castle-night", "Fantasy Castle Night", "Mochi Studio", "theme_fantasy_castle_night", 12_500, true, listOf("fantasy", "night", "purple")),
        KeyboardTheme("space-vibe", "Space vibe", "sakura", "theme_space_vibe", 9_800, false, listOf("space", "aesthetic")),
        KeyboardTheme("dreamy-castle", "Dreamy Castle", "Staeey", "theme_dreamy_castle", 9_800, true, listOf("dreamy", "sunset"))
    )

    val latestCreations = listOf(
        KeyboardTheme("cozy-sakura-cafe", "Cozy Sakura Café", "Lemonade", "theme_cozy_sakura_cafe", 956, true, listOf("cute", "nature", "green"), "A Soft Green Theme With Cute Frogs And Nature Vibes"),
        KeyboardTheme("space-vibe-2", "Space Vibe", "Dreamer", "theme_space_vibe", 956, false, listOf("blue", "soft", "aesthetic"), "Fluffy Clouds And Calm Sky For A Peaceful Typing"),
        KeyboardTheme("dreamy-fantasy", "Dreamy Fantasy", "Kittyk", "theme_dreamy_castle", 956, true, listOf("blue", "soft", "aesthetic"), "Cozy Cafe Cats To Keep You Company While Typing")
    )

    /** Community "Top Themes" ranking (screen 2) — same catalog entries, different order/medal ranks. */
    val topRankedThemes = listOf(
        KeyboardTheme("kawaii-boba-tea", "kawaii boba tea", "Mochi Studio", "theme_kawaii_boba", 12_500, true, listOf("cute", "boba")),
        KeyboardTheme("sakura-train", "Sakura Train", "sakura", "theme_sakura_train", 9_800, true, listOf("sakura", "night")),
        KeyboardTheme("pastel-pink-sky", "Pastel Pink Sky", "Staeey", "theme_pastel_pink_sky", 9_800, true, listOf("pastel", "sunset"))
    )

    val shopThemes = listOf(
        KeyboardTheme("fantasy-castle-night", "Fantasy Castle Night", "Mochi Studio", "theme_fantasy_castle_night", 12_500, true, listOf("fantasy", "night", "purple")),
        KeyboardTheme("space-vibe", "Space vibe", "sakura", "theme_space_vibe", 9_800, false, listOf("space", "aesthetic")),
        KeyboardTheme("dreamy-castle", "Dreamy Castle", "Staeey", "theme_dreamy_castle", 9_800, true, listOf("dreamy", "sunset")),
        KeyboardTheme("pastel-pink-sky", "Pastel Pink Sky", "Meow Themes", "theme_pastel_pink_sky", 11_500, true, listOf("pastel", "sunset")),
        KeyboardTheme("forest-theme", "Forest Theme", "Galaxy Corp", "theme_forest", 5_800, false, listOf("nature", "green")),
        KeyboardTheme("cozy-sakura-cafe-shop", "Cozy Sakura Café", "Vibe Studio", "theme_cozy_sakura_cafe", 3_800, true, listOf("cute", "nature", "green")),
        KeyboardTheme("pastel-rainbow", "Pastel Rainbow", "Elite Themes", "theme_pastel_rainbow", 8_200, false, listOf("rainbow", "pastel")),
        KeyboardTheme("sakura-train", "Sakura Train", "Lemonade", "theme_sakura_train", 7_400, true, listOf("sakura", "night")),
        KeyboardTheme("kawaii-boba-tea", "kawaii boba tea", "Mochi Studio", "theme_kawaii_boba", 1_800, true, listOf("cute", "boba"))
    )

    val downloadedThemes = listOf(
        shopThemes.first { it.id == "pastel-rainbow" },
        shopThemes.first { it.id == "kawaii-boba-tea" },
        shopThemes.first { it.id == "forest-theme" },
        shopThemes.first { it.id == "pastel-pink-sky" }
    )

    /** Home screen's "Popular Themes" row (docs/figma/1.png / 13.png) — a distinct trio from the
     * Recently Applied row above it, not the same popularThemes list reused. */
    val homePopularThemes = listOf(
        shopThemes.first { it.id == "cozy-sakura-cafe-shop" },
        shopThemes.first { it.id == "sakura-train" },
        shopThemes.first { it.id == "pastel-rainbow" }
    )

    val allThemes = popularThemes + latestCreations + shopThemes

    val fonts = listOf(
        FontItem("bubble-cute", "Bubble Cute", "Rounded & Playful", false, "font_bubble_cute"),
        FontItem("handwritten-elegant", "Handwritten Elegant", "Smooth & Natural", true, "font_handwritten_elegant"),
        FontItem("typewriter-classic", "Typewriter Classic", "Clean & Readable", false, "font_typewriter_classic"),
        FontItem("bold-strong", "Bold Strong", "Bold & Impactful", true, "font_bold_strong")
    )

    /** Popular Creators (screen 2) — matches Figma exactly (names, theme counts). */
    val topCreators = listOf(
        Creator("mochi-studio", "Mochi Studio", "@mochistudio", "avatar_mochi_studio", 24, 45_000, false, true),
        Creator("sakura", "Sakura", "@sakura", "avatar_sakura", 18, 32_000, false, true),
        Creator("starry", "Starry", "@starry", "avatar_starry", 15, 21_000, false, true),
        Creator("pastel-craft", "Pastel Craft", "@pastelcraft", "avatar_pastel_craft", 12, 15_000, false, true)
    )

    /** Ranked Creators leaderboard (screen 9) — a distinct creator set/order from Popular Creators. */
    val rankedCreators = listOf(
        Creator("mochi-creator", "Mochi Creator", "@mochicreator", "avatar_mochi_creator", 128, 12_500, false, true),
        Creator("pixel-art-studio", "Pixel Art Studio", "@pixelart.studio", "avatar_pixel_art", 96, 36_500, false, true),
        Creator("vibe-studio", "Vibe Studio", "@vibestudio", "avatar_vibe_studio", 84, 10_800, false, true),
        Creator("dreamy-designs", "Dreamy Designs", "@dreamydesigns", "avatar_dreamy_designs", 72, 8_800, true, true),
        Creator("techy-keys", "Techy Keys", "@techy.keys", "avatar_techy_keys", 63, 68_800, false, true)
    )

    // Profile tab (docs/figma/3.png)

    val profile = ProfileSummary(
        displayName = "Mochi Creator",
        handle = "@mochicreator",
        bio = "Creating cute & colorful keyboard themes to make typing more fun!",
        avatarAssetName = "avatar_mochi_creator",
        isVerified = true,
        stats = listOf(
            ProfileSummary.Stat("128", "Creations"),
            ProfileSummary.Stat("2.4K", "Followers"),
            ProfileSummary.Stat("156", "Following")
        )
    )

    /** MY CREATIONS strip, in Figma's order. The fourth tile is a Font, not a theme. */
    val profileCreations = listOf(
        ProfileCreation("creation-pastel-rainbow", "Pastel Rainbow", "Theme", "profile_art_pastel_rainbow", "12.5K", "3.4K"),
        ProfileCreation("creation-forest", "Forest Theme", "Theme", "theme_forest", "908", "2.6K"),
        ProfileCreation("creation-pastel-pink-sky", "Pastel Pink Sky", "Theme", "theme_pastel_pink_sky", "12.5K", "3.1K"),
        ProfileCreation("creation-sweet-handwriting", "Sweet Handwriting", "Font", "font_typewriter_classic", "755", "1.8K")
    )

    /** MY DOWNLOADS strip — only the like count shows on these tiles. */
    val profileDownloads = listOf(
        ProfileCreation("download-fantasy-castle-night", "Fantasy Castle Night", "Theme", "theme_fantasy_castle_night", "825", ""),
        ProfileCreation("download-forest", "Forest Theme", "Theme", "theme_forest", "500", ""),
        ProfileCreation("download-kawaii-boba", "kawaii boba tea", "Theme", "theme_kawaii_boba", "10K", ""),
        ProfileCreation("download-cozy-sakura-cafe", "Cozy Sakura Café", "Theme", "theme_cozy_sakura_cafe", "12.5K", "")
    )

    val profileLikedThemes = listOf(
        ProfileLikedTheme("liked-pastel-pink-sky", "Pastel Pink Sky", "Vibe Studio", "liked_pastel_pink_sky", "2.1K"),
        ProfileLikedTheme("liked-pastel-dream", "Pastel Dream", "Dreamy Designs", "liked_pastel_dream", "1.6K"),
        ProfileLikedTheme("liked-pastel-rainbow", "Pastel Rainbow", "Clean Keys", "liked_pastel_rainbow", "2.3K")
    )

    val profileFollowRows = listOf(
        ProfileFollowRow("followers", "Followers", "2.1K"),
        ProfileFollowRow("following", "Following", "126")
    )
}
