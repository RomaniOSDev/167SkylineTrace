import Foundation

enum GoalKind: String, Codable, CaseIterable {
    case manual
    case monthlyWalks
    case monthlyDistance
    case weeklyDistance

    var displayName: String {
        switch self {
        case .manual: return "Custom goal"
        case .monthlyWalks: return "Walks this month"
        case .monthlyDistance: return "Distance this month"
        case .weeklyDistance: return "Distance this week"
        }
    }
}
