import UIKit

/// One themed key cap.
///
/// Built from `CALayer`s rather than `draw(_:)` so that a press changes two animatable properties
/// instead of invalidating and re-rasterising the cap. On a keyboard that distinction is felt
/// directly: `setNeedsDisplay` on every keystroke is the difference between keys that respond
/// instantly and keys that feel a frame late.
///
/// Layer stack, bottom to top:
///   `layer`      — shadow host only. Never clips, so the shadow can fall outside the cap.
///   `capLayer`   — the fill gradient, corner radius, and border. Clips.
///   `glossLayer` — the top-edge highlight that gives the cap its bevel.
///   label / icon — the ink.
final class KeyView: UIControl {
    let definition: KeyDefinition

    private let capLayer = CAGradientLayer()
    private let glossLayer = CAGradientLayer()
    /// Rounded, clipping container. The illustration is deliberately allowed to overflow its band
    /// so it bleeds off the cap's left and right edges the way the reference art does; this is what
    /// trims that bleed back to the cap's shape.
    private let artClipView = UIView()
    private let artView = UIImageView()
    /// A flat black/white wash over the illustration only, driven by `KeyArtPlacement.brightness`.
    /// Sits between `artView` and the label so it tints the art without touching the cap fill.
    /// Masked to the illustration's own alpha channel — see `layoutArt()` — so it tints the motif,
    /// not a rectangle around it.
    private let artBrightnessOverlay = UIView()
    private let artBrightnessMask = CALayer()
    /// Bright hairline just inside the top edge — the pane's thickness catching light.
    private let bevelLayer = CAGradientLayer()
    private let bevelMask = CAShapeLayer()
    /// Depth at the bottom edge, where that same thickness occludes light.
    private let innerShadowLayer = CAShapeLayer()
    private let label = UILabel()
    private let iconView = UIImageView()

    /// Masks for `capShape == .hexagon`. `CALayer.cornerRadius` cannot express a hexagon, so a
    /// non-rectangular shape gets its silhouette from a mask instead. Created once and left
    /// detached (`mask` stays `nil` on both hosts) until a theme actually asks for a shape that
    /// needs one — every rounded-rect theme, which today is all of them, never touches these.
    private let capShapeMask = CAShapeLayer()
    private let artShapeMask = CAShapeLayer()

    /// The theme's illustration set, if it has one.
    private var artSet: KeyArtSet?

    private var style: KeyStyle
    private var metrics: KeyboardMetrics
    private var typography: ThemeTypography
    /// Set by `setSymbolName(_:)`; overrides the definition's glyph.
    private var overriddenSymbolName: String?

    /// Set by the container when shift is engaged, so the shift key can render its active state.
    var isHighlighted_shiftActive: Bool = false {
        didSet { if oldValue != isHighlighted_shiftActive { applyState(animated: false) } }
    }

    /// Draws the art tweak lab's selection ring. DEBUG tooling only — the shipping keyboard never
    /// sets this, and the layer is not created until something does.
    var isArtSelected: Bool = false {
        didSet { if oldValue != isArtSelected { updateSelectionRing() } }
    }
    private var selectionLayer: CAShapeLayer?

