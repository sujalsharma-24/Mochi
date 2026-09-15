import Foundation

/// The marketplace catalogue for the Themes screen, derived from the app's **real** theme system.
///
/// `BuiltInThemes.all` (MochiShared) is the source of truth — 28 fully-authored `MochiKeyboardTheme`
/// render documents, each with its own commissioned `themebg_*` background plate. This file bridges
/// each of those to the `KeyboardTheme` marketplace-metadata shape the browse UIs pass around
/// (`ThemesView`, `AppRoute.themeDetail`, `RenderableTheme.resolve`), so a theme card shows the
/// theme it will actually apply and previews the exact render document behind it.
///
/// **Why a derived `map`, not a hand-written list like `MockData.fontCollection`.** Nothing upstream
/// generates the font collection, so it is a literal. Here `BuiltInThemes.all` *is* the generator:
/// mapping over it means the 29th theme shows up in the catalogue automatically (with default
/// metadata) instead of silently going missing, and an id/name can never drift between the card and
/// the render document because both come from the same `MochiKeyboardTheme`.
///
/// **What is genuinely placeholder here.** The render documents and background art are real. The
/// marketplace metadata below — `category`, `likeCount`, `isPremium`, `hashtags` — has no source
/// anywhere in the project yet (there is no Firestore data, no apply/download telemetry). It is
/// hand-authored the same way `FontItem.popularityRank` is, and carries the same promise: replace
/// it with real values once the backend lands. `likeCount` doubles as the "Popular" sort key so the
/// placeholder number does one real job.
enum ThemeCatalog {

    /// The editorial metadata that is not derivable from a `MochiKeyboardTheme`.
    struct Meta {
        var category: ThemeCategory
        var likeCount: Int
        var isPremium: Bool
        var hashtags: [String]
        /// Set for the themes Home showcases. Floats them to the front of the Themes grid's default
        /// sort (see `ThemeSortOption.popular`) and swaps their thumbnail for a composited-keyboard
        /// mockup — see `composedThumbnail`.
        var featuredRank: Int? = nil

        static let `default` = Meta(category: .other, likeCount: 0, isPremium: false, hashtags: [])
    }

    /// Every theme browses as a render of **its own keyboard**, not as its raw `themebg_*` plate.
    ///
    /// The plate is honest but shows no keys, so a grid of it told the user nothing about what they
    /// would actually get — and only the three themes with hand-made marketing mockups looked
    /// finished. `themethumb_*` closes that: one image per theme, produced by rendering the real
    /// `KeyboardSurfaceView` for every built-in (see `ThemeSnapshotHarness`, DEBUG), so a card can
    /// never drift from the theme behind it and every card in the catalogue reads the same way.
    static func thumbnailName(forThemeID id: String) -> String {
        "themethumb_" + id
            .replacingOccurrences(of: "mochi.", with: "")
            .replacingOccurrences(of: "-", with: "_")
    }

    /// The six themes that ship a hand-made marketing tile keep it — it is better art than any
    /// render, and it is what these themes have always browsed as. Everything else uses its
    /// `themethumb_*` render. (Space Vibe, Forest Theme and Pastel Rainbow had tiles too, but no
    /// theme behind them and no artwork left in the source folder, so they are gone entirely.)
    static let composedThumbnail: [String: String] = [
        "mochi.fantasy-castle-night": "theme_fantasy_castle_night",
        "mochi.dreamy-castle":        "theme_dreamy_castle",
        "mochi.cozy-sakura-cafe":     "theme_cozy_sakura_cafe",
        "mochi.kawaii-boba-tea":      "theme_kawaii_boba",
        "mochi.pastel-pink-sky":      "theme_pastel_pink_sky",
        "mochi.sakura-train":         "theme_sakura_train",
    ]

    /// The catalogue byline. Every built-in theme is `authorName: "Mochi"`; the marketplace UI has
    /// always written this as "Mochi Studio", so that is reproduced rather than normalised.
    static let creatorName = "Mochi Studio"

