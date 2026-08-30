import Foundation

/// Checks that a theme is actually usable before it is allowed to ship or be published.
///
/// This exists because the failure mode of a user-generated theme system is not a crash — it is a
/// keyboard nobody can read. Every check here reduces to one question: *after the layers are
/// composited, is there enough separation between the ink and what is behind it?* Running it in
/// the Create screen turns that from a review problem into a live editing constraint.
enum ThemeValidator {
    /// WCAG AA for normal-size text, and the ratio Apple's own App Store "Sufficient Contrast"
    /// accessibility criterion is evaluated against. Key labels are small text on a surface the
    /// user reads under time pressure, so they are held to the text threshold, not the 3:1
    /// non-text one.
    static let minimumLabelContrast: Double = 4.5

    /// WCAG non-text contrast. Applies to the cap-versus-backdrop edge: if a key cap does not
    /// separate from the keyboard background, the user cannot see where one key ends and the next
    /// begins even when the letters themselves are perfectly legible.
    static let minimumCapContrast: Double = 3.0

    enum Severity: String, Equatable {
        /// Must be fixed. A theme with any of these should not be publishable.
        case error
        /// Legible but below what the design system considers premium.
        case warning
    }

    struct Issue: Equatable, CustomStringConvertible {
        var severity: Severity
        var role: KeyRole?
        var message: String
        /// The measured ratio, where the check was a contrast check.
        var measuredRatio: Double?

        var description: String {
            let scope = role.map { "[\($0.rawValue)] " } ?? ""
            let measured = measuredRatio.map { String(format: " (%.2f:1)", $0) } ?? ""
            return "\(severity.rawValue.uppercased()) \(scope)\(message)\(measured)"
        }
    }

    struct Report: Equatable {
        var issues: [Issue]

        var errors: [Issue] { issues.filter { $0.severity == .error } }
        var warnings: [Issue] { issues.filter { $0.severity == .warning } }
        /// A theme is publishable when nothing is an error. Warnings are for the author to weigh.
        var isPublishable: Bool { errors.isEmpty }
    }

