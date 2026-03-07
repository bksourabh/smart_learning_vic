import SwiftUI

struct ChildDetailView: View {
    let child: ChildProfile
    @Environment(CurriculumService.self) private var curriculumService
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.lg) {
                // Child header
                VStack(spacing: Spacing.xs) {
                    Text(child.emoji)
                        .font(.system(size: 64))
                        .padding(8)
                        .background(
                            Circle()
                                .strokeBorder(
                                    LinearGradient(
                                        colors: [.blue.opacity(0.5), .purple.opacity(0.5)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 3
                                )
                        )
                    Text(child.name)
                        .font(.title2.bold())
                        .fontDesign(.rounded)

                    HStack(spacing: Spacing.xs) {
                        Image(systemName: "star.fill")
                            .foregroundStyle(.yellow)
                        Text("\(child.totalXP) XP")
                            .font(.headline)
                            .fontDesign(.rounded)
                    }
                    .padding(.horizontal, Spacing.md)
                    .padding(.vertical, Spacing.xs)
                    .background(.yellow.opacity(0.1))
                    .clipShape(Capsule())
                }
                .padding(.top)

                // Overall stats
                LazyVGrid(columns: [
                    GridItem(.flexible(), spacing: Spacing.sm),
                    GridItem(.flexible(), spacing: Spacing.sm),
                    GridItem(.flexible(), spacing: Spacing.sm)
                ], spacing: Spacing.sm) {
                    MiniStat(
                        title: "Lessons",
                        value: "\(child.lessonProgress.filter { $0.completed }.count)",
                        icon: "book.fill",
                        color: .blue
                    )
                    MiniStat(
                        title: "Tests",
                        value: "\(child.practiceResults.count)",
                        icon: "checkmark.circle.fill",
                        color: .green
                    )
                    MiniStat(
                        title: "Streak",
                        value: "\(StreakService(modelContext: modelContext).currentStreak(for: child))",
                        icon: "flame.fill",
                        color: .orange
                    )
                }
                .padding(.horizontal)

                // Per-strand breakdown
                VStack(alignment: .leading, spacing: Spacing.sm) {
                    SectionHeader("Strand Breakdown", icon: "chart.bar.fill", accentColor: .purple)
                        .padding(.horizontal)

                    ForEach(StrandSlug.allCases) { strand in
                        StrandBreakdownCard(
                            child: child,
                            strand: strand,
                            curriculumService: curriculumService
                        )
                    }
                    .padding(.horizontal)
                }

                // Recent activity
                VStack(alignment: .leading, spacing: Spacing.sm) {
                    SectionHeader("Recent Practice Results", icon: "clock.fill", accentColor: .blue)
                        .padding(.horizontal)

                    let recent = child.practiceResults
                        .sorted(by: { $0.completedAt > $1.completedAt })
                        .prefix(5)

                    if recent.isEmpty {
                        Text("No practice tests completed yet")
                            .font(.caption)
                            .fontDesign(.rounded)
                            .foregroundStyle(.secondary)
                            .padding(.horizontal)
                    } else {
                        ForEach(Array(recent), id: \.practiceId) { result in
                            HStack {
                                Image(systemName: result.passed ? "checkmark.circle.fill" : "xmark.circle.fill")
                                    .foregroundStyle(result.passed ? .green : .red)

                                VStack(alignment: .leading) {
                                    Text(result.practiceId)
                                        .font(.caption.bold())
                                        .fontDesign(.rounded)
                                    Text("\(Int(result.percentage))%  \u{2022}  \(result.score)/\(result.totalQuestions)")
                                        .font(.caption2)
                                        .fontDesign(.rounded)
                                        .foregroundStyle(.secondary)
                                }

                                Spacer()

                                Text(result.completedAt, style: .relative)
                                    .font(.caption2)
                                    .fontDesign(.rounded)
                                    .foregroundStyle(.secondary)
                            }
                            .padding(.horizontal)
                        }
                    }
                }
            }
            .padding(.bottom)
        }
        .navigationTitle(child.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Mini Stat

private struct MiniStat: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .foregroundStyle(.white)
                .frame(width: 28, height: 28)
                .background(color.gradient)
                .clipShape(Circle())

            Text(value)
                .font(.headline)
                .fontDesign(.rounded)
            Text(title)
                .font(.caption2)
                .fontDesign(.rounded)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Spacing.sm)
        .appCard()
    }
}

// MARK: - Strand Breakdown Card

private struct StrandBreakdownCard: View {
    let child: ChildProfile
    let strand: StrandSlug
    let curriculumService: CurriculumService

    private var totalLessons: Int {
        var count = 0
        for level in curriculumService.levels {
            count += curriculumService.getLessons(levelSlug: level.slug, strandSlug: strand.rawValue).count
        }
        return count
    }

    private var completedLessons: Int {
        child.lessonProgress.filter { $0.completed && $0.strandSlug == strand.rawValue }.count
    }

    private var passedTests: Int {
        child.practiceResults.filter { $0.passed && $0.strandSlug == strand.rawValue }.count
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            HStack(spacing: Spacing.xs) {
                StrandIconView(strand: strand, size: 24, showBackground: true)
                Text(strand.rawValue.capitalized)
                    .font(.subheadline.bold())
                    .fontDesign(.rounded)
                Spacer()
                Text("\(completedLessons)/\(totalLessons) lessons")
                    .font(.caption)
                    .fontDesign(.rounded)
                    .foregroundStyle(.secondary)
            }

            ProgressBarView(
                value: totalLessons > 0 ? Double(completedLessons) / Double(totalLessons) : 0,
                color: StrandColorSet.primary(for: strand),
                height: 6,
                useGradient: true
            )

            HStack {
                Text("\(passedTests) tests passed")
                    .font(.caption2)
                    .fontDesign(.rounded)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .appCard(shadowColor: StrandColorSet.primary(for: strand).opacity(0.08))
    }
}
