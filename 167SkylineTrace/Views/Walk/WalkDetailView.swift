import SwiftUI

struct WalkDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: SkylineTraceViewModel
    let walkId: UUID

    @State private var showEditSheet = false
    @State private var showDeleteConfirmation = false

    init(viewModel: SkylineTraceViewModel, walk: NightWalk) {
        self.viewModel = viewModel
        self.walkId = walk.id
    }

    private var walk: NightWalk? {
        viewModel.walks.first(where: { $0.id == walkId })
    }

    var body: some View {
        Group {
            if let walk {
                detailContent(for: walk)
            } else {
                Color.skylineBackground.ignoresSafeArea()
            }
        }
        .onChange(of: viewModel.walks) { _ in
            if walk == nil { dismiss() }
        }
    }

    @ViewBuilder
    private func detailContent(for walk: NightWalk) -> some View {
        SkylineScreenScaffold {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: SkylineLayout.sectionSpacing) {
                    headerSection(walk)
                    routeSection(walk)
                    descriptionSection(walk)

                    if !walk.highlights.isEmpty {
                        highlightsSection(walk)
                    }

                    if !walk.tags.isEmpty {
                        tagsSection(walk)
                    }

                    if let images = walk.imageNames, !images.isEmpty {
                        photosSection(images)
                    }

                    actionButtons(walk)
                }
                .skylineContentWidth()
                .skylineScreenPadding()
                .padding(.bottom, 24)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbarBackground(Color.skylineBackground, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button {
                        viewModel.saveTemplate(from: walk, name: "\(walk.title) template")
                    } label: {
                        Label("Save as template", systemImage: "doc.on.doc")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .foregroundColor(.skylineAccent)
                }
            }
        }
        .sheet(isPresented: $showEditSheet) {
            AddWalkView(viewModel: viewModel, editingWalk: walk)
        }
        .alert("Delete walk?", isPresented: $showDeleteConfirmation) {
            Button("Delete", role: .destructive) {
                viewModel.deleteWalk(walk)
                dismiss()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This action cannot be undone.")
        }
    }

    private func headerSection(_ walk: NightWalk) -> some View {
        HStack(alignment: .top, spacing: 14) {
            SkylineIconBadge(icon: walk.mood.icon, size: 56)

            VStack(alignment: .leading, spacing: 8) {
                Text(walk.title)
                    .font(.title2.weight(.bold))
                    .foregroundColor(.skylineText)

                Text(walk.formattedDate)
                    .font(.subheadline)
                    .foregroundColor(.skylineMuted)

                if let rating = walk.rating {
                    HStack(spacing: 4) {
                        ForEach(1...5, id: \.self) { index in
                            Image(systemName: index <= rating ? "star.fill" : "star")
                                .foregroundColor(.skylineAccent)
                        }
                    }
                }
            }

            Spacer()

            if walk.isFavorite {
                Image(systemName: "star.fill")
                    .font(.title2)
                    .foregroundColor(.skylineAccent)
            }
        }
        .skylineCellCard(glow: walk.isFavorite, elevation: .raised)
    }

    private func routeSection(_ walk: NightWalk) -> some View {
        SkylinePanel(title: "Route", subtitle: walk.routeName) {
            FlowLayout(spacing: 8) {
                SkylineMetricPill(icon: "map", text: String(format: "%.1f km", walk.distance), highlighted: true)
                SkylineMetricPill(icon: "clock", text: walk.formattedDuration)
                SkylineMetricPill(icon: walk.difficulty.icon, text: walk.difficulty.displayName)
                SkylineMetricPill(icon: walk.mood.icon, text: walk.mood.displayName)
                if let weather = walk.weather {
                    SkylineMetricPill(icon: weather.icon, text: weather.displayName, highlighted: true)
                }
                SkylineMetricPill(icon: walk.neighborhood.icon, text: walk.neighborhood.displayName)
            }
        }
    }

    private func descriptionSection(_ walk: NightWalk) -> some View {
        SkylinePanel(title: "Impressions", subtitle: "Your night notes") {
            Text(walk.description.isEmpty ? "No notes yet." : walk.description)
                .font(.body)
                .foregroundColor(.skylineText.opacity(0.9))
                .lineSpacing(5)
        }
    }

    private func highlightsSection(_ walk: NightWalk) -> some View {
        SkylinePanel(title: "Highlights", subtitle: "Places you visited") {
            VStack(alignment: .leading, spacing: 10) {
                ForEach(walk.highlights, id: \.self) { highlight in
                    HStack(spacing: 10) {
                        SkylineIconBadge(icon: "star.fill", size: 28, filled: false)
                        Text(highlight)
                            .foregroundColor(.skylineText)
                    }
                }
            }
        }
    }

    private func tagsSection(_ walk: NightWalk) -> some View {
        SkylinePanel(title: "Tags") {
            FlowLayout(spacing: 8) {
                ForEach(walk.tags, id: \.self) { tag in
                    SkylineChip(text: "#\(tag)")
                }
            }
        }
    }

    private func photosSection(_ images: [String]) -> some View {
        SkylinePanel(title: "Photos", subtitle: "Linked images") {
            VStack(spacing: 10) {
                ForEach(images, id: \.self) { link in
                    HStack(spacing: 12) {
                        SkylineIconBadge(icon: "photo", size: 32, filled: false)
                        Text(link)
                            .font(.caption)
                            .foregroundColor(.skylineText)
                            .lineLimit(2)
                        Spacer()
                    }
                    .skylineInsetPanel()
                }
            }
        }
    }

    private func actionButtons(_ walk: NightWalk) -> some View {
        VStack(spacing: 12) {
            SkylinePrimaryButton("Edit walk", icon: "pencil") {
                showEditSheet = true
            }
            SkylineSecondaryButton("Delete", icon: "trash") {
                showDeleteConfirmation = true
            }
        }
    }
}
