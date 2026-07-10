import SwiftUI
import UIKit

struct MochiTabBar: View {
    @Binding var selected: MochiTab

    var body: some View {
        ZStack {
            HStack(spacing: 0) {
                tabButton(.keyboard)
                tabButton(.fonts)
                Spacer().frame(width: 64)
                tabButton(.themes)
                tabButton(.community)
            }
            .padding(.horizontal, MochiSpacing.md)
            .padding(.top, MochiSpacing.sm)
            .padding(.bottom, MochiSpacing.xs)
            .background(
                Color.white
                    .clipShape(RoundedCorner(radius: MochiRadius.sheet, corners: [.topLeft, .topRight]))
                    .shadow(color: .black.opacity(0.08), radius: 12, y: -4)
            )

            createButton
                .offset(y: -18)
        }
    }

    private func tabButton(_ tab: MochiTab) -> some View {
        Button {
            selected = tab
        } label: {
            VStack(spacing: 4) {
                Image(systemName: tab.systemImage)
                    .font(.system(size: 20, weight: .semibold))
                Text(tab.title)
                    .font(MochiFont.caption(11))
            }
            .foregroundStyle(selected == tab ? MochiColor.purple : MochiColor.textSecondary.opacity(0.6))
            .frame(maxWidth: .infinity)
        }
        .accessibilityIdentifier("tab.\(tab.rawValue)")
    }

    private var createButton: some View {
        Button {
            selected = .create
        } label: {
            ZStack {
                Circle()
                    .fill(MochiGradient.primaryButton)
                    .frame(width: 60, height: 60)
                    .shadow(color: MochiColor.purple.opacity(0.4), radius: 10, y: 4)
                Image(systemName: "wand.and.stars")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(.white)
            }
        }
        .accessibilityIdentifier("tab.create")
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = 12
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}
