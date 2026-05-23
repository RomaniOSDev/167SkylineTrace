import SwiftUI

struct RouteCard: View {
    let route: WalkRoute

    var body: some View {
        HStack(spacing: 14) {
            routePathIndicator

            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text(route.name)
                        .font(.headline)
                        .foregroundColor(.skylineText)
                    Spacer()
                    if route.isFavorite {
                        Image(systemName: "star.fill")
                            .foregroundColor(.skylineAccent)
                            .font(.subheadline)
                    }
                }

                HStack(spacing: 8) {
                    SkylineMetricPill(icon: "map", text: String(format: "%.1f km", route.distance), highlighted: true)
                    SkylineMetricPill(icon: "clock", text: "\(route.estimatedDuration) min")
                }

                VStack(alignment: .leading, spacing: 6) {
                    routePointRow(icon: "circle.fill", color: .skylineAccent, text: route.startPoint)
                    routePointRow(icon: "mappin.circle.fill", color: .skylineAccent.opacity(0.7), text: route.endPoint)
                }

                if !route.neighborhoods.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 6) {
                            ForEach(route.neighborhoods, id: \.self) { hood in
                                SkylineChip(text: hood.displayName, icon: hood.icon)
                            }
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .skylineListCard(glow: route.isFavorite)
        .overlay(alignment: .trailing) {
            Image(systemName: "chevron.right")
                .font(.caption.weight(.bold))
                .foregroundColor(.skylineAccent.opacity(0.5))
                .padding(.trailing, 14)
        }
    }

    private var routePathIndicator: some View {
        VStack(spacing: 0) {
            Circle()
                .fill(Color.skylineAccent)
                .frame(width: 10, height: 10)
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [.skylineAccent, .skylineAccent.opacity(0.2)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 2)
                .frame(maxHeight: .infinity)
            Circle()
                .stroke(Color.skylineAccent, lineWidth: 2)
                .frame(width: 10, height: 10)
        }
        .frame(width: 16)
        .padding(.vertical, 4)
    }

    private func routePointRow(icon: String, color: Color, text: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.caption2)
                .foregroundColor(color)
            Text(text)
                .font(.caption)
                .foregroundColor(.skylineText.opacity(0.9))
                .lineLimit(1)
        }
    }
}
