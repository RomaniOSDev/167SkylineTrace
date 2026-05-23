import Foundation

struct WalkGoal: Identifiable, Codable, Equatable {
    let id: UUID
    var title: String
    var kind: GoalKind
    var targetWalks: Int
    var currentWalks: Int
    var targetDistance: Double
    var currentDistance: Double
    var deadline: Date?
    var periodStart: Date?
    var isCompleted: Bool
    let createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id, title, kind, targetWalks, currentWalks
        case targetDistance, currentDistance, deadline, periodStart
        case isCompleted, createdAt
    }

    init(
        id: UUID,
        title: String,
        kind: GoalKind = .manual,
        targetWalks: Int,
        currentWalks: Int,
        targetDistance: Double,
        currentDistance: Double,
        deadline: Date? = nil,
        periodStart: Date? = nil,
        isCompleted: Bool,
        createdAt: Date
    ) {
        self.id = id
        self.title = title
        self.kind = kind
        self.targetWalks = targetWalks
        self.currentWalks = currentWalks
        self.targetDistance = targetDistance
        self.currentDistance = currentDistance
        self.deadline = deadline
        self.periodStart = periodStart
        self.isCompleted = isCompleted
        self.createdAt = createdAt
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        kind = try container.decodeIfPresent(GoalKind.self, forKey: .kind) ?? .manual
        targetWalks = try container.decode(Int.self, forKey: .targetWalks)
        currentWalks = try container.decode(Int.self, forKey: .currentWalks)
        targetDistance = try container.decode(Double.self, forKey: .targetDistance)
        currentDistance = try container.decode(Double.self, forKey: .currentDistance)
        deadline = try container.decodeIfPresent(Date.self, forKey: .deadline)
        periodStart = try container.decodeIfPresent(Date.self, forKey: .periodStart)
        isCompleted = try container.decode(Bool.self, forKey: .isCompleted)
        createdAt = try container.decode(Date.self, forKey: .createdAt)
    }

    var walksProgress: Double {
        guard targetWalks > 0 else { return 0 }
        return min(Double(currentWalks) / Double(targetWalks), 1.0)
    }

    var distanceProgress: Double {
        guard targetDistance > 0 else { return 0 }
        return min(currentDistance / targetDistance, 1.0)
    }

    var isAutoGoal: Bool {
        kind != .manual
    }
}
