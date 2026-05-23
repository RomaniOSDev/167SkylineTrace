import SwiftUI

// MARK: - Section header

struct SkylineSectionHeader: View {
    let title: String
    var subtitle: String?
    var actionTitle: String?
    var action: (() -> Void)?

    var body: some View {
        HStack(alignment: .bottom) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.skylineText)
                if let subtitle {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.skylineMuted)
                }
            }
            Spacer()
            if let actionTitle, let action {
                Button(actionTitle, action: action)
                    .font(.caption.weight(.semibold))
                    .foregroundColor(.skylineAccent)
            }
        }
    }
}

// MARK: - Icon badge

struct SkylineIconBadge: View {
    let icon: String
    var size: CGFloat = 44
    var filled: Bool = true

    var body: some View {
        ZStack {
            if filled {
                Circle()
                    .fill(Color.skylineAccent.opacity(0.2))
                    .frame(width: size + 8, height: size + 8)
            }

            Circle()
                .fill(
                    filled
                        ? AnyShapeStyle(Color.skylineAccentGradient)
                        : AnyShapeStyle(
                            LinearGradient(
                                colors: [
                                    Color.skylineAccent.opacity(0.22),
                                    Color.skylineAccent.opacity(0.08)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                )
                .frame(width: size, height: size)
                .overlay {
                    Circle()
                        .stroke(Color.white.opacity(filled ? 0.25 : 0.12), lineWidth: 1)
                }

            Image(systemName: icon)
                .font(.system(size: size * 0.4, weight: .semibold))
                .foregroundColor(filled ? .white : .skylineAccent)
        }
        .compositingGroup()
        .shadow(
            color: filled ? Color.skylineAccent.opacity(0.35) : Color.black.opacity(0.25),
            radius: filled ? 6 : 4,
            y: 2
        )
    }
}

// MARK: - Chip

struct SkylineChip: View {
    let text: String
    var icon: String?

    var body: some View {
        HStack(spacing: 4) {
            if let icon {
                Image(systemName: icon)
                    .font(.caption2)
            }
            Text(text)
                .font(.caption2.weight(.medium))
        }
        .foregroundColor(.skylineAccent)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(
            Capsule()
                .fill(
                    LinearGradient(
                        colors: [Color.skylineAccent.opacity(0.22), Color.skylineAccent.opacity(0.1)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .overlay(
            Capsule()
                .stroke(Color.white.opacity(0.12), lineWidth: 0.5)
        )
    }
}

// MARK: - Metric pill

struct SkylineMetricPill: View {
    let icon: String
    let text: String
    var highlighted: Bool = false

    var body: some View {
        HStack(spacing: 5) {
            Image(systemName: icon)
                .font(.caption2.weight(.semibold))
            Text(text)
                .font(.caption.weight(.medium))
        }
        .foregroundColor(highlighted ? .skylineAccent : .skylineMuted)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(
            Capsule()
                .fill(
                    highlighted
                        ? LinearGradient(
                            colors: [Color.skylineAccent.opacity(0.2), Color.skylineAccent.opacity(0.08)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        : LinearGradient(
                            colors: [Color.white.opacity(0.08), Color.white.opacity(0.03)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                )
        )
        .overlay {
            Capsule()
                .stroke(Color.white.opacity(highlighted ? 0.15 : 0.06), lineWidth: 0.5)
        }
    }
}

// MARK: - Progress bar

struct SkylineProgressBar: View {
    let value: Double
    var height: CGFloat = 6

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.white.opacity(0.08))
                Capsule()
                    .fill(Color.skylineAccentGradient)
                    .frame(width: max(geo.size.width * CGFloat(min(max(value, 0), 1)), height))
            }
        }
        .frame(height: height)
    }
}

// MARK: - Search field

struct SkylineSearchField: View {
    @Binding var text: String
    let placeholder: String

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.skylineAccent)
                .font(.body.weight(.medium))

            TextField(placeholder, text: $text)
                .foregroundColor(.skylineText)
                .autocorrectionDisabled()

            if !text.isEmpty {
                Button {
                    text = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.skylineMuted)
                }
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background {
            SkylineCardBackground(cornerRadius: 14, accent: .skylineAccent, glow: false)
        }
        .compositingGroup()
        .shadow(color: Color.black.opacity(0.3), radius: 8, y: 3)
    }
}

// MARK: - Sort bar

struct SkylineSortBar: View {
    @Binding var selection: WalkSortOption

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(WalkSortOption.allCases) { option in
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selection = option
                        }
                    } label: {
                        Text(option.displayName)
                            .font(.caption.weight(.semibold))
                            .foregroundColor(selection == option ? Color.skylineBackground : .skylineText)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background {
                                if selection == option {
                                    Capsule().fill(Color.skylineAccentGradient)
                                } else {
                                    Capsule().fill(Color.white.opacity(0.06))
                                }
                            }
                            .compositingGroup()
                            .shadow(
                                color: selection == option ? Color.skylineAccent.opacity(0.35) : .clear,
                                radius: selection == option ? 4 : 0,
                                y: selection == option ? 2 : 0
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

// MARK: - Buttons

struct SkylinePrimaryButton: View {
    let title: String
    let icon: String?
    let action: () -> Void

    init(_ title: String, icon: String? = nil, action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let icon {
                    Image(systemName: icon)
                        .font(.body.weight(.semibold))
                }
                Text(title)
                    .font(.body.weight(.semibold))
            }
            .foregroundColor(.skylineBackground)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background {
                ZStack {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(Color.skylineAccentGradient)
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [Color.white.opacity(0.22), Color.clear],
                                startPoint: .top,
                                endPoint: .center
                            )
                        )
                }
            }
            .compositingGroup()
            .shadow(color: Color.skylineAccent.opacity(0.45), radius: 10, y: 4)
        }
        .buttonStyle(.plain)
    }
}

struct SkylineSecondaryButton: View {
    let title: String
    let icon: String?
    let action: () -> Void

    init(_ title: String, icon: String? = nil, action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let icon {
                    Image(systemName: icon)
                }
                Text(title)
                    .font(.body.weight(.semibold))
            }
            .foregroundColor(.skylineAccent)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background {
                SkylineCardBackground(cornerRadius: 14, accent: .skylineAccent, glow: false)
            }
            .compositingGroup()
            .shadow(color: Color.black.opacity(0.28), radius: 6, y: 3)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Empty state

struct SkylineEmptyState: View {
    let icon: String
    let title: String
    let message: String
    var buttonTitle: String?
    var action: (() -> Void)?

    var body: some View {
        VStack(spacing: 16) {
            SkylineIconBadge(icon: icon, size: 64, filled: false)

            Text(title)
                .font(.headline)
                .foregroundColor(.skylineText)

            Text(message)
                .font(.subheadline)
                .foregroundColor(.skylineMuted)
                .multilineTextAlignment(.center)

            if let buttonTitle, let action {
                SkylineSecondaryButton(buttonTitle, icon: "plus", action: action)
                    .padding(.top, 4)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
        .skylineInsetPanel()
    }
}

// MARK: - Quote card

struct SkylineQuoteCard: View {
    let quote: String
    var onRefresh: (() -> Void)?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                SkylineIconBadge(icon: "quote.opening", size: 32, filled: false)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Night thought")
                        .font(.caption.weight(.semibold))
                        .foregroundColor(.skylineAccent)
                    Text("Tap to inspire")
                        .font(.caption2)
                        .foregroundColor(.skylineMuted)
                }
                Spacer()
                if let onRefresh {
                    Button(action: onRefresh) {
                        Image(systemName: "arrow.clockwise")
                            .font(.body.weight(.medium))
                            .foregroundColor(.skylineAccent)
                            .padding(8)
                            .background(Circle().fill(Color.skylineAccent.opacity(0.12)))
                    }
                    .buttonStyle(.plain)
                }
            }

            Text(quote)
                .font(.subheadline)
                .italic()
                .foregroundColor(.skylineText.opacity(0.9))
                .lineSpacing(4)
        }
        .skylineCellCard(glow: true, elevation: .raised)
    }
}

// MARK: - Screen scaffold

struct SkylineScreenScaffold<Content: View>: View {
    @ViewBuilder let content: Content

    var body: some View {
        ZStack {
            SkylineBackground()
            content
        }
    }
}
