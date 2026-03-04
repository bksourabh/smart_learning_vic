import SwiftUI

struct PracticeTestView: View {
    let practiceTest: PracticeTest
    @Environment(AppState.self) private var appState
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var viewModel: PracticeTestViewModel

    init(practiceTest: PracticeTest) {
        self.practiceTest = practiceTest
        self._viewModel = State(initialValue: PracticeTestViewModel(practiceTest: practiceTest))
    }

    var body: some View {
        Group {
            switch viewModel.state {
            case .notStarted:
                practiceStartView
            case .inProgress:
                questionView
            case .completed:
                ScoreView(viewModel: viewModel) {
                    saveResult()
                }
            case .reviewing:
                reviewView
            }
        }
        .navigationTitle(practiceTest.title)
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Start View

    private var practiceStartView: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "pencil.and.list.clipboard")
                .font(.system(size: 64))
                .foregroundStyle(.blue)

            Text(practiceTest.title)
                .font(.title2.bold())

            Text(practiceTest.description)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            VStack(spacing: 8) {
                InfoRow(label: "Questions", value: "\(practiceTest.questions.count)")
                InfoRow(label: "Pass Mark", value: "\(practiceTest.passingScore)%")
            }
            .padding()
            .background(.regularMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .padding(.horizontal)

            Spacer()

            Button {
                withAnimation(.spring(duration: 0.3)) {
                    viewModel.start()
                }
            } label: {
                Text("Start Test")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
            }
            .buttonStyle(.borderedProminent)
            .padding(.horizontal)
            .padding(.bottom, 32)
        }
    }

    // MARK: - Question View

    private var questionView: some View {
        VStack(spacing: 0) {
            // Progress dots
            ProgressDotsView(
                total: viewModel.totalQuestions,
                current: viewModel.currentQuestionIndex,
                answers: viewModel.answers,
                questions: practiceTest.questions
            )
            .padding()

            Divider()

            ScrollView {
                if let question = viewModel.currentQuestion {
                    QuestionView(
                        question: question,
                        viewModel: viewModel
                    )
                    .padding()
                }
            }

            if viewModel.showFeedback {
                FeedbackBar(viewModel: viewModel)
            }
        }
    }

    // MARK: - Review View

    private var reviewView: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(practiceTest.questions) { question in
                    ReviewQuestionCard(
                        question: question,
                        answer: viewModel.answers[question.id]
                    )
                }

                Button {
                    viewModel.restart()
                } label: {
                    Text("Try Again")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                }
                .buttonStyle(.borderedProminent)
                .padding(.top)
            }
            .padding()
        }
    }

    private func saveResult() {
        guard let child = appState.activeChild else { return }
        let progressService = ProgressService(modelContext: modelContext)
        let answers = viewModel.answers.values.map { $0 }
        progressService.savePracticeResult(
            practiceTest: practiceTest,
            score: viewModel.score,
            answers: Array(answers),
            for: child
        )
        let streakService = StreakService(modelContext: modelContext)
        streakService.recordActivity(for: child)
    }
}

// MARK: - Info Row

private struct InfoRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .bold()
        }
    }
}
