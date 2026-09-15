import Foundation

/// The relevance vocabulary behind Search.
///
/// There is no text index and no ML model in this project (see `SearchView`'s header note), so
/// "search for `night` and get the dark themes even when the word `night` isn't in the title" is
/// done with a small hand-authored lexicon instead. Each **concept** lists the everyday words that
/// point at it. The map is authored one way (`concept -> surface terms`) and inverted once at load
/// (`term -> concepts`), then the *same* inversion is run over both the query and every catalogue
/// item's own text — so "night" finding "midnight" and "midnight" finding "night" are the one rule,
/// not two. `SearchEngine` does the scoring; this file is only the vocabulary.
///
/// Everything here describes the real built-in catalogue (`ThemeCatalog.meta` hashtags/categories,
/// `MochiData.fontCollection` style descriptions). It is placeholder in the same sense
/// `ThemeCatalog`'s like counts are: replace it with real tags/telemetry once a backend exists.
enum SearchConcepts {

    /// `concept -> the words a user might type that mean it`. Single words only — the tokenizer
    /// splits everything to words before lookup, so multi-word phrases would never match.
    static let lexicon: [String: [String]] = [
        "night":       ["night", "nighttime", "midnight", "nocturnal", "evening", "dusk", "twilight", "moonlit", "moonlight", "dark", "darkness", "late"],
        "dark":        ["dark", "darkness", "gothic", "goth", "black", "shadow", "shadows", "noir", "deep", "moody", "grunge"],
        "moon":        ["moon", "moonlit", "moonlight", "lunar", "crescent", "luna"],
        "star":        ["star", "stars", "starlit", "starry", "starlight", "celestial", "constellation", "cosmic", "sparkle", "sparkles", "sparkly", "sparkling", "twinkle", "glitter", "glittery"],
        "galaxy":      ["galaxy", "galactic", "space", "cosmos", "cosmic", "nebula", "universe", "astro", "interstellar"],
        "glow":        ["glow", "glowing", "shiny", "shine", "shines", "shining", "glossy", "gloss", "neon", "luminous", "radiant", "bright", "brilliant", "gleam", "iridescent", "shimmer", "shimmery"],
        "aurora":      ["aurora", "borealis", "northern"],
        "magic":       ["magic", "magical", "mystic", "mystical", "enchanted", "enchanting", "enchantment", "witch", "witchy", "spell", "sorcery", "fairy", "fairytale", "wizard", "wonder"],
        "dream":       ["dream", "dreamy", "dreams", "dreamscape", "dreaming", "whimsical", "ethereal", "surreal", "fantasy", "imaginary", "fantastical"],
        "castle":      ["castle", "castles", "palace", "kingdom", "fortress", "citadel", "tower", "royal", "royalty", "medieval", "knight", "princess", "prince", "crown"],
        "cute":        ["cute", "cutesy", "kawaii", "adorable", "sweet", "lovely", "charming", "precious", "chibi", "cuddly", "darling"],
        "playful":     ["playful", "fun", "quirky", "bouncy", "cheerful", "happy", "joyful", "bubbly", "rounded"],
        "pink":        ["pink", "rose", "rosy", "blush", "magenta", "fuchsia", "cherry", "strawberry", "bubblegum", "flamingo", "salmon", "coral"],
        "sakura":      ["sakura", "cherry", "blossom", "blossoms", "hanami", "petal", "petals"],
        "purple":      ["purple", "lavender", "violet", "lilac", "plum", "orchid", "mauve", "amethyst", "grape"],
        "pastel":      ["pastel", "pastels", "soft", "muted", "pale", "gentle", "faded", "dreamy", "light"],
        "cozy":        ["cozy", "cosy", "warm", "comfy", "comfortable", "snug", "homey", "hygge", "wholesome", "calm", "relaxing"],
        "cafe":        ["cafe", "café", "coffee", "espresso", "latte", "tea", "matcha", "boba", "bakery", "brunch", "bistro"],
        "nature":      ["nature", "natural", "botanical", "outdoors", "earthy", "organic", "wild", "wilderness", "flora"],
        "forest":      ["forest", "forests", "woods", "woodland", "jungle", "trees", "tree", "pine", "grove"],
        "garden":      ["garden", "gardens", "greenhouse", "meadow", "cottagecore", "florist", "backyard"],
        "flower":      ["flower", "flowers", "floral", "bloom", "blooms", "blooming", "botanical", "bouquet", "daisy", "rose", "lavender"],
        "green":       ["green", "mint", "emerald", "sage", "jade", "olive", "moss", "matcha", "verdant", "lime"],
        "zen":         ["zen", "calm", "calming", "peaceful", "serene", "serenity", "tranquil", "meditative", "meditation", "mindful", "quiet", "still"],
        "ocean":       ["ocean", "oceans", "sea", "seas", "water", "wave", "waves", "marine", "nautical", "aqua", "aquatic", "underwater", "mermaid", "coastal", "seaside", "tide"],
        "beach":       ["beach", "beaches", "shore", "seashore", "sand", "sandy", "tropical", "island", "palm", "surf", "summer"],
        "winter":      ["winter", "wintry", "snow", "snowy", "snowfall", "frost", "frosty", "ice", "icy", "frozen", "cold", "arctic", "chilly", "glacial"],
        "autumn":      ["autumn", "fall", "harvest", "pumpkin", "maple", "amber", "rustic"],
        "sunset":      ["sunset", "sunrise", "sundown", "dusk", "dawn", "twilight", "horizon", "golden", "orange"],
        "elegant":     ["elegant", "elegance", "luxury", "luxurious", "classy", "sophisticated", "chic", "refined", "fancy", "posh", "glam", "glamorous", "opulent", "regal", "graceful", "smooth"],
        "paris":       ["paris", "parisian", "french", "france", "eiffel"],
        "vintage":     ["vintage", "retro", "antique", "old", "nostalgic", "timeless", "classic", "aged", "sepia", "heritage"],
        "handwritten": ["handwritten", "handwriting", "cursive", "script", "calligraphy", "calligraphic", "penmanship", "signature", "scrawl", "scribble", "ink", "pen"],
        "typewriter":  ["typewriter", "typewritten", "monospace", "mechanical", "keys", "typist"],
        "minimal":     ["minimal", "minimalist", "minimalistic", "simple", "clean", "plain", "basic", "modern", "sleek", "tidy", "understated", "readable", "crisp"],
        "bold":        ["bold", "strong", "thick", "heavy", "impactful", "powerful", "loud", "statement", "chunky", "punchy", "assertive", "confident", "unique", "stylish"],
        "carnival":    ["carnival", "circus", "fair", "fairground", "festival", "ferris", "parade", "amusement"],
        "farm":        ["farm", "farmhouse", "countryside", "rural", "barn", "ranch", "pasture", "meadow", "country"],
        "cottage":     ["cottage", "cottagecore", "cabin", "chalet", "hut", "lodge"],
        "fresh":       ["fresh", "freshness", "airy", "breezy", "clean", "crisp", "cool", "light"],
        // Colour and tone words. Every theme now carries the measured dominant colours of its own
        // background plate (`ThemeSemantics`), so these are real search axes rather than guesses.
        "blue":        ["blue", "azure", "cobalt", "navy", "indigo", "cerulean", "sky"],
        "teal":        ["teal", "turquoise", "aqua", "cyan"],
        "cream":       ["cream", "beige", "ivory", "tan", "milk", "milky", "latte", "oat", "sand"],
        "brown":       ["brown", "chocolate", "mocha", "walnut", "wood", "wooden", "caramel", "coffee"],
        "gold":        ["gold", "golden", "amber", "honey", "brass", "yellow"],
        "white":       ["white", "snowy", "ivory", "pale"],
        "grey":        ["grey", "gray", "silver", "chrome", "slate", "stone", "metal", "metallic"],
        "bright":      ["bright", "vivid", "vibrant", "saturated", "colorful", "colourful", "punchy", "bold"],
        // Subject families the catalogue actually contains.
        "tech":        ["tech", "technology", "futuristic", "cyber", "cyberpunk", "digital", "robot", "scifi", "neural", "circuit", "computer", "coding", "code", "glitch"],
        "animal":      ["animal", "animals", "pet", "pets", "cat", "cats", "kitten", "kitty", "dog", "puppy", "bunny", "frog", "bear", "dino", "dinosaur", "dragon", "creature", "fish", "jellyfish"],
        "food":        ["food", "snack", "snacks", "dessert", "cake", "candy", "sweets", "sweet", "bakery", "baking", "boba", "tea", "coffee", "matcha", "fruit", "strawberry", "sugar"],
        "travel":      ["travel", "journey", "adventure", "explore", "explorer", "voyage", "wander", "wanderlust", "trip", "train", "road", "map", "postcard"],
        "city":        ["city", "urban", "town", "street", "streets", "skyline", "buildings", "downtown", "district", "village"],
        "books":       ["book", "books", "library", "reading", "study", "desk", "writing", "journal", "paper", "stationery"],
        "game":        ["game", "games", "gaming", "arcade", "pixel", "8bit", "console", "player", "puzzle"],
        "party":       ["party", "disco", "festival", "celebration", "fireworks", "carnival", "dance", "music", "roller"],
        "desert":      ["desert", "dunes", "sand", "mirage", "egypt", "pyramid", "pyramids", "ancient", "ruins", "relics", "fossil", "prehistoric"],
        "sky":         ["sky", "clouds", "cloud", "cloudy", "air", "balloon", "kite", "kites", "flight", "floating", "horizon"],
        "rainbow":     ["rainbow", "iridescent", "holographic", "holo", "prism", "prismatic", "opal", "opalescent"],
        "spring":      ["spring", "blossom", "blossoms", "bloom", "petals", "cherry"],
        "mountain":    ["mountain", "mountains", "peak", "peaks", "alpine", "valley", "hill", "hills", "cliff"],
    ]

