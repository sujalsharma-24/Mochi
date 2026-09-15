import Foundation

/// Placeholder data standing in for Firestore reads until the data layer (TRD §3) is wired up.
///
/// **Themes are no longer mocked here.** Every theme-shaped row on Home, Community and Profile now
/// comes from `ThemeCatalog` — the real built-in catalogue — so a card always carries the id of the
/// theme it shows. The old literals were picture-only: ids like `"space-vibe"` matched no real
/// theme, so tapping one fell through `RenderableTheme.resolve`'s mood fallback and opened Cozy
/// Sakura Café's keyboard instead. Space Vibe, Forest Theme, Pastel Rainbow, Dreamy Fantasy and
/// Pastel Dream were also not in the theme source folder any more, so they are gone rather than
/// re-pointed. What is still mocked here is everything with no catalogue behind it: the signed-in
/// profile, creators, and the font collection.
enum MockData {
    /// Home's "Recently Applied" row — the editorial trio Home leads with.
    static var popularThemes: [KeyboardTheme] { ThemeCatalog.featured }

    /// Distinct from `popularThemes` (used by Recently Applied) so Home's Popular Themes row
    /// shows a different trio instead of accidentally repeating the row above it — this was
    /// a real bug on Android (session 6) fixed the same way, ported here.
    static var homePopularThemes: [KeyboardTheme] {
        let featured = Set(ThemeCatalog.featured.map(\.id))
        return Array(ThemeCatalog.topThemes(12).filter { !featured.contains($0.id) }.prefix(3))
    }

    static var latestCreations: [KeyboardTheme] { ThemeCatalog.latest(3) }

    static var allThemes: [KeyboardTheme] { ThemeCatalog.all }

    /// Home's font row, which only has room for four.
    static let fonts: [FontItem] = Array(fontCollection.prefix(4))

    /// The Fonts page's 2x3 grid (docs/figma/5.png). Nature Flow and Gothic Dark exist only here —
    /// they have no composed `font_*` tile, so their `previewAssetName` points at the art crop and
    /// they are kept out of `fonts` rather than shipped to Home with the wrong artwork.
    static let fontCollection: [FontItem] = [
        FontItem(id: "bubble-cute", name: "Bubble Cute", styleDescription: "Rounded & Playful", isPremium: false, previewAssetName: "font_bubble_cute", artAssetName: "fontart_bubble_cute", category: .cute, popularityRank: 2),
        FontItem(id: "handwritten-elegant", name: "Handwritten Elegant", styleDescription: "Smooth & Natural", isPremium: true, previewAssetName: "font_handwritten_elegant", artAssetName: "fontart_handwritten_elegant", category: .handwritten, popularityRank: 1),
        FontItem(id: "typewriter-classic", name: "Typewriter Classic", styleDescription: "Clean & Readable", isPremium: false, previewAssetName: "font_typewriter_classic", artAssetName: "fontart_typewriter_classic", category: .minimal, popularityRank: 4),
        FontItem(id: "bold-strong", name: "Bold Strong", styleDescription: "Bold & Impactful", isPremium: true, previewAssetName: "font_bold_strong", artAssetName: "fontart_bold_strong", category: .bold, popularityRank: 3),
        FontItem(id: "nature-flow", name: "Nature Flow", styleDescription: "Fresh & Calm", isPremium: false, previewAssetName: "fontart_nature_flow", artAssetName: "fontart_nature_flow", category: .elegant, popularityRank: 5),
        FontItem(id: "gothic-dark", name: "Gothic Dark", styleDescription: "Unique & Stylish", isPremium: true, previewAssetName: "fontart_gothic_dark", artAssetName: "fontart_gothic_dark", category: .other, popularityRank: 6)
    ]

    /// Figma's "MY DOWNLOADED FONTS" strip — the same six minus Typewriter Classic, in Figma's
    /// own order.
    static let downloadedFonts: [FontItem] = [
        fontCollection[0], fontCollection[1], fontCollection[3], fontCollection[4], fontCollection[5]
    ]

    // MARK: - Community tab (docs/figma/2.png)

    /// The ranked cards under Community's "TOP THEMES" — the catalogue's most-liked, so the medals
    /// mean something and each card opens its own theme.
    static var communityTopThemes: [KeyboardTheme] { ThemeCatalog.topThemes(8) }

    /// `ctaTitle` is "Choose" on the fourth tile because that is literally what Figma's Community
    /// frame shows — it reads like a copy-paste slip from Home's "Choose from Library" button, but
    /// it is reproduced here rather than silently corrected to "Follow".
    static let communityCreators: [CommunityCreator] = [
        CommunityCreator(id: "mochi-studio", name: "Mochi Studio", avatarAssetName: "avatar_mochi_studio", themeCount: 24, isVerified: true, ctaTitle: "Follow"),
        CommunityCreator(id: "sakura", name: "Sakura", avatarAssetName: "avatar_sakura", themeCount: 18, isVerified: true, ctaTitle: "Follow"),
        CommunityCreator(id: "starry", name: "Starry", avatarAssetName: "avatar_starry", themeCount: 15, isVerified: true, ctaTitle: "Follow"),
        CommunityCreator(id: "pastel-craft", name: "Pastel Craft", avatarAssetName: "avatar_pastel_craft", themeCount: 12, isVerified: true, ctaTitle: "Choose")
    ]

