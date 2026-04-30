import SwiftUI
import Charts

struct WeeklyChartView: View {
    let sessions: [SleepSession]

    var body: some View {
        Chart {
            ForEach(Date.last7Days, id: \.self) { date in
                let duration = totalDuration(for: date)
                if duration > 0 {
                    BarMark(
                        x: .value("Day", date.weekdayShort),
                        y: .value("Hours", duration / 3600)
                    )
                    .foregroundStyle(Color.blue.gradient)
                    .cornerRadius(4)
                }
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading) {
                AxisGridLine()
                AxisValueLabel()
            }
        }
        .chartXAxis {
            AxisMarks { _ in
                AxisValueLabel()
            }
        }
        .frame(height: 180)
        .padding(.horizontal)
    }

    private func totalDuration(for date: Date) -> TimeInterval {
        let dayStart = Calendar.current.startOfDay(for: date)
        let dayEnd = Calendar.current.date(byAdding: .day, value: 1, to: dayStart)!
        return sessions
            .filter { $0.startTime >= dayStart && $0.startTime < dayEnd }
            .compactMap { $0.duration }
            .reduce(0, +)
    }
}
