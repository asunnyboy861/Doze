import SwiftUI

struct SleepSessionRow: View {
    let session: SleepSession

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(session.startTime, style: .time)
                        .font(.headline)
                    if let endTime = session.endTime {
                        Image(systemName: "arrow.right")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(endTime, style: .time)
                            .font(.headline)
                    }
                }

                DurationDisplay(duration: session.duration)

                if let notes = session.notes, !notes.isEmpty {
                    Text(notes)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }

            Spacer()

            if let mood = session.mood {
                Text(mood.emoji)
                    .font(.title2)
            }
        }
        .padding(.vertical, 4)
    }
}
