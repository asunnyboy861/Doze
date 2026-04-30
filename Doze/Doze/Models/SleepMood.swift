import Foundation

enum SleepMood: String, Codable, CaseIterable {
    case great = "great"
    case good = "good"
    case okay = "okay"
    case poor = "poor"
    case terrible = "terrible"

    var emoji: String {
        switch self {
        case .great: return "\u{1F60A}"
        case .good: return "\u{1F642}"
        case .okay: return "\u{1F610}"
        case .poor: return "\u{1F614}"
        case .terrible: return "\u{1F62B}"
        }
    }

    var description: String {
        switch self {
        case .great: return "Great"
        case .good: return "Good"
        case .okay: return "Okay"
        case .poor: return "Poor"
        case .terrible: return "Terrible"
        }
    }

    var colorName: String {
        switch self {
        case .great: return "green"
        case .good: return "mint"
        case .okay: return "orange"
        case .poor: return "red"
        case .terrible: return "purple"
        }
    }
}
