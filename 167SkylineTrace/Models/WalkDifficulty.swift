import Foundation

enum WalkDifficulty: String, CaseIterable, Codable {
    case easy
    case moderate
    case challenging

    var displayName: String {
        switch self {
        case .easy: return "Easy"
        case .moderate: return "Moderate"
        case .challenging: return "Challenging"
        }
    }

    var icon: String {
        switch self {
        case .easy: return "1.circle"
        case .moderate: return "2.circle"
        case .challenging: return "3.circle"
        }
    }
}
