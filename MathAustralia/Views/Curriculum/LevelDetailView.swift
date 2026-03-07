import SwiftUI

struct LevelDetailView: View {
    let level: LevelMeta
    @Environment(CurriculumService.self) private var curriculumService
    @Environment(AppState.self) private var appState

    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.md) {
                // Gradient header banner
                VStack(spacing: Spacing.xs) {
                    Text(level.name)
                        .font(.title.bold())
                        .fontDesign(.rounded)
                        .foregroundStyle(.white)

                    Text(level.yearRange)
                        .font(.subheadline)
                        .fontDesign(.rounded)
                        .foregroundStyle(.white.opacity(0.8))

                    Text(level.description)
                        .font(.caption)
                        .fontDesign(.rounded)
                        .foregroundStyle(.white.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)

                    VictorianCurriculumBadge(size: .small)
                        .padding(.top, Spacing.xxs)
                }
                .padding(Spacing.xl)
                .frame(maxWidth: .infinity)
                .background(
                    LinearGradient(
                        colors: [Color(hex: level.color), Color(hex: level.color).opacity(0.8)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: CornerRadius.large))
                .shadow(color: Color(hex: level.color).opacity(0.3), radius: 8, x: 0, y: 4)

                // Strand cards
                ForEach(Array(curriculumService.strands.enumerated()), id: \.element.id) { index, strand in
                    let overview = curriculumService.getStrandsForLevel(level.slug)
                        .first { $0.strandSlug == strand.slug }

                    NavigationLink {
                        StrandDetailView(level: level, strand: strand)
                    } label: {
                        StrandCard(
                            strand: strand,
                            lessonCount: overview?.lessonCount ?? 0,
                            completedCount: completedCount(for: strand.slug),
                            practiceAvailable: overview?.practiceAvailable ?? false
                        )
                    }
                    .buttonStyle(.press)
                    .staggeredEntrance(index: index + 1)
                }
            }
            .padding()
        }
        .navigationTitle(level.shortName)
        .navigationBarTitleDisplayMode(.inline)
    }

    private func completedCount(for strandSlug: StrandSlug) -> Int {
        guard let child = appState.activeChild else { return 0 }
        return child.lessonProgress.filter {
            $0.completed && $0.levelSlug == level.slug && $0.strandSlug == strandSlug.rawValue
        }.count
    }
}

private struct StrandCard: View {
    let strand: StrandDefinition
    let lessonCount: Int
    let completedCount: Int
    let practiceAvailable: Bool

    var body: some View {
        HStack(spacing: Spacing.md) {
            // Left-edge color bar
            RoundedRectangle(cornerRadius: 2)
                .fill(StrandColorSet.gradient(for: strand.slug))
                .frame(width: 4)
                .padding(.vertical, -16)

            // Gradient icon background
            StrandIconView(strand: strand.slug, size: 48, showBackground: true)

            VStack(alignment: .leading, spacing: Spacing.xxs) {
                Text(strand.name)
                    .font(.headline)
                    .fontDesign(.rounded)

                HStack(spacing: Spacing.xs) {
                    Text("\(lessonCount) lessons")
                        .font(.caption)
                        .fontDesign(.rounded)
                        .foregroundStyle(.secondary)

                    if practiceAvailable {
                        Text("Practice")
                            .font(.caption2.bold())
                            .fontDesign(.rounded)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(StrandColorSet.primary(for: strand.slug).opacity(0.1))
                            .foregroundStyle(StrandColorSet.primary(for: strand.slug))
                            .clipShape(Capsule())
                    }
                }

                if lessonCount > 0 {
                    ProgressBarView(
                        value: Double(completedCount) / Double(lessonCount),
                        color: StrandColorSet.primary(for: strand.slug),
                        height: 4,
                        useGradient: true
                    )
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundStyle(.tertiary)
        }
        .padding()
        .appCard(shadowColor: StrandColorSet.primary(for: strand.slug).opacity(0.1))
    }
}
