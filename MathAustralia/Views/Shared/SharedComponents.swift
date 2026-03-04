import SwiftUI

// MARK: - Strand Icon View

struct StrandIconView: View {
    let strand: StrandSlug
    let size: CGFloat

    init(strand: StrandSlug, size: CGFloat = 24) {
        self.strand = strand
        self.size = size
    }

    var body: some View {
        Image(systemName: StrandColorSet.icon(for: strand))
            .font(.system(size: size))
            .foregroundStyle(StrandColorSet.primary(for: strand))
    }
}

// MARK: - Difficulty Badge

struct DifficultyBadge: View {
    let difficulty: Difficulty

    var body: some View {
        Text(difficulty.label)
            .font(.caption2.bold())
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

    init(value: Double, color: Color = .blue, height: CGFloat = 8) {
        self.value = min(max(value, 0), 1)
        self.color = color
        self.height = height
    }

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(color.opacity(0.2))
                    .frame(height: height)

                Capsule()
                    .fill(color)
                    .frame(width: geo.size.width * value, height: height)
                    .animation(.spring(duration: 0.5), value: value)
            }
        }
        .frame(height: height)
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
                .font(.title2)
                .foregroundStyle(color)

            Text(value)
                .font(.title3.bold())

            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Section Header

struct SectionHeader: View {
    let title: String
    let icon: String?

    init(_ title: String, icon: String? = nil) {
        self.title = title
        self.icon = icon
    }

    var body: some View {
        HStack(spacing: 8) {
            if let icon {
                Image(systemName: icon)
            }
            Text(title)
                .font(.headline)
        }
    }
}
