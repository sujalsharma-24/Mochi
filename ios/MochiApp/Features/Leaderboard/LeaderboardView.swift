import SwiftUI

/// "Ranked Creators" — ported from android/.../features/leaderboard/LeaderboardScreen.kt
/// (docs/figma/9.png). Mock data only: the period tabs and the follow buttons toggle locally,
/// there is no backend query behind them yet.
struct LeaderboardView: View {
    var onBack: () -> Void = {}
    var onSearch: () -> Void = {}
    var onCreatorClick: (String) -> Void = { _ in }
    /// No-op by default: there is no `.community` route yet, so this is a styling-only hook
    /// (Figma's "Explore Community >" link) until real navigation is wired up.
    var onExploreCommunity: () -> Void = {}

    private let periods = ["This Week", "This Month", "All Time"]
    @State private var period = "This Week"
    @State private var following: Set<String> = Set(
        MockData.rankedCreators.filter(\.isFollowing).map(\.id)
    )

    var body: some View {
        ScrollView {
            VStack(spacing: MochiSpacing.lg) {
                header
                periodTabs
                followBanner
                ForEach(Array(MockData.rankedCreators.enumerated()), id: \.element.id) { index, creator in
                    CreatorRankRow(
                        creator: creator,
                        rank: index + 1,
                        isFollowing: following.contains(creator.id),
                        onToggleFollow: { toggle(creator.id) },
                        onTap: { onCreatorClick(creator.id) }
                    )
                }
                footerBanner
            }
            .padding(.horizontal, MochiSpacing.md)
            .padding(.top, MochiSpacing.md)
            .padding(.bottom, 40)
        }
        .scrollIndicators(.hidden)
        .background(alignment: .top) {
            Image("RC_bg")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .ignoresSafeArea()
        }
    }

    private func toggle(_ id: String) {
        if following.contains(id) { following.remove(id) } else { following.insert(id) }
    }

    // MARK: - Header

    private var header: some View {
        HStack(spacing: MochiSpacing.sm) {
            circleButton("arrow.left", action: onBack)
                .accessibilityIdentifier("leaderboard.back")
            VStack(spacing: 2) {
                HStack(spacing: 5) {
                    RoundedRectangle(cornerRadius: 5, style: .continuous)
                        .fill(MochiGradient.leaderboardAccent)
                        .frame(width: 19, height: 19)
                        .overlay(Image(systemName: "trophy").font(.system(size: 9.5)).foregroundStyle(MochiColor.settingsIconGlyph))
                    Text("Ranked Creators")
                        .font(MochiFont.title(19))
                        .foregroundStyle(MochiColor.logoSolid)
                }
                Text("Discover the most popular theme makers")
                    .font(MochiFont.caption(12))
                    .foregroundStyle(MochiColor.textSecondary)
            }
            .frame(maxWidth: .infinity)
            circleButton("magnifyingglass", action: onSearch)
        }
    }

