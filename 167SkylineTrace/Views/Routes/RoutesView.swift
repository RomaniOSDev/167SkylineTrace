import SwiftUI

struct RoutesView: View {
    @ObservedObject var viewModel: SkylineTraceViewModel
    @State private var showAddRouteSheet = false

    var body: some View {
        SkylineScreenScaffold {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: SkylineLayout.sectionSpacing) {
                    SkylineSectionHeader(
                        title: "Saved routes",
                        subtitle: "\(viewModel.routes.count) night paths"
                    )

                    if viewModel.routes.isEmpty {
                        SkylineEmptyState(
                            icon: "map.fill",
                            title: "No routes yet",
                            message: "Save your favorite night paths to reuse them when logging walks.",
                            buttonTitle: "Add route",
                            action: { showAddRouteSheet = true }
                        )
                    } else {
                        ForEach(viewModel.routes) { route in
                            NavigationLink {
                                RouteDetailView(viewModel: viewModel, route: route)
                            } label: {
                                RouteCard(route: route)
                            }
                            .buttonStyle(.plain)
                            .contextMenu {
                                Button { viewModel.toggleFavoriteRoute(route) } label: {
                                    Label(route.isFavorite ? "Remove favorite" : "Favorite", systemImage: "star")
                                }
                                Button(role: .destructive) { viewModel.deleteRoute(route) } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                        }
                    }

                    SkylineSecondaryButton("Add route", icon: "plus") {
                        showAddRouteSheet = true
                    }
                }
                .skylineContentWidth()
                .skylineScreenPadding()
                .padding(.bottom, 24)
            }
        }
        .skylineScreen(title: "Routes")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button { showAddRouteSheet = true } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(.white, Color.skylineAccent)
                }
            }
        }
        .sheet(isPresented: $showAddRouteSheet) { AddRouteView(viewModel: viewModel) }
    }
}
