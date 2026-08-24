import SwiftUI

/// Layout numbers live in `HomeMetrics` and `ActionCardTuning`, not here — see HomeMetrics.swift
/// for where each came from and why the two action cards are configured separately.
struct HomeView: View {
    var onThemeClick: (KeyboardTheme) -> Void = {}

    @State private var libraryTab: LibraryTab = .fonts // Figma: FONTS is the default-active pill

    @StateObject private var viewModel = HomeViewModel(container: AppContainer.shared)

    private enum LibraryTab { case fonts, themes }

    /// Loading/Error fall back to the same MockData this screen always rendered — no spinner/error
    /// view exists anywhere in the Figma export for Home, same convention every other screen in this
    /// app follows. Only a genuinely empty catalog (`.empty`) shows a real empty row.
    private var recentlyAppliedThemes: [KeyboardTheme] {
        switch viewModel.uiState {
        case .data(let recentlyApplied, _): return recentlyApplied
        case .empty: return []
        case .loading, .error: return MockData.popularThemes
        }
    }

    private var popularThemes: [KeyboardTheme] {
        switch viewModel.uiState {
        case .data(_, let popular): return popular
        case .empty: return []
        case .loading, .error: return MockData.homePopularThemes
        }
    }

    /// 91px left / 87px right on the action-card row, 82-85px elsewhere — one 16pt margin.
    private static let screenMargin: CGFloat = 16

    /// Rows size themselves off the real screen width rather than a GeometryReader. The reader was
    /// only ever there to force equal sibling widths (different-length labels otherwise pull an
    /// HStack's children to different sizes); computing an explicit width does that directly and
    /// avoids needing a hand-maintained outer `.frame(height:)` that has to be kept in sync.
    private var contentWidth: CGFloat {
        UIScreen.main.bounds.width - 2 * Self.screenMargin
    }

    private var carouselCardWidth: CGFloat { (contentWidth - HomeMetrics.carouselGap * 2) / 3 }
    private var actionCardWidth: CGFloat { (contentWidth - HomeMetrics.actionCardGap) / 2 }

    /// Width of the title/subtitle column beside the icon, per card.
    ///
    /// Note that this does NOT by itself decide where the labels wrap. Both card labels carry
    /// explicit "\n" break points instead, because iOS balances a two-line Text rather than filling
    /// the first line greedily: given an 86pt column it still set "Design your" / "own keyboard"
    /// (50/59pt) in preference to Figma's "Design your own" / "keyboard" (68/33pt). That was
    /// verified by giving this column a visible background — the box really was the full 86pt, the
    /// text simply declined to fill it. No width value fixes that, so the design's own break points
    /// are stated in the strings.
    private func textColumnWidth(_ c: ActionCardTuning) -> CGFloat {
        actionCardWidth - 2 * c.hPad - c.iconSize - c.iconTextGap + c.textColumnExtra
    }

    var body: some View {
        // The artwork is a `.background`, not a ZStack sibling. As a sibling its `.ignoresSafeArea()`
        // expanded the shared ZStack's bounds to the literal screen edges, which dragged the content
        // up under the status bar with it — the wordmark landed on top of the clock. A background
        // participates in none of that: the image still bleeds edge to edge while the VStack keeps
        // its safe-area inset. (MochiTabBar's own comment describes this biting it at the bottom.)
        content
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .background(alignment: .top) {
                ZStack(alignment: .top) {
                    Image("home_background")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                    SparkleField()
                }
                .ignoresSafeArea()
            }
    }

    private var content: some View {
        VStack(alignment: .leading, spacing: 0) {
            header

            Spacer(minLength: HomeMetrics.gapHeaderCarousel)
            recentlyAppliedRow

            Spacer(minLength: HomeMetrics.gapCarouselCards)
            quickActionCards

            Spacer(minLength: HomeMetrics.gapCardsPills)
            libraryToggle

            Spacer(minLength: HomeMetrics.gapPillsSection)
            sectionHeader("Popular Themes")
            Color.clear.frame(height: HomeMetrics.sectionHeaderGap)
            themesRow(popularThemes)

            Spacer(minLength: HomeMetrics.gapThemesFonts)
            sectionHeader("Font Collection")
            Color.clear.frame(height: HomeMetrics.sectionHeaderGap)
            fontsRow(MockData.fonts)

            // Fixed, so the leftover height from the 16:9 -> 19.5:9 mismatch lands in the Spacers
            // above rather than pooling here as dead space.
            Color.clear.frame(height: HomeMetrics.bottomGap)
        }
        .padding(.horizontal, Self.screenMargin)
        .padding(.top, HomeMetrics.headerTopPadding)
        .padding(.bottom, 84) // reserves space for MochiTabBar, which overlays on top edge-to-edge
    }

