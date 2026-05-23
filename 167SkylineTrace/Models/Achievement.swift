import Foundation

enum AchievementType: String, CaseIterable, Codable {
    case streak3
    case streak7
    case distanceWeek10
    case neighborhoods5
    case walks10
    case walks50
    case photos5
    case favorites5
    case ratedWalks5

    var title: String {
        switch self {
        case .streak3: return "Three Nights"
        case .streak7: return "Week of Nights"
        case .distanceWeek10: return "10 km Week"
        case .neighborhoods5: return "City Explorer"
        case .walks10: return "Night Regular"
        case .walks50: return "Night Veteran"
        case .photos5: return "Memory Keeper"
        case .favorites5: return "Star Collector"
        case .ratedWalks5: return "Critic"
        }
    }

    var description: String {
        switch self {
        case .streak3: return "Walk 3 nights in a row"
        case .streak7: return "Walk 7 nights in a row"
        case .distanceWeek10: return "Cover 10 km in one week"
        case .neighborhoods5: return "Visit 5 different neighborhoods"
        case .walks10: return "Log 10 night walks"
        case .walks50: return "Log 50 night walks"
        case .photos5: return "Add photos to 5 walks"
        case .favorites5: return "Mark 5 walks as favorite"
        case .ratedWalks5: return "Rate 5 walks"
        }
    }

    var icon: String {
        switch self {
        case .streak3, .streak7: return "flame.fill"
        case .distanceWeek10: return "map.fill"
        case .neighborhoods5: return "building.2.fill"
        case .walks10, .walks50: return "figure.walk"
        case .photos5: return "photo.fill"
        case .favorites5: return "star.fill"
        case .ratedWalks5: return "star.leadinghalf.filled"
        }
    }
}

struct AchievementRecord: Identifiable, Codable, Equatable {
    let id: UUID
    let type: AchievementType
    let unlockedAt: Date
}
