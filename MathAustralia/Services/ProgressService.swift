import Foundation
import SwiftData

@Observable
final class ProgressService {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    // MARK: - Lesson Progress

    func startLesson(_ lesson: Lesson, for child: ChildProfile) {
        // Check if already started
        if getLessonProgress(lessonSlug: lesson.slug, for: child) != nil {
            return
        }

        let record = LessonProgressRecord(
            lessonSlug: lesson.slug,
            strandSlug: lesson.strandSlug.rawValue,
            levelSlug: lesson.levelSlug
        )
        record.child = child
        modelContext.insert(record)
        try? modelContext.save()
    }

    func completeLesson(_ lesson: Lesson, for child: ChildProfile) {
        let record: LessonProgressRecord
        if let existing = getLessonProgress(lessonSlug: lesson.slug, for: child) {
            record = existing
        } else {
            record = LessonProgressRecord(
                lessonSlug: lesson.slug,
                strandSlug: lesson.strandSlug.rawValue,
                levelSlug: lesson.levelSlug
            )
            record.child = child
            modelContext.insert(record)
        }

        guard !record.completed else { return }

        record.completed = true
        record.completedAt = Date()

        // Award XP
        child.totalXP += AppConstants.xpPerLesson

        try? modelContext.save()
    }

    func getLessonProgress(lessonSlug: String, for child: ChildProfile) -> LessonProgressRecord? {
        child.lessonProgress.first { $0.lessonSlug == lessonSlug }
    }

    func isLessonCompleted(lessonSlug: String, for child: ChildProfile) -> Bool {
        getLessonProgress(lessonSlug: lessonSlug, for: child)?.completed ?? false
    }

    func completedLessonsCount(for child: ChildProfile) -> Int {
        child.lessonProgress.filter { $0.completed }.count
    }

    func completedLessonsCount(strandSlug: String, for child: ChildProfile) -> Int {
        child.lessonProgress.filter { $0.completed && $0.strandSlug == strandSlug }.count
    }

    func completedLessonsCount(levelSlug: String, strandSlug: String, for child: ChildProfile) -> Int {
        child.lessonProgress.filter {
            $0.completed && $0.levelSlug == levelSlug && $0.strandSlug == strandSlug
        }.count
    }

    // MARK: - Practice Results

    func savePracticeResult(
        practiceTest: PracticeTest,
        score: Int,
        answers: [PracticeAnswer],
        for child: ChildProfile
    ) {
        let passed = Double(score) / Double(practiceTest.questions.count) * 100 >= Double(practiceTest.passingScore)

        let record = PracticeResultRecord(
            practiceId: practiceTest.id,
            strandSlug: practiceTest.strandSlug.rawValue,
            levelSlug: practiceTest.levelSlug,
            score: score,
            totalQuestions: practiceTest.questions.count,
            passed: passed
        )
        record.child = child

        // Award XP
        if score == practiceTest.questions.count {
            child.totalXP += AppConstants.xpBonusPerfect
        } else if passed {
            child.totalXP += AppConstants.xpPerPractice
        } else {
            child.totalXP += AppConstants.xpPracticeFail
        }

        modelContext.insert(record)
        try? modelContext.save()
    }

    func bestResult(practiceId: String, for child: ChildProfile) -> PracticeResultRecord? {
        child.practiceResults
            .filter { $0.practiceId == practiceId }
            .max(by: { $0.percentage < $1.percentage })
    }

    func practiceResultsCount(for child: ChildProfile) -> Int {
        child.practiceResults.count
    }

    func passedPracticeCount(for child: ChildProfile) -> Int {
        child.practiceResults.filter { $0.passed }.count
    }

    func hasPerfectScore(for child: ChildProfile) -> Bool {
        child.practiceResults.contains { $0.percentage >= 100 }
    }
}
