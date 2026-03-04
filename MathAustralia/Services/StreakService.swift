import Foundation
import SwiftData

@Observable
final class StreakService {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func recordActivity(for child: ChildProfile) {
        let today = StreakRecord.todayString()

        // Check if already recorded today
        if child.streakRecords.contains(where: { $0.date == today }) {
            return
        }

        let record = StreakRecord(date: today)
        record.child = child
        modelContext.insert(record)
        try? modelContext.save()
    }

    func currentStreak(for child: ChildProfile) -> Int {
        let dates = child.streakRecords.map { $0.date }.sorted().reversed()
        guard !dates.isEmpty else { return 0 }

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"

        var streak = 0
        var expectedDate = Date()

        for dateString in dates {
            let expected = formatter.string(from: expectedDate)
            if dateString == expected {
                streak += 1
                expectedDate = Calendar.current.date(byAdding: .day, value: -1, to: expectedDate)!
            } else if streak == 0 {
                // Allow checking yesterday if no activity today
                expectedDate = Calendar.current.date(byAdding: .day, value: -1, to: expectedDate)!
                let yesterday = formatter.string(from: expectedDate)
                if dateString == yesterday {
                    streak += 1
                    expectedDate = Calendar.current.date(byAdding: .day, value: -1, to: expectedDate)!
                } else {
                    break
                }
            } else {
                break
            }
        }

        return streak
    }

    func longestStreak(for child: ChildProfile) -> Int {
        let dates = child.streakRecords.map { $0.date }.sorted()
        guard !dates.isEmpty else { return 0 }

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"

        var longest = 1
        var current = 1

        for i in 1..<dates.count {
            guard let prevDate = formatter.date(from: dates[i - 1]),
                  let currDate = formatter.date(from: dates[i]) else { continue }

            let diff = Calendar.current.dateComponents([.day], from: prevDate, to: currDate).day ?? 0
            if diff == 1 {
                current += 1
                longest = max(longest, current)
            } else if diff > 1 {
                current = 1
            }
        }

        return longest
    }

    func weeklyActivity(for child: ChildProfile) -> [String: Bool] {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"

        var activity: [String: Bool] = [:]
        let today = Date()

        for dayOffset in 0..<7 {
            let date = Calendar.current.date(byAdding: .day, value: -dayOffset, to: today)!
            let dateString = formatter.string(from: date)
            activity[dateString] = child.streakRecords.contains { $0.date == dateString }
        }

        return activity
    }

    func hasActivityToday(for child: ChildProfile) -> Bool {
        let today = StreakRecord.todayString()
        return child.streakRecords.contains { $0.date == today }
    }
}
