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
            HStack(spacing: 16) {
                if let answer = currentAnswer {
                    Image(systemName: answer.isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .font(.title2)
                        .foregroundStyle(answer.isCorrect ? .green : .red)

                    Text(answer.isCorrect ? "Correct!" : "Incorrect")
                        .font(.headline)
                        .foregroundStyle(answer.isCorrect ? .green : .red)
                }

                Spacer()

                Button {
                    withAnimation(.spring(duration: 0.3)) {
                        viewModel.nextQuestion()
                    }
                } label: {
                    Text(viewModel.isLastQuestion ? "See Results" : "Next")
                        .font(.headline)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 10)
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
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
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: answer?.isCorrect == true ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .foregroundStyle(answer?.isCorrect == true ? .green : .red)

                Text(question.question)
                    .font(.subheadline.bold())
            }

            if let answer, let selectedId = answer.selectedOptionId,
               let options = question.options {
                ForEach(options) { option in
                    HStack(spacing: 8) {
                        Image(systemName: option.isCorrect ? "checkmark.circle.fill" :
                                (option.id == selectedId ? "xmark.circle.fill" : "circle"))
                            .foregroundStyle(option.isCorrect ? .green :
                                (option.id == selectedId ? .red : .secondary))
                            .font(.caption)
                        Text(option.text)
                            .font(.caption)
                    }
                }
            }

            if let answer, let textAnswer = answer.textAnswer {
                HStack {
                    Text("Your answer: \(textAnswer)")
                        .font(.caption)
                    if let correct = question.correctAnswer {
                        Text("Correct: \(correct)")
                            .font(.caption)
                            .foregroundStyle(.green)
                    }
                }
            }

            Text(question.explanation)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