    /// Keyed by `MochiKeyboardTheme.id`. See the type doc on what is placeholder. Category choices:
    ///  * **cute**    — candy / kawaii / carnival palettes
    ///  * **cozy**    — cafés, cottages, farms, warm interiors
    ///  * **dreamy**  — castles, moons, mermaids, aurora, witchy magic
    ///  * **nature**  — gardens, forests, matcha/zen greenery
    ///  * **elegant** — Paris, ateliers, vintage writing desks, royal sunsets
    ///  * **other**   — the ones that fit none of the above cleanly (bold glow, open ocean, beach)
    static let meta: [String: Meta] = [
        "mochi.cozy-sakura-cafe":         Meta(category: .cozy,    likeCount: 8_400,  isPremium: false, hashtags: ["sakura", "night", "cozy"], featuredRank: 3),
        "mochi.fantasy-castle-night":     Meta(category: .dreamy,  likeCount: 12_500, isPremium: true,  hashtags: ["fantasy", "castle", "night"], featuredRank: 1),
        "mochi.dreamy-castle":            Meta(category: .dreamy,  likeCount: 9_800,  isPremium: true,  hashtags: ["dreamy", "castle", "sunset"], featuredRank: 2),
        // Batch 8 — the three that were picture-only cards until now. They lead the catalogue's
        // "Newest", so they carry counts in the same range as the other showcase themes.
        "mochi.kawaii-boba-tea":          Meta(category: .cute,    likeCount: 7_600,  isPremium: false, hashtags: ["boba", "cute", "cream"], featuredRank: 5),
        "mochi.pastel-pink-sky":          Meta(category: .dreamy,  likeCount: 11_500, isPremium: true,  hashtags: ["pastel", "sky", "pink"], featuredRank: 4),
        "mochi.sakura-train":             Meta(category: .dreamy,  likeCount: 9_200,  isPremium: false, hashtags: ["sakura", "spring", "purple"], featuredRank: 6),
        "mochi.aurora-winter-wonderland": Meta(category: .dreamy,  likeCount: 10_200, isPremium: true,  hashtags: ["aurora", "winter", "snow"]),
        "mochi.cozy-countryside-farm":    Meta(category: .cozy,    likeCount: 3_100,  isPremium: false, hashtags: ["farm", "countryside", "cozy"]),
        "mochi.lavender-moon-garden":     Meta(category: .nature,  likeCount: 6_700,  isPremium: true,  hashtags: ["lavender", "moon", "garden"]),
        "mochi.magenta-midnight-glow":    Meta(category: .other,   likeCount: 4_500,  isPremium: true,  hashtags: ["magenta", "midnight", "glow"]),
        "mochi.midnight-ocean-voyage":    Meta(category: .other,   likeCount: 5_000,  isPremium: false, hashtags: ["ocean", "night", "voyage"]),
        "mochi.moonlit-magic":            Meta(category: .dreamy,  likeCount: 6_300,  isPremium: false, hashtags: ["moon", "magic", "stars"]),
        "mochi.mystic-green-haven":       Meta(category: .nature,  likeCount: 4_200,  isPremium: false, hashtags: ["green", "mystic", "nature"]),
        "mochi.royal-sunset-atelier":     Meta(category: .elegant, likeCount: 7_800,  isPremium: true,  hashtags: ["sunset", "royal", "elegant"]),
        "mochi.vintage-writer-evening":   Meta(category: .elegant, likeCount: 3_600,  isPremium: false, hashtags: ["vintage", "writer", "evening"]),
        "mochi.zen-garden":               Meta(category: .nature,  likeCount: 5_500,  isPremium: false, hashtags: ["zen", "garden", "calm"]),
        "mochi.autumn-cozy-cottage":      Meta(category: .cozy,    likeCount: 4_800,  isPremium: false, hashtags: ["autumn", "cottage", "cozy"]),
        "mochi.cozy-cottagecore-studio":  Meta(category: .cozy,    likeCount: 5_900,  isPremium: true,  hashtags: ["cottagecore", "studio", "cozy"]),
        "mochi.enchanted-garden-cafe":    Meta(category: .cozy,    likeCount: 4_000,  isPremium: false, hashtags: ["garden", "cafe", "enchanted"]),
        "mochi.enchanted-witchy-night":   Meta(category: .dreamy,  likeCount: 6_600,  isPremium: true,  hashtags: ["witchy", "night", "magic"]),
        "mochi.kawaii-strawberry-dream":  Meta(category: .cute,    likeCount: 8_100,  isPremium: true,  hashtags: ["kawaii", "strawberry", "pink"]),
        "mochi.lavender-paris-night":     Meta(category: .elegant, likeCount: 9_200,  isPremium: true,  hashtags: ["paris", "lavender", "night"]),
        "mochi.matcha-garden":            Meta(category: .nature,  likeCount: 4_700,  isPremium: false, hashtags: ["matcha", "green", "garden"]),
        "mochi.mermaid-dreamscape":       Meta(category: .dreamy,  likeCount: 7_400,  isPremium: true,  hashtags: ["mermaid", "ocean", "dream"]),
        "mochi.midnight-cafe":            Meta(category: .cozy,    likeCount: 5_200,  isPremium: false, hashtags: ["cafe", "midnight", "cozy"]),
        "mochi.moonlit-beach-escape":     Meta(category: .other,   likeCount: 4_900,  isPremium: false, hashtags: ["beach", "moonlit", "ocean"]),
        "mochi.starlit-dream-cafe":       Meta(category: .cozy,    likeCount: 6_100,  isPremium: true,  hashtags: ["starlit", "cafe", "dream"]),
        "mochi.aurora-frontier":                       Meta(category: .dreamy, likeCount: 11189, isPremium: false, hashtags: ["dreamy", "aurora", "frontier"]),
        "mochi.aurora-timber-lodge":                   Meta(category: .cozy, likeCount: 10505, isPremium: true, hashtags: ["cozy", "aurora", "timber"]),
        "mochi.azure-summer-escape":                   Meta(category: .elegant, likeCount: 5431, isPremium: true, hashtags: ["elegant", "azure", "summer"]),
        "mochi.beyond-the-horizon":                    Meta(category: .dreamy, likeCount: 11376, isPremium: true, hashtags: ["dreamy", "beyond", "horizon"]),
        "mochi.bionova-nexus":                         Meta(category: .other, likeCount: 5309, isPremium: false, hashtags: ["other", "bionova", "nexus"]),
        "mochi.botanical-cafe":                        Meta(category: .nature, likeCount: 11388, isPremium: false, hashtags: ["nature", "botanical", "cafe"]),
        "mochi.canvas-and-coffee":                     Meta(category: .cozy, likeCount: 5106, isPremium: true, hashtags: ["cozy", "canvas", "coffee"]),
        "mochi.captured-moments":                      Meta(category: .cozy, likeCount: 10968, isPremium: false, hashtags: ["cozy", "captured", "moments"]),
        "mochi.cozy-garden-cottage":                   Meta(category: .nature, likeCount: 3690, isPremium: true, hashtags: ["nature", "cozy", "garden"]),
        "mochi.creative-workspace":                    Meta(category: .cozy, likeCount: 4772, isPremium: false, hashtags: ["cozy", "creative", "workspace"]),
        "mochi.deep-sea-explorer":                     Meta(category: .dreamy, likeCount: 3286, isPremium: true, hashtags: ["dreamy", "deep", "sea"]),
        "mochi.dreams-in-rewind":                      Meta(category: .other, likeCount: 9292, isPremium: false, hashtags: ["other", "dreams", "rewind"]),
        "mochi.emberwatch-observatory":                Meta(category: .elegant, likeCount: 8565, isPremium: true, hashtags: ["elegant", "emberwatch", "observatory"]),
        "mochi.golden-midway":                         Meta(category: .cute, likeCount: 11776, isPremium: true, hashtags: ["cute", "golden", "midway"]),
        "mochi.iron-and-ember-loft":                   Meta(category: .other, likeCount: 6341, isPremium: true, hashtags: ["other", "iron", "ember"]),
        "mochi.japanese-zen":                          Meta(category: .nature, likeCount: 8136, isPremium: true, hashtags: ["nature", "japanese", "zen"]),
        "mochi.midnight-carnival":                     Meta(category: .cute, likeCount: 11072, isPremium: false, hashtags: ["cute", "midnight", "carnival"]),
        "mochi.midnight-voyage":                       Meta(category: .dreamy, likeCount: 10907, isPremium: false, hashtags: ["dreamy", "midnight", "voyage"]),
        "mochi.neon-roller-nights":                    Meta(category: .other, likeCount: 9885, isPremium: true, hashtags: ["other", "neon", "roller"]),
        "mochi.parisian-morning":                      Meta(category: .elegant, likeCount: 3243, isPremium: false, hashtags: ["elegant", "parisian", "morning"]),
        "mochi.the-wanderers-cabin":                   Meta(category: .cozy, likeCount: 8507, isPremium: false, hashtags: ["cozy", "wanderers", "cabin"]),
        "mochi.toymakers-memories":                    Meta(category: .cute, likeCount: 8886, isPremium: true, hashtags: ["cute", "toymakers", "memories"]),
        "mochi.velvet-reel-reverie":                   Meta(category: .elegant, likeCount: 9864, isPremium: false, hashtags: ["elegant", "velvet", "reel"]),
        "mochi.whispers-of-the-sewing-hearth":         Meta(category: .cozy, likeCount: 3040, isPremium: true, hashtags: ["cozy", "whispers", "sewing"]),
        "mochi.enchanted-midnight-library":            Meta(category: .dreamy, likeCount: 10116, isPremium: true, hashtags: ["dreamy", "enchanted", "midnight"]),
        "mochi.moonlit-meow-cafe":                     Meta(category: .cozy, likeCount: 6759, isPremium: false, hashtags: ["cozy", "moonlit", "meow"]),
        "mochi.mystic-ocean-atelier":                  Meta(category: .elegant, likeCount: 5068, isPremium: false, hashtags: ["elegant", "mystic", "ocean"]),
        "mochi.neon-dream-district":                   Meta(category: .cute, likeCount: 5505, isPremium: true, hashtags: ["cute", "neon", "dream"]),
        "mochi.sweetdream-carnival":                   Meta(category: .cute, likeCount: 8879, isPremium: false, hashtags: ["cute", "sweetdream", "carnival"]),
        "mochi.wanderlust-scrapbook":                  Meta(category: .cozy, likeCount: 9449, isPremium: false, hashtags: ["cozy", "wanderlust", "scrapbook"]),
        "mochi.whispering-mushroom-cottage":           Meta(category: .nature, likeCount: 11534, isPremium: false, hashtags: ["nature", "whispering", "mushroom"]),
        "mochi.astral-gearworks":                      Meta(category: .other, likeCount: 7269, isPremium: false, hashtags: ["other", "astral", "gearworks"]),
        "mochi.egypt-through-time":                    Meta(category: .elegant, likeCount: 7664, isPremium: false, hashtags: ["elegant", "egypt", "time"]),
        "mochi.galaxy-mart":                           Meta(category: .cute, likeCount: 11868, isPremium: false, hashtags: ["cute", "galaxy", "mart"]),
        "mochi.midnight-racing-garage":                Meta(category: .other, likeCount: 6331, isPremium: true, hashtags: ["other", "midnight", "racing"]),
        "mochi.moonlit-hydrangea":                     Meta(category: .nature, likeCount: 3011, isPremium: true, hashtags: ["nature", "moonlit", "hydrangea"]),
        "mochi.pirate-treasure-night":                 Meta(category: .dreamy, likeCount: 10953, isPremium: false, hashtags: ["dreamy", "pirate", "treasure"]),
        "mochi.starlit-90s-haven":                     Meta(category: .cute, likeCount: 4148, isPremium: false, hashtags: ["cute", "starlit", "s"]),
        "mochi.starlit-disco-reverie":                 Meta(category: .cute, likeCount: 4975, isPremium: true, hashtags: ["cute", "starlit", "disco"]),
        "mochi.sunset-mirage":                         Meta(category: .elegant, likeCount: 7555, isPremium: true, hashtags: ["elegant", "sunset", "mirage"]),
        "mochi.aether-garden":                         Meta(category: .dreamy, likeCount: 6867, isPremium: true, hashtags: ["dreamy", "aether", "garden"]),
        "mochi.aurora-moonlit-observatory":            Meta(category: .dreamy, likeCount: 9489, isPremium: false, hashtags: ["dreamy", "aurora", "moonlit"]),
        "mochi.cosmic-daydream-station":               Meta(category: .dreamy, likeCount: 4476, isPremium: true, hashtags: ["dreamy", "cosmic", "daydream"]),
        "mochi.starlit-cozy-village":                  Meta(category: .cozy, likeCount: 9579, isPremium: false, hashtags: ["cozy", "starlit", "village"]),
        "mochi.sunset-storybook-journey":              Meta(category: .cozy, likeCount: 7741, isPremium: false, hashtags: ["cozy", "sunset", "storybook"]),
        "mochi.tidebound-atelier":                     Meta(category: .elegant, likeCount: 3964, isPremium: true, hashtags: ["elegant", "tidebound", "atelier"]),
        "mochi.whispering-lake-cottage":               Meta(category: .cozy, likeCount: 11792, isPremium: false, hashtags: ["cozy", "whispering", "lake"]),
        "mochi.whispering-moon-harbor":                Meta(category: .cozy, likeCount: 5828, isPremium: false, hashtags: ["cozy", "whispering", "moon"]),
        "mochi.willow-moon-cottage":                   Meta(category: .cozy, likeCount: 7288, isPremium: true, hashtags: ["cozy", "willow", "moon"]),
        "mochi.botanical-workshop":                            Meta(category: .nature, likeCount: 3188, isPremium: false, hashtags: ["nature", "botanical", "workshop"]),
        "mochi.candy-bakery":                                  Meta(category: .cute, likeCount: 11573, isPremium: true, hashtags: ["cute", "candy", "bakery"]),
        "mochi.cosmic-astronaut":                              Meta(category: .dreamy, likeCount: 11892, isPremium: false, hashtags: ["dreamy", "cosmic", "astronaut"]),
        "mochi.cozy-cat":                                      Meta(category: .cozy, likeCount: 9890, isPremium: false, hashtags: ["cozy", "cozy", "cat"]),
        "mochi.cozy-night-keyboard":                           Meta(category: .cozy, likeCount: 4548, isPremium: true, hashtags: ["cozy", "cozy", "night"]),
        "mochi.cozy-terrarium":                                Meta(category: .nature, likeCount: 4109, isPremium: true, hashtags: ["nature", "cozy", "terrarium"]),
        "mochi.dreamy-garden":                                 Meta(category: .nature, likeCount: 7185, isPremium: false, hashtags: ["nature", "dreamy", "garden"]),
        "mochi.kawaii-cosmic-study":                           Meta(category: .cute, likeCount: 6395, isPremium: true, hashtags: ["cute", "kawaii", "cosmic"]),
        "mochi.kawaii-ocean-night":                            Meta(category: .cute, likeCount: 6455, isPremium: true, hashtags: ["cute", "kawaii", "ocean"]),
        "mochi.neon-racing-garage":                            Meta(category: .other, likeCount: 5241, isPremium: true, hashtags: ["other", "neon", "racing"]),
        "mochi.pastel-lakeside-carnival":                      Meta(category: .cute, likeCount: 3497, isPremium: false, hashtags: ["cute", "pastel", "lakeside"]),
        "mochi.pastel-underwater":                             Meta(category: .dreamy, likeCount: 9314, isPremium: false, hashtags: ["dreamy", "pastel", "underwater"]),
        "mochi.prehistoric-fossil-explorer":                   Meta(category: .other, likeCount: 6056, isPremium: true, hashtags: ["other", "prehistoric", "fossil"]),
        "mochi.retro-arcade":                                  Meta(category: .other, likeCount: 6210, isPremium: false, hashtags: ["other", "retro", "arcade"]),
        "mochi.sakura-night-kawaii-landscape":                 Meta(category: .dreamy, likeCount: 10276, isPremium: true, hashtags: ["dreamy", "sakura", "night"]),
        "mochi.seaside-postcard":                              Meta(category: .elegant, likeCount: 9307, isPremium: true, hashtags: ["elegant", "seaside", "postcard"]),
        "mochi.sunset-music-studio":                           Meta(category: .elegant, likeCount: 4038, isPremium: false, hashtags: ["elegant", "sunset", "music"]),
        "mochi.whimsical-world":                               Meta(category: .dreamy, likeCount: 11607, isPremium: false, hashtags: ["dreamy", "whimsical", "world"]),
        "mochi.witchy-potion-shop":                            Meta(category: .dreamy, likeCount: 6114, isPremium: true, hashtags: ["dreamy", "witchy", "potion"]),
        "mochi.abyssal-neon-haven":                            Meta(category: .other, likeCount: 11140, isPremium: false, hashtags: ["other", "abyssal", "neon"]),
        "mochi.adventure-awaits":                              Meta(category: .other, likeCount: 8917, isPremium: true, hashtags: ["other", "adventure", "awaits"]),
        "mochi.alien-moonlift":                                Meta(category: .other, likeCount: 3570, isPremium: false, hashtags: ["other", "alien", "moonlift"]),
        "mochi.blooming-gardenia":                             Meta(category: .nature, likeCount: 3012, isPremium: false, hashtags: ["nature", "blooming", "gardenia"]),
        "mochi.clockwork-horizon":                             Meta(category: .elegant, likeCount: 3015, isPremium: false, hashtags: ["elegant", "clockwork", "horizon"]),
        "mochi.cosmic-little-visitors":                        Meta(category: .cute, likeCount: 4615, isPremium: false, hashtags: ["cute", "cosmic", "little"]),
        "mochi.cosmic-observatory":                            Meta(category: .dreamy, likeCount: 9309, isPremium: false, hashtags: ["dreamy", "cosmic", "observatory"]),
        "mochi.cozy-yarn-haven":                               Meta(category: .cozy, likeCount: 10805, isPremium: false, hashtags: ["cozy", "cozy", "yarn"]),
        "mochi.dragonlight-valley":                            Meta(category: .dreamy, likeCount: 6175, isPremium: false, hashtags: ["dreamy", "dragonlight", "valley"]),
        "mochi.firework-dream-festival":                       Meta(category: .cute, likeCount: 11179, isPremium: false, hashtags: ["cute", "firework", "dream"]),
        "mochi.forgotten-ruins":                               Meta(category: .other, likeCount: 6471, isPremium: true, hashtags: ["other", "forgotten", "ruins"]),
        "mochi.frosted-crystal-cavern":                        Meta(category: .dreamy, likeCount: 10660, isPremium: true, hashtags: ["dreamy", "frosted", "crystal"]),
        "mochi.jurassic-sunset-park":                          Meta(category: .other, likeCount: 6130, isPremium: true, hashtags: ["other", "jurassic", "sunset"]),
        "mochi.kitebound-sunset":                              Meta(category: .elegant, likeCount: 7121, isPremium: false, hashtags: ["elegant", "kitebound", "sunset"]),
        "mochi.meadow-morning":                                Meta(category: .nature, likeCount: 5132, isPremium: true, hashtags: ["nature", "meadow", "morning"]),
        "mochi.moonlit-potion-lab":                            Meta(category: .dreamy, likeCount: 7799, isPremium: false, hashtags: ["dreamy", "moonlit", "potion"]),
        "mochi.mystery-at-dusk":                               Meta(category: .other, likeCount: 5667, isPremium: false, hashtags: ["other", "mystery", "at"]),
        "mochi.neon-code-haven":                               Meta(category: .other, likeCount: 4474, isPremium: true, hashtags: ["other", "neon", "code"]),
        "mochi.neural-dreamscape":                             Meta(category: .other, likeCount: 7735, isPremium: false, hashtags: ["other", "neural", "dreamscape"]),
        "mochi.oceanic-dreamscape":                            Meta(category: .dreamy, likeCount: 9510, isPremium: true, hashtags: ["dreamy", "oceanic", "dreamscape"]),
        "mochi.sakura-serenity":                               Meta(category: .cozy, likeCount: 3933, isPremium: false, hashtags: ["cozy", "sakura", "serenity"]),
        "mochi.skyward-explorer":                              Meta(category: .other, likeCount: 11820, isPremium: true, hashtags: ["other", "skyward", "explorer"]),
        "mochi.skyward-reverie":                               Meta(category: .dreamy, likeCount: 6552, isPremium: true, hashtags: ["dreamy", "skyward", "reverie"]),
        "mochi.starlit-orbit":                                 Meta(category: .dreamy, likeCount: 9738, isPremium: true, hashtags: ["dreamy", "starlit", "orbit"]),
        "mochi.wanderlight-loft":                              Meta(category: .cozy, likeCount: 5695, isPremium: false, hashtags: ["cozy", "wanderlight", "loft"]),

        // Batch 7 -- ~/Downloads/THEMES!! (see scratchpad/gen_b7.py).
        "mochi.alien-playtopia":           Meta(category: .cute,   likeCount:  6_800, isPremium: false, hashtags: ["alien", "pastel", "space"]),
        "mochi.bubblegum-circuit":         Meta(category: .cute,   likeCount:  9_400, isPremium: true,  hashtags: ["bubblegum", "city", "sunset"]),
        "mochi.dreamscape-portal":         Meta(category: .dreamy, likeCount:  8_100, isPremium: true,  hashtags: ["portal", "clouds", "gold"]),
        "mochi.dreamy-control-room":       Meta(category: .cozy,   likeCount:  5_900, isPremium: false, hashtags: ["cozy", "window", "clouds"]),
        "mochi.enchanted-glass-garden":    Meta(category: .nature, likeCount:  7_300, isPremium: false, hashtags: ["garden", "lake", "misty"]),
        "mochi.floating-dreamscape":       Meta(category: .dreamy, likeCount:  8_700, isPremium: false, hashtags: ["moon", "sunset", "float"]),
        "mochi.glitch-garden":             Meta(category: .other,  likeCount:  6_100, isPremium: true,  hashtags: ["glitch", "torii", "neon"]),
        "mochi.holographic-daydream":      Meta(category: .dreamy, likeCount: 10_500, isPremium: true,  hashtags: ["holo", "blossom", "city"]),
        "mochi.liquid-aurora":             Meta(category: .elegant,likeCount:  9_100, isPremium: true,  hashtags: ["chrome", "liquid", "silver"]),
        "mochi.miniature-greenhouse":      Meta(category: .nature, likeCount:  6_600, isPremium: false, hashtags: ["greenhouse", "glass", "green"]),
        "mochi.moon-arcade-dreams":        Meta(category: .other,  likeCount: 11_200, isPremium: true,  hashtags: ["arcade", "neon", "night"]),
        "mochi.neon-aquarium":             Meta(category: .other,  likeCount:  8_300, isPremium: false, hashtags: ["ocean", "jellyfish", "neon"]),
        "mochi.pastel-beyond":             Meta(category: .dreamy, likeCount:  7_700, isPremium: false, hashtags: ["pastel", "castle", "sky"]),
        "mochi.pixel-pet-dreams":          Meta(category: .cute,   likeCount:  7_000, isPremium: false, hashtags: ["pixel", "pets", "dusk"]),
        "mochi.pocket-city-dreams":        Meta(category: .cozy,   likeCount:  6_400, isPremium: false, hashtags: ["city", "lantern", "bridge"]),
        "mochi.pocket-cosmos":             Meta(category: .cozy,   likeCount:  5_600, isPremium: false, hashtags: ["cosmos", "desk", "study"]),
        "mochi.prismatic-jelly-dreams":    Meta(category: .dreamy, likeCount:  9_900, isPremium: true,  hashtags: ["prism", "jelly", "iridescent"]),
        "mochi.puzzlewood-adventures":     Meta(category: .cozy,   likeCount:  6_900, isPremium: false, hashtags: ["woodland", "night", "stars"]),
        "mochi.reflective-dreamworld":     Meta(category: .elegant,likeCount:  8_500, isPremium: true,  hashtags: ["reflection", "cathedral", "violet"]),
        "mochi.ruins-and-relics":          Meta(category: .other,  likeCount:  5_200, isPremium: false, hashtags: ["desert", "ruins", "gold"]),
    ]

