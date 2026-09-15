import SwiftUI
import UIKit

/// Full-screen preview for one wallpaper, reached by tapping any thumbnail anywhere in the
/// Wallpapers section — discovery rows, theme pages, collections, search results and the
/// Recently Downloaded strip all open this same view.
///
/// It is deliberately the one place the art is shown uncropped: every grid tile is a crop, so the
/// preview draws the source at its own aspect ratio behind a phone-shaped safe frame, which is
/// what the user is really deciding about. `Download` writes it to Photos; `Apply` does that and
/// then hands over the system share sheet — see `WallpaperExporter` for why that last step cannot
/// be automated on iOS.
struct WallpaperPreviewView: View {
    let item: WallpaperItem
    var isDownloaded: Bool
    var onToggleDownload: () -> Void
    var onClose: () -> Void

    @State private var applied = false
    @State private var sharing = false
    @State private var busy = false
    @State private var toast: String?

    var body: some View {
        ZStack {
            // The art itself is the backdrop, blurred and dimmed, so a portrait source fills a
            // portrait screen without either letterboxing or being cropped to death.
            Image(item.assetName)
                .resizable()
                .scaledToFill()
                .blur(radius: 40)
                .overlay(Color.black.opacity(0.45))
                .ignoresSafeArea()

            VStack(spacing: 0) {
                topBar
                Spacer(minLength: 8)
                artwork
                Spacer(minLength: 8)
                footer
            }
        }
        // `fullScreenCover` has no interactive dismiss of its own, so the edge swipe everyone
        // expects from a pushed screen is wired by hand.
        .gesture(
            DragGesture(minimumDistance: 24)
                .onEnded { value in
                    if value.translation.width > 90, abs(value.translation.height) < 120 { onClose() }
                }
        )
        .onAppear { applied = AppliedWallpaperStore.isApplied(item.id) }
        .sheet(isPresented: $sharing) {
            if let image = WallpaperExporter.image(for: item) {
                ShareSheet(items: [image])
            }
        }
        .overlay(alignment: .bottom) {
            if let toast {
                Text(toast)
                    .font(MochiFont.body(13))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 16).padding(.vertical, 10)
                    .background(Capsule().fill(.black.opacity(0.75)))
                    .padding(.horizontal, 24)
                    .padding(.bottom, 96)
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
            }
        }
        .animation(.snappy, value: toast)
        .accessibilityIdentifier("wallpapers.preview.\(item.id)")
    }

    /// Back only. It sits a clear line below the status bar rather than level with the clock, and
    /// the Like control has moved onto the artwork itself — see `artwork`.
    private var topBar: some View {
        HStack {
            Button(action: onClose) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white)
                    .padding(10)
                    .background(Circle().fill(.black.opacity(0.35)))
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("wallpapers.preview.close")

            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.top, 28)
    }

    private var artwork: some View {
        Image(item.assetName)
            .resizable()
            .scaledToFit()
            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(.white.opacity(0.25), lineWidth: 1))
            // Like rides in the artwork's own top-right corner, inside the rounded crop, so it
            // reads as part of the wallpaper card rather than as a stray chrome button.
            .overlay(alignment: .topTrailing) {
                Button {
                    onToggleDownload()
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                } label: {
                    Image(systemName: isDownloaded ? "heart.fill" : "heart")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(isDownloaded ? MochiColor.heart : .white)
                        .frame(width: 34, height: 34)
                        .background(Circle().fill(.black.opacity(0.28)))
                        .overlay(Circle().stroke(.white.opacity(0.25), lineWidth: 0.5))
                }
                .buttonStyle(.plain)
                .padding(12)
                .accessibilityIdentifier("wallpapers.preview.keep")
            }
            .shadow(color: .black.opacity(0.35), radius: 18, y: 8)
            .padding(.horizontal, 28)
    }

    private var footer: some View {
        VStack(spacing: 20) {
            VStack(spacing: 4) {
                Text(item.name)
                    .font(MochiFont.title(20))
                    .foregroundStyle(.white)
                HStack(spacing: 10) {
                    Label(item.likeCountText, systemImage: "heart.fill")
                        .foregroundStyle(.white.opacity(0.9))
                    Text(item.category.title.uppercased())
                        .foregroundStyle(.white.opacity(0.7))
                }
                .font(MochiFont.caption(11))
            }

            HStack(spacing: 10) {
                actionButton(title: isDownloaded ? "Downloaded" : "Download",
                             icon: isDownloaded ? "checkmark.circle.fill" : "arrow.down.to.line",
                             filled: false,
                             id: "download") {
                    await download()
                }
                actionButton(title: applied ? "Applied" : "Apply Wallpaper",
                             icon: applied ? "checkmark" : "lock.iphone",
                             filled: true,
                             id: "apply") {
                    await apply()
                }
            }
            .padding(.horizontal, 20)
            .disabled(busy)
        }
        .padding(.top, 18)
        .padding(.bottom, 34)
    }

    private func actionButton(title: String, icon: String, filled: Bool, id: String,
                              action: @escaping () async -> Void) -> some View {
        Button {
            Task { await action() }
        } label: {
            HStack(spacing: 5) {
                Image(systemName: icon).font(.system(size: 13, weight: .semibold))
                Text(title).font(MochiFont.body(13)).lineLimit(1).minimumScaleFactor(0.7)
            }
            .foregroundStyle(filled ? .white : MochiColor.logoSolid)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background {
                if filled {
                    // `softButton` is the ramp Home's action cards and the FONTS/THEMES pill use —
                    // orchid into a warm pink and out to periwinkle. `primaryButton` reads too
                    // purple across a button this wide.
                    Capsule().fill(MochiGradient.softButton)
                } else {
                    Capsule().fill(.white)
                }
            }
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("wallpapers.preview.\(id)")
    }

    // MARK: Actions

    private func download() async {
        busy = true
        defer { busy = false }
        let outcome = await WallpaperExporter.saveToPhotos(item)
        if outcome == .saved, !isDownloaded { onToggleDownload() }
        show(outcome.message)
    }

    /// Save first, *then* hand off — every downstream route (Settings › Wallpaper, Photos, the
    /// share sheet's "Use as Wallpaper") reads the image out of the photo library, so opening any
    /// of them before the write lands would offer art the system cannot see yet.
    private func apply() async {
        busy = true
        let outcome = await WallpaperExporter.saveToPhotos(item)
        busy = false
        guard outcome == .saved else { show(outcome.message); return }

        AppliedWallpaperStore.apply(item.id)
        applied = true
        if !isDownloaded { onToggleDownload() }
        UINotificationFeedbackGenerator().notificationOccurred(.success)

        switch await WallpaperExporter.openLockScreenFlow() {
        case .settings:
            show("Saved to Photos. Pick it under Wallpaper › Add New Wallpaper › Photos.")
        case .photos:
            show("Saved to Photos — it's your most recent shot. Share it, then “Use as Wallpaper”.")
        case .none:
            sharing = true
        }
    }

    private func show(_ message: String) {
        toast = message
        Task {
            try? await Task.sleep(nanoseconds: 3_200_000_000)
            if toast == message { toast = nil }
        }
    }
}
