import SwiftUI

struct LevelListView: View {
    @Environment(CurriculumService.self) private var curriculumService
    @Environment(AppState.self) private var appState

    @State private var lessonCounts: [String: Int] = [:]

    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.md) {
                // Victorian badge + active child chip
                HStack {
                    VictorianCurriculumBadge(size: .small)

                    Spacer()

                    if let child = appState.activeChild {
                        HStack(spacing: 6) {
                            Text(child.emoji)
                                .font(.caption)
                            Text(child.name)
                                .font(.caption.bold())
                                .fontDesign(.rounded)
                        }
                        .padding(.horizontal, Spacing.sm)
                        .padding(.vertical, Spacing.xxs)
                        .background(.blue.opacity(0.1))
                        .clipShape(Capsule())
                    }
                }
                .padding(.horizontal)

                LazyVGrid(columns: [
                    GridItem(.flexible(), spacing: Spacing.md),
                    GridItem(.flexible(), spacing: Spacing.md)
                ], spacing: Spacing.md) {
                    ForEach(Array(curriculumService.levels.enumerated()), id: \.element.id) { index, level in
                        NavigationLink(value: level) {
                            LevelCard(
                                level: level,
                                child: appState.activeChild,
                                totalLessons: lessonCounts[level.slug] ?? 0
                            )
                        }
                        .buttonStyle(.press)
                        .staggeredEntrance(index: index)
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .navigationTitle("Learn")
        .navigationDestination(for: LevelMeta.self) { level in
            LevelDetailView(level: level)
        }
        .task {
            guard lessonCounts.isEmpty else { return }
            var counts: [String: Int] = [:]
            for level in curriculumService.levels {
                var count = 0
                for strand in StrandSlug.allCases {
                    count += curriculumService.getLessons(levelSlug: level.slug, strandSlug: strand.rawValue).count
                }
                counts[level.slug] = count
            }
            lessonCounts = counts
        }
    }
}

private struct LevelCard: View {
    let level: LevelMeta
    let child: ChildProfile?
    let totalLessons: Int

    private var completedLessons: Int {
        guard let child else { return 0 }
        return child.lessonProgress.filter {
            $0.completed && $0.levelSlug == level.slug
        }.count
    }

    private var isComplete: Bool {
        totalLessons > 0 && completedLessons >= totalLessons
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            HStack {
                // Level number badge
                Text(level.shortName.replacingOccurrences(of: "Level ", with: "L").replacingOccurrences(of: "Foundation", with: "F"))
                    .font(.caption2.bold())
                    .fontDesign(.rounded)
                    .foregroundStyle(.white)
                    .frame(width: 28, height: 28)
                    .background(.white.opacity(0.25))
                    .clipShape(Circle())

                Spacer()

                if isComplete {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.white)
                        .font(.title3)
                } else if totalLessons > 0 {
                    Text("\(completedLessons)/\(totalLessons)")
                        .font(.caption.bold())
                        .fontDesign(.rounded)
                        .foregroundStyle(.white.opacity(0.8))
                }
            }

            Text(level.shortName)
                .font(.headline)
                .fontDesign(.rounded)
                .foregroundStyle(.white)

            Text(level.yearRange)
                .font(.caption)
                .fontDesign(.rounded)
                .foregroundStyle(.white.opacity(0.8))

            if totalLessons > 0 {
                ProgressBarView(
                    value: Double(completedLessons) / Double(totalLessons),
                    color: .white,
                    height: 4
                )
            }
        }
        .padding()
        .background(
            LinearGradient(
                colors: [Color(hex: level.color), Color(hex: level.color).opacity(0.85)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.large))
        .shadow(color: Color(hex: level.color).opacity(0.3), radius: 8, x: 0, y: 4)
    }
}

extension LevelMeta: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(slug)
    }

    public static func == (lhs: LevelMeta, rhs: LevelMeta) -> Bool {
        lhs.slug == rhs.slug
    }
}
