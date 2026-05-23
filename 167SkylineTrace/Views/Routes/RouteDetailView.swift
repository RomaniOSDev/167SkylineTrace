import SwiftUI

struct RouteDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: SkylineTraceViewModel
    let routeId: UUID

    @State private var showEditSheet = false
    @State private var showDeleteConfirmation = false

    init(viewModel: SkylineTraceViewModel, route: WalkRoute) {
        self.viewModel = viewModel
        self.routeId = route.id
    }

    private var route: WalkRoute? {
        viewModel.routes.first(where: { $0.id == routeId })
    }

    var body: some View {
        Group {
            if let route {
                routeDetailContent(route)
            } else {
                SkylineBackground()
            }
        }
        .onChange(of: viewModel.routes) { _ in
            if route == nil { dismiss() }
        }
    }

    @ViewBuilder
    private func routeDetailContent(_ route: WalkRoute) -> some View {
        SkylineScreenScaffold {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: SkylineLayout.sectionSpacing) {
                    HStack(spacing: 14) {
                        SkylineIconBadge(icon: "map.fill", size: 56)
                        VStack(alignment: .leading, spacing: 6) {
                            Text(route.name)
                                .font(.title2.weight(.bold))
                                .foregroundColor(.skylineText)
                            Text(String(format: "%.1f km • %d min", route.distance, route.estimatedDuration))
                                .font(.subheadline)
                                .foregroundColor(.skylineMuted)
                        }
                        Spacer()
                        if route.isFavorite {
                            Image(systemName: "star.fill")
                                .font(.title2)
                                .foregroundColor(.skylineAccent)
                        }
                    }
                    .skylineCellCard(glow: route.isFavorite, elevation: .raised)

                    SkylinePanel(title: "Path", subtitle: "Start to finish") {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack(spacing: 10) {
                                Circle().fill(Color.skylineAccent).frame(width: 8, height: 8)
                                Text(route.startPoint)
                                    .foregroundColor(.skylineText)
                            }
                            Rectangle()
                                .fill(Color.skylineAccent.opacity(0.3))
                                .frame(width: 2, height: 20)
                                .padding(.leading, 3)
                            HStack(spacing: 10) {
                                Circle().stroke(Color.skylineAccent, lineWidth: 2).frame(width: 8, height: 8)
                                Text(route.endPoint)
                                    .foregroundColor(.skylineText)
                            }
                        }
                    }

                    if !route.neighborhoods.isEmpty {
                        SkylinePanel(title: "Neighborhoods") {
                            FlowLayout(spacing: 8) {
                                ForEach(route.neighborhoods, id: \.self) { hood in
                                    SkylineChip(text: hood.displayName, icon: hood.icon)
                                }
                            }
                        }
                    }

                    if !route.description.isEmpty {
                        SkylinePanel(title: "Description") {
                            Text(route.description)
                                .foregroundColor(.skylineText.opacity(0.9))
                                .lineSpacing(4)
                        }
                    }

                    SkylinePrimaryButton("Edit route", icon: "pencil") {
                        showEditSheet = true
                    }
                    SkylineSecondaryButton("Delete", icon: "trash") {
                        showDeleteConfirmation = true
                    }
                }
                .skylineContentWidth()
                .skylineScreenPadding()
                .padding(.bottom, 24)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbarBackground(Color.skylineBackground.opacity(0.95), for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .sheet(isPresented: $showEditSheet) {
            AddRouteView(viewModel: viewModel, editingRoute: route)
        }
        .alert("Delete route?", isPresented: $showDeleteConfirmation) {
            Button("Delete", role: .destructive) {
                viewModel.deleteRoute(route)
                dismiss()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This action cannot be undone.")
        }
    }
}
