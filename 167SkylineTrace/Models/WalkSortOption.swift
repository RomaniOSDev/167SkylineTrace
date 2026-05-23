import Foundation

enum WalkSortOption: String, CaseIterable, Identifiable {
    case dateDescending
    case dateAscending
    case distanceDescending
    case distanceAscending
    case durationDescending
    case ratingDescending

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .dateDescending: return "Newest first"
        case .dateAscending: return "Oldest first"
        case .distanceDescending: return "Longest distance"
        case .distanceAscending: return "Shortest distance"
        case .durationDescending: return "Longest duration"
        case .ratingDescending: return "Highest rating"
        }
    }
}
