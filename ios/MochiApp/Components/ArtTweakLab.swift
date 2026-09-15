import SwiftUI
import UIKit

#if DEBUG
/// A DEBUG-only screen for placing a theme's per-key illustrations by eye.
///
/// It exists because illustration placement is the one part of this theme system that cannot be
/// derived. Contrast can be measured, geometry can be fitted to the system keyboard, but whether
/// the tower on `D` sits too high is a judgement, and the loop for making that judgement was:
/// change a number in `BuiltInThemes.swift`, rebuild, look, describe the difference in words,
/// repeat. Thirty-three illustrations at a minute a round trip is most of a day, and the person
/// who can actually see the answer is not the one editing the file.
///
/// So this inverts it. Tap an illustration to select it, drag the sliders (position, size, opacity,
/// brightness), then press **Copy All**: the panel emits every edited key's `KeyArtPlacement`
/// literal in one block, ready to paste into the theme. Nothing here is a mock — the keyboard on
/// screen is the production `KeyboardSurfaceView` rendering the production tokens, so what gets
/// dialled in is what the extension will draw.
struct ArtTweakLab: View {
    let theme: MochiKeyboardTheme

    /// Only the keys someone has actually moved. Sparse for the same reason the token is sparse —
    /// this dictionary is the thing that gets pasted back into the theme, and an entry per key
    /// would bury the handful that matter.
    @State private var placements: [String: KeyArtPlacement] = [:]
    @State private var selected: String?
    @State private var status: String?
    /// Background framing, edited independently of any key's illustration. Starts at the theme's
    /// authored value so the slider doesn't jump the art on first touch.
    @State private var backgroundAnchor: Double

    init(theme: MochiKeyboardTheme) {
        self.theme = theme
        _backgroundAnchor = State(initialValue: theme.surface.backgroundImage?.verticalAnchor ?? 0.5)
    }

    /// The theme actually handed to the bench — identical to `theme` except for the background's
    /// vertical anchor, which is live-edited here rather than baked into `theme` itself. A computed
    /// copy rather than mutating `theme` in place, so the emitted source always diffs against the
    /// original authored value.
    private var effectiveTheme: MochiKeyboardTheme {
        guard var background = theme.surface.backgroundImage else { return theme }
        background.verticalAnchor = backgroundAnchor
        var next = theme
        next.surface.backgroundImage = background
        return next
    }

    /// `-MochiThemeLabSelect <identity>` preselects a key and `-MochiThemeLabSeed x,y,scale,opacity`
    /// gives it a placement at launch.
    ///
    /// Same reason `-MochiThemeLabPlane` exists: there is no way to tap a key from `simctl`, and
    /// posting synthetic clicks into the Simulator needs an Accessibility grant this machine does
    /// not have. Without these, the only way to see a placement rendered is by hand, which makes
    /// the one thing this screen produces the one thing it cannot demonstrate from the command line.
    static var seededSelection: String? {
        UserDefaults.standard.string(forKey: "MochiThemeLabSelect")
    }

    static var seededPlacement: KeyArtPlacement? {
        guard let raw = UserDefaults.standard.string(forKey: "MochiThemeLabSeed") else { return nil }
        let parts = raw.split(separator: ",").compactMap { Double($0.trimmingCharacters(in: .whitespaces)) }
        guard parts.count >= 3 else { return nil }
        return KeyArtPlacement(
            offsetX: parts[0],
            offsetY: parts[1],
            scale: parts[2],
            opacity: parts.count > 3 ? parts[3] : nil,
            brightness: parts.count > 4 ? parts[4] : nil
        )
    }

    private var current: KeyArtPlacement {
        selected.map { placements[$0] ?? .identity } ?? .identity
    }

    var body: some View {
        VStack(spacing: 0) {
            header
            controls
            Spacer(minLength: 8)
            bench
        }
        .background(Color(white: 0.10).ignoresSafeArea())
        .onAppear {
            guard let seed = Self.seededSelection else { return }
            selected = seed
            guard let placement = Self.seededPlacement else { return }
            placements[seed] = placement
            // A seeded launch is a scripted launch, and a scripted launch wants the artifact — this
            // is what lets the copy path be exercised from `simctl`, where the button cannot be
            // pressed. Identical to what the button does.
            copy()
        }
    }

