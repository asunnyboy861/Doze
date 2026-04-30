import SwiftUI
import SwiftData

struct SessionDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let session: SleepSession

    @State private var startTime: Date
    @State private var endTime: Date
    @State private var hasEndTime: Bool
    @State private var notes: String
    @State private var selectedMood: SleepMood?
    @State private var isEditing = false

    init(session: SleepSession) {
        self.session = session
        _startTime = State(initialValue: session.startTime)
        _endTime = State(initialValue: session.endTime ?? Date())
        _hasEndTime = State(initialValue: session.endTime != nil)
        _notes = State(initialValue: session.notes ?? "")
        _selectedMood = State(initialValue: session.mood)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Sleep Time") {
                    DatePicker("Started", selection: $startTime, displayedComponents: [.date, .hourAndMinute])
                        .disabled(!isEditing)

                    Toggle("Set End Time", isOn: $hasEndTime)
                        .disabled(!isEditing)

                    if hasEndTime {
                        DatePicker("Woke Up", selection: $endTime, in: startTime..., displayedComponents: [.date, .hourAndMinute])
                            .disabled(!isEditing)
                    }
                }

                Section("Duration") {
                    DurationDisplay(duration: currentDuration)
                }

                Section("Mood") {
                    MoodSelector(selectedMood: $selectedMood)
                        .allowsHitTesting(isEditing)
                }

                Section("Notes") {
                    if isEditing {
                        TextEditor(text: $notes)
                            .frame(height: 80)
                    } else {
                        Text(notes.isEmpty ? "No notes" : notes)
                            .foregroundStyle(notes.isEmpty ? .secondary : .primary)
                    }
                }
            }
            .navigationTitle("Session Detail")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    if isEditing {
                        Button("Save") { saveChanges() }
                    } else {
                        Button("Edit") { isEditing = true }
                    }
                }
            }
        }
    }

    private var currentDuration: TimeInterval? {
        guard hasEndTime else { return nil }
        return endTime.timeIntervalSince(startTime)
    }

    private func saveChanges() {
        session.startTime = startTime
        session.endTime = hasEndTime ? endTime : nil
        session.notes = notes.isEmpty ? nil : notes
        session.mood = selectedMood
        session.updatedAt = Date()
        isEditing = false
    }
}
