import SwiftUI
import SwiftData

struct QuickLogView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var startTime = Date().addingTimeInterval(-8 * 3600)
    @State private var endTime = Date()
    @State private var showEndTime = true
    @State private var notes = ""
    @State private var selectedMood: SleepMood?

    var body: some View {
        NavigationStack {
            Form {
                Section("Sleep Time") {
                    DatePicker(
                        "Started",
                        selection: $startTime,
                        displayedComponents: [.date, .hourAndMinute]
                    )

                    Toggle("Set End Time", isOn: $showEndTime)

                    if showEndTime {
                        DatePicker(
                            "Woke Up",
                            selection: $endTime,
                            in: startTime...,
                            displayedComponents: [.date, .hourAndMinute]
                        )
                    }
                }

                Section("How did you sleep?") {
                    MoodSelector(selectedMood: $selectedMood)
                }

                Section("Notes (Optional)") {
                    TextEditor(text: $notes)
                        .frame(height: 80)
                }
            }
            .navigationTitle("Log Sleep")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { saveSession() }
                        .disabled(!isValid)
                }
            }
        }
    }

    private var isValid: Bool {
        if showEndTime {
            return endTime > startTime
        }
        return true
    }

    private func saveSession() {
        let session = SleepSession(
            startTime: startTime,
            endTime: showEndTime ? endTime : nil,
            notes: notes.isEmpty ? nil : notes,
            mood: selectedMood
        )
        modelContext.insert(session)

        Task {
            try? await HealthKitManager.shared.requestAuthorization()
            await HealthKitManager.shared.saveSleepSession(session)
        }

        dismiss()
    }
}