    /// Community's "Latest Creations" — the newest catalogue themes, as posts. Each one carries its
    /// real theme so the card opens, downloads and likes the theme it is showing; the summary is the
    /// theme's own description line from `ThemeSemantics`.
    static var communityLatest: [KeyboardTheme] { ThemeCatalog.latest(4) }

    // MARK: - Leaderboard / Ranked Creators (docs/figma/9.png)

    /// The "Ranked Creators" list, in rank order. Same shape as `topCreators` (reuses `Creator`);
    /// values mirror android's `MockData.rankedCreators`.
    /// Creator preview strips show real theme thumbnails, three each, walked across the catalogue
    /// so no two creators show the same trio.
    private static func previews(_ offset: Int) -> [String] {
        let themes = ThemeCatalog.topThemes(24)
        guard !themes.isEmpty else { return [] }
        return (0..<3).map { themes[(offset * 3 + $0) % themes.count].imageAssetName }
    }

    static let rankedCreators: [Creator] = [
        // avatar_mochi_creator is a mismatched asset (neon ring + camera-edit badge baked in, no
        // bear hoodie); avatar_sakura is the closest existing match to Figma's pink-haired girl
        // in art style/palette. Neither has the bear-hood art docs/figma/9.png shows — that
        // illustration doesn't exist in the catalog and would need a real asset export from Figma.
        Creator(id: "mochi-creator", displayName: "Mochi Creator", handle: "@mochicreator", avatarAssetName: "avatar_sakura", themeCount: 128, likeCount: 12_500, isFollowing: false, isVerified: true, previewAssetNames: previews(0)),
        Creator(id: "pixel-art-studio", displayName: "Pixel Art Studio", handle: "@pixelart.studio", avatarAssetName: "avatar_pixel_art", themeCount: 96, likeCount: 36_500, isFollowing: false, isVerified: true, previewAssetNames: previews(1)),
        Creator(id: "vibe-studio", displayName: "Vibe Studio", handle: "@vibestudio", avatarAssetName: "avatar_vibe_studio", themeCount: 84, likeCount: 10_800, isFollowing: false, isVerified: true, previewAssetNames: previews(2)),
        Creator(id: "dreamy-designs", displayName: "Dreamy Designs", handle: "@dreamydesigns", avatarAssetName: "avatar_dreamy_designs", themeCount: 72, likeCount: 8_800, isFollowing: true, isVerified: true, previewAssetNames: previews(3)),
        Creator(id: "techy-keys", displayName: "Techy Keys", handle: "@techy.keys", avatarAssetName: "avatar_techy_keys", themeCount: 63, likeCount: 68_800, isFollowing: false, isVerified: true, previewAssetNames: previews(4))
    ]

    // Wallpapers are real content now — see `WallpaperCatalog`, not MockData.

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

    /// MY CREATIONS. Tiles carry a real theme each, so tapping one opens that theme; the fourth is
    /// a Font, as the frame has it. Counts stay as the frame's strings — there is no real telemetry.
    static var profileCreations: [ProfileCreation] {
        let themes = ThemeCatalog.featured
        let counts = [("12.5K", "3.4K"), ("9.8K", "2.6K"), ("8.4K", "3.1K")]
        var rows = themes.prefix(3).enumerated().map { index, theme in
            ProfileCreation(id: "creation-\(theme.id)", themeID: theme.id, name: theme.name, kind: "Theme",
                            imageAssetName: theme.imageAssetName,
                            likes: counts[index].0, downloads: counts[index].1)
        }
        rows.append(ProfileCreation(id: "creation-sweet-handwriting", themeID: nil, name: "Sweet Handwriting",
                                    kind: "Font", imageAssetName: "font_typewriter_classic",
                                    likes: "755", downloads: "1.8K"))
        return rows
    }

    /// MY DOWNLOADS — the user's real downloaded themes (`DownloadedThemeStore`), newest first.
    /// Empty until they download something, which the screen renders as a prompt.
    static var profileDownloads: [ProfileCreation] {
        DownloadedThemeStore.loadDownloadedThemeIDs().reversed().compactMap { id in
            guard let theme = ThemeCatalog.theme(id: id) else { return nil }
            return ProfileCreation(id: "download-\(theme.id)", themeID: theme.id, name: theme.name,
                                   kind: "Theme", imageAssetName: theme.imageAssetName,
                                   likes: theme.likeCountFormatted, downloads: "")
        }
    }

    /// The Liked Themes card — the user's real likes (`LikedThemeStore`), newest first.
    static var profileLikedThemes: [ProfileLikedTheme] {
        LikedThemeStore.likedThemes().prefix(3).map { theme in
            ProfileLikedTheme(id: "liked-\(theme.id)", themeID: theme.id, name: theme.name,
                              creatorName: theme.creatorName, imageAssetName: theme.imageAssetName,
                              likes: theme.likeCountFormatted)
        }
    }

    static let profileFollowRows: [ProfileFollowRow] = [
        ProfileFollowRow(id: "followers", label: "Followers", value: "2.1K"),
        ProfileFollowRow(id: "following", label: "Following", value: "126")
    ]
}
