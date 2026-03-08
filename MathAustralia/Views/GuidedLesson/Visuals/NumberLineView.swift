import SwiftUI

struct NumberLineView: View {
    let numbers: [Double]
    let operation: MathOperation?
    let strandColor: Color

    @State private var animateMarkers = false
    @State private var animateJumps = false

    private var rangeMin: Double {
        let minVal = (numbers.min() ?? 0)
        return floor(min(minVal, 0) - 1)
    }

    private var rangeMax: Double {
        let maxVal = (numbers.max() ?? 10)
        return ceil(maxVal + 1)
    }

    private var tickCount: Int {
        min(Int(rangeMax - rangeMin) + 1, 15)
    }

    var body: some View {
        VStack(spacing: Spacing.md) {
            // Title
            HStack {
                Image(systemName: "line.horizontal.3")
                    .foregroundStyle(strandColor)
                Text("Number Line")
                    .font(.caption.bold())
                    .fontDesign(.rounded)
            }
            .foregroundStyle(.secondary)

            GeometryReader { geo in
                let width = geo.size.width - 40
                let height: CGFloat = 80

                ZStack {
                    // Main line
                    Path { path in
                        path.move(to: CGPoint(x: 20, y: height / 2))
                        path.addLine(to: CGPoint(x: width + 20, y: height / 2))
                    }
                    .stroke(Color.secondary.opacity(0.4), lineWidth: 2)

                    // Arrow heads
                    Path { path in
                        let y = height / 2
                        // Right arrow
                        path.move(to: CGPoint(x: width + 12, y: y - 6))
                        path.addLine(to: CGPoint(x: width + 20, y: y))
                        path.addLine(to: CGPoint(x: width + 12, y: y + 6))
                    }
                    .stroke(Color.secondary.opacity(0.4), lineWidth: 2)

                    // Tick marks and labels
                    ForEach(0..<tickCount, id: \.self) { i in
                        let value = rangeMin + Double(i)
                        let x = 20 + width * CGFloat(Double(i) / Double(max(tickCount - 1, 1)))
                        let y = height / 2

                        // Tick mark
                        Path { path in
                            path.move(to: CGPoint(x: x, y: y - 6))
                            path.addLine(to: CGPoint(x: x, y: y + 6))
                        }
                        .stroke(Color.secondary.opacity(0.6), lineWidth: 1)

                        // Label
                        Text(formatNumber(value))
                            .font(.system(size: 10, design: .rounded))
                            .foregroundStyle(.secondary)
                            .position(x: x, y: y + 20)
                    }

                    // Number markers
                    ForEach(Array(numbers.enumerated()), id: \.offset) { index, number in
                        let fraction = (number - rangeMin) / (rangeMax - rangeMin)
                        let x = 20 + width * CGFloat(fraction)
                        let y = height / 2

                        Circle()
                            .fill(strandColor)
                            .frame(width: 14, height: 14)
                            .overlay(
                                Text(formatNumber(number))
                                    .font(.system(size: 8, weight: .bold, design: .rounded))
                                    .foregroundStyle(.white)
                            )
                            .position(x: x, y: y - 18)
                            .scaleEffect(animateMarkers ? 1 : 0)
                            .animation(
                                .spring(duration: 0.5, bounce: 0.3)
                                    .delay(Double(index) * 0.3),
                                value: animateMarkers
                            )
                    }

                    // Jump arcs between consecutive numbers
                    if numbers.count >= 2, operation != nil {
                        ForEach(0..<numbers.count - 1, id: \.self) { i in
                            let from = (numbers[i] - rangeMin) / (rangeMax - rangeMin)
                            let to = (numbers[i + 1] - rangeMin) / (rangeMax - rangeMin)
                            let fromX = 20 + width * CGFloat(from)
                            let toX = 20 + width * CGFloat(to)
                            let midX = (fromX + toX) / 2
                            let y = height / 2

                            Path { path in
                                path.move(to: CGPoint(x: fromX, y: y - 24))
                                path.addQuadCurve(
                                    to: CGPoint(x: toX, y: y - 24),
                                    control: CGPoint(x: midX, y: y - 50)
                                )
                            }
                            .trim(from: 0, to: animateJumps ? 1 : 0)
                            .stroke(strandColor.opacity(0.6), style: StrokeStyle(lineWidth: 2, dash: [4, 3]))
                            .animation(
                                .easeInOut(duration: 0.8).delay(Double(i) * 0.4 + 0.5),
                                value: animateJumps
                            )
                        }
                    }
                }
            }
            .frame(height: 100)
        }
        .padding()
        .onAppear {
            animateMarkers = true
            animateJumps = true
        }
    }

    private func formatNumber(_ num: Double) -> String {
        num == floor(num) ? String(Int(num)) : String(format: "%.1f", num)
    }
}
