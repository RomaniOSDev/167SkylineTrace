import SwiftUI

struct ActivityCalendarView: View {
    let days: [CalendarDay]

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 6), count: 7)
    private let weekdaySymbols = ["S", "M", "T", "W", "T", "F", "S"]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            SkylineSectionHeader(
                title: "Activity calendar",
                subtitle: "Last 35 days of night walks"
            )

            HStack {
                ForEach(weekdaySymbols, id: \.self) { symbol in
                    Text(symbol)
                        .font(.caption2.weight(.semibold))
                        .foregroundColor(.skylineMuted)
                        .frame(maxWidth: .infinity)
                }
            }

            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(days) { day in
                    VStack(spacing: 4) {
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(intensityColor(for: day.walkCount))
                            .frame(height: 32)
                            .overlay {
                                if day.walkCount > 0 {
                                    Text("\(day.walkCount)")
                                        .font(.caption2.weight(.bold))
                                        .foregroundColor(day.walkCount > 1 ? .white : .skylineAccent)
                                }
                            }
                        Text(shortLabel(for: day.id))
                            .font(.system(size: 9))
                            .foregroundColor(.skylineMuted)
                    }
                }
            }

            HStack(spacing: 12) {
                legendItem(color: Color.skylineAccent.opacity(0.1), label: "None")
                legendItem(color: Color.skylineAccent.opacity(0.35), label: "1")
                legendItem(color: Color.skylineAccent.opacity(0.6), label: "2+")
            }
            .font(.caption2)
            .foregroundColor(.skylineMuted)
        }
        .skylineCellCard(elevation: .card)
    }

    private func legendItem(color: Color, label: String) -> some View {
        HStack(spacing: 4) {
            RoundedRectangle(cornerRadius: 3)
                .fill(color)
                .frame(width: 12, height: 12)
            Text(label)
        }
    }

    private func intensityColor(for count: Int) -> Color {
        switch count {
        case 0: return Color.skylineAccent.opacity(0.08)
        case 1: return Color.skylineAccent.opacity(0.4)
        case 2: return Color.skylineAccent.opacity(0.65)
        default: return Color.skylineAccent
        }
    }

    private func shortLabel(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }
}
