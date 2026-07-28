import SwiftUI

/// Rebuilt against docs/figma/2.png (the Community frame), measured rather than eyeballed — same
/// method HomeView uses against 1.png.
///
/// The export is a 2169x3853px **16:9** canvas; an iPhone 16 Pro is 402x874pt, roughly 19.5:9.
/// That mismatch is the whole story of this file, and it needs two factors rather than one:
///
///  * **Widths** come straight from `measured px * 402/2169` (= 0.1853). Every raw measurement
///    quoted in a comment below is that number's source. Horizontally the design is already at the
///    screen's limit — Top Themes is three 118pt cards in 370pt of gutter-to-gutter space, Popular
///    Creators is four 86.7pt tiles in the same 370pt — so widths cannot grow at all without
///    dropping a card off the row. They are reproduced exactly.
///  * **Heights and type** are then multiplied by `S`. Width-scaling alone lands the design's 671pt
///    of content in a 746pt content box: it reads ~22% small (a full frame of Figma is 16:9, so
///    seen whole it magnifies everything by 874/402 ÷ 3853/2169) and pools the difference as dead
///    space above the tab bar. `S` spends that height on the design instead.
///
/// Artwork aspect ratios stay pinned to their measured values so the keyboard previews aren't
/// cropped by the taller cards; the extra height goes to the white text bodies, which is exactly
/// where the enlarged type needs it.
///
/// Also worth knowing: Figma's own "see all" beside TOP THEMES sits 48px lower than its heading,
/// while the two other section headers align theirs on the heading baseline. All three align here.
private let S: CGFloat = 1.22

private enum Metrics {
    /// Left edge of the wordmark, search field, pills and cards all land on 77-85px. One margin.
    static let margin: CGFloat = 16
    /// Figma insets the two scrollable rows by 77px (14.3pt) rather than the 85px it uses
    /// everywhere else. Those 2pt are what make three 118pt theme cards and four 86.7pt creator
    /// tiles sit fully inside the screen instead of clipping the last one, so the rows bleed back
    /// out of the page gutter by exactly that much.
    static let rowBleed: CGFloat = 2
    /// Negative, so the wordmark rides higher than the safe-area edge would otherwise put it. The
    /// Dynamic Island's own graphic ends ~48pt down while the safe-area inset is 59pt, so this much
    /// overlap still clears the status bar glyphs.
    static let contentTop: CGFloat = -18

    // Header — wordmark measures 618x175px, avatar 216px across including its white ring. The
    // header is the one block with width to spare, so the avatar scales with the wordmark.
    static let avatar: CGFloat = 40 * S
    static let headerToSearch: CGFloat = 8.6 * S  // 123px wordmark-bottom to field-top, less leading

    // Search field: 2003x146px, 38px corner, placeholder inset 79px, glyph 77px wide inset 56px.
    static let searchHeight: CGFloat = 28 * S
    static let searchRadius: CGFloat = 7 * S
    static let searchInset: CGFloat = 14.6
    /// Figma's outline is 2px on a 2169px frame = 0.37pt. A 1pt stroke — the obvious default — is
    /// nearly three times that and was the "border feels too thick" note.
    static let hairline: CGFloat = 0.37 * S
    static let searchIcon: CGFloat = 14.3 * S
    static let searchToPills: CGFloat = 9 * S     // 49px

    // Filter pills: five equal 358px pills, 54px apart, 124px tall — the row fills the content
    // width exactly, so widths are derived from the gaps rather than hard-coded, and the gap stays
    // un-scaled to leave "Following" room to set at the larger size.
    //
    // The corner solves to ~37px (6.85pt) but is set at 7.5pt with a *circular* rather than
    // continuous profile. Continuous corners stay flatter for longer before they turn, which is
    // what read as "too square" at this radius; circular spends the whole radius on the curve.
    static let pillHeight: CGFloat = 24 * S
    static let pillGap: CGFloat = 10
    static let pillRadius: CGFloat = 7.5 * S
    static let pillsToHeading: CGFloat = 8 * S    // 62px, less the heading's own line leading

