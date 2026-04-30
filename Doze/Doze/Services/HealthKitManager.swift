import HealthKit

@Observable
final class HealthKitManager {
    static let shared = HealthKitManager()

    private let healthStore = HKHealthStore()
    private let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!

    var isAuthorized = false

    private init() {}

    var isHealthDataAvailable: Bool {
        HKHealthStore.isHealthDataAvailable()
    }

    func requestAuthorization() async throws {
        guard isHealthDataAvailable else { return }

        try await healthStore.requestAuthorization(
            toShare: [sleepType],
            read: [sleepType]
        )
        isAuthorized = true
    }

    func saveSleepSession(_ session: SleepSession) async {
        guard isAuthorized, let endTime = session.endTime else { return }

        let sleepSample = HKCategorySample(
            type: sleepType,
            value: HKCategoryValueSleepAnalysis.asleepUnspecified.rawValue,
            start: session.startTime,
            end: endTime
        )

        do {
            try await healthStore.save(sleepSample)
        } catch {
            print("HealthKit save error: \(error)")
        }
    }

    func deleteSleepSession(_ session: SleepSession) async {
        guard isAuthorized, let endTime = session.endTime else { return }

        let predicate = HKQuery.predicateForSamples(
            withStart: session.startTime.addingTimeInterval(-1),
            end: endTime.addingTimeInterval(1),
            options: .strictStartDate
        )

        let query = HKSampleQuery(
            sampleType: sleepType,
            predicate: predicate,
            limit: HKObjectQueryNoLimit,
            sortDescriptors: nil
        ) { [weak self] _, samples, error in
            guard let samples = samples as? [HKCategorySample], !samples.isEmpty else { return }
            self?.healthStore.delete(samples) { _, _ in }
        }

        healthStore.execute(query)
    }
}
