import SwiftUI

struct WalkCard: View {
    let walk: NightWalk

    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            RoundedRectangle(cornerRadius: 3, style: .continuous)
                .fill(Color.skylineAccentGradient)
                .frame(width: 4)
                .padding(.vertical, 4)

            VStack(alignment: .leading, spacing: 14) {
                headerRow
                Text(walk.preview)
                    .font(.subheadline)
                    .foregroundColor(.skylineText.opacity(0.85))
                    .lineLimit(2)
                    .lineSpacing(3)

                metricsRow

                if !walk.highlights.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(walk.highlights, id: \.self) { highlight in
                                SkylineChip(text: highlight, icon: "mappin")
                            }
                        }
                    }
                }

                if !walk.tags.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 6) {
                            ForEach(walk.tags.prefix(4), id: \.self) { tag in
                                Text("#\(tag)")
                                    .font(.caption2)
                                    .foregroundColor(.skylineMuted)
                            }
                        }
                    }
                }
            }
            .padding(.leading, 12)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .skylineListCard(glow: walk.isFavorite)
        .overlay(alignment: .topTrailing) {
            Image(systemName: "chevron.right")
                .font(.caption.weight(.bold))
                .foregroundColor(.skylineAccent.opacity(0.6))
                .padding(14)
        }
    }

    private var headerRow: some View {
        HStack(alignment: .top, spacing: 12) {
            SkylineIconBadge(icon: walk.mood.icon, size: 48)

            VStack(alignment: .leading, spacing: 4) {
                Text(walk.title)
                    .font(.headline)
                    .foregroundColor(.skylineText)
                    .lineLimit(2)

                Text(walk.formattedDate)
                    .font(.caption)
                    .foregroundColor(.skylineMuted)
            }

            Spacer(minLength: 20)

            VStack(alignment: .trailing, spacing: 6) {
                if walk.isFavorite {
                    Image(systemName: "star.fill")
                        .foregroundColor(.skylineAccent)
                        .font(.subheadline)
                }
                if let rating = walk.rating {
                    HStack(spacing: 2) {
                        ForEach(1...5, id: \.self) { index in
                            Image(systemName: index <= rating ? "star.fill" : "star")
                                .font(.system(size: 9))
                                .foregroundColor(.skylineAccent)
                        }
                    }
                }
            }
        }
    }

    private var metricsRow: some View {
        HStack(spacing: 8) {
            SkylineMetricPill(icon: "clock", text: walk.formattedDuration)
            SkylineMetricPill(icon: "map", text: String(format: "%.1f km", walk.distance), highlighted: true)
            if let weather = walk.weather {
                SkylineMetricPill(icon: weather.icon, text: weather.displayName, highlighted: true)
            }
            SkylineMetricPill(icon: walk.neighborhood.icon, text: walk.neighborhood.displayName)
        }
    }
}
