import Foundation
import SwiftData

@Model
final class StreakRecord {
    var date: String  // YYYY-MM-DD format
    var child: ChildProfile?

    init(date: String) {
        self.date = date
    }

    static func todayString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }
}
