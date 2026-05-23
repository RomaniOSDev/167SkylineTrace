import SwiftUI

struct WalkFilterSheet: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: SkylineTraceViewModel

    var body: some View {
        NavigationStack {
            ZStack {
                SkylineBackground()

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: SkylineLayout.sectionSpacing) {
                        Toggle(isOn: $viewModel.favoritesOnly) {
                            HStack(spacing: 12) {
                                SkylineIconBadge(icon: "star.fill", size: 36, filled: false)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Favorites only")
                                        .foregroundColor(.skylineText)
                                    Text("Show starred walks")
                                        .font(.caption)
                                        .foregroundColor(.skylineMuted)
                                }
                            }
                        }
                        .tint(.skylineAccent)
                        .skylineCellCard(elevation: .card)

                        moodSection
                        neighborhoodSection
                        weatherSection

                        SkylineSecondaryButton("Clear all filters", icon: "xmark") {
                            viewModel.clearFilters()
                        }
                    }
                    .skylineContentWidth()
                    .skylineScreenPadding()
                }
            }
            .navigationTitle("Filters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                        .foregroundColor(.skylineAccent)
                }
            }
        }
        .presentationBackground(Color.skylineBackground)
    }

    private var moodSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Mood")
                .font(.headline)
                .foregroundColor(.skylineText)
            FlowLayout(spacing: 8) {
                filterChip("Any", selected: viewModel.filterMood == nil) {
                    viewModel.filterMood = nil
                }
                ForEach(WalkMood.allCases, id: \.self) { mood in
                    filterChip(mood.displayName, icon: mood.icon, selected: viewModel.filterMood == mood) {
                        viewModel.filterMood = viewModel.filterMood == mood ? nil : mood
                    }
                }
            }
        }
        .skylineCellCard(elevation: .card)
    }

    private var neighborhoodSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Neighborhood")
                .font(.headline)
                .foregroundColor(.skylineText)
            FlowLayout(spacing: 8) {
                filterChip("Any", selected: viewModel.filterNeighborhood == nil) {
                    viewModel.filterNeighborhood = nil
                }
                ForEach(Neighborhood.allCases, id: \.self) { hood in
                    filterChip(hood.displayName, icon: hood.icon, selected: viewModel.filterNeighborhood == hood) {
                        viewModel.filterNeighborhood = viewModel.filterNeighborhood == hood ? nil : hood
                    }
                }
            }
        }
        .skylineCellCard(elevation: .card)
    }

    private var weatherSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Weather")
                .font(.headline)
                .foregroundColor(.skylineText)
            FlowLayout(spacing: 8) {
                filterChip("Any", selected: viewModel.filterWeather == nil) {
                    viewModel.filterWeather = nil
                }
                ForEach(WalkWeather.allCases, id: \.self) { weather in
                    filterChip(weather.displayName, icon: weather.icon, selected: viewModel.filterWeather == weather) {
                        viewModel.filterWeather = viewModel.filterWeather == weather ? nil : weather
                    }
                }
            }
        }
        .skylineCellCard(elevation: .card)
    }

    private func filterChip(_ title: String, icon: String? = nil, selected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 4) {
                if let icon {
                    Image(systemName: icon)
                        .font(.caption2)
                }
                Text(title)
                    .font(.caption.weight(.semibold))
            }
            .foregroundColor(selected ? Color.skylineBackground : .skylineText)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background {
                if selected {
                    Capsule().fill(Color.skylineAccentGradient)
                } else {
                    Capsule().fill(Color.white.opacity(0.06))
                }
            }
            .compositingGroup()
            .shadow(
                color: selected ? Color.skylineAccent.opacity(0.35) : .clear,
                radius: selected ? 4 : 0,
                y: selected ? 2 : 0
            )
        }
        .buttonStyle(.plain)
    }
}

/// Simple flow layout for filter chips (iOS 16+)
struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        arrange(proposal: proposal, subviews: subviews).size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = arrange(proposal: proposal, subviews: subviews)
        for (index, frame) in result.frames.enumerated() {
            subviews[index].place(
                at: CGPoint(x: bounds.minX + frame.minX, y: bounds.minY + frame.minY),
                proposal: .unspecified
            )
        }
    }

    private func arrange(proposal: ProposedViewSize, subviews: Subviews) -> (size: CGSize, frames: [CGRect]) {
        let maxWidth = proposal.width ?? UIScreen.main.bounds.width - 64
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0
        var frames: [CGRect] = []

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > maxWidth, x > 0 {
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }
            frames.append(CGRect(x: x, y: y, width: size.width, height: size.height))
            rowHeight = max(rowHeight, size.height)
            x += size.width + spacing
        }

        return (CGSize(width: maxWidth, height: y + rowHeight), frames)
    }
}
