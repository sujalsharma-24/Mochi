import SwiftUI

struct ThemeCard: View {
    let theme: KeyboardTheme
    var onTap: () -> Void = {}

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: MochiSpacing.sm) {
                ZStack(alignment: .topTrailing) {
                    // The card used to draw a seeded placeholder for *every* theme, ignoring
                    // `imageAssetName` — so a grid of 121 themes showed 121 generated gradients
                    // rather than the themes themselves. The plate is what the theme actually
                    // looks like, so draw it and keep the placeholder for the art-free case.
                    Group {
                        if ThemeArtAvailability.hasArt(theme.imageAssetName) {
                            Image(theme.imageAssetName)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } else {
                            KeyboardPreviewPlaceholder(seed: theme.id)
                        }
                    }
                    .aspectRatio(1, contentMode: .fit)
                    .clipShape(RoundedRectangle(cornerRadius: MochiRadius.card, style: .continuous))

                    if theme.isPremium {
                        Image(systemName: "crown.fill")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(.white)
                            .padding(6)
                            .background(Circle().fill(MochiColor.premiumTag))
                            .padding(8)
                    }
                }

                Text(theme.name)
                    .font(MochiFont.heading(14))
                    .foregroundStyle(MochiColor.textPrimary)
                    .lineLimit(1)

                HStack(spacing: 4) {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 11))
                        .foregroundStyle(MochiColor.pink)
                    Text(theme.likeCountFormatted)
                        .font(MochiFont.caption(12))
                        .foregroundStyle(MochiColor.textSecondary)
                }
            }
        }
        .buttonStyle(.plain)
    }
}

/// Sizes solved by rendering the real Inter TTFs and matching against the measured glyph runs in
/// docs/figma/1.png: "POPULAR THEMES" is 439px wide with a 37px cap height on a 2169px-wide frame,
/// which at 402pt of screen is Inter Bold ~9pt — noticeably smaller than the 13pt this carried
/// before. "see all" solves to Inter Regular ~8.8pt.
struct SectionHeader: View {
    let title: String
    var actionTitle: String? = "see all"
    /// Defaults are the Figma-measured sizes; Home passes its live-tuned values in.
    var titleSize: CGFloat = 9
    var actionSize: CGFloat = 9
    var action: () -> Void = {}
    /// Home has more than one "see all" on screen at once (Popular Themes, Font Collection), so
    /// each caller that needs to be found unambiguously (e.g. by UI tests) can tag its own.
    var actionIdentifier: String?

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(title.uppercased())
                .font(MochiFont.title(titleSize))
                .foregroundStyle(MochiColor.textPrimary)
            Spacer()
            if let actionTitle {
                Button(action: action) {
                    Text(actionTitle)
                        .font(MochiFont.body(actionSize))
                        .foregroundStyle(MochiColor.textPrimary) // black in Figma, not purple
                }
                .padding(.trailing, 2)
                .accessibilityIdentifier(actionIdentifier ?? "")
            }
        }
    }
}
