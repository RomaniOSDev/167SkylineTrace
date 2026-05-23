import Foundation

enum WalkWeather: String, CaseIterable, Codable {
    case clear
    case cloudy
    case rainy
    case windy
    case foggy
    case cold

    var displayName: String {
        switch self {
        case .clear: return "Clear"
        case .cloudy: return "Cloudy"
        case .rainy: return "Rainy"
        case .windy: return "Windy"
        case .foggy: return "Foggy"
        case .cold: return "Cold"
        }
    }

    var icon: String {
        switch self {
        case .clear: return "moon.stars.fill"
        case .cloudy: return "cloud.fill"
        case .rainy: return "cloud.rain.fill"
        case .windy: return "wind"
        case .foggy: return "cloud.fog.fill"
        case .cold: return "snowflake"
        }
    }
}
