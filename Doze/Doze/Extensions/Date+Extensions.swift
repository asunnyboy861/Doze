import Foundation

extension Date {
    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }

    var endOfDay: Date {
        Calendar.current.date(byAdding: .day, value: 1, to: startOfDay) ?? self
    }

    var weekdayShort: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter.string(from: self)
    }

    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        return formatter.string(from: self)
    }

    var formattedTime: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: self)
    }

    var isToday: Bool {
        Calendar.current.isDateInToday(self)
    }

    var isYesterday: Bool {
        Calendar.current.isDateInYesterday(self)
    }

    static var last7Days: [Date] {
        (0..<7).reversed().compactMap { offset in
            Calendar.current.date(byAdding: .day, value: -offset, to: Date())
        }
    }

    static var last30Days: [Date] {
        (0..<30).reversed().compactMap { offset in
            Calendar.current.date(byAdding: .day, value: -offset, to: Date())
        }
    }
}
