import SwiftUI

struct WalksFeedView: View {
    @ObservedObject var viewModel: SkylineTraceViewModel
    @State private var showAddWalkSheet = false
    @State private var showFilterSheet = false
    @State private var showTemplates = false

    var body: some View {
        SkylineScreenScaffold {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: SkylineLayout.sectionSpacing) {
                    summaryHeader
                    SkylineSearchField(text: $viewModel.searchText, placeholder: "Search walks, tags, places...")
                    SkylineSortBar(selection: $viewModel.sortOption)
                    statsScroll
                    SkylineQuoteCard(quote: viewModel.currentQuote) {
                        viewModel.refreshQuote()
                    }
                    walksSection
                    SkylinePrimaryButton("New walk", icon: "plus") {
                        showAddWalkSheet = true
                    }
                }
                .skylineContentWidth()
                .skylineScreenPadding()
                .padding(.bottom, 24)
            }
        }
        .skylineScreen(title: "Night Walks")
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                HStack(spacing: 16) {
                    toolbarButton(
                        icon: viewModel.hasActiveFilters ? "line.3.horizontal.decrease.circle.fill" : "line.3.horizontal.decrease.circle",
                        action: { showFilterSheet = true }
                    )
                    toolbarButton(icon: "doc.on.doc", action: { showTemplates = true })
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button { showAddWalkSheet = true } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(.white, Color.skylineAccent)
                }
            }
        }
        .sheet(isPresented: $showAddWalkSheet) { AddWalkView(viewModel: viewModel) }
        .sheet(isPresented: $showFilterSheet) { WalkFilterSheet(viewModel: viewModel) }
        .sheet(isPresented: $showTemplates) {
            NavigationStack { WalkTemplatesView(viewModel: viewModel) }
        }
        .onAppear { viewModel.refreshQuote() }
    }

    private var summaryHeader: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Your city after dark")
                .font(.subheadline)
                .foregroundColor(.skylineMuted)
            Text(summarySubtitle)
                .font(.caption.weight(.semibold))
                .foregroundColor(.skylineAccent)
        }
    }

    @ViewBuilder
    private var walksSection: some View {
        SkylineSectionHeader(
            title: "Recent walks",
            subtitle: "\(viewModel.displayedWalks.count) shown",
            actionTitle: viewModel.hasActiveFilters ? "Clear" : nil,
            action: viewModel.hasActiveFilters ? { viewModel.clearFilters() } : nil
        )

        if viewModel.displayedWalks.isEmpty {
            SkylineEmptyState(
                icon: "figure.walk",
                title: "No walks found",
                message: emptyMessage,
                buttonTitle: viewModel.hasActiveFilters ? nil : "Log first walk",
                action: viewModel.hasActiveFilters ? nil : { showAddWalkSheet = true }
            )
        } else {
            ForEach(viewModel.displayedWalks) { walk in
                NavigationLink {
                    WalkDetailView(viewModel: viewModel, walk: walk)
                } label: {
                    WalkCard(walk: walk)
                }
                .buttonStyle(.plain)
                .contextMenu { walkContextMenu(walk) }
            }
        }
    }

    @ViewBuilder
    private func walkContextMenu(_ walk: NightWalk) -> some View {
        Button { viewModel.toggleFavorite(walk) } label: {
            Label(walk.isFavorite ? "Remove favorite" : "Favorite", systemImage: "star")
        }
        Button {
            viewModel.saveTemplate(from: walk, name: "\(walk.title) template")
        } label: {
            Label("Save as template", systemImage: "doc.on.doc")
        }
        Button(role: .destructive) { viewModel.deleteWalk(walk) } label: {
            Label("Delete", systemImage: "trash")
        }
    }

    private func toolbarButton(icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.body.weight(.medium))
                .foregroundColor(.skylineAccent)
                .padding(8)
                .background(Circle().fill(Color.skylineAccent.opacity(0.12)))
        }
    }

    private var emptyMessage: String {
        if viewModel.hasActiveFilters || !viewModel.searchText.isEmpty {
            return "No walks match your search or filters."
        }
        return "Start logging your night walks to see them here."
    }

    private var summarySubtitle: String {
        String(format: "%d walks • %.1f km • %d h", viewModel.totalWalks, viewModel.totalDistance, viewModel.totalHours)
    }

    private var statsScroll: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                StatCard(title: "Walks", value: "\(viewModel.totalWalks)", icon: "figure.walk", color: .skylineAccent).frame(width: 150)
                StatCard(title: "Kilometers", value: String(format: "%.1f", viewModel.totalDistance), icon: "map.fill", color: .skylineAccent).frame(width: 150)
                StatCard(title: "Hours", value: "\(viewModel.totalHours)", icon: "clock.fill", color: .skylineAccent).frame(width: 150)
                StatCard(title: "Streak", value: "\(viewModel.streakDays)", icon: "flame.fill", color: .skylineAccent).frame(width: 150)
            }
        }
    }
}