    init(
        definition: KeyDefinition,
        style: KeyStyle,
        metrics: KeyboardMetrics,
        typography: ThemeTypography,
        artSet: KeyArtSet? = nil
    ) {
        self.definition = definition
        self.style = style
        self.metrics = metrics
        self.typography = typography
        self.artSet = artSet
        super.init(frame: .zero)

        // The shadow lives on the view's own layer because `capLayer` has to clip its gradient to
        // the rounded corners, and a clipping layer cannot cast a shadow outside itself.
        layer.masksToBounds = false

        capLayer.needsDisplayOnBoundsChange = true
        layer.addSublayer(capLayer)

        glossLayer.masksToBounds = true
        capLayer.addSublayer(glossLayer)

        artClipView.isUserInteractionEnabled = false
        artClipView.clipsToBounds = true
        addSubview(artClipView)

        // Aspect-**fill**, not fit. Fitting is what made the first pass look wrong: a tall motif
        // like the lit tower got scaled down until it fitted the band's height, leaving it small
        // and floating with dead space either side. Filling makes every illustration span the cap's
        // full width and bleed off both edges, which is how the reference art reads.
        artView.contentMode = .scaleAspectFill
        artView.isUserInteractionEnabled = false
        artClipView.addSubview(artView)

        artBrightnessOverlay.isUserInteractionEnabled = false
        artBrightnessOverlay.isHidden = true
        artBrightnessMask.contentsGravity = .resizeAspectFill
        artBrightnessOverlay.layer.mask = artBrightnessMask
        artClipView.addSubview(artBrightnessOverlay)

        // Both sit above the artwork: the edge of a pane is in front of whatever is inside it.
        innerShadowLayer.fillRule = .evenOdd
        innerShadowLayer.fillColor = UIColor.black.cgColor
        layer.addSublayer(innerShadowLayer)

        bevelMask.fillColor = UIColor.clear.cgColor
        bevelMask.strokeColor = UIColor.black.cgColor
        bevelLayer.mask = bevelMask
        layer.addSublayer(bevelLayer)

        label.textAlignment = .center
        label.isUserInteractionEnabled = false
        // A themed keyboard can be handed a font that has no glyph budget for `return` on a narrow
        // cap. Shrinking is the right failure — truncating a key label is not.
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.7
        label.baselineAdjustment = .alignCenters
        addSubview(label)

        // `.center`, not `.scaleAspectFit`. Aspect-fit *upscales* to the view's bounds, which meant
        // the symbol configuration's point size below had no effect at all and every glyph was
        // drawn at cap height. Centring renders the symbol at exactly the size it was configured
        // for, which is the only way the point size becomes a real control.
        iconView.contentMode = .center
        iconView.isUserInteractionEnabled = false
        addSubview(iconView)

        configureContent()
        apply(style: style, metrics: metrics, typography: typography, artSet: artSet)

        isAccessibilityElement = true
        accessibilityTraits = .keyboardKey
        accessibilityLabel = definition.accessibilityLabel ?? definition.label
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // MARK: - Content

    /// Swaps the glyph without rebuilding the key. Used for shift → caps lock, which has to be
    /// distinguishable at a glance or the user cannot tell why their letters are capitalised.
    func setSymbolName(_ name: String) {
        guard definition.symbolName != nil, overriddenSymbolName != name else { return }
        overriddenSymbolName = name
        configureContent()
    }

    private func configureContent() {
        if let symbolName = overriddenSymbolName ?? definition.symbolName {
            label.isHidden = true
            iconView.isHidden = false
            // `.medium` rather than the default so symbol keys hold their weight against the
            // letter caps — a hairline glyph next to a bold `Q` reads as a rendering bug.
            //
            // Sized at the system label size exactly. An earlier 1.15× multiplier was measured on
            // screen at roughly 60% of the cap height against the system keyboard's ~40%, which
            // made shift and backspace shout over the letters they sit beside.
            let configuration = UIImage.SymbolConfiguration(
                pointSize: metrics.systemLabelPointSize,
                weight: .medium
            )
            iconView.image = UIImage(systemName: symbolName, withConfiguration: configuration)
        } else {
            label.isHidden = false
            iconView.isHidden = true
            label.text = definition.label
        }
    }

    // MARK: - Theming

    func apply(
        style: KeyStyle,
        metrics: KeyboardMetrics,
        typography: ThemeTypography,
        artSet: KeyArtSet? = nil
    ) {
        self.style = style
        self.metrics = metrics
        self.typography = typography
        self.artSet = artSet

        let radius = CGFloat(style.cornerRadiusOverride ?? Double(metrics.keyCornerRadius))
        switch style.resolvedCapShape {
        case .roundedRect:
            capLayer.cornerRadius = radius
            // `.continuous` is not cosmetic here. The system keyboard's caps are superellipses, and
            // a circular corner at the same radius reads visibly harder-edged next to them — this
            // is one of the details that separates a themed keyboard from a convincing one.
            capLayer.cornerCurve = .continuous
            capLayer.mask = nil
            glossLayer.cornerRadius = radius
            glossLayer.cornerCurve = .continuous
        case .hexagon:
            // The mask itself is sized in `layoutSubviews`, where `bounds` is actually known; this
            // only turns off the native rounding so it cannot fight the mask.
            capLayer.cornerRadius = 0
            capLayer.mask = capShapeMask
            glossLayer.cornerRadius = 0
        }
        capLayer.masksToBounds = true

        if let border = style.border {
            capLayer.borderWidth = CGFloat(border.width)
            capLayer.borderColor = border.color.cgColor
        } else {
            capLayer.borderWidth = 0
            capLayer.borderColor = nil
        }

        layer.shadowColor = style.shadow.color.cgColor
        layer.shadowOpacity = Float(style.shadow.opacity)
        layer.shadowRadius = CGFloat(style.shadow.radius)
        layer.shadowOffset = CGSize(width: 0, height: CGFloat(style.shadow.offsetY))

        if let highlight = style.topHighlight {
            glossLayer.isHidden = false
            glossLayer.colors = [highlight.cgColor, highlight.withAlpha(0).cgColor]
            glossLayer.startPoint = CGPoint(x: 0.5, y: 0)
            glossLayer.endPoint = CGPoint(x: 0.5, y: 1)
        } else {
            glossLayer.isHidden = true
        }

        switch style.resolvedCapShape {
        case .roundedRect:
            artClipView.layer.cornerRadius = radius
            artClipView.layer.cornerCurve = .continuous
            artClipView.layer.mask = nil
        case .hexagon:
            artClipView.layer.cornerRadius = 0
            artClipView.layer.mask = artShapeMask
        }
        // Resolved per key, not per set: a placement may pin this one illustration's opacity.
        if let artSet, let identity = definition.artIdentity {
            artClipView.alpha = CGFloat(artSet.resolvedOpacity(for: identity))
        } else {
            artClipView.alpha = 1
        }
        artClipView.isHidden = artSet == nil || definition.artIdentity == nil

        if let glass = style.glass {
            bevelLayer.isHidden = false
            innerShadowLayer.isHidden = false
            bevelLayer.colors = [glass.bevelColor.cgColor, glass.bevelColor.withAlpha(0).cgColor]
            bevelLayer.startPoint = CGPoint(x: 0.5, y: 0)
            bevelLayer.endPoint = CGPoint(x: 0.5, y: CGFloat(glass.bevelFalloff))
            bevelMask.lineWidth = CGFloat(glass.bevelWidth)
            innerShadowLayer.shadowColor = glass.innerShadowColor.cgColor
            innerShadowLayer.shadowOpacity = Float(glass.innerShadowOpacity)
            innerShadowLayer.shadowRadius = CGFloat(glass.innerShadowRadius)
            // Offset upward so the shadow falls from the *bottom* rim inward, which is where a
            // pane's thickness occludes light arriving from above.
            innerShadowLayer.shadowOffset = CGSize(width: 0, height: -CGFloat(glass.innerShadowRadius) * 0.6)
        } else {
            bevelLayer.isHidden = true
            innerShadowLayer.isHidden = true
        }

        let pointSize = definition.symbolName != nil || isWordLabel
            ? metrics.systemLabelPointSize
            : metrics.inputLabelPointSize * CGFloat(typography.sizeMultiplier)
        label.font = Self.font(for: typography, pointSize: pointSize)

        applyState(animated: false)
        setNeedsLayout()
    }

    /// Replaces the cap's text without rebuilding the view. Used for shift re-casing, which
    /// happens often enough that recreating thirty key views for it would be visible.
    func setLabelText(_ text: String) {
        guard definition.symbolName == nil else { return }
        label.text = text
        accessibilityLabel = definition.accessibilityLabel ?? text
    }

    /// `return` / `space` / `123` are set at the smaller system size even though `space` is not a
    /// `.system` role, because the distinction that matters typographically is word-versus-glyph,
    /// not which role the theme styles them under.
    private var isWordLabel: Bool {
        guard let text = definition.label else { return false }
        return text.count > 1
    }

    private static func font(for typography: ThemeTypography, pointSize: CGFloat) -> UIFont {
        let weight = UIFont.Weight(rawValue: CGFloat(typography.weightRawValue))
        guard let family = typography.fontFamily else {
            return .systemFont(ofSize: pointSize, weight: weight)
        }
        // A custom family must be registered in the *extension's* own `UIAppFonts` — the two
        // bundles do not share font registrations. Falling back rather than forcing means a
        // misconfigured theme looks plain instead of blank.
        guard let custom = UIFont(name: family, size: pointSize) else {
            return .systemFont(ofSize: pointSize, weight: weight)
        }
        return custom
    }

    // MARK: - State

    private func applyState(animated: Bool) {
        let showsPressed = isHighlighted || isHighlighted_shiftActive
        let fill = showsPressed ? style.resolvedPressedFill : style.fill
        let ink = showsPressed ? style.resolvedPressedLabelColor : style.labelColor

        // Press feedback must land on the same frame as the touch. `CATransaction` without actions
        // suppresses Core Animation's implicit 0.25s fade on `colors`, which would otherwise make
        // every keystroke feel soft.
        CATransaction.begin()
        CATransaction.setDisableActions(!animated)
        capLayer.colors = fill.stops.map(\.cgColor)
        applyGradientDirection(fill.angleDegrees)
        // A single-stop gradient needs its colour duplicated: CAGradientLayer draws nothing with
        // one entry, which would silently produce invisible keys for every solid-fill theme.
        if fill.stops.count == 1, let only = fill.stops.first {
            capLayer.colors = [only.cgColor, only.cgColor]
        }
        label.textColor = ink.uiColor
        iconView.tintColor = ink.uiColor
        CATransaction.commit()
    }

    private func applyGradientDirection(_ angleDegrees: Double) {
        let radians = angleDegrees * .pi / 180
        let dx = cos(radians) / 2
        let dy = sin(radians) / 2
        capLayer.startPoint = CGPoint(x: 0.5 - dx, y: 0.5 - dy)
        capLayer.endPoint = CGPoint(x: 0.5 + dx, y: 0.5 + dy)
    }

    override var isHighlighted: Bool {
        didSet { if oldValue != isHighlighted { applyState(animated: false) } }
    }

    // MARK: - Layout

    override func layoutSubviews() {
        super.layoutSubviews()
        capLayer.frame = bounds
        // The gloss occupies the top ~45% of the cap. Any taller and it stops reading as an edge
        // catching light and starts reading as a second gradient fighting the first.
        glossLayer.frame = CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height * 0.45)
        layoutArt()
        // Ink rides slightly above centre when a theme has artwork — enough to clear the busiest
        // part of the illustration, not so much that the letters look pinned to the top. An earlier
        // pass lifted them by a third of the art band and the whole keyboard read as top-heavy.
        let inkOffset = (artSet != nil && definition.artIdentity != nil)
            ? -bounds.height * CGFloat(artSet?.labelLiftFraction ?? 0)
            : 0
        label.frame = bounds.offsetBy(dx: 0, dy: inkOffset)
        iconView.frame = bounds.offsetBy(dx: 0, dy: inkOffset)

        let radius = capLayer.cornerRadius
        let outline = Self.outlinePath(for: style.resolvedCapShape, in: bounds, cornerRadius: radius)

        if style.resolvedCapShape == .hexagon {
            capShapeMask.frame = bounds
            capShapeMask.path = outline.cgPath
            artShapeMask.frame = bounds
            artShapeMask.path = outline.cgPath
        }

        layoutGlass(radius: radius, outline: outline)
        layoutSelectionRing(radius: radius)

        // An explicit shadow path avoids Core Animation deriving it from the layer's contents on
        // every frame — measurable on a 30-key grid, and free to provide since we know the shape.
        layer.shadowPath = outline.cgPath
    }

