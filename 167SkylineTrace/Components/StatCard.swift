import SwiftUI

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                SkylineIconBadge(icon: icon, size: 36, filled: false)
                Spacer()
            }

            Text(value)
                .font(.system(size: 26, weight: .bold, design: .rounded))
                .foregroundColor(.skylineText)
                .minimumScaleFactor(0.7)
                .lineLimit(1)

            Text(title)
                .font(.caption.weight(.medium))
                .foregroundColor(.skylineMuted)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .skylineCellCard(accent: color, elevation: .card)
    }
}
