import SwiftUI

struct LevelDetailView: View {
    let level: LevelMeta
    @Environment(CurriculumService.self) private var curriculumService
    @Environment(AppState.self) private var appState

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Level header
                VStack(spacing: 8) {
                    Text(level.name)
                        .font(.title.bold())
                    Text(level.yearRange)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Text(level.description)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .padding(.top)

                // Strand cards
                ForEach(curriculumService.strands) { strand in
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
                    .buttonStyle(.plain)
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
        HStack(spacing: 16) {
            // Strand icon
            StrandIconView(strand: strand.slug, size: 28)
                .frame(width: 48, height: 48)
                .background(StrandColorSet.background(for: strand.slug))
                .clipShape(RoundedRectangle(cornerRadius: 12))

            VStack(alignment: .leading, spacing: 4) {
                Text(strand.name)
                    .font(.headline)

                HStack(spacing: 8) {
                    Text("\(lessonCount) lessons")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    if practiceAvailable {
                        Text("Practice")
                            .font(.caption2.bold())
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(.blue.opacity(0.1))
                            .foregroundStyle(.blue)
                            .clipShape(Capsule())
                    }
                }

                if lessonCount > 0 {
                    ProgressBarView(
                        value: Double(completedCount) / Double(lessonCount),
                        color: StrandColorSet.primary(for: strand.slug),
                        height: 4
                    )
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundStyle(.tertiary)
        }
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