    /// One-hop neighbours. A query concept also lights its neighbours, at `adjacencyDecay` strength,
    /// so "shiny" (→ glow) also reaches aurora/star themes without every synonym being listed under
    /// every concept. Kept deliberately short — this is a nudge, not a thesaurus.
    static let adjacency: [String: [String]] = [
        "night":       ["dark", "moon", "star", "magic"],
        "dark":        ["night", "gothic", "moon"],
        "moon":        ["night", "star", "magic"],
        "star":        ["galaxy", "glow", "night", "magic"],
        "galaxy":      ["star", "night"],
        "glow":        ["star", "aurora", "night"],
        "aurora":      ["glow", "winter", "star"],
        "magic":       ["dream", "castle", "star", "night"],
        "dream":       ["magic", "pastel", "castle"],
        "castle":      ["magic", "dream", "elegant"],
        "cute":        ["pink", "playful", "pastel", "sakura"],
        "playful":     ["cute", "carnival"],
        "pink":        ["sakura", "cute", "pastel", "purple"],
        "sakura":      ["pink", "flower", "cute"],
        "purple":      ["pink", "pastel", "magic"],
        "pastel":      ["pink", "purple", "cute", "dream"],
        "cozy":        ["cafe", "cottage", "autumn", "warm"],
        "cafe":        ["cozy", "green"],
        "nature":      ["forest", "garden", "green", "flower"],
        "forest":      ["nature", "green", "night"],
        "garden":      ["nature", "flower", "green", "cottage"],
        "flower":      ["garden", "sakura", "nature", "pink"],
        "green":       ["nature", "forest", "garden", "zen"],
        "zen":         ["green", "minimal", "cozy", "nature"],
        "ocean":       ["beach", "winter", "dream"],
        "beach":       ["ocean", "sunset"],
        "winter":      ["aurora", "ocean"],
        "autumn":      ["cozy", "cottage", "farm"],
        "sunset":      ["elegant", "beach", "dream"],
        "elegant":     ["castle", "vintage", "paris"],
        "paris":       ["elegant", "vintage"],
        "vintage":     ["elegant", "handwritten", "typewriter", "minimal"],
        "handwritten": ["vintage", "elegant"],
        "typewriter":  ["vintage", "minimal"],
        "minimal":     ["zen", "vintage", "fresh"],
        "bold":        ["carnival"],
        "carnival":    ["playful", "cute"],
        "farm":        ["cottage", "autumn", "nature"],
        "cottage":     ["farm", "garden", "cozy", "autumn"],
        "fresh":       ["nature", "green", "minimal"],
    ]

