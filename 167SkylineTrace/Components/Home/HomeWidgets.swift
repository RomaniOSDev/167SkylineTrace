import SwiftUI

// MARK: - Widget shell

struct HomeWidget<Content: View>: View {
    let title: String
    var subtitle: String?
    var span: WidgetSpan = .single
    @ViewBuilder let content: Content

    enum WidgetSpan {
        case single
        case double
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if !title.isEmpty {
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(.skylineText)
                    if let subtitle {
                        Text(subtitle)
                            .font(.caption2)
                            .foregroundColor(.skylineMuted)
                    }
                }
            }
            content
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .skylineCellCard(elevation: .card)
    }
}

// MARK: - Stat widget

struct HomeStatWidget: View {
    let icon: String
    let value: String
    let label: String
    var trend: String?

    var body: some View {
        HStack(spacing: 12) {
            SkylineIconBadge(icon: icon, size: 40, filled: false)
            VStack(alignment: .leading, spacing: 4) {
                Text(value)
                    .font(.title2.weight(.bold))
                    .foregroundColor(.skylineText)
                Text(label)
                    .font(.caption)
                    .foregroundColor(.skylineMuted)
                if let trend {
                    Text(trend)
                        .font(.caption2.weight(.semibold))
                        .foregroundColor(.skylineAccent)
                }
            }
            Spacer()
        }
    }
}

// MARK: - Streak widget

struct HomeStreakWidget: View {
    let streakDays: Int

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(Color.orange.opacity(0.2))
                    .frame(width: 64, height: 64)
                SkylineIconBadge(icon: "flame.fill", size: 48)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("\(streakDays)")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundColor(.skylineText)
                Text(streakDays == 1 ? "night in a row" : "nights in a row")
                    .font(.caption)
                    .foregroundColor(.skylineMuted)
            }
            Spacer()
        }
    }
}

// MARK: - Quick action

struct HomeQuickActionsWidget: View {
    var onNewWalk: () -> Void
    var onRoutes: () -> Void
    var onGallery: () -> Void
    var onStats: () -> Void

    private let columns = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        LazyVGrid(columns: columns, spacing: 10) {
            quickTile(title: "New walk", icon: "plus.circle.fill", action: onNewWalk)
            quickTile(title: "Routes", icon: "map.fill", action: onRoutes)
            quickTile(title: "Gallery", icon: "photo.on.rectangle.angled", action: onGallery)
            quickTile(title: "Stats", icon: "chart.bar.fill", action: onStats)
        }
    }

    private func quickTile(title: String, icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(Color.skylineAccentGradient)
                Text(title)
                    .font(.caption.weight(.semibold))
                    .foregroundColor(.skylineText)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background {
                SkylineCardBackground(cornerRadius: 14, accent: .skylineAccent, glow: false)
            }
            .compositingGroup()
            .shadow(color: Color.black.opacity(0.22), radius: 4, y: 2)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Goal mini widget

struct HomeGoalMiniWidget: View {
    let goal: WalkGoal

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(goal.title)
                    .font(.caption.weight(.semibold))
                    .foregroundColor(.skylineText)
                    .lineLimit(1)
                Spacer()
                if goal.isCompleted {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.skylineAccent)
                }
            }

            if goal.targetWalks > 0 {
                SkylineProgressBar(value: goal.walksProgress)
                Text("\(goal.currentWalks)/\(goal.targetWalks) walks")
                    .font(.caption2)
                    .foregroundColor(.skylineMuted)
            }

            if goal.targetDistance > 0 {
                SkylineProgressBar(value: goal.distanceProgress)
                Text(String(format: "%.1f/%.1f km", goal.currentDistance, goal.targetDistance))
                    .font(.caption2)
                    .foregroundColor(.skylineMuted)
            }
        }
    }
}

// MARK: - Mini calendar

struct HomeMiniCalendarWidget: View {
    let days: [CalendarDay]

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 4), count: 7)

    var body: some View {
        LazyVGrid(columns: columns, spacing: 4) {
            ForEach(days.suffix(14)) { day in
                RoundedRectangle(cornerRadius: 4, style: .continuous)
                    .fill(heatColor(day.walkCount))
                    .frame(height: 22)
            }
        }
    }

    private func heatColor(_ count: Int) -> Color {
        switch count {
        case 0: return Color.white.opacity(0.06)
        case 1: return Color.skylineAccent.opacity(0.45)
        default: return Color.skylineAccent
        }
    }
}

// MARK: - Hero carousel

struct HomeHeroCarousel: View {
    let slides: [HomeHeroSlide]
    @Binding var selectedIndex: Int

    var body: some View {
        TabView(selection: $selectedIndex) {
            ForEach(Array(slides.enumerated()), id: \.element.id) { index, slide in
                ZStack(alignment: .bottomLeading) {
                    slideVisual(for: slide)
                        .frame(height: 220)
                        .clipped()

                    LinearGradient(
                        colors: [.clear, .black.opacity(0.8)],
                        startPoint: .center,
                        endPoint: .bottom
                    )

                    VStack(alignment: .leading, spacing: 6) {
                        if let badge = slide.badge {
                            Text(badge)
                                .font(.caption2.weight(.bold))
                                .foregroundColor(.skylineBackground)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Capsule().fill(Color.skylineAccent))
                        }
                        Text(slide.title)
                            .font(.title3.weight(.bold))
                            .foregroundColor(.white)
                        Text(slide.subtitle)
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.85))
                    }
                    .padding(16)
                }
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .strokeBorder(Color.skylineBorderGradient, lineWidth: 1.5)
                }
                .compositingGroup()
                .shadow(
                    color: Color.skylineAccent.opacity(0.25),
                    radius: SkylineElevation.hero.radius,
                    y: SkylineElevation.hero.y
                )
                .tag(index)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .automatic))
        .frame(height: 220)
    }

    @ViewBuilder
    private func slideVisual(for slide: HomeHeroSlide) -> some View {
        switch slide.visual {
        case .photo(let ref, let neighborhood):
            if ref.lowercased().hasPrefix("http"), let url = URL(string: ref) {
                AsyncImage(url: url) { phase in
                    if case .success(let img) = phase {
                        img.resizable().scaledToFill()
                    } else {
                        NightSceneIllustration(variant: .from(neighborhood: neighborhood))
                    }
                }
            } else {
                ZStack {
                    NightSceneIllustration(variant: .from(neighborhood: neighborhood))
                    Image(systemName: "camera.fill")
                        .font(.largeTitle)
                        .foregroundColor(.white.opacity(0.2))
                }
            }
        case .scene(let variant):
            NightSceneIllustration(variant: variant)
        }
    }
}

struct HomeHeroSlide: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let badge: String?
    let visual: Visual

    enum Visual {
        case photo(reference: String, neighborhood: Neighborhood)
        case scene(NightSceneIllustration.Variant)
    }
}