    /// The cap's own silhouette, in `bounds`-local coordinates. Every consumer that needs to know
    /// the cap's outline — the shadow, the glass bevel, the selection ring — asks this rather than
    /// re-deriving `roundedRect` vs. hexagon itself, so the two stay impossible to disagree.
    private static func outlinePath(for shape: KeyCapShape, in rect: CGRect, cornerRadius: CGFloat) -> UIBezierPath {
        switch shape {
        case .roundedRect:
            return UIBezierPath(roundedRect: rect, cornerRadius: cornerRadius)
        case .hexagon:
            return hexagonPath(in: rect)
        }
    }

    /// Flat top and bottom edges spanning the middle half of the width, points at mid-height —
    /// identical geometry to the Create screen's `HexagonShape` chip preview, so the shape a user
    /// picks there is the exact shape the real cap draws.
    private static func hexagonPath(in rect: CGRect) -> UIBezierPath {
        let w = rect.width
        let points = [
            CGPoint(x: rect.minX + w * 0.25, y: rect.minY),
            CGPoint(x: rect.minX + w * 0.75, y: rect.minY),
            CGPoint(x: rect.maxX, y: rect.midY),
            CGPoint(x: rect.minX + w * 0.75, y: rect.maxY),
            CGPoint(x: rect.minX + w * 0.25, y: rect.maxY),
            CGPoint(x: rect.minX, y: rect.midY)
        ]
        let path = UIBezierPath()
        path.move(to: points[0])
        for point in points.dropFirst() { path.addLine(to: point) }
        path.close()
        return path
    }