    static let adjacencyDecay = 0.55

    /// Words that don't carry meaning for matching. Stripped from the query before scoring.
    static let stopWords: Set<String> = [
        "a", "an", "the", "my", "me", "i", "of", "for", "with", "and", "or", "to", "in", "on",
        "at", "is", "it", "this", "that", "these", "those", "some", "any", "want", "wanted",
        "need", "needed", "looking", "look", "show", "give", "find", "get", "something", "stuff",
        "like", "please", "pls", "kinda", "sorta", "very", "really", "so", "more", "most", "all",
        "new", "cool", "nice", "good", "best", "top",
    ]

    /// Words that pick a content type rather than describe content. `SearchEngine` lifts these out
    /// of the query and folds them into the type filter, so "cute font" narrows to fonts.
    static let typeWords: [String: SearchContentType] = [
        "theme": .theme, "themes": .theme, "wallpaper": .theme, "wallpapers": .theme,
        "font": .font, "fonts": .font, "typeface": .font, "typefaces": .font, "lettering": .font,
        "creator": .creator, "creators": .creator, "designer": .creator, "designers": .creator,
        "artist": .creator, "artists": .creator, "maker": .creator, "makers": .creator,
    ]

    // MARK: - Derived indexes (built once)

    /// `term -> concepts it points at`. The authored `lexicon` inverted.
    static let termToConcepts: [String: [String]] = {
        var out: [String: [String]] = [:]
        for (concept, terms) in lexicon {
            for term in terms {
                out[term, default: []].append(concept)
            }
            // A concept name is itself a term for that concept.
            out[concept, default: []].append(concept)
        }
        // De-dup.
        for (term, concepts) in out {
            out[term] = Array(Set(concepts))
        }
        return out
    }()

    /// The concepts a single word evokes, directly (weight 1) — used for indexing catalogue items.
    static func directConcepts(for token: String) -> [String] {
        termToConcepts[token] ?? []
    }

    /// The concepts a query token evokes, with weights: direct hits at 1.0, one-hop neighbours at
    /// `adjacencyDecay`. Used for the query side only.
    static func weightedConcepts(for token: String) -> [String: Double] {
        var out: [String: Double] = [:]
        for concept in directConcepts(for: token) {
            out[concept] = max(out[concept] ?? 0, 1.0)
            for neighbour in adjacency[concept] ?? [] {
                out[neighbour] = max(out[neighbour] ?? 0, adjacencyDecay)
            }
        }
        return out
    }
}
