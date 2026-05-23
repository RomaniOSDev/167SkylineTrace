import SwiftUI

struct TemplateCell: View {
    let template: WalkTemplate

    var body: some View {
        HStack(spacing: 14) {
            SkylineIconBadge(icon: template.mood.icon, size: 44)

            VStack(alignment: .leading, spacing: 8) {
                Text(template.name)
                    .font(.headline)
                    .foregroundColor(.skylineText)

                Text(template.title)
                    .font(.subheadline)
                    .foregroundColor(.skylineMuted)
                    .lineLimit(1)

                HStack(spacing: 8) {
                    SkylineMetricPill(
                        icon: "map",
                        text: String(format: "%.1f km", template.distance),
                        highlighted: true
                    )
                    SkylineMetricPill(icon: "clock", text: "\(template.duration) min")
                    SkylineMetricPill(icon: template.mood.icon, text: template.mood.displayName)
                }
            }

            Spacer()

            Image(systemName: "plus.circle.fill")
                .font(.title2)
                .foregroundColor(.skylineAccent)
        }
        .skylineListCard()
    }
}
