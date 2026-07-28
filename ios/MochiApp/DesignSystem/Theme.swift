import SwiftUI

enum MochiColor {
    static let purple = Color(red: 0.545, green: 0.361, blue: 0.965)
    static let purpleDark = Color(red: 0.486, green: 0.227, blue: 0.929)
    static let pink = Color(red: 0.925, green: 0.286, blue: 0.600)
    static let pinkLight = Color(red: 0.976, green: 0.716, blue: 0.855)
    static let lavender = Color(red: 0.808, green: 0.749, blue: 0.976)

    /// Pure black. This was a soft dark grey for a while, chosen by eye off a screenshot; sampling
    /// the glyph cores in docs/figma/1.png settles it — section headers, card titles, card
    /// subtitles, carousel names, pill labels, button labels and "see all" all come back exactly
    /// (0, 0, 0). Text that reads lighter in the design is lighter because of its Inter weight,
    /// not its colour.
    static let textPrimary = Color.black
    static let textSecondary = Color(red: 0.46, green: 0.44, blue: 0.50)

    /// Flat #AAAAAA. Sampled off docs/figma/2.png (Community): the search placeholder,
    /// "24 Themes" under a creator name and every theme description come back as the same
    /// neutral grey — not a desaturated purple, and not `textSecondary`.
    static let textMuted = Color(red: 170 / 255, green: 170 / 255, blue: 170 / 255)

    /// #9750AB — the "by <creator>" byline under a Top Themes card. Lighter and pinker than
    /// `logoSolid` (#9C28B1), which is what the verified-seal badge uses.
    static let creatorLink = Color(red: 151 / 255, green: 80 / 255, blue: 171 / 255)

    /// #F44336 — the filled like heart. Material Red 500, not the app's own `pink`.
    static let heart = Color(red: 244 / 255, green: 67 / 255, blue: 54 / 255)

    /// #8A4FA0 — 1pt outline on the Community search field, the filter pills and the round
    /// download buttons. The white cards themselves carry no stroke at all, only a soft shadow.
    static let outline = Color(red: 138 / 255, green: 79 / 255, blue: 160 / 255)

    /// Pixel-sampled directly off docs/figma/1.png (RGB 156,40,177 = #9C28B1) — the "Mochi"
    /// wordmark is a flat solid color, not a gradient; matches android's MochiColor.logoSolid.
    static let logoSolid = Color(red: 0.612, green: 0.157, blue: 0.694)

    static let cardBackground = Color.white
    static let screenBackgroundFallback = Color(red: 0.976, green: 0.906, blue: 0.965)

    static let freeTag = Color(red: 0.549, green: 0.792, blue: 0.396)
    static let premiumTag = Color(red: 0.976, green: 0.702, blue: 0.235)

    // MARK: - Fonts page (docs/figma/5.png)

    /// #77A509 on #F4F6D2 — the "Free" badge on a font card. Sampled off 5.png; deliberately a
    /// separate pair from `freeTag`, which is a bare text colour with no chip behind it.
    static let freeChipText = Color(red: 119 / 255, green: 165 / 255, blue: 9 / 255)
    static let freeChipBackground = Color(red: 244 / 255, green: 246 / 255, blue: 210 / 255)
    /// #FD981B on #FDEDC6 — the "Pro" counterpart.
    static let proChipText = Color(red: 253 / 255, green: 152 / 255, blue: 27 / 255)
    static let proChipBackground = Color(red: 253 / 255, green: 237 / 255, blue: 198 / 255)

    /// #8A8585 — the Fonts header subtitle, the "Type something..." placeholder and the
    /// apply-panel subtitle. A *warm* grey; Community's `textMuted` is a flat neutral #AAAAAA and
    /// reads visibly cooler against this page's pink background.
    static let textGreyWarm = Color(red: 138 / 255, green: 133 / 255, blue: 133 / 255)

    /// #F9D0ED — the small "Aa" chip that sits left of the "Fonts" page title.
    static let badgePink = Color(red: 249 / 255, green: 208 / 255, blue: 237 / 255)

    /// The back button's circle: a pink-to-orchid ramp, unlike the search button beside it which
    /// is flat `logoSolid`.
    static let backButtonStart = Color(red: 227 / 255, green: 171 / 255, blue: 244 / 255)
    static let backButtonEnd = Color(red: 201 / 255, green: 121 / 255, blue: 224 / 255)

