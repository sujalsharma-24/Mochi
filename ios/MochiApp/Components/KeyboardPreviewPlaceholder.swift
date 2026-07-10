import SwiftUI

/// Vector stand-in for a theme's rendered keyboard background until real art assets
/// (client-provided, per TRD scope) are dropped into Assets.xcassets under the same name.
struct KeyboardPreviewPlaceholder: View {
    let seed: String
    var cornerRadius: CGFloat = MochiRadius.card

    private var gradientColors: [Color] {
        let palettes: [[Color]] = [
            [Color(red: 0.267, green: 0.212, blue: 0.573), Color(red: 0.514, green: 0.318, blue: 0.741)],
            [Color(red: 0.976, green: 0.706, blue: 0.831), Color(red: 0.573, green: 0.451, blue: 0.827)],
            [Color(red: 0.192, green: 0.325, blue: 0.243), Color(red: 0.306, green: 0.494, blue: 0.400)],
            [Color(red: 0.980, green: 0.827, blue: 0.616), Color(red: 0.980, green: 0.706, blue: 0.510)],
            [Color(red: 0.180, green: 0.180, blue: 0.400), Color(red: 0.420, green: 0.290, blue: 0.620)]
        ]
        let index = abs(seed.hashValue) % palettes.count
        return palettes[index]
    }

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                LinearGradient(colors: gradientColors, startPoint: .topLeading, endPoint: .bottomTrailing)

                VStack(spacing: proxy.size.height * 0.035) {
                    ForEach(0..<3) { row in
                        HStack(spacing: proxy.size.width * 0.02) {
                            ForEach(0..<(row == 2 ? 7 : 9), id: \.self) { _ in
                                RoundedRectangle(cornerRadius: 3)
                                    .fill(Color.white.opacity(0.22))
                                    .frame(height: proxy.size.height * 0.11)
                            }
                        }
                    }
                }
                .padding(.horizontal, proxy.size.width * 0.06)
                .padding(.top, proxy.size.height * 0.55)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
    }
}