    // Section headings. Every gap here is the measured px distance minus the leading SwiftUI puts
    // above and below a Text's glyphs, solved by rendering and re-measuring rather than by assuming
    // a line-height ratio — which is why they aren't round numbers.
    //
    // Gaps take `S` like everything else, but only became affordable once the Latest Creations
    // cards dropped to `latestScale`. At the full `S` on those cards there was no height left and
    // un-scaled gaps were the only way to keep the page on screen; freeing ~26pt there buys the
    // proportional rhythm back, and the last card now clears the tab bar by roughly Figma's 34pt.
    static let headingToContent: CGFloat = 8.35 * S   // 57px, Popular Creators / Latest Creations
    static let headingToTopThemes: CGFloat = 12.7 * S // 73px — Top Themes sits further off its heading
    static let contentToHeading: CGFloat = 9.5 * S    // 65-66px

    // Top Themes: 637px cards 49px apart; 491px of art over a 222px white body; 63px corner.
    // Card width and art height are both un-scaled: the row is width-bound, and stretching only the
    // art's height would crop the keyboard preview top and bottom.
    static let themeCard: CGFloat = 118
    static let themeCardGap: CGFloat = 9
    static let themeArtHeight: CGFloat = 91
    static let themeBodyHeight: CGFloat = 41 * S
    static let cardRadius: CGFloat = 12
    /// 85px medal, centred on the art's top-left corner (its own centre sits 4px below art top).
    static let rankBadge: CGFloat = 15.7
    static let downloadButton: CGFloat = 16.7

    // Popular Creators: 468x300px tiles 48px apart; 144px avatar; 242x82px capsule CTA.
    //
    // The one row where `S` is applied to WIDTH as well. Holding the tile at its width-scaled 86.7pt
    // while its type grew left it squat and cramped, and the enlarged name no longer cleared the
    // avatar. Scaling the tile whole restores Figma's proportions exactly; the cost is that ~3.4 of
    // the four tiles are visible at rest instead of all four, which the row's scrolling absorbs.
    static let creatorCard: CGSize = CGSize(width: 86.7 * S, height: 55.6 * S)
    static let creatorCardGap: CGFloat = 9
    static let creatorAvatar: CGFloat = 26.7 * S  // 144px
    static let creatorInset: CGFloat = 7.8 * S    // 42px
    /// Figma leaves 5.6pt right of the verified seal, not the 7.8pt it uses on the left — but the
    /// design is packed to the millimetre there: "Mochi Studio" + its gap + the seal comes to 42.56pt
    /// inside 42.6pt of room, i.e. 0.04pt spare. Reproduced exactly, SwiftUI's slightly wider text
    /// measurement tips it over and the name ellipsises, so this is trimmed to buy ~3pt of slack.
    static let creatorTrailing: CGFloat = 3.2 * S
    static let creatorAvatarGap: CGFloat = 4 * S  // 22px avatar-right to name-left
    static let followSize: CGSize = CGSize(width: 44.9 * S, height: 15.2 * S)

    // Latest Creations: full-width 2004x400px cards, 22px apart, 63px corner. Thumb is 713x336px
    // (2.12:1 — a wider crop than the 1.35:1 art the rest of the app uses) with a 36px corner.
    //
    // These cards are the one block that is width-bound AND height-scaled, and the two fight. The
    // thumb fills 84% of the card's height in Figma; at the full `S` the card grew tall enough that
    // matching that fill made the thumb 43% of the card's width against Figma's 36%, squeezing the
    // text column until the summary broke a word early. `latestScale` is the settlement: enough
    // extra height for the enlarged type, little enough that the summary's first line still breaks
    // after "Frogs" exactly as the design does.
    static let latestScale: CGFloat = 1.12
    static let latestCardHeight: CGFloat = 74.14 * latestScale
    static let latestCardGap: CGFloat = 4 * S
    /// Derived from the card rather than hard-coded, so the 84% vertical fill holds whatever
    /// `latestScale` is. Left un-scaled while the card grew, the thumb filled only 69% of the card
    /// and floated in the middle — the "undersized and too far from the top and bottom" note.
    static let latestThumb: CGSize = CGSize(width: latestCardHeight * 0.8399 * 2.1223,
                                            height: latestCardHeight * 0.8399)
    static let latestThumbRadius: CGFloat = 7 * latestScale
    static let latestThumbLead: CGFloat = 7.97 * latestScale   // 43px
    static let latestThumbGap: CGFloat = 10.2 * latestScale    // 55px thumb-right to title-left
    static let latestDownload: CGFloat = 15
    static let tagHeight: CGFloat = 10 * S        // 54px
    static let tagGap: CGFloat = 4                // 22px
    static let verifiedBadge: CGFloat = 6.1 * S   // 33px
    /// Figma leaves 130px (24pt) of bare white right of the "..." — slack a 16:9 frame can afford
    /// and the enlarged type cannot, so it is trimmed rather than reproduced. It is the only
    /// measurement on this page deliberately not carried over.
    static let latestTrailing: CGFloat = 8
}

