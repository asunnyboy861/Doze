import SwiftUI
import SwiftData

@main
struct DozeApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: SleepSession.self)
    }
}
