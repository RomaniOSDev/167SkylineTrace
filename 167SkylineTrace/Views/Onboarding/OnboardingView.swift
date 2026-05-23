import SwiftUI

struct OnboardingView: View {
    var onComplete: () -> Void

    @State private var currentPage = 0

    private let pages: [OnboardingPage] = [
        OnboardingPage(
            title: "Your night walks",
            subtitle: "Log distance, mood, weather, and photos after every evening stroll.",
            icon: "moon.stars.fill",
            scene: .downtown
        ),
        OnboardingPage(
            title: "Routes & gallery",
            subtitle: "Save favorite paths and browse memories from all your walks in one place.",
            icon: "map.fill",
            scene: .bridge
        ),
        OnboardingPage(
            title: "Goals & insights",
            subtitle: "Set targets, unlock achievements, and track your progress over time.",
            icon: "chart.line.uptrend.xyaxis",
            scene: .park
        )
    ]

    var body: some View {
        ZStack {
            SkylineBackground()

            VStack(spacing: 0) {
                headerBar

                TabView(selection: $currentPage) {
                    ForEach(Array(pages.enumerated()), id: \.element.id) { index, page in
                        OnboardingPageView(page: page)
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut(duration: 0.25), value: currentPage)

                footer
            }
        }
        .preferredColorScheme(.dark)
    }

    private var headerBar: some View {
        HStack {
            Spacer()
            Button("Skip", action: finishOnboarding)
                .font(.subheadline.weight(.semibold))
                .foregroundColor(.skylineMuted)
        }
        .padding(.horizontal, SkylineLayout.horizontalPadding)
        .padding(.top, 8)
        .padding(.bottom, 4)
    }

    private var footer: some View {
        VStack(spacing: 24) {
            pageIndicator

            if isLastPage {
                SkylinePrimaryButton("Get started", icon: "checkmark", action: finishOnboarding)
            } else {
                SkylinePrimaryButton("Continue", icon: "arrow.right", action: advance)
            }
        }
        .padding(.horizontal, SkylineLayout.horizontalPadding)
        .padding(.bottom, 40)
        .padding(.top, 8)
    }

    private var isLastPage: Bool {
        currentPage >= pages.count - 1
    }

    private var pageIndicator: some View {
        HStack(spacing: 8) {
            ForEach(0..<pages.count, id: \.self) { index in
                Capsule()
                    .fill(index == currentPage ? Color.skylineAccent : Color.white.opacity(0.2))
                    .frame(width: index == currentPage ? 24 : 8, height: 8)
                    .animation(.easeInOut(duration: 0.2), value: currentPage)
            }
        }
    }

    private func advance() {
        guard currentPage < pages.count - 1 else { return }
        withAnimation(.easeInOut(duration: 0.25)) {
            currentPage += 1
        }
    }

    private func finishOnboarding() {
        onComplete()
    }
}

// MARK: - Page model

private struct OnboardingPage: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let icon: String
    let scene: NightSceneIllustration.Variant
}

// MARK: - Page content

private struct OnboardingPageView: View {
    let page: OnboardingPage

    var body: some View {
        VStack(spacing: 28) {
            ZStack {
                NightSceneIllustration(variant: page.scene)
                    .frame(height: 280)
                    .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))

                VStack {
                    Spacer()
                    SkylineIconBadge(icon: page.icon, size: 64)
                        .offset(y: 32)
                }
            }
            .overlay {
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .strokeBorder(Color.skylineBorderGradient, lineWidth: 1.5)
            }
            .compositingGroup()
            .shadow(
                color: Color.skylineAccent.opacity(0.3),
                radius: SkylineElevation.hero.radius,
                y: SkylineElevation.hero.y
            )
            .padding(.horizontal, SkylineLayout.horizontalPadding)

            VStack(spacing: 12) {
                Text(page.title)
                    .font(.title.weight(.bold))
                    .foregroundColor(.skylineText)
                    .multilineTextAlignment(.center)

                Text(page.subtitle)
                    .font(.body)
                    .foregroundColor(.skylineMuted)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.horizontal, 28)

            Spacer(minLength: 0)
        }
        .padding(.top, 8)
    }
}

#Preview {
    OnboardingView(onComplete: {})
}
