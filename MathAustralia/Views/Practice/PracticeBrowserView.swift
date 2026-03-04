import SwiftUI

struct PracticeBrowserView: View {
    @Environment(CurriculumService.self) private var curriculumService
    @Environment(AppState.self) private var appState

    @State private var selectedLevel: String?
    @State private var selectedStrand: StrandSlug?

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Level filter
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        FilterChip(label: "All", isSelected: selectedLevel == nil) {
                            selectedLevel = nil
                        }
                        ForEach(curriculumService.levels) { level in
                            FilterChip(
                                label: level.shortName,
                                isSelected: selectedLevel == level.slug
                            ) {
                                selectedLevel = level.slug
                            }
                        }
                    }
                    .padding(.horizontal)
                }

                // Strand filter
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        FilterChip(label: "All Strands", isSelected: selectedStrand == nil) {
                            selectedStrand = nil
                        }
                        ForEach(StrandSlug.allCases) { strand in
                            FilterChip(
                                label: strand.rawValue.capitalized,
                                isSelected: selectedStrand == strand
                            ) {
                                selectedStrand = strand
                            }
                        }
                    }
                    .padding(.horizontal)
                }

                // Practice test list
                LazyVStack(spacing: 12) {
                    ForEach(filteredTests, id: \.id) { test in
                        NavigationLink {
                            PracticeTestView(practiceTest: test)
                        } label: {
                            PracticeTestCard(test: test, child: appState.activeChild)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .navigationTitle("Practice")
    }

    private var filteredTests: [PracticeTest] {
        var tests = curriculumService.getAllPracticeTests()

        if let level = selectedLevel {
            tests = tests.filter { $0.levelSlug == level }
        }
        if let strand = selectedStrand {
            tests = tests.filter { $0.strandSlug == strand }
        }

        return tests
    }
}

// MARK: - Filter Chip

private struct FilterChip: View {
    let label: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.caption.bold())
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? .blue : .gray.opacity(0.15))
                .foregroundStyle(isSelected ? .white : .primary)
                .clipShape(Capsule())
        }
    }
}

// MARK: - Practice Test Card

private struct PracticeTestCard: View {
    let test: PracticeTest
    let child: ChildProfile?

    private var bestResult: PracticeResultRecord? {
        child?.practiceResults
            .filter { $0.practiceId == test.id }
            .max(by: { $0.percentage < $1.percentage })
    }

    var body: some View {
        HStack(spacing: 12) {
            StrandIconView(strand: test.strandSlug, size: 24)
                .frame(width: 44, height: 44)
                .background(StrandColorSet.background(for: test.strandSlug))
                .clipShape(RoundedRectangle(cornerRadius: 10))

            VStack(alignment: .leading, spacing: 4) {
                Text(test.title)
                    .font(.subheadline.bold())
                    .lineLimit(1)

                HStack(spacing: 8) {
                    Text("\(test.questions.count) questions")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Text("Pass: \(test.passingScore)%")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            if let best = bestResult {
                VStack(spacing: 2) {
                    Text("\(Int(best.percentage))%")
                        .font(.caption.bold())
                        .foregroundStyle(best.passed ? .green : .orange)
                    if best.passed {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.caption)
                            .foregroundStyle(.green)
                    }
                }
            } else {
                Image(systemName: "chevron.right")
                    .foregroundStyle(.tertiary)
            }
        }
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
