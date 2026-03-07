import SwiftUI

struct FeedbackBar: View {
    let viewModel: PracticeTestViewModel

    private var currentAnswer: PracticeAnswer? {
        guard let question = viewModel.currentQuestion else { return nil }
        return viewModel.answers[question.id]
    }

    var body: some View {
        VStack(spacing: 0) {
            Divider()
            HStack(spacing: Spacing.md) {
                if let answer = currentAnswer {
                    Image(systemName: answer.isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .font(.title2)
                        .foregroundStyle(answer.isCorrect ? .green : .orange)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(answer.isCorrect ? "Correct!" : "Not quite")
                            .font(.headline)
                            .fontDesign(.rounded)
                            .foregroundStyle(answer.isCorrect ? .green : .orange)
                        if !answer.isCorrect {
                            Text("Keep going, you've got this!")
                                .font(.caption)
                                .fontDesign(.rounded)
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                Spacer()

                Button {
                    withAnimation(.spring(duration: 0.3)) {
                        viewModel.nextQuestion()
                    }
                } label: {
                    Text(viewModel.isLastQuestion ? "See Results" : "Next")
                        .font(.headline)
                        .fontDesign(.rounded)
                        .padding(.horizontal, Spacing.xl)
                        .padding(.vertical, 10)
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
            .background(
                (currentAnswer?.isCorrect == true ? Color.green : Color.orange).opacity(0.06)
            )
            .background(.regularMaterial)
        }
    }
}

// MARK: - Review Question Card

struct ReviewQuestionCard: View {
    let question: Question
    let answer: PracticeAnswer?

    @State private var contentHeight: CGFloat = 80

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            HStack(alignment: .top) {
                Image(systemName: answer?.isCorrect == true ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .foregroundStyle(answer?.isCorrect == true ? .green : .red)
                    .padding(.top, 2)

                SmartTextView(question.question, font: .subheadline)
            }

            if let answer, let selectedId = answer.selectedOptionId,
               let options = question.options {
                // Batch all options into a single render for performance
                let optionLines = options.map { option in
                    let marker = option.isCorrect ? "\u{2713}" : (option.id == selectedId ? "\u{2717}" : "\u{25CB}")
                    return "\(marker) \(option.text)"
                }.joined(separator: "\n")
                SmartTextView(optionLines, font: .caption)
            }

            if let answer, let textAnswer = answer.textAnswer {
                HStack {
                    Text("Your answer: \(textAnswer)")
                        .font(.caption)
                        .fontDesign(.rounded)
                    if let correct = question.correctAnswer {
                        Text("Correct: \(correct)")
                            .font(.caption)
                            .fontDesign(.rounded)
                            .foregroundStyle(.green)
                    }
                }
            }

            SmartTextView(question.explanation, font: .caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .appCard()
    }
}