    /// The full catalogue, in `BuiltInThemes.all` order. This is what the Themes grid browses and
    /// what every non-`.data` `ThemesViewModel` state falls back to.
    ///
    /// Category and hashtags come from `ThemeSemantics` — derived from each theme's own name and
    /// the measured colours of its own plate — rather than from the table above, whose values for
    /// the generated batches were placeholders ("other" was being shown as a hashtag). The table
    /// still owns like counts, the premium flag and the featured order, which are editorial.
    static let all: [KeyboardTheme] = BuiltInThemes.all.map { built in
        var resolved = meta[built.id] ?? .default
        if let semantics = ThemeSemantics.entry(for: built.id) {
            resolved.category = semantics.category
            resolved.hashtags = semantics.tags
        }
        return KeyboardTheme(builtIn: built, meta: resolved,
                             blurb: ThemeSemantics.entry(for: built.id)?.blurb ?? "")
    }

    /// The three themes Home and the Themes grid lead with, in editorial order.
    static var featured: [KeyboardTheme] {
        all.filter { $0.featuredRank != nil }
            .sorted { ($0.featuredRank ?? .max) < ($1.featuredRank ?? .max) }
    }

    /// Most-liked first — what Community's "Top Themes" row ranks.
    static func topThemes(_ count: Int) -> [KeyboardTheme] {
        Array(all.sorted { $0.likeCount > $1.likeCount }.prefix(count))
    }

