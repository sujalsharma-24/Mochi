import SwiftUI

/// "Ranked Creators" — ported from android/.../features/leaderboard/LeaderboardScreen.kt
/// (docs/figma/9.png). Mock data only: the period tabs and the follow buttons toggle locally,
/// there is no backend query behind them yet.
struct LeaderboardView: View {
    var onBack: () -> Void = {}
    var onSearch: () -> Void = {}
    var onCreatorClick: (String) -> Void = { _ in }

    private let periods = ["This Week", "This Month", "All Time"]
    @State private var period = "This Week"
    @State private var following: Set<String> = Set(
        MockData.rankedCreators.filter(\.isFollowing).map(\.id)
    )

    var body: some View {
        ZStack {
            MochiGradient.background.ignoresSafeArea()
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
                HStack(spacing: 6) {
                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                        .fill(MochiColor.purple)
                        .frame(width: 22, height: 22)
                        .overlay(Image(systemName: "trophy.fill").font(.system(size: 11)).foregroundStyle(.white))
                    Text("Ranked Creators")
                        .font(MochiFont.title(22))
                        .foregroundStyle(MochiColor.purple)
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
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 44, height: 44)
                .background(MochiGradient.primaryButton)
                .clipShape(Circle())
        }
    }

    // MARK: - Period tabs

    private var periodTabs: some View {
        HStack(spacing: MochiSpacing.sm) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(periods, id: \.self) { p in
                        let isSelected = p == period
                        Text(p)
                            .font(MochiFont.heading(13))
                            .foregroundStyle(isSelected ? .white : MochiColor.textPrimary)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 10)
                            .background {
                                if isSelected {
                                    Capsule().fill(MochiGradient.primaryButton)
                                } else {
                                    Capsule().fill(Color.white)
                                        .overlay(Capsule().stroke(MochiColor.purple.opacity(0.25), lineWidth: 1))
                                }
                            }
                            .onTapGesture { period = p }
                    }
                }
            }
            Spacer(minLength: 0)
            ForEach(["line.3.horizontal.decrease", "slider.horizontal.3"], id: \.self) { icon in
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundStyle(MochiColor.textPrimary)
                    .frame(width: 36, height: 36)
                    .overlay(Circle().stroke(MochiColor.purple.opacity(0.25), lineWidth: 1))
            }
        }
    }

    // MARK: - Banners

    private var followBanner: some View {
        HStack(spacing: MochiSpacing.sm) {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(MochiGradient.primaryButton)
                .frame(width: 44, height: 44)
                .overlay(Image(systemName: "keyboard.fill").font(.system(size: 18)).foregroundStyle(.white))
            VStack(alignment: .leading, spacing: 2) {
                Text("Follow creators whose style you love")
                    .font(MochiFont.heading(14)).foregroundStyle(MochiColor.purple)
                Text("See their themes without opening a profile!")
                    .font(MochiFont.caption(11)).foregroundStyle(MochiColor.textSecondary)
            }
            Spacer(minLength: 0)
        }
        .padding(MochiSpacing.md)
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

    var body: some View {
        HStack(spacing: MochiSpacing.sm) {
            rankBadge
            avatar
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 4) {
                    Text(creator.displayName)
                        .font(MochiFont.heading(15))
                        .foregroundStyle(MochiColor.textPrimary)
                    if creator.isVerified {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.system(size: 12)).foregroundStyle(MochiColor.purple)
                    }
                }
                Text(creator.handle)
                    .font(MochiFont.caption(12)).foregroundStyle(MochiColor.purple)
                HStack(spacing: 10) {
                    Label("\(creator.themeCount) Themes", systemImage: "paintpalette.fill")
                        .labelStyle(.titleAndIcon)
                        .font(MochiFont.caption(11))
                        .foregroundStyle(MochiColor.textSecondary)
                    HStack(spacing: 3) {
                        Image(systemName: "heart.fill").font(.system(size: 10)).foregroundStyle(MochiColor.pink)
                        Text(creator.likeCount.formattedCompact)
                            .font(MochiFont.caption(11)).foregroundStyle(MochiColor.textSecondary)
                    }
                }
            }
            Spacer(minLength: 0)
            followButton
        }
        .padding(MochiSpacing.md)
        .background(Color.white, in: RoundedRectangle(cornerRadius: MochiRadius.card, style: .continuous))
        .contentShape(Rectangle())
        .onTapGesture(perform: onTap)
    }

    private var rankBadge: some View {
        Group {
            if rank <= 3 {
                Text("\(rank)")
                    .font(MochiFont.heading(13)).foregroundStyle(.white)
                    .frame(width: 28, height: 28)
                    .background(Self.medalColors[rank - 1], in: Circle())
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
                Image(creator.avatarAssetName).resizable().scaledToFill()
            } else {
                Image("avatar_user").resizable().scaledToFill()
            }
        }
        .frame(width: 56, height: 56)
        .clipShape(Circle())
    }

    private var followButton: some View {
        Button(action: onToggleFollow) {
            HStack(spacing: 4) {
                Image(systemName: "person.badge.plus")
                    .font(.system(size: 12))
                Text(isFollowing ? "Following" : "Follow")
                    .font(MochiFont.caption(12))
            }
            .foregroundStyle(isFollowing ? .white : MochiColor.purple)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background {
                if isFollowing {
                    Capsule().fill(MochiGradient.primaryButton)
                } else {
                    Capsule().fill(Color.white)
                        .overlay(Capsule().stroke(MochiColor.purple.opacity(0.3), lineWidth: 1))
                }
            }
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    LeaderboardView()
}
