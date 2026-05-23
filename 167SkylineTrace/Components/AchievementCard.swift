import SwiftUI

struct AchievementCard: View {
    let type: AchievementType
    let isUnlocked: Bool
    let unlockedAt: Date?

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                SkylineIconBadge(icon: type.icon, size: 48, filled: isUnlocked)
                if !isUnlocked {
                    Circle()
                        .fill(Color.black.opacity(0.45))
                        .frame(width: 48, height: 48)
                    Image(systemName: "lock.fill")
                        .font(.caption)
                        .foregroundColor(.skylineMuted)
                }
            }

            VStack(alignment: .leading, spacing: 6) {
                Text(type.title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(isUnlocked ? .skylineText : .skylineMuted)

                Text(type.description)
                    .font(.caption)
                    .foregroundColor(.skylineMuted)
                    .lineLimit(2)

                if let unlockedAt, isUnlocked {
                    Text("Unlocked \(unlockedAt.formatted(date: .abbreviated, time: .omitted))")
                        .font(.caption2.weight(.medium))
                        .foregroundColor(.skylineAccent)
                }
            }

            Spacer()

            if isUnlocked {
                Image(systemName: "checkmark.seal.fill")
                    .font(.title3)
                    .foregroundColor(.skylineAccent)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .skylineListCard(glow: isUnlocked)
        .opacity(isUnlocked ? 1 : 0.85)
    }
}
