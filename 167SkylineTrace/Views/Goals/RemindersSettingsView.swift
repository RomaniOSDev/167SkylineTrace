import SwiftUI

struct RemindersSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: SkylineTraceViewModel

    @State private var settings: ReminderSettings

    private let weekdayLabels = [
        (1, "Sun"), (2, "Mon"), (3, "Tue"), (4, "Wed"),
        (5, "Thu"), (6, "Fri"), (7, "Sat")
    ]

    init(viewModel: SkylineTraceViewModel) {
        self.viewModel = viewModel
        _settings = State(initialValue: viewModel.reminderSettings)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                SkylineBackground()

                Form {
                    Section {
                        Toggle("Enable reminders", isOn: $settings.isEnabled)
                            .tint(.skylineAccent)
                    }

                    Section(header: Text("Time").foregroundColor(.gray)) {
                        Stepper("Hour: \(settings.hour)", value: $settings.hour, in: 0...23)
                        Stepper("Minute: \(settings.minute)", value: $settings.minute, in: 0...59, step: 5)
                    }

                    Section(header: Text("Weekdays").foregroundColor(.gray)) {
                        ForEach(weekdayLabels, id: \.0) { day, label in
                            Toggle(label, isOn: weekdayBinding(day))
                                .tint(.skylineAccent)
                        }
                    }
                }
                .scrollContentBackground(.hidden)
                .foregroundColor(.skylineText)
                .accentColor(.skylineAccent)
            }
            .navigationTitle("Reminders")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(.skylineAccent)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .foregroundColor(.skylineAccent)
                }
            }
        }
        .presentationBackground(Color.skylineBackground)
    }

    private func weekdayBinding(_ day: Int) -> Binding<Bool> {
        Binding(
            get: { settings.weekdays.contains(day) },
            set: { isOn in
                if isOn {
                    settings.weekdays.insert(day)
                } else {
                    settings.weekdays.remove(day)
                }
            }
        )
    }

    private func save() {
        WalkNotificationService.requestAuthorization { _ in
            viewModel.updateReminders(settings)
            dismiss()
        }
    }
}
