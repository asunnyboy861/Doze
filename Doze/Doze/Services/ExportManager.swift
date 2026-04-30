import Foundation

@Observable
final class ExportManager {
    enum ExportFormat {
        case csv
        case pdf
    }

    func exportToCSV(sessions: [SleepSession]) -> URL? {
        let header = "Start Time,End Time,Duration (hours),Mood,Notes\n"
        let rows = sessions.compactMap { session -> String? in
            let start = ISO8601DateFormatter().string(from: session.startTime)
            let end = session.endTime.map { ISO8601DateFormatter().string(from: $0) } ?? ""
            let durationHours = session.duration.map { String(format: "%.2f", $0 / 3600) } ?? ""
            let mood = session.mood?.description ?? ""
            let notes = (session.notes ?? "").replacingOccurrences(of: "\"", with: "\"\"")
            let notesEscaped = notes.isEmpty ? "" : "\"\(notes)\""
            return "\(start),\(end),\(durationHours),\(mood),\(notesEscaped)"
        }

        let csvContent = header + rows.joined(separator: "\n")

        let tempDir = FileManager.default.temporaryDirectory
        let fileURL = tempDir.appendingPathComponent("doze_sleep_data.csv")

        do {
            try csvContent.write(to: fileURL, atomically: true, encoding: .utf8)
            return fileURL
        } catch {
            print("CSV export error: \(error)")
            return nil
        }
    }
}
