import UIKit

/// The themed keyboard surface: background, scrim, suggestion bar, and either the key grid or the
/// emoji panel.
///
/// This one view is what both the in-app preview and the real keyboard extension render. That is
/// the point of it. The alternative — a SwiftUI preview in the app and a UIKit keyboard in the
/// extension — guarantees the two drift, and the drift always surfaces as the worst possible bug
/// in this product: the theme the user bought does not look like the theme they previewed.
///
/// Layer order, bottom to top:
///   1. `baseLayer`         — `surface.baseFill`, always drawn, also the art-missing fallback.
///   2. `artView`           — the background image, downsampled to the drawn size.
///   3. `scrimLayer`        — the contrast guarantee, and the reason this is not a wallpaper app.
///   4. `suggestionBar`     — completions, when enabled.
///   5. `keyContainer` / `emojiPlane` — the caps, or the emoji grid.
///   6. `callout`           — the long-press accent picker, above everything.
final class KeyboardSurfaceView: UIView {
    /// Reports key presses. `nil` in preview mode, which is what makes the preview inert without
    /// needing a second code path.
    var onAction: ((KeyAction) -> Void)?
    /// Reports a character chosen from the long-press accent picker.
    var onInsertText: ((String) -> Void)?

    // MARK: - Art tweak mode (DEBUG tooling)

    /// Turns the keyboard into an illustration picker: taps select a key's artwork instead of
    /// typing, and the selected cap carries a ring.
    ///
    /// It lives on the production renderer rather than in a separate lab view for the same reason
    /// the in-app test bench runs the production input engine — the placement someone dials in here
    /// has to be the placement the extension draws, and a second renderer built for tweaking would
    /// drift from the first one the moment either changed. The cost is this one flag, which the
    /// shipping keyboard never sets.
    var isArtTweakMode: Bool = false {
        didSet {
            guard oldValue != isArtTweakMode else { return }
            if !isArtTweakMode { selectArt(nil) }
            stopRepeating()
        }
    }

    /// Fires with the tapped key's `artIdentity`, or `nil` when a key with no illustration is
    /// tapped. Only called in tweak mode.
    var onArtSelected: ((String?) -> Void)?

    private(set) var selectedArtIdentity: String?

    private(set) var theme: MochiKeyboardTheme
    private(set) var plane: KeyboardPlane = .letters
    private var includesNextKeyboardKey: Bool

    /// Drives letter case and the shift key's appearance. The renderer owns the *presentation*;
    /// the view controller owns when it changes.
    var shiftState: ShiftState = .off {
        didSet { if oldValue != shiftState { updateShiftPresentation() } }
    }

    /// Whether to show the completions strip. Off in preview, where there is no text to complete.
    var showsSuggestionBar: Bool {
        didSet { if oldValue != showsSuggestionBar { setNeedsLayout() } }
    }

    private let baseLayer = CAGradientLayer()
    /// Clips `artView`, which is deliberately sized *larger* than the keyboard to crop the art —
    /// see `layoutArtFrame()`.
    private let artClip = UIView()
    private let artView = UIImageView()
    private let scrimLayer = CAGradientLayer()
    /// Renders `theme.effects`. Sits above the scrim and below the keys — ambient atmosphere behind
    /// the caps, not a layer that could ever compete with a label for contrast. `isHidden` whenever
    /// `effects.isEnabled` is false, which is the default for every theme that doesn't ask for this.
    private let effectsEmitter = CAEmitterLayer()
    private var effectsParticleImage: UIImage?
    private var effectsParticleTint: ThemeColor?
    private let keyContainer = UIView()
    private var keyViews: [KeyView] = []
    private lazy var suggestionBar = SuggestionBarView(chrome: theme.chrome)
    private var emojiPlane: EmojiPlaneView?

    private var callout: KeyCalloutView?
    private var calloutKey: KeyView?

    /// Fires backspace repeatedly while held.
    private var repeatTimer: Timer?
    private var repeatTicks = 0

