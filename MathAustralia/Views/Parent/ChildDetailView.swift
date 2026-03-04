import SwiftUI

struct ChildDetailView: View {
    let child: ChildProfile
    @Environment(CurriculumService.self) private var curriculumService
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Child header
                VStack(spacing: 8) {
                    Text(child.emoji)
                        .font(.system(size: 64))
                    Text(child.name)
                        .font(.title2.bold())
                    Text("\(child.totalXP) XP")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.top)

                // Overall stats
                LazyVGrid(columns: [
                    GridItem(.flexible(), spacing: 12),
                    GridItem(.flexible(), spacing: 12),
                    GridItem(.flexible(), spacing: 12)
                ], spacing: 12) {
                    MiniStat(
                        title: "Lessons",
                        value: "\(child.lessonProgress.filter { $0.completed }.count)",
                        icon: "book.fill"
                    )
                    MiniStat(
                        title: "Tests",
                        value: "\(child.practiceResults.count)",
                        icon: "checkmark.circle.fill"
                    )
                    MiniStat(
                        title: "Streak",
                        value: "\(StreakService(modelContext: modelContext).currentStreak(for: child))",
                        icon: "flame.fill"
                    )
                }
                .padding(.horizontal)

                // Per-strand breakdown
                VStack(alignment: .leading, spacing: 12) {
                    Text("Strand Breakdown")
                        .font(.headline)
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
                VStack(alignment: .leading, spacing: 12) {
                    Text("Recent Practice Results")
                        .font(.headline)
                        .padding(.horizontal)

                    let recent = child.practiceResults
                        .sorted(by: { $0.completedAt > $1.completedAt })
                        .prefix(5)

                    if recent.isEmpty {
                        Text("No practice tests completed yet")
                            .font(.caption)
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
                                    Text("\(Int(result.percentage))% • \(result.score)/\(result.totalQuestions)")
                                        .font(.caption2)
                                        .foregroundStyle(.secondary)
                                }

                                Spacer()

                                Text(result.completedAt, style: .relative)
                                    .font(.caption2)
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

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .foregroundStyle(.blue)
            Text(value)
                .font(.headline)
            Text(title)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 10))
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
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                StrandIconView(strand: strand, size: 18)
                Text(strand.rawValue.capitalized)
                    .font(.subheadline.bold())
                Spacer()
                Text("\(completedLessons)/\(totalLessons) lessons")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            ProgressBarView(
                value: totalLessons > 0 ? Double(completedLessons) / Double(totalLessons) : 0,
                color: StrandColorSet.primary(for: strand),
                height: 6
            )

            HStack {
                Text("\(passedTests) tests passed")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
