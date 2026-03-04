import SwiftUI

struct LevelListView: View {
    @Environment(CurriculumService.self) private var curriculumService
    @Environment(AppState.self) private var appState

    var body: some View {
        ScrollView {
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 16),
                GridItem(.flexible(), spacing: 16)
            ], spacing: 16) {
                ForEach(curriculumService.levels) { level in
                    NavigationLink(value: level) {
                        LevelCard(level: level, child: appState.activeChild)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding()
        }
        .navigationTitle("Learn")
        .navigationDestination(for: LevelMeta.self) { level in
            LevelDetailView(level: level)
        }
    }
}

private struct LevelCard: View {
    let level: LevelMeta
    let child: ChildProfile?
    @Environment(CurriculumService.self) private var curriculumService
    @Environment(\.modelContext) private var modelContext

    private var completedLessons: Int {
        guard let child else { return 0 }
        var count = 0
        for strand in StrandSlug.allCases {
            count += child.lessonProgress.filter {
                $0.completed && $0.levelSlug == level.slug && $0.strandSlug == strand.rawValue
            }.count
        }
        return count
    }

    private var totalLessons: Int {
        var count = 0
        for strand in StrandSlug.allCases {
            count += curriculumService.getLessons(levelSlug: level.slug, strandSlug: strand.rawValue).count
        }
        return count
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(level.shortName)
                    .font(.headline)
                    .foregroundStyle(.white)
                Spacer()
                if totalLessons > 0 {
                    Text("\(completedLessons)/\(totalLessons)")
                        .font(.caption.bold())
                        .foregroundStyle(.white.opacity(0.8))
                }
            }

            Text(level.yearRange)
                .font(.caption)
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
        .background(Color(hex: level.color))
        .clipShape(RoundedRectangle(cornerRadius: 12))
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