    // MARK: - Selection ring (DEBUG tooling)

    private func updateSelectionRing() {
        guard isArtSelected else {
            selectionLayer?.removeFromSuperlayer()
            selectionLayer = nil
            return
        }
        guard selectionLayer == nil else { return }
        let ring = CAShapeLayer()
        ring.fillColor = UIColor.clear.cgColor
        // A dashed cyan ring rather than a tint or a glow: it has to be unmistakable against a cap
        // whose whole point is that it is nearly the colour of the sky behind it, and it must not
        // change any pixel of the thing being judged. A fill would alter the art's apparent opacity,
        // which is one of the values the lab exists to set.
        ring.strokeColor = UIColor.systemCyan.cgColor
        ring.lineWidth = 2
        ring.lineDashPattern = [4, 3]
        layer.addSublayer(ring)
        selectionLayer = ring
        setNeedsLayout()
    }

    private func layoutSelectionRing(radius: CGFloat) {
        guard let selectionLayer else { return }
        selectionLayer.frame = bounds
        switch style.resolvedCapShape {
        case .roundedRect:
            selectionLayer.path = UIBezierPath(
                roundedRect: bounds.insetBy(dx: 1, dy: 1),
                cornerRadius: max(0, radius - 1)
            ).cgPath
        case .hexagon:
            selectionLayer.path = Self.hexagonPath(in: bounds.insetBy(dx: 1, dy: 1)).cgPath
        }
    }

