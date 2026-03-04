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
            VStack(spacing: 20) {
                // Header
                VStack(spacing: 4) {
                    Text("Parent Dashboard")
                        .font(.title.bold())
                    if let parent = appState.currentParent {
                        Text("Welcome, \(parent.displayName)")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.top)

                // Children overview cards
                ForEach(children, id: \.name) { child in
                    NavigationLink {
                        ChildDetailView(child: child)
                    } label: {
                        ParentChildCard(child: child)
                    }
                    .buttonStyle(.plain)
                }

                if children.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "person.badge.plus")
                            .font(.system(size: 48))
                            .foregroundStyle(.secondary)
                        Text("No children added yet")
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 40)
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
        HStack(spacing: 16) {
            Text(child.emoji)
                .font(.system(size: 40))

            VStack(alignment: .leading, spacing: 4) {
                Text(child.name)
                    .font(.headline)

                HStack(spacing: 16) {
                    Label("\(child.lessonProgress.filter { $0.completed }.count) lessons", systemImage: "book.fill")
                    Label("\(child.practiceResults.count) tests", systemImage: "checkmark.circle.fill")
                }
                .font(.caption)
                .foregroundStyle(.secondary)

                HStack(spacing: 16) {
                    Label("\(StreakService(modelContext: modelContext).currentStreak(for: child)) day streak", systemImage: "flame.fill")
                    Label("\(child.totalXP) XP", systemImage: "star.fill")
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundStyle(.tertiary)
        }
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
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
                    HStack(spacing: 12) {
                        Text(child.emoji)
                            .font(.title)
                        VStack(alignment: .leading) {
                            Text(child.name)
                                .font(.headline)
                            Text(child.currentLevel.replacingOccurrences(of: "-", with: " ").capitalized)
                                .font(.caption)
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
