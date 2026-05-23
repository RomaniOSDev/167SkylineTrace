import Foundation

struct PeriodSummary: Equatable {
    let walks: Int
    let distance: Double
    let hours: Int

    static let empty = PeriodSummary(walks: 0, distance: 0, hours: 0)
}

struct PeriodComparison: Equatable {
    let current: PeriodSummary
    let previous: PeriodSummary

    var walksDelta: Int { current.walks - previous.walks }
    var distanceDelta: Double { current.distance - previous.distance }
    var hoursDelta: Int { current.hours - previous.hours }
}

struct CalendarDay: Identifiable, Equatable {
    let id: Date
    let walkCount: Int
    let totalDistance: Double
}

struct GalleryPhotoItem: Identifiable, Equatable {
    let walkId: UUID
    let walkTitle: String
    let imageName: String
    let date: Date

    var id: String { "\(walkId.uuidString)-\(imageName)" }
}