    private func layoutGlass(radius: CGFloat, outline: UIBezierPath) {
        guard let glass = style.glass, bounds.width > 1 else { return }
        let inset = CGFloat(glass.bevelWidth) / 2
        let insetOutline = Self.outlinePath(
            for: style.resolvedCapShape,
            in: bounds.insetBy(dx: inset, dy: inset),
            cornerRadius: max(0, radius - inset)
        )

        bevelLayer.frame = bounds
        bevelMask.frame = bounds
        bevelMask.path = insetOutline.cgPath

        // Even-odd: the filled region is the ring *outside* the cap, which the mask then hides,
        // leaving only the shadow it casts inward. This is the standard way to get an inner shadow
        // out of Core Animation, which has no such property. The outer padding only has to clear
        // the cap on every side by more than the shadow's own radius, so a shape-independent
        // constant works as well as one derived from a corner radius that a hexagon doesn't have.
        innerShadowLayer.frame = bounds
        let padding = max(radius * 3, CGFloat(glass.innerShadowRadius) * 4, 24)
        let outer = UIBezierPath(rect: bounds.insetBy(dx: -padding, dy: -padding))
        outer.append(outline.reversing())
        innerShadowLayer.path = outer.cgPath

        let clip = CAShapeLayer()
        clip.path = outline.cgPath
        innerShadowLayer.mask = clip
    }

