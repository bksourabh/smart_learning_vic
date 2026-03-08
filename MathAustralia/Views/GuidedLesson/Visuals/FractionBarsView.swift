import SwiftUI

struct FractionBarsView: View {
    let fractions: [(Int, Int)]
    let strandColor: Color

    @State private var animateFill = false

    private var displayFractions: [(Int, Int)] {
        fractions.isEmpty ? [(1, 2), (2, 4)] : Array(fractions.prefix(3))
    }

    var body: some View {
        VStack(spacing: Spacing.md) {
            HStack {
                Image(systemName: "rectangle.split.3x1")
                    .foregroundStyle(strandColor)
                Text("Fraction Bars")
                    .font(.caption.bold())
                    .fontDesign(.rounded)
            }
            .foregroundStyle(.secondary)

            VStack(spacing: Spacing.md) {
                ForEach(Array(displayFractions.enumerated()), id: \.offset) { index, fraction in
                    fractionBar(
                        numerator: fraction.0,
                        denominator: fraction.1,
                        delay: Double(index) * 0.3
                    )
                }
            }
        }
        .padding()
        .onAppear { animateFill = true }
    }

    private func fractionBar(numerator: Int, denominator: Int, delay: Double) -> some View {
        VStack(spacing: Spacing.xxs) {
            // Label
            Text("\(numerator)/\(denominator)")
                .font(.subheadline.bold())
                .fontDesign(.rounded)
                .foregroundStyle(strandColor)

            // Bar
            GeometryReader { geo in
                let segmentWidth = geo.size.width / CGFloat(denominator)

                HStack(spacing: 1) {
                    ForEach(0..<denominator, id: \.self) { i in
                        RoundedRectangle(cornerRadius: 3)
                            .fill(i < numerator ? strandColor.opacity(0.7) : strandColor.opacity(0.1))
                            .overlay(
                                RoundedRectangle(cornerRadius: 3)
                                    .strokeBorder(strandColor.opacity(0.3), lineWidth: 1)
                            )
                            .frame(width: segmentWidth - 1)
                            .scaleEffect(y: animateFill ? 1 : 0, anchor: .bottom)
                            .animation(
                                .spring(duration: 0.4, bounce: 0.2)
                                    .delay(delay + Double(i) * 0.05),
                                value: animateFill
                            )
                    }
                }
            }
            .frame(height: 36)
        }
    }
}
