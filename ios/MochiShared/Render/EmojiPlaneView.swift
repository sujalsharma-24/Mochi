import UIKit

/// The emoji panel: a category strip, a scrolling grid, and a bottom row to get back to letters.
///
/// A `UICollectionView` rather than a grid of buttons, and that choice is about memory rather than
/// convenience. Cell reuse means only the ~40 emoji actually on screen exist as views at any
/// moment; a button per emoji would instantiate several hundred views and their attributed
/// strings up front, inside a process with roughly 30–48 MB to spend before the system kills it
/// without a crash log.
final class EmojiPlaneView: UIView {
    var onInsert: ((String) -> Void)?
    var onBackspace: (() -> Void)?
    var onReturnToLetters: (() -> Void)?
    var onNextKeyboard: (() -> Void)?

    private var theme: MochiKeyboardTheme
    private var metrics: KeyboardMetrics
    private let showsNextKeyboardKey: Bool

    private let categoryStrip = UIScrollView()
    private var categoryButtons: [UIButton] = []
    private var collectionView: UICollectionView!
    private let bottomBar = UIView()
    private var bottomKeys: [KeyView] = []

    private var selectedCategory = 0

    private static let cellIdentifier = "emoji"

    init(theme: MochiKeyboardTheme, metrics: KeyboardMetrics, showsNextKeyboardKey: Bool) {
        self.theme = theme
        self.metrics = metrics
        self.showsNextKeyboardKey = showsNextKeyboardKey
        super.init(frame: .zero)

        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(EmojiCell.self, forCellWithReuseIdentifier: Self.cellIdentifier)
        collectionView.showsVerticalScrollIndicator = false
        // The keyboard sits at the bottom of the screen where the home indicator lives; the
        // default content inset would push the last row of emoji under it.
        collectionView.contentInsetAdjustmentBehavior = .never
        addSubview(collectionView)

        categoryStrip.showsHorizontalScrollIndicator = false
        addSubview(categoryStrip)
        buildCategoryButtons()

        addSubview(bottomBar)
        buildBottomKeys()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // MARK: - Theme

    func applyTheme(_ newTheme: MochiKeyboardTheme, metrics newMetrics: KeyboardMetrics) {
        theme = newTheme
        metrics = newMetrics
        updateCategoryButtonColors()
        for keyView in bottomKeys {
            keyView.apply(
                style: theme.style(for: keyView.definition.role),
                metrics: metrics,
                typography: theme.typography,
                artSet: theme.keyArt
            )
        }
        collectionView.reloadData()
    }

    // MARK: - Category strip

    private func buildCategoryButtons() {
        for (index, category) in EmojiCatalog.categories.enumerated() {
            let button = UIButton(type: .system)
            button.setImage(
                UIImage(systemName: category.symbolName, withConfiguration: UIImage.SymbolConfiguration(
                    pointSize: 15,
                    weight: .medium
                )),
                for: .normal
            )
            button.tag = index
            button.accessibilityLabel = category.name
            button.addTarget(self, action: #selector(categoryTapped(_:)), for: .touchUpInside)
            categoryStrip.addSubview(button)
            categoryButtons.append(button)
        }
        updateCategoryButtonColors()
    }

    private func updateCategoryButtonColors() {
        for (index, button) in categoryButtons.enumerated() {
            button.tintColor = (index == selectedCategory ? theme.chrome.inkColor : theme.chrome.mutedInkColor).uiColor
        }
    }

    @objc private func categoryTapped(_ sender: UIButton) {
        selectedCategory = sender.tag
        updateCategoryButtonColors()
        collectionView.reloadData()
        collectionView.setContentOffset(.zero, animated: false)
    }

    // MARK: - Bottom bar

    private func buildBottomKeys() {
        var definitions: [KeyDefinition] = [
            KeyDefinition(
                action: .switchPlane(.letters),
                role: .system,
                width: .ratio(1.33),
                label: "ABC",
                accessibilityLabel: "Letters"
            )
        ]
        if showsNextKeyboardKey {
            definitions.append(KeyDefinition(
                action: .nextKeyboard,
                role: .system,
                width: .ratio(1.33),
                symbolName: "globe",
                accessibilityLabel: "Next keyboard"
            ))
        }
        definitions.append(KeyDefinition(
            action: .backspace,
            role: .system,
            width: .ratio(1.33),
            symbolName: "delete.left",
            accessibilityLabel: "Delete",
            repeatsWhenHeld: true
        ))

        for definition in definitions {
            let keyView = KeyView(
                definition: definition,
                style: theme.style(for: definition.role),
                metrics: metrics,
                typography: theme.typography,
                artSet: theme.keyArt
            )
            keyView.addTarget(self, action: #selector(bottomKeyTapped(_:)), for: .touchUpInside)
            bottomBar.addSubview(keyView)
            bottomKeys.append(keyView)
        }
    }

    @objc private func bottomKeyTapped(_ sender: KeyView) {
        switch sender.definition.action {
        case .switchPlane: onReturnToLetters?()
        case .backspace: onBackspace?()
        case .nextKeyboard: onNextKeyboard?()
        default: break
        }
    }

    // MARK: - Layout

    override func layoutSubviews() {
        super.layoutSubviews()
        let stripHeight: CGFloat = 34
        let bottomHeight = metrics.keyHeight + metrics.bottomInset

        categoryStrip.frame = CGRect(x: 0, y: 0, width: bounds.width, height: stripHeight)
        let buttonWidth: CGFloat = 40
        for (index, button) in categoryButtons.enumerated() {
            button.frame = CGRect(
                x: CGFloat(index) * buttonWidth,
                y: 0,
                width: buttonWidth,
                height: stripHeight
            )
        }
        categoryStrip.contentSize = CGSize(
            width: CGFloat(categoryButtons.count) * buttonWidth,
            height: stripHeight
        )

        collectionView.frame = CGRect(
            x: 0,
            y: stripHeight,
            width: bounds.width,
            height: max(0, bounds.height - stripHeight - bottomHeight)
        )

        bottomBar.frame = CGRect(
            x: 0,
            y: bounds.height - bottomHeight,
            width: bounds.width,
            height: bottomHeight
        )

        // The bottom row reuses the key grid's own metrics so its buttons line up with the letter
        // keyboard's bottom row — switching planes should not visibly move the ABC key.
        var x = metrics.sideInset
        for keyView in bottomKeys {
            let width: CGFloat
            if case .ratio(let multiple) = keyView.definition.width {
                width = metrics.standardKeyWidth * multiple
            } else {
                width = metrics.standardKeyWidth
            }
            keyView.frame = CGRect(x: x, y: 0, width: width, height: metrics.keyHeight)
            x += width + metrics.columnGap
        }

        if let flow = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            let columns = max(6, floor(bounds.width / 44))
            let side = floor(bounds.width / columns)
            flow.itemSize = CGSize(width: side, height: side)
        }
    }
}

// MARK: - Collection view

extension EmojiPlaneView: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        EmojiCatalog.categories[selectedCategory].emoji.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: EmojiPlaneView.cellIdentifier,
            for: indexPath
        ) as! EmojiCell
        cell.configure(
            emoji: EmojiCatalog.categories[selectedCategory].emoji[indexPath.item],
            highlightColor: theme.chrome.highlightFill.stops.first?.uiColor ?? .clear
        )
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        onInsert?(EmojiCatalog.categories[selectedCategory].emoji[indexPath.item])
    }
}

private final class EmojiCell: UICollectionViewCell {
    private let label = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        label.textAlignment = .center
        // 30pt is what the system emoji keyboard renders at. Larger looks toy-like at this grid
        // density; smaller and the more detailed emoji stop being distinguishable at a glance.
        label.font = .systemFont(ofSize: 30)
        contentView.addSubview(label)
        contentView.layer.cornerRadius = 6
        contentView.layer.cornerCurve = .continuous
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func configure(emoji: String, highlightColor: UIColor) {
        label.text = emoji
        contentView.backgroundColor = isHighlighted ? highlightColor : .clear
    }

    override var isHighlighted: Bool {
        didSet { contentView.backgroundColor = isHighlighted ? UIColor.white.withAlphaComponent(0.18) : .clear }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        label.frame = contentView.bounds
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        // Clearing on reuse keeps a recycled cell from briefly showing the previous emoji while
        // scrolling fast, which reads as flicker.
        label.text = nil
        contentView.backgroundColor = .clear
    }
}