    private var metrics: KeyboardMetrics
    /// The bounds size the current art was decoded for. Re-decoding on every layout pass would be
    /// the single most expensive thing this view could do, so art is only reloaded when the size
    /// it was prepared for is no longer the size being drawn.
    private var artSizeInUse: CGSize = .zero

    private let containerURL: URL?

    init(
        theme: MochiKeyboardTheme,
        includesNextKeyboardKey: Bool,
        showsSuggestionBar: Bool = false,
        containerURL: URL? = nil
    ) {
        self.theme = theme
        self.includesNextKeyboardKey = includesNextKeyboardKey
        self.showsSuggestionBar = showsSuggestionBar
        self.containerURL = containerURL
        self.metrics = KeyboardMetrics(availableWidth: UIScreen.main.bounds.width, isLandscape: false)
        super.init(frame: .zero)

        layer.addSublayer(baseLayer)

        artView.contentMode = .scaleToFill
        artClip.clipsToBounds = true
        artClip.isUserInteractionEnabled = false
        artClip.addSubview(artView)
        addSubview(artClip)

        layer.addSublayer(scrimLayer)

        effectsEmitter.isHidden = true
        layer.addSublayer(effectsEmitter)

        addSubview(suggestionBar)
        suggestionBar.onSelect = { [weak self] text in
            self?.onSuggestionSelected?(text)
        }

        keyContainer.backgroundColor = .clear
        addSubview(keyContainer)

        // `cancelsTouchesInView = false` so a normal tap still reaches the key. When the press does
        // become a long press we explicitly cancel that key's tracking, which is what stops the
        // base letter being inserted alongside the accent the user actually picked.
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        longPress.minimumPressDuration = 0.45
        longPress.cancelsTouchesInView = false
        longPress.delaysTouchesBegan = false
        keyContainer.addGestureRecognizer(longPress)

        applyTheme(theme)
        rebuildKeys()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    /// Called when a suggestion is tapped.
    var onSuggestionSelected: ((String) -> Void)?

    // MARK: - Theme

    func applyTheme(_ newTheme: MochiKeyboardTheme) {
        theme = newTheme

        let baseFill = theme.surface.baseFill
        // Duplicated for the same reason as key caps: CAGradientLayer draws nothing from a
        // single-entry `colors` array, so a flat base would render as a transparent keyboard.
        baseLayer.colors = baseFill.stops.count == 1
            ? [baseFill.stops[0].cgColor, baseFill.stops[0].cgColor]
            : baseFill.stops.map(\.cgColor)
        let radians = baseFill.angleDegrees * .pi / 180
        baseLayer.startPoint = CGPoint(x: 0.5 - cos(radians) / 2, y: 0.5 - sin(radians) / 2)
        baseLayer.endPoint = CGPoint(x: 0.5 + cos(radians) / 2, y: 0.5 + sin(radians) / 2)

        scrimLayer.colors = [theme.surface.scrim.topColor.cgColor, theme.surface.scrim.bottomColor.cgColor]
        scrimLayer.startPoint = CGPoint(x: 0.5, y: 0)
        scrimLayer.endPoint = CGPoint(x: 0.5, y: 1)

        // Force the art to reload on the next layout pass rather than reloading here: at this
        // point `bounds` may still be zero (the theme is usually applied before the input view has
        // been sized), and decoding for a zero size would throw the work away.
        artSizeInUse = .zero
        artView.image = nil
        artView.isHidden = theme.surface.backgroundImage == nil

        suggestionBar.applyChrome(theme.chrome)
        emojiPlane?.applyTheme(theme, metrics: metrics)
        applyEffects(theme.effects)

        for keyView in keyViews {
            keyView.apply(
                style: theme.style(for: keyView.definition.role),
                metrics: metrics,
                typography: theme.typography,
                artSet: theme.keyArt
            )
        }
        setNeedsLayout()
    }

    // MARK: - Effects

    /// Builds (or tears down) the ambient particle emitter from `theme.effects`.
    ///
    /// This is the one place `ThemeEffects` actually draws anything — previously the token was
    /// declared and ignored. `CAEmitterLayer` rather than a per-frame `draw(_:)` loop or a SpriteKit
    /// scene, per TRD ADR-002: it is GPU-composited, costs nothing when `isHidden`, and needs no
    /// timer of its own.
    private func applyEffects(_ effects: ThemeEffects) {
        guard effects.isEnabled, effects.birthRate > 0 else {
            effectsEmitter.isHidden = true
            effectsEmitter.emitterCells = nil
            return
        }
        effectsEmitter.isHidden = false

        let tint = effects.tint ?? ThemeColor(red: 1, green: 1, blue: 1)
        if effectsParticleImage == nil || effectsParticleTint != tint
            || effects.particleImageName != effectsParticleAssetName {
            effectsParticleImage = Self.makeParticleImage(named: effects.particleImageName, tint: tint)
            effectsParticleTint = tint
            effectsParticleAssetName = effects.particleImageName
        }

        let cell = CAEmitterCell()
        // Hard-capped regardless of what a theme document asks for: this is ambient atmosphere, not
        // a fireworks show, and the extension's dirty-memory ceiling has no headroom for a runaway
        // particle count — see `ThemeEffects.birthRate`'s own doc comment.
        cell.birthRate = Float(min(effects.birthRate, 14))
        cell.lifetime = 4.5
        cell.lifetimeRange = 1.5
        // A wide emission cone plus a steady downward pull reads as ambient drift regardless of
        // which way `emissionLongitude`'s zero point happens to face — `yAcceleration` alone
        // dominates the trajectory well before a particle's ~4.5s lifetime is up.
        cell.velocity = 8
        cell.velocityRange = 6
        cell.emissionRange = .pi * 2
        cell.yAcceleration = 16
        cell.scale = 0.16
        cell.scaleRange = 0.10
        cell.alphaSpeed = -0.22
        cell.spin = 0.4
        cell.spinRange = 0.9
        cell.contents = effectsParticleImage?.cgImage
        effectsEmitter.emitterCells = [cell]
    }

    /// Which `particleImageName` `effectsParticleImage` was built for, so a theme that only changes
    /// `tint` regenerates the texture but one that changes nothing does not.
    private var effectsParticleAssetName: String?

    /// A soft radial dot, tinted to the theme's `effects.tint` (or white). Generated once and cached
    /// rather than shipped as a bundled asset: no "sparkle" artwork exists for this to reference, and
    /// a tiny procedural texture is both honest about that and cheaper than decoding a PNG for
    /// something this small. `particleImageName` is still honoured first when a theme names a real
    /// bundled asset, so authored content is never silently overridden.
    private static func makeParticleImage(named particleImageName: String?, tint: ThemeColor) -> UIImage? {
        if let particleImageName, let bundled = UIImage(named: particleImageName) {
            return bundled
        }
        let diameter: CGFloat = 14
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: diameter, height: diameter))
        return renderer.image { context in
            let colors = [
                tint.uiColor.withAlphaComponent(0.9).cgColor,
                tint.uiColor.withAlphaComponent(0).cgColor
            ] as CFArray
            guard let gradient = CGGradient(
                colorsSpace: CGColorSpaceCreateDeviceRGB(),
                colors: colors,
                locations: [0, 1]
            ) else { return }
            context.cgContext.drawRadialGradient(
                gradient,
                startCenter: CGPoint(x: diameter / 2, y: diameter / 2), startRadius: 0,
                endCenter: CGPoint(x: diameter / 2, y: diameter / 2), endRadius: diameter / 2,
                options: []
            )
        }
    }

    func setPlane(_ newPlane: KeyboardPlane) {
        guard newPlane != plane else { return }
        plane = newPlane
        // Shift is a letters-plane concept; carrying it across a plane switch leaves the shift key
        // looking engaged on a plane that has no shift key.
        shiftState = .off
        dismissCallout()

        if plane == .emoji {
            installEmojiPlaneIfNeeded()
            emojiPlane?.isHidden = false
            keyContainer.isHidden = true
        } else {
            emojiPlane?.isHidden = true
            keyContainer.isHidden = false
            rebuildKeys()
        }
        setNeedsLayout()
    }

    func setIncludesNextKeyboardKey(_ includes: Bool) {
        guard includes != includesNextKeyboardKey else { return }
        includesNextKeyboardKey = includes
        rebuildKeys()
        setNeedsLayout()
    }

    func updateSuggestions(_ suggestions: [SuggestionEngine.Suggestion]) {
        suggestionBar.update(with: suggestions)
    }

    // MARK: - Sizing

    /// The height this keyboard wants for a given width. The extension turns this into its input
    /// view height constraint; the preview uses it to size its own frame.
    func preferredHeight(forWidth width: CGFloat) -> CGFloat {
        let candidate = KeyboardMetrics(
            availableWidth: width,
            isLandscape: UIScreen.main.bounds.width > UIScreen.main.bounds.height
        )
        let layout = KeyboardLayout.layout(
            for: plane,
            includesNextKeyboardKey: includesNextKeyboardKey,
            metrics: candidate
        )
        return candidate.totalHeight(
            rowCount: layout.rows.count,
            includesSuggestionBar: showsSuggestionBar
        )
    }

    // MARK: - Keys

    private func rebuildKeys() {
        keyViews.forEach { $0.removeFromSuperview() }
        keyViews.removeAll(keepingCapacity: true)

        let layout = KeyboardLayout.layout(
            for: plane == .emoji ? .letters : plane,
            includesNextKeyboardKey: includesNextKeyboardKey,
            metrics: metrics
        )
        for row in layout.rows {
            for definition in row.keys where definition.action != .spacer {
                let keyView = KeyView(
                    definition: definition,
                    style: theme.style(for: definition.role),
                    metrics: metrics,
                    typography: theme.typography,
                    artSet: theme.keyArt
                )
                keyView.addTarget(self, action: #selector(keyTapped(_:)), for: .touchUpInside)
                keyView.addTarget(self, action: #selector(keyTouchDown(_:)), for: .touchDown)
                for event in [UIControl.Event.touchUpInside, .touchUpOutside, .touchCancel, .touchDragExit] {
                    keyView.addTarget(self, action: #selector(keyTouchEnded(_:)), for: event)
                }
                keyContainer.addSubview(keyView)
                keyViews.append(keyView)
            }
        }
        updateShiftPresentation()
        // The key views were just thrown away, so the ring has to be re-applied — otherwise a
        // rotation or plane switch silently clears the selection while the panel still shows it.
        if isArtTweakMode { selectArt(selectedArtIdentity) }
    }

    @objc private func keyTapped(_ sender: KeyView) {
        if isArtTweakMode {
            selectArt(sender.definition.artIdentity)
            onArtSelected?(sender.definition.artIdentity)
            return
        }
        // Repeating keys already acted on touch-down; firing again on release would delete one
        // character too many on every tap.
        guard !sender.definition.repeatsWhenHeld else { return }
        guard callout == nil else { return }
        onAction?(sender.definition.action)
    }

    @objc private func keyTouchDown(_ sender: KeyView) {
        // Backspace must not run away while someone is picking illustrations, and a plane switch
        // fired from a tweak tap would swap the grid out from under the panel.
        guard !isArtTweakMode else { return }
        guard sender.definition.repeatsWhenHeld else { return }
        onAction?(sender.definition.action)
        startRepeating(sender)
    }

    // MARK: - Art tweak mode

    /// Moves the selection ring from outside — used when the panel's own state is the source of
    /// truth, such as a seeded launch argument.
    func selectArtIdentity(_ identity: String?) {
        guard identity != selectedArtIdentity else { return }
        selectArt(identity)
    }

    private func selectArt(_ identity: String?) {
        selectedArtIdentity = identity
        for keyView in keyViews {
            keyView.isArtSelected = identity != nil && keyView.definition.artIdentity == identity
        }
    }

    /// Replaces the whole per-key placement map and redraws. Driven by the tweak panel's sliders,
    /// so it runs on every value change and has to stay cheap: it mutates the art set in place and
    /// asks for a layout pass rather than rebuilding the key views, which would drop the selection
    /// and restart every illustration's decode.
    func updateKeyArtPlacements(_ placements: [String: KeyArtPlacement]) {
        guard var artSet = theme.keyArt else { return }
        artSet.placements = placements
        theme.keyArt = artSet
        for keyView in keyViews {
            keyView.apply(
                style: theme.style(for: keyView.definition.role),
                metrics: metrics,
                typography: theme.typography,
                artSet: artSet
            )
        }
        setNeedsLayout()
    }

    @objc private func keyTouchEnded(_ sender: KeyView) {
        stopRepeating()
    }

    // MARK: - Key repeat

    private func startRepeating(_ keyView: KeyView) {
        stopRepeating()
        repeatTicks = 0
        // 0.45s before the first repeat, matching the delay before the system keyboard starts
        // running. Repeating immediately makes a deliberate single delete feel like it ran away.
        repeatTimer = Timer.scheduledTimer(withTimeInterval: 0.45, repeats: false) { [weak self, weak keyView] _ in
            guard let self, let keyView else { return }
            self.beginSustainedRepeat(keyView)
        }
    }

    private func beginSustainedRepeat(_ keyView: KeyView) {
        repeatTimer?.invalidate()
        repeatTimer = Timer.scheduledTimer(withTimeInterval: 0.09, repeats: true) { [weak self, weak keyView] timer in
            guard let self, let keyView, keyView.isHighlighted else {
                self?.stopRepeating()
                return
            }
            self.repeatTicks += 1
            self.onAction?(keyView.definition.action)
            // Accelerates after roughly a second of holding, the way the system keyboard does, so
            // clearing a long line does not take as long as typing it did.
            if self.repeatTicks == 11 {
                timer.invalidate()
                self.repeatTimer = Timer.scheduledTimer(withTimeInterval: 0.04, repeats: true) { [weak self, weak keyView] innerTimer in
                    guard let self, let keyView, keyView.isHighlighted else {
                        self?.stopRepeating()
                        innerTimer.invalidate()
                        return
                    }
                    self.onAction?(keyView.definition.action)
                }
            }
        }
    }

    private func stopRepeating() {
        repeatTimer?.invalidate()
        repeatTimer = nil
        repeatTicks = 0
    }

    // MARK: - Long-press accent picker

    @objc private func handleLongPress(_ recognizer: UILongPressGestureRecognizer) {
        // The accent picker is meaningless while selecting illustrations, and it would cover the
        // very cap being judged.
        guard !isArtTweakMode else { return }
        let location = recognizer.location(in: keyContainer)

        switch recognizer.state {
        case .began:
            guard let keyView = keyViews.first(where: { $0.frame.contains(location) }),
                  !keyView.definition.alternates.isEmpty else { return }
            presentCallout(for: keyView)
            // Cancels the pending touchUpInside so the base letter is not inserted as well.
            keyView.cancelTracking(with: nil)

        case .changed:
            guard let callout else { return }
            callout.updateSelection(forTouchAt: recognizer.location(in: callout))

        case .ended:
            if let selection = callout?.selectedOption {
                onInsertText?(selection)
            }
            dismissCallout()

        case .cancelled, .failed:
            dismissCallout()

        default:
            break
        }
    }

    private func presentCallout(for keyView: KeyView) {
        dismissCallout()
        let alternates = keyView.definition.alternates
        // Alternates are offered in the case the user is currently typing in, so holding shift and
        // long-pressing `e` gives `É` rather than a lowercase accent they then have to fix.
        let cased = shiftState.isUppercase ? alternates.map { $0.uppercased() } : alternates

        let view = KeyCalloutView(
            options: cased,
            chrome: theme.chrome,
            metrics: metrics,
            typography: theme.typography
        )
        addSubview(view)
        let keyFrameInSelf = keyContainer.convert(keyView.frame, to: self)
        view.position(over: keyFrameInSelf, in: bounds)
        view.updateSelection(forTouchAt: CGPoint(x: view.bounds.midX, y: view.bounds.midY))
        callout = view
        calloutKey = keyView
    }

    private func dismissCallout() {
        callout?.removeFromSuperview()
        callout = nil
        calloutKey = nil
    }

    // MARK: - Emoji

    private func installEmojiPlaneIfNeeded() {
        guard emojiPlane == nil else { return }
        let view = EmojiPlaneView(
            theme: theme,
            metrics: metrics,
            showsNextKeyboardKey: includesNextKeyboardKey
        )
        view.onInsert = { [weak self] emoji in self?.onInsertText?(emoji) }
        view.onBackspace = { [weak self] in self?.onAction?(.backspace) }
        view.onReturnToLetters = { [weak self] in self?.onAction?(.switchPlane(.letters)) }
        view.onNextKeyboard = { [weak self] in self?.onAction?(.nextKeyboard) }
        addSubview(view)
        emojiPlane = view
    }

    // MARK: - Shift

    private func updateShiftPresentation() {
        for keyView in keyViews {
            keyView.setLetterCaseUppercased(shiftState.isUppercase)
            if case .shift = keyView.definition.action {
                keyView.isHighlighted_shiftActive = shiftState.showsEngagedKey
                // A distinct glyph for caps lock. Without it, one-shot and locked look identical
                // and the user has no way to tell why their next letter came out capitalised.
                keyView.setSymbolName(shiftState == .locked ? "capslock.fill" : "shift")
            }
        }
    }

    // MARK: - Layout

    override func layoutSubviews() {
        super.layoutSubviews()
        guard bounds.width > 0, bounds.height > 0 else { return }

        let newMetrics = KeyboardMetrics.forView(self)
        if newMetrics != metrics {
            metrics = newMetrics
            rebuildKeys()
            emojiPlane?.applyTheme(theme, metrics: metrics)
        }

        // Layer frames are set inside a disabled-action transaction: CALayer animates `frame`
        // implicitly, and on a keyboard that means the background visibly slides into place every
        // time the input view is resized.
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        baseLayer.frame = bounds
        scrimLayer.frame = bounds
        effectsEmitter.frame = bounds
        // A line source across the top edge: particles originate along the whole width and drift
        // down through the keyboard, which reads as ambient rather than coming from one spot.
        effectsEmitter.emitterPosition = CGPoint(x: bounds.midX, y: 0)
        effectsEmitter.emitterSize = CGSize(width: bounds.width, height: 1)
        effectsEmitter.emitterShape = .line
        CATransaction.commit()

        artClip.frame = bounds
        layoutArtFrame()

        // The completions bar is meaningless on the emoji plane, so it is hidden there and the
        // panel takes the full height instead. The keyboard's *total* height is deliberately left
        // unchanged across the switch — reclaiming the strip for more emoji is free, but resizing
        // the input view would make the host app's content jump under the user's thumb.
        let showsBar = showsSuggestionBar && plane != .emoji
        let barHeight = showsBar ? metrics.suggestionBarHeight : 0
        suggestionBar.isHidden = !showsBar
        suggestionBar.frame = CGRect(x: 0, y: 0, width: bounds.width, height: barHeight)

        let contentFrame = CGRect(
            x: 0,
            y: barHeight,
            width: bounds.width,
            height: max(0, bounds.height - barHeight)
        )
        keyContainer.frame = contentFrame
        emojiPlane?.frame = bounds

        let layout = KeyboardLayout.layout(
            for: plane == .emoji ? .letters : plane,
            includesNextKeyboardKey: includesNextKeyboardKey,
            metrics: metrics
        )
        let solved = KeyboardLayoutSolver.solve(
            layout: layout,
            metrics: metrics,
            in: contentFrame.size
        )
        // Solver output and `keyViews` are built by the same traversal in the same order, so they
        // correspond index-for-index. `zip` rather than a lookup keeps that assumption cheap and
        // makes a mismatch fail safe — extra views simply keep their previous frame.
        for (keyView, solvedKey) in zip(keyViews, solved) {
            keyView.frame = solvedKey.frame
        }

        loadArtIfNeeded()
    }

    private func loadArtIfNeeded() {
        guard let backgroundImage = theme.surface.backgroundImage else { return }
        guard bounds.size != artSizeInUse else { return }
        artSizeInUse = bounds.size

        let image = ThemeImageLoader.loadBackground(
            backgroundImage,
            targetSize: bounds.size,
            scale: traitCollection.displayScale > 0 ? traitCollection.displayScale : UIScreen.main.scale,
            containerURL: containerURL
        )
        artView.image = image
        // Art that failed to load leaves `baseFill` showing. The validator has already guaranteed
        // the theme is legible in exactly that state, so this needs no further handling.
        artView.isHidden = image == nil

        layoutArtFrame()
    }

    /// Sizes the art inside `artClip`, biasing which horizontal band survives the crop.
    ///
    /// The art is laid out by **frame**, oversized and offset inside a clipping view, rather than
    /// by setting `contentsRect` on the image view's layer. `UIImageView` owns its layer's
    /// contents — it rewrites `contents`, and with it the sampling rectangle, whenever the image or
    /// the layout changes — so a `contentsRect` written from outside is liable to be dropped on the
    /// next pass. That is not theoretical: on device it silently discarded the whole background
    /// plate for every theme that crops (which is all of them), leaving the flat `baseFill` showing
    /// and the art loaded, unhidden, correctly framed and simply never drawn.
    private func layoutArtFrame() {
        let box = artClip.bounds
        guard let image = artView.image, image.size.width > 0, image.size.height > 0,
              box.width > 0, box.height > 0 else {
            artView.frame = box
            return
        }

        guard theme.surface.backgroundImage?.scalesToFill ?? true else {
            // Aspect-fit: the whole image, letterboxed over `baseFill`.
            artView.contentMode = .scaleAspectFit
            artView.frame = box
            return
        }

        artView.contentMode = .scaleToFill
        let aspect = image.size.width / image.size.height
        let filledHeight = box.width / aspect
        if filledHeight >= box.height {
            // Taller than the box once width-matched: crop vertically, biased by the anchor.
            let anchor = CGFloat(theme.surface.backgroundImage?.verticalAnchor ?? 0.5)
            artView.frame = CGRect(
                x: 0,
                y: -(filledHeight - box.height) * anchor,
                width: box.width,
                height: filledHeight
            )
        } else {
            // Wider than the box once height-matched: crop horizontally, centred.
            let filledWidth = box.height * aspect
            artView.frame = CGRect(
                x: -(filledWidth - box.width) / 2,
                y: 0,
                width: filledWidth,
                height: box.height
            )
        }
    }

    // MARK: - Memory

    /// Called by the extension on a memory warning.
    ///
    /// Dropping the decoded art is the largest single reclaim available and it is fully
    /// recoverable — the next layout pass re-decodes it. Under a ~30–48 MB ceiling, responding to
    /// the warning is what stands between a keyboard that survives and one the system kills
    /// silently.
    func releaseDecodedArt() {
        artView.image = nil
        artSizeInUse = .zero
        // Per-key illustrations are the second largest reclaimable allocation after the plate, and
        // like it they regenerate from the bundle on the next layout pass.
        KeyArtStore.shared.releaseAll()
        // The particle texture is tiny next to the plate, but there is no reason to keep it either —
        // it regenerates from `applyEffects` the next time a theme is (re)applied.
        effectsEmitter.emitterCells = nil
        effectsParticleImage = nil
    }

    deinit {
        repeatTimer?.invalidate()
    }
}

// MARK: -

extension KeyView {
    /// Re-cases a letter cap in place. Non-letter keys are left alone — `123` and `return` are not
    /// affected by shift, and uppercasing them would be wrong rather than merely pointless.
    func setLetterCaseUppercased(_ uppercased: Bool) {
        guard case .insert(let character) = definition.action,
              character.count == 1,
              character.rangeOfCharacter(from: .letters) != nil else { return }
        setLabelText(uppercased ? character.uppercased() : character.lowercased())
    }
}
