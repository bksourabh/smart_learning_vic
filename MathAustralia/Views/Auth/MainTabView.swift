import SwiftUI

struct MainTabView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        TabView {
            NavigationStack {
                LevelListView()
            }
            .tabItem {
                Label("Learn", systemImage: "book.fill")
            }

            NavigationStack {
                PracticeBrowserView()
            }
            .tabItem {
                Label("Practice", systemImage: "checkmark.circle.fill")
            }

            NavigationStack {
                ProgressDashboardView()
            }
            .tabItem {
                Label("Progress", systemImage: "chart.bar.fill")
            }

            NavigationStack {
                ProfileView()
            }
            .tabItem {
                Label("Profile", systemImage: "person.fill")
            }
        }
    }
}
