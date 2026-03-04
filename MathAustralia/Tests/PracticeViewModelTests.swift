import XCTest
@testable import MathAustralia

final class PracticeViewModelTests: XCTestCase {

    private func makePracticeTest() -> PracticeTest {
        PracticeTest(
            id: "test-1",
            title: "Test Practice",
            description: "A test practice",
            strandSlug: .number,
            levelSlug: "foundation",
            questions: [
                Question(
                    id: "q1",
                    type: .mcq,
                    question: "What is 1+1?",
                    hint: nil,
                    difficulty: .easy,
                    options: [
                        MCQOption(id: "a", text: "1", isCorrect: false),
                        MCQOption(id: "b", text: "2", isCorrect: true),
                        MCQOption(id: "c", text: "3", isCorrect: false),
                        MCQOption(id: "d", text: "4", isCorrect: false)
                    ],
                    correctAnswer: nil,
                    acceptableAnswers: nil,
                    explanation: "1+1=2",
                    topic: "addition"
                ),
                Question(
                    id: "q2",
                    type: .shortAnswer,
                    question: "What is 2+3?",
                    hint: "Count on your fingers",
                    difficulty: .easy,
                    options: nil,
                    correctAnswer: "5",
                    acceptableAnswers: ["5", "five"],
                    explanation: "2+3=5",
                    topic: "addition"
                )
            ],
            passingScore: 50,
            timeLimit: nil
        )
    }

    func testInitialState() {
        let vm = PracticeTestViewModel(practiceTest: makePracticeTest())
        XCTAssertEqual(vm.state, .notStarted)
        XCTAssertEqual(vm.currentQuestionIndex, 0)
        XCTAssertTrue(vm.answers.isEmpty)
    }

    func testStart() {
        let vm = PracticeTestViewModel(practiceTest: makePracticeTest())
        vm.start()
        XCTAssertEqual(vm.state, .inProgress)
        XCTAssertNotNil(vm.currentQuestion)
    }

    func testSubmitCorrectMCQ() {
        let vm = PracticeTestViewModel(practiceTest: makePracticeTest())
        vm.start()
        vm.submitMCQAnswer(optionId: "b")
        XCTAssertTrue(vm.showFeedback)
        XCTAssertEqual(vm.score, 1)
        XCTAssertTrue(vm.answers["q1"]?.isCorrect ?? false)
    }

    func testSubmitIncorrectMCQ() {
        let vm = PracticeTestViewModel(practiceTest: makePracticeTest())
        vm.start()
        vm.submitMCQAnswer(optionId: "a")
        XCTAssertTrue(vm.showFeedback)
        XCTAssertEqual(vm.score, 0)
        XCTAssertFalse(vm.answers["q1"]?.isCorrect ?? true)
    }

    func testSubmitCorrectTextAnswer() {
        let vm = PracticeTestViewModel(practiceTest: makePracticeTest())
        vm.start()
        vm.submitMCQAnswer(optionId: "b")
        vm.nextQuestion()
        vm.submitTextAnswer(text: "5")
        XCTAssertTrue(vm.showFeedback)
        XCTAssertEqual(vm.score, 2)
    }

    func testSubmitAcceptableTextAnswer() {
        let vm = PracticeTestViewModel(practiceTest: makePracticeTest())
        vm.start()
        vm.submitMCQAnswer(optionId: "b")
        vm.nextQuestion()
        vm.submitTextAnswer(text: "five")
        XCTAssertTrue(vm.answers["q2"]?.isCorrect ?? false)
    }

    func testCompleteFlow() {
        let vm = PracticeTestViewModel(practiceTest: makePracticeTest())
        vm.start()
        vm.submitMCQAnswer(optionId: "b")
        vm.nextQuestion()
        vm.submitTextAnswer(text: "5")
        vm.nextQuestion()
        XCTAssertEqual(vm.state, .completed)
        XCTAssertEqual(vm.score, 2)
        XCTAssertTrue(vm.passed)
        XCTAssertTrue(vm.isPerfect)
    }

    func testPercentage() {
        let vm = PracticeTestViewModel(practiceTest: makePracticeTest())
        vm.start()
        vm.submitMCQAnswer(optionId: "b")
        vm.nextQuestion()
        vm.submitTextAnswer(text: "wrong")
        vm.nextQuestion()
        XCTAssertEqual(vm.percentage, 50.0)
        XCTAssertTrue(vm.passed) // 50% >= 50% passing
    }

    func testReview() {
        let vm = PracticeTestViewModel(practiceTest: makePracticeTest())
        vm.start()
        vm.submitMCQAnswer(optionId: "b")
        vm.nextQuestion()
        vm.submitTextAnswer(text: "5")
        vm.nextQuestion()
        vm.review()
        XCTAssertEqual(vm.state, .reviewing)
    }

    func testRestart() {
        let vm = PracticeTestViewModel(practiceTest: makePracticeTest())
        vm.start()
        vm.submitMCQAnswer(optionId: "b")
        vm.restart()
        XCTAssertEqual(vm.state, .notStarted)
    }
}
