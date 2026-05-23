import SwiftUI

/// Shadow presets tuned for scroll performance (single composited shadow per card).
enum SkylineElevation: Equatable {
    /// Dense lists — minimal blur, cheap while scrolling.
    case list
    /// Default cards and widgets.
    case card
    /// Featured blocks, quote, comparison.
    case raised
    /// Hero carousel / one per screen max.
    case hero

    var shadowColor: Color {
        Color.black.opacity(opacity)
    }

    var radius: CGFloat {
        switch self {
        case .list: return 5
        case .card: return 10
        case .raised: return 14
        case .hero: return 18
        }
    }

    var y: CGFloat {
        switch self {
        case .list: return 2
        case .card: return 5
        case .raised: return 7
        case .hero: return 10
        }
    }

    private var opacity: Double {
        switch self {
        case .list: return 0.28
        case .card: return 0.38
        case .raised: return 0.45
        case .hero: return 0.5
        }
    }

    static func forCard(glow: Bool) -> SkylineElevation {
        glow ? .raised : .card
    }
}

enum SkylineDepth {
  static let cornerRadius: CGFloat = SkylineLayout.cardRadius
}
