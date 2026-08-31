import SwiftUI

/// Ported from android/.../features/settings/SettingsScreen.kt (docs/figma/7.png).
///
/// Real: the 4 KEYBOARD toggles + the PREFERENCES › Notifications toggle (persisted via
/// `AppSettingsStore` — the keyboard toggles into the App Group container the extension reads),
/// Log Out and Delete Account. Everything else (Appearance / Language / Storage / Privacy / Help)
/// is the same static placeholder UI Android carries, out of scope.
struct SettingsView: View {
    var onBack: () -> Void = {}
    var onSignedOut: () -> Void = {}

    @ObservedObject private var settings = AppSettingsStore.shared
    @State private var showDeleteConfirm = false
    @State private var isDeleting = false
    @State private var errorMessage: String?
    @State private var themeMode: ThemeMode = .light

    private enum ThemeMode { case light, dark }

    var body: some View {
        ZStack {
            MochiGradient.background.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: MochiSpacing.lg) {
                    header
                    setupBanner

                    section("ACCOUNT") {
                        row("person.fill", "Signed in as", settings.accountLabel, trailing: { EmptyView() })
                        row("rectangle.portrait.and.arrow.right", "Log Out", "Sign out of your account",
                            onTap: signOut, trailing: { chevron })
                        row("trash.fill", "Delete Account", "Permanently delete your account and data",
                            onTap: { showDeleteConfirm = true },
                            trailing: {
                                if isDeleting { ProgressView().tint(MochiColor.purple) } else { chevron }
                            })
                    }

                    section("KEYBOARD") {
                        toggleRow("sparkles", "Autocorrect", "Fix typos automatically as you type", $settings.autocorrectEnabled)
                        toggleRow("hand.draw.fill", "Swipe Typing", "Type by sliding between letters", $settings.swipeTypingEnabled)
                        toggleRow("iphone.radiowaves.left.and.right", "Haptic Feedback", "Vibrate on key press", $settings.hapticFeedbackEnabled)
                        toggleRow("speaker.wave.2.fill", "Key Click Sound", "Play a sound on key press", $settings.keyClickSoundEnabled)
                    }

                    section("APPEARANCE") {
                        row("paintpalette.fill", "Theme Mode", "Choose your preferred theme", trailing: { themeModeToggle })
                        row("gearshape.fill", "App Appearance", "Customize how the app looks", trailing: { chevron })
                    }

                    section("PREFERENCES") {
                        row("globe", "Language", "Choose app language", trailing: {
                            Text("English (US)").font(MochiFont.body(13)).foregroundStyle(MochiColor.textSecondary)
                        })
                        toggleRow("bell.fill", "Notifications", "Manage notification preferences", $settings.notificationsEnabled)
                        row("keyboard", "Default Keyboard", "Set Mochi as your default keyboard", trailing: { chevron })
                        row("arrow.counterclockwise", "Reset to Default", "Reset all settings to default", trailing: { chevron })
                    }

                    section("STORAGE") {
                        row("trash.slash.fill", "Clear Cache", "Free up space by clearing cache", trailing: { clearPill("24.3 MB") })
                        row("externaldrive.fill.badge.xmark", "Clear Data", "Clear all app data (Reset app)", trailing: { clearPill("0.00 MB") })
                        row("chart.pie.fill", "Storage Usage", "Manage app storage", trailing: {
                            HStack(spacing: 4) {
                                Text("158.7 MB").font(MochiFont.body(13)).foregroundStyle(MochiColor.textSecondary)
                                chevron
                            }
                        })
                    }

                    section("PRIVACY & DATA") {
                        row("checkmark.shield.fill", "Privacy Policy", "Read our privacy policy", trailing: { chevron })
                        row("doc.text.fill", "Terms of Service", "Read our terms of service", trailing: { chevron })
                        row("list.bullet.rectangle.fill", "Manage Data", "Manage your data & privacy", trailing: { chevron })
                    }

                    section("HELP & SUPPORT") {
                        row("person.fill.questionmark", "Help Center", "Get help with common questions", trailing: { chevron })
                        row("bubble.left.and.bubble.right.fill", "FAQs", "Frequently asked questions", trailing: { chevron })
                        row("envelope.fill", "Contact Us", "We're here to help", trailing: { chevron })
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
                    Text("Settings").font(MochiFont.title(26)).foregroundStyle(MochiColor.purple)
                }
            }
            Text("Manage your app preferences")
                .font(MochiFont.caption(12)).foregroundStyle(MochiColor.textSecondary)
        }
        .frame(maxWidth: .infinity)
    }

    private var setupBanner: some View {
        HStack(spacing: MochiSpacing.sm) {
            iconTile("keyboard")
            VStack(alignment: .leading, spacing: 2) {
                Text("Keyboard Setup Guide").font(MochiFont.heading(15)).foregroundStyle(MochiColor.purple)
                Text("Learn how to set up Mochi as your default keyboard")
                    .font(MochiFont.caption(11)).foregroundStyle(MochiColor.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 0)
            HStack(spacing: 4) {
                Text("Start Guide").font(MochiFont.caption(12)).foregroundStyle(MochiColor.purple)
                chevron
            }
        }
        .padding(MochiSpacing.md)
        .background(Color.white, in: RoundedRectangle(cornerRadius: MochiRadius.card, style: .continuous))
    }

    private func section<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: MochiSpacing.sm) {
            Text(title).font(MochiFont.heading(13)).foregroundStyle(MochiColor.textPrimary)
            VStack(spacing: 0) { content() }
                .background(Color.white, in: RoundedRectangle(cornerRadius: MochiRadius.card, style: .continuous))
        }
    }

    private func row<Trailing: View>(
        _ icon: String, _ title: String, _ subtitle: String,
        onTap: (() -> Void)? = nil,
        @ViewBuilder trailing: () -> Trailing
    ) -> some View {
        HStack(spacing: MochiSpacing.sm) {
            iconTile(icon)
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(MochiFont.heading(14)).foregroundStyle(MochiColor.textPrimary)
                Text(subtitle).font(MochiFont.caption(11)).foregroundStyle(MochiColor.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 4)
            trailing()
        }
        .padding(.horizontal, MochiSpacing.md)
        .padding(.vertical, 12)
        .contentShape(Rectangle())
        .onTapGesture { onTap?() }
    }

    private func toggleRow(_ icon: String, _ title: String, _ subtitle: String, _ binding: Binding<Bool>) -> some View {
        row(icon, title, subtitle) {
            Toggle("", isOn: binding)
                .labelsHidden()
                .tint(MochiColor.purple)
        }
    }

    private func iconTile(_ icon: String) -> some View {
        RoundedRectangle(cornerRadius: 10, style: .continuous)
            .fill(MochiGradient.primaryButton)
            .frame(width: 40, height: 40)
            .overlay(Image(systemName: icon).font(.system(size: 17)).foregroundStyle(.white))
    }

    private var chevron: some View {
        Image(systemName: "chevron.right").font(.system(size: 13, weight: .semibold)).foregroundStyle(MochiColor.purple)
    }

    private func clearPill(_ value: String) -> some View {
        HStack(spacing: 8) {
            Text(value).font(MochiFont.body(13)).foregroundStyle(MochiColor.textSecondary)
            Text("Clear")
                .font(MochiFont.caption(12)).foregroundStyle(MochiColor.purple)
                .padding(.horizontal, 12).padding(.vertical, 6)
                .overlay(Capsule().stroke(MochiColor.purple.opacity(0.3), lineWidth: 1))
        }
    }

    private var themeModeToggle: some View {
        HStack(spacing: 0) {
            ForEach([("Light", ThemeMode.light), ("Dark", ThemeMode.dark)], id: \.0) { label, mode in
                Text(label)
                    .font(MochiFont.caption(11))
                    .foregroundStyle(themeMode == mode ? MochiColor.purple : .white)
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
