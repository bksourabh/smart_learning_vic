import SwiftUI

struct StreakCalendarView: View {
    let child: ChildProfile
    @Environment(\.modelContext) private var modelContext

    private var weekDays: [(String, String, Bool, Bool)] {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dayFormatter = DateFormatter()
        dayFormatter.dateFormat = "EEE"

        let today = Date()
        let todayString = formatter.string(from: today)
        return (0..<7).reversed().map { offset in
            let date = Calendar.current.date(byAdding: .day, value: -offset, to: today)!
            let dateString = formatter.string(from: date)
            let dayName = dayFormatter.string(from: date)
            let hasActivity = child.streakRecords.contains { $0.date == dateString }
            let isToday = dateString == todayString
            return (dayName, dateString, hasActivity, isToday)
        }
    }

    var body: some View {
        VStack(spacing: Spacing.sm) {
            // Flame header
            HStack(spacing: Spacing.xs) {
                Image(systemName: "flame.fill")
                    .foregroundStyle(.orange)
                Text("\(StreakService(modelContext: modelContext).currentStreak(for: child)) day streak")
                    .font(.caption.bold())
                    .fontDesign(.rounded)
                    .foregroundStyle(.orange)
                Spacer()
            }

            HStack(spacing: Spacing.xs) {
                ForEach(Array(weekDays.enumerated()), id: \.element.1) { index, day in
                    let (dayName, _, hasActivity, isToday) = day
                    VStack(spacing: 6) {
                        Text(dayName)
                            .font(.caption2)
                            .fontDesign(.rounded)
                            .foregroundStyle(.secondary)

                        ZStack {
                            Circle()
                                .fill(
                                    hasActivity
                                        ? LinearGradient(colors: [.green, .green.opacity(0.8)], startPoint: .top, endPoint: .bottom)
                                        : LinearGradient(colors: [.gray.opacity(0.12), .gray.opacity(0.08)], startPoint: .top, endPoint: .bottom)
                                )
                                .frame(width: 34, height: 34)

                            if isToday {
                                Circle()
                                    .strokeBorder(.blue, lineWidth: 2)
                                    .frame(width: 34, height: 34)
                            }

                            if hasActivity {
                                Image(systemName: "checkmark")
                                    .font(.caption.bold())
                                    .foregroundStyle(.white)
                            }
                        }
                        .shadow(color: hasActivity ? .green.opacity(0.3) : .clear, radius: 4, y: 2)
                    }
                    .frame(maxWidth: .infinity)
                    .staggeredEntrance(index: index)
                }
            }
        }
        .padding()
        .appCard()
    }
}
