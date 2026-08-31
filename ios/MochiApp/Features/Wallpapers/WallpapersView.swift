import SwiftUI

/// Ported from android/.../features/wallpapers/WallpaperExploreScreen.kt (docs/figma/10.png).
///
/// The Figma frame is a wide sidebar+content layout unlike every other screen here; adapted to the
/// app's phone-width single-column convention, same call Android made. Mock data only: the search
/// box filters locally, the category chips are decorative (no backing field), and "download" just
/// marks the wallpaper as recently-downloaded in-session. Premium wallpapers route to the paywall.
struct WallpapersView: View {
    var onBack: () -> Void = {}
    var onUnlockPremium: () -> Void = {}

    @ObservedObject private var billing = BillingRepository.shared
    @State private var query = ""
    @State private var selectedCategory = "Popular"
    @State private var downloaded: [String] = []

    private let categories: [(String, String)] = [
        ("Popular", "flame.fill"), ("Latest", "clock.fill"), ("Cute", "face.smiling.fill"),
        ("Dark", "moon.stars.fill"), ("Nature", "leaf.fill"), ("Space", "globe")
    ]

    private var filtered: [WallpaperItem] {
        let q = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !q.isEmpty else { return MockData.wallpapers }
        return MockData.wallpapers.filter { $0.name.lowercased().contains(q) }
    }

    private var recentlyDownloaded: [WallpaperItem] {
        downloaded.compactMap { id in MockData.wallpapers.first { $0.id == id } }
    }

