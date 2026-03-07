import SwiftUI

struct QuestionView: View {
    let question: Question
    @Bindable var viewModel: PracticeTestViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.lg) {
            // Question number with progress
            HStack {
                Text("Question \(viewModel.currentQuestionIndex + 1) of \(viewModel.totalQuestions)")
                    .font(.caption.bold())
                    .fontDesign(.rounded)
                    .foregroundStyle(.secondary)
                Spacer()
                Text("\(viewModel.score) correct")
                    .font(.caption.bold())
                    .fontDesign(.rounded)
                    .foregroundStyle(.green)
                    .contentTransition(.numericText())
            }

            // Question text in elevated card
            VStack(alignment: .leading) {
                SmartTextView(question.question, font: .body)
            }
            .padding(Spacing.md)
            .frame(maxWidth: .infinity, alignment: .leading)
            .appCard()

            // Answer input
            switch question.type {
            case .mcq:
                if let options = question.options {
                    MCQOptionsView(
                        options: options,
                        selectedId: viewModel.answers[question.id]?.selectedOptionId,
                        showFeedback: viewModel.showFeedback
                    ) { optionId in
                        viewModel.submitMCQAnswer(optionId: optionId)
                    }
                }
            case .shortAnswer:
                ShortAnswerView(
                    isAnswered: viewModel.answers[question.id] != nil,
                    isCorrect: viewModel.answers[question.id]?.isCorrect ?? false,
                    showFeedback: viewModel.showFeedback
                ) { text in
                    viewModel.submitTextAnswer(text: text)
                }
            }

            // Hint
            if let hint = question.hint, !viewModel.showFeedback {
                HStack(spacing: Spacing.xs) {
                    Image(systemName: "lightbulb.fill")
                        .foregroundStyle(.yellow)
                    Text(hint)
                        .font(.caption)
                        .fontDesign(.rounded)
                        .foregroundStyle(.secondary)
                }
                .padding()
                .background(.yellow.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: CornerRadius.small))
            }

            // Explanation after answering
            if viewModel.showFeedback {
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Text("Explanation")
                        .font(.caption.bold())
                        .fontDesign(.rounded)
                    SmartTextView(question.explanation, font: .caption)
                        .foregroundStyle(.secondary)
                }
                .padding()
                .background(.blue.opacity(0.05), in: RoundedRectangle(cornerRadius: CornerRadius.small))
            }
        }
    }
}

// MARK: - Progress Dots

struct ProgressDotsView: View {
    let total: Int
    let current: Int
    let answers: [String: PracticeAnswer]
    let questions: [Question]

    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<total, id: \.self) { index in
                Circle()
                    .fill(dotColor(for: index))
                    .frame(width: index == current ? 10 : 6, height: index == current ? 10 : 6)
                    .animation(.spring(duration: 0.2), value: current)
            }
        }
    }

    private func dotColor(for index: Int) -> Color {
        let questionId = questions[index].id
        if let answer = answers[questionId] {
            return answer.isCorrect ? .green : .red
        }
        return index == current ? .blue : .gray.opacity(0.3)
    }
}
