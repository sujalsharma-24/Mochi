import SwiftUI
import UIKit

/// A fully interactive keyboard inside the containing app, driven by the **same**
/// `KeyboardInputEngine` and `KeyboardSurfaceView` the real extension uses.
///
/// It exists because the loop for testing a keyboard extension — build, install, walk through
/// Settings, find a text field in another app — is slow enough that people stop doing it, and
/// typing behaviour that nobody exercises is typing behaviour that quietly rots. Everything except
/// the host document is real: shift and caps lock, the double-space period, backspace repeat, the
/// long-press accent picker, the emoji panel and the completions bar all run the production code.
///
/// The one thing it cannot prove is memory. The simulator has no jetsam limit, so a keyboard that
/// would be killed on device looks perfectly healthy here.
struct KeyboardTestBench: UIViewRepresentable {
    let theme: MochiKeyboardTheme
    /// Mirrors what has been "typed", so the caller can display it.
    @Binding var typedText: String
    /// Plane to open on. Exists so a screenshot of the emoji panel can be captured from the
    /// command line, where there is no way to tap the emoji key.
    var initialPlane: KeyboardPlane = .letters

    func makeCoordinator() -> Coordinator {
        Coordinator(typedText: $typedText)
    }

    func makeUIView(context: Context) -> KeyboardSurfaceView {
        let surface = KeyboardSurfaceView(
            theme: theme,
            includesNextKeyboardKey: true,
            showsSuggestionBar: true,
            containerURL: ThemeStore.containerURL
        )
        context.coordinator.attach(to: surface)
        if initialPlane != .letters {
            surface.setPlane(initialPlane)
        }
        return surface
    }

    func updateUIView(_ view: KeyboardSurfaceView, context: Context) {
        if view.theme != theme {
            view.applyTheme(theme)
        }
    }

    static func preferredHeight(for theme: MochiKeyboardTheme, width: CGFloat) -> CGFloat {
        let metrics = KeyboardMetrics(availableWidth: width, isLandscape: false)
        let layout = KeyboardLayout.layout(for: .letters, includesNextKeyboardKey: true, metrics: metrics)
        return metrics.totalHeight(rowCount: layout.rows.count, includesSuggestionBar: true)
    }

    final class Coordinator {
        private let engine = KeyboardInputEngine()
        private let document = BufferTextDocument()
        private var typedText: Binding<String>
        private weak var surface: KeyboardSurfaceView?

        init(typedText: Binding<String>) {
            self.typedText = typedText
        }

        func attach(to surface: KeyboardSurfaceView) {
            self.surface = surface
            engine.document = document
            document.onChange = { [weak self] text in
                // Bindings must be written on the main actor; every call path into here is already
                // a touch event, so this is a hop only in the pathological case.
                DispatchQueue.main.async { self?.typedText.wrappedValue = text }
            }
            engine.onStateChange = { [weak surface] shiftState, suggestions in
                surface?.shiftState = shiftState
                surface?.updateSuggestions(suggestions)
            }
            engine.onPlaneChange = { [weak surface] plane in surface?.setPlane(plane) }
            // No other keyboard to advance to inside the app; the globe key is shown because that
            // is what most users will see, but it does nothing here.
            engine.onNextKeyboard = {}

            surface.onAction = { [weak self] action in self?.engine.handle(action) }
            surface.onInsertText = { [weak self] text in self?.engine.insert(text) }
            surface.onSuggestionSelected = { [weak self] text in self?.engine.acceptSuggestion(text) }
            engine.refreshContextualState()
        }
    }
}
