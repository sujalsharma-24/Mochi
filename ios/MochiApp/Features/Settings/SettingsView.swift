import SwiftUI

/// Rebuilt against docs/figma/7.png (2161×3840 export; back button measures 152px against the
/// app's universal 44pt tap target, giving a ~3.45px/pt scale used to derive the numbers below —
/// section label/first-row gap ≈10pt, row vertical padding ~10pt, icon tile ~30pt, card top/bottom
/// padding ≈10pt, inter-card gap ≈12pt; tile and padding nudged up a couple pt off the raw
/// measurement after eyeballing the first Simulator render).
///
/// Real: the 4 KEYBOARD toggles + the PREFERENCES › Notifications toggle (persisted via
/// `AppSettingsStore` — the keyboard toggles into the App Group container the extension reads),
/// Log Out and Delete Account. Figma's export has no ACCOUNT or KEYBOARD section at all — those
/// are where the only working functionality on this screen lives, so they stay (parity-plus)
/// rather than being cut to match the static mock; everything else below matches the export.
struct SettingsView: View {
    var onBack: () -> Void = {}
    var onSignedOut: () -> Void = {}

    @ObservedObject private var settings = AppSettingsStore.shared
    @State private var showDeleteConfirm = false
    @State private var isDeleting = false
    @State private var errorMessage: String?
    @State private var themeMode: ThemeMode = .light

    private enum ThemeMode { case light, dark }

    /// Card-to-card gap and the row icon tile size, both pixel-measured off 7.png rather than
    /// reusing Home/Leaderboard's looser spacing — this screen's cards sit noticeably tighter.
    private enum Metrics {
        static let sectionSpacing: CGFloat = 12
        static let rowIconTile: CGFloat = 30
        static let bannerIconTile: CGFloat = 40
    }

    var body: some View {
        ZStack {
            MochiGradient.background.ignoresSafeArea()
            SparkleField()
            ScrollView {
                VStack(alignment: .leading, spacing: Metrics.sectionSpacing) {
                    header
                    setupBanner

                    section("ACCOUNT") {
                        row("person", "Signed in as", settings.accountLabel, trailing: { EmptyView() })
                        divider
                        row("rectangle.portrait.and.arrow.right", "Log Out", "Sign out of your account",
                            onTap: signOut, trailing: { chevron })
                        divider
                        row("trash", "Delete Account", "Permanently delete your account and data",
                            onTap: { showDeleteConfirm = true },
                            trailing: {
                                if isDeleting { ProgressView().tint(MochiColor.logoSolid) } else { chevron }
                            })
                    }

                    section("KEYBOARD") {
                        toggleRow("sparkles", "Autocorrect", "Fix typos automatically as you type", $settings.autocorrectEnabled)
                        divider
                        toggleRow("hand.draw", "Swipe Typing", "Type by sliding between letters", $settings.swipeTypingEnabled)
                        divider
                        toggleRow("iphone.radiowaves.left.and.right", "Haptic Feedback", "Vibrate on key press", $settings.hapticFeedbackEnabled)
                        divider
                        toggleRow("speaker.wave.2", "Key Click Sound", "Play a sound on key press", $settings.keyClickSoundEnabled)
                    }

                    section("APPEARANCE") {
                        row("paintpalette", "Theme Mode", "Choose your preferred theme", trailing: { themeModeToggle })
                        divider
                        row(nil, "App Appearance", "Customize how the app looks", trailing: { chevron })
                    }

                    section("PREFERENCES") {
                        row("globe", "Language", "Choose app language", trailing: {
                            Text("English (US)").font(MochiFont.body(13)).foregroundStyle(MochiColor.textMuted)
                        })
                        divider
                        toggleRow("bell", "Notifications", "Manage notification preferences", $settings.notificationsEnabled)
                        divider
                        row("keyboard", "Default Keyboard", "Set Mochi as your default keyboard", trailing: { chevron })
                        divider
                        row("arrow.counterclockwise", "Reset to Default", "Reset all settings to default", trailing: { chevron })
                    }

                    section("STORAGE") {
                        row(asset: "icon_clear_cache", "Clear Cache", "Free up space by clearing cache", trailing: { clearPill("24.3 MB") })
                        divider
                        row("trash", "Clear Data", "Clear all app data (Reset app)", trailing: { clearPill("0.00 MB") })
                        divider
                        row(asset: "icon_storage_usage", "Storage Usage", "Manage app storage", trailing: {
                            HStack(spacing: 4) {
                                Text("158.7 MB").font(MochiFont.body(13)).foregroundStyle(MochiColor.textMuted)
                                chevron
                            }
                        })
                    }

                    section("PRIVACY & DATA") {
                        row("checkmark.shield", "Privacy Policy", "Read our privacy policy", trailing: { chevron })
                        divider
                        row("doc.text", "Terms of Service", "Read our terms of service", trailing: { chevron })
                        divider
                        row("list.bullet.rectangle", "Manage Data", "Manage your data & privacy", trailing: { chevron })
                    }

                    section("HELP & SUPPORT") {
                        row("person.crop.circle.badge.questionmark", "Help Center", "Get help with common questions", trailing: { chevron })
                        divider
                        row("bubble.left.and.bubble.right", "FAQs", "Frequently asked questions", trailing: { chevron })
                        divider
                        row("envelope", "Contact Us", "We're here to help", trailing: { chevron })
                    }
                }
                .padding(.horizontal, MochiSpacing.md)
                .padding(.top, MochiSpacing.md)
                .padding(.bottom, 40)
            }
            .scrollIndicators(.hidden)
        }
        .confirmationDialog("Delete your account?", isPresented: $showDeleteConfirm, titleVisibility: .visible) {
            Button("Delete", role: .destructive, action: deleteAccount)
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This permanently deletes your account and unpublishes your themes. This can't be undone.")
        }
        .alert("Something went wrong", isPresented: Binding(get: { errorMessage != nil }, set: { if !$0 { errorMessage = nil } })) {
            Button("OK") { errorMessage = nil }
        } message: {
            Text(errorMessage ?? "")
        }
    }

