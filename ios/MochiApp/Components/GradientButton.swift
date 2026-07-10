import SwiftUI

struct GradientButton: View {
    let title: String
    var systemImage: String? = nil
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: MochiSpacing.xs) {
                if let systemImage {
                    Image(systemName: systemImage)
                }
                Text(title)
            }
            .font(MochiFont.button())
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(MochiGradient.primaryButton)
            .clipShape(Capsule())
        }
    }
}

struct OutlineButton: View {
    let title: String
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(MochiFont.button())
                .foregroundStyle(MochiColor.textPrimary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Color.white)
                .clipShape(Capsule())
                .overlay(
                    Capsule().stroke(MochiColor.purple.opacity(0.35), lineWidth: 1)
                )
        }
    }
}
