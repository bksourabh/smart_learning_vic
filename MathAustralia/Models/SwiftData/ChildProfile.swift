import Foundation
import SwiftData

@Model
final class ChildProfile {
    var name: String
    var emoji: String
    var currentLevel: String
    var totalXP: Int
    var createdAt: Date
    var parent: ParentAccount?

    @Relationship(deleteRule: .cascade, inverse: \LessonProgressRecord.child)
    var lessonProgress: [LessonProgressRecord]

    @Relationship(deleteRule: .cascade, inverse: \PracticeResultRecord.child)
    var practiceResults: [PracticeResultRecord]

    @Relationship(deleteRule: .cascade, inverse: \AchievementRecord.child)
    var achievements: [AchievementRecord]

    @Relationship(deleteRule: .cascade, inverse: \StreakRecord.child)
    var streakRecords: [StreakRecord]

    init(name: String, emoji: String, currentLevel: String = "foundation") {
        self.name = name
        self.emoji = emoji
        self.currentLevel = currentLevel
        self.totalXP = 0
        self.createdAt = Date()
        self.lessonProgress = []
        self.practiceResults = []
        self.achievements = []
        self.streakRecords = []
    }
}
