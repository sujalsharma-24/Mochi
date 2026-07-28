import SwiftUI

/// The Profile frame, docs/figma/3.png. Layout numbers live in `ProfileMetrics` / `ProfileType`,
/// not here — that file records the raw px behind each one and the three scale factors the page
/// carries (`U` for y positions, `T` for type and text-driven boxes, `A` for artwork).
///
/// The page is laid out as **one absolute canvas** keyed to the frame's own axes, the way
/// CreateThemeView is, rather than as a stack of sections. Every element is positioned by the
/// coordinate measured off the export, so any figure can be checked straight against 3.png without
/// first having to unwind a chain of paddings. Text is placed by **cap top**, not frame top,
/// because that is what a ruler over the export measures — see `place(x:capTop:size:)`.
///
/// The exception is anything whose horizontal extent is set by its own text. Widths on this page
/// are never scaled (the grid is already flush with the content box), so at `T` those runs are wide
/// enough to collide with the marks beside them. Each is laid out as a flow pinned by one measured
/// edge instead: the tile count rows, the download tile's body, the downloads heading with its
/// filter pills, the "Upgrade Plan" capsule and the "Edit Profile" capsule.
struct ProfileView: View {
    /// Figma draws "Theme" as the selected filter over MY DOWNLOADS and "Font" as the alternative.
    enum DownloadFilter: String, CaseIterable, Identifiable {
        case theme = "Theme", font = "Font"
        var id: String { rawValue }
    }

    var onBack: () -> Void = {}

    @State private var filter: DownloadFilter = .theme

    private let profile = MockData.profile

    var body: some View {
        ScrollView(showsIndicators: false) {
            ZStack(alignment: .topLeading) {
                Color.clear.frame(height: ProfileMetrics.canvasHeight)

                header
                banners
                creationsSection
                downloadsSection
                pairSection
            }
            .frame(width: UIScreen.main.bounds.width, alignment: .topLeading)
            .padding(.top, ProfileMetrics.contentTop)
            // Clears MochiTabBar, which overlays this view edge to edge.
            .padding(.bottom, 96)
        }
        // Applied as a background rather than as a ZStack sibling, for the same reason Community,
        // Fonts and Themes do it: a sibling that ignores the safe area drags the whole stack up
        // under the status bar and takes the header with it.
        .background(alignment: .top) { backdrop }
    }

