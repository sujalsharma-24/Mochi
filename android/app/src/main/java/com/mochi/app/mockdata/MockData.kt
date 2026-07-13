package com.mochi.app.mockdata

import com.mochi.app.model.Creator
import com.mochi.app.model.FontItem
import com.mochi.app.model.KeyboardTheme

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
}