    private func circleButton(_ systemName: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(MochiColor.textPrimary)
                .frame(width: 38, height: 38)
                .background(MochiGradient.leaderboardAccent)
                .clipShape(Circle())
        }
    }

    // MARK: - Period tabs

    private var periodTabs: some View {
        HStack(spacing: 6) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 6) {
                    ForEach(periods, id: \.self) { p in
                        let isSelected = p == period
                        Text(p)
                            .font(MochiFont.heading(12))
                            .lineLimit(1)
                            .foregroundStyle(MochiColor.textPrimary)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 8)
                            .background {
                                if isSelected {
                                    Capsule().fill(MochiGradient.leaderboardAccent)
                                } else {
                                    Capsule().fill(Color.white)
                                        .overlay(Capsule().stroke(MochiColor.outline, lineWidth: 1))
                                }
                            }
                            .onTapGesture { period = p }
                    }
                }
            }
            Spacer(minLength: 4)
            HStack(spacing: 3) {
                Image(systemName: "line.3.horizontal.decrease")
                    .font(.system(size: 10))
                Text("Filter")
                    .font(MochiFont.heading(12))
                    .lineLimit(1)
            }
            .foregroundStyle(MochiColor.outline)
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .background(Color.white, in: Capsule())
            .overlay(Capsule().stroke(MochiColor.outline, lineWidth: 1))

            Image(systemName: "slider.horizontal.3")
                .font(.system(size: 12))
                .foregroundStyle(MochiColor.outline)
                .frame(width: 32, height: 32)
                .overlay(Circle().stroke(MochiColor.outline, lineWidth: 1))
        }
    }

    // MARK: - Banners

    /// Figma's icon is a keyboard body outline with a grid of small keys inside — no SF Symbol
    /// matches that silhouette, so it's drawn directly rather than approximated with `keyboard.fill`.
    private var keyboardGlyph: some View {
        VStack(spacing: 2.5) {
            HStack(spacing: 2.5) {
                ForEach(0..<4, id: \.self) { _ in
                    RoundedRectangle(cornerRadius: 1, style: .continuous)
                        .fill(.white)
                        .frame(width: 3, height: 3)
                }
            }
            HStack(spacing: 2.5) {
                ForEach(0..<4, id: \.self) { _ in
                    RoundedRectangle(cornerRadius: 1, style: .continuous)
                        .fill(.white)
                        .frame(width: 3, height: 3)
                }
            }
            RoundedRectangle(cornerRadius: 1, style: .continuous)
                .fill(.white)
                .frame(width: 20, height: 3)
        }
        .padding(5)
        .overlay(RoundedRectangle(cornerRadius: 6, style: .continuous).stroke(.white, lineWidth: 1.6))
    }

    private var followBanner: some View {
        HStack(spacing: MochiSpacing.sm) {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(MochiColor.logoSolid)
                .frame(width: 40, height: 40)
                .overlay(keyboardGlyph)
            VStack(alignment: .leading, spacing: 2) {
                Text("Follow creators whose style you love")
                    .font(MochiFont.heading(11))
                    .lineLimit(1)
                    .minimumScaleFactor(0.65)
                    .foregroundStyle(MochiColor.logoSolid)
                Text("See their themes without opening a profile!")
                    .font(MochiFont.caption(9))
                    .lineLimit(1)
                    .minimumScaleFactor(0.65)
                    .foregroundStyle(MochiColor.textSecondary)
            }
            Spacer(minLength: 4)
            Button(action: onExploreCommunity) {
                HStack(spacing: 2) {
                    Text("Explore Community")
                        .lineLimit(1)
                    Image(systemName: "chevron.right")
                        .font(.system(size: 8))
                }
                .font(MochiFont.caption(9))
                .foregroundStyle(MochiColor.logoSolid)
                .padding(.horizontal, 8)
                .padding(.vertical, 6)
                .overlay(Capsule().stroke(MochiColor.outline, lineWidth: 1))
                .fixedSize()
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, MochiSpacing.md)
        .padding(.vertical, 10)
        .background(Color.white, in: RoundedRectangle(cornerRadius: MochiRadius.card, style: .continuous))
    }

    private var footerBanner: some View {
        HStack(spacing: MochiSpacing.sm) {
            Image("icon_trophy_mochi")
                .resizable().scaledToFill()
                .frame(width: 56, height: 56)
                .clipShape(Circle())
            VStack(alignment: .leading, spacing: 2) {
                Text("Rankings update every Monday")
                    .font(MochiFont.heading(15)).foregroundStyle(MochiColor.purple)
                Text("Keep creating amazing themes & climb the ranks!")
                    .font(MochiFont.caption(11)).foregroundStyle(MochiColor.textSecondary)
            }
            Spacer(minLength: 0)
        }
        .padding(MochiSpacing.md)
        .background(Color.white, in: RoundedRectangle(cornerRadius: MochiRadius.card, style: .continuous))
    }
}

// MARK: - Row

private struct CreatorRankRow: View {
    let creator: Creator
    let rank: Int
    let isFollowing: Bool
    let onToggleFollow: () -> Void
    let onTap: () -> Void

    private static let medalColors: [Color] = [
        Color(red: 0.867, green: 0.663, blue: 0.208),
        Color(red: 0.722, green: 0.722, blue: 0.784),
        Color(red: 0.690, green: 0.475, blue: 0.247)
    ]

    private static let avatarSize: CGFloat = 56
    /// rankBadge width + the HStack's `sm` spacing — how far the avatar's leading edge sits from
    /// the card's edge, so the thumbnail row below can line up under it instead of hugging trailing.
    private static let leadingInset: CGFloat = 28 + MochiSpacing.sm

