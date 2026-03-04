import Foundation
import SwiftData

@Model
final class LessonProgressRecord {
    var lessonSlug: String
    var strandSlug: String
    var levelSlug: String
    var started: Bool
    var completed: Bool
    var startedAt: Date?
    var completedAt: Date?
    var child: ChildProfile?

    init(lessonSlug: String, strandSlug: String, levelSlug: String) {
        self.lessonSlug = lessonSlug
        self.strandSlug = strandSlug
        self.levelSlug = levelSlug
        self.started = true
        self.completed = false
        self.startedAt = Date()
    }
}