/// Weight per run was settled by template matching, not by eye: each glyph run was cropped from
/// the export, normalised against its *own* ink colour (grey and purple runs read a weight heavier
/// if you normalise them against black), then compared pixel-for-pixel against the same string
/// rendered in all four bundled Inter weights. "see all" and an idle pill land on Regular by a wide
/// margin, section headings on Bold by a wide margin — those anchors show the method discriminates
/// rather than drifting one way.
///
/// The result overturned several assumptions this file started with. Figma sets the Latest
/// Creations title, its byline and the creator-tile name in **Medium**, not SemiBold, and the
/// selected pill well below Bold.
///
/// Where the match was a near-tie — under ~10% between two adjacent weights, which covered the
/// selected pill, the theme name, the theme byline, the like counts, the hashtag chips and the
/// summary copy — the lighter option is taken. Those ties are inside the method's own noise, and
/// on device every one of them read heavy against the frame: `S` enlarges the type, and a weight
/// that looks right at 5pt looks a notch heavy at 6.5pt. Runs the match separated cleanly
/// (section headings Bold, "see all" and idle pills Regular, the Latest byline Medium, the
/// "Follow" CTA SemiBold) keep their measured weight regardless.
///
/// Sizes are then solved per run the way HomeView's were — render the bundled TTF at the run's
/// weight, measure, scale until it matches the export — so each size below is only valid for the
/// weight beside it. Changing one means re-solving the other. `S` lifts the whole set together.
private enum Type {
    static let logo: CGFloat = 42 * S              // Fredoka;   618px wordmark
    static let searchPlaceholder: CGFloat = 8.73 * S  // Medium;   549px
    static let pillSelected: CGFloat = 10.38 * S   // Medium;    "For you" 203px
    static let pillIdle: CGFloat = 9.2 * S         // Regular;   "Popular" 180px
    static let sectionTitle: CGFloat = 8.7 * S     // Bold;      "POPULAR CREATORS" 495px
    static let seeAll: CGFloat = 8.2 * S           // Regular;   138px
    static let themeName: CGFloat = 7.41 * S       // Regular;   "kawaii boba tea" 295px
    static let themeByline: CGFloat = 5.47 * S     // Medium;    "by Mochi Studio" 228px
    static let themeLikes: CGFloat = 4.47 * S      // Regular;   "12.5K" 62px
    static let creatorName: CGFloat = 5.5 * S      // Medium;    "Mochi Studio" 186px
    static let creatorThemes: CGFloat = 4.71 * S   // Medium;    "24 Themes" 137px
    static let followLabel: CGFloat = 6.2 * S      // SemiBold;  "Follow" 106px
    static let latestTitle: CGFloat = 8.38 * S     // Medium;    "Cozy Sakura Café" 389px
    static let latestByline: CGFloat = 6.51 * S    // Medium;    "By Lemonade" 229px
    static let latestSummary: CGFloat = 5.21 * S   // Regular;   493px for the first line
    static let latestLikes: CGFloat = 4.97 * S     // Medium;    "956" 50px
    static let tag: CGFloat = 5.48 * S             // Medium;    "#cute" 81px
}

struct CommunityView: View {
    var onOpenProfile: () -> Void = {}

    /// Figma spells the placeholder "serch themes, creators.." — kept verbatim, like the fourth
    /// creator tile's "Choose" CTA.
    private enum FeedTab: String, CaseIterable {
        case forYou = "For you", popular = "Popular", latest = "Latest", following = "Following", myLikes = "My Likes"
    }

