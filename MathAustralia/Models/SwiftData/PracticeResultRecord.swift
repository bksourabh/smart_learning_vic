import Foundation
import SwiftData

@Model
final class PracticeResultRecord {
    var practiceId: String
    var strandSlug: String
    var levelSlug: String
    var score: Int
    var totalQuestions: Int
    var percentage: Double
    var passed: Bool
    var completedAt: Date
    var child: ChildProfile?

    init(practiceId: String, strandSlug: String, levelSlug: String,
         score: Int, totalQuestions: Int, passed: Bool) {
        self.practiceId = practiceId
        self.strandSlug = strandSlug
        self.levelSlug = levelSlug
        self.score = score
        self.totalQuestions = totalQuestions
        self.percentage = totalQuestions > 0 ? Double(score) / Double(totalQuestions) * 100 : 0
        self.passed = passed
        self.completedAt = Date()
    }
}
