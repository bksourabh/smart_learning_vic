import SwiftUI

struct PatternSequenceView: View {
    let numbers: [Double]
    let strandColor: Color

    @State private var revealedCount = 0

    private var sequence: [Double] {
        if numbers.count >= 3 {
            return Array(numbers.prefix(6))
        }
        // Generate a simple arithmetic sequence as fallback
        return [2, 4, 6, 8, 10]
    }

    var body: some View {
        VStack(spacing: Spacing.md) {
            HStack {
                Image(systemName: "ellipsis.rectangle")
                    .foregroundStyle(strandColor)
                Text("Pattern")
                    .font(.caption.bold())
                    .fontDesign(.rounded)
            }
            .foregroundStyle(.secondary)

            // Sequence items
            HStack(spacing: Spacing.sm) {
                ForEach(Array(sequence.enumerated()), id: \.offset) { index, number in
                    VStack(spacing: 4) {
                        Text(formatNumber(number))
                            .font(.title3.bold())
                            .fontDesign(.rounded)
                            .foregroundStyle(index < revealedCount ? strandColor : .clear)
                            .frame(width: 44, height: 44)
                            .background(
                                RoundedRectangle(cornerRadius: CornerRadius.small)
                                    .fill(index < revealedCount
                                          ? strandColor.opacity(0.12)
                                          : Color.secondary.opacity(0.08))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: CornerRadius.small)
                                    .strokeBorder(
                                        index < revealedCount
                                            ? strandColor.opacity(0.3)
                                            : Color.secondary.opacity(0.15),
                                        lineWidth: 1
                                    )
                            )
                            .scaleEffect(index < revealedCount ? 1 : 0.8)

                        if index < sequence.count - 1 {
                            Image(systemName: "arrow.right")
                                .font(.system(size: 8))
                                .foregroundStyle(.secondary.opacity(0.5))
                        }
                    }
                    .animation(
                        .spring(duration: 0.4, bounce: 0.3).delay(Double(index) * 0.2),
                        value: revealedCount
                    )
                }

                // "What comes next?" placeholder
                Text("?")
                    .font(.title3.bold())
                    .fontDesign(.rounded)
                    .foregroundStyle(strandColor.opacity(0.5))
                    .frame(width: 44, height: 44)
                    .background(
                        RoundedRectangle(cornerRadius: CornerRadius.small)
                            .strokeBorder(strandColor.opacity(0.3), style: StrokeStyle(lineWidth: 2, dash: [5, 3]))
                    )
            }

            // Pattern description
            if sequence.count >= 2 {
                let diff = sequence[1] - sequence[0]
                Text("Pattern: +\(formatNumber(diff)) each step")
                    .font(.caption)
                    .fontDesign(.rounded)
                    .foregroundStyle(.secondary)
                    .opacity(revealedCount >= sequence.count ? 1 : 0)
                    .animation(.easeIn(duration: 0.3), value: revealedCount)
            }
        }
        .padding()
        .onAppear {
            revealedCount = sequence.count
        }
    }

    private func formatNumber(_ num: Double) -> String {
        num == floor(num) ? String(Int(num)) : String(format: "%.1f", num)
    }
}
