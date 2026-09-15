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
    /// Whether to draw the suggestion-bar row above the keys. Off by default so the many call sites
    /// that only ever wanted the key grid (theme cards, list thumbnails) don't grow a row they never
    /// asked for; the Create-theme editor's full-keyboard preview turns this on explicitly.
    var showsSuggestionBar: Bool = false
    /// Root to resolve `.appGroupFile` background art against. Defaults to the real App Group
    /// container, which is `nil` until that entitlement is provisioned — pass
    /// `CustomThemeStore.mediaRootURL` here when previewing a theme whose photo background was
    /// written there instead, or this preview silently shows no art for it (`ThemeImageLoader`
    /// returns `nil` for an `.appGroupFile` source with no container to resolve against).
    var containerURL: URL? = ThemeStore.containerURL

    /// A theme editor is the one place the suggestion bar needs to look alive rather than blank —
    /// `SuggestionBarView` simply renders nothing for an empty list, and an unseeded strip would
    /// read as a broken row rather than "here's where suggestions go." These three are inert set
    /// dressing (the preview forwards no taps anywhere); the middle two are muted the way a real
    /// completion would be, so the row also shows off the theme's own chrome colours.
    private static let previewSuggestions: [SuggestionEngine.Suggestion] = [
        .init(text: "Mochi", isVerbatim: true),
        .init(text: "keyboard", isVerbatim: false),
        .init(text: "theme", isVerbatim: false)
    ]

    func makeUIView(context: Context) -> KeyboardSurfaceView {
        let view = KeyboardSurfaceView(
            theme: theme,
            includesNextKeyboardKey: showsNextKeyboardKey,
            showsSuggestionBar: showsSuggestionBar,
            containerURL: containerURL
        )
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.setPlane(plane)
        if showsSuggestionBar {
            view.updateSuggestions(Self.previewSuggestions)
        }
        // Compression resistance below the SwiftUI default keeps a preview inside a scroll view
        // from fighting its container for height instead of simply being given it.
        view.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        view.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return view
    }

    func sizeThatFits(_ proposal: ProposedViewSize, uiView: KeyboardSurfaceView, context: Context) -> CGSize? {
        let width = proposal.width ?? (UIScreen.main.bounds.width - 40)
        let height = Self.preferredHeight(
            for: theme,
            width: width,
            plane: plane,
            includesSuggestionBar: showsSuggestionBar
        )
        return CGSize(width: width, height: height)
    }

    func updateUIView(_ view: KeyboardSurfaceView, context: Context) {
        if view.theme != theme {
            view.applyTheme(theme)
        }
        view.setPlane(plane)
        view.setIncludesNextKeyboardKey(showsNextKeyboardKey)
        view.showsSuggestionBar = showsSuggestionBar
        if showsSuggestionBar {
            view.updateSuggestions(Self.previewSuggestions)
        }
    }

    /// Reports the keyboard's natural height so a caller can size the preview without hardcoding a
    /// number that will be wrong on the next device width.
    static func preferredHeight(
        for theme: MochiKeyboardTheme, width: CGFloat, plane: KeyboardPlane = .letters,
        includesSuggestionBar: Bool = false
    ) -> CGFloat {
        let metrics = KeyboardMetrics(availableWidth: width, isLandscape: false)
        let layout = KeyboardLayout.layout(for: plane, includesNextKeyboardKey: true, metrics: metrics)
        return metrics.totalHeight(rowCount: layout.rows.count, includesSuggestionBar: includesSuggestionBar)
    }
}

/// The preview at its natural height, which is almost always what a caller wants.
struct SizedKeyboardThemePreview: View {
    let theme: MochiKeyboardTheme
    var plane: KeyboardPlane = .letters
    var showsSuggestionBar: Bool = false
    var containerURL: URL? = ThemeStore.containerURL

    var body: some View {
        GeometryReader { proxy in
            KeyboardThemePreview(
                theme: theme, plane: plane, showsSuggestionBar: showsSuggestionBar, containerURL: containerURL
            )
            .frame(
                width: proxy.size.width,
                height: KeyboardThemePreview.preferredHeight(
                    for: theme,
                    width: proxy.size.width,
                    plane: plane,
                    includesSuggestionBar: showsSuggestionBar
                )
            )
        }
        .frame(height: KeyboardThemePreview.preferredHeight(
            for: theme,
            width: UIScreen.main.bounds.width,
            plane: plane,
            includesSuggestionBar: showsSuggestionBar
        ))
    }
}