    private var header: some View {
        HStack(alignment: .top) {
            Text("Mochi")
                .font(MochiFont.logo(HomeMetrics.logoSize))
                .foregroundStyle(MochiColor.logoSolid) // flat color, not a gradient

            Spacer()

            VStack(spacing: 5) {
                // Single sparkle: home_background.png already bakes in an ambient sparkle near this
                // corner, so no extra overlay is added here — a second one made it look like two
                // stars stacked, when Figma shows exactly one.
                Image("icon_create_custom")
                    .resizable()
                    .frame(width: HomeMetrics.createCustomIcon, height: HomeMetrics.createCustomIcon)
                    .clipShape(Circle())
                Text("Create Custom")
                    .font(MochiFont.caption(HomeMetrics.createCustomLabel))
                    .foregroundStyle(MochiColor.textPrimary)
            }
        }
    }

    private func sectionHeader(_ title: String) -> some View {
        SectionHeader(title: title, titleSize: HomeMetrics.sectionHeaderSize, actionSize: HomeMetrics.seeAllSize) {}
    }

    /// Figma shows exactly 3 recently-applied cards filling the row edge-to-edge, no scrolling.
    private var recentlyAppliedRow: some View {
        HStack(alignment: .top, spacing: HomeMetrics.carouselGap) {
            ForEach(recentlyAppliedThemes) { theme in
                themeCard(theme, width: carouselCardWidth, artRadius: HomeMetrics.carouselArtRadius)
            }
        }
    }

    /// Transparent background behind the text, no white card box, and deliberately NO crown/like
    /// count — those belong to the dedicated Themes tab's card, not Home's (Figma's Home cards show
    /// only art + name).
    private func themeCard(_ theme: KeyboardTheme, width: CGFloat, artRadius: CGFloat) -> some View {
        VStack(spacing: HomeMetrics.carouselNameGap) {
            KeyboardThemeArt(
                assetName: theme.imageAssetName,
                seed: theme.id,
                cornerRadius: artRadius,
                ratio: HomeMetrics.carouselArtRatio
            )
            Text(theme.name)
                .font(MochiFont.itemName(HomeMetrics.themeNameSize))
                .foregroundStyle(MochiColor.textPrimary)
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .frame(height: HomeMetrics.carouselNameReserve, alignment: .top)
        }
        .frame(width: width)
        .contentShape(Rectangle())
        .onTapGesture { onThemeClick(theme) }
    }

    private var quickActionCards: some View {
        HStack(spacing: HomeMetrics.actionCardGap) {
            actionCard(
                ActionCardTuning.customCreate,
                iconAsset: "icon_palette",
                title: "Custom Create",
                subtitle: "Design your own\nkeyboard",
                buttonTitle: "Create"
            )
            actionCard(
                ActionCardTuning.chooseLibrary,
                iconAsset: "icon_library",
                title: "Choose from\nLibrary",
                subtitle: "Pick a created\nkeyboard",
                buttonTitle: "Choose"
            )
        }
    }

