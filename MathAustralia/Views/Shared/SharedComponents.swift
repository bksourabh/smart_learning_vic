import SwiftUI

// MARK: - Strand Icon View

struct StrandIconView: View {
    let strand: StrandSlug
    let size: CGFloat
    let showBackground: Bool

    init(strand: StrandSlug, size: CGFloat = 24, showBackground: Bool = false) {
        self.strand = strand
        self.size = size
        self.showBackground = showBackground
    }

    var body: some View {
        if showBackground {
            Image(systemName: StrandColorSet.icon(for: strand))
                .font(.system(size: size * 0.55))
                .foregroundStyle(.white)
                .frame(width: size, height: size)
                .background(StrandColorSet.gradient(for: strand))
                .clipShape(RoundedRectangle(cornerRadius: size * 0.25))
        } else {
            Image(systemName: StrandColorSet.icon(for: strand))
                .font(.system(size: size))
                .foregroundStyle(StrandColorSet.primary(for: strand))
        }
    }
}

// MARK: - Difficulty Badge

struct DifficultyBadge: View {
    let difficulty: Difficulty

    var body: some View {
        Text(difficulty.label)
            .font(.caption2.bold())
            .fontDesign(.rounded)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(backgroundColor)
            .foregroundStyle(foregroundColor)
            .clipShape(Capsule())
    }

    private var backgroundColor: Color {
        switch difficulty {
        case .easy: return .green.opacity(0.15)
        case .medium: return .orange.opacity(0.15)
        case .hard: return .red.opacity(0.15)
        }
    }

    private var foregroundColor: Color {
        switch difficulty {
        case .easy: return .green
        case .medium: return .orange
        case .hard: return .red
        }
    }
}

// MARK: - Progress Bar View

struct ProgressBarView: View {
    let value: Double  // 0.0 to 1.0
    let color: Color
    let height: CGFloat
    let useGradient: Bool

    @State private var animatedValue: Double = 0

    init(value: Double, color: Color = .blue, height: CGFloat = 8, useGradient: Bool = false) {
        self.value = min(max(value, 0), 1)
        self.color = color
        self.height = height
        self.useGradient = useGradient
    }

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(color.opacity(0.15))
                    .frame(height: height)

                Capsule()
                    .fill(
                        useGradient
                            ? AnyShapeStyle(LinearGradient(colors: [color.opacity(0.8), color], startPoint: .leading, endPoint: .trailing))
                            : AnyShapeStyle(color)
                    )
                    .frame(width: geo.size.width * animatedValue, height: height)
            }
        }
        .frame(height: height)
        .onAppear {
            withAnimation(.spring(duration: 0.8, bounce: 0.1).delay(0.3)) {
                animatedValue = value
            }
        }
        .onChange(of: value) { _, newValue in
            withAnimation(.spring(duration: 0.5)) {
                animatedValue = newValue
            }
        }
    }
}

// MARK: - Stat Card

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(.white)
                .frame(width: 36, height: 36)
                .background(color.gradient)
                .clipShape(Circle())

            Text(value)
                .font(.title3.bold())
                .fontDesign(.rounded)

            Text(title)
                .font(.caption)
                .fontDesign(.rounded)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .appCard()
    }
}

// MARK: - Section Header

struct SectionHeader: View {
    let title: String
    let icon: String?
    let accentColor: Color

    init(_ title: String, icon: String? = nil, accentColor: Color = .blue) {
        self.title = title
        self.icon = icon
        self.accentColor = accentColor
    }

    var body: some View {
        HStack(spacing: 8) {
            RoundedRectangle(cornerRadius: 2)
                .fill(accentColor.gradient)
                .frame(width: 4, height: 20)

            if let icon {
                Image(systemName: icon)
                    .foregroundStyle(accentColor)
            }
            Text(title)
                .font(.headline)
                .fontDesign(.rounded)
        }
    }
}
