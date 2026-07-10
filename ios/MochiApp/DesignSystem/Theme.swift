import SwiftUI

enum MochiColor {
    static let purple = Color(red: 0.545, green: 0.361, blue: 0.965)
    static let purpleDark = Color(red: 0.486, green: 0.227, blue: 0.929)
    static let pink = Color(red: 0.925, green: 0.286, blue: 0.600)
    static let pinkLight = Color(red: 0.976, green: 0.716, blue: 0.855)
    static let lavender = Color(red: 0.808, green: 0.749, blue: 0.976)

    static let textPrimary = Color(red: 0.145, green: 0.106, blue: 0.235)
    static let textSecondary = Color(red: 0.42, green: 0.38, blue: 0.50)

    static let cardBackground = Color.white
    static let screenBackgroundFallback = Color(red: 0.976, green: 0.906, blue: 0.965)

    static let freeTag = Color(red: 0.549, green: 0.792, blue: 0.396)
    static let premiumTag = Color(red: 0.976, green: 0.702, blue: 0.235)
}

enum MochiGradient {
    static let background = LinearGradient(
        colors: [
            Color(red: 0.980, green: 0.796, blue: 0.898),
            Color(red: 0.851, green: 0.729, blue: 0.965),
            Color(red: 0.745, green: 0.686, blue: 0.965)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let primaryButton = LinearGradient(
        colors: [MochiColor.pink, MochiColor.purple],
        startPoint: .leading,
        endPoint: .trailing
    )

    static let logoText = LinearGradient(
        colors: [MochiColor.purpleDark, MochiColor.pink],
        startPoint: .leading,
        endPoint: .trailing
    )

    static let premiumBanner = LinearGradient(
        colors: [
            Color(red: 0.416, green: 0.204, blue: 0.780),
            Color(red: 0.667, green: 0.278, blue: 0.816)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

enum MochiRadius {
    static let card: CGFloat = 20
    static let pill: CGFloat = 999
    static let sheet: CGFloat = 28
}

enum MochiSpacing {
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
}
