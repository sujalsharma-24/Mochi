import UIKit

/// The strip above the keys offering word completions.
///
/// Three slots, fixed. A variable number of suggestions makes the bar's separators jump around
/// between keystrokes, which is visually noisy at exactly the moment the user is reading it.
/// Empty slots simply render nothing.
final class SuggestionBarView: UIView {
    var onSelect: ((String) -> Void)?

    private var chrome: ThemeChrome
    private var suggestions: [SuggestionEngine.Suggestion] = []
    private var buttons: [UIButton] = []
    private var separators: [CALayer] = []
    private let slotCount = 3

    init(chrome: ThemeChrome) {
        self.chrome = chrome
        super.init(frame: .zero)

        for index in 0..<slotCount {
            let button = UIButton(type: .system)
            button.titleLabel?.font = .systemFont(ofSize: 17, weight: .regular)
            button.titleLabel?.adjustsFontSizeToFitWidth = true
            button.titleLabel?.minimumScaleFactor = 0.75
            button.tag = index
            button.addTarget(self, action: #selector(tapped(_:)), for: .touchUpInside)
            addSubview(button)
            buttons.append(button)

            if index < slotCount - 1 {
                let separator = CALayer()
                layer.addSublayer(separator)
                separators.append(separator)
            }
        }
        applyChrome(chrome)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func applyChrome(_ newChrome: ThemeChrome) {
        chrome = newChrome
        for (index, button) in buttons.enumerated() {
            // The verbatim suggestion is set in the full-strength ink and the dictionary
            // candidates in the muted one. That is the only affordance telling the user which of
            // the three is literally what they typed, and it matters most for names and slang the
            // dictionary would otherwise appear to be "correcting".
            let isVerbatim = suggestions.indices.contains(index) && suggestions[index].isVerbatim
            button.setTitleColor((isVerbatim ? chrome.inkColor : chrome.mutedInkColor).uiColor, for: .normal)
        }
        for separator in separators {
            separator.backgroundColor = chrome.mutedInkColor.withAlpha(0.28).cgColor
        }
    }

    func update(with newSuggestions: [SuggestionEngine.Suggestion]) {
        guard newSuggestions != suggestions else { return }
        suggestions = newSuggestions
        for (index, button) in buttons.enumerated() {
            let suggestion = newSuggestions.indices.contains(index) ? newSuggestions[index] : nil
            button.setTitle(suggestion?.text, for: .normal)
            button.isEnabled = suggestion != nil
        }
        applyChrome(chrome)
        setNeedsLayout()
    }

    @objc private func tapped(_ sender: UIButton) {
        guard suggestions.indices.contains(sender.tag) else { return }
        onSelect?(suggestions[sender.tag].text)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let slotWidth = bounds.width / CGFloat(slotCount)
        // Occupied slots are centred as a group rather than packed to the left. With a single
        // candidate — which is what an unrecognised word produces, and therefore what a user sees
        // while typing a name — left-packing leaves it stranded in the corner with two thirds of
        // the bar empty. The system keyboard centres the lone candidate for the same reason.
        let occupied = max(1, suggestions.count)
        let leadingOffset = (CGFloat(slotCount - occupied) / 2) * slotWidth
        for (index, button) in buttons.enumerated() {
            button.frame = CGRect(
                x: leadingOffset + CGFloat(index) * slotWidth,
                y: 0,
                width: slotWidth,
                height: bounds.height
            )
        }
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        for (index, separator) in separators.enumerated() {
            // Separators are inset vertically so they read as dividers rather than as a grid.
            // They are also only drawn between *occupied* slots — a divider next to nothing looks
            // like a missing suggestion rather than a deliberate blank.
            let hasNeighbours = suggestions.count > index + 1
            separator.isHidden = !hasNeighbours
            separator.frame = CGRect(
                x: leadingOffset + CGFloat(index + 1) * slotWidth - 0.5,
                y: bounds.height * 0.22,
                width: 1,
                height: bounds.height * 0.56
            )
        }
        CATransaction.commit()
    }
}
