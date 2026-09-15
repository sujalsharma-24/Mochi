import UIKit

/// The keyboard extension's root controller.
///
/// Deliberately thin. All typing behaviour lives in `KeyboardInputEngine`, which the in-app test
/// bench drives too — so shift, caps lock and the double-space period cannot behave differently in
/// the two places. What is left here is the parts that genuinely belong to an extension: the input
/// view's height, the theme reload on activation, and the memory warning.
///
/// UIKit rather than SwiftUI, per TRD ADR-002. That is not a style preference: hosting SwiftUI via
/// `UIHostingController` inside a `UIInputViewController` has a documented failure mode of leaking
/// several MB per keyboard switch, and under a ~30–48 MB ceiling a leak that size is fatal within
/// a few text fields rather than eventually.
final class KeyboardViewController: UIInputViewController {
    private var surfaceView: KeyboardSurfaceView?
    private var heightConstraint: NSLayoutConstraint?

    private let engine = KeyboardInputEngine()
    private var document: ProxyTextDocument?

    override func viewDidLoad() {
        super.viewDidLoad()

        // The input view must be transparent.
        //
        // On iOS 26, a host app that adopts Liquid Glass wraps the keyboard in a system-provided
        // rounded glass container and insets our content inside it. An opaque background on our
        // view paints over that container's corners and shows up as the grey bar/box users report.
        // Clearing it lets the system's own material show through where it is supposed to. There
        // is no API to ask whether the host adopted Liquid Glass, so this is unconditional — and
        // harmless on older hosts, because the theme's own base layer paints the surface anyway.
        view.backgroundColor = .clear
        inputView?.backgroundColor = .clear

        // An input view only adopts the height its own constraints ask for when it is allowed to
        // size itself. Without this the system substitutes the standard system-keyboard height and
        // `updateHeightConstraint()` below is silently ignored, however it is prioritised — which
        // is exactly what made the real keyboard ~44pt (one suggestion bar) shorter than the
        // in-app preview of the same theme. The visible symptom was not the missing bar but the
        // background art: `scaleAspectFill` into the shorter box crops equally top and bottom, so
        // the top of the scene the theme was designed around simply wasn't on screen.
        inputView?.allowsSelfSizing = true

        let surface = KeyboardSurfaceView(
            theme: ThemeStore.loadActiveTheme(),
            includesNextKeyboardKey: needsInputModeSwitchKey,
            showsSuggestionBar: true,
            containerURL: ThemeStore.containerURL
        )
        surface.translatesAutoresizingMaskIntoConstraints = false
        surface.onAction = { [weak self] action in self?.engine.handle(action) }
        surface.onInsertText = { [weak self] text in self?.engine.insert(text) }
        surface.onSuggestionSelected = { [weak self] text in self?.engine.acceptSuggestion(text) }
        view.addSubview(surface)
        NSLayoutConstraint.activate([
            surface.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            surface.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            surface.topAnchor.constraint(equalTo: view.topAnchor),
            surface.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        surfaceView = surface

        let document = ProxyTextDocument(proxy: textDocumentProxy)
        self.document = document
        engine.document = document
        engine.onStateChange = { [weak self] shiftState, suggestions in
            self?.surfaceView?.shiftState = shiftState
            self?.surfaceView?.updateSuggestions(suggestions)
        }
        engine.onPlaneChange = { [weak self] plane in
            self?.surfaceView?.setPlane(plane)
            self?.updateHeightConstraint()
        }
        engine.onNextKeyboard = { [weak self] in self?.advanceToNextInputMode() }
        engine.loadLexicon(from: self)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Re-read the theme on every activation. There is no push channel into an extension: the
        // app writes the document to the App Group container, and this is the moment we find out.
        // Doing it here rather than in `viewDidLoad` is what makes "apply a theme, tap a text
        // field, see it" work — the extension process is often reused across activations.
        surfaceView?.applyTheme(ThemeStore.loadActiveTheme())
        surfaceView?.setIncludesNextKeyboardKey(needsInputModeSwitchKey)
        // Same story as the theme: the app writes the applied font style into the App Group and
        // this activation is when the extension finds out.
        engine.appliedStyleID = FontStyleStore.loadAppliedStyleID()
        engine.refreshContextualState()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        updateHeightConstraint()
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Under this memory ceiling the warning is the last chance to act before the process is
        // killed with no crash log. Decoded background art is the largest reclaimable allocation
        // and it regenerates on the next layout pass, so it goes first.
        surfaceView?.releaseDecodedArt()
    }

    override func textDidChange(_ textInput: UITextInput?) {
        super.textDidChange(textInput)
        engine.refreshContextualState()
    }

    // MARK: - Height

    /// The system sizes a custom keyboard to match the system keyboard unless we say otherwise.
    /// We say otherwise, because our metrics are derived from the layout we actually draw — if the
    /// two disagree the keys get vertically squeezed inside a height nobody asked for.
    private func updateHeightConstraint() {
        guard let surfaceView, view.bounds.width > 0 else { return }
        let target = surfaceView.preferredHeight(forWidth: view.bounds.width)

        if let heightConstraint {
            // Constant-only updates avoid the constraint churn that shows up as the keyboard
            // visibly resizing itself a frame after it appears.
            if abs(heightConstraint.constant - target) > 0.5 {
                heightConstraint.constant = target
            }
            return
        }
        let constraint = view.heightAnchor.constraint(equalToConstant: target)
        // Below required, so that when the system imposes its own height during rotation or a
        // floating-keyboard transition, Auto Layout resolves it instead of logging a conflict and
        // breaking one of the two at random.
        constraint.priority = .init(999)
        constraint.isActive = true
        heightConstraint = constraint
    }
}
