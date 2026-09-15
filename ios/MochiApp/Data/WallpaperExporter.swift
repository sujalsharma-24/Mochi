import Photos
import SwiftUI
import UIKit
import os

/// Saving a bundled wallpaper out of the app, and remembering which one the user applied.
///
/// **On "Apply" and what iOS actually permits.** There is no public API to set the device's lock
/// or home screen wallpaper — none has ever shipped. So "Apply" cannot be one tap that silently
/// changes the Lock Screen, and this deliberately does not pretend otherwise. What it does instead
/// is walk the user the rest of the way: the image is written to the photo library at full
/// resolution, and then `openLockScreenFlow()` hands off to the real system wallpaper UI.
///
/// ⚠️ **`App-Prefs:` is not a documented URL scheme.** It opens Settings' own Wallpaper pane, which
/// is exactly the flow asked for, and it works on device — but App Review has rejected apps for
/// shipping it. It is tried first and falls back silently, so flipping `usesSettingsDeepLink` to
/// `false` below reduces the whole thing to the App-Store-safe path (Photos, then the share sheet,
/// whose "Use as Wallpaper" action is the only sanctioned route) without touching anything else.
enum WallpaperExporter {
    private static let logger = Logger(subsystem: "com.mochi.app", category: "WallpaperExporter")

    enum Outcome: Equatable {
        case saved
        /// The user has denied (or restricted) add-only photo access.
        case denied
        case failed(String)

        var message: String {
            switch self {
            case .saved:  return "Saved to your Photos."
            case .denied: return "Mochi needs permission to add to Photos. Turn it on in Settings › Mochi › Photos."
            case .failed(let why): return why
            }
        }
    }

    /// The bundled art at full resolution. `UIImage(named:)` resolves the same asset key the cards
    /// draw, so what gets saved is exactly what was previewed.
    static func image(for item: WallpaperItem) -> UIImage? {
        UIImage(named: item.assetName)
    }

    /// Writes the wallpaper into the photo library, asking for add-only access first.
    ///
    /// Add-only (`.addOnly`) rather than `.readWrite` on purpose: the app never reads the user's
    /// library, so asking for the full permission would be requesting access it has no use for.
    @MainActor
    static func saveToPhotos(_ item: WallpaperItem) async -> Outcome {
        guard let image = image(for: item) else {
            return .failed("That wallpaper's artwork is missing from the bundle.")
        }

        let status = await withCheckedContinuation { (c: CheckedContinuation<PHAuthorizationStatus, Never>) in
            PHPhotoLibrary.requestAuthorization(for: .addOnly) { c.resume(returning: $0) }
        }
        guard status == .authorized || status == .limited else {
            logger.info("Photos add-only access not granted: \(status.rawValue, privacy: .public)")
            return .denied
        }

        do {
            try await PHPhotoLibrary.shared().performChanges {
                PHAssetChangeRequest.creationRequestForAsset(from: image)
            }
            logger.info("Saved wallpaper to Photos: \(item.id, privacy: .public)")
            return .saved
        } catch {
            logger.error("Photos save failed: \(error.localizedDescription, privacy: .public)")
            return .failed(error.localizedDescription)
        }
    }
}

/// Which wallpaper the user last applied. Sibling of `DownloadedWallpaperStore` — same App Group
/// suite, same one-way app-writes contract — so a future "use this wallpaper behind the keyboard"
/// slice can read the choice without any new plumbing.
enum AppliedWallpaperStore {
    private static let logger = Logger(subsystem: "com.mochi.app", category: "AppliedWallpaperStore")

    private static var defaults: UserDefaults {
        UserDefaults(suiteName: AppGroup.identifier) ?? .standard
    }

    private static let key = "mochi.wallpapers.appliedWallpaperID"

    static func loadAppliedWallpaperID() -> String? {
        defaults.string(forKey: key)
    }

    static func apply(_ wallpaperID: String) {
        guard !wallpaperID.isEmpty else { return }
        defaults.set(wallpaperID, forKey: key)
        logger.info("Applied wallpaper: \(wallpaperID, privacy: .public)")
    }

    static func clear() {
        defaults.removeObject(forKey: key)
    }

    static func isApplied(_ wallpaperID: String) -> Bool {
        loadAppliedWallpaperID() == wallpaperID
    }
}

extension WallpaperExporter {
    /// Set to `false` to drop the undocumented Settings deep link and ship only the App-Store-safe
    /// fallbacks. See this file's header.
    static let usesSettingsDeepLink = true

    /// Where "Apply" ended up, so the caller can tell the user what to do next.
    enum Handoff {
        /// Settings opened on its Wallpaper pane — the user finishes there.
        case settings
        /// The Photos app opened; the saved wallpaper is the most recent item.
        case photos
        /// Nothing could be opened — the caller should present the share sheet instead.
        case none
    }

    /// Takes the user into the real iPhone wallpaper flow, best route first.
    ///
    /// Ordered by how close each lands to "set this as my Lock Screen": Settings › Wallpaper is
    /// the actual destination; Photos is one share-sheet tap away from it; the share sheet the
    /// caller falls back to is the same action reached from inside the app.
    @MainActor
    static func openLockScreenFlow() async -> Handoff {
        var candidates: [(String, Handoff)] = []
        if usesSettingsDeepLink {
            candidates += [("App-Prefs:root=Wallpaper", .settings), ("prefs:root=Wallpaper", .settings)]
        }
        candidates.append(("photos-redirect://", .photos))

        for (string, handoff) in candidates {
            guard let url = URL(string: string), UIApplication.shared.canOpenURL(url) else { continue }
            let opened = await UIApplication.shared.open(url)
            if opened { return handoff }
        }
        return .none
    }
}

/// The system share sheet, which is where iOS's own "Use as Wallpaper" action lives. Presented
/// from the preview's Apply button when the Settings/Photos handoff isn't available.
struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ controller: UIActivityViewController, context: Context) {}
}
