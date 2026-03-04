import SwiftUI

struct QuestionView: View {
    let question: Question
    @Bindable var viewModel: PracticeTestViewModel

    @State private var contentHeight: CGFloat = 100

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Question number
            Text("Question \(viewModel.currentQuestionIndex + 1) of \(viewModel.totalQuestions)")
                .font(.caption)
                .foregroundStyle(.secondary)

            // Question text
            MathTextView(content: question.question, dynamicHeight: $contentHeight)
                .frame(height: contentHeight)

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
                HStack(spacing: 8) {
                    Image(systemName: "lightbulb.fill")
                        .foregroundStyle(.yellow)
                    Text(hint)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding()
                .background(.yellow.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }

            // Explanation after answering
            if viewModel.showFeedback {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Explanation")
                        .font(.caption.bold())
                    Text(question.explanation)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding()
                .background(.blue.opacity(0.05))
                .clipShape(RoundedRectangle(cornerRadius: 8))
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
