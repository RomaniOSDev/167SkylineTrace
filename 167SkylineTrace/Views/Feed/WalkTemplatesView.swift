import SwiftUI

struct WalkTemplatesView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: SkylineTraceViewModel
    @State private var showAddWalk = false
    @State private var selectedTemplate: WalkTemplate?

    var body: some View {
        ZStack {
            SkylineBackground()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: SkylineLayout.sectionSpacing) {
                    SkylineSectionHeader(
                        title: "Walk templates",
                        subtitle: "Reuse your favorite night walk setups"
                    )

                    if viewModel.templates.isEmpty {
                        SkylineEmptyState(
                            icon: "doc.on.doc",
                            title: "No templates",
                            message: "Save any walk as a template from the feed or detail screen."
                        )
                    } else {
                        ForEach(viewModel.templates) { template in
                            TemplateCell(template: template)
                                .onTapGesture {
                                    selectedTemplate = template
                                    showAddWalk = true
                                }
                                .contextMenu {
                                    Button {
                                        selectedTemplate = template
                                        showAddWalk = true
                                    } label: {
                                        Label("Use template", systemImage: "plus.circle")
                                    }
                                    Button(role: .destructive) {
                                        viewModel.deleteTemplate(template)
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                        }
                    }
                }
                .skylineContentWidth()
                .skylineScreenPadding()
            }
        }
        .skylineScreen(title: "Templates")
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Done") { dismiss() }
                    .foregroundColor(.skylineAccent)
            }
        }
        .sheet(isPresented: $showAddWalk) {
            if let template = selectedTemplate {
                AddWalkView(viewModel: viewModel, template: template)
            }
        }
    }
}
