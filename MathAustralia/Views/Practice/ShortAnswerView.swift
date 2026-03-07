import SwiftUI

struct ShortAnswerView: View {
    let isAnswered: Bool
    let isCorrect: Bool
    let showFeedback: Bool
    let onSubmit: (String) -> Void

    @State private var answer = ""
    @FocusState private var isFocused: Bool

    private var borderColor: Color {
        if showFeedback {
            return isCorrect ? .green : .red
        }
        return isFocused ? .blue : .gray.opacity(0.3)
    }

    var body: some View {
        VStack(spacing: Spacing.sm) {
            HStack {
                TextField("Type your answer...", text: $answer)
                    .fontDesign(.rounded)
                    .focused($isFocused)
                    .disabled(showFeedback)
                    .keyboardType(.decimalPad)
                    .padding(Spacing.sm)
                    .background(.gray.opacity(0.06))
                    .clipShape(RoundedRectangle(cornerRadius: CornerRadius.small))
                    .overlay(
                        RoundedRectangle(cornerRadius: CornerRadius.small)
                            .strokeBorder(borderColor, lineWidth: 2)
                    )
                    .animation(.easeInOut(duration: 0.2), value: isFocused)
                    .animation(.easeInOut(duration: 0.2), value: showFeedback)

                if !showFeedback && !answer.isEmpty {
                    Button {
                        Haptics.selection()
                        onSubmit(answer)
                        isFocused = false
                    } label: {
                        Text("Submit")
                            .fontDesign(.rounded)
                    }
                    .buttonStyle(.borderedProminent)
                }
            }

            if showFeedback {
                HStack(spacing: Spacing.xs) {
                    Image(systemName: isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .foregroundStyle(isCorrect ? .green : .red)
                    Text(isCorrect ? "Correct!" : "Incorrect")
                        .font(.subheadline.bold())
                        .fontDesign(.rounded)
                        .foregroundStyle(isCorrect ? .green : .red)
                }
                .padding(Spacing.sm)
                .frame(maxWidth: .infinity)
                .background((isCorrect ? Color.green : Color.red).opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: CornerRadius.small))
                .transition(.scale.combined(with: .opacity))
            }
        }
    }
}
