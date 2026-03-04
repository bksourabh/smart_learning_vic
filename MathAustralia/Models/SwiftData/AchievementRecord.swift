import Foundation
import SwiftData

@Model
final class AchievementRecord {
    var achievementId: String
    var unlockedAt: Date
    var child: ChildProfile?

    init(achievementId: String) {
        self.achievementId = achievementId
        self.unlockedAt = Date()
    }
}
