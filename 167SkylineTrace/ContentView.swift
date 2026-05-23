import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = SkylineTraceViewModel()
    @State private var selectedTab = 0
    @AppStorage(OnboardingStorage.completedKey) private var hasCompletedOnboarding = false

    var body: some View {
        Group {
            if hasCompletedOnboarding {
                mainTabInterface
            } else {
                OnboardingView {
                    hasCompletedOnboarding = true
                }
            }
        }
        .tint(.skylineAccent)
        .preferredColorScheme(.dark)
    }

    private var mainTabInterface: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                HomeView(viewModel: viewModel, selectedTab: $selectedTab)
            }
            .tag(0)
            .tabItem {
                Label("Home", systemImage: "house.fill")
            }

            NavigationStack {
                WalksFeedView(viewModel: viewModel)
            }
            .tag(1)
            .tabItem {
                Label("Walks", systemImage: "figure.walk")
            }

            NavigationStack {
                RoutesView(viewModel: viewModel)
            }
            .tag(2)
            .tabItem {
                Label("Routes", systemImage: "map.fill")
            }

            NavigationStack {
                PhotoGalleryView(viewModel: viewModel)
            }
            .tag(3)
            .tabItem {
                Label("Gallery", systemImage: "photo.on.rectangle")
            }

            NavigationStack {
                GoalsView(viewModel: viewModel)
            }
            .tag(4)
            .tabItem {
                Label("Goals", systemImage: "target")
            }

            NavigationStack {
                StatsView(viewModel: viewModel)
            }
            .tag(5)
            .tabItem {
                Label("Statistics", systemImage: "chart.bar.fill")
            }
        }
        .onAppear {
            SkylineListAppearance.configure()
            viewModel.loadFromUserDefaults()
            WalkNotificationService.requestAuthorization()
        }
    }
}

#Preview {
    ContentView()
}
