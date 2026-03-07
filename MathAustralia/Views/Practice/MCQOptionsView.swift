import SwiftUI

struct MCQOptionsView: View {
    let options: [MCQOption]
    let selectedId: String?
    let showFeedback: Bool
    let onSelect: (String) -> Void

    private let letters = ["A", "B", "C", "D", "E", "F"]

    var body: some View {
        VStack(spacing: Spacing.sm) {
            ForEach(Array(options.enumerated()), id: \.element.id) { index, option in
                Button {
                    if !showFeedback {
                        Haptics.selection()
                        onSelect(option.id)
                    }
                } label: {
                    HStack(alignment: .center, spacing: Spacing.sm) {
                        // Letter label in colored circle
                        letterLabel(for: option, index: index)

                        SmartTextView(option.text, font: .body)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        if showFeedback && option.isCorrect {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(.green)
                        } else if showFeedback && option.id == selectedId && !option.isCorrect {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(.red)
                        }
                    }
                    .padding()
                    .background(optionBackground(for: option), in: RoundedRectangle(cornerRadius: CornerRadius.medium))
                    .overlay(
                        RoundedRectangle(cornerRadius: CornerRadius.medium)
                            .strokeBorder(optionBorder(for: option), lineWidth: 2)
                    )
                    .scaleEffect(showFeedback && option.isCorrect ? 1.02 : 1)
                    .animation(.spring(duration: 0.3), value: showFeedback)
                }
                .buttonStyle(.bounce)
                .disabled(showFeedback)
            }
        }
    }

    @ViewBuilder
    private func letterLabel(for option: MCQOption, index: Int) -> some View {
        let letter = index < letters.count ? letters[index] : "\(index + 1)"

        if showFeedback && option.isCorrect {
            Text(letter)
                .font(.caption.bold())
                .fontDesign(.rounded)
                .foregroundStyle(.white)
                .frame(width: 28, height: 28)
                .background(.green.gradient)
                .clipShape(Circle())
        } else if showFeedback && option.id == selectedId && !option.isCorrect {
            Text(letter)
                .font(.caption.bold())
                .fontDesign(.rounded)
                .foregroundStyle(.white)
                .frame(width: 28, height: 28)
                .background(.red.gradient)
                .clipShape(Circle())
        } else if option.id == selectedId {
            Text(letter)
                .font(.caption.bold())
                .fontDesign(.rounded)
                .foregroundStyle(.white)
                .frame(width: 28, height: 28)
                .background(.blue.gradient)
                .clipShape(Circle())
        } else {
            Text(letter)
                .font(.caption.bold())
                .fontDesign(.rounded)
                .foregroundStyle(.secondary)
                .frame(width: 28, height: 28)
                .background(.gray.opacity(0.1))
                .clipShape(Circle())
        }
    }

    private func optionBackground(for option: MCQOption) -> Color {
        if showFeedback && option.isCorrect {
            return .green.opacity(0.08)
        }
        if showFeedback && option.id == selectedId && !option.isCorrect {
            return .red.opacity(0.08)
        }
        if option.id == selectedId {
            return .blue.opacity(0.08)
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
        return .gray.opacity(0.15)
    }
}
