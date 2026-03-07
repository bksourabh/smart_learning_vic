import SwiftUI
import SwiftData

struct ChildPickerView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.modelContext) private var modelContext

    @State private var showAddChild = false

    private var children: [ChildProfile] {
        appState.currentParent?.children ?? []
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: Spacing.xl) {
                if children.isEmpty {
                    emptyState
                } else {
                    VStack(spacing: Spacing.xs) {
                        Text("Who's learning today?")
                            .font(.title2.bold())
                            .fontDesign(.rounded)
                            .padding(.top, Spacing.xl)

                        VictorianCurriculumBadge(size: .small)
                    }

                    LazyVGrid(columns: [
                        GridItem(.flexible(), spacing: Spacing.md),
                        GridItem(.flexible(), spacing: Spacing.md)
                    ], spacing: Spacing.md) {
                        ForEach(Array(children.enumerated()), id: \.element.name) { index, child in
                            ChildCard(child: child) {
                                Haptics.selection()
                                appState.selectChild(child)
                            }
                            .staggeredEntrance(index: index)
                        }
                    }
                    .padding(.horizontal)

                    Spacer()
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showAddChild = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                    }
                }
                ToolbarItem(placement: .topBarLeading) {
                    Button("Sign Out") {
                        appState.logout()
                    }
                }
            }
            .navigationTitle("Select Child")
            .sheet(isPresented: $showAddChild) {
                AddChildView()
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: Spacing.md) {
            Spacer()
            Image(systemName: "person.badge.plus")
                .font(.system(size: 64))
                .foregroundStyle(.secondary)
                .symbolEffect(.pulse)

            Text("No children added yet")
                .font(.title3)
                .fontDesign(.rounded)

            Text("Add a child profile to get started")
                .font(.subheadline)
                .fontDesign(.rounded)
                .foregroundStyle(.secondary)

            Button {
                showAddChild = true
            } label: {
                Text("Add Child")
                    .font(.headline)
                    .fontDesign(.rounded)
                    .padding(.horizontal, Spacing.xxl)
                    .padding(.vertical, Spacing.sm)
            }
            .buttonStyle(.borderedProminent)
            Spacer()
        }
    }
}

private struct ChildCard: View {
    let child: ChildProfile
    let onTap: () -> Void

    @Environment(\.colorScheme) private var colorScheme

    private var levelColor: Color {
        Color(hex: "#3478F9") // Default blue, could be dynamic per level
    }

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: Spacing.sm) {
                // Emoji with gradient ring
                Text(child.emoji)
                    .font(.system(size: 48))
                    .padding(6)
                    .background(
                        Circle()
                            .strokeBorder(
                                LinearGradient(
                                    colors: [.blue.opacity(0.6), .purple.opacity(0.6)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 3
                            )
                    )

                Text(child.name)
                    .font(.headline)
                    .fontDesign(.rounded)

                // XP chip
                Text("\(child.totalXP) XP")
                    .font(.caption.bold())
                    .fontDesign(.rounded)
                    .foregroundStyle(.blue)
                    .padding(.horizontal, Spacing.xs)
                    .padding(.vertical, Spacing.xxs)
                    .background(.blue.opacity(0.1))
                    .clipShape(Capsule())
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, Spacing.xl)
            .appCard(cornerRadius: CornerRadius.large)
        }
        .buttonStyle(.press)
    }
}
