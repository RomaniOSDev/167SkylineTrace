import Foundation

struct ReminderSettings: Codable, Equatable {
    var isEnabled: Bool
    var hour: Int
    var minute: Int
    var weekdayNumbers: [Int]

    var weekdays: Set<Int> {
        get { Set(weekdayNumbers) }
        set { weekdayNumbers = Array(newValue).sorted() }
    }

    static let `default` = ReminderSettings(
        isEnabled: false,
        hour: 20,
        minute: 0,
        weekdayNumbers: [2, 4, 6]
    )
}
