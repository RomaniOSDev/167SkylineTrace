import Foundation

struct WalkTemplate: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var title: String
    var routeId: UUID?
    var routeName: String?
    var distance: Double
    var duration: Int
    var mood: WalkMood
    var difficulty: WalkDifficulty
    var neighborhood: Neighborhood
    var weather: WalkWeather?
    var description: String
    var highlights: [String]
    var tags: [String]
    var imageNames: [String]?
    let createdAt: Date
}
