import Foundation

struct NightWalk: Identifiable, Codable, Equatable {
    let id: UUID
    let date: Date
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
    var rating: Int?
    var isFavorite: Bool
    let createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id, date, title, routeId, routeName, distance, duration
        case mood, difficulty, neighborhood, weather, description
        case highlights, tags, imageNames, rating, isFavorite, createdAt
    }

    init(
        id: UUID,
        date: Date,
        title: String,
        routeId: UUID? = nil,
        routeName: String? = nil,
        distance: Double,
        duration: Int,
        mood: WalkMood,
        difficulty: WalkDifficulty,
        neighborhood: Neighborhood,
        weather: WalkWeather? = nil,
        description: String,
        highlights: [String],
        tags: [String],
        imageNames: [String]?,
        rating: Int?,
        isFavorite: Bool,
        createdAt: Date
    ) {
        self.id = id
        self.date = date
        self.title = title
        self.routeId = routeId
        self.routeName = routeName
        self.distance = distance
        self.duration = duration
        self.mood = mood
        self.difficulty = difficulty
        self.neighborhood = neighborhood
        self.weather = weather
        self.description = description
        self.highlights = highlights
        self.tags = tags
        self.imageNames = imageNames
        self.rating = rating
        self.isFavorite = isFavorite
        self.createdAt = createdAt
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        date = try container.decode(Date.self, forKey: .date)
        title = try container.decode(String.self, forKey: .title)
        routeId = try container.decodeIfPresent(UUID.self, forKey: .routeId)
        routeName = try container.decodeIfPresent(String.self, forKey: .routeName)
        distance = try container.decode(Double.self, forKey: .distance)
        duration = try container.decode(Int.self, forKey: .duration)
        mood = try container.decode(WalkMood.self, forKey: .mood)
        difficulty = try container.decode(WalkDifficulty.self, forKey: .difficulty)
        neighborhood = try container.decode(Neighborhood.self, forKey: .neighborhood)
        weather = try container.decodeIfPresent(WalkWeather.self, forKey: .weather)
        description = try container.decode(String.self, forKey: .description)
        highlights = try container.decode([String].self, forKey: .highlights)
        tags = try container.decode([String].self, forKey: .tags)
        imageNames = try container.decodeIfPresent([String].self, forKey: .imageNames)
        rating = try container.decodeIfPresent(Int.self, forKey: .rating)
        isFavorite = try container.decode(Bool.self, forKey: .isFavorite)
        createdAt = try container.decode(Date.self, forKey: .createdAt)
    }

    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMMM yyyy, HH:mm"
        formatter.locale = Locale(identifier: "en_US")
        return formatter.string(from: date)
    }

    var formattedDuration: String {
        let hours = duration / 60
        let minutes = duration % 60
        if hours > 0 {
            return "\(hours) h \(minutes) min"
        }
        return "\(minutes) min"
    }

    var preview: String {
        if description.count > 100 {
            return String(description.prefix(100)) + "..."
        }
        return description
    }
}
