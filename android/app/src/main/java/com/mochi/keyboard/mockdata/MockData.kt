package com.mochi.keyboard.mockdata

import com.mochi.keyboard.model.CommunityCreator
import com.mochi.keyboard.model.CommunityPost
import com.mochi.keyboard.model.Creator
import com.mochi.keyboard.model.FontItem
import com.mochi.keyboard.model.KeyboardTheme
import com.mochi.keyboard.model.ProfileCreation
import com.mochi.keyboard.model.ProfileFollowRow
import com.mochi.keyboard.model.ProfileLikedTheme
import com.mochi.keyboard.model.ProfileSummary
import com.mochi.keyboard.model.TagPalette

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

    /** The Fonts page's 2x3 grid (docs/figma/5.png). Nature Flow and Gothic Dark exist only here —
     * they have no composed small `font_*` tile, so their previewAssetName points at the art crop
     * and they're kept out of `fonts` below rather than shipped to Home with the wrong artwork. */
    val fontCollection = listOf(
        FontItem("bubble-cute", "Bubble Cute", "Rounded & Playful", false, "font_bubble_cute", "fontart_bubble_cute"),
        FontItem("handwritten-elegant", "Handwritten Elegant", "Smooth & Natural", true, "font_handwritten_elegant", "fontart_handwritten_elegant"),
        FontItem("typewriter-classic", "Typewriter Classic", "Clean & Readable", false, "font_typewriter_classic", "fontart_typewriter_classic"),
        FontItem("bold-strong", "Bold Strong", "Bold & Impactful", true, "font_bold_strong", "fontart_bold_strong"),
        FontItem("nature-flow", "Nature Flow", "Fresh & Calm", false, "fontart_nature_flow", "fontart_nature_flow"),
        FontItem("gothic-dark", "Gothic Dark", "Unique & Stylish", true, "fontart_gothic_dark", "fontart_gothic_dark")
    )

    /** Home's font row, which only has room for four. */
    val fonts = fontCollection.take(4)

    /** Figma's "MY DOWNLOADED FONTS" strip — the same six minus Typewriter Classic, in Figma's own order. */
    val downloadedFonts = listOf(fontCollection[0], fontCollection[1], fontCollection[3], fontCollection[4], fontCollection[5])

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

    // Community tab (docs/figma/2.png)

    val communityTopThemes = listOf(
        KeyboardTheme("community-kawaii-boba", "kawaii boba tea", "Mochi Studio", "theme_kawaii_boba", 12_500, false, listOf("cute", "boba")),
        KeyboardTheme("community-sakura-train", "Sakura Train", "sakura", "theme_sakura_train", 9_800, false, listOf("sakura", "train")),
        KeyboardTheme("community-pastel-pink-sky", "Pastel Pink Sky", "Staeey", "theme_pastel_pink_sky", 9_800, false, listOf("pastel", "sunset"))
    )

    /** `ctaTitle` is "Choose" on the fourth tile because that's literally what Figma's Community
     * frame shows — reads like a copy-paste slip from Home's "Choose from Library" button, but
     * reproduced rather than silently corrected. */
    val communityCreators = listOf(
        CommunityCreator("mochi-studio", "Mochi Studio", "avatar_mochi_studio", 24, true, "Follow"),
        CommunityCreator("sakura", "Sakura", "avatar_sakura", 18, true, "Follow"),
        CommunityCreator("starry", "Starry", "avatar_starry", 15, true, "Follow"),
        CommunityCreator("pastel-craft", "Pastel Craft", "avatar_pastel_craft", 12, true, "Choose")
    )

    /** Summaries are title-cased and line-broken exactly as Figma sets them — the first card's
     * copy really does describe "cute frogs and nature vibes" over a purple sakura-café keyboard. */
    val communityLatest = listOf(
        CommunityPost("latest-cozy-sakura-cafe", "Cozy Sakura Café", "Lemonade", "latest_cozy_sakura_cafe", "A Soft Green Theme With Cute Frogs\nAnd Nature Vibes", 956, listOf("cute", "nature", "green"), TagPalette.GREEN),
        CommunityPost("latest-space-vibe", "Space Vibe", "Dreamer", "latest_space_vibe", "Fluffy Clouds And Calm Sky\nFor A Peaceful Typing", 956, listOf("blue", "soft", "aesthetic"), TagPalette.BLUE),
        CommunityPost("latest-dreamy-fantasy", "Dreamy Fantasy", "Kittyk", "latest_dreamy_fantasy", "Cozy Cafe Cats To Keep You\nCompany While Typing", 956, listOf("blue", "soft", "aesthetic"), TagPalette.PEACH)
    )
}
