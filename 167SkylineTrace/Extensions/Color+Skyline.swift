import SwiftUI

extension Color {
    static let skylineBackground = Color(red: 0.059, green: 0.075, blue: 0.157)
    static let skylineAccent = Color(red: 0.008, green: 0.467, blue: 0.859)
    static let skylineText = Color.white
    static let skylineCard = Color(red: 0.09, green: 0.12, blue: 0.22)
    static let skylineCardElevated = Color(red: 0.12, green: 0.16, blue: 0.28)
    static let skylineCardDeep = Color(red: 0.07, green: 0.09, blue: 0.18)
    static let skylineMuted = Color.white.opacity(0.45)

    static var skylineAccentGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color(red: 0.12, green: 0.58, blue: 0.98),
                Color.skylineAccent,
                Color(red: 0.0, green: 0.35, blue: 0.72)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static var skylineCardGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color.skylineCardElevated,
                Color.skylineCard,
                Color.skylineCardDeep
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static var skylineSurfaceShine: LinearGradient {
        LinearGradient(
            colors: [
                Color.white.opacity(0.14),
                Color.white.opacity(0.03),
                Color.clear
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    static var skylineBorderGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color.skylineAccent.opacity(0.5),
                Color.skylineAccent.opacity(0.15),
                Color.white.opacity(0.05)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}