    // MARK: - Header

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text("Art Tweak — \(theme.name)")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white)
                Spacer()
                Text(placements.isEmpty ? "no edits" : "\(placements.count) edited")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(placements.isEmpty ? .white.opacity(0.4) : .cyan)
            }
            Text(status ?? (selected.map { "selected: \($0)" } ?? "tap any key's illustration to select it"))
                .font(.system(size: 11, design: .monospaced))
                .foregroundStyle(status != nil ? .green : .white.opacity(0.55))
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 14)
        .padding(.top, 10)
    }

    // MARK: - Controls

    @ViewBuilder
    private var controls: some View {
        VStack(spacing: 6) {
            // Bounds mirror `KeyArtPlacement`'s own clamps exactly, and must keep doing so. The
            // first pass capped these at ±0.5 and 0.3–2.5, tighter than the token — and two keys
            // came back sitting at precisely -0.500, which is indistinguishable from a deliberate
            // choice in the emitted source. A slider that silently bottoms out short of the real
            // limit does not constrain a value, it fabricates one.
            row("X", value: current.offsetX, range: -1...1, step: 0.005,
                set: update { $0.offsetX = $1 })
            row("Y", value: current.offsetY, range: -1...1, step: 0.005,
                set: update { $0.offsetY = $1 })
            row("Size", value: current.scale, range: 0.2...3, step: 0.01,
                set: update { $0.scale = $1 })
            row(
                "Opacity",
                // Falls back to the set-wide value so the slider starts where the key is actually
                // drawn, not at 1.0 — otherwise the first touch of this slider jumps the artwork.
                value: current.opacity ?? (theme.keyArt?.opacity ?? 1),
                range: 0...1,
                step: 0.01,
                set: update { $0.opacity = $1 }
            )
            row(
                "Brightness",
                // No set-wide brightness token exists, so this always starts at 0 (unchanged) —
                // there is nothing else for it to fall back to.
                value: current.brightness ?? 0,
                range: -1...1,
                step: 0.01,
                set: update { $0.brightness = $1 }
            )

            buttons
        }
        .disabled(selected == nil)
        .opacity(selected == nil ? 0.45 : 1)
        .padding(.horizontal, 14)
        .padding(.top, 8)

        backgroundControls
    }

    /// Framing for the background plate itself — separate from any key's illustration, and never
    /// disabled by the "select a key first" gate above, since there is nothing to select.
    @ViewBuilder
    private var backgroundControls: some View {
        if theme.surface.backgroundImage != nil {
            VStack(spacing: 6) {
                Divider().background(Color.white.opacity(0.15)).padding(.vertical, 2)
                row(
                    "BG Anchor",
                    value: backgroundAnchor,
                    range: 0...1,
                    step: 0.01,
                    set: { backgroundAnchor = $0; status = nil }
                )
            }
            .padding(.horizontal, 14)
        }
    }

    private func row(
        _ label: String,
        value: Double,
        range: ClosedRange<Double>,
        step: Double,
        set: @escaping (Double) -> Void
    ) -> some View {
        HStack(spacing: 8) {
            Text(label)
                .font(.system(size: 11, weight: .medium, design: .monospaced))
                .foregroundStyle(.white.opacity(0.75))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .frame(width: 68, alignment: .leading)

            // Nudge buttons flank the slider because a slider is the wrong instrument for the last
            // 2% of this job: a 340pt track across a 0.3–2.5 range moves ~0.006 per point, so the
            // difference between "right" and "one hair off" is smaller than a fingertip.
            nudge("−") { set(max(range.lowerBound, value - step)) }
            Slider(value: Binding(get: { value.clamped(to: range) }, set: set), in: range)
                .tint(.cyan)
            nudge("+") { set(min(range.upperBound, value + step)) }

            Text(String(format: "%+.3f", value))
                .font(.system(size: 10, design: .monospaced))
                .foregroundStyle(.white.opacity(0.6))
                .frame(width: 54, alignment: .trailing)
        }
    }

    private func nudge(_ glyph: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(glyph)
                .font(.system(size: 14, weight: .bold, design: .monospaced))
                .foregroundStyle(.white)
                .frame(width: 26, height: 26)
                .background(Color.white.opacity(0.12), in: RoundedRectangle(cornerRadius: 6))
        }
        .buttonStyle(.plain)
    }

    private var buttons: some View {
        HStack(spacing: 6) {
            action("Reset", tint: .orange) {
                guard let selected else { return }
                placements[selected] = nil
                status = "reset \(selected)"
            }
            action("Apply to all", tint: .purple) {
                // The common case by a wide margin: every illustration in a set was produced by the
                // same generation pass, so when one is too large or too bright they all are. Dial
                // one key in, push it to the rest, then fix the few that disagree.
                guard let selected, let placement = placements[selected] else { return }
                for identity in artIdentities { placements[identity] = placement }
                status = "applied \(selected)'s placement to \(artIdentities.count) keys"
            }
            action("Clear all", tint: .red) {
                placements.removeAll()
                status = "cleared every edit"
            }
            action("Copy All", tint: .cyan) { copy() }
        }
        .padding(.top, 2)
    }

    private func action(_ title: String, tint: Color, run: @escaping () -> Void) -> some View {
        Button(action: run) {
            Text(title)
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(tint)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 7)
                .background(tint.opacity(0.16), in: RoundedRectangle(cornerRadius: 7))
        }
        .buttonStyle(.plain)
    }

    // MARK: - Bench

    private var bench: some View {
        GeometryReader { proxy in
            ArtTweakBench(
                theme: effectiveTheme,
                placements: placements,
                selected: selected,
                onSelect: { identity in
                    selected = identity
                    status = identity == nil ? "that key has no illustration" : nil
                }
            )
            .frame(
                width: proxy.size.width,
                height: KeyboardTestBench.preferredHeight(for: theme, width: proxy.size.width)
            )
        }
        .frame(height: KeyboardTestBench.preferredHeight(for: theme, width: UIScreen.main.bounds.width))
    }

    // MARK: - Editing

    /// Mutates the selected key's placement, creating it at identity if this is its first edit.
    private func update(_ apply: @escaping (inout KeyArtPlacement, Double) -> Void) -> (Double) -> Void {
        { value in
            guard let selected else { return }
            var placement = placements[selected] ?? .identity
            apply(&placement, value)
            // Re-run through the initialiser so the token's own clamps apply here too, rather than
            // trusting the slider's bounds to be the only guard on a value that gets persisted.
            placements[selected] = KeyArtPlacement(
                offsetX: placement.offsetX,
                offsetY: placement.offsetY,
                scale: placement.scale,
                opacity: placement.opacity,
                brightness: placement.brightness
            )
            status = nil
        }
    }

    private var artIdentities: [String] {
        let metrics = KeyboardMetrics(availableWidth: UIScreen.main.bounds.width, isLandscape: false)
        let layout = KeyboardLayout.layout(for: .letters, includesNextKeyboardKey: true, metrics: metrics)
        return layout.rows.flatMap { $0.keys }.compactMap(\.artIdentity)
    }

    // MARK: - Copy

    /// Emits the placements as Swift source, ready to paste into `BuiltInThemes`.
    ///
    /// Written to two places on purpose. The pasteboard is for the person doing the tweaking; the
    /// file in the app container is so the result can be read straight off the simulator without
    /// anyone having to retype or re-paste a block of numbers — which is the failure mode this whole
    /// screen exists to remove.
    private func copy() {
        let source = swiftSource()
        UIPasteboard.general.string = source

        var wrote = "clipboard"
        if let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let url = documents.appendingPathComponent("keyart-placements.swift")
            if (try? source.write(to: url, atomically: true, encoding: .utf8)) != nil {
                wrote = "clipboard + \(url.lastPathComponent)"
            }
        }
        status = "copied \(placements.count) placement(s) → \(wrote)"
    }

    private func swiftSource() -> String {
        var sections: [String] = []

        let originalAnchor = theme.surface.backgroundImage?.verticalAnchor
        if let originalAnchor, abs(originalAnchor - backgroundAnchor) > 0.001 {
            sections.append("""
            // Background — paste as `verticalAnchor:` on this theme's ThemeBackgroundImage.
            verticalAnchor: \(String(format: "%.2f", backgroundAnchor))
            """)
        }

        if placements.isEmpty {
            sections.append("// No key placements — every illustration is drawing at the set-wide defaults.\nplacements: [:]")
        } else {
            let body = placements.keys.sorted().map { identity -> String in
                let p = placements[identity]!
                var parts = [
                    String(format: "offsetX: %.3f", p.offsetX),
                    String(format: "offsetY: %.3f", p.offsetY),
                    String(format: "scale: %.3f", p.scale)
                ]
                if let opacity = p.opacity { parts.append(String(format: "opacity: %.2f", opacity)) }
                if let brightness = p.brightness, brightness != 0 {
                    parts.append(String(format: "brightness: %.2f", brightness))
                }
                return "    \"\(identity)\": KeyArtPlacement(\(parts.joined(separator: ", "))),"
            }
            sections.append("""
            // Key art — paste as the `placements:` argument of this theme's KeyArtSet.
            placements: [
            \(body.joined(separator: "\n"))
            ]
            """)
        }

        return """
        // Generated by ArtTweakLab for \(theme.name) (\(theme.id)).
        \(sections.joined(separator: "\n\n"))
        """
    }
}

