import Foundation
import SwiftData

@Model
final class SleepSession {
    var id: UUID = UUID()
    var startTime: Date = Date()
    var endTime: Date?
    var notes: String?
    var moodRawValue: String?
    var createdAt: Date = Date()
    var updatedAt: Date = Date()

    var mood: SleepMood? {
        get { moodRawValue.flatMap { SleepMood(rawValue: $0) } }
        set { moodRawValue = newValue?.rawValue }
    }

    var duration: TimeInterval? {
        guard let endTime = endTime else { return nil }
        return endTime.timeIntervalSince(startTime)
    }

    var durationText: String {
        guard let duration = duration else { return "In progress" }
        let hours = Int(duration) / 3600
        let minutes = (Int(duration) % 3600) / 60
        return "\(hours)h \(minutes)m"
    }

    init(startTime: Date = Date(), endTime: Date? = nil, notes: String? = nil, mood: SleepMood? = nil) {
        self.id = UUID()
        self.startTime = startTime
        self.endTime = endTime
        self.notes = notes
        self.moodRawValue = mood?.rawValue
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}
