import SwiftUI

struct ProgressDashboardView: View {
    @Environment(AppState.self) private var appState
    @Environment(CurriculumService.self) private var curriculumService
    @Environment(\.modelContext) private var modelContext

    private var child: ChildProfile? { appState.activeChild }

    var body: some View {
        ScrollView {
            if let child {
                VStack(spacing: 20) {
                    // Stats overview
                    LazyVGrid(columns: [
                        GridItem(.flexible(), spacing: 12),
                        GridItem(.flexible(), spacing: 12)
                    ], spacing: 12) {
                        StatCard(
                            title: "Total XP",
                            value: "\(child.totalXP)",
                            icon: "star.fill",
                            color: .yellow
                        )
                        StatCard(
                            title: "Lessons",
                            value: "\(completedLessons)",
                            icon: "book.fill",
                            color: .blue
                        )
                        StatCard(
                            title: "Tests Passed",
                            value: "\(passedTests)",
                            icon: "checkmark.circle.fill",
                            color: .green
                        )
                        StatCard(
                            title: "Current Streak",
                            value: "\(currentStreak) days",
                            icon: "flame.fill",
                            color: .orange
                        )
                    }
                    .padding(.horizontal)

                    // Streak Calendar
                    VStack(alignment: .leading, spacing: 12) {
                        SectionHeader("Weekly Activity", icon: "calendar")
                        StreakCalendarView(child: child)
                    }
                    .padding(.horizontal)

                    // Achievements
                    VStack(alignment: .leading, spacing: 12) {
                        SectionHeader("Achievements", icon: "trophy.fill")
                        AchievementGridView(child: child)
                    }
                    .padding(.horizontal)

                    // Per-strand progress
                    VStack(alignment: .leading, spacing: 12) {
                        SectionHeader("Strand Progress", icon: "chart.bar.fill")
                        ForEach(StrandSlug.allCases) { strand in
                            StrandProgressRow(
                                strand: strand,
                                completed: strandCompleted(strand),
                                total: strandTotal(strand)
                            )
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
        }
        .navigationTitle("Progress")
    }

    private var completedLessons: Int {
        child?.lessonProgress.filter { $0.completed }.count ?? 0
    }

    private var passedTests: Int {
        child?.practiceResults.filter { $0.passed }.count ?? 0
    }

    private var currentStreak: Int {
        guard let child else { return 0 }
        return StreakService(modelContext: modelContext).currentStreak(for: child)
    }

    private func strandCompleted(_ strand: StrandSlug) -> Int {
        child?.lessonProgress.filter { $0.completed && $0.strandSlug == strand.rawValue }.count ?? 0
    }

    private func strandTotal(_ strand: StrandSlug) -> Int {
        var total = 0
        for level in curriculumService.levels {
            total += curriculumService.getLessons(levelSlug: level.slug, strandSlug: strand.rawValue).count
        }
        return total
    }
}

// MARK: - Strand Progress Row

private struct StrandProgressRow: View {
    let strand: StrandSlug
    let completed: Int
    let total: Int

    var body: some View {
        HStack(spacing: 12) {
            StrandIconView(strand: strand, size: 20)
                .frame(width: 32, height: 32)
                .background(StrandColorSet.background(for: strand))
                .clipShape(RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(strand.rawValue.capitalized)
                        .font(.subheadline.bold())
                    Spacer()
                    Text("\(completed)/\(total)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                ProgressBarView(
                    value: total > 0 ? Double(completed) / Double(total) : 0,
                    color: StrandColorSet.primary(for: strand),
                    height: 6
                )
            }
        }
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
