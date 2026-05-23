import Foundation

enum WalkMood: String, CaseIterable, Codable {
    case peaceful
    case energetic
    case romantic
    case reflective
    case adventurous

    var displayName: String {
        switch self {
        case .peaceful: return "Peaceful"
        case .energetic: return "Energetic"
        case .romantic: return "Romantic"
        case .reflective: return "Reflective"
        case .adventurous: return "Adventurous"
        }
    }

    var icon: String {
        switch self {
        case .peaceful: return "leaf.fill"
        case .energetic: return "bolt.fill"
        case .romantic: return "heart.fill"
        case .reflective: return "brain.head.profile"
        case .adventurous: return "map.fill"
        }
    }
}
