import UIKit

/// Word completions and spelling corrections for the suggestion bar.
///
/// Backed by `UITextChecker` and `UILexicon`, both of which work inside a keyboard extension with
/// **no Full Access** — they read the system dictionary and the user's own text shortcuts and
/// contact names in-process, without the keyboard ever seeing the network.
///
/// This is deliberately *not* autocorrect. It never silently replaces what the user typed; it
/// offers candidates that only apply when tapped. Real autocorrect needs an n-gram language model
/// and a touch model of which keys neighbour which, and a half-built one that changes words
/// without being asked is materially worse than none — it is the single most complained-about
/// behaviour in any keyboard.
final class SuggestionEngine {
    /// One candidate in the bar.
    struct Suggestion: Equatable {
        let text: String
        /// The literal characters the user typed, always offered first so they can defend a word
        /// the dictionary does not know — a name, a handle, deliberate slang.
        let isVerbatim: Bool
    }

    private let checker = UITextChecker()
    private var lexiconEntries: [(shortcut: String, expansion: String)] = []

    /// `UILexicon` is delivered asynchronously and is the user's own data — text-replacement
    /// shortcuts and unpaired contact names. Loading it is free and it is the only part of this
    /// that knows anything personal, which is why nothing here is ever logged or transmitted.
    func loadLexicon(from controller: UIInputViewController) {
        controller.requestSupplementaryLexicon { [weak self] lexicon in
            self?.lexiconEntries = lexicon.entries.map { ($0.userInput.lowercased(), $0.documentText) }
        }
    }

    /// - Parameter partialWord: the word currently being typed, i.e. the text between the last
    ///   whitespace and the insertion point.
    /// - Returns: up to three candidates, verbatim first.
    func suggestions(forPartialWord partialWord: String, limit: Int = 3) -> [Suggestion] {
        let trimmed = partialWord.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return [] }

        var results: [Suggestion] = [Suggestion(text: trimmed, isVerbatim: true)]
        var seen: Set<String> = [trimmed.lowercased()]

        func append(_ candidate: String) {
            let key = candidate.lowercased()
            guard !seen.contains(key), results.count < limit else { return }
            seen.insert(key)
            results.append(Suggestion(text: candidate, isVerbatim: false))
        }

        // The user's own shortcuts outrank the dictionary: someone who set "omw" → "On my way!"
        // wants that ahead of any completion of "omw".
        for entry in lexiconEntries where entry.shortcut.hasPrefix(trimmed.lowercased()) {
            append(entry.expansion)
        }

        // `UITextChecker` indexes by UTF-16 offsets, so the range has to be built in that space —
        // using `count` breaks on any word containing an emoji or a composed character, which is
        // precisely the input most likely to reach a keyboard like this one.
        let nsRange = NSRange(location: 0, length: (trimmed as NSString).length)
        let language = preferredLanguage

        if let completions = checker.completions(
            forPartialWordRange: nsRange,
            in: trimmed,
            language: language
        ) {
            for completion in completions { append(completion) }
        }

        // Only fall back to spelling guesses once completions have run dry. A misspelling is a
        // less likely intent than a prefix, so guesses should never outrank completions.
        if results.count < limit,
           checker.rangeOfMisspelledWord(
               in: trimmed,
               range: nsRange,
               startingAt: 0,
               wrap: false,
               language: language
           ).location != NSNotFound,
           let guesses = checker.guesses(forWordRange: nsRange, in: trimmed, language: language) {
            for guess in guesses { append(guess) }
        }

        return results
    }

    /// The checker's language, falling back to US English when the user's locale has no dictionary.
    /// Passing an unsupported language makes `UITextChecker` return nil for everything, which
    /// presents as a suggestion bar that is simply always empty.
    private var preferredLanguage: String {
        let preferred = Locale.preferredLanguages.first ?? "en_US"
        let available = UITextChecker.availableLanguages
        if available.contains(preferred) { return preferred }
        let base = preferred.split(separator: "-").first.map(String.init) ?? "en"
        return available.first { $0.hasPrefix(base) } ?? "en_US"
    }

    // MARK: - Word extraction

    /// The partial word immediately before the insertion point.
    ///
    /// Splits on whitespace *and* newlines only. Splitting on punctuation as well would look
    /// tidier but breaks contractions — "don" is a poor thing to be suggesting completions for
    /// while someone types "don't".
    static func partialWord(before context: String?) -> String {
        guard let context, !context.isEmpty else { return "" }
        guard let lastBreak = context.rangeOfCharacter(from: .whitespacesAndNewlines, options: .backwards) else {
            return context
        }
        return String(context[lastBreak.upperBound...])
    }
}
