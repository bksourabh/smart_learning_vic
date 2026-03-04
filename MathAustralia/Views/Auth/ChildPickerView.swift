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
            VStack(spacing: 24) {
                if children.isEmpty {
                    emptyState
                } else {
                    Text("Who's learning today?")
                        .font(.title2.bold())
                        .padding(.top, 24)

                    LazyVGrid(columns: [
                        GridItem(.flexible(), spacing: 16),
                        GridItem(.flexible(), spacing: 16)
                    ], spacing: 16) {
                        ForEach(children, id: \.name) { child in
                            ChildCard(child: child) {
                                appState.selectChild(child)
                            }
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
                    Button("Log Out") {
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
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "person.badge.plus")
                .font(.system(size: 64))
                .foregroundStyle(.secondary)

            Text("No children added yet")
                .font(.title3)

            Text("Add a child profile to get started")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Button {
                showAddChild = true
            } label: {
                Text("Add Child")
                    .font(.headline)
                    .padding(.horizontal, 32)
                    .padding(.vertical, 12)
            }
            .buttonStyle(.borderedProminent)
            Spacer()
        }
    }
}

private struct ChildCard: View {
    let child: ChildProfile
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 12) {
                Text(child.emoji)
                    .font(.system(size: 48))

                Text(child.name)
                    .font(.headline)

                Text("\(child.totalXP) XP")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 24)
            .background(.regularMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(.plain)
    }
}
