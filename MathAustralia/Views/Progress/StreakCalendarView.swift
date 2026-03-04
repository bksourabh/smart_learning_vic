import SwiftUI

struct StreakCalendarView: View {
    let child: ChildProfile
    @Environment(\.modelContext) private var modelContext

    private var weekDays: [(String, String, Bool)] {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dayFormatter = DateFormatter()
        dayFormatter.dateFormat = "EEE"

        let today = Date()
        return (0..<7).reversed().map { offset in
            let date = Calendar.current.date(byAdding: .day, value: -offset, to: today)!
            let dateString = formatter.string(from: date)
            let dayName = dayFormatter.string(from: date)
            let hasActivity = child.streakRecords.contains { $0.date == dateString }
            return (dayName, dateString, hasActivity)
        }
    }

    var body: some View {
        HStack(spacing: 8) {
            ForEach(weekDays, id: \.1) { dayName, _, hasActivity in
                VStack(spacing: 6) {
                    Text(dayName)
                        .font(.caption2)
                        .foregroundStyle(.secondary)

                    ZStack {
                        Circle()
                            .fill(hasActivity ? .green : .gray.opacity(0.15))
                            .frame(width: 32, height: 32)

                        if hasActivity {
                            Image(systemName: "checkmark")
                                .font(.caption.bold())
                                .foregroundStyle(.white)
                        }
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
