import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        Group {
            if !appState.isAuthenticated {
                WelcomeView()
                    .transition(.opacity.combined(with: .move(edge: .leading)))
            } else if !appState.hasActiveChild {
                ChildPickerView()
                    .transition(.opacity.combined(with: .move(edge: .trailing)))
            } else {
                MainTabView()
                    .transition(.opacity.combined(with: .move(edge: .trailing)))
            }
        }
        .animation(.easeInOut(duration: 0.4), value: appState.isAuthenticated)
        .animation(.easeInOut(duration: 0.4), value: appState.hasActiveChild)
    }
}