    /// The illustration is anchored to the **canvas** origin, not the screen's. It is a width-fit
    /// reconstruction of the frame's own background, so its sparkles and swirls only line up with
    /// the header they were drawn around if it starts where the header does — pinned to the screen
    /// top instead, everything sat ~32pt high. `profile_background` is padded well past the screen's
    /// height so that offset never uncovers its foot.
    private var backdrop: some View {
        GeometryReader { proxy in
            ZStack(alignment: .top) {
                Image("profile_background")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: proxy.size.width, alignment: .top)
                SparkleField()
            }
            .offset(y: proxy.safeAreaInsets.top + ProfileMetrics.contentTop)
        }
        .ignoresSafeArea()
    }

    // MARK: - Header

    @ViewBuilder
    private var header: some View {
        Button(action: onBack) {
            // The disc carries the same short pink->orchid ramp the Themes header discs do —
            // sampled here it runs #E17FCE to #BC7AE2, which is `themeCircleButton` to within two
            // levels — with a black glyph on top.
            Circle()
                .fill(MochiGradient.themeCircleButton)
                .frame(width: ProfileMetrics.backDisc, height: ProfileMetrics.backDisc)
                .overlay {
                    Image(systemName: "arrow.left")
                        .font(.system(size: ProfileMetrics.backArrowHeight * 1.44, weight: .semibold))
                        .foregroundColor(MochiColor.textPrimary)
                }
        }
        .accessibilityIdentifier("profile.back")
        .place(x: ProfileMetrics.margin, y: ProfileMetrics.backTop)

        avatar
            .place(x: ProfileMetrics.avatarLeading, y: ProfileMetrics.avatarTop)

        // Name and seal travel together: the seal keeps its measured 18.9pt clear of the name's
        // last glyph rather than sitting at the frame's own x, which the name now reaches past.
        HStack(spacing: ProfileMetrics.verifiedGap) {
            figmaText(profile.displayName, MochiFont.itemName(ProfileType.name),
                      "Inter-Medium", MochiColor.textPrimary)
            Image("icon_verified")
                .resizable()
                .scaledToFit()
                .frame(width: ProfileMetrics.verified, height: ProfileMetrics.verified)
        }
        .place(x: ProfileMetrics.nameX, capTop: ProfileMetrics.nameTop, size: ProfileType.name)

        figmaText(profile.handle, MochiFont.itemName(ProfileType.handle),
                  "Inter-Medium", MochiColor.creatorLink)
            .place(x: ProfileMetrics.textColumnX, capTop: ProfileMetrics.handleTop,
                   size: ProfileType.handle)

        // The break point is stated rather than left to the layout: iOS balances a two-line Text
        // instead of filling the first line greedily, which set "…keyboard" / "themes to make
        // typing more fun!" where Figma sets "…themes to" / "make typing more fun!".
        ForEach(Array(["Creating cute & colorful keyboard themes to",
                       "make typing more fun!"].enumerated()), id: \.offset) { index, line in
            figmaText(line, MochiFont.body(ProfileType.bio),
                      "Inter-Regular", MochiColor.textGreyWarm)
                .place(x: ProfileMetrics.textColumnX,
                       capTop: ProfileMetrics.bioTop + CGFloat(index) * ProfileMetrics.bioLineGap,
                       size: ProfileType.bio)
        }

        ForEach(Array(profile.stats.enumerated()), id: \.offset) { index, stat in
            figmaText(stat.value, MochiFont.itemName(ProfileType.statNumber),
                      "Inter-Medium", MochiColor.textPrimary)
                .place(x: ProfileMetrics.statNumberX[index], capTop: ProfileMetrics.statNumberTop,
                       size: ProfileType.statNumber)
            figmaText(stat.label, MochiFont.body(ProfileType.statLabel),
                      "Inter-Regular", MochiColor.textGreyWarm)
                .place(x: ProfileMetrics.statLabelX[index], capTop: ProfileMetrics.statLabelTop,
                       size: ProfileType.statLabel)
        }

        editProfileButton
    }

    /// The ring, the portrait and the camera badge are one raster in Figma. `avatar_mochi_creator`
    /// is that circle lifted straight out of 3.png with an alpha mask; the badge drawn on top of it
    /// is larger than the clipped remnant underneath, so it covers rather than doubles it.
    private var avatar: some View {
        let size = ProfileMetrics.avatar
        let badge = ProfileMetrics.cameraBadge
        return Image("avatar_mochi_creator")
            .resizable()
            .frame(width: size, height: size)
            .overlay(alignment: .topLeading) {
                Circle()
                    .fill(MochiColor.cardBackground)
                    .frame(width: badge, height: badge)
                    .overlay {
                        Image(systemName: "camera.fill")
                            .font(.system(size: ProfileMetrics.cameraGlyph))
                            .foregroundColor(MochiColor.logoSolid)
                    }
                    .offset(x: size * ProfileMetrics.cameraCentreFraction.x - badge / 2,
                            y: size * ProfileMetrics.cameraCentreFraction.y - badge / 2)
            }
    }

    /// Pinned by its right edge, which is the content box's — the frame ends the capsule on the
    /// same x every card does. The pencil and the label are centred in it as one row, so the
    /// capsule grows leftward with the text instead of clipping it.
    private var editProfileButton: some View {
        Button {} label: {
            HStack(spacing: ProfileMetrics.editIconGap) {
                PencilGlyph(bodyHalfWidth: 0.105)
                    .stroke(MochiColor.editProfileInk,
                            style: StrokeStyle(lineWidth: 0.5, lineCap: .round, lineJoin: .round))
                    .frame(width: ProfileMetrics.editPencil.width,
                           height: ProfileMetrics.editPencil.height)
                Text("Edit Profile")
                    .font(MochiFont.itemName(ProfileType.editProfile))
                    .foregroundColor(MochiColor.editProfileInk)
                    .fixedSize()
            }
            .padding(.leading, ProfileMetrics.editPillLeadPad)
            .padding(.trailing, ProfileMetrics.editPillTrailPad)
            .frame(height: ProfileMetrics.editPillHeight)
            .background {
                Capsule()
                    .fill(MochiColor.cardBackground)
                    .overlay(Capsule().stroke(MochiColor.editProfileStroke,
                                              lineWidth: ProfileMetrics.hairline))
            }
        }
        .accessibilityIdentifier("profile.editProfile")
        .placeTrailing(right: ProfileMetrics.margin + ProfileMetrics.contentWidth,
                       y: ProfileMetrics.editPillTop)
    }

    // MARK: - Mochi Pro / Go Premium banners

    @ViewBuilder
    private var banners: some View {
        banner(
            top: ProfileMetrics.proTop,
            mascotX: ProfileMetrics.proMascotX,
            titleAt: ProfileMetrics.proTitle,
            subtitleAt: ProfileMetrics.proSubtitle,
            subtitle: ["You're on Premium Plan  Enjoy all premium",
                       "features and unlimited creations."],
            pillRight: ProfileMetrics.proPillRight
        ) {
            Text("Mochi Pro")
                .font(MochiFont.heading(ProfileType.bannerTitle))
                .foregroundColor(MochiColor.logoSolid)
        }

        banner(
            top: ProfileMetrics.premiumTop,
            mascotX: ProfileMetrics.premiumMascotX,
            titleAt: ProfileMetrics.premiumTitle,
            subtitleAt: ProfileMetrics.premiumSubtitle,
            subtitle: ["Unlock all premium themes, fonts, and features."],
            pillRight: ProfileMetrics.premiumPillRight
        ) {
            // The wordmark is the app's shared pink->periwinkle ramp: sampled across its 461px run
            // it opens #C877DC, warms to #E17CD0 about a third of the way in and closes on #8D7DE7
            // — `softButton` to within a couple of levels. Painted through a mask because
            // Text.foregroundStyle(_ ShapeStyle:) is iOS 17+ and this target ships to 16.
            Text("Go Premium")
                .font(MochiFont.heading(ProfileType.bannerTitle))
                .opacity(0)
                .overlay {
                    MochiGradient.softButton.mask {
                        Text("Go Premium")
                            .font(MochiFont.heading(ProfileType.bannerTitle))
                    }
                }
        }
    }

    @ViewBuilder
    private func banner<Title: View>(
        top: CGFloat,
        mascotX: CGFloat,
        titleAt: CGPoint,
        subtitleAt: CGPoint,
        subtitle: [String],
        pillRight: CGFloat,
        @ViewBuilder title: () -> Title
    ) -> some View {
        RoundedRectangle(cornerRadius: ProfileMetrics.bannerRadius, style: .continuous)
            .fill(MochiColor.cardBackground)
            .overlay {
                RoundedRectangle(cornerRadius: ProfileMetrics.bannerRadius, style: .continuous)
                    .stroke(MochiColor.outline, lineWidth: ProfileMetrics.hairline)
            }
            .frame(width: ProfileMetrics.contentWidth, height: ProfileMetrics.bannerHeight)
            .place(x: ProfileMetrics.margin, y: top)

        Image("mascot_mochi_pro")
            .resizable()
            .frame(width: ProfileMetrics.bannerMascot, height: ProfileMetrics.bannerMascot)
            .place(x: ProfileMetrics.margin + mascotX, y: top + ProfileMetrics.bannerMascotTop)

        title()
            .fixedSize()
            .place(x: ProfileMetrics.margin + titleAt.x, capTop: top + titleAt.y,
                   size: ProfileType.bannerTitle)

        ForEach(Array(subtitle.enumerated()), id: \.offset) { index, line in
            figmaText(line, MochiFont.body(ProfileType.bannerSubtitle),
                      "Inter-Regular", MochiColor.textMuted)
                .place(x: ProfileMetrics.margin + subtitleAt.x,
                       capTop: top + subtitleAt.y + CGFloat(index) * ProfileMetrics.bioLineGap,
                       size: ProfileType.bannerSubtitle)
        }

        upgradePill
            .placeTrailing(right: ProfileMetrics.margin + pillRight,
                           y: top + ProfileMetrics.upgradePillTop)
    }

    private var upgradePill: some View {
        Button {} label: {
            HStack(spacing: 0) {
                Image("icon_crown")
                    .resizable()
                    .scaledToFit()
                    .frame(width: ProfileMetrics.upgradeCrown.width,
                           height: ProfileMetrics.upgradeCrown.height)
                Color.clear.frame(width: ProfileMetrics.upgradeCrownGap, height: 0)
                Text("Upgrade Plan")
                    .font(MochiFont.itemName(ProfileType.upgrade))
                    .foregroundColor(MochiColor.textPrimary)
                    .fixedSize()
                Color.clear.frame(width: ProfileMetrics.upgradeChevronGap, height: 0)
                Image(systemName: "chevron.right")
                    .font(.system(size: ProfileMetrics.upgradeChevron, weight: .bold))
                    .foregroundColor(MochiColor.textPrimary)
            }
            .padding(.leading, ProfileMetrics.upgradePillLeadPad)
            .padding(.trailing, ProfileMetrics.upgradePillTrailPad)
            .frame(height: ProfileMetrics.upgradePillHeight)
            .background(Capsule().fill(MochiGradient.softButton))
        }
        .accessibilityIdentifier("profile.upgradePlan")
    }

    // MARK: - MY CREATIONS

    @ViewBuilder
    private var creationsSection: some View {
        figmaText("MY CREATIONS", MochiFont.title(ProfileType.sectionHeading),
                  "Inter-Bold", MochiColor.textPrimary)
            .place(x: ProfileMetrics.margin, capTop: ProfileMetrics.creationsHeadingTop,
                   size: ProfileType.sectionHeading)

        figmaText("see all", MochiFont.body(ProfileType.seeAll),
                  "Inter-Regular", MochiColor.textPrimary)
            .placeTrailing(right: ProfileMetrics.margin + ProfileMetrics.seeAllRight,
                           capTop: ProfileMetrics.seeAllTop, size: ProfileType.seeAll)

        ForEach(Array(MockData.profileCreations.enumerated()), id: \.element.id) { index, item in
            creationCard(item)
                .place(x: ProfileMetrics.margin
                       + CGFloat(index) * (ProfileMetrics.cardWidth + ProfileMetrics.cardGap),
                       y: ProfileMetrics.creationsTop)
        }
    }

    private func creationCard(_ item: ProfileCreation) -> some View {
        VStack(spacing: 0) {
            artwork(item.imageAssetName, height: ProfileMetrics.creationArtHeight) {
                // Figma's three dots are chunky — 12px across on a 70px disc — where SF's
                // `ellipsis` draws them far finer, which reads as a different mark.
                TripleDot()
                    .fill(MochiColor.textPrimary)
                    .frame(width: ProfileMetrics.cardBadge * 0.74,
                           height: ProfileMetrics.cardBadge * 0.17)
            }

            ZStack(alignment: .topLeading) {
                MochiColor.cardBackground

                figmaText(item.name, MochiFont.itemName(ProfileType.cardTitle),
                          "Inter-Medium", MochiColor.textPrimary)
                    .place(x: ProfileMetrics.cardPad, capTop: ProfileMetrics.creationNameTop,
                           size: ProfileType.cardTitle)

                figmaText(item.kind, MochiFont.itemName(ProfileType.cardTag),
                          "Inter-Medium", MochiColor.creatorLink)
                    .place(x: ProfileMetrics.cardPad, capTop: ProfileMetrics.creationTagTop,
                           size: ProfileType.cardTag)

                // A flow, not four pinned x's: at `T` the two counts are wide enough that the
                // frame's own positions would run the download figure past the card's edge.
                HStack(spacing: 0) {
                    Image(systemName: "heart.fill")
                        .resizable()
                        .foregroundColor(MochiColor.heart)
                        .frame(width: ProfileMetrics.creationHeart.width,
                               height: ProfileMetrics.creationHeart.height)
                    Color.clear.frame(width: ProfileMetrics.creationCountGap, height: 0)
                    Text(item.likes)
                        .font(MochiFont.itemName(ProfileType.cardCount))
                        .foregroundColor(MochiColor.textPrimary)
                    Spacer(minLength: 2)
                    Image(systemName: "arrow.down.to.line")
                        .font(.system(size: ProfileMetrics.creationDownload, weight: .medium))
                        .foregroundColor(MochiColor.downloadGlyph)
                    Color.clear.frame(width: ProfileMetrics.creationCountGap, height: 0)
                    Text(item.downloads)
                        .font(MochiFont.itemName(ProfileType.cardCount))
                        .foregroundColor(MochiColor.textPrimary)
                }
                .padding(.horizontal, ProfileMetrics.cardPad)
                .frame(width: ProfileMetrics.cardWidth, height: ProfileType.cardCount * 1.4)
                .place(x: 0, capTop: ProfileMetrics.creationCountTop, size: ProfileType.cardCount)
            }
            .frame(width: ProfileMetrics.cardWidth, height: ProfileMetrics.creationBodyHeight)
        }
        .frame(width: ProfileMetrics.cardWidth)
        .clipShape(RoundedRectangle(cornerRadius: ProfileMetrics.cardRadius, style: .continuous))
        .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
    }

    // MARK: - MY DOWNLOADS

    @ViewBuilder
    private var downloadsSection: some View {
        // The heading and its two capsules are one row rather than three pinned x's: at `T` the
        // heading reaches the frame's own capsule position.
        HStack(alignment: .center, spacing: 0) {
            figmaText("MY DOWNLOADS", MochiFont.title(ProfileType.sectionHeading),
                      "Inter-Bold", MochiColor.textPrimary)
                .offset(y: ProfileMetrics.downloadsHeadingTop - ProfileMetrics.filterPillTop
                        - (ProfileMetrics.filterPillHeight
                           - ProfileType.sectionHeading * Metrics.capRatio) / 2)
            Color.clear.frame(width: ProfileMetrics.headingToFilterPill, height: 0)
            filterPill(.theme)
            Color.clear.frame(width: ProfileMetrics.filterPillGap, height: 0)
            filterPill(.font)
        }
        .fixedSize()
        .place(x: ProfileMetrics.margin, y: ProfileMetrics.filterPillTop)

        ForEach(Array(MockData.profileDownloads.enumerated()), id: \.element.id) { index, item in
            downloadCard(item)
                .place(x: ProfileMetrics.margin
                       + CGFloat(index) * (ProfileMetrics.cardWidth + ProfileMetrics.cardGap),
                       y: ProfileMetrics.downloadsTop)
        }
    }

    private func filterPill(_ option: DownloadFilter) -> some View {
        let selected = filter == option
        return Button { filter = option } label: {
            Text(option.rawValue)
                .font(MochiFont.itemName(ProfileType.filterPill))
                .foregroundColor(selected ? MochiColor.cardBackground : MochiColor.logoSolid)
                .fixedSize()
                .padding(.horizontal, ProfileMetrics.filterPillPad)
                .frame(height: ProfileMetrics.filterPillHeight)
                .background {
                    if selected {
                        Capsule().fill(MochiColor.logoSolid)
                    } else {
                        Capsule().stroke(MochiColor.logoSolid, lineWidth: ProfileMetrics.hairline)
                    }
                }
        }
        .accessibilityIdentifier("profile.filter.\(option.rawValue)")
    }

    private func downloadCard(_ item: ProfileCreation) -> some View {
        VStack(spacing: 0) {
            artwork(item.imageAssetName, height: ProfileMetrics.downloadArtHeight) {
                Image(systemName: "checkmark")
                    .font(.system(size: ProfileMetrics.cardBadge * 0.50, weight: .bold))
                    .foregroundColor(MochiColor.logoSolid)
            }

            ZStack(alignment: .topLeading) {
                MochiColor.cardBackground

                // A flow for the same reason the creation card's count row is one: at `T`,
                // "Fantasy Castle Night" reaches the heart's measured x.
                HStack(spacing: 0) {
                    Text(item.name)
                        .font(MochiFont.body(ProfileType.downloadTitle))
                        .foregroundColor(MochiColor.textPrimary)
                        .lineLimit(1)
                        .fixedSize(horizontal: false, vertical: true)
                        .minimumScaleFactor(0.85)
                    Spacer(minLength: 2)
                    Image(systemName: "heart.fill")
                        .resizable()
                        .foregroundColor(MochiColor.heart)
                        .frame(width: ProfileMetrics.downloadHeart.width,
                               height: ProfileMetrics.downloadHeart.height)
                    Color.clear.frame(width: ProfileMetrics.creationCountGap, height: 0)
                    Text(item.likes)
                        .font(MochiFont.itemName(ProfileType.cardCount))
                        .foregroundColor(MochiColor.textPrimary)
                        .fixedSize()
                }
                .padding(.horizontal, ProfileMetrics.cardPad * 0.7)
                .frame(width: ProfileMetrics.cardWidth, height: ProfileType.downloadTitle * 1.4)
                .place(x: 0, capTop: ProfileMetrics.downloadNameTop, size: ProfileType.downloadTitle)
            }
            .frame(width: ProfileMetrics.cardWidth, height: ProfileMetrics.downloadBodyHeight)
        }
        .frame(width: ProfileMetrics.cardWidth)
        .clipShape(RoundedRectangle(cornerRadius: ProfileMetrics.cardRadius, style: .continuous))
        .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
    }

    /// Both tile kinds share the same artwork treatment: a fixed crop with a white disc pinned to
    /// its top-right. The Figma export bakes that disc into the artwork underneath, and the disc
    /// drawn here sits at the same size and offset, so it covers that copy.
    private func artwork<Badge: View>(
        _ asset: String,
        height: CGFloat,
        @ViewBuilder badge: () -> Badge
    ) -> some View {
        Image(asset)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: ProfileMetrics.cardWidth, height: height)
            .clipped()
            .overlay(alignment: .topTrailing) {
                Circle()
                    .fill(MochiColor.cardBackground)
                    .frame(width: ProfileMetrics.cardBadge, height: ProfileMetrics.cardBadge)
                    .overlay { badge() }
                    .padding(.trailing, ProfileMetrics.cardBadgeTrailing)
                    .padding(.top, ProfileMetrics.cardBadgeTop)
            }
    }

    // MARK: - Liked Themes / Followers pair

    @ViewBuilder
    private var pairSection: some View {
        pairCardBackground.place(x: ProfileMetrics.margin, y: ProfileMetrics.pairTop)
        pairCardBackground.place(x: ProfileMetrics.margin + ProfileMetrics.pairRightX,
                                 y: ProfileMetrics.pairTop)

        pairHeader(originX: ProfileMetrics.margin, chevron: false)
        pairHeader(originX: ProfileMetrics.margin + ProfileMetrics.pairRightX, chevron: true)

        ForEach(Array(MockData.profileLikedThemes.enumerated()), id: \.element.id) { index, item in
            likedRow(item, rowTop: ProfileMetrics.pairTop + ProfileMetrics.likedRowTop
                     + CGFloat(index) * ProfileMetrics.likedRowPitch)
        }

        ForEach(Array(MockData.profileFollowRows.enumerated()), id: \.element.id) { index, item in
            followRow(item, rowTop: ProfileMetrics.pairTop + ProfileMetrics.followRowTop
                      + CGFloat(index) * ProfileMetrics.followRowPitch)
        }
    }

    private var pairCardBackground: some View {
        RoundedRectangle(cornerRadius: ProfileMetrics.pairRadius, style: .continuous)
            .fill(MochiColor.cardBackground)
            .frame(width: ProfileMetrics.pairCard.width, height: ProfileMetrics.pairCard.height)
            .shadow(color: .black.opacity(0.05), radius: 5, y: 2)
    }

    /// Figma heads **both** cards "Liked Themes" with the same heart — the right-hand one lists
    /// Followers / Following under it, and adds a chevron after its "See all". That is almost
    /// certainly a copy-paste left in the design, but it is what the frame draws, so it is
    /// reproduced rather than corrected.
    @ViewBuilder
    private func pairHeader(originX: CGFloat, chevron: Bool) -> some View {
        Image(systemName: "heart.fill")
            .resizable()
            .foregroundColor(MochiColor.heart)
            .frame(width: ProfileMetrics.pairHeart.width, height: ProfileMetrics.pairHeart.height)
            .place(x: originX + ProfileMetrics.pairHeartX,
                   y: ProfileMetrics.pairTop + ProfileMetrics.pairHeartTop)

        figmaText("Liked Themes", MochiFont.heading(ProfileType.pairHeading),
                  "Inter-SemiBold", MochiColor.textPrimary)
            .place(x: originX + ProfileMetrics.pairHeadingX,
                   capTop: ProfileMetrics.pairTop + ProfileMetrics.pairHeadingTop,
                   size: ProfileType.pairHeading)

        HStack(spacing: ProfileMetrics.followChevronGap) {
            figmaText("See all", MochiFont.heading(ProfileType.pairSeeAll),
                      "Inter-SemiBold", MochiColor.logoSolid)
            if chevron {
                Image(systemName: "chevron.right")
                    .font(.system(size: ProfileMetrics.pairChevron, weight: .semibold))
                    .foregroundColor(MochiColor.logoSolid)
            }
        }
        .placeTrailing(right: originX + ProfileMetrics.pairSeeAllRight,
                       capTop: ProfileMetrics.pairTop + ProfileMetrics.pairHeadingTop,
                       size: ProfileType.pairSeeAll)
    }

    @ViewBuilder
    private func likedRow(_ item: ProfileLikedTheme, rowTop: CGFloat) -> some View {
        Image(item.imageAssetName)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: ProfileMetrics.likedThumb.width, height: ProfileMetrics.likedThumb.height)
            .clipShape(RoundedRectangle(cornerRadius: ProfileMetrics.likedThumbRadius,
                                        style: .continuous))
            .place(x: ProfileMetrics.margin + ProfileMetrics.likedThumbX, y: rowTop)

        figmaText(item.name, MochiFont.heading(ProfileType.likedName),
                  "Inter-SemiBold", MochiColor.textPrimary)
            .place(x: ProfileMetrics.margin + ProfileMetrics.likedTextX,
                   capTop: rowTop + ProfileMetrics.likedNameTop, size: ProfileType.likedName)

        figmaText("by \(item.creatorName)", MochiFont.body(ProfileType.likedByline),
                  "Inter-Regular", MochiColor.textMuted)
            .place(x: ProfileMetrics.margin + ProfileMetrics.likedTextX,
                   capTop: rowTop + ProfileMetrics.likedBylineTop, size: ProfileType.likedByline)

        Image(systemName: "heart.fill")
            .resizable()
            .foregroundColor(MochiColor.heart)
            .frame(width: ProfileMetrics.likedHeart.width, height: ProfileMetrics.likedHeart.height)
            .place(x: ProfileMetrics.margin + ProfileMetrics.likedHeartX,
                   y: rowTop + ProfileMetrics.likedHeartTop)

        figmaText(item.likes, MochiFont.itemName(ProfileType.likedCount),
                  "Inter-Medium", MochiColor.textPrimary)
            .placeTrailing(right: ProfileMetrics.margin + ProfileMetrics.likedCountRight,
                           capTop: rowTop + ProfileMetrics.likedCountTop,
                           size: ProfileType.likedCount)
    }

    @ViewBuilder
    private func followRow(_ item: ProfileFollowRow, rowTop: CGFloat) -> some View {
        let originX = ProfileMetrics.margin + ProfileMetrics.pairRightX

        RoundedRectangle(cornerRadius: ProfileMetrics.followIconRadius, style: .continuous)
            .fill(MochiColor.logoSolid)
            .frame(width: ProfileMetrics.followIcon, height: ProfileMetrics.followIcon)
            .overlay {
                Image(systemName: "person.3.fill")
                    .font(.system(size: ProfileMetrics.followGlyph * 0.60))
                    .foregroundColor(MochiColor.cardBackground)
            }
            .place(x: originX + ProfileMetrics.followIconX, y: rowTop)

        figmaText(item.label, MochiFont.itemName(ProfileType.followLabel),
                  "Inter-Medium", MochiColor.textPrimary)
            .place(x: originX + ProfileMetrics.followTextX,
                   capTop: rowTop + ProfileMetrics.followLabelTop, size: ProfileType.followLabel)

        HStack(spacing: ProfileMetrics.followChevronGap) {
            figmaText(item.value, MochiFont.itemName(ProfileType.followValue),
                      "Inter-Medium", MochiColor.textPrimary)
            Image(systemName: "chevron.right")
                .font(.system(size: ProfileMetrics.followChevron, weight: .semibold))
                .foregroundColor(MochiColor.textPrimary)
        }
        .placeTrailing(right: originX + ProfileMetrics.followValueRight,
                       capTop: rowTop + ProfileMetrics.followLabelTop,
                       size: ProfileType.followValue)
    }

    // MARK: - Helpers

    /// One `Text` set in a bundled Inter face. `postScriptName` is carried purely so each call site
    /// states the weight it was solved at — `ProfileType` documents the pairing, and reading the two
    /// together is how a drifted weight gets caught.
    private func figmaText(_ string: String, _ font: Font,
                           _ postScriptName: String, _ color: Color) -> some View {
        _ = postScriptName
        return Text(string)
            .font(font)
            .foregroundColor(color)
            .fixedSize()
    }

    fileprivate enum Metrics {
        /// Inter's cap height as a fraction of its em (1490/2048). Used where a run has to be
        /// centred against something whose height is known before the view exists.
        static let capRatio: CGFloat = 0.7275
    }
}

// MARK: - Absolute placement on the Figma canvas

private extension View {
    /// Pins a view's top-left corner to a coordinate on the Figma canvas.
    func place(x: CGFloat, y: CGFloat) -> some View {
        frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .offset(x: x, y: y)
    }

    /// Pins a text run by its **cap top**, which is what the measurements in `ProfileMetrics` are.
    /// Inter's ascent sits 0.9688em above the baseline and its cap 0.7275em, so a run's frame starts
    /// 0.2413em above its cap line; `size` names the point size so that can be resolved without a
    /// GeometryReader.
    func place(x: CGFloat, capTop: CGFloat, size: CGFloat) -> some View {
        frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .offset(x: x, y: capTop - size * 0.2413)
    }

    /// The mirror of `place`, for the runs and capsules the frame pins by their **right** edge.
    func placeTrailing(right: CGFloat, y: CGFloat) -> some View {
        frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
            .offset(x: right - UIScreen.main.bounds.width, y: y)
    }

    func placeTrailing(right: CGFloat, capTop: CGFloat, size: CGFloat) -> some View {
        frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
            .offset(x: right - UIScreen.main.bounds.width, y: capTop - size * 0.2413)
    }
}

#Preview {
    ProfileView()
}
