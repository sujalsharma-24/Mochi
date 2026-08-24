import Foundation

/// No `isVerified`/avatar-photo field exists anywhere in this app's schema, so real creator tiles
/// never show a verified badge or a real photo (falls back to the same neutral avatar every
/// unmatched creator id already renders) — not an oversight, there's nothing to source it from.
struct CommunityCreatorUi: Identifiable {
    let uid: String
    let name: String
    let themeCount: Int
    let isFollowing: Bool
    var id: String { uid }
}

enum CommunityUiState {
    case loading
    case data(feedThemes: [KeyboardTheme], latestThemes: [KeyboardTheme], creators: [CommunityCreatorUi])
    case error(String)
}

/// Swift mirror of android/.../features/community/CommunityViewModel.kt — backs Community's 5 feed
/// tabs + Popular Creators + Latest Creations + follow/report actions.
///
/// ThemeRepository's getTopRanked/getPublishedThemes/getThemesByCreators/getThemesByIds map 1:1 onto
/// Popular/Latest/Following/My Likes. "For you" has no dedicated query of its own — stands in with
/// getTopRanked until a real personalized feed is in scope.
///
/// Popular Creators has no dedicated backend query either (UserRepository can only create a profile,
/// not list/search them) — derived instead from the top-ranked themes batch, grouping by creatorUid
/// and counting appearances within that batch. That's a real-data approximation (not MockData), just
/// bounded to whichever creators show up in the top 20 themes, not a true global ranking.
@MainActor
final class CommunityViewModel: ObservableObject {
    @Published private(set) var uiState: CommunityUiState = .loading

    private let themeRepository: ThemeRepository?
    private let likeRepository: LikeRepository?
    private let followRepository: FollowRepository?
    private let reportRepository: ReportRepository?
    private let authRepository: AuthRepository?

    private var followedUids: Set<String> = []
    private var selectedTab: String = "For you"

    init(container: AppContainer?) {
        themeRepository = container?.themeRepository
        likeRepository = container?.likeRepository
        followRepository = container?.followRepository
        reportRepository = container?.reportRepository
        authRepository = container?.authRepository

        guard themeRepository != nil else { return }
        Task {
            if let uid = authRepository?.currentUser?.uid, let followRepository {
                let uids = (try? await followRepository.followedUids(followerId: uid)) ?? []
                followedUids = Set(uids)
            }
            await loadFeed()
        }
    }

    func selectTab(_ tab: String) {
        guard tab != selectedTab else { return }
        selectedTab = tab
        Task { await loadFeed() }
    }

    func loadFeed() async {
        guard let themeRepository else { return }
        let uid = authRepository?.currentUser?.uid
        do {
            let feedThemes = try await fetchTab(selectedTab, uid: uid)
            async let topRankedTask = try? themeRepository.getTopRanked(limit: 20)
            async let latestTask = try? themeRepository.getPublishedThemes(limit: 10)
            let topRanked = await topRankedTask ?? []
            let latest = await latestTask ?? []
            uiState = .data(feedThemes: feedThemes, latestThemes: latest, creators: buildCreators(topRanked))
        } catch {
            uiState = .error(error.localizedDescription)
        }
    }

    private func fetchTab(_ tab: String, uid: String?) async throws -> [KeyboardTheme] {
        guard let themeRepository else { return [] }
        switch tab {
        case "Popular":
            return try await themeRepository.getTopRanked(limit: 20)
        case "Latest":
            return try await themeRepository.getPublishedThemes(limit: 20)
        case "Following":
            var uids: [String] = []
            if let uid, let followRepository {
                uids = (try? await followRepository.followedUids(followerId: uid)) ?? []
            }
            return try await themeRepository.getThemesByCreators(creatorUids: uids)
        case "My Likes":
            var ids: [String] = []
            if let uid, let likeRepository {
                ids = (try? await likeRepository.likedThemeIds(uid: uid)) ?? []
            }
            return try await themeRepository.getThemesByIds(ids)
        default: // "For you" — no dedicated query yet, see class doc
            return try await themeRepository.getTopRanked(limit: 20)
        }
    }

    private func buildCreators(_ themes: [KeyboardTheme]) -> [CommunityCreatorUi] {
        var order: [String] = []
        var counts: [String: Int] = [:]
        var names: [String: String] = [:]
        for theme in themes where !theme.creatorUid.isEmpty {
            if counts[theme.creatorUid] == nil {
                order.append(theme.creatorUid)
                names[theme.creatorUid] = theme.creatorName
            }
            counts[theme.creatorUid, default: 0] += 1
        }
        return order.map { uid in
            CommunityCreatorUi(uid: uid, name: names[uid] ?? "", themeCount: counts[uid] ?? 0, isFollowing: followedUids.contains(uid))
        }
    }

    func toggleFollow(_ creatorUid: String) {
        guard let uid = authRepository?.currentUser?.uid, uid != creatorUid, let followRepository else { return }
        let wasFollowing = followedUids.contains(creatorUid)
        if wasFollowing { followedUids.remove(creatorUid) } else { followedUids.insert(creatorUid) }
        reapplyFollowState()
        Task {
            do {
                if wasFollowing {
                    try await followRepository.unfollow(followerId: uid, followeeId: creatorUid)
                } else {
                    try await followRepository.follow(followerId: uid, followeeId: creatorUid)
                }
            } catch {
                if wasFollowing { followedUids.insert(creatorUid) } else { followedUids.remove(creatorUid) }
                reapplyFollowState()
            }
        }
    }

    private func reapplyFollowState() {
        guard case .data(let feedThemes, let latestThemes, let creators) = uiState else { return }
        let updated = creators.map { CommunityCreatorUi(uid: $0.uid, name: $0.name, themeCount: $0.themeCount, isFollowing: followedUids.contains($0.uid)) }
        uiState = .data(feedThemes: feedThemes, latestThemes: latestThemes, creators: updated)
    }

    func reportTheme(themeId: String, reason: String) {
        guard let uid = authRepository?.currentUser?.uid, let reportRepository else { return }
        Task { try? await reportRepository.reportTheme(reporterUid: uid, themeId: themeId, reason: reason) }
    }
}

/// Community's card models carry a bit more than a bare theme (a fixed hashtag-chip color, a
/// summary line) that `KeyboardTheme` has no direct field for — description doubles as the summary,
/// and the tag palette is deterministically derived from the theme id so a given theme always shows
/// the same chip color rather than flickering between reloads.
extension KeyboardTheme {
    func toCommunityPost() -> CommunityPost {
        let palettes: [CommunityPost.TagPalette] = [.green, .blue, .peach]
        // `String.hashValue` is randomized per process launch in Swift, unlike Kotlin's stable
        // `hashCode()` — a manual stable sum keeps the same theme showing the same chip color
        // across relaunches instead of flickering.
        let stableHash = id.utf8.reduce(0) { $0 &+ Int($1) }
        let index = stableHash % palettes.count
        return CommunityPost(
            id: id,
            name: name,
            creatorName: creatorName,
            thumbAssetName: imageAssetName,
            summary: description,
            likeCount: likeCount,
            hashtags: hashtags,
            tagPalette: palettes[index]
        )
    }
}
