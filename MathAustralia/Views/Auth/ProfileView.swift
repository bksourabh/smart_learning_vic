import SwiftUI

struct ProfileView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.modelContext) private var modelContext

    @State private var showParentDashboard = false
    @State private var showChildPicker = false

    var body: some View {
        List {
            if let child = appState.activeChild {
                // Profile header card
                Section {
                    VStack(spacing: Spacing.sm) {
                        // Gradient-ringed emoji with glow
                        Text(child.emoji)
                            .font(.system(size: 56))
                            .padding(8)
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
                            .shadow(color: .blue.opacity(0.2), radius: 12, y: 4)

                        Text(child.name)
                            .font(.title2.bold())
                            .fontDesign(.rounded)

                        // Prominent XP with glow
                        HStack(spacing: Spacing.xs) {
                            Image(systemName: "star.fill")
                                .foregroundStyle(.yellow)
                            Text("\(child.totalXP) XP")
                                .font(.headline)
                                .fontDesign(.rounded)
                                .contentTransition(.numericText())
                        }
                        .padding(.horizontal, Spacing.md)
                        .padding(.vertical, Spacing.xs)
                        .background(.yellow.opacity(0.1))
                        .clipShape(Capsule())
                        .glow(color: .yellow, radius: 6)

                        VictorianCurriculumBadge(size: .small)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, Spacing.sm)
                }

                Section("Current Level") {
                    HStack {
                        Image(systemName: "graduationcap.fill")
                            .foregroundStyle(.blue)
                        Text(child.currentLevel.replacingOccurrences(of: "-", with: " ").capitalized)
                            .fontDesign(.rounded)
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
                    Label("Sign Out", systemImage: "rectangle.portrait.and.arrow.right")
                }
            }

            Section("About") {
                HStack {
                    Text("App")
                        .fontDesign(.rounded)
                    Spacer()
                    Text("Math Australia")
                        .fontDesign(.rounded)
                        .foregroundStyle(.secondary)
                }
                HStack {
                    Text("Version")
                        .fontDesign(.rounded)
                    Spacer()
                    Text("1.0.0")
                        .fontDesign(.rounded)
                        .foregroundStyle(.secondary)
                }
                HStack {
                    Image(systemName: "seal.fill")
                        .foregroundStyle(BrandColors.victorianGold)
                    Text("Curriculum")
                        .fontDesign(.rounded)
                    Spacer()
                    Text("Victorian Curriculum V2")
                        .fontDesign(.rounded)
                        .foregroundStyle(BrandColors.victorianGold)
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
                    HStack(spacing: Spacing.sm) {
                        Text(child.emoji)
                            .font(.title)
                        VStack(alignment: .leading) {
                            Text(child.name)
                                .font(.headline)
                                .fontDesign(.rounded)
                            Text("\(child.totalXP) XP")
                                .font(.caption)
                                .fontDesign(.rounded)
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
