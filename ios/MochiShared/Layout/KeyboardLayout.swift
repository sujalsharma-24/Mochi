import CoreGraphics
import Foundation

/// What a key does when tapped. Kept separate from how it looks so that the theme system and the
/// input system can evolve independently — a new theme must never require a layout change, and a
/// new layout must never require every theme to be re-authored.
enum KeyAction: Equatable {
    case insert(String)
    case backspace
    case shift
    case switchPlane(KeyboardPlane)
    /// Advance to the next system keyboard. Required by App Review guideline 4.4.1; the layout
    /// only includes it when `UIInputViewController.needsInputModeSwitchKey` is true, which is how
    /// the system tells us whether the user has other keyboards installed.
    case nextKeyboard
    case newLine
    case space
    /// Occupies grid space without drawing or accepting touches. Used to reproduce the wider gaps
    /// the system keyboard leaves either side of shift and backspace.
    case spacer
}

enum KeyboardPlane: String, Equatable {
    case letters
    case numbers
    case symbols
    /// Not a key grid. The emoji plane is a scrolling collection with its own chrome, so
    /// `KeyboardSurfaceView` swaps in a different view rather than solving a layout for it.
    case emoji
}

/// How wide a key is, relative to the row it lives in.
enum KeyWidth: Equatable {
    /// One letter-key width, exactly as the top row's ten columns define it.
    case standard
    /// A multiple of `standard`.
    case ratio(CGFloat)
    /// Splits whatever width the fixed keys in the row leave over. Space bars and the gaps beside
    /// shift are expressed this way.
    case fill
}

struct KeyDefinition: Equatable {
    var action: KeyAction
    var role: KeyRole
    var width: KeyWidth
    /// Text drawn on the cap. `nil` for symbol keys and spacers.
    var label: String?
    /// SF Symbol name, used when `label` is nil.
    var symbolName: String?
    /// Read aloud by VoiceOver. Falls back to `label`, but symbol keys have no label and would
    /// otherwise be announced as nothing at all.
    var accessibilityLabel: String?
    /// Fires repeatedly while held. Only backspace does this — a repeating letter key is a bug,
    /// not a feature, on a touch keyboard where fingers rest.
    var repeatsWhenHeld: Bool

    init(
        action: KeyAction,
        role: KeyRole,
        width: KeyWidth = .standard,
        label: String? = nil,
        symbolName: String? = nil,
        accessibilityLabel: String? = nil,
        repeatsWhenHeld: Bool = false
    ) {
        self.action = action
        self.role = role
        self.width = width
        self.label = label
        self.symbolName = symbolName
        self.accessibilityLabel = accessibilityLabel
        self.repeatsWhenHeld = repeatsWhenHeld
    }

    /// Stable identity used to look up this key's illustration, or `nil` for keys that never carry
    /// one.
    ///
    /// Deliberately not derived from the label: the label changes with shift and with the active
    /// plane, and an asset name that changes when the user presses shift would flicker the artwork
    /// on every capital letter. Derived from the *action* instead, which is stable.
    var artIdentity: String? {
        switch action {
        case .insert(let character):
            let lowered = character.lowercased()
            // Only single Latin letters have illustrations; digits and punctuation share the cap
            // style but not the art set.
            return lowered.count == 1 && lowered.rangeOfCharacter(from: .letters) != nil ? lowered : nil
        case .shift: return "shift"
        case .backspace: return "backspace"
        case .space: return "space"
        case .newLine: return "return"
        case .nextKeyboard: return "globe"
        case .switchPlane(let plane):
            // Both `123` and `ABC` are the same physical key in the same position, so they share
            // one illustration rather than popping to a different picture on every plane switch.
            return plane == .emoji ? "emoji" : "123"
        case .spacer: return nil
        }
    }

    /// The characters a long press offers, if any. Drives the accent callout.
    var alternates: [String] {
        guard case .insert(let character) = action else { return [] }
        return AccentMap.alternates(for: character)
    }

    static func letter(_ character: String) -> KeyDefinition {
        KeyDefinition(action: .insert(character), role: .input, label: character)
    }

    static let spacer = KeyDefinition(action: .spacer, role: .input, width: .fill)
}

struct KeyRow: Equatable {
    var keys: [KeyDefinition]
    /// Extra inset applied to both ends of this row. The home row (`ASDFGHJKL`) is indented by
    /// half a key plus half a gap on the system keyboard, which is what centres its nine keys
    /// against the top row's ten.
    var additionalSideInset: CGFloat

