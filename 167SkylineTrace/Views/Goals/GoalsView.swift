import SwiftUI

struct GoalsView: View {
    @ObservedObject var viewModel: SkylineTraceViewModel
    @State private var showAddGoalSheet = false
    @State private var showReminders = false

    var body: some View {
        SkylineScreenScaffold {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: SkylineLayout.sectionSpacing) {
                    remindersCard
                    achievementsSection
                    goalsSection
                }
                .skylineContentWidth()
                .skylineScreenPadding()
                .padding(.bottom, 24)
            }
        }
        .skylineScreen(title: "Goals")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button { showAddGoalSheet = true } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(.white, Color.skylineAccent)
                }
            }
        }
        .sheet(isPresented: $showAddGoalSheet) { AddGoalView(viewModel: viewModel) }
        .sheet(isPresented: $showReminders) { RemindersSettingsView(viewModel: viewModel) }
    }

    private var remindersCard: some View {
        Button { showReminders = true } label: {
            HStack(spacing: 14) {
                SkylineIconBadge(icon: "bell.fill", size: 44)
                VStack(alignment: .leading, spacing: 4) {
                    Text("Walk reminders")
                        .font(.headline)
                        .foregroundColor(.skylineText)
                    Text(viewModel.reminderSettings.isEnabled ? "Notifications enabled" : "Tap to schedule night walks")
                        .font(.caption)
                        .foregroundColor(.skylineMuted)
                }
                Spacer()
                Text(viewModel.reminderSettings.isEnabled ? "On" : "Off")
                    .font(.caption.weight(.bold))
                    .foregroundColor(.skylineAccent)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Capsule().fill(Color.skylineAccent.opacity(0.15)))
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.bold))
                    .foregroundColor(.skylineAccent.opacity(0.6))
            }
            .skylineCellCard(glow: viewModel.reminderSettings.isEnabled, elevation: .raised)
        }
        .buttonStyle(.plain)
    }

    private var achievementsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            SkylineSectionHeader(
                title: "Achievements",
                subtitle: "\(viewModel.unlockedAchievements.count) of \(AchievementType.allCases.count) unlocked"
            )

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(viewModel.unlockedAchievements.prefix(5)) { record in
                        VStack(spacing: 6) {
                            SkylineIconBadge(icon: record.type.icon, size: 40)
                            Text(record.type.title)
                                .font(.caption2)
                                .foregroundColor(.skylineText)
                                .lineLimit(1)
                                .frame(width: 72)
                        }
                    }
                }
            }

            ForEach(AchievementType.allCases, id: \.self) { type in
                let record = viewModel.achievements.first(where: { $0.type == type })
                AchievementCard(type: type, isUnlocked: record != nil, unlockedAt: record?.unlockedAt)
            }
        }
    }

    private var goalsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            SkylineSectionHeader(title: "Your goals", subtitle: "Track progress over time")

            if viewModel.goals.isEmpty {
                SkylineEmptyState(
                    icon: "target",
                    title: "No goals yet",
                    message: "Set distance or walk-count targets to stay motivated.",
                    buttonTitle: "Add goal",
                    action: { showAddGoalSheet = true }
                )
            } else {
                ForEach(viewModel.goals) { goal in
                    GoalCard(goal: goal)
                        .contextMenu {
                            if !goal.isCompleted {
                                Button { viewModel.completeGoal(goal) } label: {
                                    Label("Complete", systemImage: "checkmark")
                                }
                            }
                            Button(role: .destructive) { viewModel.deleteGoal(goal) } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                }
            }

            SkylineSecondaryButton("Add goal", icon: "plus") {
                showAddGoalSheet = true
            }
        }
    }
}
