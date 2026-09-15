import Foundation

/// The "RECENT SEARCHES" chips, persisted across launches.
///
/// Plain `UserDefaults.standard` — **not** the App Group. Search history is a browsing convenience
/// for this app on this device; the keyboard extension has no reason to read it.
///
/// Rules: most-recent first, case-insensitive de-dup (typing "night" twice doesn't stack), capped
/// at `capacity`. Commits happen on submit / chip tap only, never per keystroke, so the list never
/// fills up with "c", "co", "cot", "cotton".
enum RecentSearchStore {
    private static let key = "mochi.search.recentSearches"
    static let capacity = 8

    /// Shown before the user has searched anything — matches the chips docs/figma/6.png draws. Once
    /// the user searches (or hits "Clear All"), their own list takes over and this is never seen again.
    static let seed = ["cotton candy", "handwritten font", "neon night", "mochi studio"]

    static func load() -> [String] {
        guard let stored = UserDefaults.standard.array(forKey: key) as? [String] else { return seed }
        return stored
    }

    /// Records `term` at the front and returns the new list.
    @discardableResult
    static func record(_ term: String) -> [String] {
        let trimmed = term.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.count >= 2 else { return load() }

        var list = load().filter { $0.caseInsensitiveCompare(trimmed) != .orderedSame }
        list.insert(trimmed, at: 0)
        if list.count > capacity { list = Array(list.prefix(capacity)) }

        UserDefaults.standard.set(list, forKey: key)
        return list
    }

    @discardableResult
    static func clear() -> [String] {
        UserDefaults.standard.set([String](), forKey: key)
        return []
    }
}
