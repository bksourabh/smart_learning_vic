import SwiftUI

struct PracticeBrowserView: View {
    @Environment(CurriculumService.self) private var curriculumService
    @Environment(AppState.self) private var appState

    @State private var selectedLevel: String?
    @State private var selectedStrand: StrandSlug?
    @State private var allTests: [PracticeTest] = []
    @State private var isLoaded = false

    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.lg) {
                // Level filter
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: Spacing.xs) {
                        FilterChip(label: "All", isSelected: selectedLevel == nil) {
                            withAnimation(.spring(duration: 0.3)) { selectedLevel = nil }
                        }
                        ForEach(curriculumService.levels) { level in
                            FilterChip(
                                label: level.shortName,
                                isSelected: selectedLevel == level.slug
                            ) {
                                withAnimation(.spring(duration: 0.3)) { selectedLevel = level.slug }
                            }
                        }
                    }
                    .padding(.horizontal)
                }

                // Strand filter with icons
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: Spacing.xs) {
                        FilterChip(label: "All Strands", isSelected: selectedStrand == nil) {
                            withAnimation(.spring(duration: 0.3)) { selectedStrand = nil }
                        }
                        ForEach(StrandSlug.allCases) { strand in
                            StrandFilterChip(
                                strand: strand,
                                isSelected: selectedStrand == strand
                            ) {
                                withAnimation(.spring(duration: 0.3)) { selectedStrand = strand }
                            }
                        }
                    }
                    .padding(.horizontal)
                }

                // Practice test list
                LazyVStack(spacing: Spacing.sm) {
                    ForEach(Array(filteredTests.enumerated()), id: \.element.id) { index, test in
                        NavigationLink {
                            PracticeTestView(practiceTest: test)
                        } label: {
                            PracticeTestCard(test: test, child: appState.activeChild)
                        }
                        .buttonStyle(.press)
                        .staggeredEntrance(index: index)
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .navigationTitle("Practice")
        .task {
            if !isLoaded {
                allTests = curriculumService.getAllPracticeTests()
                isLoaded = true
            }
        }
    }

    private var filteredTests: [PracticeTest] {
        var tests = allTests

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
                .fontDesign(.rounded)
                .padding(.horizontal, Spacing.sm)
                .padding(.vertical, 6)
                .background(isSelected ? .blue : .gray.opacity(0.12))
                .foregroundStyle(isSelected ? .white : .primary)
                .clipShape(Capsule())
        }
    }
}

// MARK: - Strand Filter Chip

private struct StrandFilterChip: View {
    let strand: StrandSlug
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Image(systemName: StrandColorSet.icon(for: strand))
                    .font(.caption2)
                Text(strand.rawValue.capitalized)
                    .font(.caption.bold())
                    .fontDesign(.rounded)
            }
            .padding(.horizontal, Spacing.sm)
            .padding(.vertical, 6)
            .background(isSelected ? StrandColorSet.primary(for: strand) : StrandColorSet.primary(for: strand).opacity(0.1))
            .foregroundStyle(isSelected ? .white : StrandColorSet.primary(for: strand))
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

    private var isNew: Bool {
        bestResult == nil
    }

    var body: some View {
        HStack(spacing: Spacing.sm) {
            // Left strand color bar
            RoundedRectangle(cornerRadius: 2)
                .fill(StrandColorSet.gradient(for: test.strandSlug))
                .frame(width: 4)
                .padding(.vertical, -16)

            StrandIconView(strand: test.strandSlug, size: 44, showBackground: true)

            VStack(alignment: .leading, spacing: Spacing.xxs) {
                HStack {
                    Text(test.title)
                        .font(.subheadline.bold())
                        .fontDesign(.rounded)
                        .lineLimit(1)

                    if isNew {
                        Text("NEW")
                            .font(.system(size: 9, weight: .heavy, design: .rounded))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 5)
                            .padding(.vertical, 2)
                            .background(.orange.gradient)
                            .clipShape(Capsule())
                    }
                }

                HStack(spacing: Spacing.xs) {
                    Text("\(test.questions.count) questions")
                        .font(.caption)
                        .fontDesign(.rounded)
                        .foregroundStyle(.secondary)

                    Text("Pass: \(test.passingScore)%")
                        .font(.caption)
                        .fontDesign(.rounded)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            if let best = bestResult {
                VStack(spacing: 2) {
                    Text("\(Int(best.percentage))%")
                        .font(.caption.bold())
                        .fontDesign(.rounded)
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
        .appCard(shadowColor: StrandColorSet.primary(for: test.strandSlug).opacity(0.08))
    }
}