// MARK: -

/// The production keyboard renderer, in selection mode.
private struct ArtTweakBench: UIViewRepresentable {
    let theme: MochiKeyboardTheme
    let placements: [String: KeyArtPlacement]
    let selected: String?
    let onSelect: (String?) -> Void

    func makeUIView(context: Context) -> KeyboardSurfaceView {
        let surface = KeyboardSurfaceView(
            theme: theme,
            includesNextKeyboardKey: true,
            showsSuggestionBar: false,
            containerURL: ThemeStore.containerURL
        )
        surface.isArtTweakMode = true
        surface.onArtSelected = onSelect
        return surface
    }

    func updateUIView(_ view: KeyboardSurfaceView, context: Context) {
        // Only the placements and the ring are pushed unconditionally. Re-applying the whole theme
        // on every tick would rebuild every key view mid-drag and drop the selection — `applyTheme`
        // itself only touches the background layers, not key views (see its doc comment), but it's
        // still gated on an actual change so a placement-only edit doesn't reload the background.
        if view.theme != theme {
            view.applyTheme(theme)
        }
        view.updateKeyArtPlacements(placements)
        view.selectArtIdentity(selected)
    }
}

private extension Double {
    func clamped(to range: ClosedRange<Double>) -> Double {
        Swift.min(range.upperBound, Swift.max(range.lowerBound, self))
    }
}
#endif
