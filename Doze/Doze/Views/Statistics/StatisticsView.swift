import SwiftUI
import SwiftData
import Charts

struct StatisticsView: View {
    @Query(sort: \SleepSession.startTime, order: .reverse) private var sessions: [SleepSession]
    @State private var selectedPeriod = 0
    @State private var showPaywall = false

    private var isProUser: Bool { PurchaseManager.shared.isProUser }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    Picker("Period", selection: $selectedPeriod) {
                        Text("Week").tag(0)
                        Text("Month").tag(1)
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)

                    if selectedPeriod == 0 || isProUser {
                        weeklyStatsSection
                    }

                    if isProUser {
                        monthlyStatsSection
                    } else if selectedPeriod == 1 {
                        paywallOverlay
                    }

                    if isProUser {
                        insightsSection
                    }

                    if isProUser {
                        exportButton
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Statistics")
        }
    }

    private var weeklyStatsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("This Week")
                .font(.headline)
                .padding(.horizontal)

            WeeklyChartView(sessions: sessions)

            HStack {
                StatItem(title: "Average", value: weeklyAverageText)
                Spacer()
                StatItem(title: "Best Night", value: weeklyBestText)
                Spacer()
                StatItem(title: "Total", value: weeklyTotalText)
            }
            .padding(.horizontal)
        }
    }

    private var monthlyStatsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("This Month")
                .font(.headline)
                .padding(.horizontal)

            Chart {
                ForEach(Date.last30Days, id: \.self) { date in
                    let duration = totalDuration(for: date)
                    if duration > 0 {
                        LineMark(
                            x: .value("Day", date, unit: .day),
                            y: .value("Hours", duration / 3600)
                        )
                        .foregroundStyle(Color.blue)
                        .interpolationMethod(.catmullRom)
                    }
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading) {
                    AxisGridLine()
                    AxisValueLabel()
                }
            }
            .frame(height: 180)
            .padding(.horizontal)

            HStack {
                StatItem(title: "Average", value: monthlyAverageText)
                Spacer()
                StatItem(title: "Best Night", value: monthlyBestText)
            }
            .padding(.horizontal)
        }
    }

    private var insightsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Insights")
                .font(.headline)
                .padding(.horizontal)

            VStack(spacing: 8) {
                InsightRow(icon: "moon.zzz.fill", color: .blue, text: bestDayInsight)
                InsightRow(icon: "face.smiling", color: .green, text: moodInsight)
            }
            .padding(.horizontal)
        }
    }

    private var paywallOverlay: some View {
        VStack(spacing: 12) {
            Image(systemName: "lock.fill")
                .font(.largeTitle)
                .foregroundStyle(.secondary)
            Text("Monthly trends require Doze Premium")
                .font(.headline)
            Button("Upgrade") {
                showPaywall = true
            }
            .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity)
        .padding(40)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal)
        .sheet(isPresented: $showPaywall) {
            PaywallView()
        }
    }

    private var exportButton: some View {
        Button {
            exportData()
        } label: {
            Label("Export Data", systemImage: "square.and.arrow.up")
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
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

    private var weeklyAverageText: String {
        let durations = Date.last7Days.compactMap { day -> TimeInterval? in
            let d = totalDuration(for: day)
            return d > 0 ? d : nil
        }
        guard !durations.isEmpty else { return "--" }
        let avg = durations.reduce(0, +) / Double(durations.count)
        return formatDuration(avg)
    }

    private var weeklyBestText: String {
        let best = Date.last7Days.map { totalDuration(for: $0) }.max() ?? 0
        return best > 0 ? formatDuration(best) : "--"
    }

    private var weeklyTotalText: String {
        let total = Date.last7Days.map { totalDuration(for: $0) }.reduce(0, +)
        return total > 0 ? formatDuration(total) : "--"
    }

    private var monthlyAverageText: String {
        let durations = Date.last30Days.compactMap { day -> TimeInterval? in
            let d = totalDuration(for: day)
            return d > 0 ? d : nil
        }
        guard !durations.isEmpty else { return "--" }
        let avg = durations.reduce(0, +) / Double(durations.count)
        return formatDuration(avg)
    }

    private var monthlyBestText: String {
        let best = Date.last30Days.map { totalDuration(for: $0) }.max() ?? 0
        return best > 0 ? formatDuration(best) : "--"
    }

    private var bestDayInsight: String {
        return "You tend to sleep longer on weekends"
    }

    private var moodInsight: String {
        let goodMoodCount = sessions.filter { $0.mood == .great || $0.mood == .good }.count
        let totalMood = sessions.filter { $0.mood != nil }.count
        if totalMood == 0 { return "Log your mood to see insights" }
        let pct = Int(Double(goodMoodCount) / Double(totalMood) * 100)
        return "\(pct)% of nights you felt good or great"
    }

    private func formatDuration(_ duration: TimeInterval) -> String {
        let hours = Int(duration) / 3600
        let minutes = (Int(duration) % 3600) / 60
        return "\(hours)h \(minutes)m"
    }

    private func exportData() {
        let url = ExportManager().exportToCSV(sessions: sessions)
        if let url = url {
            let activityVC = UIActivityViewController(activityItems: [url], applicationActivities: nil)
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let rootVC = windowScene.windows.first?.rootViewController {
                rootVC.present(activityVC, animated: true)
            }
        }
    }
}

struct StatItem: View {
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.title3)
                .fontWeight(.semibold)
        }
    }
}

struct InsightRow: View {
    let icon: String
    let color: Color
    let text: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(color)
                .frame(width: 32)
            Text(text)
                .font(.subheadline)
            Spacer()
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}
