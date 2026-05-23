import Foundation

enum AchievementEvaluator {
    static func evaluate(
        walks: [NightWalk],
        unlocked: [AchievementRecord]
    ) -> [AchievementRecord] {
        var result = unlocked
        let unlockedTypes = Set(unlocked.map(\.type))

        func unlock(_ type: AchievementType) {
            guard !unlockedTypes.contains(type),
                  !result.contains(where: { $0.type == type }) else { return }
            result.append(AchievementRecord(id: UUID(), type: type, unlockedAt: Date()))
        }

        if walks.count >= 10 { unlock(.walks10) }
        if walks.count >= 50 { unlock(.walks50) }
        if walks.filter(\.isFavorite).count >= 5 { unlock(.favorites5) }
        if walks.compactMap(\.rating).count >= 5 { unlock(.ratedWalks5) }

        let photoWalks = walks.filter { ($0.imageNames?.isEmpty == false) }
        if photoWalks.count >= 5 { unlock(.photos5) }

        let neighborhoods = Set(walks.map(\.neighborhood))
        if neighborhoods.count >= 5 { unlock(.neighborhoods5) }

        let streak = currentStreak(walks: walks)
        if streak >= 3 { unlock(.streak3) }
        if streak >= 7 { unlock(.streak7) }

        if weeklyDistance(walks: walks) >= 10 { unlock(.distanceWeek10) }

        return result
    }

    private static func currentStreak(walks: [NightWalk]) -> Int {
        let calendar = Calendar.current
        var streak = 0
        var date = calendar.startOfDay(for: Date())

        while true {
            let hasWalk = walks.contains { calendar.isDate($0.date, inSameDayAs: date) }
            if hasWalk {
                streak += 1
                guard let previous = calendar.date(byAdding: .day, value: -1, to: date) else { break }
                date = previous
            } else {
                break
            }
        }
        return streak
    }

    private static func weeklyDistance(walks: [NightWalk]) -> Double {
        let calendar = Calendar.current
        guard let weekStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date())) else {
            return 0
        }
        let weekEnd = calendar.date(byAdding: .day, value: 7, to: weekStart) ?? Date()
        return walks
            .filter { $0.date >= weekStart && $0.date < weekEnd }
            .reduce(0) { $0 + $1.distance }
    }
}
