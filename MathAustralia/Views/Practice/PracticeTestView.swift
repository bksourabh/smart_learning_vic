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
        VStack(spacing: Spacing.xl) {
            Spacer()

            // Strand-themed icon
            StrandIconView(strand: practiceTest.strandSlug, size: 80, showBackground: true)

            Text(practiceTest.title)
                .font(.title2.bold())
                .fontDesign(.rounded)

            Text(practiceTest.description)
                .font(.subheadline)
                .fontDesign(.rounded)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            VStack(spacing: Spacing.xs) {
                InfoRow(label: "Questions", value: "\(practiceTest.questions.count)")
                InfoRow(label: "Pass Mark", value: "\(practiceTest.passingScore)%")
            }
            .padding()
            .appCard()
            .padding(.horizontal)

            Spacer()

            // Gradient start button
            Button {
                withAnimation(.spring(duration: 0.3)) {
                    viewModel.start()
                }
                Haptics.impact(.medium)
            } label: {
                Text("Start Test")
                    .font(.headline)
                    .fontDesign(.rounded)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(StrandColorSet.gradient(for: practiceTest.strandSlug))
                    .clipShape(RoundedRectangle(cornerRadius: CornerRadius.medium))
                    .shadow(color: StrandColorSet.primary(for: practiceTest.strandSlug).opacity(0.3), radius: 8, x: 0, y: 4)
            }
            .padding(.horizontal)
            .padding(.bottom, Spacing.xxl)
        }
    }

    // MARK: - Question View

    private var questionView: some View {
        VStack(spacing: 0) {
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
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
    }

    // MARK: - Review View

    private var reviewView: some View {
        ScrollView {
            LazyVStack(spacing: Spacing.md) {
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
                        .fontDesign(.rounded)
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
                .fontDesign(.rounded)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .bold()
                .fontDesign(.rounded)
        }
    }
}
