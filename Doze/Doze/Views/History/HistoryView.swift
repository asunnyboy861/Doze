import SwiftUI
import SwiftData

struct HistoryView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \SleepSession.startTime, order: .reverse) private var sessions: [SleepSession]
    @State private var selectedSession: SleepSession?
    @State private var showPaywall = false

    private var displaySessions: [SleepSession] {
        if PurchaseManager.shared.isProUser {
            return sessions
        } else {
            let cutoff = Calendar.current.date(byAdding: .day, value: -30, to: Date())!
            return sessions.filter { $0.startTime >= cutoff }
        }
    }

    private var groupedSessions: [(Date, [SleepSession])] {
        let grouped = Dictionary(grouping: displaySessions) { session in
            Calendar.current.startOfDay(for: session.startTime)
        }
        return grouped.sorted { $0.key > $1.key }
    }

    var body: some View {
        NavigationStack {
            List {
                if !PurchaseManager.shared.isProUser && sessions.count > displaySessions.count {
                    Section {
                        Button {
                            showPaywall = true
                        } label: {
                            HStack {
                                Image(systemName: "lock.fill")
                                Text("Unlock full history")
                                Spacer()
                                Image(systemName: "chevron.right")
                            }
                            .foregroundStyle(.blue)
                        }
                    }
                }

                ForEach(groupedSessions, id: \.0) { date, sessionsForDate in
                    Section(header: Text(date.formattedDate)) {
                        ForEach(sessionsForDate) { session in
                            SleepSessionRow(session: session)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    selectedSession = session
                                }
                        }
                        .onDelete { indexSet in
                            deleteSessions(at: indexSet, in: sessionsForDate)
                        }
                    }
                }
            }
            .navigationTitle("History")
            .sheet(item: $selectedSession) { session in
                SessionDetailView(session: session)
            }
            .sheet(isPresented: $showPaywall) {
                PaywallView()
            }
        }
    }

    private func deleteSessions(at offsets: IndexSet, in sessionsForDate: [SleepSession]) {
        for index in offsets {
            let session = sessionsForDate[index]
            Task {
                await HealthKitManager.shared.deleteSleepSession(session)
            }
            modelContext.delete(session)
        }
    }
}
