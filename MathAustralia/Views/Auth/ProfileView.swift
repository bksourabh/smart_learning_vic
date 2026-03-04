import SwiftUI

struct ProfileView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.modelContext) private var modelContext

    @State private var showParentDashboard = false
    @State private var showChildPicker = false

    var body: some View {
        List {
            if let child = appState.activeChild {
                Section {
                    HStack(spacing: 16) {
                        Text(child.emoji)
                            .font(.system(size: 48))
                        VStack(alignment: .leading) {
                            Text(child.name)
                                .font(.title2.bold())
                            Text("\(child.totalXP) XP")
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.vertical, 8)
                }

                Section("Current Level") {
                    HStack {
                        Image(systemName: "graduationcap.fill")
                            .foregroundStyle(.blue)
                        Text(child.currentLevel.replacingOccurrences(of: "-", with: " ").capitalized)
                    }
                }
            }

            Section("Account") {
                Button {
                    showChildPicker = true
                } label: {
                    Label("Switch Child", systemImage: "person.2")
                }

                Button {
                    showParentDashboard = true
                } label: {
                    Label("Parent Dashboard", systemImage: "shield.fill")
                }

                Button(role: .destructive) {
                    appState.logout()
                } label: {
                    Label("Log Out", systemImage: "rectangle.portrait.and.arrow.right")
                }
            }

            Section("About") {
                HStack {
                    Text("Version")
                    Spacer()
                    Text("1.0.0")
                        .foregroundStyle(.secondary)
                }
                HStack {
                    Text("Curriculum")
                    Spacer()
                    Text("Victorian Curriculum V2")
                        .foregroundStyle(.secondary)
                }
            }
        }
        .navigationTitle("Profile")
        .sheet(isPresented: $showParentDashboard) {
            NavigationStack {
                ParentDashboardView()
            }
        }
        .sheet(isPresented: $showChildPicker) {
            NavigationStack {
                ChildPickerSheet()
            }
        }
    }
}

private struct ChildPickerSheet: View {
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss

    private var children: [ChildProfile] {
        appState.currentParent?.children ?? []
    }

    var body: some View {
        List {
            ForEach(children, id: \.name) { child in
                Button {
                    appState.selectChild(child)
                    dismiss()
                } label: {
                    HStack(spacing: 12) {
                        Text(child.emoji)
                            .font(.title)
                        VStack(alignment: .leading) {
                            Text(child.name)
                                .font(.headline)
                            Text("\(child.totalXP) XP")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        if child.name == appState.activeChild?.name {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(.blue)
                        }
                    }
                }
                .buttonStyle(.plain)
            }
        }
        .navigationTitle("Switch Child")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Done") { dismiss() }
            }
        }
    }
}