    // MARK: - Actions

    private func signOut() {
        try? AppContainer.shared?.authRepository.signOut()
        onSignedOut()
    }

    private func deleteAccount() {
        guard let container = AppContainer.shared else {
            // No backend yet — behave as a sign-out so the flow is demonstrable.
            onSignedOut()
            return
        }
        isDeleting = true
        Task {
            do {
                try await container.authRepository.deleteAccount()
                isDeleting = false
                onSignedOut()
            } catch {
                isDeleting = false
                errorMessage = error.localizedDescription
            }
        }
    }

    // MARK: - Pieces

    private var header: some View {
        VStack(spacing: 2) {
            ZStack {
                HStack {
                    Button(action: onBack) {
                        Image(systemName: "arrow.left")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(.white)
                            .frame(width: 44, height: 44)
                            .background(MochiGradient.primaryButton)
                            .clipShape(Circle())
                    }
                    .accessibilityIdentifier("settings.back")
                    Spacer()
                }
                HStack(spacing: 6) {
                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                        .fill(MochiGradient.primaryButton)
                        .frame(width: 24, height: 24)
                        .overlay(Image(systemName: "gearshape.fill").font(.system(size: 12)).foregroundStyle(.white))
                    // Figma's export reads "Setting" (singular). Its "g" is single-storey (rules out
                    // Inter) but noticeably less bubbly/heavy than the "Mochi" wordmark's Fredoka
                    // SemiBold — a stem/cap-height ratio measured off the export (~0.16) lands on
                    // Baloo2 at its default weight (400), not Fredoka 600. Flat #9C28B1 (`logoSolid`),
                    // not the bluer `MochiColor.purple`: sampled straight off the glyph fill.
                    Text("Setting").font(MochiFont.displayRound(26)).foregroundStyle(MochiColor.logoSolid)
                }
            }
            Text("Manage your app preferences")
                .font(MochiFont.caption(12)).foregroundStyle(MochiColor.textSecondary)
        }
        .frame(maxWidth: .infinity)
    }

    private var setupBanner: some View {
        HStack(spacing: MochiSpacing.sm) {
            iconTile("keyboard", size: Metrics.bannerIconTile)
            VStack(alignment: .leading, spacing: 2) {
                Text("Keyboard Setup Guide").font(MochiFont.heading(15)).foregroundStyle(MochiColor.logoSolid)
                Text("Learn how to set up Mochi as your default keyboard")
                    .font(MochiFont.caption(11)).foregroundStyle(MochiColor.textMuted)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 0)
            HStack(spacing: 4) {
                Text("Start Guide").font(MochiFont.caption(12)).foregroundStyle(MochiColor.logoSolid)
                chevron
            }
        }
        .padding(MochiSpacing.md)
        .background(Color.white, in: RoundedRectangle(cornerRadius: MochiRadius.card, style: .continuous))
    }