    // MARK: - Themes page (docs/figma/8.png)

    /// #A92CC0 — the arrow-into-tray mark on each theme tile. Sampled at the glyph core; it is a
    /// touch lighter than `logoSolid`, which every *stroke* on this page uses.
    static let downloadGlyph = Color(red: 169 / 255, green: 44 / 255, blue: 192 / 255)

    // MARK: - Create Custom Theme (docs/figma/4.png)

    /// #BD16F7 — the hue both saturation/value squares are built on. Solved from the squares
    /// rather than guessed: white blended toward this colour across the square's width, then
    /// darkened down its height, reproduces every sample taken off the KEY COLOR rect to within a
    /// couple of levels. It is markedly bluer than `purple`, which reads too red in the ramp.
    static let pickerHue = Color(red: 189 / 255, green: 22 / 255, blue: 247 / 255)

    // MARK: - Profile (docs/figma/3.png)

    /// #621570 — the "Edit Profile" capsule's 2px outline. Markedly darker than the label inside
    /// it, which is a separate colour: the first build set both to this and the text came out
    /// visibly muddy against the design's. Sampled at the stroke's core on the top and left edges.
    static let editProfileStroke = Color(red: 98 / 255, green: 21 / 255, blue: 112 / 255)

    /// #9012A7 — the "Edit Profile" label and the pencil beside it. Close to `logoSolid` (#9C28B1)
    /// but a touch deeper, and definitely not the capsule's own stroke colour.
    static let editProfileInk = Color(red: 144 / 255, green: 18 / 255, blue: 167 / 255)

    /// The RECENT grid, read left-to-right then top-to-bottom off the six swatches.
    static let recentSwatches: [Color] = [
        Color(red: 241 / 255, green: 191 / 255, blue: 243 / 255),
        Color(red: 236 / 255, green: 159 / 255, blue: 212 / 255),
        Color(red: 161 / 255, green: 201 / 255, blue: 234 / 255),
        Color(red: 221 / 255, green: 172 / 255, blue: 215 / 255),
        Color(red: 240 / 255, green: 194 / 255, blue: 211 / 255),
        Color(red: 182 / 255, green: 137 / 255, blue: 208 / 255)
    ]
}

