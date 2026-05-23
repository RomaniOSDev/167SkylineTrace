import Foundation

enum Neighborhood: String, CaseIterable, Codable {
    case downtown
    case oldTown
    case park
    case waterfront
    case business
    case residential
    case other

    var displayName: String {
        switch self {
        case .downtown: return "Downtown"
        case .oldTown: return "Old Town"
        case .park: return "Park District"
        case .waterfront: return "Waterfront"
        case .business: return "Business District"
        case .residential: return "Residential"
        case .other: return "Other"
        }
    }

    var icon: String {
        switch self {
        case .downtown: return "building.2.fill"
        case .oldTown: return "building.columns.fill"
        case .park: return "tree.fill"
        case .waterfront: return "water.waves"
        case .business: return "briefcase.fill"
        case .residential: return "house.fill"
        case .other: return "map.fill"
        }
    }
}
