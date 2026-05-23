import Foundation

struct WalkRoute: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var startPoint: String
    var endPoint: String
    var distance: Double
    var estimatedDuration: Int
    var neighborhoods: [Neighborhood]
    var description: String
    var isFavorite: Bool
}