    private func layoutArt() {
        guard let artSet, let identity = definition.artIdentity, bounds.width > 1 else {
            artView.image = nil
            artBrightnessOverlay.isHidden = true
            return
        }
        artClipView.frame = bounds

        let scale = traitCollection.displayScale > 0 ? traitCollection.displayScale : UIScreen.main.scale
        let fills = artSet.fillKeys.contains(identity)

        // The band the illustration occupies. Anchored near the cap's bottom edge — reading as part
        // of the cap rather than a sticker floating mid-face — but lifted clear of it by
        // `bottomInsetFraction` so a tall motif doesn't crowd the very bottom rim. Inset 0 keeps the
        // old flush behaviour; every batch-2 theme now carries a small positive inset.
        let base: CGRect = fills
            ? bounds
            : CGRect(
                x: 0,
                y: bounds.height * (1 - CGFloat(artSet.heightFraction) - CGFloat(artSet.bottomInsetFraction)),
                width: bounds.width,
                height: bounds.height * CGFloat(artSet.heightFraction)
              )

        // Per-key nudge. Applied to the *frame*, inside a clip view that is still exactly the cap,
        // so scaling past 1 pushes the illustration under the rounded corners rather than out over
        // them — art keeps bleeding from the cap's edges the way it is meant to.
        let placement = artSet.placement(for: identity)
        let band = Self.place(base, in: bounds, with: placement)

        let image = KeyArtStore.shared.image(
            identity: identity,
            artSet: artSet,
            targetSize: band.size,
            scale: scale
        )
        artView.image = image
        artView.frame = band

        let brightness = artSet.resolvedBrightness(for: identity)
        if brightness == 0 {
            artBrightnessOverlay.isHidden = true
        } else {
            artBrightnessOverlay.isHidden = false
            artBrightnessOverlay.frame = band
            artBrightnessOverlay.backgroundColor = brightness > 0 ? .white : .black
            artBrightnessOverlay.alpha = CGFloat(min(1, abs(brightness)))
            // Mirror artView's own image/gravity into the mask so the wash only lands on the
            // illustration's actual pixels, not the transparent rest of its band.
            artBrightnessMask.frame = artBrightnessOverlay.bounds
            artBrightnessMask.contents = image?.cgImage
        }
    }

    /// Scales `base` about its own centre, then offsets by a fraction of the **cap's** size.
    ///
    /// Offsets are relative to the cap rather than to the band so that a nudge means the same thing
    /// on a letter key and on the space bar, whose bands differ by a factor of four.
    private static func place(_ base: CGRect, in capBounds: CGRect, with placement: KeyArtPlacement) -> CGRect {
        let scaled = CGSize(
            width: base.width * CGFloat(placement.scale),
            height: base.height * CGFloat(placement.scale)
        )
        return CGRect(
            x: base.midX - scaled.width / 2 + capBounds.width * CGFloat(placement.offsetX),
            y: base.midY - scaled.height / 2 + capBounds.height * CGFloat(placement.offsetY),
            width: scaled.width,
            height: scaled.height
        )
    }

    // MARK: - Touch target

    /// Expands the tappable area into the gaps between caps.
    ///
    /// The system keyboard does this and it is a large part of why it feels accurate: the visible
    /// cap is smaller than the region that accepts the touch, so a thumb landing in the gutter
    /// still hits the intended key rather than nothing. Half the column gap on each side tiles the
    /// row with no overlap and no dead zones.
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let slop = metrics.columnGap / 2
        return bounds.insetBy(dx: -slop, dy: -metrics.rowGap / 2).contains(point)
    }
}
