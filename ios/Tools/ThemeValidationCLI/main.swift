import Foundation

// A host-side check that every built-in theme is legible, plus a JSON round-trip test.
//
// This runs without a simulator, an Xcode project, or a signing identity, which is the point:
// contrast is the property most likely to regress when someone nudges a colour, and a check that
// needs a device to run is a check nobody runs. `ios/Tools/validate-themes.sh` builds and runs it.
//
// It compiles because the theme model is deliberately Foundation-only — see the `canImport(UIKit)`
// guard in `ThemeColor.swift`.

var failed = false

print("Theme validation")
print(String(repeating: "=", count: 72))

for theme in BuiltInThemes.all {
    print("\n\(theme.name)  (\(theme.id))")
    print(String(repeating: "-", count: 72))

    let backdrop = theme.surface.effectiveKeyBackdrop
    print("  key backdrop (base + weakest scrim): \(backdrop.hexString)")

    // Print the measured ratios whether or not they pass. A validator that only speaks up on
    // failure gives no way to see that a value is sitting one nudge above the threshold.
    for role in KeyRole.allCases {
        let style = theme.style(for: role)
        let cap = style.fill.contrastRepresentative.composited(over: backdrop)
        let label = style.labelColor.composited(over: cap)
        let pressedCap = style.resolvedPressedFill.contrastRepresentative.composited(over: backdrop)
        let pressedLabel = style.resolvedPressedLabelColor.composited(over: pressedCap)

        let labelRatio = label.contrastRatio(against: cap)
        let capRatio = cap.contrastRatio(against: backdrop)
        let pressedRatio = pressedLabel.contrastRatio(against: pressedCap)
        let pressDelta = abs(cap.relativeLuminance - pressedCap.relativeLuminance)

        print(String(
            format: "  %-7@ label %5.2f:1   cap %5.2f:1   pressed-label %5.2f:1   press ΔL %.3f",
            role.rawValue as NSString,
            labelRatio,
            capRatio,
            pressedRatio,
            pressDelta
        ))
    }

    let report = ThemeValidator.validate(theme)
    if report.issues.isEmpty {
        print("  ✓ no issues")
    } else {
        for issue in report.issues {
            print("  \(issue)")
        }
    }
    if !report.isPublishable {
        failed = true
        print("  ✗ NOT PUBLISHABLE — \(report.errors.count) error(s)")
    }

    // A theme that cannot survive the App Group round trip is broken regardless of how it looks:
    // the extension only ever sees the decoded copy.
    do {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        let data = try encoder.encode(theme)
        let decoded = try JSONDecoder().decode(MochiKeyboardTheme.self, from: data)
        if decoded == theme {
            print("  ✓ JSON round-trip is lossless (\(data.count) bytes)")
        } else {
            failed = true
            print("  ✗ JSON round-trip changed the theme")
        }
    } catch {
        failed = true
        print("  ✗ JSON round-trip threw: \(error)")
    }
}

// MARK: - Art-backed legibility

// `ThemeValidator` above checks base + scrim only. This checks the real artwork, pixel by pixel,
// under every key — the measurement that decides whether the scrim is actually doing its job.
// Every theme that ships background art gets checked against it, not just the first one.
for artTheme in BuiltInThemes.all {
    guard case .bundled(let artName)? = artTheme.surface.backgroundImage?.source else { continue }
    let base = "SharedAssets/KeyboardArt.xcassets/\(artName).imageset/\(artName)"
    guard let artPath = [base + ".heic", base + ".png"].first(where: {
        FileManager.default.fileExists(atPath: $0)
    }) else {
        print("\n! \(artTheme.name): background art not found on disk — skipped")
        continue
    }
    let deviceWidth: CGFloat = 402
    let deviceMetrics = KeyboardMetrics(availableWidth: deviceWidth, isLandscape: false)
    let letterLayout = KeyboardLayout.layout(
        for: .letters,
        includesNextKeyboardKey: true,
        metrics: deviceMetrics
    )
    let gridHeight = deviceMetrics.totalHeight(rowCount: letterLayout.rows.count)

    print("""

        Art-backed legibility — \(artTheme.name) @ \(Int(deviceWidth))×\
        \(Int(gridHeight + deviceMetrics.suggestionBarHeight))pt (iPhone 16 Pro, letters + bar)
        """)
    print(String(repeating: "-", count: 72))

    if let results = ArtBackdropCheck.run(
        theme: artTheme,
        artPath: artPath,
        width: deviceWidth,
        keyGridHeight: gridHeight,
        suggestionBarHeight: deviceMetrics.suggestionBarHeight
    ) {
        print("  worst 6 keys (label = strict worst pixel; cap = area clearing 3:1):")
        for r in results.sorted(by: { $0.capCoverage < $1.capCoverage }).prefix(6) {
            print(String(
                format: "    %-11@ %-7@ label %5.2f:1   cap cover %6.2f%% (worst %4.2f:1)   backdrop L %.3f–%.3f",
                r.label as NSString,
                r.role.rawValue as NSString,
                r.worstLabelContrast,
                r.capCoverage * 100,
                r.worstCapContrast,
                r.minBackdropLuminance,
                r.maxBackdropLuminance
            ))
        }

        let labelFailures = results.filter { $0.worstLabelContrast < ThemeValidator.minimumLabelContrast }
        let capFailures = results.filter {
            $0.capCoverage < ArtBackdropCheck.requiredCapCoverage
                && artTheme.style(for: $0.role).border == nil
        }
        if labelFailures.isEmpty && capFailures.isEmpty {
            print("  ✓ every key clears AA against the real artwork — the scrim is doing its job")
        } else {
            failed = true
            for r in labelFailures {
                print(String(format: "  ✗ '%@' label %.2f:1 against the art", r.label, r.worstLabelContrast))
            }
            for r in capFailures {
                print(String(format: "  ✗ '%@' cap clears 3:1 on only %.2f%% of its area", r.label, r.capCoverage * 100))
            }
        }
    } else {
        print("  ! could not load the artwork — skipped")
    }
}

print("")
if failed {
    print("FAILED")
    exit(1)
}
print("PASSED")
