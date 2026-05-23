import SwiftUI

struct AddRouteView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: SkylineTraceViewModel

    let editingRoute: WalkRoute?

    @State private var name = ""
    @State private var startPoint = ""
    @State private var endPoint = ""
    @State private var distance: Double = 0
    @State private var estimatedDuration = 30
    @State private var selectedNeighborhoods: Set<Neighborhood> = []
    @State private var description = ""
    @State private var isFavorite = false

    private var isEditing: Bool { editingRoute != nil }

    init(viewModel: SkylineTraceViewModel, editingRoute: WalkRoute? = nil) {
        self.viewModel = viewModel
        self.editingRoute = editingRoute

        if let route = editingRoute {
            _name = State(initialValue: route.name)
            _startPoint = State(initialValue: route.startPoint)
            _endPoint = State(initialValue: route.endPoint)
            _distance = State(initialValue: route.distance)
            _estimatedDuration = State(initialValue: route.estimatedDuration)
            _selectedNeighborhoods = State(initialValue: Set(route.neighborhoods))
            _description = State(initialValue: route.description)
            _isFavorite = State(initialValue: route.isFavorite)
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                SkylineBackground()

                Form {
                    Section {
                        TextField("Route name", text: $name)
                        TextField("Start point", text: $startPoint)
                        TextField("End point", text: $endPoint)
                        ZStack(alignment: .topLeading) {
                            if description.isEmpty {
                                Text("Description")
                                    .foregroundColor(.gray.opacity(0.6))
                                    .padding(.top, 8)
                                    .padding(.leading, 4)
                            }
                            TextEditor(text: $description)
                                .frame(height: 80)
                        }
                    }

                    Section(header: Text("Details").foregroundColor(.gray)) {
                        HStack {
                            Text("Distance (km)")
                            Spacer()
                            TextField("0", value: $distance, format: .number)
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.trailing)
                                .frame(width: 80)
                        }

                        HStack {
                            Text("Duration (min)")
                            Spacer()
                            Stepper("\(estimatedDuration)", value: $estimatedDuration, in: 5...300, step: 5)
                        }
                    }

                    Section(header: Text("Neighborhoods").foregroundColor(.gray)) {
                        ForEach(Neighborhood.allCases, id: \.self) { hood in
                            Toggle(isOn: binding(for: hood)) {
                                Label(hood.displayName, systemImage: hood.icon)
                            }
                            .tint(.skylineAccent)
                        }
                    }

                    Section {
                        Toggle("Add to favorites", isOn: $isFavorite)
                            .tint(.skylineAccent)
                    }
                }
                .scrollContentBackground(.hidden)
                .foregroundColor(.skylineText)
                .accentColor(.skylineAccent)
            }
            .navigationTitle(isEditing ? "Edit route" : "New route")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbarBackground(Color.skylineBackground, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(.skylineAccent)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { saveRoute() }
                        .foregroundColor(canSave ? .skylineAccent : .gray)
                        .disabled(!canSave)
                }
            }
        }
        .presentationBackground(Color.skylineBackground)
    }

    private var canSave: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty &&
        !startPoint.trimmingCharacters(in: .whitespaces).isEmpty &&
        !endPoint.trimmingCharacters(in: .whitespaces).isEmpty
    }

    private func binding(for neighborhood: Neighborhood) -> Binding<Bool> {
        Binding(
            get: { selectedNeighborhoods.contains(neighborhood) },
            set: { isOn in
                if isOn {
                    selectedNeighborhoods.insert(neighborhood)
                } else {
                    selectedNeighborhoods.remove(neighborhood)
                }
            }
        )
    }

    private func saveRoute() {
        let neighborhoods = Array(selectedNeighborhoods)

        if var existing = editingRoute {
            existing.name = name.trimmingCharacters(in: .whitespaces)
            existing.startPoint = startPoint.trimmingCharacters(in: .whitespaces)
            existing.endPoint = endPoint.trimmingCharacters(in: .whitespaces)
            existing.distance = distance
            existing.estimatedDuration = estimatedDuration
            existing.neighborhoods = neighborhoods
            existing.description = description
            existing.isFavorite = isFavorite
            viewModel.updateRoute(existing)
        } else {
            let route = WalkRoute(
                id: UUID(),
                name: name.trimmingCharacters(in: .whitespaces),
                startPoint: startPoint.trimmingCharacters(in: .whitespaces),
                endPoint: endPoint.trimmingCharacters(in: .whitespaces),
                distance: distance,
                estimatedDuration: estimatedDuration,
                neighborhoods: neighborhoods,
                description: description,
                isFavorite: isFavorite
            )
            viewModel.addRoute(route)
        }

        dismiss()
    }
}