    /// Newest first. There are no real dates, so "newest" is reverse catalogue order — the same
    /// rule the Themes screen's "Newest" sort uses (a theme added later sits later in `all`).
    static func latest(_ count: Int) -> [KeyboardTheme] {
        Array(all.reversed().prefix(count))
    }

    /// Look one up by its canonical id — used to resolve the downloaded-ids list and any
    /// id-carrying navigation back to a full catalogue entry.
    static func theme(id: String) -> KeyboardTheme? {
        all.first { $0.id == id }
    }
}

extension KeyboardTheme {
    /// Bridges one authored render document to a marketplace catalogue entry. `id` and `name` come
    /// straight from the `MochiKeyboardTheme` so they can never disagree with what
    /// `RenderableTheme.resolve` will render; `imageAssetName` is the theme's own background plate.
    init(builtIn: MochiKeyboardTheme, meta: ThemeCatalog.Meta, blurb: String = "") {
        let plateName: String
        if case .bundled(let name)? = builtIn.surface.backgroundImage?.source {
            plateName = name
        } else {
            // Every current built-in ships bundled plate art; this only guards a future art-free
            // theme, which the thumbnail view renders as its gradient fallback.
            plateName = ""
        }

        // Its own marketing tile if it has one, otherwise a render of its own keyboard; the plate is
        // the last fallback, for a theme whose thumbnail has not been generated yet (a published
        // custom theme, say).
        let rendered = ThemeCatalog.thumbnailName(forThemeID: builtIn.id)
        let thumbnail = ThemeCatalog.composedThumbnail[builtIn.id]
            ?? (ThemeArtAvailability.hasArt(rendered) ? rendered : plateName)

        self.init(
            id: builtIn.id,
            name: builtIn.name,
            creatorName: ThemeCatalog.creatorName,
            imageAssetName: thumbnail,
            likeCount: meta.likeCount,
            isPremium: meta.isPremium,
            hashtags: meta.hashtags,
            description: blurb,
            creatorUid: "",
            downloadCount: 0,
            category: meta.category,
            featuredRank: meta.featuredRank
        )
    }
}
