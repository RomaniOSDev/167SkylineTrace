import SwiftUI
import Charts

struct StatsView: View {
    @ObservedObject var viewModel: SkylineTraceViewModel
    @State private var showShareSheet = false
    @State private var shareItems: [Any] = []

    var body: some View {
        SkylineScreenScaffold {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: SkylineLayout.sectionSpacing) {
                    exportButtons

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        StatCard(title: "Walks", value: "\(viewModel.totalWalks)", icon: "figure.walk", color: .skylineAccent)
                        StatCard(title: "Kilometers", value: String(format: "%.1f", viewModel.totalDistance), icon: "map.fill", color: .skylineAccent)
                        StatCard(title: "Hours", value: "\(viewModel.totalHours)", icon: "clock.fill", color: .skylineAccent)
                        StatCard(title: "Avg rating", value: String(format: "%.1f", viewModel.averageRating), icon: "star.fill", color: .skylineAccent)
                    }

                    PeriodComparisonCard(comparison: viewModel.periodComparison)
                    bestWalkSection
                    ActivityCalendarView(days: viewModel.calendarDays)
                    activityChart
                    insightPanel(title: "Weather moods", subtitle: "Conditions during walks", stats: weatherRows)
                    insightPanel(title: "Neighborhoods", subtitle: "Where you walk most", stats: neighborhoodRows)
                    insightPanel(title: "Moods", subtitle: "How nights feel", stats: moodRows)
                }
                .skylineContentWidth()
                .skylineScreenPadding()
                .padding(.bottom, 24)
            }
        }
        .skylineScreen(title: "Statistics")
        .sheet(isPresented: $showShareSheet) {
            ShareSheet(items: shareItems)
        }
    }

    private var exportButtons: some View {
        HStack(spacing: 12) {
            SkylineSecondaryButton("Share report", icon: "square.and.arrow.up") {
                shareItems = [viewModel.exportTextReport()]
                showShareSheet = true
            }
            SkylineSecondaryButton("Export PDF", icon: "doc.richtext") {
                if let data = viewModel.exportPDFData() {
                    let url = FileManager.default.temporaryDirectory.appendingPathComponent("night-walks-report.pdf")
                    try? data.write(to: url)
                    shareItems = [url]
                    showShareSheet = true
                }
            }
        }
    }

    @ViewBuilder
    private var bestWalkSection: some View {
        SkylinePanel(title: "Best walk this month", subtitle: "Top rated night walk") {
            if let walk = viewModel.bestWalkThisMonth {
                NavigationLink {
                    WalkDetailView(viewModel: viewModel, walk: walk)
                } label: {
                    HStack(spacing: 14) {
                        SkylineIconBadge(icon: walk.mood.icon, size: 44)
                        VStack(alignment: .leading, spacing: 6) {
                            Text(walk.title)
                                .font(.subheadline.weight(.semibold))
                                .foregroundColor(.skylineText)
                            Text(walk.formattedDate)
                                .font(.caption)
                                .foregroundColor(.skylineMuted)
                            if let rating = walk.rating {
                                Text(String(repeating: "★", count: rating))
                                    .foregroundColor(.skylineAccent)
                            }
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.skylineAccent.opacity(0.6))
                    }
                }
                .buttonStyle(.plain)
            } else {
                Text("No walks logged this month yet.")
                    .font(.caption)
                    .foregroundColor(.skylineMuted)
            }
        }
    }

    private var activityChart: some View {
        SkylinePanel(title: "Weekly activity", subtitle: "Walks per week") {
            if viewModel.walks.isEmpty {
                Text("Log walks to see your activity chart.")
                    .font(.caption)
                    .foregroundColor(.skylineMuted)
            } else {
                Chart(viewModel.weeklyActivity) { data in
                    BarMark(
                        x: .value("Week", data.week),
                        y: .value("Walks", data.count)
                    )
                    .foregroundStyle(Color.skylineAccentGradient)
                    .cornerRadius(6)
                }
                .frame(height: 160)
                .chartXAxis {
                    AxisMarks { _ in
                        AxisValueLabel()
                            .foregroundStyle(Color.skylineMuted)
                    }
                }
                .chartYAxis {
                    AxisMarks { _ in
                        AxisGridLine().foregroundStyle(Color.skylineAccent.opacity(0.15))
                        AxisValueLabel().foregroundStyle(Color.skylineMuted)
                    }
                }
            }
        }
    }

    private var weatherRows: [(icon: String, name: String, count: Int)] {
        viewModel.weatherStats.map { ($0.icon, $0.name, $0.count) }
    }

    private var neighborhoodRows: [(icon: String, name: String, count: Int)] {
        viewModel.neighborhoodStats.map { ($0.icon, $0.name, $0.count) }
    }

    private var moodRows: [(icon: String, name: String, count: Int)] {
        viewModel.moodStats.map { ($0.icon, $0.name, $0.count) }
    }

    @ViewBuilder
    private func insightPanel(title: String, subtitle: String, stats: [(icon: String, name: String, count: Int)]) -> some View {
        SkylinePanel(title: title, subtitle: subtitle) {
            if stats.isEmpty {
                Text("No data yet.")
                    .font(.caption)
                    .foregroundColor(.skylineMuted)
            } else {
                ForEach(Array(stats.enumerated()), id: \.offset) { index, stat in
                    SkylineInsightRow(
                        icon: stat.icon,
                        title: stat.name,
                        value: "\(stat.count)",
                        rank: index + 1
                    )
                    if index < stats.count - 1 {
                        Divider().background(Color.white.opacity(0.08))
                    }
                }
            }
        }
    }
}
