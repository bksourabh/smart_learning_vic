import SwiftUI

struct ProgressDashboardView: View {
    @Environment(AppState.self) private var appState
    @Environment(CurriculumService.self) private var curriculumService
    @Environment(\.modelContext) private var modelContext

    private var child: ChildProfile? { appState.activeChild }

    var body: some View {
        ScrollView {
            if let child {
                VStack(spacing: Spacing.lg) {
                    // Stats overview
                    LazyVGrid(columns: [
                        GridItem(.flexible(), spacing: Spacing.sm),
                        GridItem(.flexible(), spacing: Spacing.sm)
                    ], spacing: Spacing.sm) {
                        StatCard(
                            title: "Total XP",
                            value: "\(child.totalXP)",
                            icon: "star.fill",
                            color: .yellow
                        )
                        .staggeredEntrance(index: 0)

                        StatCard(
                            title: "Lessons",
                            value: "\(completedLessons)",
                            icon: "book.fill",
                            color: .blue
                        )
                        .staggeredEntrance(index: 1)

                        StatCard(
                            title: "Tests Passed",
                            value: "\(passedTests)",
                            icon: "checkmark.circle.fill",
                            color: .green
                        )
                        .staggeredEntrance(index: 2)

                        StatCard(
                            title: "Current Streak",
                            value: "\(currentStreak) days",
                            icon: "flame.fill",
                            color: .orange
                        )
                        .staggeredEntrance(index: 3)
                    }
                    .padding(.horizontal)

                    // Streak Calendar
                    VStack(alignment: .leading, spacing: Spacing.sm) {
                        SectionHeader("Weekly Activity", icon: "calendar", accentColor: .orange)
                        StreakCalendarView(child: child)
                    }
                    .padding(.horizontal)
                    .staggeredEntrance(index: 4)

                    // Achievements
                    VStack(alignment: .leading, spacing: Spacing.sm) {
                        SectionHeader("Achievements", icon: "trophy.fill", accentColor: .yellow)
                        AchievementGridView(child: child)
                    }
                    .padding(.horizontal)
                    .staggeredEntrance(index: 5)

                    // Per-strand progress
                    VStack(alignment: .leading, spacing: Spacing.sm) {
                        SectionHeader("Strand Progress", icon: "chart.bar.fill", accentColor: .purple)
                        ForEach(Array(StrandSlug.allCases.enumerated()), id: \.element) { index, strand in
                            StrandProgressRow(
                                strand: strand,
                                completed: strandCompleted(strand),
                                total: strandTotal(strand)
                            )
                            .staggeredEntrance(index: index + 6)
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
        HStack(spacing: Spacing.sm) {
            StrandIconView(strand: strand, size: 36, showBackground: true)

            VStack(alignment: .leading, spacing: Spacing.xxs) {
                HStack {
                    Text(strand.rawValue.capitalized)
                        .font(.subheadline.bold())
                        .fontDesign(.rounded)
                    Spacer()
                    Text("\(completed)/\(total)")
                        .font(.caption)
                        .fontDesign(.rounded)
                        .foregroundStyle(.secondary)
                }
                ProgressBarView(
                    value: total > 0 ? Double(completed) / Double(total) : 0,
                    color: StrandColorSet.primary(for: strand),
                    height: 6,
                    useGradient: true
                )
            }
        }
        .padding()
        .appCard(shadowColor: StrandColorSet.primary(for: strand).opacity(0.08))
    }
}
