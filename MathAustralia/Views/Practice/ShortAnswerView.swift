import SwiftUI

struct ShortAnswerView: View {
    let isAnswered: Bool
    let isCorrect: Bool
    let showFeedback: Bool
    let onSubmit: (String) -> Void

    @State private var answer = ""
    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                TextField("Type your answer...", text: $answer)
                    .textFieldStyle(.roundedBorder)
                    .focused($isFocused)
                    .disabled(showFeedback)
                    .keyboardType(.decimalPad)

                if !showFeedback && !answer.isEmpty {
                    Button("Submit") {
                        onSubmit(answer)
                        isFocused = false
                    }
                    .buttonStyle(.borderedProminent)
                }
            }

            if showFeedback {
                HStack(spacing: 8) {
                    Image(systemName: isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .foregroundStyle(isCorrect ? .green : .red)
                    Text(isCorrect ? "Correct!" : "Incorrect")
                        .font(.subheadline.bold())
                        .foregroundStyle(isCorrect ? .green : .red)
                }
                .transition(.scale.combined(with: .opacity))
            }
        }
    }
}
