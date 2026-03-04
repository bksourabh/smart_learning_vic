import SwiftUI

struct MCQOptionsView: View {
    let options: [MCQOption]
    let selectedId: String?
    let showFeedback: Bool
    let onSelect: (String) -> Void

    var body: some View {
        VStack(spacing: 10) {
            ForEach(options) { option in
                Button {
                    if !showFeedback {
                        onSelect(option.id)
                    }
                } label: {
                    HStack(spacing: 12) {
                        optionIndicator(for: option)

                        MathTextView(content: option.text)
                            .frame(height: 40)

                        Spacer()
                    }
                    .padding()
                    .background(optionBackground(for: option))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .strokeBorder(optionBorder(for: option), lineWidth: 2)
                    )
                }
                .buttonStyle(.plain)
                .disabled(showFeedback)
            }
        }
    }

    @ViewBuilder
    private func optionIndicator(for option: MCQOption) -> some View {
        if showFeedback && option.isCorrect {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(.green)
        } else if showFeedback && option.id == selectedId && !option.isCorrect {
            Image(systemName: "xmark.circle.fill")
                .foregroundStyle(.red)
        } else if option.id == selectedId {
            Image(systemName: "circle.fill")
                .foregroundStyle(.blue)
        } else {
            Image(systemName: "circle")
                .foregroundStyle(.secondary)
        }
    }

    private func optionBackground(for option: MCQOption) -> Color {
        if showFeedback && option.isCorrect {
            return .green.opacity(0.1)
        }
        if showFeedback && option.id == selectedId && !option.isCorrect {
            return .red.opacity(0.1)
        }
        if option.id == selectedId {
            return .blue.opacity(0.1)
        }
        return .clear
    }

    private func optionBorder(for option: MCQOption) -> Color {
        if showFeedback && option.isCorrect {
            return .green
        }
        if showFeedback && option.id == selectedId && !option.isCorrect {
            return .red
        }
        if option.id == selectedId {
            return .blue
        }
        return .gray.opacity(0.2)
    }
}
