import SwiftUI

struct PeriodComparisonCard: View {
    let comparison: PeriodComparison

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            SkylineSectionHeader(
                title: "This month vs last",
                subtitle: "Walk activity comparison"
            )

            HStack(spacing: 12) {
                comparisonTile(
                    title: "Walks",
                    value: "\(comparison.current.walks)",
                    delta: comparison.walksDelta,
                    icon: "figure.walk"
                )
                comparisonTile(
                    title: "Distance",
                    value: String(format: "%.1f", comparison.current.distance),
                    delta: Int(comparison.distanceDelta.rounded()),
                    icon: "map",
                    isDistance: true
                )
                comparisonTile(
                    title: "Hours",
                    value: "\(comparison.current.hours)",
                    delta: comparison.hoursDelta,
                    icon: "clock"
                )
            }
        }
        .skylineCellCard(glow: true, elevation: .raised)
    }

    private func comparisonTile(title: String, value: String, delta: Int, icon: String, isDistance: Bool = false) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(.skylineAccent)
            Text(value)
                .font(.title3.weight(.bold))
                .foregroundColor(.skylineText)
                .minimumScaleFactor(0.7)
                .lineLimit(1)
            Text(title)
                .font(.caption2)
                .foregroundColor(.skylineMuted)
            Text(isDistance ? String(format: "%+.1f", Double(delta)) : String(format: "%+d", delta))
                .font(.caption2.weight(.bold))
                .foregroundColor(delta >= 0 ? .skylineAccent : .orange)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.white.opacity(0.04))
        )
    }
}
