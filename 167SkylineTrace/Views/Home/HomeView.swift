import SwiftUI

struct HomeView: View {
    @ObservedObject var viewModel: SkylineTraceViewModel
    @Binding var selectedTab: Int

    @State private var heroIndex = 0
    @State private var showAddWalk = false
    @State private var showTemplates = false
    @State private var showReminders = false

    private let widgetColumns = [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)]

    var body: some View {
        SkylineScreenScaffold {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: SkylineLayout.sectionSpacing) {
                    greetingHeader
                    heroCarousel
                    quickActionsWidget
                    statsWidgetGrid
                    photoMemoriesSection
                    recentWalksSection
                    bottomWidgetsRow
                    quoteWidget
                }
                .skylineContentWidth()
                .skylineScreenPadding()
                .padding(.bottom, 28)
            }
        }
        .skylineScreen(title: "Home")
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                NavigationLink {
                    SettingsView()
                } label: {
                    Image(systemName: "gearshape.fill")
                        .font(.body.weight(.semibold))
                        .foregroundColor(.skylineAccent)
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button { showAddWalk = true } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(.white, Color.skylineAccent)
                }
            }
        }
        .sheet(isPresented: $showAddWalk) { AddWalkView(viewModel: viewModel) }
        .sheet(isPresented: $showTemplates) {
            NavigationStack { WalkTemplatesView(viewModel: viewModel) }
        }
        .sheet(isPresented: $showReminders) { RemindersSettingsView(viewModel: viewModel) }
        .onAppear { viewModel.refreshQuote() }
    }

    // MARK: - Sections

    private var greetingHeader: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(greeting)
                .font(.title2.weight(.bold))
                .foregroundColor(.skylineText)
            Text("Your night city dashboard")
                .font(.subheadline)
                .foregroundColor(.skylineMuted)
        }
    }

    private var heroCarousel: some View {
        HomeHeroCarousel(slides: viewModel.homeHeroSlides, selectedIndex: $heroIndex)
    }

    private var quickActionsWidget: some View {
        HomeWidget(title: "Quick actions", subtitle: "Start exploring") {
            HomeQuickActionsWidget(
                onNewWalk: { showAddWalk = true },
                onRoutes: { selectedTab = 2 },
                onGallery: { selectedTab = 3 },
                onStats: { selectedTab = 5 }
            )
        }
    }

    private var statsWidgetGrid: some View {
        LazyVGrid(columns: widgetColumns, spacing: 12) {
            HomeWidget(title: "Walks", subtitle: viewModel.monthWalksDeltaText) {
                HomeStatWidget(
                    icon: "figure.walk",
                    value: "\(viewModel.totalWalks)",
                    label: "Total logged"
                )
            }

            HomeWidget(title: "Distance", subtitle: viewModel.monthDistanceDeltaText) {
                HomeStatWidget(
                    icon: "map.fill",
                    value: String(format: "%.1f", viewModel.totalDistance),
                    label: "Kilometers"
                )
            }

            HomeWidget(title: "Streak", subtitle: "Keep the rhythm") {
                HomeStreakWidget(streakDays: viewModel.streakDays)
            }

            HomeWidget(title: "This month", subtitle: "Activity") {
                HomeMiniCalendarWidget(days: viewModel.calendarDays)
            }
        }
    }

    private var photoMemoriesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SkylineSectionHeader(
                title: "Night memories",
                subtitle: "\(viewModel.galleryPhotos.count) photos",
                actionTitle: "See all",
                action: { selectedTab = 3 }
            )

            if viewModel.homePhotoStrip.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(NightSceneIllustration.Variant.allCases, id: \.self) { variant in
                            NightSceneIllustration(variant: variant)
                                .frame(width: 140, height: 180)
                                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                                        .stroke(Color.skylineAccent.opacity(0.3), lineWidth: 1)
                                )
                        }
                    }
                }
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(viewModel.homePhotoStrip) { photo in
                            NavigationLink {
                                if let walk = viewModel.walks.first(where: { $0.id == photo.walkId }) {
                                    WalkDetailView(viewModel: viewModel, walk: walk)
                                }
                            } label: {
                                NightPhotoTile(
                                    imageReference: photo.imageName,
                                    walkTitle: photo.walkTitle,
                                    subtitle: photo.date.formatted(date: .abbreviated, time: .omitted),
                                    height: 180,
                                    showOverlay: true
                                )
                                .frame(width: 160)
                            }
                            .buttonStyle(.plain)
                        }

                        Button { selectedTab = 3 } label: {
                            VStack(spacing: 12) {
                                Image(systemName: "plus.viewfinder")
                                    .font(.title)
                                Text("Add more")
                                    .font(.caption.weight(.semibold))
                            }
                            .foregroundColor(.skylineAccent)
                            .frame(width: 120, height: 180)
                            .background(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .strokeBorder(style: StrokeStyle(lineWidth: 1, dash: [6]))
                                    .foregroundColor(.skylineAccent.opacity(0.4))
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    @ViewBuilder
    private var recentWalksSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SkylineSectionHeader(
                title: "Recent walks",
                subtitle: "Pick up where you left off",
                actionTitle: "All walks",
                action: { selectedTab = 1 }
            )

            if viewModel.homeRecentWalks.isEmpty {
                SkylineEmptyState(
                    icon: "figure.walk",
                    title: "No walks yet",
                    message: "Your latest night walks will appear here with photos.",
                    buttonTitle: "Log a walk",
                    action: { showAddWalk = true }
                )
            } else {
                VStack(spacing: 12) {
                    ForEach(viewModel.homeRecentWalks) { walk in
                        NavigationLink {
                            WalkDetailView(viewModel: viewModel, walk: walk)
                        } label: {
                            HomeRecentWalkCell(walk: walk)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    private var bottomWidgetsRow: some View {
        VStack(spacing: 12) {
            if let goal = viewModel.primaryActiveGoal {
                HomeWidget(title: "Active goal", subtitle: goal.isAutoGoal ? "Auto-tracked" : "In progress") {
                    HomeGoalMiniWidget(goal: goal)
                }
            }

            HStack(spacing: 12) {
                HomeWidget(title: "Achievements", subtitle: "\(viewModel.unlockedAchievements.count) unlocked") {
                    HStack(spacing: -8) {
                        ForEach(viewModel.unlockedAchievements.prefix(4)) { record in
                            SkylineIconBadge(icon: record.type.icon, size: 36, filled: true)
                                .overlay(Circle().stroke(Color.skylineBackground, lineWidth: 2))
                        }
                        if viewModel.unlockedAchievements.isEmpty {
                            Text("Walk to unlock badges")
                                .font(.caption)
                                .foregroundColor(.skylineMuted)
                        }
                    }
                }
                .onTapGesture { selectedTab = 4 }
            }

            HomeWidget(title: "Reminders", subtitle: viewModel.reminderSettings.isEnabled ? "Enabled" : "Off") {
                Button { showReminders = true } label: {
                    HStack {
                        SkylineIconBadge(icon: "bell.fill", size: 36, filled: false)
                        Text("Manage night walk reminders")
                            .font(.caption)
                            .foregroundColor(.skylineText)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(.skylineAccent)
                    }
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var quoteWidget: some View {
        SkylineQuoteCard(quote: viewModel.currentQuote) {
            viewModel.refreshQuote()
        }
    }

    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "Good morning"
        case 12..<17: return "Good afternoon"
        case 17..<22: return "Good evening"
        default: return "Good night"
        }
    }
}

// MARK: - Recent walk cell with image

struct HomeRecentWalkCell: View {
    let walk: NightWalk

    var body: some View {
        HStack(spacing: 0) {
            imageSide
                .frame(width: 100)

            VStack(alignment: .leading, spacing: 8) {
                Text(walk.title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.skylineText)
                    .lineLimit(2)

                Text(walk.formattedDate)
                    .font(.caption2)
                    .foregroundColor(.skylineMuted)

                HStack(spacing: 6) {
                    SkylineMetricPill(icon: "map", text: String(format: "%.1f km", walk.distance), highlighted: true)
                    SkylineMetricPill(icon: walk.mood.icon, text: walk.mood.displayName)
                }
            }
            .padding(12)

            Image(systemName: "chevron.right")
                .font(.caption.weight(.bold))
                .foregroundColor(.skylineAccent.opacity(0.5))
                .padding(.trailing, 12)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .skylineListRowSurface(glow: walk.isFavorite)
    }

    @ViewBuilder
    private var imageSide: some View {
        Group {
            if let image = walk.imageNames?.first {
                NightPhotoTile(
                    imageReference: image,
                    walkTitle: nil,
                    subtitle: nil,
                    height: 108,
                    showOverlay: false
                )
            } else {
                NightSceneIllustration(variant: .from(neighborhood: walk.neighborhood))
            }
        }
        .frame(width: 108, height: 108)
        .clipped()
    }
}