    init(_ keys: [KeyDefinition], additionalSideInset: CGFloat = 0) {
        self.keys = keys
        self.additionalSideInset = additionalSideInset
    }
}

/// The key grid for one plane, before any theming is applied.
struct KeyboardLayout: Equatable {
    var rows: [KeyRow]

    /// - Parameter includesNextKeyboardKey: pass `UIInputViewController.needsInputModeSwitchKey`.
    ///   When false the globe key is omitted and the bottom row's remaining keys take the space,
    ///   matching what the system keyboard does for a user with a single keyboard installed.
    static func letters(includesNextKeyboardKey: Bool, metrics: KeyboardMetrics) -> KeyboardLayout {
        let homeRowInset = (metrics.standardKeyWidth + metrics.columnGap) / 2
        return KeyboardLayout(rows: [
            KeyRow("QWERTYUIOP".map { KeyDefinition.letter(String($0)) }),
            KeyRow("ASDFGHJKL".map { KeyDefinition.letter(String($0)) },
                   additionalSideInset: homeRowInset),
            KeyRow(bottomLetterRow()),
            KeyRow(functionRow(includesNextKeyboardKey: includesNextKeyboardKey, returnLabel: "return"))
        ])
    }

    static func numbers(includesNextKeyboardKey: Bool) -> KeyboardLayout {
        KeyboardLayout(rows: [
            KeyRow("1234567890".map { KeyDefinition.letter(String($0)) }),
            KeyRow("-/:;()$&@\"".map { KeyDefinition.letter(String($0)) }),
            KeyRow([
                KeyDefinition(
                    action: .switchPlane(.symbols),
                    role: .system,
                    width: .ratio(1.33),
                    label: "#+=",
                    accessibilityLabel: "More symbols"
                ),
                .spacer
            ]
            + ".,?!'".map { KeyDefinition.letter(String($0)) }
            + [
                .spacer,
                KeyDefinition(
                    action: .backspace,
                    role: .system,
                    width: .ratio(1.33),
                    symbolName: "delete.left",
                    accessibilityLabel: "Delete",
                    repeatsWhenHeld: true
                )
            ]),
            KeyRow(functionRow(
                includesNextKeyboardKey: includesNextKeyboardKey,
                returnLabel: "return",
                planeSwitchLabel: "ABC",
                planeSwitchTarget: .letters
            ))
        ])
    }

    static func symbols(includesNextKeyboardKey: Bool) -> KeyboardLayout {
        KeyboardLayout(rows: [
            KeyRow("[]{}#%^*+=".map { KeyDefinition.letter(String($0)) }),
            KeyRow("_\\|~<>€£¥•".map { KeyDefinition.letter(String($0)) }),
            KeyRow([
                KeyDefinition(
                    action: .switchPlane(.numbers),
                    role: .system,
                    width: .ratio(1.33),
                    label: "123",
                    accessibilityLabel: "Numbers"
                ),
                .spacer
            ]
            + ".,?!'".map { KeyDefinition.letter(String($0)) }
            + [
                .spacer,
                KeyDefinition(
                    action: .backspace,
                    role: .system,
                    width: .ratio(1.33),
                    symbolName: "delete.left",
                    accessibilityLabel: "Delete",
                    repeatsWhenHeld: true
                )
            ]),
            KeyRow(functionRow(
                includesNextKeyboardKey: includesNextKeyboardKey,
                returnLabel: "return",
                planeSwitchLabel: "ABC",
                planeSwitchTarget: .letters
            ))
        ])
    }

    private static func bottomLetterRow() -> [KeyDefinition] {
        [
            KeyDefinition(
                action: .shift,
                role: .system,
                width: .ratio(1.33),
                symbolName: "shift",
                accessibilityLabel: "Shift"
            ),
            .spacer
        ]
        + "ZXCVBNM".map { KeyDefinition.letter(String($0)) }
        + [
            .spacer,
            KeyDefinition(
                action: .backspace,
                role: .system,
                width: .ratio(1.33),
                symbolName: "delete.left",
                accessibilityLabel: "Delete",
                repeatsWhenHeld: true
            )
        ]
    }