    static func validate(_ theme: MochiKeyboardTheme) -> Report {
        var issues: [Issue] = []

        // The colour behind a key cap, with background *art* deliberately excluded — see
        // `ThemeSurface.effectiveKeyBackdrop`. Art cannot be reduced to one luminance, which is
        // precisely why a theme that uses art is required to carry a scrim strong enough that the
        // composite below is a fair description of what the user sees.
        let backdrop = theme.surface.effectiveKeyBackdrop

        if theme.surface.backgroundImage != nil, theme.surface.scrim.weakestColor.alpha < 0.12 {
            issues.append(Issue(
                severity: .warning,
                role: nil,
                message: """
                    Background art with an almost transparent scrim (\(
                        String(format: "%.0f%%", theme.surface.scrim.weakestColor.alpha * 100)
                    ) at its weakest). Key legibility will depend on what the artwork happens to \
                    look like behind each key, which cannot be validated. Raise the scrim, or blur \
                    the art.
                    """,
                measuredRatio: nil
            ))
        }

        for role in KeyRole.allCases {
            guard let style = theme.keyStyles[role] else {
                issues.append(Issue(
                    severity: .warning,
                    role: role,
                    message: "No style authored; falls back to the input style.",
                    measuredRatio: nil
                ))
                continue
            }

            // A fully transparent label is a deliberate choice, not a failure — the Fantasy Castle
            // Night space bar hides its "space" text so the panorama inside the cap reads cleanly.
            // Measuring contrast on invisible ink returns 1.00:1 and would block the theme forever.
            let labelIsHidden = style.labelColor.alpha == 0

            // Cap flattened onto the backdrop: a translucent cap's real colour, not its authored one.
            let capOnBackdrop = style.fill.contrastRepresentative.composited(over: backdrop)
            let labelOnCap = style.labelColor.composited(over: capOnBackdrop)
            let labelRatio = labelOnCap.contrastRatio(against: capOnBackdrop)

            if labelIsHidden {
                // No text to read; only the cap's own separation matters below.
            } else if labelRatio < minimumLabelContrast {
                issues.append(Issue(
                    severity: .error,
                    role: role,
                    message: "Label contrast against the key cap is below \(minimumLabelContrast):1.",
                    measuredRatio: labelRatio
                ))
            } else if labelRatio < 7 {
                issues.append(Issue(
                    severity: .warning,
                    role: role,
                    message: "Label contrast passes AA but not AAA (7:1).",
                    measuredRatio: labelRatio
                ))
            }

            let capRatio = capOnBackdrop.contrastRatio(against: backdrop)
            // A cap with no border relies entirely on its own fill to separate from the keyboard
            // background. One that has a border can legitimately be near-invisible in fill and
            // still read as a key, so the check is skipped there rather than producing noise.
            if style.border == nil, capRatio < minimumCapContrast {
                issues.append(Issue(
                    severity: .error,
                    role: role,
                    message: """
                        Key cap does not separate from the keyboard background \
                        (needs \(minimumCapContrast):1, or a border).
                        """,
                    measuredRatio: capRatio
                ))
            }

            // The pressed state is a real state a user sees on every keystroke, so it is validated
            // like any other rather than assumed to inherit legibility from the resting state.
            let pressedCap = style.resolvedPressedFill.contrastRepresentative.composited(over: backdrop)
            let pressedLabel = style.resolvedPressedLabelColor.composited(over: pressedCap)
            let pressedRatio = pressedLabel.contrastRatio(against: pressedCap)
            if !labelIsHidden, pressedRatio < minimumLabelContrast {
                issues.append(Issue(
                    severity: .error,
                    role: role,
                    message: "Pressed-state label contrast is below \(minimumLabelContrast):1.",
                    measuredRatio: pressedRatio
                ))
            }

            // Press feedback has to be *visible*. A pressed fill that measures within a hair of the
            // resting fill means the key looks dead on tap, which reads as the keyboard having
            // missed the touch.
            let restingLuminance = capOnBackdrop.relativeLuminance
            let pressedLuminance = pressedCap.relativeLuminance
            if abs(restingLuminance - pressedLuminance) < 0.02 {
                issues.append(Issue(
                    severity: .warning,
                    role: role,
                    message: "Pressed state is nearly identical to the resting state; taps will look unresponsive.",
                    measuredRatio: nil
                ))
            }
        }

        // Chrome ink sits on the keyboard surface, not on a key cap — the suggestion bar and the
        // emoji category strip have the background art directly behind them. That makes it a
        // separate check rather than something the per-role loop above covers: a theme with
        // near-black key labels (correct, its caps are pale) would be invisible here.
        let chromeInk = theme.chrome.inkColor.composited(over: backdrop)
        let chromeRatio = chromeInk.contrastRatio(against: backdrop)
        if chromeRatio < minimumLabelContrast {
            issues.append(Issue(
                severity: .error,
                role: nil,
                message: "Suggestion/emoji ink (`chrome.inkColor`) is illegible on the keyboard surface.",
                measuredRatio: chromeRatio
            ))
        }

        // The muted variant is real text too — it is the emoji category strip's unselected state,
        // which users read to navigate. Held to the same bar rather than excused as decorative.
        let mutedInk = theme.chrome.mutedInkColor.composited(over: backdrop)
        let mutedRatio = mutedInk.contrastRatio(against: backdrop)
        if mutedRatio < 3.0 {
            issues.append(Issue(
                severity: .warning,
                role: nil,
                message: "`chrome.mutedInkColor` is below 3:1 on the surface; unselected emoji categories will be hard to see.",
                measuredRatio: mutedRatio
            ))
        }

        // The base colour is what the user gets when the artwork is missing — a fresh install that
        // has not synced, a file evicted from the container, a download that failed. That state has
        // to be legible too, so it is validated as a first-class case rather than treated as an
        // error path.
        if theme.surface.backgroundImage != nil {
            let fallbackBackdrop = theme.surface.scrim.weakestColor
                .composited(over: theme.surface.baseFill.contrastRepresentative)
            for role in KeyRole.allCases {
                let style = theme.style(for: role)
                guard style.labelColor.alpha > 0 else { continue }
                let cap = style.fill.contrastRepresentative.composited(over: fallbackBackdrop)
                let label = style.labelColor.composited(over: cap)
                if label.contrastRatio(against: cap) < minimumLabelContrast {
                    issues.append(Issue(
                        severity: .error,
                        role: role,
                        message: "Illegible when the background art is unavailable; fix `surface.baseColor`.",
                        measuredRatio: label.contrastRatio(against: cap)
                    ))
                }
            }
        }

        return Report(issues: issues)
    }
}
