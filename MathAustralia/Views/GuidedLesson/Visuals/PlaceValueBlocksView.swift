import SwiftUI

struct PlaceValueBlocksView: View {
    let numbers: [Double]
    let strandColor: Color

    @State private var animate = false

    private var displayNumber: Int {
        Int(numbers.first ?? 345)
    }

    private var thousands: Int { displayNumber / 1000 }
    private var hundreds: Int { (displayNumber % 1000) / 100 }
    private var tens: Int { (displayNumber % 100) / 10 }
    private var ones: Int { displayNumber % 10 }

    var body: some View {
        VStack(spacing: Spacing.md) {
            HStack {
                Image(systemName: "cube.fill")
                    .foregroundStyle(strandColor)
                Text("Place Value Blocks")
                    .font(.caption.bold())
                    .fontDesign(.rounded)
            }
            .foregroundStyle(.secondary)

            Text(String(displayNumber))
                .font(.title2.bold())
                .fontDesign(.rounded)
                .foregroundStyle(strandColor)

            HStack(alignment: .bottom, spacing: Spacing.lg) {
                if thousands > 0 {
                    placeColumn(count: thousands, label: "Thousands", blockView: AnyView(thousandBlock))
                }
                placeColumn(count: hundreds, label: "Hundreds", blockView: AnyView(hundredBlock))
                placeColumn(count: tens, label: "Tens", blockView: AnyView(tenBlock))
                placeColumn(count: ones, label: "Ones", blockView: AnyView(oneBlock))
            }
        }
        .padding()
        .onAppear { animate = true }
    }

    private func placeColumn(count: Int, label: String, blockView: AnyView) -> some View {
        VStack(spacing: Spacing.xxs) {
            VStack(spacing: 2) {
                ForEach(0..<min(count, 9), id: \.self) { i in
                    blockView
                        .scaleEffect(animate ? 1 : 0)
                        .animation(
                            .spring(duration: 0.4, bounce: 0.3).delay(Double(i) * 0.08),
                            value: animate
                        )
                }
            }
            .frame(minHeight: 40)

            Text("\(count)")
                .font(.caption.bold())
                .fontDesign(.rounded)
                .foregroundStyle(strandColor)

            Text(label)
                .font(.system(size: 9, design: .rounded))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }

    private var thousandBlock: some View {
        RoundedRectangle(cornerRadius: 3)
            .fill(strandColor.opacity(0.25))
            .overlay(
                RoundedRectangle(cornerRadius: 3)
                    .strokeBorder(strandColor.opacity(0.5), lineWidth: 1)
            )
            .frame(width: 32, height: 32)
    }

    private var hundredBlock: some View {
        RoundedRectangle(cornerRadius: 2)
            .fill(strandColor.opacity(0.2))
            .overlay(
                RoundedRectangle(cornerRadius: 2)
                    .strokeBorder(strandColor.opacity(0.4), lineWidth: 1)
            )
            .frame(width: 28, height: 28)
    }

    private var tenBlock: some View {
        RoundedRectangle(cornerRadius: 2)
            .fill(strandColor.opacity(0.15))
            .overlay(
                RoundedRectangle(cornerRadius: 2)
                    .strokeBorder(strandColor.opacity(0.3), lineWidth: 1)
            )
            .frame(width: 10, height: 28)
    }

    private var oneBlock: some View {
        RoundedRectangle(cornerRadius: 2)
            .fill(strandColor.opacity(0.12))
            .overlay(
                RoundedRectangle(cornerRadius: 2)
                    .strokeBorder(strandColor.opacity(0.25), lineWidth: 1)
            )
            .frame(width: 10, height: 10)
    }
}
