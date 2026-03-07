import SwiftUI

struct ParentDashboardView: View {
    @Environment(AppState.self) private var appState
    @Environment(CurriculumService.self) private var curriculumService
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var showManageChildren = false

    private var children: [ChildProfile] {
        appState.currentParent?.children ?? []
    }

    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.lg) {
                // Header with Victorian badge
                VStack(spacing: Spacing.xs) {
                    Text("Parent Dashboard")
                        .font(.title.bold())
                        .fontDesign(.rounded)
                    if let parent = appState.currentParent {
                        Text("Welcome, \(parent.displayName)")
                            .font(.subheadline)
                            .fontDesign(.rounded)
                            .foregroundStyle(.secondary)
                    }
                    VictorianCurriculumBadge(size: .small)
                }
                .padding(.top)

                // Children overview cards
                ForEach(children, id: \.name) { child in
                    NavigationLink {
                        ChildDetailView(child: child)
                    } label: {
                        ParentChildCard(child: child)
                    }
                    .buttonStyle(.press)
                }

                if children.isEmpty {
                    VStack(spacing: Spacing.sm) {
                        Image(systemName: "person.badge.plus")
                            .font(.system(size: 48))
                            .foregroundStyle(.secondary)
                            .symbolEffect(.pulse)
                        Text("No children added yet")
                            .fontDesign(.rounded)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, Spacing.xxxl)
                }
            }
            .padding(.horizontal)
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showManageChildren = true
                } label: {
                    Label("Manage", systemImage: "person.2.fill")
                }
            }
            ToolbarItem(placement: .topBarLeading) {
                Button("Done") { dismiss() }
            }
        }
        .sheet(isPresented: $showManageChildren) {
            ManageChildrenView()
        }
    }
}

// MARK: - Parent Child Card

private struct ParentChildCard: View {
    let child: ChildProfile
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        HStack(spacing: Spacing.md) {
            // Emoji with ring
            Text(child.emoji)
                .font(.system(size: 40))
                .padding(4)
                .background(
                    Circle()
                        .strokeBorder(
                            LinearGradient(
                                colors: [.blue.opacity(0.4), .purple.opacity(0.4)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 2
                        )
                )

            VStack(alignment: .leading, spacing: Spacing.xxs) {
                Text(child.name)
                    .font(.headline)
                    .fontDesign(.rounded)

                HStack(spacing: Spacing.md) {
                    Label("\(child.lessonProgress.filter { $0.completed }.count) lessons", systemImage: "book.fill")
                    Label("\(child.practiceResults.count) tests", systemImage: "checkmark.circle.fill")
                }
                .font(.caption)
                .fontDesign(.rounded)
                .foregroundStyle(.secondary)

                HStack(spacing: Spacing.md) {
                    Label("\(StreakService(modelContext: modelContext).currentStreak(for: child)) day streak", systemImage: "flame.fill")
                    Label("\(child.totalXP) XP", systemImage: "star.fill")
                }
                .font(.caption)
                .fontDesign(.rounded)
                .foregroundStyle(.secondary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundStyle(.tertiary)
        }
        .padding()
        .appCard()
    }
}

// MARK: - Manage Children View

struct ManageChildrenView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var showAddChild = false

    private var children: [ChildProfile] {
        appState.currentParent?.children ?? []
    }

    var body: some View {
        NavigationStack {
            List {
                ForEach(children, id: \.name) { child in
                    HStack(spacing: Spacing.sm) {
                        Text(child.emoji)
                            .font(.title)
                        VStack(alignment: .leading) {
                            Text(child.name)
                                .font(.headline)
                                .fontDesign(.rounded)
                            Text(child.currentLevel.replacingOccurrences(of: "-", with: " ").capitalized)
                                .font(.caption)
                                .fontDesign(.rounded)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .onDelete { offsets in
                    for offset in offsets {
                        let child = children[offset]
                        modelContext.delete(child)
                    }
                    try? modelContext.save()
                }
            }
            .navigationTitle("Manage Children")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showAddChild = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
                ToolbarItem(placement: .topBarLeading) {
                    Button("Done") { dismiss() }
                }
            }
            .sheet(isPresented: $showAddChild) {
                AddChildView()
            }
        }
    }
}
