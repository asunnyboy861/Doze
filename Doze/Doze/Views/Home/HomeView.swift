import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \SleepSession.startTime, order: .reverse) private var sessions: [SleepSession]
    @State private var showQuickLog = false

    private var lastNightSession: SleepSession? {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
        return sessions.first { session in
            session.startTime >= yesterday && session.startTime < today
        }
    }

    private var todaySessions: [SleepSession] {
        let today = Calendar.current.startOfDay(for: Date())
        return sessions.filter { $0.startTime >= today }
    }

    private var todayTotalDuration: TimeInterval {
        todaySessions.compactMap { $0.duration }.reduce(0, +)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    greetingSection

                    if let session = lastNightSession {
                        lastNightCard(session: session)
                    }

                    weeklyChartSection

                    Button {
                        showQuickLog = true
                    } label: {
                        Label("Log Sleep", systemImage: "moon.zzz.fill")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .navigationTitle("Doze")
            .sheet(isPresented: $showQuickLog) {
                QuickLogView()
            }
        }
    }

    private var greetingSection: some View {
        VStack(spacing: 8) {
            Text(greetingText)
                .font(.largeTitle)
                .fontWeight(.bold)
            Text("How did you sleep?")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 20)
    }

    private func lastNightCard(session: SleepSession) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Last Night")
                .font(.headline)
                .foregroundStyle(.secondary)

            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(session.startTime, style: .time)
                        if let endTime = session.endTime {
                            Image(systemName: "arrow.right")
                                .font(.caption2)
                            Text(endTime, style: .time)
                        }
                    }
                    .font(.subheadline)

                    DurationDisplay(duration: session.duration)
                }

                Spacer()

                if let mood = session.mood {
                    Text(mood.emoji)
                        .font(.title)
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal)
    }

    private var weeklyChartSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("This Week")
                .font(.headline)
                .padding(.horizontal)

            WeeklyChartView(sessions: sessions)

            HStack {
                VStack(alignment: .leading) {
                    Text("Average")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(averageDurationText)
                        .font(.title2)
                        .fontWeight(.semibold)
                }
                Spacer()
                VStack(alignment: .trailing) {
                    Text("Total This Week")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(totalWeekDurationText)
                        .font(.title2)
                        .fontWeight(.semibold)
                }
            }
            .padding(.horizontal)
        }
    }

    private var greetingText: String {
        let hour = Calendar.current.component(.hour, from: Date())
        if hour < 12 { return "Good Morning!" }
        if hour < 17 { return "Good Afternoon!" }
        return "Good Evening!"
    }

    private var averageDurationText: String {
        let durations = Date.last7Days.compactMap { day -> TimeInterval? in
            let dayStart = Calendar.current.startOfDay(for: day)
            let dayEnd = Calendar.current.date(byAdding: .day, value: 1, to: dayStart)!
            let dayDuration = sessions
                .filter { $0.startTime >= dayStart && $0.startTime < dayEnd }
                .compactMap { $0.duration }
                .reduce(0, +)
            return dayDuration > 0 ? dayDuration : nil
        }
        guard !durations.isEmpty else { return "--" }
        let avg = durations.reduce(0, +) / Double(durations.count)
        let hours = Int(avg) / 3600
        let minutes = (Int(avg) % 3600) / 60
        return "\(hours)h \(minutes)m"
    }

    private var totalWeekDurationText: String {
        let total = Date.last7Days.map { day -> TimeInterval in
            let dayStart = Calendar.current.startOfDay(for: day)
            let dayEnd = Calendar.current.date(byAdding: .day, value: 1, to: dayStart)!
            return sessions
                .filter { $0.startTime >= dayStart && $0.startTime < dayEnd }
                .compactMap { $0.duration }
                .reduce(0, +)
        }.reduce(0, +)
        let hours = Int(total) / 3600
        return "\(hours)h"
    }
}
