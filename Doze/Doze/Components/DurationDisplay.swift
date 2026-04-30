import SwiftUI

struct DurationDisplay: View {
    let duration: TimeInterval?

    var body: some View {
        if let duration = duration {
            let hours = Int(duration) / 3600
            let minutes = (Int(duration) % 3600) / 60

            HStack(spacing: 4) {
                if hours > 0 {
                    Text("\(hours)")
                        .font(.title)
                        .fontWeight(.bold)
                    Text("h")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                }
                Text("\(minutes)")
                    .font(.title)
                    .fontWeight(.bold)
                Text("m")
                    .font(.headline)
                    .foregroundStyle(.secondary)
            }
        } else {
            Text("In progress")
                .font(.headline)
                .foregroundStyle(.secondary)
        }
    }
}
