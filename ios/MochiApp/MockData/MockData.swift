import Foundation

/// Placeholder data standing in for Firestore reads until the data layer (TRD §3) is wired up.
enum MockData {
    static let popularThemes: [KeyboardTheme] = [
        KeyboardTheme(id: "fantasy-castle-night", name: "Fantasy Castle Night", creatorName: "Mochi Studio", imageAssetName: "theme_fantasy_castle_night", likeCount: 12_500, isPremium: true, hashtags: ["fantasy", "night", "purple"]),
        KeyboardTheme(id: "space-vibe", name: "Space vibe", creatorName: "sakura", imageAssetName: "theme_space_vibe", likeCount: 9_800, isPremium: false, hashtags: ["space", "aesthetic"]),
        KeyboardTheme(id: "dreamy-castle", name: "Dreamy Castle", creatorName: "Staeey", imageAssetName: "theme_dreamy_castle", likeCount: 9_800, isPremium: true, hashtags: ["dreamy", "sunset"])
    ]

    static let latestCreations: [KeyboardTheme] = [
        KeyboardTheme(id: "cozy-sakura-cafe", name: "Cozy Sakura Café", creatorName: "Lemonade", imageAssetName: "theme_cozy_sakura_cafe", likeCount: 956, isPremium: true, hashtags: ["cute", "nature", "green"]),
        KeyboardTheme(id: "space-vibe-2", name: "Space Vibe", creatorName: "Dreamer", imageAssetName: "theme_space_vibe", likeCount: 956, isPremium: false, hashtags: ["blue", "soft", "aesthetic"]),
        KeyboardTheme(id: "dreamy-fantasy", name: "Dreamy Fantasy", creatorName: "Kittyk", imageAssetName: "theme_dreamy_castle", likeCount: 956, isPremium: true, hashtags: ["blue", "soft", "aesthetic"])
    ]

    static let allThemes: [KeyboardTheme] = popularThemes + latestCreations + [
        KeyboardTheme(id: "pastel-pink-sky", name: "Pastel Pink Sky", creatorName: "Meow Themes", imageAssetName: "theme_pastel_pink_sky", likeCount: 11_500, isPremium: true, hashtags: ["pastel", "sunset"]),
        KeyboardTheme(id: "forest-theme", name: "Forest Theme", creatorName: "Galaxy Corp", imageAssetName: "theme_forest", likeCount: 5_800, isPremium: false, hashtags: ["nature", "green"]),
        KeyboardTheme(id: "pastel-rainbow", name: "Pastel Rainbow", creatorName: "Elite Themes", imageAssetName: "theme_pastel_rainbow", likeCount: 12_500, isPremium: false, hashtags: ["rainbow", "pastel"]),
        KeyboardTheme(id: "kawaii-boba-tea", name: "kawaii boba tea", creatorName: "Mochi Studio", imageAssetName: "theme_kawaii_boba", likeCount: 1_800, isPremium: true, hashtags: ["cute", "boba"])
    ]

    static let fonts: [FontItem] = [
        FontItem(id: "bubble-cute", name: "Bubble Cute", styleDescription: "Rounded & Playful", isPremium: false, previewAssetName: "font_bubble_cute"),
        FontItem(id: "handwritten-elegant", name: "Handwritten Elegant", styleDescription: "Smooth & Natural", isPremium: true, previewAssetName: "font_handwritten_elegant"),
        FontItem(id: "typewriter-classic", name: "Typewriter Classic", styleDescription: "Clean & Readable", isPremium: false, previewAssetName: "font_typewriter_classic"),
        FontItem(id: "bold-strong", name: "Bold Strong", styleDescription: "Bold & Impactful", isPremium: true, previewAssetName: "font_bold_strong")
    ]

    static let topCreators: [Creator] = [
        Creator(id: "mochi-creator", displayName: "Mochi Creator", handle: "@mochicreator", avatarAssetName: "avatar_mochi_creator", themeCount: 128, likeCount: 12_500, isFollowing: false, isVerified: true),
        Creator(id: "pixel-art-studio", displayName: "Pixel Art Studio", handle: "@pixelart.studio", avatarAssetName: "avatar_pixel_art", themeCount: 96, likeCount: 36_500, isFollowing: false, isVerified: true),
        Creator(id: "vibe-studio", displayName: "Vibe Studio", handle: "@vibestudio", avatarAssetName: "avatar_vibe_studio", themeCount: 84, likeCount: 10_800, isFollowing: false, isVerified: true),
        Creator(id: "dreamy-designs", displayName: "Dreamy Designs", handle: "@dreamydesigns", avatarAssetName: "avatar_dreamy_designs", themeCount: 72, likeCount: 8_800, isFollowing: true, isVerified: true)
    ]
}
