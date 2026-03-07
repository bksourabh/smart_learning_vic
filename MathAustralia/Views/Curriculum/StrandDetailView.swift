import SwiftUI

struct StrandDetailView: View {
    let level: LevelMeta
    let strand: StrandDefinition
    @Environment(CurriculumService.self) private var curriculumService
    @Environment(AppState.self) private var appState

    private var lessons: [Lesson] {
        curriculumService.getLessons(levelSlug: level.slug, strandSlug: strand.slug.rawValue)
    }

    private var practiceTest: PracticeTest? {
        curriculumService.getPractice(levelSlug: level.slug, strandSlug: strand.slug.rawValue)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.md) {
                // Strand banner header
                HStack(spacing: Spacing.md) {
                    StrandIconView(strand: strand.slug, size: 56, showBackground: true)

                    VStack(alignment: .leading, spacing: Spacing.xxs) {
                        Text(strand.fullName)
                            .font(.headline)
                            .fontDesign(.rounded)
                        Text("\(lessons.count) lessons")
                            .font(.caption)
                            .fontDesign(.rounded)
                            .foregroundStyle(.secondary)
                        Text(strand.description)
                            .font(.caption)
                            .fontDesign(.rounded)
                            .foregroundStyle(.secondary)
                            .lineLimit(2)
                    }
                }
                .padding(Spacing.md)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(StrandColorSet.lightGradient(for: strand.slug))
                .clipShape(RoundedRectangle(cornerRadius: CornerRadius.medium))

                // Lesson path
                VStack(spacing: 0) {
                    ForEach(Array(lessons.enumerated()), id: \.element.id) { index, lesson in
                        HStack(spacing: Spacing.md) {
                            // Numbered circle with connecting line
                            VStack(spacing: 0) {
                                if index > 0 {
                                    Rectangle()
                                        .fill(StrandColorSet.primary(for: strand.slug).opacity(0.2))
                                        .frame(width: 2, height: 12)
                                }

                                ZStack {
                                    Circle()
                                        .fill(
                                            isCompleted(lesson)
                                                ? StrandColorSet.primary(for: strand.slug)
                                                : StrandColorSet.primary(for: strand.slug).opacity(0.15)
                                        )
                                        .frame(width: 32, height: 32)

                                    if isCompleted(lesson) {
                                        Image(systemName: "checkmark")
                                            .font(.caption.bold())
                                            .foregroundStyle(.white)
                                    } else {
                                        Text("\(index + 1)")
                                            .font(.caption.bold())
                                            .fontDesign(.rounded)
                                            .foregroundStyle(StrandColorSet.primary(for: strand.slug))
                                    }
                                }

                                if index < lessons.count - 1 {
                                    Rectangle()
                                        .fill(StrandColorSet.primary(for: strand.slug).opacity(0.2))
                                        .frame(width: 2, height: 12)
                                }
                            }

                            NavigationLink {
                                LessonDetailView(lesson: lesson)
                            } label: {
                                HStack {
                                    VStack(alignment: .leading, spacing: Spacing.xxs) {
                                        Text(lesson.title)
                                            .font(.subheadline.bold())
                                            .fontDesign(.rounded)

                                        HStack(spacing: Spacing.xs) {
                                            DifficultyBadge(difficulty: lesson.difficulty)
                                            Text("\(lesson.estimatedMinutes) min")
                                                .font(.caption2)
                                                .fontDesign(.rounded)
                                                .foregroundStyle(.secondary)
                                        }
                                    }

                                    Spacer()

                                    Image(systemName: "chevron.right")
                                        .font(.caption)
                                        .foregroundStyle(.tertiary)
                                }
                                .padding(Spacing.sm)
                                .background(.regularMaterial)
                                .clipShape(RoundedRectangle(cornerRadius: CornerRadius.small))
                            }
                            .buttonStyle(.plain)
                        }
                        .staggeredEntrance(index: index)
                    }
                }

                // Practice test
                if let practice = practiceTest {
                    VStack(alignment: .leading, spacing: Spacing.sm) {
                        SectionHeader("Practice Test", icon: "checkmark.circle.fill", accentColor: StrandColorSet.primary(for: strand.slug))

                        NavigationLink {
                            PracticeTestView(practiceTest: practice)
                        } label: {
                            HStack(spacing: Spacing.sm) {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.title2)
                                    .foregroundStyle(StrandColorSet.primary(for: strand.slug))

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(practice.title)
                                        .font(.subheadline.bold())
                                        .fontDesign(.rounded)
                                    Text("\(practice.questions.count) questions  \u{2022}  Pass: \(practice.passingScore)%")
                                        .font(.caption)
                                        .fontDesign(.rounded)
                                        .foregroundStyle(.secondary)
                                }

                                Spacer()

                                if let best = bestResult(for: practice) {
                                    Text("\(Int(best.percentage))%")
                                        .font(.caption.bold())
                                        .fontDesign(.rounded)
                                        .foregroundStyle(best.passed ? .green : .orange)
                                }
                            }
                            .padding()
                            .appCard(shadowColor: StrandColorSet.primary(for: strand.slug).opacity(0.1))
                        }
                        .buttonStyle(.press)
                    }
                }
            }
            .padding()
        }
        .navigationTitle(strand.name)
        .navigationBarTitleDisplayMode(.inline)
    }

    private func isCompleted(_ lesson: Lesson) -> Bool {
        guard let child = appState.activeChild else { return false }
        return child.lessonProgress.contains {
            $0.lessonSlug == lesson.slug && $0.completed
        }
    }

    private func bestResult(for practice: PracticeTest) -> PracticeResultRecord? {
        guard let child = appState.activeChild else { return nil }
        return child.practiceResults
            .filter { $0.practiceId == practice.id }
            .max(by: { $0.percentage < $1.percentage })
    }
}
