import Foundation

/// Swift mirror of android/.../features/themedetail/ThemeDetailViewModel.kt. Liking writes a real
/// `likes/{uid}_{themeId}` doc; the theme's own stored likeCount only updates once
/// `onLikeWritten` (functions/src/likes.ts) processes that write server-side, so `likeCount` here
/// is a local optimistic counter for instant feedback, not a read of the persisted field — it can
/// drift from the real value and isn't re-synced after. Follow reuses the same FollowRepository
/// Community/Profile will eventually share; `creatorUid` is empty for MockData-sourced themes (the
/// view already guards on that before showing a Follow button at all).
///
/// Takes `AppContainer?` rather than individual repositories (unlike AuthView, which force-unwraps
/// `AppContainer.shared` because it's only ever reached once the backend is configured) — Theme
/// Detail is reachable from Home/Themes' still-MockData tabs regardless of whether a real backend
/// exists yet, so every action here must degrade to a harmless no-op instead of crashing when
/// `container` is nil. `isUserPremium` is hardcoded false for the same reason Android's Theme
/// Detail originally shipped without real entitlement gating: no BillingRepository/RevenueCat SDK
/// exists on iOS yet (Paywall hasn't been built here) — a documented gap, not an oversight.
@MainActor
final class ThemeDetailViewModel: ObservableObject {
    @Published private(set) var isLiked = false
    @Published private(set) var likeCount: Int
    @Published private(set) var isFollowing = false
    @Published private(set) var isUserPremium = false

    private let container: AppContainer?
    private let themeId: String
    private let creatorUid: String

    init(container: AppContainer?, themeId: String, creatorUid: String, initialLikeCount: Int) {
        self.container = container
        self.themeId = themeId
        self.creatorUid = creatorUid
        self.likeCount = initialLikeCount

        guard let container, let uid = container.authRepository.currentUser?.uid else { return }
        Task {
            if let liked = try? await container.likeRepository.isLiked(uid: uid, themeId: themeId) {
                isLiked = liked
            }
        }
        if !creatorUid.isEmpty, creatorUid != uid {
            Task {
                if let following = try? await container.followRepository.isFollowing(followerId: uid, followeeId: creatorUid) {
                    isFollowing = following
                }
            }
        }
    }

    func toggleLike() {
        guard let container, let uid = container.authRepository.currentUser?.uid else { return }
        let wasLiked = isLiked
        isLiked = !wasLiked
        likeCount += wasLiked ? -1 : 1
        Task {
            do {
                if wasLiked {
                    try await container.likeRepository.unlike(uid: uid, themeId: themeId)
                } else {
                    try await container.likeRepository.like(uid: uid, themeId: themeId)
                }
            } catch {
                isLiked = wasLiked
                likeCount += wasLiked ? 1 : -1
            }
        }
    }

    func toggleFollow() {
        guard let container, let uid = container.authRepository.currentUser?.uid else { return }
        guard !creatorUid.isEmpty, creatorUid != uid else { return }
        let wasFollowing = isFollowing
        isFollowing = !wasFollowing
        Task {
            do {
                if wasFollowing {
                    try await container.followRepository.unfollow(followerId: uid, followeeId: creatorUid)
                } else {
                    try await container.followRepository.follow(followerId: uid, followeeId: creatorUid)
                }
            } catch {
                isFollowing = wasFollowing
            }
        }
    }
}
