import Foundation
import Combine

final class SkylineTraceViewModel: ObservableObject {
    @Published var walks: [NightWalk] = []
    @Published var routes: [WalkRoute] = []
    @Published var goals: [WalkGoal] = []
    @Published var templates: [WalkTemplate] = []
    @Published var achievements: [AchievementRecord] = []
    @Published var reminderSettings: ReminderSettings = .default

    @Published var searchText = ""
    @Published var favoritesOnly = false
    @Published var filterMood: WalkMood?
    @Published var filterNeighborhood: Neighborhood?
    @Published var filterWeather: WalkWeather?
    @Published var sortOption: WalkSortOption = .dateDescending
    @Published var currentQuote: String = NightQuoteProvider.randomQuote()

    var hasActiveFilters: Bool {
        favoritesOnly || filterMood != nil || filterNeighborhood != nil || filterWeather != nil
    }

    var totalWalks: Int { walks.count }

    var totalDistance: Double {
        walks.reduce(0) { $0 + $1.distance }
    }

    var totalDuration: Int {
        walks.reduce(0) { $0 + $1.duration }
    }

    var totalHours: Int { totalDuration / 60 }

    var averageRating: Double {
        let ratedWalks = walks.compactMap(\.rating)
        guard !ratedWalks.isEmpty else { return 0 }
        return Double(ratedWalks.reduce(0, +)) / Double(ratedWalks.count)
    }

