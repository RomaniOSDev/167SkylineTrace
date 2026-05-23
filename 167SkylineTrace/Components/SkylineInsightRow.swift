import SwiftUI

struct SkylineInsightRow: View {
    let icon: String
    let title: String
    let value: String
    var rank: Int?

    var body: some View {
        HStack(spacing: 14) {
            if let rank {
                Text("\(rank)")
                    .font(.caption.weight(.bold))
                    .foregroundColor(.skylineBackground)
                    .frame(width: 22, height: 22)
                    .background(Circle().fill(Color.skylineAccentGradient))
            }

            SkylineIconBadge(icon: icon, size: 36, filled: false)

            Text(title)
                .font(.subheadline)
                .foregroundColor(.skylineText)

            Spacer()

            Text(value)
                .font(.subheadline.weight(.bold))
                .foregroundColor(.skylineAccent)
        }
        .padding(.vertical, 6)
    }
}

struct SkylinePanel<Content: View>: View {
    let title: String
    var subtitle: String?
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            SkylineSectionHeader(title: title, subtitle: subtitle)
            content
        }
        .skylineCellCard(elevation: .card)
    }
}
