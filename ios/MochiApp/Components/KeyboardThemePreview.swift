import SwiftUI
import UIKit

/// A live, correct preview of what the keyboard extension will actually look like.
///
/// It wraps the *same* `KeyboardSurfaceView` the extension renders, rather than reimplementing the
/// keyboard in SwiftUI. That is the whole reason the renderer is UIKit and lives in `MochiShared`.
/// A parallel SwiftUI implementation would be nicer to write and would start drifting from the
/// real keyboard the first time either side was touched — and in a theme marketplace, "the theme
/// I previewed is not the theme I got" is the one bug that costs refunds and ratings.
///
/// The preview is inert: it does not forward key actions anywhere, so taps still show press
/// feedback (which is worth seeing) but type nothing.
struct KeyboardThemePreview: UIViewRepresentable {
    let theme: MochiKeyboardTheme
    var plane: KeyboardPlane = .letters
    /// Whether to draw the globe key. Real keyboards only show it when the user has more than one
    /// keyboard installed; a preview should show it, because that is what most users will get.
    var showsNextKeyboardKey: Bool = true

    func makeUIView(context: Context) -> KeyboardSurfaceView {
        let view = KeyboardSurfaceView(
            theme: theme,
            includesNextKeyboardKey: showsNextKeyboardKey,
            containerURL: ThemeStore.containerURL
        )
        view.setPlane(plane)
        // Compression resistance below the SwiftUI default keeps a preview inside a scroll view
        // from fighting its container for height instead of simply being given it.
        view.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        return view
    }

    func updateUIView(_ view: KeyboardSurfaceView, context: Context) {
        if view.theme != theme {
            view.applyTheme(theme)
        }
        view.setPlane(plane)
        view.setIncludesNextKeyboardKey(showsNextKeyboardKey)
    }

    /// Reports the keyboard's natural height so a caller can size the preview without hardcoding a
    /// number that will be wrong on the next device width.
    static func preferredHeight(for theme: MochiKeyboardTheme, width: CGFloat, plane: KeyboardPlane = .letters) -> CGFloat {
        let metrics = KeyboardMetrics(availableWidth: width, isLandscape: false)
        let layout = KeyboardLayout.layout(for: plane, includesNextKeyboardKey: true, metrics: metrics)
        return metrics.totalHeight(rowCount: layout.rows.count)
    }
}

/// The preview at its natural height, which is almost always what a caller wants.
struct SizedKeyboardThemePreview: View {
    let theme: MochiKeyboardTheme
    var plane: KeyboardPlane = .letters

    var body: some View {
        GeometryReader { proxy in
            KeyboardThemePreview(theme: theme, plane: plane)
                .frame(
                    width: proxy.size.width,
                    height: KeyboardThemePreview.preferredHeight(
                        for: theme,
                        width: proxy.size.width,
                        plane: plane
                    )
                )
        }
        .frame(height: KeyboardThemePreview.preferredHeight(
            for: theme,
            width: UIScreen.main.bounds.width,
            plane: plane
        ))
    }
}