    var streakDays: Int {
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

    var displayedWalks: [NightWalk] {
        var result = walks

        if favoritesOnly {
            result = result.filter(\.isFavorite)
        }
        if let filterMood {
            result = result.filter { $0.mood == filterMood }
        }
        if let filterNeighborhood {
            result = result.filter { $0.neighborhood == filterNeighborhood }
        }
        if let filterWeather {
            result = result.filter { $0.weather == filterWeather }
        }
        if !searchText.trimmingCharacters(in: .whitespaces).isEmpty {
            let query = searchText.lowercased()
            result = result.filter { walk in
                walk.title.lowercased().contains(query)
                    || walk.description.lowercased().contains(query)
                    || (walk.routeName?.lowercased().contains(query) ?? false)
                    || walk.tags.contains { $0.lowercased().contains(query) }
                    || walk.highlights.contains { $0.lowercased().contains(query) }
            }
        }

        switch sortOption {
        case .dateDescending:
            result.sort { $0.date > $1.date }
        case .dateAscending:
            result.sort { $0.date < $1.date }
        case .distanceDescending:
            result.sort { $0.distance > $1.distance }
        case .distanceAscending:
            result.sort { $0.distance < $1.distance }
        case .durationDescending:
            result.sort { $0.duration > $1.duration }
        case .ratingDescending:
            result.sort { ($0.rating ?? 0) > ($1.rating ?? 0) }
        }

        return result
    }

    var sortedWalks: [NightWalk] {
        walks.sorted { $0.date > $1.date }
    }

    var galleryPhotos: [GalleryPhotoItem] {
        walks.flatMap { walk in
            (walk.imageNames ?? []).map { image in
                GalleryPhotoItem(
                    walkId: walk.id,
                    walkTitle: walk.title,
                    imageName: image,
                    date: walk.date
                )
            }
        }
        .sorted { $0.date > $1.date }
    }

    var periodComparison: PeriodComparison {
        let calendar = Calendar.current
        let now = Date()
        let currentStart = calendar.date(from: calendar.dateComponents([.year, .month], from: now))!
        let previousStart = calendar.date(byAdding: .month, value: -1, to: currentStart)!
        let previousEnd = currentStart

        return PeriodComparison(
            current: summary(for: walks, from: currentStart, to: now),
            previous: summary(for: walks, from: previousStart, to: previousEnd)
        )
    }

    var bestWalkThisMonth: NightWalk? {
        let calendar = Calendar.current
        let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: Date()))!
        let monthWalks = walks.filter { $0.date >= monthStart }
        return monthWalks.max { lhs, rhs in
            let leftScore = (lhs.rating ?? 0) * 10 + (lhs.isFavorite ? 5 : 0)
            let rightScore = (rhs.rating ?? 0) * 10 + (rhs.isFavorite ? 5 : 0)
            if leftScore == rightScore { return lhs.date < rhs.date }
            return leftScore < rightScore
        }
    }

    var calendarDays: [CalendarDay] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        return (0..<35).compactMap { offset -> CalendarDay? in
            guard let day = calendar.date(byAdding: .day, value: -offset, to: today) else { return nil }
            let dayWalks = walks.filter { calendar.isDate($0.date, inSameDayAs: day) }
            return CalendarDay(
                id: day,
                walkCount: dayWalks.count,
                totalDistance: dayWalks.reduce(0) { $0 + $1.distance }
            )
        }
        .reversed()
    }

    struct WeeklyActivity: Identifiable {
        let id = UUID()
        let week: String
        let count: Int
    }

    var weeklyActivity: [WeeklyActivity] {
        let calendar = Calendar.current
        let today = Date()
        let weekDates = (0..<8).compactMap { calendar.date(byAdding: .day, value: -$0 * 7, to: today) }.reversed()
        return weekDates.map { date in
            let weekStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date))!
            let weekEnd = calendar.date(byAdding: .day, value: 7, to: weekStart)!
            let count = walks.filter { $0.date >= weekStart && $0.date < weekEnd }.count
            let formatter = DateFormatter()
            formatter.dateFormat = "dd.MM"
            formatter.locale = Locale(identifier: "en_US")
            return WeeklyActivity(
                week: "\(formatter.string(from: weekStart))-\(formatter.string(from: weekEnd))",
                count: count
            )
        }
    }

    struct NeighborhoodStat: Identifiable {
        let id = UUID()
        let name: String
        let icon: String
        let count: Int
    }

    var neighborhoodStats: [NeighborhoodStat] {
        Dictionary(grouping: walks, by: \.neighborhood)
            .map { neighborhood, walks in
                NeighborhoodStat(name: neighborhood.displayName, icon: neighborhood.icon, count: walks.count)
            }
            .sorted { $0.count > $1.count }
    }

    struct MoodStat: Identifiable {
        let id = UUID()
        let name: String
        let icon: String
        let count: Int
    }

    var moodStats: [MoodStat] {
        Dictionary(grouping: walks, by: \.mood)
            .map { mood, walks in
                MoodStat(name: mood.displayName, icon: mood.icon, count: walks.count)
            }
            .sorted { $0.count > $1.count }
    }

    struct WeatherStat: Identifiable {
        let id = UUID()
        let name: String
        let icon: String
        let count: Int
    }

    var weatherStats: [WeatherStat] {
        Dictionary(grouping: walks.compactMap(\.weather), by: { $0 })
            .map { weather, items in
                WeatherStat(name: weather.displayName, icon: weather.icon, count: items.count)
            }
            .sorted { $0.count > $1.count }
    }

    var unlockedAchievements: [AchievementRecord] {
        achievements.sorted { $0.unlockedAt > $1.unlockedAt }
    }

    var lockedAchievementTypes: [AchievementType] {
        let unlocked = Set(achievements.map(\.type))
        return AchievementType.allCases.filter { !unlocked.contains($0) }
    }

    // MARK: - Walks

    func addWalk(_ walk: NightWalk) {
        walks.append(walk)
        updateManualGoals(with: walk)
        refreshDerivedState()
        saveToUserDefaults()
    }

    func updateWalk(_ walk: NightWalk) {
        if let index = walks.firstIndex(where: { $0.id == walk.id }) {
            walks[index] = walk
            refreshDerivedState()
            saveToUserDefaults()
        }
    }

    func deleteWalk(_ walk: NightWalk) {
        walks.removeAll { $0.id == walk.id }
        refreshDerivedState()
        saveToUserDefaults()
    }

    func toggleFavorite(_ walk: NightWalk) {
        if let index = walks.firstIndex(where: { $0.id == walk.id }) {
            walks[index].isFavorite.toggle()
            refreshDerivedState()
            saveToUserDefaults()
        }
    }

    func clearFilters() {
        favoritesOnly = false
        filterMood = nil
        filterNeighborhood = nil
        filterWeather = nil
        searchText = ""
    }

    func refreshQuote() {
        currentQuote = NightQuoteProvider.randomQuote()
    }

    // MARK: - Templates

    func saveTemplate(from walk: NightWalk, name: String) {
        let template = WalkTemplate(
            id: UUID(),
            name: name,
            title: walk.title,
            routeId: walk.routeId,
            routeName: walk.routeName,
            distance: walk.distance,
            duration: walk.duration,
            mood: walk.mood,
            difficulty: walk.difficulty,
            neighborhood: walk.neighborhood,
            weather: walk.weather,
            description: walk.description,
            highlights: walk.highlights,
            tags: walk.tags,
            imageNames: walk.imageNames,
            createdAt: Date()
        )
        templates.append(template)
        saveToUserDefaults()
    }

    func deleteTemplate(_ template: WalkTemplate) {
        templates.removeAll { $0.id == template.id }
        saveToUserDefaults()
    }

    func walk(from template: WalkTemplate) -> NightWalk {
        NightWalk(
            id: UUID(),
            date: Date(),
            title: template.title,
            routeId: template.routeId,
            routeName: template.routeName,
            distance: template.distance,
            duration: template.duration,
            mood: template.mood,
            difficulty: template.difficulty,
            neighborhood: template.neighborhood,
            weather: template.weather,
            description: template.description,
            highlights: template.highlights,
            tags: template.tags,
            imageNames: template.imageNames,
            rating: nil,
            isFavorite: false,
            createdAt: Date()
        )
    }

    // MARK: - Routes

    func addRoute(_ route: WalkRoute) {
        routes.append(route)
        saveToUserDefaults()
    }

    func updateRoute(_ route: WalkRoute) {
        if let index = routes.firstIndex(where: { $0.id == route.id }) {
            routes[index] = route
            saveToUserDefaults()
        }
    }

    func deleteRoute(_ route: WalkRoute) {
        routes.removeAll { $0.id == route.id }
        saveToUserDefaults()
    }

    func toggleFavoriteRoute(_ route: WalkRoute) {
        if let index = routes.firstIndex(where: { $0.id == route.id }) {
            routes[index].isFavorite.toggle()
            saveToUserDefaults()
        }
    }

    func routeName(for id: UUID?) -> String? {
        guard let id else { return nil }
        return routes.first(where: { $0.id == id })?.name
    }

    // MARK: - Goals

    func addGoal(_ goal: WalkGoal) {
        goals.append(goal)
        refreshAutoGoals()
        saveToUserDefaults()
    }

    func deleteGoal(_ goal: WalkGoal) {
        goals.removeAll { $0.id == goal.id }
        saveToUserDefaults()
    }

    func completeGoal(_ goal: WalkGoal) {
        if let index = goals.firstIndex(where: { $0.id == goal.id }) {
            goals[index].isCompleted = true
            saveToUserDefaults()
        }
    }

    func addAutoGoal(kind: GoalKind, targetWalks: Int, targetDistance: Double) {
        let title: String
        let periodStart: Date
        let calendar = Calendar.current
        let now = Date()

        switch kind {
        case .monthlyWalks:
            title = "\(targetWalks) walks this month"
            periodStart = calendar.date(from: calendar.dateComponents([.year, .month], from: now))!
        case .monthlyDistance:
            title = String(format: "%.0f km this month", targetDistance)
            periodStart = calendar.date(from: calendar.dateComponents([.year, .month], from: now))!
        case .weeklyDistance:
            title = String(format: "%.0f km this week", targetDistance)
            periodStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now))!
        case .manual:
            return
        }

        let goal = WalkGoal(
            id: UUID(),
            title: title,
            kind: kind,
            targetWalks: targetWalks,
            currentWalks: 0,
            targetDistance: targetDistance,
            currentDistance: 0,
            deadline: nil,
            periodStart: periodStart,
            isCompleted: false,
            createdAt: Date()
        )
        goals.append(goal)
        refreshAutoGoals()
        saveToUserDefaults()
    }

    // MARK: - Reminders

    func updateReminders(_ settings: ReminderSettings) {
        reminderSettings = settings
        WalkNotificationService.scheduleReminders(settings: settings)
        saveToUserDefaults()
    }

    // MARK: - Export

    func exportTextReport() -> String {
        WalkExportService.makeTextReport(
            walks: walks,
            routes: routes,
            goals: goals,
            achievements: achievements,
            comparison: periodComparison,
            bestWalk: bestWalkThisMonth
        )
    }

    func exportPDFData() -> Data? {
        WalkExportService.makePDFData(report: exportTextReport())
    }

    // MARK: - Private

    private func refreshDerivedState() {
        refreshAutoGoals()
        achievements = AchievementEvaluator.evaluate(walks: walks, unlocked: achievements)
    }

    private func refreshAutoGoals() {
        let calendar = Calendar.current
        let now = Date()

        for index in goals.indices {
            guard goals[index].isAutoGoal, let periodStart = goals[index].periodStart else { continue }

            let periodEnd: Date
            switch goals[index].kind {
            case .weeklyDistance:
                periodEnd = calendar.date(byAdding: .day, value: 7, to: periodStart) ?? now
            case .monthlyWalks, .monthlyDistance:
                periodEnd = calendar.date(byAdding: .month, value: 1, to: periodStart) ?? now
            case .manual:
                continue
            }

            let periodWalks = walks.filter { $0.date >= periodStart && $0.date < periodEnd }
            goals[index].currentWalks = periodWalks.count
            goals[index].currentDistance = periodWalks.reduce(0) { $0 + $1.distance }

            let walksDone = goals[index].targetWalks == 0 || goals[index].currentWalks >= goals[index].targetWalks
            let distanceDone = goals[index].targetDistance == 0 || goals[index].currentDistance >= goals[index].targetDistance
            goals[index].isCompleted = walksDone && distanceDone
        }

    }

    private func updateManualGoals(with walk: NightWalk) {
        for index in goals.indices where !goals[index].isAutoGoal && !goals[index].isCompleted {
            goals[index].currentWalks += 1
            goals[index].currentDistance += walk.distance
            let walksDone = goals[index].currentWalks >= goals[index].targetWalks
            let distanceDone = goals[index].currentDistance >= goals[index].targetDistance
            if walksDone && distanceDone {
                goals[index].isCompleted = true
            }
        }
    }

    private func summary(for walks: [NightWalk], from start: Date, to end: Date) -> PeriodSummary {
        let filtered = walks.filter { $0.date >= start && $0.date < end }
        let duration = filtered.reduce(0) { $0 + $1.duration }
        return PeriodSummary(
            walks: filtered.count,
            distance: filtered.reduce(0) { $0 + $1.distance },
            hours: duration / 60
        )
    }

    private let walksKey = "skylinetrace_walks"
    private let routesKey = "skylinetrace_routes"
    private let goalsKey = "skylinetrace_goals"
    private let templatesKey = "skylinetrace_templates"
    private let achievementsKey = "skylinetrace_achievements"
    private let remindersKey = "skylinetrace_reminders"

    func saveToUserDefaults() {
        encode(walks, key: walksKey)
        encode(routes, key: routesKey)
        encode(goals, key: goalsKey)
        encode(templates, key: templatesKey)
        encode(achievements, key: achievementsKey)
        encode(reminderSettings, key: remindersKey)
    }

    func loadFromUserDefaults() {
        walks = decode([NightWalk].self, key: walksKey) ?? []
        routes = decode([WalkRoute].self, key: routesKey) ?? []
        goals = decode([WalkGoal].self, key: goalsKey) ?? []
        templates = decode([WalkTemplate].self, key: templatesKey) ?? []
        achievements = decode([AchievementRecord].self, key: achievementsKey) ?? []
        reminderSettings = decode(ReminderSettings.self, key: remindersKey) ?? .default

        if walks.isEmpty {
            loadDemoData()
        } else {
            refreshDerivedState()
            WalkNotificationService.scheduleReminders(settings: reminderSettings)
        }
        refreshQuote()
    }

    private func encode<T: Encodable>(_ value: T, key: String) {
        if let encoded = try? JSONEncoder().encode(value) {
            UserDefaults.standard.set(encoded, forKey: key)
        }
    }

    private func decode<T: Decodable>(_ type: T.Type, key: String) -> T? {
        guard let data = UserDefaults.standard.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(type, from: data)
    }

    private func loadDemoData() {
        let routeId = UUID()
        let route = WalkRoute(
            id: routeId,
            name: "Central route",
            startPoint: "Main Square",
            endPoint: "Victory Park",
            distance: 4.5,
            estimatedDuration: 60,
            neighborhoods: [.downtown, .park],
            description: "A classic route through the city center",
            isFavorite: true
        )
        routes = [route]

        walks = [
            NightWalk(
                id: UUID(),
                date: Date().addingTimeInterval(-86400 * 2),
                title: "Night promenade along the waterfront",
                routeId: routeId,
                routeName: route.name,
                distance: 5.2,
                duration: 75,
                mood: .peaceful,
                difficulty: .easy,
                neighborhood: .waterfront,
                weather: .clear,
                description: "A beautiful walk along the river. City lights reflected in the water, creating a magical atmosphere.",
                highlights: ["Observation deck", "Fountain", "Monument"],
                tags: ["waterfront", "night", "romance"],
                imageNames: ["waterfront_lights", "river_reflection"],
                rating: 5,
                isFavorite: true,
                createdAt: Date()
            ),
            NightWalk(
                id: UUID(),
                date: Date().addingTimeInterval(-86400),
                title: "Downtown neon loop",
                routeId: nil,
                routeName: "Central route",
                distance: 3.8,
                duration: 55,
                mood: .energetic,
                difficulty: .moderate,
                neighborhood: .downtown,
                weather: .cloudy,
                description: "Busy avenues, glowing storefronts, and quiet side streets.",
                highlights: ["Main Square", "Glass bridge"],
                tags: ["downtown", "neon"],
                imageNames: ["downtown_neon", "city_crosswalk"],
                rating: 4,
                isFavorite: false,
                createdAt: Date()
            ),
            NightWalk(
                id: UUID(),
                date: Date().addingTimeInterval(-3600 * 8),
                title: "Park paths under moonlight",
                routeId: nil,
                routeName: nil,
                distance: 2.4,
                duration: 40,
                mood: .reflective,
                difficulty: .easy,
                neighborhood: .park,
                weather: .foggy,
                description: "Mist between the trees. Soft lamps along the trail.",
                highlights: ["Old oak alley"],
                tags: ["park", "quiet"],
                imageNames: ["park_moonlight"],
                rating: 5,
                isFavorite: true,
                createdAt: Date()
            )
        ]

        goals = [
            WalkGoal(
                id: UUID(),
                title: "10 night walks",
                kind: .manual,
                targetWalks: 10,
                currentWalks: 3,
                targetDistance: 50,
                currentDistance: 11.4,
                deadline: Date().addingTimeInterval(86400 * 30),
                periodStart: nil,
                isCompleted: false,
                createdAt: Date()
            ),
            WalkGoal(
                id: UUID(),
                title: "5 walks this month",
                kind: .monthlyWalks,
                targetWalks: 5,
                currentWalks: 3,
                targetDistance: 0,
                currentDistance: 0,
                deadline: nil,
                periodStart: Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: Date())),
                isCompleted: false,
                createdAt: Date()
            )
        ]

        refreshDerivedState()
        saveToUserDefaults()
    }
}