    /// Figma's card carries its section label *inside* the white card (top-left, above the first
    /// row) and a faint 1pt `outline`-colour stroke around the whole card — the old version drew
    /// the label above the card in the page background and left the card unstroked.
    private func section<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title)
                .font(.custom("Inter-Bold", size: 13))
                .foregroundStyle(MochiColor.textPrimary)
                .padding(.horizontal, MochiSpacing.md)
                .padding(.top, 12)
                .padding(.bottom, 10)
            content()
        }
        .background(Color.white, in: RoundedRectangle(cornerRadius: MochiRadius.card, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: MochiRadius.card, style: .continuous)
                .stroke(MochiColor.outline, lineWidth: 1)
        )
    }

    /// A hairline row separator, `#AAAAAA` (matching `textMuted`) inset to the row's own
    /// horizontal padding — sampled off the divider between "Clear Cache" and "Clear Data".
    private var divider: some View {
        Rectangle()
            .fill(MochiColor.textMuted)
            .frame(height: 1)
            .padding(.horizontal, MochiSpacing.md)
    }

    private func row<Trailing: View>(
        _ icon: String?, _ title: String, _ subtitle: String,
        onTap: (() -> Void)? = nil,
        @ViewBuilder trailing: () -> Trailing
    ) -> some View {
        HStack(spacing: MochiSpacing.sm) {
            iconTile(icon, size: Metrics.rowIconTile)
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(MochiFont.heading(14)).foregroundStyle(MochiColor.textPrimary)
                Text(subtitle).font(MochiFont.caption(11)).foregroundStyle(MochiColor.textMuted)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 4)
            trailing()
        }
        .padding(.horizontal, MochiSpacing.md)
        .padding(.vertical, 10)
        .contentShape(Rectangle())
        .onTapGesture { onTap?() }
    }

    /// The two rows (Clear Cache, Storage Usage) whose Figma glyph has no SF Symbol equivalent —
    /// cropped whole (gradient tile included) straight from the 7.png tile, same one-scale-slot
    /// convention as `icon_crown`/`icon_bow`.
    private func row<Trailing: View>(
        asset: String, _ title: String, _ subtitle: String,
        onTap: (() -> Void)? = nil,
        @ViewBuilder trailing: () -> Trailing
    ) -> some View {
        HStack(spacing: MochiSpacing.sm) {
            Image(asset)
                .resizable()
                .scaledToFill()
                .frame(width: Metrics.rowIconTile, height: Metrics.rowIconTile)
                .clipShape(RoundedRectangle(cornerRadius: Metrics.rowIconTile * 0.3, style: .continuous))
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(MochiFont.heading(14)).foregroundStyle(MochiColor.textPrimary)
                Text(subtitle).font(MochiFont.caption(11)).foregroundStyle(MochiColor.textMuted)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 4)
            trailing()
        }
        .padding(.horizontal, MochiSpacing.md)
        .padding(.vertical, 10)
        .contentShape(Rectangle())
        .onTapGesture { onTap?() }
    }

    private func toggleRow(_ icon: String, _ title: String, _ subtitle: String, _ binding: Binding<Bool>) -> some View {
        row(icon, title, subtitle) {
            Toggle("", isOn: binding)
                .labelsHidden()
                .tint(MochiColor.logoSolid)
        }
    }

    /// `icon == nil` reproduces the export's "App Appearance" row, whose tile is a bare gradient
    /// square with no glyph on it at all — not a missing-icon bug in the design, just how it ships.
    private func iconTile(_ icon: String?, size: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: size * 0.3, style: .continuous)
            .fill(MochiGradient.settingsIconTile)
            .frame(width: size, height: size)
            .overlay {
                if let icon {
                    Image(systemName: icon)
                        .font(.system(size: size * 0.46, weight: .regular))
                        .foregroundStyle(MochiColor.settingsIconGlyph)
                }
            }
    }

    private var chevron: some View {
        Image(systemName: "chevron.right").font(.system(size: 13, weight: .semibold)).foregroundStyle(MochiColor.logoSolid)
    }

    private func clearPill(_ value: String) -> some View {
        HStack(spacing: 8) {
            Text(value).font(MochiFont.body(13)).foregroundStyle(MochiColor.textMuted)
            Text("Clear")
                .font(MochiFont.caption(12)).foregroundStyle(MochiColor.logoSolid)
                .padding(.horizontal, 12).padding(.vertical, 6)
                .overlay(Capsule().stroke(MochiColor.logoSolid.opacity(0.3), lineWidth: 1))
        }
    }

    private var themeModeToggle: some View {
        HStack(spacing: 0) {
            ForEach([("Light", ThemeMode.light), ("Dark", ThemeMode.dark)], id: \.0) { label, mode in
                Text(label)
                    .font(MochiFont.caption(11))
                    .foregroundStyle(themeMode == mode ? MochiColor.logoSolid : .white)
                    .padding(.horizontal, 10).padding(.vertical, 6)
                    .background {
                        if themeMode == mode { Capsule().fill(Color.white) }
                    }
                    .onTapGesture { themeMode = mode }
            }
        }
        .padding(3)
        .background(MochiGradient.primaryButton, in: Capsule())
    }
}

#Preview {
    SettingsView()
}