    private static func functionRow(
        includesNextKeyboardKey: Bool,
        returnLabel: String,
        planeSwitchLabel: String = "123",
        planeSwitchTarget: KeyboardPlane = .numbers
    ) -> [KeyDefinition] {
        var keys: [KeyDefinition] = [
            KeyDefinition(
                action: .switchPlane(planeSwitchTarget),
                role: .system,
                width: .ratio(1.33),
                label: planeSwitchLabel,
                accessibilityLabel: planeSwitchLabel == "ABC" ? "Letters" : "Numbers"
            )
        ]
        if includesNextKeyboardKey {
            keys.append(KeyDefinition(
                action: .nextKeyboard,
                role: .system,
                width: .ratio(1.33),
                symbolName: "globe",
                accessibilityLabel: "Next keyboard"
            ))
        }
        // Narrower than the other function keys (1.1 against 1.33). The bottom row has to fit up to
        // five keys on a 402pt-wide phone, and the space bar is the one that must not be squeezed —
        // it is the most-hit target on the keyboard and the one people aim at least precisely.
        keys.append(KeyDefinition(
            action: .switchPlane(.emoji),
            role: .system,
            width: .ratio(1.1),
            symbolName: "face.smiling",
            accessibilityLabel: "Emoji"
        ))
        keys.append(KeyDefinition(action: .space, role: .space, width: .fill, label: "space"))
        keys.append(KeyDefinition(
            action: .newLine,
            role: .action,
            width: .ratio(2.6),
            label: returnLabel,
            accessibilityLabel: "Return"
        ))
        return keys
    }

    static func layout(for plane: KeyboardPlane, includesNextKeyboardKey: Bool, metrics: KeyboardMetrics) -> KeyboardLayout {
        switch plane {
        case .letters: return .letters(includesNextKeyboardKey: includesNextKeyboardKey, metrics: metrics)
        case .numbers: return .numbers(includesNextKeyboardKey: includesNextKeyboardKey)
        case .symbols: return .symbols(includesNextKeyboardKey: includesNextKeyboardKey)
        // The emoji plane has no key grid. It still reports the letters layout so that height
        // calculations stay stable across the switch — the keyboard must not change size when the
        // user opens emoji, or the host app's content jumps underneath them.
        case .emoji: return .letters(includesNextKeyboardKey: includesNextKeyboardKey, metrics: metrics)
        }
    }
}

// MARK: - Frame solving

/// A key with its resolved frame. The solver is a pure function of layout + metrics, with no view
/// objects involved, which is what lets the in-app preview and the extension produce identical
/// geometry and lets the whole thing be unit-tested without a keyboard running.
struct SolvedKey: Equatable {
    var definition: KeyDefinition
    var frame: CGRect
}

enum KeyboardLayoutSolver {
    static func solve(layout: KeyboardLayout, metrics: KeyboardMetrics, in size: CGSize) -> [SolvedKey] {
        var solved: [SolvedKey] = []
        var y = metrics.topInset

        for row in layout.rows {
            let rowInset = metrics.sideInset + row.additionalSideInset
            let available = size.width - rowInset * 2
            let gapTotal = metrics.columnGap * CGFloat(max(0, row.keys.count - 1))

            // Fixed-width keys are measured first; whatever is left is divided between the
            // `.fill` keys. A row with no fill keys simply leaves the remainder unused rather
            // than stretching, which keeps a malformed layout from silently distorting the grid.
            var fixedWidth: CGFloat = 0
            var fillCount = 0
            for key in row.keys {
                switch key.width {
                case .standard: fixedWidth += metrics.standardKeyWidth
                case .ratio(let multiple): fixedWidth += metrics.standardKeyWidth * multiple
                case .fill: fillCount += 1
                }
            }
            let fillWidth = fillCount > 0
                ? max(0, (available - gapTotal - fixedWidth) / CGFloat(fillCount))
                : 0

            var x = rowInset
            for key in row.keys {
                let width: CGFloat
                switch key.width {
                case .standard: width = metrics.standardKeyWidth
                case .ratio(let multiple): width = metrics.standardKeyWidth * multiple
                case .fill: width = fillWidth
                }
                if key.action != .spacer {
                    solved.append(SolvedKey(
                        definition: key,
                        frame: CGRect(x: x, y: y, width: width, height: metrics.keyHeight)
                    ))
                }
                x += width + metrics.columnGap
            }
            y += metrics.keyHeight + metrics.rowGap
        }
        return solved
    }
}
