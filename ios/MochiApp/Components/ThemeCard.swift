import SwiftUI

struct ThemeCard: View {
    let theme: KeyboardTheme
    var onTap: () -> Void = {}

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: MochiSpacing.sm) {
                ZStack(alignment: .topTrailing) {
                    KeyboardPreviewPlaceholder(seed: theme.id)
                        .aspectRatio(1, contentMode: .fit)

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

struct SectionHeader: View {
    let title: String
    var actionTitle: String? = "see all"
    var action: () -> Void = {}

    var body: some View {
        HStack {
            Text(title.uppercased())
                .font(MochiFont.heading(13))
                .foregroundStyle(MochiColor.textPrimary)
            Spacer()
            if let actionTitle {
                Button(action: action) {
                    Text(actionTitle)
                        .font(MochiFont.caption(13))
                        .foregroundStyle(MochiColor.purple)
                }
            }
        }
    }
}