    var body: some View {
        ZStack {
            MochiGradient.background.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: MochiSpacing.lg) {
                    header
                    searchBar
                    featuredBanner
                    categoryRow
                    grid
                    if !recentlyDownloaded.isEmpty { recentSection }
                    goPremiumBanner
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, MochiSpacing.md)
                .padding(.top, MochiSpacing.md)
                .padding(.bottom, 40)
            }
            .scrollIndicators(.hidden)
        }
        .clipped()
    }

    private func tap(_ item: WallpaperItem) {
        if item.isPremium && !billing.isUserPremium {
            onUnlockPremium()
        } else if !downloaded.contains(item.id) {
            downloaded.insert(item.id, at: 0)
        }
    }

    // MARK: - Pieces

    private var header: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack(spacing: 8) {
                Button(action: onBack) {
                    Image(systemName: "arrow.left")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(MochiColor.purple)
                        .frame(width: 32, height: 32)
                        .background(Color.white, in: Circle())
                }
                .accessibilityIdentifier("wallpapers.back")
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(Color.white)
                    .frame(width: 28, height: 28)
                    .overlay(Image(systemName: "photo.fill").font(.system(size: 13)).foregroundStyle(MochiColor.purple))
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(MochiColor.purple.opacity(0.3), lineWidth: 1))
                Text("Wallpapers").font(MochiFont.title(24)).foregroundStyle(MochiColor.textPrimary)
            }
            Text("Find the perfect wallpaper for your keyboard")
                .font(MochiFont.caption(12)).foregroundStyle(MochiColor.textSecondary)
        }
    }

    private var searchBar: some View {
        HStack(spacing: MochiSpacing.sm) {
            TextField("Search wallpapers..", text: $query)
                .font(MochiFont.body(14))
                .foregroundStyle(MochiColor.textPrimary)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
            Image(systemName: "magnifyingglass").foregroundStyle(MochiColor.textPrimary)
        }
        .padding(.horizontal, MochiSpacing.md)
        .padding(.vertical, 14)
        .background(Color.white, in: Capsule())
    }

    private var featuredBanner: some View {
        Color.clear
            .frame(height: (UIScreen.main.bounds.width - 2 * MochiSpacing.md) / 1.9)
            .frame(maxWidth: .infinity)
            .overlay(
                Image("wallpaper_moonlight_night")
                    .resizable()
                    .scaledToFill()
            )
            .clipShape(RoundedRectangle(cornerRadius: MochiRadius.card, style: .continuous))
    }

    private var categoryRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: MochiSpacing.sm) {
                ForEach(categories, id: \.0) { label, icon in
                    let isSelected = label == selectedCategory
                    VStack(spacing: 2) {
                        Image(systemName: icon).font(.system(size: 16)).foregroundStyle(MochiColor.purple)
                        Text(label).font(MochiFont.caption(9)).foregroundStyle(MochiColor.textPrimary)
                    }
                    .frame(width: 64, height: 64)
                    .background(Color.white, in: RoundedRectangle(cornerRadius: MochiRadius.card, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: MochiRadius.card, style: .continuous)
                            .stroke(isSelected ? MochiColor.purple : MochiColor.purple.opacity(0.15), lineWidth: 1)
                    )
                    .onTapGesture { selectedCategory = label }
                }
            }
        }
    }

    private var grid: some View {
        VStack(alignment: .leading, spacing: MochiSpacing.sm) {
            Text("LIVE WALLPAPERS").font(MochiFont.heading(13)).foregroundStyle(MochiColor.textPrimary)
            if filtered.isEmpty {
                Text("No wallpapers found.").font(MochiFont.caption(12)).foregroundStyle(MochiColor.textSecondary)
            } else {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: MochiSpacing.md), count: 3), spacing: MochiSpacing.md) {
                    ForEach(filtered) { item in
                        card(item)
                    }
                }
            }
        }
    }

    private func card(_ item: WallpaperItem) -> some View {
        let isLocked = item.isPremium && !billing.isUserPremium
        return VStack(alignment: .leading, spacing: 4) {
            ZStack(alignment: .topTrailing) {
                Image(item.assetName)
                    .resizable().scaledToFill()
                    .frame(maxWidth: .infinity)
                    .aspectRatio(1, contentMode: .fill)
                    .clipped()
                if item.isPremium {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 9)).foregroundStyle(.white)
                        .padding(5)
                        .background(MochiColor.premiumTag, in: Capsule())
                        .padding(6)
                }
            }
            HStack {
                Text(item.name)
                    .font(MochiFont.heading(12)).foregroundStyle(MochiColor.textPrimary)
                    .lineLimit(1)
                Spacer(minLength: 2)
                Image(systemName: isLocked ? "lock.fill" : (downloaded.contains(item.id) ? "checkmark.circle.fill" : "arrow.down.circle"))
                    .font(.system(size: 13)).foregroundStyle(MochiColor.purple)
            }
            .padding(.horizontal, 8)
            .padding(.bottom, 6)
        }
        .background(Color.white, in: RoundedRectangle(cornerRadius: MochiRadius.card, style: .continuous))
        .clipShape(RoundedRectangle(cornerRadius: MochiRadius.card, style: .continuous))
        .contentShape(Rectangle())
        .onTapGesture { tap(item) }
    }

    private var recentSection: some View {
        VStack(alignment: .leading, spacing: MochiSpacing.sm) {
            Text("Recently Downloaded").font(MochiFont.heading(15)).foregroundStyle(MochiColor.textPrimary)
            ForEach(recentlyDownloaded) { item in
                HStack(spacing: MochiSpacing.sm) {
                    Image(item.assetName).resizable().scaledToFill()
                        .frame(width: 40, height: 40)
                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                    Text(item.name).font(MochiFont.body(13)).foregroundStyle(MochiColor.textPrimary)
                    Spacer()
                    Image(systemName: "checkmark.circle.fill").font(.system(size: 17)).foregroundStyle(MochiColor.purple)
                }
                .padding(MochiSpacing.sm)
                .background(Color.white, in: RoundedRectangle(cornerRadius: MochiRadius.card, style: .continuous))
            }
        }
    }

    private var goPremiumBanner: some View {
        HStack(spacing: MochiSpacing.sm) {
            Image("icon_premium_crown").resizable().scaledToFill()
                .frame(width: 48, height: 48).clipShape(Circle())
            VStack(alignment: .leading, spacing: 2) {
                Text("Go Premium").font(MochiFont.heading(15)).foregroundStyle(MochiColor.purple)
                Text("Unlock premium wallpapers and exclusive collections.")
                    .font(MochiFont.caption(11)).foregroundStyle(MochiColor.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 0)
            Button("Upgrade Now", action: onUnlockPremium)
                .font(MochiFont.caption(12)).foregroundStyle(.white)
                .padding(.horizontal, 14).padding(.vertical, 8)
                .background(MochiGradient.primaryButton, in: Capsule())
        }
        .padding(MochiSpacing.md)
        .background(Color.white, in: RoundedRectangle(cornerRadius: MochiRadius.card, style: .continuous))
    }
}

#Preview {
    WallpapersView()
}
