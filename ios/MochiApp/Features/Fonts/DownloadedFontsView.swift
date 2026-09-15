import SwiftUI

/// The "see all" destination for the Fonts screen's MY DOWNLOADED FONTS strip.
///
/// Shows every style the user owns — persisted in `FontStyleStore`, seeded on first run with the
/// five Figma ships — each rendered through its own lookalike transform so the row is a real
/// specimen. "Apply" writes through the same `FontStyleStore.apply` path `FontsView` uses, so there
/// is one applied-font code path across the app. Empty state is handled rather than pushed onto a
/// blank screen.
struct DownloadedFontsView: View {
    var onBack: () -> Void = {}
    var onOpenPaywall: () -> Void = {}

    @ObservedObject private var billing = BillingRepository.shared
    @State private var ownedIDs: [String] = FontStyleStore.loadOwnedStyleIDs()
    @State private var appliedID: String? = FontStyleStore.loadAppliedStyleID()

    private var fonts: [FontItem] {
        ownedIDs.compactMap { id in MockData.fontCollection.first { $0.id == id } }
    }

    var body: some View {
        ZStack {
            MochiGradient.background.ignoresSafeArea()
            VStack(alignment: .leading, spacing: MochiSpacing.md) {
                header
                if fonts.isEmpty {
                    emptyState
                } else {
                    ScrollView {
                        LazyVStack(spacing: MochiSpacing.sm) {
                            ForEach(fonts) { row($0) }
                        }
                        .padding(.bottom, 40)
                    }
                    .scrollIndicators(.hidden)
                }
                Spacer(minLength: 0)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, MochiSpacing.md)
            .padding(.top, MochiSpacing.md)
        }
        .clipped()
    }

    private func apply(_ font: FontItem) {
        guard !(font.isPremium && !billing.isUserPremium) else {
            onOpenPaywall()
            return
        }
        FontStyleStore.apply(font.id)
        appliedID = font.id
    }

    // MARK: - Pieces

    private var header: some View {
        HStack(spacing: 10) {
            Button(action: onBack) {
                Image(systemName: "arrow.left")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(MochiColor.textPrimary)
                    .frame(width: 34, height: 34)
                    .background(Circle().fill(.white))
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("downloadedFonts.back")

            Text("My Downloaded Fonts")
                .font(MochiFont.title(19))
                .foregroundStyle(MochiColor.textPrimary)
            Spacer(minLength: 0)
        }
    }

    private var emptyState: some View {
        VStack(spacing: 8) {
            Image(systemName: "textformat")
                .font(.system(size: 34, weight: .light))
                .foregroundStyle(MochiColor.textGreyWarm)
            Text("No downloaded fonts yet")
                .font(MochiFont.itemName(15))
                .foregroundStyle(MochiColor.textPrimary)
            Text("Apply a font from the Fonts screen and it shows up here.")
                .font(MochiFont.body(13))
                .foregroundStyle(MochiColor.textGreyWarm)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 60)
        .accessibilityIdentifier("downloadedFonts.empty")
    }

    private func row(_ font: FontItem) -> some View {
        let style = FontStyleCatalog.style(for: font.id)
        let isApplied = font.id == appliedID
        return HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 6) {
                    Text(font.name)
                        .font(MochiFont.itemName(15))
                        .foregroundStyle(MochiColor.textPrimary)
                    if font.isPremium {
                        Text("Pro")
                            .font(MochiFont.itemName(10))
                            .foregroundStyle(MochiColor.proChipText)
                            .padding(.horizontal, 6).padding(.vertical, 1)
                            .background(MochiColor.proChipBackground, in: Capsule())
                    }
                }
                Text(style?.styled("Aa Bb Cc 123") ?? "Aa Bb Cc 123")
                    .font(.system(size: 17))
                    .foregroundStyle(MochiColor.logoSolid)
                    .lineLimit(1)
            }
            Spacer(minLength: 0)
            Text(isApplied ? "Applied" : "Apply")
                .font(MochiFont.body(13))
                .foregroundStyle(isApplied ? MochiColor.textPrimary : .white)
                .padding(.horizontal, 14)
                .frame(height: 30)
                .background {
                    if isApplied {
                        Capsule().stroke(MochiColor.logoSolid, lineWidth: 0.5)
                    } else {
                        Capsule().fill(MochiGradient.fontsAccent)
                    }
                }
                .contentShape(Capsule())
                .onTapGesture { apply(font) }
                .accessibilityIdentifier("downloadedFonts.\(font.id).apply")
        }
        .padding(12)
        .background(Color.white, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        .accessibilityIdentifier("downloadedFonts.row.\(font.id)")
    }
}

#Preview {
    DownloadedFontsView()
}
