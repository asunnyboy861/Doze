import SwiftUI

extension Color {
    static let moodGreat = Color.green
    static let moodGood = Color.mint
    static let moodOkay = Color.orange
    static let moodPoor = Color.red
    static let moodTerrible = Color.purple

    static func moodColor(for mood: SleepMood) -> Color {
        switch mood {
        case .great: return .moodGreat
        case .good: return .moodGood
        case .okay: return .moodOkay
        case .poor: return .moodPoor
        case .terrible: return .moodTerrible
        }
    }
}
