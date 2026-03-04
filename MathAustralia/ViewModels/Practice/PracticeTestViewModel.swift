import Foundation
import SwiftData

@Observable
final class PracticeTestViewModel {
    let practiceTest: PracticeTest

    private(set) var state: PracticeState = .notStarted
    private(set) var currentQuestionIndex: Int = 0
    private(set) var answers: [String: PracticeAnswer] = [:]
    private(set) var showFeedback = false
    private(set) var score: Int = 0

    var currentQuestion: Question? {
        guard currentQuestionIndex < practiceTest.questions.count else { return nil }
        return practiceTest.questions[currentQuestionIndex]
    }

    var totalQuestions: Int { practiceTest.questions.count }
    var answeredCount: Int { answers.count }
    var isLastQuestion: Bool { currentQuestionIndex == totalQuestions - 1 }

    var percentage: Double {
        guard totalQuestions > 0 else { return 0 }
        return Double(score) / Double(totalQuestions) * 100
    }

    var passed: Bool {
        percentage >= Double(practiceTest.passingScore)
    }

    var isPerfect: Bool {
        score == totalQuestions
    }

    init(practiceTest: PracticeTest) {
        self.practiceTest = practiceTest
    }

    // MARK: - State Machine

    func start() {
        state = .inProgress
        currentQuestionIndex = 0
        answers = [:]
        score = 0
        showFeedback = false
    }

    func submitMCQAnswer(optionId: String) {
        guard let question = currentQuestion, state == .inProgress else { return }

        let isCorrect = question.options?.first(where: { $0.id == optionId })?.isCorrect ?? false

        let answer = PracticeAnswer(
            questionId: question.id,
            selectedOptionId: optionId,
            isCorrect: isCorrect,
            answeredAt: Date()
        )

        answers[question.id] = answer
        if isCorrect { score += 1 }
        showFeedback = true
    }

    func submitTextAnswer(text: String) {
        guard let question = currentQuestion, state == .inProgress else { return }

        let isCorrect = checkTextAnswer(text, for: question)

        let answer = PracticeAnswer(
            questionId: question.id,
            textAnswer: text,
            isCorrect: isCorrect,
            answeredAt: Date()
        )

        answers[question.id] = answer
        if isCorrect { score += 1 }
        showFeedback = true
    }

    func nextQuestion() {
        showFeedback = false
        if isLastQuestion {
            state = .completed
        } else {
            currentQuestionIndex += 1
        }
    }

    func review() {
        state = .reviewing
        currentQuestionIndex = 0
    }

    func restart() {
        state = .notStarted
    }

    // MARK: - Answer Checking

    private func checkTextAnswer(_ userAnswer: String, for question: Question) -> Bool {
        let trimmed = userAnswer.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()

        // Check exact match with correct answer
        if let correct = question.correctAnswer?.lowercased(), trimmed == correct {
            return true
        }

        // Check acceptable answers
        if let acceptable = question.acceptableAnswers {
            if acceptable.map({ $0.lowercased() }).contains(trimmed) {
                return true
            }
        }

        // Numeric tolerance check
        if let correctStr = question.correctAnswer,
           let correctNum = Double(correctStr),
           let userNum = Double(trimmed) {
            return abs(correctNum - userNum) < AppConstants.numericTolerance
        }

        return false
    }
}
