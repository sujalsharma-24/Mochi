import SwiftUI
import UIKit

/// One named list of themes on its own page — what every "see all" in the app opens.
///
/// Community's Top Themes and Latest Creations, and Profile's My Creations, Liked Themes and My
/// Downloads all show a *slice* of the catalogue in a row that scrolls out of view. Each had a "see
/// all" that did nothing. Rather than five bespoke screens, this is one page parameterised by which
/// slice it shows, using the same card treatment as the Themes grid so the app reads consistently.
struct ThemeCollectionView: View {
    let kind: ThemeCollectionKind
    var onBack: () -> Void = {}
    var onThemeClick: (KeyboardTheme) -> Void = { _ in }

    @State private var downloadedIDs: Set<String> = Set(DownloadedThemeStore.loadDownloadedThemeIDs())
    @AppStorage(AppliedThemeStore.defaultsKey) private var appliedThemeId: String = ""

    private var themes: [KeyboardTheme] { kind.themes }

    private var columns: [GridItem] {
        [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)]
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 14) {
                header

                if themes.isEmpty {
                    Text(kind.emptyMessage)
                        .font(MochiFont.body(14))
                        .foregroundStyle(MochiColor.textGreyWarm)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, 40)
                        .accessibilityIdentifier("themeCollection.empty")
                } else {
                    LazyVGrid(columns: columns, spacing: 14) {
                        ForEach(themes) { theme in
                            card(theme)
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 40)
        }
        .background(alignment: .top) {
            ZStack(alignment: .top) {
                Image("themes_background")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                SparkleField()
            }
            .ignoresSafeArea()
        }
        .onAppear { downloadedIDs = Set(DownloadedThemeStore.loadDownloadedThemeIDs()) }
    }

    private var header: some View {
        HStack(spacing: 12) {
            Button(action: onBack) {
                Image(systemName: "arrow.left")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(MochiColor.textPrimary)
                    .frame(width: 36, height: 36)
                    .background(Circle().fill(MochiGradient.themeCircleButton))
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("themeCollection.back")

            VStack(alignment: .leading, spacing: 2) {
                Text(kind.title)
                    .font(MochiFont.title(20))
                    .foregroundStyle(MochiColor.logoSolid)
                Text(kind.subtitle)
                    .font(MochiFont.caption(11))
                    .foregroundStyle(MochiColor.textGreyWarm)
            }
            Spacer(minLength: 0)
        }
        .padding(.top, 4)
    }

    private func card(_ theme: KeyboardTheme) -> some View {
        VStack(spacing: 0) {
            ThemePlateThumbnail(assetName: theme.imageAssetName)
                .aspectRatio(640.0 / 440.0, contentMode: .fit)
                .clipped()
                .overlay(alignment: .topTrailing) {
                    Button {
                        let nowDownloaded = DownloadedThemeStore.toggle(theme.id)
                        if nowDownloaded { downloadedIDs.insert(theme.id) } else { downloadedIDs.remove(theme.id) }
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    } label: {
                        Image(systemName: downloadedIDs.contains(theme.id)
                              ? "checkmark.circle.fill" : "arrow.down.circle.fill")
                            .font(.system(size: 18))
                            .foregroundStyle(downloadedIDs.contains(theme.id) ? MochiColor.logoSolid : .white)
                            .shadow(color: .black.opacity(0.25), radius: 2)
                    }
                    .buttonStyle(.plain)
                    .padding(6)
                    .accessibilityIdentifier("themeCollection.\(theme.id).download")
                }

            VStack(alignment: .leading, spacing: 3) {
                Text(theme.name)
                    .font(MochiFont.caption(12))
                    .foregroundStyle(MochiColor.textPrimary)
                    .lineLimit(1)

                HStack(spacing: 4) {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 9))
                        .foregroundStyle(MochiColor.heart)
                    Text(theme.likeCountFormatted)
                        .font(MochiFont.caption(10))
                        .foregroundStyle(MochiColor.textGreyWarm)
                    Spacer(minLength: 0)
                    if appliedThemeId == theme.id {
                        Text("Applied")
                            .font(MochiFont.caption(9))
                            .foregroundStyle(MochiColor.logoSolid)
                    }
                }
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 7)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.white)
        }
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .shadow(color: MochiColor.purpleDark.opacity(0.13), radius: 5, y: 3)
        .contentShape(Rectangle())
        .onTapGesture { onThemeClick(theme) }
        .accessibilityIdentifier("themeCollection.card.\(theme.id)")
    }
}

/// Which slice of the catalogue a `ThemeCollectionView` shows. `Hashable` so it can travel on the
/// navigation path as part of `AppRoute`.
enum ThemeCollectionKind: String, Hashable {
    case topThemes, latest, myCreations, liked, downloads

    var title: String {
        switch self {
        case .topThemes:   return "Top Themes"
        case .latest:      return "Latest Creations"
        case .myCreations: return "My Creations"
        case .liked:       return "Liked Themes"
        case .downloads:   return "My Downloads"
        }
    }

    var subtitle: String {
        switch self {
        case .topThemes:   return "The most-loved themes in Mochi"
        case .latest:      return "Freshly added to the collection"
        case .myCreations: return "Themes published under your name"
        case .liked:       return "Everything you've hearted"
        case .downloads:   return "Themes you've kept"
        }
    }

    var emptyMessage: String {
        switch self {
        case .liked:     return "Tap the heart on a theme to keep it here."
        case .downloads: return "Tap the download icon on a theme to keep it here."
        default:         return "Nothing here yet."
        }
    }

    var themes: [KeyboardTheme] {
        switch self {
        case .topThemes:   return ThemeCatalog.topThemes(ThemeCatalog.all.count)
        case .latest:      return ThemeCatalog.latest(ThemeCatalog.all.count)
        case .myCreations: return CustomThemeStore.publishedCatalogueThemes() + ThemeCatalog.featured
        case .liked:       return LikedThemeStore.likedThemes()
        case .downloads:
            return DownloadedThemeStore.loadDownloadedThemeIDs().reversed()
                .compactMap { ThemeCatalog.theme(id: $0) }
        }
    }
}
