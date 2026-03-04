import SwiftUI
import SwiftData

struct AddChildView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var selectedEmoji = "🧒"
    @State private var selectedLevel = "foundation"

    private let levelOptions = [
        ("foundation", "Foundation"),
        ("level-1", "Level 1"),
        ("level-2", "Level 2"),
        ("level-3", "Level 3"),
        ("level-4", "Level 4"),
        ("level-5", "Level 5"),
        ("level-6", "Level 6"),
        ("level-7", "Level 7"),
        ("level-8", "Level 8"),
        ("level-9", "Level 9"),
        ("level-10", "Level 10"),
    ]

    var body: some View {
        NavigationStack {
            Form {
                Section("Name") {
                    TextField("Child's Name", text: $name)
                }

                Section("Avatar") {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 12) {
                        ForEach(AppConstants.childAvatars, id: \.self) { emoji in
                            Text(emoji)
                                .font(.system(size: 36))
                                .padding(8)
                                .background(
                                    selectedEmoji == emoji
                                        ? Color.blue.opacity(0.2)
                                        : Color.clear
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                .onTapGesture {
                                    selectedEmoji = emoji
                                }
                        }
                    }
                }

                Section("Starting Level") {
                    Picker("Level", selection: $selectedLevel) {
                        ForEach(levelOptions, id: \.0) { slug, name in
                            Text(name).tag(slug)
                        }
                    }
                    .pickerStyle(.menu)
                }
            }
            .navigationTitle("Add Child")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        addChild()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }

    private func addChild() {
        let child = ChildProfile(
            name: name,
            emoji: selectedEmoji,
            currentLevel: selectedLevel
        )
        child.parent = appState.currentParent
        modelContext.insert(child)
        try? modelContext.save()
        dismiss()
    }
}