    @State private var selectedTab: FeedTab = .forYou
    @State private var query: String = ""

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {
                header

                Color.clear.frame(height: Metrics.headerToSearch)
                searchField

                Color.clear.frame(height: Metrics.searchToPills)
                filterPills

                Color.clear.frame(height: Metrics.pillsToHeading)
                sectionHeading("Top Themes")
                // The rank medals overhang the cards' top edge, and the row's own ScrollView clips
                // to its bounds — so the overhang is paid for inside the row and deducted here.
                Color.clear.frame(height: max(0, Metrics.headingToTopThemes - Metrics.rankBadge / 2))
                topThemesRow

                Color.clear.frame(height: Metrics.contentToHeading)
                sectionHeading("Popular Creators")
                Color.clear.frame(height: Metrics.headingToContent)
                creatorsRow

                Color.clear.frame(height: Metrics.contentToHeading)
                sectionHeading("Latest Creations")
                Color.clear.frame(height: Metrics.headingToContent)
                latestCreations
            }
            .padding(.horizontal, Metrics.margin)
            .padding(.top, Metrics.contentTop)
            .padding(.bottom, 100) // clears MochiTabBar, which overlays this view edge-to-edge
        }
        // Applied as a background rather than as a ZStack sibling: a sibling that ignores the safe
        // area drags the whole stack's bounds up under the status bar, which put the wordmark
        // behind the clock. `.background` is laid out against this view instead of alongside it, so
        // the artwork still bleeds off every edge while the content stays inside the safe area.
        .background(alignment: .top) {
            // Rebuilt from 2.png rather than reusing `home_background`. That asset is 0.447 wide
            // against this 0.46 screen and, more to the point, its artwork is drawn for a 16:9 frame
            // — filling with it enlarges the corner blobs, which is the "too zoomed in" note. This
            // one is derived from the export's own uncovered gutters: per row, the left and right
            // gutter medians are taken (sparkle blowouts rejected), smoothed, and interpolated
            // across — the backdrop really is a per-row left-to-right ramp, so that reconstruction
            // lands within ~4/255 of the real interior pixels. Rendering it at the phone's aspect
            // stretches a smooth gradient vertically, which is invisible, and keeps all four of
            // Figma's corner colours instead of cropping them off.
            ZStack(alignment: .top) {
                Image("community_background")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                SparkleField()
            }
            .ignoresSafeArea()
        }
    }

    // MARK: - Header

    private var header: some View {
        HStack(alignment: .center) {
            Text("Mochi")
                .font(MochiFont.logo(Type.logo))
                .foregroundStyle(MochiColor.logoSolid)

            Spacer()

            Button(action: onOpenProfile) {
                Image("avatar_user")
                    .resizable()
                    .scaledToFill()
                    .frame(width: Metrics.avatar, height: Metrics.avatar)
                    .clipShape(Circle())
            }
            .accessibilityIdentifier("community.openProfile")
        }
    }

    // MARK: - Search

    /// A live `TextField` rather than a static label: the design is a search affordance and there is
    /// already a SearchView in the app, so wiring the text through costs nothing and avoids shipping
    /// a control that looks tappable but isn't.
    private var searchField: some View {
        HStack(spacing: 0) {
            TextField("serch themes, creators..", text: $query)
                .font(MochiFont.caption(Type.searchPlaceholder))
                .foregroundStyle(MochiColor.textPrimary)
                .tint(MochiColor.purple)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()

            Spacer(minLength: 8)

            Image(systemName: "magnifyingglass")
                .font(.system(size: Metrics.searchIcon, weight: .regular))
                .foregroundStyle(MochiColor.textMuted)
        }
        .padding(.horizontal, Metrics.searchInset)
        .frame(height: Metrics.searchHeight)
        .background(Color.white, in: RoundedRectangle(cornerRadius: Metrics.searchRadius, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: Metrics.searchRadius, style: .continuous)
                .stroke(MochiColor.outline, lineWidth: Metrics.hairline)
        )
    }

    // MARK: - Filter pills

    /// The five pills divide the content width exactly in Figma (5 x 358px + 4 x 54px = the full
    /// 2004px), so they're laid out as equal flexible columns rather than sized to their labels —
    /// which is also why "My Likes" and "Latest" end up the same width despite the length gap.
    private var filterPills: some View {
        HStack(spacing: Metrics.pillGap) {
            ForEach(FeedTab.allCases, id: \.self) { tab in
                let isSelected = selectedTab == tab
                Text(tab.rawValue)
                    .font(isSelected ? MochiFont.itemName(Type.pillSelected) : MochiFont.body(Type.pillIdle))
                    .foregroundStyle(MochiColor.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                    .frame(maxWidth: .infinity)
                    .frame(height: Metrics.pillHeight)
                    .background {
                        let shape = RoundedRectangle(cornerRadius: Metrics.pillRadius, style: .circular)
                        if isSelected {
                            shape.fill(MochiGradient.softButton)
                        } else {
                            shape.fill(Color.white)
                                .overlay(shape.stroke(MochiColor.creatorLink, lineWidth: Metrics.hairline))
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture { selectedTab = tab }
            }
        }
    }

    // MARK: - Section heading

    private func sectionHeading(_ title: String) -> some View {
        HStack(alignment: .firstTextBaseline) {
            Text(title.uppercased())
                .font(MochiFont.title(Type.sectionTitle))
                .foregroundStyle(MochiColor.textPrimary)
            Spacer()
            Text("see all")
                .font(MochiFont.body(Type.seeAll))
                .foregroundStyle(MochiColor.textPrimary)
        }
    }

    // MARK: - Top Themes

    /// Three 118pt cards plus two 9pt gaps is 372pt against 370pt of content width, so the third
    /// card's right edge is clipped by ~2pt — exactly as in the export, where it lands at 2094px
    /// against a 2089px margin. A horizontal ScrollView reproduces that and makes it scrollable.
    private var topThemesRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(alignment: .top, spacing: Metrics.themeCardGap) {
                ForEach(Array(MockData.communityTopThemes.enumerated()), id: \.element.id) { index, theme in
                    topThemeCard(theme, rank: index + 1)
                }
            }
            .padding(.top, Metrics.rankBadge / 2)
        }
        .padding(.horizontal, -Metrics.rowBleed)
    }

    private func topThemeCard(_ theme: KeyboardTheme, rank: Int) -> some View {
        VStack(spacing: 0) {
            Image(theme.imageAssetName)
                .resizable()
                .scaledToFill()
                .frame(width: Metrics.themeCard, height: Metrics.themeArtHeight)
                .clipped()

            VStack(alignment: .leading, spacing: 0) {
                Text(theme.name)
                    .font(MochiFont.body(Type.themeName))
                    .foregroundStyle(MochiColor.textPrimary)
                    .lineLimit(1)

                Spacer(minLength: 0)

                Text("by \(theme.creatorName)")
                    .font(MochiFont.itemName(Type.themeByline))
                    .foregroundStyle(MochiColor.creatorLink)
                    .lineLimit(1)

                Spacer(minLength: 0)

                HStack(spacing: 3) {
                    Image(systemName: "heart.fill")
                        .font(.system(size: Type.themeLikes * 1.25))
                        .foregroundStyle(MochiColor.heart)
                    Text(theme.likeCountFormatted)
                        .font(MochiFont.body(Type.themeLikes))
                        .foregroundStyle(MochiColor.textPrimary)
                }
            }
            .padding(.leading, 8)
            .padding(.vertical, 5 * S)
            .frame(width: Metrics.themeCard, height: Metrics.themeBodyHeight, alignment: .topLeading)
        }
        .frame(width: Metrics.themeCard)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: Metrics.cardRadius, style: .continuous))
        .shadow(color: MochiColor.purpleDark.opacity(0.13), radius: 5, y: 3)
        .overlay(alignment: .bottomTrailing) {
            DownloadButton(diameter: Metrics.downloadButton)
                .padding(.trailing, 8.5)
                .padding(.bottom, 5 * S)
        }
        // The medal straddles the art's top edge (its centre sits 4px below it in the export) and
        // is left-aligned with the card, so it overhangs the card's top — hence the overlay rather
        // than an inset badge, and hence `.clipped(false)` behaviour by default.
        .overlay(alignment: .topLeading) {
            Image("badge_rank_\(rank)")
                .resizable()
                .scaledToFit()
                .frame(width: Metrics.rankBadge, height: Metrics.rankBadge)
                .offset(y: -Metrics.rankBadge / 2 + 0.7)
        }
    }

    // MARK: - Popular Creators

    private var creatorsRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(alignment: .top, spacing: Metrics.creatorCardGap) {
                ForEach(MockData.communityCreators) { creator in
                    creatorCard(creator)
                }
            }
        }
        .padding(.horizontal, -Metrics.rowBleed)
    }

    private func creatorCard(_ creator: CommunityCreator) -> some View {
        VStack(spacing: 0) {
            HStack(alignment: .top, spacing: Metrics.creatorAvatarGap) {
                Image(creator.avatarAssetName)
                    .resizable()
                    .scaledToFill()
                    .frame(width: Metrics.creatorAvatar, height: Metrics.creatorAvatar)
                    .clipShape(Circle())

                VStack(alignment: .leading, spacing: 1 * S) {
                    HStack(spacing: 2 * S) {
                        Text(creator.name)
                            .font(MochiFont.itemName(Type.creatorName))
                            .foregroundStyle(MochiColor.textPrimary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.96) // shrink a hair rather than ever ellipsise
                        if creator.isVerified { VerifiedSeal() }
                    }
                    Text("\(creator.themeCount) Themes")
                        .font(MochiFont.caption(Type.creatorThemes))
                        .foregroundStyle(MochiColor.textMuted)
                        .lineLimit(1)
                }
                .padding(.top, 6 * S)
            }
            // No trailing `Spacer` here, and the left-alignment comes from the frame instead. A
            // Spacer is flexible and a Text is compressible, so an HStack hands them the surplus
            // between them — which ellipsised "Mochi Studio" to "Mochi Stu..." while ~8pt of tile
            // sat empty to its right. `.layoutPriority` on the label did not fix it; removing the
            // competing flexible sibling does.
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.leading, Metrics.creatorInset)
            .padding(.trailing, Metrics.creatorTrailing)

            Spacer(minLength: 0)

            // Centred on the TILE, not on the padded content box — the insets above are asymmetric
            // (Figma's are), so centring inside them would push the capsule ~1pt right of where the
            // design puts it, which is dead centre.
            Text(creator.ctaTitle)
                .font(MochiFont.button(Type.followLabel))
                .foregroundStyle(MochiColor.textPrimary)
                .frame(width: Metrics.followSize.width, height: Metrics.followSize.height)
                .background(MochiGradient.softButton, in: Capsule())
                .frame(maxWidth: .infinity)
        }
        .padding(.top, 5.4 * S)
        .padding(.bottom, 5.2 * S)
        .frame(width: Metrics.creatorCard.width, height: Metrics.creatorCard.height, alignment: .topLeading)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: Metrics.cardRadius, style: .continuous))
        .shadow(color: MochiColor.purpleDark.opacity(0.13), radius: 5, y: 3)
    }

    // MARK: - Latest Creations

    private var latestCreations: some View {
        VStack(spacing: Metrics.latestCardGap) {
            ForEach(MockData.communityLatest) { post in
                latestCard(post)
            }
        }
    }

    private func latestCard(_ post: CommunityPost) -> some View {
        HStack(spacing: 0) {
            Image(post.thumbAssetName)
                .resizable()
                .scaledToFill()
                .frame(width: Metrics.latestThumb.width, height: Metrics.latestThumb.height)
                .clipShape(RoundedRectangle(cornerRadius: Metrics.latestThumbRadius, style: .continuous))
                .padding(.trailing, Metrics.latestThumbGap)

            VStack(alignment: .leading, spacing: 0) {
                Text(post.name)
                    .font(MochiFont.itemName(Type.latestTitle))
                    .foregroundStyle(MochiColor.textPrimary)
                    .lineLimit(1)

                Color.clear.frame(height: 4 * S)

                HStack(spacing: 1 * S) {
                    Text("By \(post.creatorName)")
                        .font(MochiFont.itemName(Type.latestByline))
                        .foregroundStyle(MochiColor.textPrimary)
                        .lineLimit(1)
                    VerifiedSeal()
                }

                Color.clear.frame(height: 6 * S)

                // Break points come from the copy itself (see MockData.communityLatest) rather
                // than from this frame's width, so they stay put at any scale.
                Text(post.summary)
                    .font(MochiFont.body(Type.latestSummary))
                    .foregroundStyle(MochiColor.textMuted)
                    .lineSpacing(1.3 * S)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Spacer(minLength: 4 * S)

                HStack(spacing: Metrics.tagGap) {
                    ForEach(post.hashtags, id: \.self) { tag in
                        Text("#\(tag)")
                            .font(MochiFont.caption(Type.tag))
                            .foregroundStyle(tagForeground(post.tagPalette))
                            .padding(.horizontal, 3.5)
                            .frame(height: Metrics.tagHeight)
                            .background(tagBackground(post.tagPalette), in: Capsule())
                    }
                }
            }

            HStack(spacing: 0) {
                Image(systemName: "heart.fill")
                    .font(.system(size: Type.latestLikes * 1.25))
                    .foregroundStyle(MochiColor.heart)
                Text("\(post.likeCount)")
                    .font(MochiFont.caption(Type.latestLikes))
                    .foregroundStyle(MochiColor.textPrimary)
                    .padding(.leading, 4.8)

                DownloadButton(diameter: Metrics.latestDownload)
                    .padding(.leading, 10.7)

                Image(systemName: "ellipsis")
                    .font(.system(size: 9 * S, weight: .black))
                    .foregroundStyle(MochiColor.textPrimary)
                    .padding(.leading, 9.8)
            }
            .padding(.trailing, Metrics.latestTrailing)
        }
        .padding(.leading, 8)
        .padding(.vertical, 6 * S)
        .frame(height: Metrics.latestCardHeight)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: Metrics.cardRadius, style: .continuous))
        .shadow(color: MochiColor.purpleDark.opacity(0.13), radius: 5, y: 3)
    }

    private func tagForeground(_ palette: CommunityPost.TagPalette) -> Color {
        switch palette {
        case .green: return Color(red: 57 / 255, green: 146 / 255, blue: 19 / 255)
        case .blue: return Color(red: 14 / 255, green: 107 / 255, blue: 250 / 255)
        case .peach: return Color(red: 251 / 255, green: 141 / 255, blue: 82 / 255)
        }
    }

    private func tagBackground(_ palette: CommunityPost.TagPalette) -> Color {
        switch palette {
        case .green: return Color(red: 241 / 255, green: 247 / 255, blue: 228 / 255)
        case .blue: return Color(red: 241 / 255, green: 239 / 255, blue: 251 / 255)
        case .peach: return Color(red: 255 / 255, green: 240 / 255, blue: 225 / 255)
        }
    }
}