enum MochiGradient {
    static let background = LinearGradient(
        colors: [
            Color(red: 0.988, green: 0.851, blue: 0.925),
            Color(red: 0.902, green: 0.784, blue: 0.949),
            Color(red: 0.804, green: 0.741, blue: 0.961)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let primaryButton = LinearGradient(
        colors: [MochiColor.pink, MochiColor.pink.opacity(0.85), MochiColor.purple],
        startPoint: .leading,
        endPoint: .trailing
    )

    /// Home's action-card buttons AND the selected FONTS/THEMES pill — one shared ramp, sampled
    /// across the pill in docs/figma/1.png. It is not a straight pink-to-purple two-stop: it starts
    /// orchid (206,118,219), warms to pink about a third of the way across (226,127,204), then
    /// runs to periwinkle (143,124,233). A two-stop approximation loses that warm middle and reads
    /// noticeably flatter.
    static let softButton = LinearGradient(
        stops: [
            .init(color: Color(red: 206/255, green: 118/255, blue: 219/255), location: 0.0),
            .init(color: Color(red: 226/255, green: 127/255, blue: 204/255), location: 0.32),
            .init(color: Color(red: 143/255, green: 124/255, blue: 233/255), location: 1.0)
        ],
        startPoint: .leading,
        endPoint: .trailing
    )

    /// The Fonts page's accent ramp — the selected category pill, both Apply buttons, the "Aa"
    /// title chip and the selected tab icon all share it. Sampled across the "All" pill in
    /// docs/figma/5.png: it starts a full step pinker than `softButton` (#DE79D3 against #CE76DB)
    /// and ends slightly deeper in periwinkle, which is why it is its own ramp rather than a reuse.
    static let fontsAccent = LinearGradient(
        stops: [
            .init(color: Color(red: 222/255, green: 121/255, blue: 211/255), location: 0.0),
            .init(color: Color(red: 225/255, green: 127/255, blue: 206/255), location: 0.28),
            .init(color: Color(red: 135/255, green: 127/255, blue: 233/255), location: 1.0)
        ],
        startPoint: .leading,
        endPoint: .trailing
    )

    static let logoText = LinearGradient(
        colors: [MochiColor.purpleDark, MochiColor.pink],
        startPoint: .leading,
        endPoint: .trailing
    )

    // MARK: - Themes page ramps (docs/figma/8.png)

    /// The Themes page's "Apply" capsule and its selected "All" pill. Sampled across the 236px
    /// Apply button at 8px intervals: it is NOT `softButton`. That ramp opens orchid (206,118,219)
    /// and only warms to pink a third of the way in; this one *starts* pink (229,128,201), holds
    /// that through the first 30%, then runs to periwinkle. Using `softButton` here left the
    /// button's left end visibly too purple.
    static let themeButton = LinearGradient(
        stops: [
            .init(color: Color(red: 229/255, green: 128/255, blue: 201/255), location: 0.0),
            .init(color: Color(red: 227/255, green: 127/255, blue: 204/255), location: 0.30),
            .init(color: Color(red: 208/255, green: 120/255, blue: 221/255), location: 0.55),
            .init(color: Color(red: 143/255, green: 123/255, blue: 233/255), location: 1.0)
        ],
        startPoint: .leading,
        endPoint: .trailing
    )

    /// The two header discs. Both the back *and* the search button carry this ramp with a black
    /// glyph — unlike the Fonts frame, where the search button is a flat `logoSolid` disc with a
    /// white glyph. A horizontal slice through either circle spans only part of `themeButton`'s
    /// range, so it gets its own shorter ramp rather than reusing that one.
    static let themeCircleButton = LinearGradient(
        colors: [
            Color(red: 226/255, green: 128/255, blue: 204/255),
            Color(red: 188/255, green: 121/255, blue: 227/255)
        ],
        startPoint: .leading,
        endPoint: .trailing
    )

    /// The rounded-square chip holding the palette mark left of the "Themes" title.
    static let themeBadge = LinearGradient(
        colors: [
            Color(red: 222/255, green: 121/255, blue: 216/255),
            Color(red: 161/255, green: 126/255, blue: 231/255)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    // MARK: - Create Custom Theme ramps (docs/figma/4.png)

    /// The selected editor pill ("Fonts"). Only 294px wide, so it crosses a much shorter stretch of
    /// the family's pink→periwinkle run than `softButton` does — sampled end to end it opens on
    /// (229,129,197) and closes on (177,123,227), never reaching either of `softButton`'s extremes.
    static let editorPill = LinearGradient(
        colors: [
            Color(red: 229 / 255, green: 129 / 255, blue: 197 / 255),
            Color(red: 177 / 255, green: 123 / 255, blue: 227 / 255)
        ],
        startPoint: .leading,
        endPoint: .trailing
    )

    /// The four tag chips. A touch cooler at the closing end than `editorPill`.
    static let tagPill = LinearGradient(
        colors: [
            Color(red: 228 / 255, green: 126 / 255, blue: 203 / 255),
            Color(red: 160 / 255, green: 124 / 255, blue: 229 / 255)
        ],
        startPoint: .leading,
        endPoint: .trailing
    )

    /// Fill of the four small key-shape previews — pale lavender at the cap, deepening to orchid
    /// at the foot.
    static let keyShapePreview = LinearGradient(
        colors: [
            Color(red: 236 / 255, green: 226 / 255, blue: 247 / 255),
            Color(red: 206 / 255, green: 170 / 255, blue: 232 / 255)
        ],
        startPoint: .top,
        endPoint: .bottom
    )

    /// The rail under each saturation/value square. Figma stops the sweep at magenta rather than
    /// carrying it back round to red — its right end samples (251,4,201) — so the ramp runs to
    /// 11/12 of the wheel, not a full turn.
    static let hueSpectrum = LinearGradient(
        colors: (0...11).map { Color(hue: Double($0) / 12.0, saturation: 1, brightness: 1) },
        startPoint: .leading,
        endPoint: .trailing
    )

    static let premiumBanner = LinearGradient(
        colors: [
            Color(red: 0.416, green: 0.204, blue: 0.780),
            Color(red: 0.667, green: 0.278, blue: 0.816)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

enum MochiRadius {
    static let card: CGFloat = 20
    static let pill: CGFloat = 999
    static let sheet: CGFloat = 28
}

enum MochiSpacing {
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
}
