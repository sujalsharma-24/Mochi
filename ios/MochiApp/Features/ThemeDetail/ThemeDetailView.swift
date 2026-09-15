import SwiftUI
import UIKit

/// Port of android/.../features/themedetail/ThemeDetailScreen.kt. No Figma source exists for this
/// screen on either platform (see [[project-mochi-decisions]]'s Figma Ground Truth note) — layout
/// follows the locked feature spec for Screen 5 (Theme Detail): preview, name/description,
/// hashtags, creator credit, like/apply, same as Android's own from-scratch design.
struct ThemeDetailView: View {
    let theme: KeyboardTheme
    var onBack: () -> Void = {}
    var onUnlockPremium: () -> Void = {}
    var onCreatorClick: (String) -> Void = { _ in }

    @StateObject private var viewModel: ThemeDetailViewModel

    @AppStorage(AppliedThemeStore.defaultsKey) private var appliedThemeId: String = ""
    @State private var showTrySheet = false
    @State private var trySheetIsApplied = false

    private var isApplied: Bool { appliedThemeId == theme.id }

    init(theme: KeyboardTheme, onBack: @escaping () -> Void = {}, onUnlockPremium: @escaping () -> Void = {}, onCreatorClick: @escaping (String) -> Void = { _ in }) {
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

    private var cardWidth: CGFloat {
        min(UIScreen.main.bounds.width - 40, 400)
    }

    var body: some View {
        VStack(spacing: 0) {
            topBar

            Spacer(minLength: 8)

            if theme.isPremium {
                premiumBadge
                    .padding(.bottom, 20)
            }

            keyboardCard

            Spacer().frame(height: 14)

            infoSection

            Spacer(minLength: 16)

            buttonsSection

            Spacer().frame(height: 60)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background {
            GeometryReader { geo in
                if ThemeArtAvailability.hasArt(theme.imageAssetName) {
                    Image(theme.imageAssetName)
                        .resizable()
                        .scaledToFill()
                        .frame(width: geo.size.width, height: geo.size.height)
                        .clipped()
                        .blur(radius: 40)
                        .overlay(Color.black.opacity(0.45))
                } else {
                    MochiGradient.background
                }
            }
            .ignoresSafeArea()
        }
        .gesture(
            DragGesture(minimumDistance: 24)
                .onEnded { value in
                    if value.translation.width > 90, abs(value.translation.height) < 120 { onBack() }
                }
        )
        .sheet(isPresented: $showTrySheet) {
            KeyboardTrySheet(marketplaceTheme: theme, applied: trySheetIsApplied)
                .presentationDetents([.large])
        }
    }

    // MARK: - Premium Badge (Centered directly above keyboard card)

    private var premiumBadge: some View {
        HStack(spacing: 4) {
            Image(systemName: "star.fill")
                .font(.system(size: 9))
            Text("Premium")
                .font(MochiFont.caption(10))
                .fontWeight(.semibold)
        }
        .foregroundStyle(.white)
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(MochiColor.premiumTag)
        .clipShape(Capsule())
        .shadow(color: .black.opacity(0.2), radius: 4, y: 2)
    }

    // MARK: - Top Bar (Circular back on left, Like heart on right, positioned safely below status bar)

    private var topBar: some View {
        HStack {
            Button(action: onBack) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 42, height: 42)
                    .background(Circle().fill(.black.opacity(0.35)))
                    .overlay(Circle().stroke(.white.opacity(0.2), lineWidth: 0.5))
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("themeDetail.back")

            Spacer()

            Button {
                viewModel.toggleLike()
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
            } label: {
                Image(systemName: viewModel.isLiked ? "heart.fill" : "heart")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(viewModel.isLiked ? MochiColor.heart : .white)
                    .frame(width: 42, height: 42)
                    .background(Circle().fill(.black.opacity(0.35)))
                    .overlay(Circle().stroke(.white.opacity(0.2), lineWidth: 0.5))
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("themeDetail.like")
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
    }

    // MARK: - Keyboard Card (100% clean — zero overlays blocking the keys)

    private var keyboardCard: some View {
        let width = cardWidth
        let height = KeyboardThemePreview.preferredHeight(
            for: resolvedTheme.theme,
            width: width,
            plane: .letters,
            includesSuggestionBar: false
        )

        return KeyboardThemePreview(
            theme: resolvedTheme.theme,
            plane: .letters,
            showsNextKeyboardKey: true,
            showsSuggestionBar: false
        )
        .frame(width: width, height: height)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(.white.opacity(0.25), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.35), radius: 18, y: 8)
    }

    // MARK: - Info Section (Shifted up directly below keyboard with 14pt gap)

    private var infoSection: some View {
        VStack(spacing: 6) {
            Text(theme.name)
                .font(MochiFont.title(22))
                .fontWeight(.bold)
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)

            HStack(spacing: 8) {
                Button {
                    viewModel.toggleLike()
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: viewModel.isLiked ? "heart.fill" : "heart")
                            .foregroundStyle(viewModel.isLiked ? MochiColor.heart : .white.opacity(0.9))
                        Text(viewModel.likeCount.formattedCompact)
                            .foregroundStyle(.white.opacity(0.9))
                    }
                }
                .buttonStyle(.plain)

                Text("•")
                    .foregroundStyle(.white.opacity(0.4))
                Text(theme.category.rawValue.uppercased())
                    .foregroundStyle(.white.opacity(0.75))
                if !theme.creatorName.isEmpty {
                    Text("•")
                        .foregroundStyle(.white.opacity(0.4))
                    Text(theme.creatorName.hasPrefix("by ") ? theme.creatorName : "by \(theme.creatorName)")
                        .foregroundStyle(.white.opacity(0.75))
                }
            }
            .font(MochiFont.caption(12))

            if !resolvedTheme.isExact {
                Text("Preview shown with a matching Mochi theme — this design’s own artwork is still in production.")
                    .font(MochiFont.caption(11))
                    .foregroundStyle(.white.opacity(0.70))
                    .multilineTextAlignment(.center)
                    .padding(.top, 2)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(.horizontal, 24)
    }

    // MARK: - Buttons Section (Mobile app capsule buttons, matched to card width, 48pt height)

    private var buttonsSection: some View {
        HStack(spacing: 12) {
            actionButton(
                title: "Preview",
                icon: "eye.fill",
                filled: false,
                id: "preview"
            ) {
                trySheetIsApplied = false
                showTrySheet = true
            }

            if isLocked {
                actionButton(
                    title: "Unlock Premium",
                    icon: "star.fill",
                    filled: true,
                    id: "unlock"
                ) {
                    onUnlockPremium()
                }
            } else if isApplied {
                actionButton(
                    title: "Applied",
                    icon: "checkmark",
                    filled: true,
                    id: "applied"
                ) {
                    trySheetIsApplied = false
                    showTrySheet = true
                }
            } else {
                actionButton(
                    title: "Apply Theme",
                    icon: "paintbrush.fill",
                    filled: true,
                    id: "apply"
                ) {
                    applyTheme()
                }
            }
        }
        .frame(width: cardWidth)
    }

    private func actionButton(
        title: String,
        icon: String,
        filled: Bool,
        id: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .semibold))
                Text(title)
                    .font(MochiFont.body(14))
                    .fontWeight(.semibold)
                    .lineLimit(1)
            }
            .foregroundStyle(filled ? .white : MochiColor.logoSolid)
            .frame(maxWidth: .infinity)
            .frame(height: 48)
            .background {
                if filled {
                    Capsule().fill(MochiGradient.softButton)
                } else {
                    Capsule().fill(.white)
                }
            }
            .clipShape(Capsule())
            .shadow(color: .black.opacity(0.12), radius: 8, y: 3)
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("themeDetail.\(id)")
    }

    private var resolvedTheme: RenderableTheme.Resolved {
        RenderableTheme.resolve(for: theme)
    }

    private func applyTheme() {
        AppliedThemeStore.apply(theme)
        appliedThemeId = theme.id
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        trySheetIsApplied = true
        showTrySheet = true
    }
}

private struct CircleIconButton: View {
    let systemImage: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 40, height: 40)
                .background(Circle().fill(.black.opacity(0.35)))
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
                        .foregroundStyle(.white)

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
