import UIKit

/// The document the keyboard is typing into.
///
/// An abstraction over `UITextDocumentProxy` so the input logic can run somewhere other than a
/// live keyboard extension. That is not a testability nicety — enabling a keyboard extension means
/// installing it, walking through Settings, and finding a text field in another app, which is slow
/// enough that behaviour stops getting checked. With this, the same logic runs against a plain
/// string in the in-app test bench.
protocol TextDocumentAdapter: AnyObject {
    var contextBeforeInput: String? { get }
    var autocapitalization: UITextAutocapitalizationType { get }
    func insertText(_ text: String)
    func deleteBackward()
}

/// All the typing behaviour: shift, caps lock, auto-capitalisation, the double-space period, and
/// suggestion acceptance.
///
/// Deliberately holds no views. `KeyboardViewController` and the test bench both drive it and
/// render its output, which is what keeps the two from disagreeing about what shift does.
final class KeyboardInputEngine {
    weak var document: TextDocumentAdapter?

    /// Fired when the renderer needs to update — shift glyph, letter case, suggestion bar.
    var onStateChange: ((ShiftState, [SuggestionEngine.Suggestion]) -> Void)?
    var onPlaneChange: ((KeyboardPlane) -> Void)?
    var onNextKeyboard: (() -> Void)?

    private(set) var shiftState: ShiftState = .oneShot
    private let suggestionEngine: SuggestionEngine

    private var lastShiftTapTime: TimeInterval = 0
    private var lastSpaceTime: TimeInterval = 0

    init(suggestionEngine: SuggestionEngine = SuggestionEngine()) {
        self.suggestionEngine = suggestionEngine
    }

    func loadLexicon(from controller: UIInputViewController) {
        suggestionEngine.loadLexicon(from: controller)
    }

    // MARK: - Actions

    func handle(_ action: KeyAction) {
        switch action {
        case .insert(let character):
            // The layout stores letters uppercase; case is decided here, at insertion, so the
            // renderer never has to know about shift semantics.
            insert(shiftState.isUppercase ? character.uppercased() : character.lowercased())

        case .space:
            insertSpace()

        case .newLine:
            document?.insertText("\n")
            refreshContextualState()

        case .backspace:
            document?.deleteBackward()
            refreshContextualState()

        case .shift:
            handleShiftTap()

        case .switchPlane(let plane):
            onPlaneChange?(plane)

        case .nextKeyboard:
            onNextKeyboard?()

        case .spacer:
            break
        }
    }

    /// Inserts literal text — a letter, an accent from the callout, or an emoji.
    func insert(_ text: String) {
        document?.insertText(text)
        shiftState = shiftState.afterCharacterInput
        emitState()
    }

    func acceptSuggestion(_ text: String) {
        // Replace the partial word rather than appending to it. Deleting by character count is
        // safe here because `partialWord(before:)` returned exactly these characters from the same
        // context string.
        let partial = SuggestionEngine.partialWord(before: document?.contextBeforeInput)
        for _ in 0..<partial.count { document?.deleteBackward() }
        document?.insertText(text + " ")
        shiftState = shiftState.afterCharacterInput
        refreshContextualState()
    }

    /// Space, with the double-space-to-period shortcut Apple lists as expected keyboard behaviour.
    ///
    /// Only fires when the character before the two spaces is a letter or digit, so "hello  " gets
    /// a period but ".  " does not become "..  " — double-spacing after punctuation is something
    /// people do deliberately.
    private func insertSpace() {
        let now = Date.timeIntervalSinceReferenceDate
        let context = document?.contextBeforeInput ?? ""

        if now - lastSpaceTime < 0.6,
           context.hasSuffix(" "),
           !context.hasSuffix("  "),
           let priorCharacter = context.dropLast().last,
           priorCharacter.isLetter || priorCharacter.isNumber {
            document?.deleteBackward()
            document?.insertText(". ")
            lastSpaceTime = 0
            refreshContextualState()
            return
        }

        document?.insertText(" ")
        lastSpaceTime = now
        refreshContextualState()
    }

    /// Single tap toggles shift; a second tap within the double-tap window locks it.
    private func handleShiftTap() {
        let now = Date.timeIntervalSinceReferenceDate
        if now - lastShiftTapTime < 0.3 {
            shiftState = .locked
            lastShiftTapTime = 0
            emitState()
            return
        }
        lastShiftTapTime = now
        shiftState = shiftState.afterShiftTap
        emitState()
    }

    // MARK: - Contextual state

    func refreshContextualState() {
        updateShiftForContext()
        emitState()
    }

    /// Auto-capitalises at the start of the document and after sentence-ending punctuation.
    ///
    /// Users treat this as part of the keyboard working correctly rather than as a feature, and
    /// `documentContextBeforeInput` is available without Full Access, so there is no reason to
    /// leave it out. It respects the host field's `autocapitalizationType`, which is why a URL or
    /// password-adjacent field does not get surprise capitals.
    private func updateShiftForContext() {
        // Caps lock is the user's explicit choice and outranks anything inferred from context.
        guard shiftState != .locked else { return }
        guard document?.autocapitalization != UITextAutocapitalizationType.none else {
            shiftState = .off
            return
        }

        let context = document?.contextBeforeInput ?? ""
        let trimmed = context.trimmingCharacters(in: .whitespaces)
        if context.isEmpty {
            shiftState = .oneShot
        } else if let last = trimmed.last, ".!?".contains(last), context.hasSuffix(" ") {
            shiftState = .oneShot
        } else {
            shiftState = .off
        }
    }

    private func emitState() {
        let partial = SuggestionEngine.partialWord(before: document?.contextBeforeInput)
        onStateChange?(shiftState, suggestionEngine.suggestions(forPartialWord: partial))
    }
}

// MARK: - Adapters

/// Adapter over the real host document.
final class ProxyTextDocument: TextDocumentAdapter {
    private let proxy: UITextDocumentProxy

    init(proxy: UITextDocumentProxy) {
        self.proxy = proxy
    }

    var contextBeforeInput: String? { proxy.documentContextBeforeInput }
    var autocapitalization: UITextAutocapitalizationType { proxy.autocapitalizationType ?? .sentences }
    func insertText(_ text: String) { proxy.insertText(text) }
    func deleteBackward() { proxy.deleteBackward() }
}

/// Adapter over a plain string, for the in-app test bench.
///
/// Deleting by `removeLast()` on `Character` rather than by UTF-16 unit is deliberate: it deletes a
/// whole grapheme cluster, which is what `deleteBackward()` does on a real document and what a
/// user expects when they backspace over an emoji or an accented letter.
final class BufferTextDocument: TextDocumentAdapter {
    private(set) var text: String = ""
    var onChange: ((String) -> Void)?

    var contextBeforeInput: String? { text }
    var autocapitalization: UITextAutocapitalizationType { .sentences }

    func insertText(_ newText: String) {
        text += newText
        onChange?(text)
    }

    func deleteBackward() {
        guard !text.isEmpty else { return }
        text.removeLast()
        onChange?(text)
    }
}
