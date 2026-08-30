import UIKit

/// The accent picker shown when a letter key is held.
///
/// **Why it opens downward on the top row.** Apple's documentation is explicit that a custom
/// keyboard cannot draw above the top edge of its primary view — the system keyboard's own key
/// callouts are drawn by the system, in space we do not have. A callout anchored above a `Q` would
/// simply be clipped away. So this positions itself above the key when there is room and below it
/// when there is not, and clamps horizontally to stay inside the keyboard. That is a real
/// behavioural difference from the system keyboard, and it is the honest one: the alternative is a
/// picker that silently does nothing on the row people use most.
final class KeyCalloutView: UIView {
    /// Index of the option currently under the user's finger.
    private(set) var selectedIndex: Int = 0

    private let options: [String]
    private let chrome: ThemeChrome
    private let metrics: KeyboardMetrics

    private let backgroundLayer = CAGradientLayer()
    private let highlightLayer = CALayer()
    private var optionLabels: [UILabel] = []

    private let optionWidth: CGFloat
    private let optionHeight: CGFloat
    private static let padding: CGFloat = 6

    init(options: [String], chrome: ThemeChrome, metrics: KeyboardMetrics, typography: ThemeTypography) {
        self.options = options
        self.chrome = chrome
        self.metrics = metrics
        // Sized off the key grid rather than off the text, so the callout reads as part of the
        // same keyboard instead of a floating tooltip.
        self.optionWidth = max(34, metrics.standardKeyWidth * 0.94)
        self.optionHeight = metrics.keyHeight * 0.86
        super.init(frame: .zero)

        backgroundLayer.colors = chrome.panelFill.stops.count == 1
            ? [chrome.panelFill.stops[0].cgColor, chrome.panelFill.stops[0].cgColor]
            : chrome.panelFill.stops.map(\.cgColor)
        backgroundLayer.cornerRadius = metrics.keyCornerRadius + 2
        backgroundLayer.cornerCurve = .continuous
        layer.addSublayer(backgroundLayer)

        highlightLayer.backgroundColor = chrome.highlightFill.stops.first?.cgColor
        highlightLayer.cornerRadius = metrics.keyCornerRadius - 1
        highlightLayer.cornerCurve = .continuous
        layer.addSublayer(highlightLayer)

        for option in options {
            let label = UILabel()
            label.text = option
            label.textAlignment = .center
            label.textColor = chrome.inkColor.uiColor
            label.font = .systemFont(
                ofSize: metrics.inputLabelPointSize * CGFloat(typography.sizeMultiplier),
                weight: UIFont.Weight(rawValue: CGFloat(typography.weightRawValue))
            )
            addSubview(label)
            optionLabels.append(label)
        }

        // A shadow separates the callout from whatever art is behind it. Without it, a translucent
        // panel over a busy background reads as a rendering glitch rather than a layer.
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.35
        layer.shadowRadius = 8
        layer.shadowOffset = CGSize(width: 0, height: 3)
        isUserInteractionEnabled = false
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    var intrinsicSize: CGSize {
        CGSize(
            width: CGFloat(options.count) * optionWidth + Self.padding * 2,
            height: optionHeight + Self.padding * 2
        )
    }

    /// Positions the callout relative to the key it belongs to, inside `container`.
    ///
    /// - Returns: `true` when the callout ended up above the key, `false` when it had to flip below.
    @discardableResult
    func position(over keyFrame: CGRect, in container: CGRect) -> Bool {
        let size = intrinsicSize
        let gap: CGFloat = 4

        var originY = keyFrame.minY - size.height - gap
        var placedAbove = true
        if originY < 0 {
            originY = keyFrame.maxY + gap
            placedAbove = false
        }
        // If it fits in neither direction the key row is taller than the keyboard, which cannot
        // happen with real metrics — but clamping rather than trusting that keeps a bad theme from
        // pushing the picker off screen entirely.
        originY = min(max(0, originY), max(0, container.height - size.height))

        var originX = keyFrame.midX - size.width / 2
        originX = min(max(0, originX), max(0, container.width - size.width))

        frame = CGRect(x: originX, y: originY, width: size.width, height: size.height)
        return placedAbove
    }

    /// Updates the highlighted option from a touch location in the callout's own coordinate space.
    func updateSelection(forTouchAt point: CGPoint) {
        guard !options.isEmpty else { return }
        let relativeX = point.x - Self.padding
        let index = Int(floor(relativeX / optionWidth))
        let clamped = min(max(0, index), options.count - 1)
        guard clamped != selectedIndex else { return }
        selectedIndex = clamped
        setNeedsLayout()
    }

    var selectedOption: String? {
        options.indices.contains(selectedIndex) ? options[selectedIndex] : nil
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        backgroundLayer.frame = bounds
        for (index, label) in optionLabels.enumerated() {
            label.frame = CGRect(
                x: Self.padding + CGFloat(index) * optionWidth,
                y: Self.padding,
                width: optionWidth,
                height: optionHeight
            )
        }
        if optionLabels.indices.contains(selectedIndex) {
            highlightLayer.frame = optionLabels[selectedIndex].frame.insetBy(dx: 1, dy: 0)
        }
        layer.shadowPath = UIBezierPath(
            roundedRect: bounds,
            cornerRadius: backgroundLayer.cornerRadius
        ).cgPath
        CATransaction.commit()
    }
}