/// White disc, 1pt purple outline, purple "download into tray" glyph. Drawn rather than pulled from
/// SF Symbols because the closest symbols (`arrow.down.to.line`, `square.and.arrow.down`) both miss
/// the design's open-topped U tray, which is the part that reads at 15-17pt.
private struct DownloadButton: View {
    let diameter: CGFloat

    var body: some View {
        Circle()
            .fill(Color.white)
            .overlay(Circle().stroke(MochiColor.outline, lineWidth: Metrics.hairline))
            .overlay {
                Canvas { context, size in
                    let w = size.width, h = size.height
                    let line = w * 0.095
                    var stem = Path()
                    stem.move(to: CGPoint(x: w / 2, y: h * 0.08))
                    stem.addLine(to: CGPoint(x: w / 2, y: h * 0.58))

                    var head = Path()
                    head.move(to: CGPoint(x: w * 0.26, y: h * 0.38))
                    head.addLine(to: CGPoint(x: w / 2, y: h * 0.60))
                    head.addLine(to: CGPoint(x: w * 0.74, y: h * 0.38))

                    var tray = Path()
                    tray.move(to: CGPoint(x: w * 0.17, y: h * 0.65))
                    tray.addLine(to: CGPoint(x: w * 0.17, y: h * 0.92))
                    tray.addLine(to: CGPoint(x: w * 0.83, y: h * 0.92))
                    tray.addLine(to: CGPoint(x: w * 0.83, y: h * 0.65))

                    let style = StrokeStyle(lineWidth: line, lineCap: .round, lineJoin: .round)
                    let ink = GraphicsContext.Shading.color(MochiColor.logoSolid)
                    context.stroke(stem, with: ink, style: style)
                    context.stroke(head, with: ink, style: style)
                    context.stroke(tray, with: ink, style: style)
                }
                .padding(diameter * 0.26)
            }
            .frame(width: diameter, height: diameter)
            .shadow(color: .black.opacity(0.16), radius: 2, y: 2)
    }
}

/// Figma's scalloped purple check seal, in the same #9C28B1 as the wordmark.
private struct VerifiedSeal: View {
    var body: some View {
        Image(systemName: "checkmark.seal.fill")
            .resizable()
            .scaledToFit()
            .frame(width: Metrics.verifiedBadge, height: Metrics.verifiedBadge)
            .foregroundStyle(MochiColor.logoSolid)
    }
}

#Preview {
    CommunityView()
}
