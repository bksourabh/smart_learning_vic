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
        List {
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 12) {
                        StrandIconView(strand: strand.slug, size: 32)
                        VStack(alignment: .leading) {
                            Text(strand.fullName)
                                .font(.headline)
                            Text("\(lessons.count) lessons")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    Text(strand.description)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 4)
            }

            Section("Lessons") {
                ForEach(lessons) { lesson in
                    NavigationLink {
                        LessonDetailView(lesson: lesson)
                    } label: {
                        LessonRow(lesson: lesson, isCompleted: isCompleted(lesson))
                    }
                }
            }

            if let practice = practiceTest {
                Section("Practice Test") {
                    NavigationLink {
                        PracticeTestView(practiceTest: practice)
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.title2)
                                .foregroundStyle(StrandColorSet.primary(for: strand.slug))

                            VStack(alignment: .leading, spacing: 2) {
                                Text(practice.title)
                                    .font(.subheadline.bold())
                                Text("\(practice.questions.count) questions • Pass: \(practice.passingScore)%")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }

                            Spacer()

                            if let best = bestResult(for: practice) {
                                Text("\(Int(best.percentage))%")
                                    .font(.caption.bold())
                                    .foregroundStyle(best.passed ? .green : .orange)
                            }
                        }
                    }
                }
            }
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

private struct LessonRow: View {
    let lesson: Lesson
    let isCompleted: Bool

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                .foregroundStyle(isCompleted ? .green : .secondary)

            VStack(alignment: .leading, spacing: 4) {
                Text(lesson.title)
                    .font(.subheadline.bold())

                HStack(spacing: 8) {
                    DifficultyBadge(difficulty: lesson.difficulty)

                    Text("\(lesson.estimatedMinutes) min")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()
        }
    }
}
