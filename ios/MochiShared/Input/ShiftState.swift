import Foundation

/// The three states shift can actually be in.
///
/// Modelled as an enum rather than a `Bool` + a separate `isCapsLocked` flag because the two-flag
/// version has an unrepresentable-but-reachable fourth state (locked *and* one-shot), and the bug
/// it produces — caps lock silently releasing after one letter — is exactly the kind of thing that
/// gets reported as "the keyboard is broken" rather than as a specific defect.
enum ShiftState: Equatable {
    /// Lowercase.
    case off
    /// Uppercase for exactly one character, then back to `off`. What the system does at the start
    /// of a sentence, and what a single shift tap gives you.
    case oneShot
    /// Uppercase until explicitly turned off. Reached by double-tapping shift.
    case locked

    var isUppercase: Bool { self != .off }

    /// Whether the shift key should render in its engaged style.
    var showsEngagedKey: Bool { self != .off }

    /// What a single tap on the shift key does from here.
    ///
    /// Tapping while locked releases the lock rather than dropping to one-shot — a user tapping a
    /// lit caps-lock key is asking for lowercase, not for one more capital.
    var afterShiftTap: ShiftState {
        switch self {
        case .off: return .oneShot
        case .oneShot: return .off
        case .locked: return .off
        }
    }

    /// Applied after a character is inserted.
    var afterCharacterInput: ShiftState {
        self == .oneShot ? .off : self
    }
}
