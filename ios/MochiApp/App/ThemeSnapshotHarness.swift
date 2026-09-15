import SwiftUI
import UIKit

/// DEBUG-only: renders every built-in theme's real keyboard (`KeyboardSurfaceView`, the same view
/// the extension draws) to a PNG in the app's Documents/snapshots folder, then exits.
///
/// Launch with `-MochiThemeSnapshots 1`; narrow it with `-MochiThemeSnapshotIDs id1,id2`. Two jobs:
/// reviewing many themes side by side without screenshotting them one at a time, and producing the
/// `themethumb_*` browse thumbnails so every catalogue card shows its own keyboard, not a raw plate.
#if DEBUG
enum ThemeSnapshotHarness {
    static var isEnabled: Bool {
        UserDefaults.standard.bool(forKey: "MochiThemeSnapshots")
    }

    private static var themes: [MochiKeyboardTheme] {
        let raw = UserDefaults.standard.string(forKey: "MochiThemeSnapshotIDs") ?? ""
        let wanted = raw.split(separator: ",").map { String($0) }
        guard !wanted.isEmpty else { return BuiltInThemes.all }
        return BuiltInThemes.all.filter { theme in wanted.contains { theme.id.hasSuffix($0) } }
    }

    @MainActor
    static func run(in window: UIWindow) {
        let folder = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("snapshots", isDirectory: true)
        try? FileManager.default.removeItem(at: folder)
        try? FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)

        let width: CGFloat = 402
        for theme in themes {
            // The suggestion bar is part of the keyboard the user gets, so the thumbnail shows it.
            // Without it a card showed the key grid alone, cropped into the tile's 1.45:1 frame,
            // which read as a zoomed-in detail rather than as "this is what you'll be typing on".
            let height = KeyboardThemePreview.preferredHeight(
                for: theme, width: width, plane: .letters, includesSuggestionBar: true
            )
            let view = KeyboardSurfaceView(
                theme: theme,
                includesNextKeyboardKey: true,
                showsSuggestionBar: true,
                containerURL: nil
            )
            view.frame = CGRect(x: 0, y: 0, width: width, height: height)
            view.setPlane(.letters)
            // An empty bar renders as a blank strip; these are the same inert three the in-app
            // preview seeds it with, so the row reads as a suggestion bar in the theme's own chrome.
            view.updateSuggestions([
                .init(text: "Mochi", isVerbatim: true),
                .init(text: "keyboard", isVerbatim: false),
                .init(text: "theme", isVerbatim: false)
            ])
            window.addSubview(view)
            view.setNeedsLayout()
            view.layoutIfNeeded()

            let format = UIGraphicsImageRendererFormat()
            format.scale = 2
            let image = UIGraphicsImageRenderer(size: view.bounds.size, format: format).image { _ in
                view.drawHierarchy(in: view.bounds, afterScreenUpdates: true)
            }
            view.removeFromSuperview()

            if let data = image.pngData() {
                try? data.write(to: folder.appendingPathComponent("\(theme.id).png"))
            }
        }
        print("MochiThemeSnapshots: wrote \(themes.count) to \(folder.path)")
        exit(0)
    }
}

/// Hosts the harness: it needs a real window for `drawHierarchy` to capture layer effects.
struct ThemeSnapshotHostView: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if let window = view.window { ThemeSnapshotHarness.run(in: window) }
        }
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
}
#endif
