import SwiftUI

struct MeasurementScaleView: View {
    let numbers: [Double]
    let keywords: [String]
    let strandColor: Color

    @State private var animatePointer = false

    private var measurementType: MeasurementKind {
        let kw = keywords.joined(separator: " ").lowercased()
        if kw.contains("temperature") { return .thermometer }
        if kw.contains("mass") || kw.contains("weight") { return .scale }
        if kw.contains("capacity") || kw.contains("volume") { return .beaker }
        return .ruler
    }

    private var displayValue: Double { numbers.first ?? 5 }
    private var maxValue: Double { max(numbers.max() ?? 10, displayValue + 2) }

    var body: some View {
        VStack(spacing: Spacing.md) {
            HStack {
                Image(systemName: measurementIcon)
                    .foregroundStyle(strandColor)
                Text(measurementLabel)
                    .font(.caption.bold())
                    .fontDesign(.rounded)
            }
            .foregroundStyle(.secondary)

            switch measurementType {
            case .ruler:
                rulerView
            case .thermometer:
                thermometerView
            case .scale, .beaker:
                beakerView
            }
        }
        .padding()
        .onAppear { animatePointer = true }
    }

    // MARK: - Ruler

    private var rulerView: some View {
        GeometryReader { geo in
            let width = geo.size.width - 20
            let tickSpacing = width / CGFloat(max(maxValue, 1))

            ZStack(alignment: .leading) {
                // Ruler body
                RoundedRectangle(cornerRadius: 4)
                    .fill(strandColor.opacity(0.08))
                    .overlay(
                        RoundedRectangle(cornerRadius: 4)
                            .strokeBorder(strandColor.opacity(0.2), lineWidth: 1)
                    )
                    .frame(height: 50)

                // Tick marks
                ForEach(0...Int(maxValue), id: \.self) { i in
                    let x = 10 + tickSpacing * CGFloat(i)
                    let isMajor = i % 5 == 0

                    VStack(spacing: 2) {
                        Rectangle()
                            .fill(strandColor.opacity(isMajor ? 0.6 : 0.3))
                            .frame(width: 1, height: isMajor ? 20 : 12)

                        if isMajor {
                            Text("\(i)")
                                .font(.system(size: 8, design: .rounded))
                                .foregroundStyle(.secondary)
                        }
                    }
                    .position(x: x, y: 35)
                }

                // Pointer
                Image(systemName: "arrowtriangle.down.fill")
                    .font(.system(size: 14))
                    .foregroundStyle(strandColor)
                    .position(
                        x: animatePointer ? 10 + tickSpacing * CGFloat(displayValue) : 10,
                        y: 6
                    )
                    .animation(.spring(duration: 0.8, bounce: 0.2), value: animatePointer)
            }
        }
        .frame(height: 70)
    }

    // MARK: - Thermometer

    private var thermometerView: some View {
        HStack(spacing: Spacing.md) {
            // Thermometer
            ZStack(alignment: .bottom) {
                Capsule()
                    .fill(Color.secondary.opacity(0.1))
                    .frame(width: 24, height: 120)

                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [.blue, strandColor, .red],
                            startPoint: .bottom,
                            endPoint: .top
                        )
                    )
                    .frame(width: 18, height: animatePointer ? CGFloat(displayValue / maxValue) * 110 + 10 : 10)
                    .animation(.spring(duration: 1.0, bounce: 0.1), value: animatePointer)
                    .padding(.bottom, 3)

                // Bulb
                Circle()
                    .fill(strandColor)
                    .frame(width: 30, height: 30)
                    .offset(y: 10)
            }

            // Scale labels
            VStack(alignment: .leading) {
                Text("\(Int(maxValue))°")
                Spacer()
                Text("\(Int(displayValue))°")
                    .font(.headline.bold())
                    .foregroundStyle(strandColor)
                Spacer()
                Text("0°")
            }
            .font(.caption)
            .fontDesign(.rounded)
            .foregroundStyle(.secondary)
            .frame(height: 130)
        }
    }

    // MARK: - Beaker

    private var beakerView: some View {
        ZStack(alignment: .bottom) {
            // Container
            RoundedRectangle(cornerRadius: 6)
                .fill(Color.secondary.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .strokeBorder(Color.secondary.opacity(0.3), lineWidth: 2)
                )
                .frame(width: 80, height: 120)

            // Fill
            RoundedRectangle(cornerRadius: 4)
                .fill(strandColor.opacity(0.3))
                .frame(
                    width: 74,
                    height: animatePointer ? CGFloat(displayValue / maxValue) * 110 : 0
                )
                .animation(.spring(duration: 0.8, bounce: 0.1), value: animatePointer)
                .padding(.bottom, 3)

            // Value label
            Text(formatNumber(displayValue))
                .font(.headline.bold())
                .fontDesign(.rounded)
                .foregroundStyle(strandColor)
                .offset(y: -60)
        }
        .frame(height: 130)
    }

    private var measurementIcon: String {
        switch measurementType {
        case .ruler: return "ruler"
        case .thermometer: return "thermometer.medium"
        case .scale: return "scalemass"
        case .beaker: return "drop.fill"
        }
    }

    private var measurementLabel: String {
        switch measurementType {
        case .ruler: return "Length"
        case .thermometer: return "Temperature"
        case .scale: return "Mass"
        case .beaker: return "Capacity"
        }
    }

    private func formatNumber(_ num: Double) -> String {
        num == floor(num) ? String(Int(num)) : String(format: "%.1f", num)
    }
}

private enum MeasurementKind {
    case ruler, thermometer, scale, beaker
}
