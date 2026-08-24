import SwiftUI

/// Port of android/.../features/themedetail/ThemeDetailScreen.kt. No Figma source exists for this
/// screen on either platform (see [[project-mochi-decisions]]'s Figma Ground Truth note) — layout
/// follows the locked feature spec for Screen 5 (Theme Detail): preview, name/description,
/// hashtags, creator credit, like/apply, same as Android's own from-scratch design.
struct ThemeDetailView: View {
    let theme: KeyboardTheme
    var onBack: () -> Void = {}
    var onUnlockPremium: () -> Void = {}
    var onCreatorClick: (String) -> Void = {}

    @StateObject private var viewModel: ThemeDetailViewModel

    init(theme: KeyboardTheme, onBack: @escaping () -> Void = {}, onUnlockPremium: @escaping () -> Void = {}, onCreatorClick: @escaping (String) -> Void = {}) {
        self.theme = theme
        self.onBack = onBack
        self.onUnlockPremium = onUnlockPremium
        self.onCreatorClick = onCreatorClick
        _viewModel = StateObject(wrappedValue: ThemeDetailViewModel(
            container: AppContainer.shared,
            themeId: theme.id,
            creatorUid: theme.creatorUid,
            initialLikeCount: theme.likeCount
        ))
    }

    /// The content-tier flag (theme.isPremium) only says this theme requires a subscription — a
    /// user who already has one isn't locked out of it, so the CTA/badge gate on both together.
    private var isLocked: Bool { theme.isPremium && !viewModel.isUserPremium }

    var body: some View {
        ZStack(alignment: .bottom) {
            MochiGradient.background.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 0) {
                    topBar

                    ZStack(alignment: .topTrailing) {
                        KeyboardThemeArt(assetName: theme.imageAssetName, seed: theme.id, ratio: 1.05)

                        if theme.isPremium {
                            HStack(spacing: 4) {
                                Image(systemName: "star.fill")
                                    .font(.system(size: 10))
                                Text("Premium")
                                    .font(MochiFont.caption(11))
                            }
                            .foregroundStyle(.white)
                            .padding(.horizontal, MochiSpacing.sm)
                            .padding(.vertical, 6)
                            .background(MochiColor.premiumTag)
                            .clipShape(Capsule())
                            .padding(MochiSpacing.sm)
                        }
                    }
                    .padding(.horizontal, MochiSpacing.md)

                    VStack(alignment: .leading, spacing: MochiSpacing.md) {
                        Text(theme.name)
                            .font(MochiFont.title(24))
                            .foregroundStyle(MochiColor.textPrimary)

                        CreatorRow(
                            creatorName: theme.creatorName,
                            creatorUid: theme.creatorUid,
                            isFollowing: viewModel.isFollowing,
                            onFollowClick: viewModel.toggleFollow,
                            onCreatorClick: { if !theme.creatorUid.isEmpty { onCreatorClick(theme.creatorUid) } }
                        )

                        Button(action: viewModel.toggleLike) {
                            HStack(spacing: 4) {
                                Image(systemName: viewModel.isLiked ? "heart.fill" : "heart")
                                    .foregroundStyle(MochiColor.pink)
                                Text(viewModel.likeCount.formattedCompact)
                                    .font(MochiFont.body(14))
                                    .foregroundStyle(MochiColor.textSecondary)
                            }
                        }

                        if !theme.description.isEmpty {
                            Text(theme.description)
                                .font(MochiFont.body(14))
                                .foregroundStyle(MochiColor.textSecondary)
                        }

                        if !theme.hashtags.isEmpty {
                            LazyVGrid(columns: [GridItem(.adaptive(minimum: 60), spacing: MochiSpacing.sm)], alignment: .leading, spacing: MochiSpacing.sm) {
                                ForEach(theme.hashtags, id: \.self) { tag in
                                    HashtagChip(tag: tag)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, MochiSpacing.md)
                    .padding(.vertical, MochiSpacing.md)
                }
                .padding(.bottom, 110)
            }

            VStack {
                HStack(spacing: MochiSpacing.sm) {
                    OutlineButton(title: "Preview") {}
                    GradientButton(title: isLocked ? "Unlock Premium" : "Apply Theme") {
                        if isLocked { onUnlockPremium() }
                    }
                }
                .padding(MochiSpacing.md)
            }
            .background(Color.white)
        }
    }

    private var topBar: some View {
        HStack {
            CircleIconButton(systemImage: "chevron.left", action: onBack)
            Spacer()
            CircleIconButton(systemImage: "square.and.arrow.up", action: {})
        }
        .padding(MochiSpacing.md)
    }
}

private struct CircleIconButton: View {
    let systemImage: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .foregroundStyle(MochiColor.textPrimary)
                .frame(width: 40, height: 40)
                .background(Color.white)
                .clipShape(Circle())
        }
    }
}

private struct CreatorRow: View {
    let creatorName: String
    let creatorUid: String
    let isFollowing: Bool
    let onFollowClick: () -> Void
    let onCreatorClick: () -> Void

    var body: some View {
        HStack(spacing: MochiSpacing.sm) {
            Button(action: onCreatorClick) {
                HStack(spacing: MochiSpacing.sm) {
                    ZStack {
                        Circle().fill(MochiColor.lavender)
                        Text(creatorName.prefix(1).uppercased())
                            .font(MochiFont.heading(14))
                            .foregroundStyle(MochiColor.purpleDark)
                    }
                    .frame(width: 32, height: 32)

                    Text(creatorName)
                        .font(MochiFont.body(14))
                        .foregroundStyle(MochiColor.textPrimary)

                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 14))
                        .foregroundStyle(MochiColor.purple)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            // MockData-sourced themes have no creatorUid to follow — hide the button rather than
            // ship a Follow action that can never actually do anything (same guard the view model
            // itself enforces).
            if !creatorUid.isEmpty {
                Button(action: onFollowClick) {
                    Text(isFollowing ? "Following" : "Follow")
                        .font(MochiFont.caption(12))
                        .foregroundStyle(MochiColor.purple)
                        .padding(.horizontal, MochiSpacing.sm)
                        .padding(.vertical, 6)
                        .background(MochiColor.purple.opacity(0.1))
                        .clipShape(Capsule())
                }
            }
        }
    }
}

private struct HashtagChip: View {
    let tag: String

    var body: some View {
        Text("#\(tag)")
            .font(MochiFont.caption(12))
            .foregroundStyle(MochiColor.purple)
            .padding(.horizontal, MochiSpacing.sm)
            .padding(.vertical, 6)
            .background(Color.white)
            .clipShape(Capsule())
    }
}

#Preview {
    ThemeDetailView(theme: MockData.popularThemes.first!)
}
