import Foundation

/// Placeholder data standing in for Firestore reads until the data layer (TRD §3) is wired up.
enum MockData {
    static let popularThemes: [KeyboardTheme] = [
        KeyboardTheme(id: "fantasy-castle-night", name: "Fantasy Castle Night", creatorName: "Mochi Studio", imageAssetName: "theme_fantasy_castle_night", likeCount: 12_500, isPremium: true, hashtags: ["fantasy", "night", "purple"]),
        KeyboardTheme(id: "space-vibe", name: "Space vibe", creatorName: "sakura", imageAssetName: "theme_space_vibe", likeCount: 9_800, isPremium: false, hashtags: ["space", "aesthetic"]),
        KeyboardTheme(id: "dreamy-castle", name: "Dreamy Castle", creatorName: "Staeey", imageAssetName: "theme_dreamy_castle", likeCount: 9_800, isPremium: true, hashtags: ["dreamy", "sunset"])
    ]

    /// Distinct from `popularThemes` (used by Recently Applied) so Home's Popular Themes row
    /// shows Figma's actual trio instead of accidentally repeating the row above it — this was
    /// a real bug on Android (session 6) fixed the same way, ported here.
    static let homePopularThemes: [KeyboardTheme] = [
        KeyboardTheme(id: "cozy-sakura-cafe-home", name: "Cozy Sakura Café", creatorName: "Lemonade", imageAssetName: "theme_cozy_sakura_cafe", likeCount: 956, isPremium: true, hashtags: ["cute", "nature", "green"]),
        KeyboardTheme(id: "sakura-train-home", name: "Sakura Train", creatorName: "Dreamer", imageAssetName: "theme_sakura_train", likeCount: 1_200, isPremium: false, hashtags: ["sakura", "train"]),
        KeyboardTheme(id: "pastel-rainbow-home", name: "Pastel Rainbow", creatorName: "Elite Themes", imageAssetName: "theme_pastel_rainbow", likeCount: 12_500, isPremium: false, hashtags: ["rainbow", "pastel"])
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

    // MARK: - Themes tab (docs/figma/8.png)

    /// The 3x3 grid, in Figma's order, with Figma's creators and counts — none of which match
    /// `allThemes`, which is why this is its own array.
    ///
    /// `creatorName` carries the byline **exactly as the frame sets it**, prefix included. Figma
    /// writes "by Mochi Studio" / "by sakura" / "by Staeey" on the first row and then drops the
    /// "by" for the remaining six ("Meow Themes", "Galaxy Corp", ...). That is inconsistent, but it
    /// is what the design shows, so it is reproduced rather than normalised — the same call made
    /// for Community's "Choose" CTA and the Fonts frame's "Soft by".
    ///
    /// `imageAssetName` points at the `themeart_*` crops lifted straight out of 8.png at 640x440,
    /// not at the older `theme_*` tiles, which are differently framed and differently proportioned.
    static let themesGrid: [KeyboardTheme] = [
        KeyboardTheme(id: "themes-fantasy-castle-night", name: "Fantasy Castle Night", creatorName: "by Mochi Studio", imageAssetName: "themeart_fantasy_castle_night", likeCount: 12_500, isPremium: true, hashtags: ["fantasy", "night"]),
        KeyboardTheme(id: "themes-space-vibe", name: "Space vibe", creatorName: "by sakura", imageAssetName: "themeart_space_vibe", likeCount: 9_800, isPremium: false, hashtags: ["space", "aesthetic"]),
        KeyboardTheme(id: "themes-dreamy-castle", name: "Dreamy Castle", creatorName: "by Staeey", imageAssetName: "themeart_dreamy_castle", likeCount: 9_800, isPremium: true, hashtags: ["dreamy", "sunset"]),
        KeyboardTheme(id: "themes-pastel-pink-sky", name: "Pastel Pink Sky", creatorName: "Meow Themes", imageAssetName: "themeart_pastel_pink_sky", likeCount: 11_500, isPremium: true, hashtags: ["pastel", "sunset"]),
        KeyboardTheme(id: "themes-forest", name: "Forest Theme", creatorName: "Galaxy Corp", imageAssetName: "themeart_forest", likeCount: 5_800, isPremium: false, hashtags: ["nature", "green"]),
        KeyboardTheme(id: "themes-cozy-sakura-cafe", name: "Cozy Sakura Café", creatorName: "Vibe Studio", imageAssetName: "themeart_cozy_sakura_cafe", likeCount: 3_800, isPremium: true, hashtags: ["cute", "nature"]),
        KeyboardTheme(id: "themes-pastel-rainbow", name: "Pastel Rainbow", creatorName: "Elite Themes", imageAssetName: "themeart_pastel_rainbow", likeCount: 8_000, isPremium: false, hashtags: ["rainbow", "pastel"]),
        KeyboardTheme(id: "themes-sakura-train", name: "Sakura Train", creatorName: "Snowy Day", imageAssetName: "themeart_sakura_train", likeCount: 2_800, isPremium: false, hashtags: ["sakura", "train"]),
        KeyboardTheme(id: "themes-kawaii-boba", name: "kawaii boba tea", creatorName: "Pet World", imageAssetName: "themeart_kawaii_boba", likeCount: 1_800, isPremium: true, hashtags: ["cute", "boba"])
    ]

    /// The "MY DOWNLOADED THEMES" strip. Its four tiles are a *wider* crop of the same artwork
    /// (461x308 rather than 640x440), so they carry their own `themedl_*` assets.
    static let downloadedThemes: [KeyboardTheme] = [
        KeyboardTheme(id: "themes-dl-pastel-rainbow", name: "Pastel Rainbow", creatorName: "Elite Themes", imageAssetName: "themedl_pastel_rainbow", likeCount: 8_000, isPremium: false, hashtags: []),
        KeyboardTheme(id: "themes-dl-kawaii-boba", name: "kawaii boba tea", creatorName: "Pet World", imageAssetName: "themedl_kawaii_boba", likeCount: 1_800, isPremium: true, hashtags: []),
        KeyboardTheme(id: "themes-dl-forest", name: "Forest Theme", creatorName: "Galaxy Corp", imageAssetName: "themedl_forest", likeCount: 5_800, isPremium: false, hashtags: []),
        KeyboardTheme(id: "themes-dl-pastel-pink-sky", name: "Pastel Pink Sky", creatorName: "Meow Themes", imageAssetName: "themedl_pastel_pink_sky", likeCount: 11_500, isPremium: true, hashtags: [])
    ]

    /// Home's font row, which only has room for four.
    static let fonts: [FontItem] = Array(fontCollection.prefix(4))

    /// The Fonts page's 2x3 grid (docs/figma/5.png). Nature Flow and Gothic Dark exist only here —
    /// they have no composed `font_*` tile, so their `previewAssetName` points at the art crop and
    /// they are kept out of `fonts` rather than shipped to Home with the wrong artwork.
    static let fontCollection: [FontItem] = [
        FontItem(id: "bubble-cute", name: "Bubble Cute", styleDescription: "Rounded & Playful", isPremium: false, previewAssetName: "font_bubble_cute", artAssetName: "fontart_bubble_cute"),
        FontItem(id: "handwritten-elegant", name: "Handwritten Elegant", styleDescription: "Smooth & Natural", isPremium: true, previewAssetName: "font_handwritten_elegant", artAssetName: "fontart_handwritten_elegant"),
        FontItem(id: "typewriter-classic", name: "Typewriter Classic", styleDescription: "Clean & Readable", isPremium: false, previewAssetName: "font_typewriter_classic", artAssetName: "fontart_typewriter_classic"),
        FontItem(id: "bold-strong", name: "Bold Strong", styleDescription: "Bold & Impactful", isPremium: true, previewAssetName: "font_bold_strong", artAssetName: "fontart_bold_strong"),
        FontItem(id: "nature-flow", name: "Nature Flow", styleDescription: "Fresh & Calm", isPremium: false, previewAssetName: "fontart_nature_flow", artAssetName: "fontart_nature_flow"),
        FontItem(id: "gothic-dark", name: "Gothic Dark", styleDescription: "Unique & Stylish", isPremium: true, previewAssetName: "fontart_gothic_dark", artAssetName: "fontart_gothic_dark")
    ]

    /// Figma's "MY DOWNLOADED FONTS" strip — the same six minus Typewriter Classic, in Figma's
    /// own order.
    static let downloadedFonts: [FontItem] = [
        fontCollection[0], fontCollection[1], fontCollection[3], fontCollection[4], fontCollection[5]
    ]

    // MARK: - Community tab (docs/figma/2.png)

    /// The three ranked cards under Community's "TOP THEMES". Distinct from `popularThemes` —
    /// Figma's Community page leads with a different trio (and different creators/like counts)
    /// than Home does.
    static let communityTopThemes: [KeyboardTheme] = [
        KeyboardTheme(id: "community-kawaii-boba", name: "kawaii boba tea", creatorName: "Mochi Studio", imageAssetName: "theme_kawaii_boba", likeCount: 12_500, isPremium: false, hashtags: ["cute", "boba"]),
        KeyboardTheme(id: "community-sakura-train", name: "Sakura Train", creatorName: "sakura", imageAssetName: "theme_sakura_train", likeCount: 9_800, isPremium: false, hashtags: ["sakura", "train"]),
        KeyboardTheme(id: "community-pastel-pink-sky", name: "Pastel Pink Sky", creatorName: "Staeey", imageAssetName: "theme_pastel_pink_sky", likeCount: 9_800, isPremium: false, hashtags: ["pastel", "sunset"])
    ]

    /// `ctaTitle` is "Choose" on the fourth tile because that is literally what Figma's Community
    /// frame shows — it reads like a copy-paste slip from Home's "Choose from Library" button, but
    /// it is reproduced here rather than silently corrected to "Follow".
    static let communityCreators: [CommunityCreator] = [
        CommunityCreator(id: "mochi-studio", name: "Mochi Studio", avatarAssetName: "avatar_mochi_studio", themeCount: 24, isVerified: true, ctaTitle: "Follow"),
        CommunityCreator(id: "sakura", name: "Sakura", avatarAssetName: "avatar_sakura", themeCount: 18, isVerified: true, ctaTitle: "Follow"),
        CommunityCreator(id: "starry", name: "Starry", avatarAssetName: "avatar_starry", themeCount: 15, isVerified: true, ctaTitle: "Follow"),
        CommunityCreator(id: "pastel-craft", name: "Pastel Craft", avatarAssetName: "avatar_pastel_craft", themeCount: 12, isVerified: true, ctaTitle: "Choose")
    ]

    /// Summaries are title-cased exactly as Figma sets them, and the first card's copy really does
    /// describe "cute frogs and nature vibes" over a purple sakura-café keyboard — another mismatch
    /// carried over verbatim rather than rewritten.
    ///
    /// The line breaks are explicit because Figma's are: every card wraps well before its text
    /// column runs out ("...Cute Frogs / And Nature Vibes", not "...Cute Frogs And / Nature Vibes"),
    /// so the break is authored, not a consequence of the measure. Letting the text wrap naturally
    /// reproduced the right line *count* but the wrong break on two of the three cards.
    static let communityLatest: [CommunityPost] = [
        CommunityPost(id: "latest-cozy-sakura-cafe", name: "Cozy Sakura Café", creatorName: "Lemonade", thumbAssetName: "latest_cozy_sakura_cafe", summary: "A Soft Green Theme With Cute Frogs\nAnd Nature Vibes", likeCount: 956, hashtags: ["cute", "nature", "green"], tagPalette: .green),
        CommunityPost(id: "latest-space-vibe", name: "Space Vibe", creatorName: "Dreamer", thumbAssetName: "latest_space_vibe", summary: "Fluffy Clouds And Calm Sky\nFor A Peaceful Typing", likeCount: 956, hashtags: ["blue", "soft", "aesthetic"], tagPalette: .blue),
        CommunityPost(id: "latest-dreamy-fantasy", name: "Dreamy Fantasy", creatorName: "Kittyk", thumbAssetName: "latest_dreamy_fantasy", summary: "Cozy Cafe Cats To Keep You\nCompany While Typing", likeCount: 956, hashtags: ["blue", "soft", "aesthetic"], tagPalette: .peach)
    ]

    static let topCreators: [Creator] = [
        Creator(id: "mochi-creator", displayName: "Mochi Creator", handle: "@mochicreator", avatarAssetName: "avatar_mochi_creator", themeCount: 128, likeCount: 12_500, isFollowing: false, isVerified: true),
        Creator(id: "pixel-art-studio", displayName: "Pixel Art Studio", handle: "@pixelart.studio", avatarAssetName: "avatar_pixel_art", themeCount: 96, likeCount: 36_500, isFollowing: false, isVerified: true),
        Creator(id: "vibe-studio", displayName: "Vibe Studio", handle: "@vibestudio", avatarAssetName: "avatar_vibe_studio", themeCount: 84, likeCount: 10_800, isFollowing: false, isVerified: true),
        Creator(id: "dreamy-designs", displayName: "Dreamy Designs", handle: "@dreamydesigns", avatarAssetName: "avatar_dreamy_designs", themeCount: 72, likeCount: 8_800, isFollowing: true, isVerified: true)
    ]

    // MARK: - Profile tab (docs/figma/3.png)

    static let profile = ProfileSummary(
        displayName: "Mochi Creator",
        handle: "@mochicreator",
        bio: "Creating cute & colorful keyboard themes to make typing more fun!",
        avatarAssetName: "avatar_mochi_creator",
        isVerified: true,
        stats: [
            ProfileSummary.Stat(value: "128", label: "Creations"),
            ProfileSummary.Stat(value: "2.4K", label: "Followers"),
            ProfileSummary.Stat(value: "156", label: "Following")
        ]
    )

    /// The MY CREATIONS strip, in Figma's order. The fourth tile is a **Font**, not a theme — its
    /// artwork is the "Aa Typewriter Classic" card and its purple sub-line reads "Font" where the
    /// other three read "Theme" — so the row is deliberately mixed rather than themes-only.
    ///
    /// `imageAssetName` points at the existing full-keyboard tiles rather than at fresh crops from
    /// 3.png: they are the same artwork at better than twice the resolution. Two of them had to be
    /// re-cut, though — `theme_pastel_rainbow` and `themeart_forest` carry Figma's own round
    /// download badge baked into the top-right corner, and it sits further right than the disc
    /// ProfileView draws over it, so a sliver of the arrow showed past the edge. The badge is
    /// painted out in `profile_art_pastel_rainbow` and `theme_forest`; the originals are left as
    /// they are because the Themes grid draws that badge deliberately.
    static let profileCreations: [ProfileCreation] = [
        ProfileCreation(id: "creation-pastel-rainbow", name: "Pastel Rainbow", kind: "Theme", imageAssetName: "profile_art_pastel_rainbow", likes: "12.5K", downloads: "3.4K"),
        ProfileCreation(id: "creation-forest", name: "Forest Theme", kind: "Theme", imageAssetName: "theme_forest", likes: "908", downloads: "2.6K"),
        ProfileCreation(id: "creation-pastel-pink-sky", name: "Pastel Pink Sky", kind: "Theme", imageAssetName: "theme_pastel_pink_sky", likes: "12.5K", downloads: "3.1K"),
        ProfileCreation(id: "creation-sweet-handwriting", name: "Sweet Handwriting", kind: "Font", imageAssetName: "font_typewriter_classic", likes: "755", downloads: "1.8K")
    ]

    /// The MY DOWNLOADS strip. Only the like count shows on these tiles, so `downloads` is unused.
    static let profileDownloads: [ProfileCreation] = [
        ProfileCreation(id: "download-fantasy-castle-night", name: "Fantasy Castle Night", kind: "Theme", imageAssetName: "theme_fantasy_castle_night", likes: "825", downloads: ""),
        ProfileCreation(id: "download-forest", name: "Forest Theme", kind: "Theme", imageAssetName: "theme_forest", likes: "500", downloads: ""),
        ProfileCreation(id: "download-kawaii-boba", name: "kawaii boba tea", kind: "Theme", imageAssetName: "theme_kawaii_boba", likes: "10K", downloads: ""),
        ProfileCreation(id: "download-cozy-sakura-cafe", name: "Cozy Sakura Caf\u{00E9}", kind: "Theme", imageAssetName: "theme_cozy_sakura_cafe", likes: "12.5K", downloads: "")
    ]

    /// The three rows in the Liked Themes card. Their thumbnails are 153x128px crops lifted out of
    /// 3.png — "Pastel Dream" has no tile anywhere else in the catalogue, and cropping all three
    /// together keeps the row visually consistent.
    static let profileLikedThemes: [ProfileLikedTheme] = [
        ProfileLikedTheme(id: "liked-pastel-pink-sky", name: "Pastel Pink Sky", creatorName: "Vibe Studio", imageAssetName: "liked_pastel_pink_sky", likes: "2.1K"),
        ProfileLikedTheme(id: "liked-pastel-dream", name: "Pastel Dream", creatorName: "Dreamy Designs", imageAssetName: "liked_pastel_dream", likes: "1.6K"),
        ProfileLikedTheme(id: "liked-pastel-rainbow", name: "Pastel Rainbow", creatorName: "Clean Keys", imageAssetName: "liked_pastel_rainbow", likes: "2.3K")
    ]

    static let profileFollowRows: [ProfileFollowRow] = [
        ProfileFollowRow(id: "followers", label: "Followers", value: "2.1K"),
        ProfileFollowRow(id: "following", label: "Following", value: "126")
    ]
}