    /// Figma: icon on the left, title+subtitle to its right, button BELOW and horizontally CENTERED
    /// in the card — its centre sits within 3px of the card's centre in the export, so an earlier
    /// leading-edge alignment was wrong. Label is pure black on the pastel gradient, not white.
    ///
    /// The icon/text row takes `maxHeight: .infinity` above the button, which parks the icon on the
    /// vertical middle of the card's left side. It also keeps the two cards the same height: letting
    /// the text drive the content minimum made "Choose from Library" taller than "Custom Create",
    /// since its title wraps to two lines and the other's doesn't.
    private func actionCard(
        _ c: ActionCardTuning,
        iconAsset: String,
        title: String,
        subtitle: String,
        buttonTitle: String
    ) -> some View {
        VStack(spacing: 0) {
            HStack(alignment: .center, spacing: c.iconTextGap) {
                Image(iconAsset)
                    .resizable()
                    .scaledToFit() // a forced square frame stretched the non-square art
                    .frame(width: c.iconSize, height: c.iconSize)
                    .offset(x: c.iconHOffset, y: c.iconVOffset)
                VStack(alignment: .leading, spacing: c.titleGap) {
                    Text(title)
                        .font(MochiFont.heading(c.titleSize))
                        .foregroundStyle(MochiColor.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)
                        .offset(y: c.titleVOffset)
                    Text(subtitle)
                        .font(MochiFont.body(c.subtitleSize))
                        .foregroundStyle(MochiColor.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)
                        .offset(y: c.subtitleVOffset)
                }
                .frame(width: textColumnWidth(c), alignment: .leading)
                .offset(y: c.textVOffset)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)

            SlimPillButton(title: buttonTitle, c: c) {}
                .offset(y: c.buttonVOffset)
        }
        .padding(.horizontal, c.hPad)
        .padding(.vertical, c.vPad)
        .frame(width: actionCardWidth, height: actionCardWidth / HomeMetrics.actionCardRatio)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: HomeMetrics.actionCardRadius, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: HomeMetrics.actionCardRadius, style: .continuous)
                .stroke(MochiColor.purple.opacity(0.3), lineWidth: 1)
        )
        .shadow(color: MochiColor.purpleDark.opacity(0.10), radius: 10, y: 4)
    }

    /// Deliberately not GradientButton/Button here: Material's equivalent minimum-touch-target
    /// override cost Android several rounds — a plain tappable Text sidesteps the same class of
    /// bug on iOS before it has a chance to occur.
    private func SlimPillButton(
        title: String,
        c: ActionCardTuning,
        action: @escaping () -> Void
    ) -> some View {
        Text(title)
            // Inter Regular, not `MochiFont.button` (SemiBold) — "Create"/"Choose" read as plain
            // weight in the design, and bold made them compete with the card title above.
            .font(MochiFont.body(c.buttonTextSize))
            .foregroundStyle(MochiColor.textPrimary)
            .frame(width: c.buttonWidth, height: c.buttonHeight)
            .background(MochiGradient.softButton)
            .clipShape(Capsule())
            .onTapGesture(perform: action)
    }

    /// The pills sit inset from the screen edges (154px in Figma, vs the 82-91px the rest of the
    /// page uses), so this row gets its own extra padding on top of the shared screen margin.
    private var libraryToggle: some View {
        HStack(spacing: HomeMetrics.pillGap) {
            toggleButton(title: "Fonts", tab: .fonts)
            toggleButton(title: "Themes", tab: .themes)
        }
        .padding(.horizontal, HomeMetrics.pillExtraInset)
    }

    private func toggleButton(title: String, tab: LibraryTab) -> some View {
        let isSelected = libraryTab == tab
        return Text(title.uppercased())
            .font(MochiFont.title(HomeMetrics.pillLabelSize))
            .foregroundStyle(MochiColor.textPrimary)
            .frame(maxWidth: .infinity)
            .frame(height: HomeMetrics.pillHeight)
            .background(
                Group {
                    if isSelected {
                        Capsule().fill(MochiGradient.softButton)
                    } else {
                        Capsule().fill(Color.white)
                            .overlay(Capsule().stroke(MochiColor.purple.opacity(0.4), lineWidth: 1))
                    }
                }
            )
            .onTapGesture { libraryTab = tab }
    }

    /// Figma sizes Popular Themes cards bigger than Recently Applied's, horizontally scrollable
    /// so ~2.5 cards are visible (the 3rd peeking as a scroll affordance).
    private func themesRow(_ themes: [KeyboardTheme]) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(alignment: .top, spacing: HomeMetrics.popularCardGap) {
                ForEach(themes) { theme in
                    themeCard(theme, width: HomeMetrics.popularCardWidth, artRadius: HomeMetrics.popularArtRadius)
                }
            }
        }
    }

    /// Real per-style decorative art (bubble letters, script, block letters, dotted) rather than a
    /// flat system "Aa" glyph — Figma's Font Collection cards are bespoke illustrations, and the
    /// matching crops already exist in Assets.xcassets (see FontArtCard's knownFontArt set). The
    /// "Aa" placeholder (shown only for fonts without extracted art) uses the logo font.
    private func fontsRow(_ fonts: [FontItem]) -> some View {
        let cardWidth = HomeMetrics.fontCardWidth
        let cardHeight = cardWidth / HomeMetrics.fontCardRatio
        let cardRadius = HomeMetrics.fontCardRadius
        return ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: HomeMetrics.fontCardGap) {
                ForEach(fonts) { font in
                    FontArtCard(assetName: font.previewAssetName, cornerRadius: cardRadius) {
                        VStack(spacing: 6) {
                            Text("Aa")
                                .font(MochiFont.logo(cardWidth * 0.27))
                                .foregroundStyle(MochiColor.purple)
                            VStack(spacing: 1) {
                                Text(font.name)
                                    .font(MochiFont.heading(cardWidth * 0.1))
                                    .foregroundStyle(MochiColor.textPrimary)
                                    .lineLimit(1)
                                Text(font.styleDescription)
                                    .font(MochiFont.body(cardWidth * 0.083))
                                    .foregroundStyle(MochiColor.textPrimary)
                                    .lineLimit(1)
                            }
                        }
                        .padding(8)
                        .frame(width: cardWidth, height: cardHeight, alignment: .center)
                        .background(Color.white)
                    }
                    .frame(width: cardWidth, height: cardHeight)
                    .clipShape(RoundedRectangle(cornerRadius: cardRadius, style: .continuous))
                }
            }
        }
    }
}

#Preview {
    HomeView()
}
