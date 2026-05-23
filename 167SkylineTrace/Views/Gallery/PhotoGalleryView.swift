import SwiftUI

struct PhotoGalleryView: View {
    @ObservedObject var viewModel: SkylineTraceViewModel

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        SkylineScreenScaffold {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: SkylineLayout.sectionSpacing) {
                    SkylineSectionHeader(
                        title: "Night gallery",
                        subtitle: "\(viewModel.galleryPhotos.count) photo links"
                    )

                    if viewModel.galleryPhotos.isEmpty {
                        SkylineEmptyState(
                            icon: "photo.on.rectangle",
                            title: "Gallery is empty",
                            message: "Add photo links when logging walks to build your visual memory of the city at night."
                        )
                    } else {
                        LazyVStack(spacing: 12) {
                            ForEach(viewModel.galleryPhotos) { photo in
                                NavigationLink {
                                    if let walk = viewModel.walks.first(where: { $0.id == photo.walkId }) {
                                        WalkDetailView(viewModel: viewModel, walk: walk)
                                    }
                                } label: {
                                    PhotoGalleryCell(photo: photo)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
                .skylineContentWidth()
                .skylineScreenPadding()
                .padding(.bottom, 24)
            }
        }
        .skylineScreen(title: "Gallery")
    }
}
