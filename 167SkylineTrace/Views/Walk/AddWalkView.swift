import SwiftUI

struct AddWalkView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: SkylineTraceViewModel

    let editingWalk: NightWalk?
    let template: WalkTemplate?

    @State private var title = ""
    @State private var selectedRouteId: UUID?
    @State private var customRouteName = ""
    @State private var description = ""
    @State private var distance: Double = 0
    @State private var duration = 30
    @State private var mood: WalkMood = .peaceful
    @State private var difficulty: WalkDifficulty = .easy
    @State private var neighborhood: Neighborhood = .downtown
    @State private var weather: WalkWeather?
    @State private var highlights: [String] = []
    @State private var tagsString = ""
    @State private var rating: Int?
    @State private var isFavorite = false
    @State private var photoLinks = ""
    @State private var saveAsTemplate = false
    @State private var templateName = ""

    private var isEditing: Bool { editingWalk != nil }

    init(viewModel: SkylineTraceViewModel, editingWalk: NightWalk? = nil, template: WalkTemplate? = nil) {
        self.viewModel = viewModel
        self.editingWalk = editingWalk
        self.template = template

        if let walk = editingWalk {
            _title = State(initialValue: walk.title)
            _selectedRouteId = State(initialValue: walk.routeId)
            _customRouteName = State(initialValue: walk.routeName ?? "")
            _description = State(initialValue: walk.description)
            _distance = State(initialValue: walk.distance)
            _duration = State(initialValue: walk.duration)
            _mood = State(initialValue: walk.mood)
            _difficulty = State(initialValue: walk.difficulty)
            _neighborhood = State(initialValue: walk.neighborhood)
            _weather = State(initialValue: walk.weather)
            _highlights = State(initialValue: walk.highlights.isEmpty ? [""] : walk.highlights)
            _tagsString = State(initialValue: walk.tags.joined(separator: ", "))
            _rating = State(initialValue: walk.rating)
            _isFavorite = State(initialValue: walk.isFavorite)
            _photoLinks = State(initialValue: walk.imageNames?.joined(separator: ", ") ?? "")
        } else if let template {
            _title = State(initialValue: template.title)
            _selectedRouteId = State(initialValue: template.routeId)
            _customRouteName = State(initialValue: template.routeName ?? "")
            _description = State(initialValue: template.description)
            _distance = State(initialValue: template.distance)
            _duration = State(initialValue: template.duration)
            _mood = State(initialValue: template.mood)
            _difficulty = State(initialValue: template.difficulty)
            _neighborhood = State(initialValue: template.neighborhood)
            _weather = State(initialValue: template.weather)
            _highlights = State(initialValue: template.highlights.isEmpty ? [""] : template.highlights)
            _tagsString = State(initialValue: template.tags.joined(separator: ", "))
            _photoLinks = State(initialValue: template.imageNames?.joined(separator: ", ") ?? "")
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                SkylineBackground()

                Form {
                    Section {
                        TextField("Title", text: $title)

                        Picker("Saved route", selection: $selectedRouteId) {
                            Text("None").tag(Optional<UUID>.none)
                            ForEach(viewModel.routes) { route in
                                Text(route.name).tag(Optional(route.id))
                            }
                        }
                        .onChange(of: selectedRouteId) { newValue in
                            applyRouteDefaults(newValue)
                        }

                        if selectedRouteId == nil {
                            TextField("Custom route name", text: $customRouteName)
                        }

                        ZStack(alignment: .topLeading) {
                            if description.isEmpty {
                                Text("Impressions")
                                    .foregroundColor(.gray.opacity(0.6))
                                    .padding(.top, 8)
                                    .padding(.leading, 4)
                            }
                            TextEditor(text: $description)
                                .frame(height: 100)
                        }
                    }

                    Section(header: sectionHeader("Route")) {
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
                            Stepper("\(duration)", value: $duration, in: 5...300, step: 5)
                        }

                        Picker("Neighborhood", selection: $neighborhood) {
                            ForEach(Neighborhood.allCases, id: \.self) { hood in
                                Label(hood.displayName, systemImage: hood.icon).tag(hood)
                            }
                        }
                    }

                    Section(header: sectionHeader("Mood & weather")) {
                        Picker("Mood", selection: $mood) {
                            ForEach(WalkMood.allCases, id: \.self) { item in
                                Label(item.displayName, systemImage: item.icon).tag(item)
                            }
                        }

                        Picker("Difficulty", selection: $difficulty) {
                            ForEach(WalkDifficulty.allCases, id: \.self) { item in
                                Label(item.displayName, systemImage: item.icon).tag(item)
                            }
                        }

                        Picker("Weather", selection: $weather) {
                            Text("—").tag(Optional<WalkWeather>.none)
                            ForEach(WalkWeather.allCases, id: \.self) { item in
                                Label(item.displayName, systemImage: item.icon).tag(Optional(item))
                            }
                        }
                    }

                    Section(header: sectionHeader("Highlights")) {
                        ForEach($highlights.indices, id: \.self) { index in
                            HStack {
                                TextField("Place", text: $highlights[index])
                                Button {
                                    highlights.remove(at: index)
                                } label: {
                                    Image(systemName: "minus.circle")
                                        .foregroundColor(.skylineAccent)
                                }
                            }
                        }
                        Button("Add place") { highlights.append("") }
                            .foregroundColor(.skylineAccent)
                    }

                    Section(header: sectionHeader("Tags")) {
                        TextField("Tags separated by commas", text: $tagsString)
                    }

                    Section(header: sectionHeader("Photo links")) {
                        TextField("Image URLs or names, comma-separated", text: $photoLinks)
                    }

                    Section(header: sectionHeader("Rating")) {
                        Picker("Rating", selection: $rating) {
                            Text("—").tag(nil as Int?)
                            ForEach(1...5, id: \.self) { value in
                                Text(String(repeating: "★", count: value)).tag(value as Int?)
                            }
                        }
                        .pickerStyle(.segmented)
                    }

                    Section {
                        Toggle("Add to favorites", isOn: $isFavorite)
                            .tint(.skylineAccent)
                    }

                    if !isEditing {
                        Section(header: sectionHeader("Template")) {
                            Toggle("Save as template", isOn: $saveAsTemplate)
                                .tint(.skylineAccent)
                            if saveAsTemplate {
                                TextField("Template name", text: $templateName)
                            }
                        }
                    }
                }
                .scrollContentBackground(.hidden)
                .foregroundColor(.skylineText)
                .accentColor(.skylineAccent)
            }
            .navigationTitle(isEditing ? "Edit walk" : "New walk")
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
                    Button("Save") { saveWalk() }
                        .foregroundColor(title.trimmingCharacters(in: .whitespaces).isEmpty ? .gray : .skylineAccent)
                        .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
        .presentationBackground(Color.skylineBackground)
    }

    private func sectionHeader(_ text: String) -> some View {
        Text(text).foregroundColor(.gray)
    }

    private func applyRouteDefaults(_ routeId: UUID?) {
        guard let routeId, let route = viewModel.routes.first(where: { $0.id == routeId }) else { return }
        customRouteName = route.name
        distance = route.distance
        duration = route.estimatedDuration
        if let first = route.neighborhoods.first {
            neighborhood = first
        }
    }

    private func resolvedRouteName() -> String? {
        if let selectedRouteId, let name = viewModel.routeName(for: selectedRouteId) {
            return name
        }
        let custom = customRouteName.trimmingCharacters(in: .whitespaces)
        return custom.isEmpty ? nil : custom
    }

    private func saveWalk() {
        let tags = tagsString.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty }
        let filteredHighlights = highlights.map { $0.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty }
        let images = photoLinks.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty }

        if var existing = editingWalk {
            existing.title = title.trimmingCharacters(in: .whitespaces)
            existing.routeId = selectedRouteId
            existing.routeName = resolvedRouteName()
            existing.description = description
            existing.distance = distance
            existing.duration = duration
            existing.mood = mood
            existing.difficulty = difficulty
            existing.neighborhood = neighborhood
            existing.weather = weather
            existing.highlights = filteredHighlights
            existing.tags = tags
            existing.imageNames = images.isEmpty ? nil : images
            existing.rating = rating
            existing.isFavorite = isFavorite
            viewModel.updateWalk(existing)
        } else {
            let walk = NightWalk(
                id: UUID(),
                date: Date(),
                title: title.trimmingCharacters(in: .whitespaces),
                routeId: selectedRouteId,
                routeName: resolvedRouteName(),
                distance: distance,
                duration: duration,
                mood: mood,
                difficulty: difficulty,
                neighborhood: neighborhood,
                weather: weather,
                description: description,
                highlights: filteredHighlights,
                tags: tags,
                imageNames: images.isEmpty ? nil : images,
                rating: rating,
                isFavorite: isFavorite,
                createdAt: Date()
            )
            viewModel.addWalk(walk)

            if saveAsTemplate {
                let name = templateName.trimmingCharacters(in: .whitespaces)
                viewModel.saveTemplate(from: walk, name: name.isEmpty ? walk.title : name)
            }
        }

        dismiss()
    }
}
