import SwiftUI

struct GenericIllustrationView: View {
    let strandSlug: StrandSlug
    let strandColor: Color

    @State private var animate = false

    private let mathSymbols = ["+", "-", "×", "÷", "=", "π", "√", "∑", "%", "∞"]

    var body: some View {
        ZStack {
            // Background gradient
            RoundedRectangle(cornerRadius: CornerRadius.large)
                .fill(
                    LinearGradient(
                        colors: [strandColor.opacity(0.08), strandColor.opacity(0.15)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            // Floating math symbols
            ForEach(0..<8, id: \.self) { index in
                Text(mathSymbols[index % mathSymbols.count])
                    .font(.system(size: CGFloat(16 + (index * 5) % 14)))
                    .foregroundStyle(strandColor.opacity(0.2))
                    .offset(
                        x: CGFloat((index * 37 - 100) % 120),
                        y: CGFloat((index * 23 - 60) % 80)
                    )
                    .rotationEffect(.degrees(Double(index * 25)))
                    .scaleEffect(animate ? 1 : 0.5)
                    .animation(
                        .easeInOut(duration: 1.5)
                            .repeatForever(autoreverses: true)
                            .delay(Double(index) * 0.15),
                        value: animate
                    )
            }

            // Central strand icon
            VStack(spacing: Spacing.sm) {
                Image(systemName: StrandColorSet.icon(for: strandSlug))
                    .font(.system(size: 40))
                    .foregroundStyle(strandColor)
                    .scaleEffect(animate ? 1.05 : 0.95)
                    .animation(
                        .easeInOut(duration: 2).repeatForever(autoreverses: true),
                        value: animate
                    )

                Text(strandSlug.rawValue.capitalized)
                    .font(.caption.bold())
                    .fontDesign(.rounded)
                    .foregroundStyle(strandColor)
            }
        }
        .frame(height: 160)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.large))
        .onAppear { animate = true }
    }
}
