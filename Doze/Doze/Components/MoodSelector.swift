import SwiftUI

struct MoodSelector: View {
    @Binding var selectedMood: SleepMood?

    var body: some View {
        HStack(spacing: 12) {
            ForEach(SleepMood.allCases, id: \.self) { mood in
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        selectedMood = mood
                    }
                } label: {
                    VStack(spacing: 4) {
                        Text(mood.emoji)
                            .font(.title)
                        Text(mood.description)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(
                        selectedMood == mood
                            ? Color.moodColor(for: mood).opacity(0.2)
                            : Color.clear
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                .buttonStyle(.plain)
            }
        }
    }
}
