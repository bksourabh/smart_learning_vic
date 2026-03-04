import Foundation

// MARK: - Question Type

enum QuestionType: String, Codable {
    case mcq
    case shortAnswer = "short-answer"
}

// MARK: - MCQ Option

struct MCQOption: Codable, Identifiable {
    let id: String
    let text: String
    let isCorrect: Bool
}

// MARK: - Question

struct Question: Codable, Identifiable {
    let id: String
    let type: QuestionType
    let question: String
    let hint: String?
    let difficulty: Difficulty
    let options: [MCQOption]?
    let correctAnswer: String?
    let acceptableAnswers: [String]?
    let explanation: String
    let topic: String
}

// MARK: - Practice Test

struct PracticeTest: Codable, Identifiable {
    let id: String
    let title: String
    let description: String
    let strandSlug: StrandSlug
    let levelSlug: String
    let questions: [Question]
    let passingScore: Int
    let timeLimit: Int?
}

// MARK: - Practice State

enum PracticeState: String {
    case notStarted = "not-started"
    case inProgress = "in-progress"
    case reviewing
    case completed
}

// MARK: - Practice Answer

struct PracticeAnswer: Identifiable {
    let questionId: String
    var selectedOptionId: String?
    var textAnswer: String?
    var isCorrect: Bool
    var answeredAt: Date

    var id: String { questionId }
}

// MARK: - Achievement Definition

struct AchievementDefinition: Codable, Identifiable {
    let id: String
    let name: String
    let description: String
    let icon: String
    let condition: AchievementConditionType
    let value: Int
}

enum AchievementConditionType: String, Codable {
    case firstLesson = "first_lesson"
    case lessonsCompleted = "lessons_completed"
    case perfectScore = "perfect_score"
    case streak
    case strandCompleted = "strand_completed"
}
