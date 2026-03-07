import SwiftUI

struct LessonDetailView: View {
    let lesson: Lesson
    @Environment(AppState.self) private var appState
    @Environment(\.modelContext) private var modelContext

    @State private var showObjectives = false
    @State private var showCompletionCelebration = false

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: Spacing.lg) {
                // Header
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    HStack {
                        DifficultyBadge(difficulty: lesson.difficulty)
                        Text("\(lesson.estimatedMinutes) min")
                            .font(.caption)
                            .fontDesign(.rounded)
                            .foregroundStyle(.secondary)
                    }

                    Text(lesson.description)
                        .font(.subheadline)
                        .fontDesign(.rounded)
                        .foregroundStyle(.secondary)
                }

                // Objectives
                if !lesson.objectives.isEmpty {
                    VStack(alignment: .leading, spacing: Spacing.xs) {
                        HStack(spacing: Spacing.xs) {
                            Image(systemName: "target")
                                .foregroundStyle(.green)
                            Text("Learning Objectives")
                                .font(.subheadline.bold())
                                .fontDesign(.rounded)
                        }

                        ForEach(lesson.objectives, id: \.self) { objective in
                            HStack(alignment: .top, spacing: Spacing.xs) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(.green)
                                    .font(.caption)
                                    .padding(.top, 2)
                                Text(objective)
                                    .font(.caption)
                                    .fontDesign(.rounded)
                            }
                        }
                    }
                    .padding(Spacing.md)
                    .background(.green.opacity(0.06))
                    .clipShape(RoundedRectangle(cornerRadius: CornerRadius.medium))
                }

                // All sections rendered in a single pass for instant loading
                SmartTextView(combinedSectionsContent)

                // Worked Examples
                if !lesson.workedExamples.isEmpty {
                    VStack(alignment: .leading, spacing: Spacing.md) {
                        SectionHeader("Worked Examples", icon: "pencil.and.outline", accentColor: .purple)

                        ForEach(Array(lesson.workedExamples.enumerated()), id: \.offset) { index, example in
                            WorkedExampleCard(example: example, index: index + 1)
                        }
                    }
                }

                // Mark as complete button
                Button {
                    markComplete()
                    showCompletionCelebration = true
                } label: {
                    HStack {
                        Image(systemName: isCompleted ? "checkmark.circle.fill" : "checkmark.circle")
                        Text(isCompleted ? "Completed" : "Mark as Complete")
                    }
                    .font(.headline)
                    .fontDesign(.rounded)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                }
                .buttonStyle(.borderedProminent)
                .tint(isCompleted ? .green : .blue)
                .disabled(isCompleted)
                .padding(.top, Spacing.xs)
            }
            .padding()
        }
        .navigationTitle(lesson.title)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            recordStart()
        }
        .overlay {
            if showCompletionCelebration && isCompleted {
                CelebrationView()
            }
        }
    }

    /// Combine all lesson sections into a single markdown string for one-shot rendering.
    /// This produces exactly ONE WKWebView instead of 2 per section.
    private var combinedSectionsContent: String {
        lesson.sections.map { section in
            var parts: [String] = []
            if let title = section.title {
                parts.append("### \(title)")
            }
            parts.append(section.content)
            if let steps = section.steps, !steps.isEmpty {
                parts.append(steps.enumerated()
                    .map { "\($0 + 1). \($1)" }
                    .joined(separator: "\n"))
            }
            if let hint = section.hint {
                parts.append("💡 *\(hint)*")
            }
            return parts.joined(separator: "\n\n")
        }.joined(separator: "\n\n---\n\n")
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
        Haptics.success()
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

// MARK: - Worked Example Card

private struct WorkedExampleCard: View {
    let example: WorkedExample
    let index: Int
    @State private var isExpanded = false

    private var combinedExampleContent: String {
        var parts: [String] = []
        parts.append("**Problem:**\n\(example.problem)")
        parts.append("**Steps:**\n" + example.steps.enumerated()
            .map { "\($0 + 1). \($1)" }
            .joined(separator: "\n"))
        parts.append("**Answer:** \(example.answer)")
        parts.append(example.explanation)
        return parts.joined(separator: "\n\n")
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Button {
                withAnimation(.spring(duration: 0.3)) {
                    isExpanded.toggle()
                }
                Haptics.selection()
            } label: {
                HStack {
                    // Purple chip
                    Text("Example \(index)")
                        .font(.caption2.bold())
                        .fontDesign(.rounded)
                        .foregroundStyle(.purple)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(.purple.opacity(0.1))
                        .clipShape(Capsule())

                    Text(example.title)
                        .font(.subheadline.bold())
                        .fontDesign(.rounded)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .rotationEffect(.degrees(isExpanded ? 90 : 0))
                        .foregroundStyle(.secondary)
                }
            }
            .buttonStyle(.plain)

            if isExpanded {
                // All example content in ONE SmartTextView for instant rendering
                SmartTextView(combinedExampleContent, font: .caption)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding()
        .appCard()
    }
}
