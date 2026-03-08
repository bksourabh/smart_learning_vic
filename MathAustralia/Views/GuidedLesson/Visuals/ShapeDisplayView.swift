import SwiftUI

struct ShapeDisplayView: View {
    let keywords: [String]
    let numbers: [Double]
    let strandColor: Color

    @State private var animateShape = false

    private var shapeType: ShapeKind {
        let kw = keywords.joined(separator: " ").lowercased()
        if kw.contains("triangle") { return .triangle }
        if kw.contains("circle") { return .circle }
        if kw.contains("square") { return .square }
        if kw.contains("rectangle") { return .rectangle }
        if kw.contains("polygon") || kw.contains("hexagon") { return .hexagon }
        return .rectangle
    }

    var body: some View {
        VStack(spacing: Spacing.md) {
            HStack {
                Image(systemName: "cube")
                    .foregroundStyle(strandColor)
                Text("Shape")
                    .font(.caption.bold())
                    .fontDesign(.rounded)
            }
            .foregroundStyle(.secondary)

            ZStack {
                shapeView
                    .scaleEffect(animateShape ? 1 : 0.3)
                    .opacity(animateShape ? 1 : 0)
                    .animation(.spring(duration: 0.6, bounce: 0.2), value: animateShape)
            }
            .frame(height: 140)

            if !numbers.isEmpty {
                HStack(spacing: Spacing.sm) {
                    ForEach(Array(numbers.prefix(3).enumerated()), id: \.offset) { _, num in
                        Text(formatNumber(num))
                            .font(.caption.bold())
                            .fontDesign(.rounded)
                            .foregroundStyle(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(strandColor.opacity(0.8))
                            .clipShape(Capsule())
                    }
                }
            }
        }
        .padding()
        .onAppear { animateShape = true }
    }

    @ViewBuilder
    private var shapeView: some View {
        switch shapeType {
        case .triangle:
            TriangleShape()
                .fill(strandColor.opacity(0.15))
                .overlay(TriangleShape().stroke(strandColor, lineWidth: 2))
                .frame(width: 120, height: 110)

        case .circle:
            Circle()
                .fill(strandColor.opacity(0.15))
                .overlay(Circle().stroke(strandColor, lineWidth: 2))
                .frame(width: 120, height: 120)

        case .square:
            Rectangle()
                .fill(strandColor.opacity(0.15))
                .overlay(Rectangle().stroke(strandColor, lineWidth: 2))
                .frame(width: 110, height: 110)

        case .rectangle:
            Rectangle()
                .fill(strandColor.opacity(0.15))
                .overlay(Rectangle().stroke(strandColor, lineWidth: 2))
                .frame(width: 140, height: 90)

        case .hexagon:
            HexagonShape()
                .fill(strandColor.opacity(0.15))
                .overlay(HexagonShape().stroke(strandColor, lineWidth: 2))
                .frame(width: 120, height: 110)
        }
    }

    private func formatNumber(_ num: Double) -> String {
        num == floor(num) ? String(Int(num)) : String(format: "%.1f", num)
    }
}

// MARK: - Shape Kind

private enum ShapeKind {
    case triangle, circle, square, rectangle, hexagon
}

// MARK: - Triangle Shape

private struct TriangleShape: Shape {
    func path(in rect: CGRect) -> Path {
        Path { path in
            path.move(to: CGPoint(x: rect.midX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
            path.closeSubpath()
        }
    }
}

// MARK: - Hexagon Shape

private struct HexagonShape: Shape {
    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2
        var path = Path()
        for i in 0..<6 {
            let angle = Angle(degrees: Double(i) * 60 - 90)
            let point = CGPoint(
                x: center.x + radius * CGFloat(Foundation.cos(angle.radians)),
                y: center.y + radius * CGFloat(Foundation.sin(angle.radians))
            )
            if i == 0 {
                path.move(to: point)
            } else {
                path.addLine(to: point)
            }
        }
        path.closeSubpath()
        return path
    }
}
