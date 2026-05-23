import Foundation

struct NightPhoto: Identifiable, Codable, Equatable {
    let id: UUID
    let walkId: UUID
    var imageName: String
    var caption: String?
    var location: String?
    let date: Date
}
