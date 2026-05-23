import SwiftUI

struct AddGoalView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: SkylineTraceViewModel

    @State private var goalKind: GoalKind = .manual
    @State private var title = ""
    @State private var targetWalks = 5
    @State private var targetDistance: Double = 10
    @State private var hasDeadline = false
    @State private var deadline = Date().addingTimeInterval(86400 * 30)

    var body: some View {
        NavigationStack {
            ZStack {
                SkylineBackground()

                Form {
                    Section {
                        Picker("Goal type", selection: $goalKind) {
                            ForEach(GoalKind.allCases, id: \.self) { kind in
                                Text(kind.displayName).tag(kind)
                            }
                        }
                    }

                    if goalKind == .manual {
                        Section {
                            TextField("Goal title", text: $title)
                        }

                        Section(header: Text("Targets").foregroundColor(.gray)) {
                            Stepper("Walks: \(targetWalks)", value: $targetWalks, in: 1...100)
                            HStack {
                                Text("Distance (km)")
                                Spacer()
                                TextField("10", value: $targetDistance, format: .number)
                                    .keyboardType(.decimalPad)
                                    .multilineTextAlignment(.trailing)
                                    .frame(width: 80)
                            }
                        }

                        Section {
                            Toggle("Set deadline", isOn: $hasDeadline)
                                .tint(.skylineAccent)
                            if hasDeadline {
                                DatePicker("Deadline", selection: $deadline, displayedComponents: .date)
                            }
                        }
                    } else {
                        Section(header: Text("Auto-tracking").foregroundColor(.gray)) {
                            Text("Progress updates automatically from your walks.")
                                .font(.caption)
                                .foregroundColor(.gray)

                            if goalKind == .monthlyWalks {
                                Stepper("Target walks: \(targetWalks)", value: $targetWalks, in: 1...100)
                            } else {
                                HStack {
                                    Text("Target km")
                                    Spacer()
                                    TextField("20", value: $targetDistance, format: .number)
                                        .keyboardType(.decimalPad)
                                        .multilineTextAlignment(.trailing)
                                        .frame(width: 80)
                                }
                            }
                        }
                    }
                }
                .scrollContentBackground(.hidden)
                .foregroundColor(.skylineText)
                .accentColor(.skylineAccent)
            }
            .navigationTitle("New goal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(.skylineAccent)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { saveGoal() }
                        .foregroundColor(canSave ? .skylineAccent : .gray)
                        .disabled(!canSave)
                }
            }
        }
        .presentationBackground(Color.skylineBackground)
    }

    private var canSave: Bool {
        if goalKind == .manual {
            return !title.trimmingCharacters(in: .whitespaces).isEmpty
        }
        if goalKind == .monthlyWalks { return targetWalks > 0 }
        return targetDistance > 0
    }

    private func saveGoal() {
        if goalKind == .manual {
            let goal = WalkGoal(
                id: UUID(),
                title: title.trimmingCharacters(in: .whitespaces),
                kind: .manual,
                targetWalks: targetWalks,
                currentWalks: 0,
                targetDistance: targetDistance,
                currentDistance: 0,
                deadline: hasDeadline ? deadline : nil,
                periodStart: nil,
                isCompleted: false,
                createdAt: Date()
            )
            viewModel.addGoal(goal)
        } else {
            viewModel.addAutoGoal(
                kind: goalKind,
                targetWalks: goalKind == .monthlyWalks ? targetWalks : 0,
                targetDistance: goalKind == .monthlyWalks ? 0 : targetDistance
            )
        }
        dismiss()
    }
}
