import SwiftUI

struct SettingsView: View {
    @AppStorage("useCloudKit") private var useCloudKit = false
    @AppStorage("bedtimeReminderEnabled") private var bedtimeReminderEnabled = false
    @AppStorage("bedtimeHour") private var bedtimeHour = 22
    @AppStorage("bedtimeMinute") private var bedtimeMinute = 0
    @State private var showPaywall = false
    @State private var showContactSupport = false

    private let supportURL = "https://asunnyboy861.github.io/Doze/support.html"
    private let privacyURL = "https://asunnyboy861.github.io/Doze/privacy.html"
    private let termsURL = "https://asunnyboy861.github.io/Doze/terms.html"

    var body: some View {
        NavigationStack {
            Form {
                if !PurchaseManager.shared.isProUser {
                    Section {
                        Button {
                            showPaywall = true
                        } label: {
                            HStack {
                                Image(systemName: "crown.fill")
                                    .foregroundStyle(.yellow)
                                Text("Upgrade to Premium")
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }

                Section("Sync") {
                    Toggle("iCloud Sync", isOn: $useCloudKit)
                        .disabled(!PurchaseManager.shared.isProUser)
                    Text("Sync your sleep data across all devices")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Section("Reminders") {
                    Toggle("Bedtime Reminder", isOn: $bedtimeReminderEnabled)
                    if bedtimeReminderEnabled {
                        DatePicker(
                            "Remind at",
                            selection: Binding(
                                get: {
                                    let cal = Calendar.current
                                    var comps = DateComponents()
                                    comps.hour = bedtimeHour
                                    comps.minute = bedtimeMinute
                                    return cal.date(from: comps) ?? Date()
                                },
                                set: { date in
                                    let cal = Calendar.current
                                    bedtimeHour = cal.component(.hour, from: date)
                                    bedtimeMinute = cal.component(.minute, from: date)
                                }
                            ),
                            displayedComponents: .hourAndMinute
                        )
                    }
                }

                Section("Health") {
                    Button("Enable HealthKit Sync") {
                        Task {
                            try? await HealthKitManager.shared.requestAuthorization()
                        }
                    }
                }

                Section("Links") {
                    Link("Support", destination: URL(string: supportURL)!)
                    Link("Privacy Policy", destination: URL(string: privacyURL)!)
                    Link("Terms of Use", destination: URL(string: termsURL)!)
                }

                Section("Support") {
                    Button("Contact Us") {
                        showContactSupport = true
                    }
                }

                if PurchaseManager.shared.isProUser {
                    Section("Subscription") {
                        Button("Restore Purchases") {
                            Task {
                                await PurchaseManager.shared.restorePurchases()
                            }
                        }
                    }
                }

                Section("About") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("Settings")
            .sheet(isPresented: $showPaywall) {
                PaywallView()
            }
            .sheet(isPresented: $showContactSupport) {
                ContactSupportView()
            }
            .onChange(of: bedtimeReminderEnabled) { _, newValue in
                if newValue {
                    Task {
                        try? await NotificationManager.shared.requestAuthorization()
                        await NotificationManager.shared.scheduleBedtimeReminder(at: bedtimeHour, minute: bedtimeMinute)
                    }
                } else {
                    NotificationManager.shared.removeBedtimeReminder()
                }
            }
        }
    }
}