    /// Values dialled in through the (now-removed) live tweak panel, baked in permanently. All
    /// three rank medals share `rankBadge`'s numbers rather than each keeping its own tuning.
    private enum Tuned {
        static let rankBadge = ElementTweak(scale: 0.81, x: 4, y: -8)
        static let avatarCrown = ElementTweak(scale: 1, x: -7, y: 0)
        static let nameHandle = ElementTweak(scale: 1, x: 0, y: 11)
        static let stats = ElementTweak(scale: 1, x: -101, y: -15)
        static let thumbnails = ElementTweak(scale: 1.2, x: -16, y: -7)
        static let followButton = ElementTweak(scale: 1, x: 0, y: 7)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: MochiSpacing.sm) {
            HStack(alignment: .top, spacing: MochiSpacing.sm) {
                rankBadge
                avatar
                    .tuned(Tuned.avatarCrown)
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 4) {
                        Text(creator.displayName)
                            .font(MochiFont.heading(13))
                            .lineLimit(1)
                            .foregroundStyle(MochiColor.textPrimary)
                        if creator.isVerified {
                            Image(systemName: "checkmark.seal.fill")
                                .font(.system(size: 12)).foregroundStyle(MochiColor.logoSolid)
                        }
                    }
                    Text(creator.handle)
                        .font(MochiFont.caption(12)).lineLimit(1).foregroundStyle(MochiColor.purple)
                }
                .tuned(Tuned.nameHandle)
                Spacer(minLength: 8)
                followButton
                    .tuned(Tuned.followButton)
            }
            HStack(spacing: 0) {
                Spacer(minLength: 0)
                statsRow
            }
            .tuned(Tuned.stats)
            if !creator.previewAssetNames.isEmpty {
                HStack(spacing: 6) {
                    ForEach(creator.previewAssetNames, id: \.self) { asset in
                        ThemePlateThumbnail(assetName: asset)
                            .frame(width: 64, height: 64)
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    }
                }
                .padding(.leading, Self.leadingInset)
                .tuned(Tuned.thumbnails)
            }
        }
        .padding(MochiSpacing.md)
        .background(Color.white, in: RoundedRectangle(cornerRadius: MochiRadius.card, style: .continuous))
        .contentShape(Rectangle())
        .onTapGesture(perform: onTap)
    }

    private var statsRow: some View {
        HStack(alignment: .center, spacing: 10) {
            HStack(spacing: 3) {
                Image(systemName: "paintpalette.fill").font(.system(size: 10))
                Text("\(creator.themeCount) Themes").font(MochiFont.caption(11)).lineLimit(1)
            }
            .foregroundStyle(MochiColor.textSecondary)
            HStack(spacing: 3) {
                Image(systemName: "heart.fill").font(.system(size: 10)).foregroundStyle(MochiColor.pink)
                Text(creator.likeCount.formattedCompact).font(MochiFont.caption(11)).lineLimit(1)
            }
            .foregroundStyle(MochiColor.textSecondary)
        }
        .fixedSize()
    }

    /// A scalloped "seal" silhouette (SF Symbol's `seal.fill`) reads much closer to Figma's coin
    /// medal than a plain circle; a radial highlight over the flat medal color fakes the coin's
    /// embossed look without needing custom art.
    private var rankBadge: some View {
        Group {
            if rank <= 3 {
                let base = Self.medalColors[rank - 1]
                ZStack {
                    Image(systemName: "seal.fill")
                        .font(.system(size: 30))
                        .foregroundStyle(
                            RadialGradient(
                                colors: [base.opacity(0.75), base],
                                center: .center, startRadius: 1, endRadius: 15
                            )
                        )
                    Image(systemName: "seal")
                        .font(.system(size: 24))
                        .foregroundStyle(.white.opacity(0.35))
                    Text("\(rank)")
                        .font(MochiFont.heading(13))
                        .foregroundStyle(MochiColor.textPrimary)
                }
                .frame(width: 28, height: 28)
                .tuned(Tuned.rankBadge)
            } else {
                Text("\(rank)")
                    .font(MochiFont.title(18)).foregroundStyle(MochiColor.textPrimary)
                    .frame(width: 28, height: 28)
            }
        }
    }

    private var avatar: some View {
        Group {
            if UIImage(named: creator.avatarAssetName) != nil {
                Image(creator.avatarAssetName).resizable().aspectRatio(1, contentMode: .fill)
            } else {
                Image("avatar_user").resizable().aspectRatio(1, contentMode: .fill)
            }
        }
        .frame(width: Self.avatarSize, height: Self.avatarSize)
        .layoutPriority(1)
        .clipShape(Circle())
        .overlay(alignment: .top) {
            // avatar_pixel_art and avatar_vibe_studio already bake a crown into the art itself;
            // only rank 1's asset (avatar_sakura) doesn't, so this only draws for rank 1.
            if rank == 1 {
                Image(systemName: "crown.fill")
                    .font(.system(size: 14))
                    .foregroundStyle(Self.medalColors[rank - 1])
                    .offset(y: -8)
            }
        }
    }

    private var followButton: some View {
        Button(action: onToggleFollow) {
            HStack(spacing: 4) {
                Image(systemName: isFollowing ? "person.fill.checkmark" : "person.badge.plus")
                    .font(.system(size: 12))
                Text(isFollowing ? "Following" : "Follow")
                    .font(MochiFont.caption(12))
            }
            .foregroundStyle(isFollowing ? MochiColor.textPrimary : MochiColor.logoSolid)
            .padding(.horizontal, 12)
            .padding(.vertical, 7)
            .background {
                if isFollowing {
                    Capsule().fill(MochiGradient.leaderboardAccent)
                } else {
                    Capsule().fill(Color.white)
                        .overlay(Capsule().stroke(MochiColor.outline, lineWidth: 1))
                }
            }
        }
        .buttonStyle(.plain)
    }
}

/// One element's baked-in adjustment: a uniform `scale` and an `x`/`y` nudge, layered on top of
/// the fixed Figma-measured layout.
///
/// This used to be shared with the Wallpapers screen's live tweak panel. That panel is gone (its
/// numbers now sit in `WallpaperMetrics`), so the type lives here, beside its only remaining
/// caller, rather than in a file about a screen that no longer uses it.
struct ElementTweak {
    var scale: CGFloat = 1
    var x: CGFloat = 0
    var y: CGFloat = 0
}

private extension View {
    /// Applies a baked-in `ElementTweak` (scale + offset) — values dialled in through a live tweak
    /// panel during layout, now hardcoded; the panel itself has been removed.
    func tuned(_ t: ElementTweak) -> some View {
        self.scaleEffect(t.scale, anchor: .topLeading).offset(x: t.x, y: t.y)
    }
}

#Preview {
    LeaderboardView()
}
