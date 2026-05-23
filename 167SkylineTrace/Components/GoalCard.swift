import SwiftUI

struct GoalCard: View {
    let goal: WalkGoal

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top) {
                SkylineIconBadge(
                    icon: goal.isCompleted ? "checkmark" : (goal.isAutoGoal ? "bolt.fill" : "target"),
                    size: 40,
                    filled: goal.isCompleted
                )

                VStack(alignment: .leading, spacing: 4) {
                    Text(goal.title)
                        .font(.headline)
                        .foregroundColor(.skylineText)

                    if goal.isAutoGoal {
                        SkylineChip(text: "Auto-tracked", icon: "sparkles")
                    }
                }

                Spacer()

                statusBadge
            }

            if goal.targetWalks > 0 {
                progressBlock(
                    title: "Walks",
                    current: "\(goal.currentWalks)",
                    target: "\(goal.targetWalks)",
                    progress: goal.walksProgress
                )
            }

            if goal.targetDistance > 0 {
                progressBlock(
                    title: "Distance",
                    current: String(format: "%.1f", goal.currentDistance),
                    target: String(format: "%.1f km", goal.targetDistance),
                    progress: goal.distanceProgress
                )
            }

            if let deadline = goal.deadline {
                HStack(spacing: 6) {
                    Image(systemName: "calendar")
                        .font(.caption2)
                        .foregroundColor(.skylineMuted)
                    Text("Due \(formattedShortDate(deadline))")
                        .font(.caption)
                        .foregroundColor(.skylineMuted)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .skylineListCard(glow: goal.isCompleted)
    }

    @ViewBuilder
    private var statusBadge: some View {
        if goal.isCompleted {
            Text("Done")
                .font(.caption.weight(.bold))
                .foregroundColor(.skylineBackground)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(Capsule().fill(Color.skylineAccentGradient))
        } else {
            Text("\(Int(max(goal.walksProgress, goal.distanceProgress) * 100))%")
                .font(.caption.weight(.bold))
                .foregroundColor(.skylineAccent)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(Capsule().fill(Color.skylineAccent.opacity(0.15)))
        }
    }

    private func progressBlock(title: String, current: String, target: String, progress: Double) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(.caption.weight(.medium))
                    .foregroundColor(.skylineMuted)
                Spacer()
                Text("\(current) / \(target)")
                    .font(.caption.weight(.semibold))
                    .foregroundColor(.skylineAccent)
            }
            SkylineProgressBar(value: progress)
        }
    }
}
