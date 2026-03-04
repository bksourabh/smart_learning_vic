import SwiftUI

struct LessonDetailView: View {
    let lesson: Lesson
    @Environment(AppState.self) private var appState
    @Environment(\.modelContext) private var modelContext

    @State private var showObjectives = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        DifficultyBadge(difficulty: lesson.difficulty)
                        Text("\(lesson.estimatedMinutes) min")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    Text(lesson.description)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                // Objectives
                if !lesson.objectives.isEmpty {
                    DisclosureGroup("Learning Objectives", isExpanded: $showObjectives) {
                        VStack(alignment: .leading, spacing: 6) {
                            ForEach(lesson.objectives, id: \.self) { objective in
                                HStack(alignment: .top, spacing: 8) {
                                    Image(systemName: "checkmark.circle")
                                        .foregroundStyle(.green)
                                        .font(.caption)
                                        .padding(.top, 2)
                                    Text(objective)
                                        .font(.caption)
                                }
                            }
                        }
                        .padding(.top, 8)
                    }
                    .tint(.primary)
                }

                // Sections
                ForEach(lesson.sections, id: \.stableId) { section in
                    LessonSectionView(section: section)
                }

                // Worked Examples
                if !lesson.workedExamples.isEmpty {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Worked Examples")
                            .font(.title3.bold())

                        ForEach(lesson.workedExamples, id: \.stableId) { example in
                            WorkedExampleCard(example: example)
                        }
                    }
                }

                // Mark as complete button
                Button {
                    markComplete()
                } label: {
                    HStack {
                        Image(systemName: isCompleted ? "checkmark.circle.fill" : "checkmark.circle")
                        Text(isCompleted ? "Completed" : "Mark as Complete")
                    }
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                }
                .buttonStyle(.borderedProminent)
                .tint(isCompleted ? .green : .blue)
                .disabled(isCompleted)
                .padding(.top, 8)
            }
            .padding()
        }
        .navigationTitle(lesson.title)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            recordStart()
        }
    }

    private var isCompleted: Bool {
        guard let child = appState.activeChild else { return false }
        return child.lessonProgress.contains {
            $0.lessonSlug == lesson.slug && $0.completed
        }
    }

    private func recordStart() {
        guard let child = appState.activeChild else { return }
        let progressService = ProgressService(modelContext: modelContext)
        progressService.startLesson(lesson, for: child)
        let streakService = StreakService(modelContext: modelContext)
        streakService.recordActivity(for: child)
    }

    private func markComplete() {
        guard let child = appState.activeChild else { return }
        let progressService = ProgressService(modelContext: modelContext)
        progressService.completeLesson(lesson, for: child)
        let achievementService = AchievementService(
            modelContext: modelContext,
            curriculumService: CurriculumService(),
            progressService: progressService,
            streakService: StreakService(modelContext: modelContext)
        )
        achievementService.checkAndUnlock(for: child)
    }
}

// MARK: - Lesson Section View

struct LessonSectionView: View {
    let section: LessonSection
    @State private var contentHeight: CGFloat = 200

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let title = section.title {
                HStack(spacing: 8) {
                    sectionIcon
                    Text(title)
                        .font(.headline)
                }
            }

            MathTextView(content: section.content, dynamicHeight: $contentHeight)
                .frame(height: contentHeight)

            if let steps = section.steps, !steps.isEmpty {
                VStack(alignment: .leading, spacing: 6) {
                    ForEach(Array(steps.enumerated()), id: \.offset) { index, step in
                        HStack(alignment: .top, spacing: 8) {
                            Text("\(index + 1).")
                                .font(.caption.bold())
                                .foregroundStyle(.secondary)
                                .frame(width: 20)
                            Text(step)
                                .font(.subheadline)
                        }
                    }
                }
                .padding()
                .background(.regularMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }

            if let hint = section.hint {
                HStack(spacing: 8) {
                    Image(systemName: "lightbulb.fill")
                        .foregroundStyle(.yellow)
                    Text(hint)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding()
                .background(.yellow.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
        .padding(.vertical, 4)
    }

    @ViewBuilder
    private var sectionIcon: some View {
        switch section.type {
        case .introduction:
            Image(systemName: "star.fill")
                .foregroundStyle(.yellow)
        case .explanation:
            Image(systemName: "book.fill")
                .foregroundStyle(.blue)
        case .example:
            Image(systemName: "pencil.and.outline")
                .foregroundStyle(.purple)
        case .keyConcept:
            Image(systemName: "key.fill")
                .foregroundStyle(.orange)
        case .practicePrompt:
            Image(systemName: "pencil.circle.fill")
                .foregroundStyle(.green)
        case .summary:
            Image(systemName: "list.bullet.clipboard.fill")
                .foregroundStyle(.teal)
        }
    }
}

// MARK: - Worked Example Card

private struct WorkedExampleCard: View {
    let example: WorkedExample
    @State private var isExpanded = false
    @State private var contentHeight: CGFloat = 100

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Button {
                withAnimation(.spring(duration: 0.3)) {
                    isExpanded.toggle()
                }
            } label: {
                HStack {
                    Text(example.title)
                        .font(.subheadline.bold())
                    Spacer()
                    Image(systemName: "chevron.right")
                        .rotationEffect(.degrees(isExpanded ? 90 : 0))
                        .foregroundStyle(.secondary)
                }
            }
            .buttonStyle(.plain)

            if isExpanded {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Problem:")
                        .font(.caption.bold())
                    MathTextView(content: example.problem, dynamicHeight: $contentHeight)
                        .frame(height: contentHeight)

                    Text("Steps:")
                        .font(.caption.bold())
                    ForEach(Array(example.steps.enumerated()), id: \.offset) { index, step in
                        HStack(alignment: .top, spacing: 8) {
                            Text("\(index + 1).")
                                .font(.caption.bold())
                                .foregroundStyle(.blue)
                            Text(step)
                                .font(.caption)
                        }
                    }

                    Divider()

                    Text("Answer:")
                        .font(.caption.bold())
                    Text(example.answer)
                        .font(.subheadline)
                        .foregroundStyle(.green)

                    Text(example.explanation)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
