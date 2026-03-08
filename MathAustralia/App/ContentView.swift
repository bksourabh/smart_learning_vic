import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.modelContext) private var modelContext

    @State private var isRestoringSession = true

    var body: some View {
        Group {
            if isRestoringSession {
                // Brief splash while checking stored credentials
                launchView
            } else if !appState.isAuthenticated {
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
        .animation(.easeInOut(duration: 0.3), value: isRestoringSession)
        .task {
            await restoreSession()
        }
    }

    // MARK: - Session Restoration

    private func restoreSession() async {
        let authService = AuthService(modelContext: modelContext)
        if let parent = await authService.restoreSession() {
            appState.login(parent: parent)
        }
        isRestoringSession = false
    }

    // MARK: - Launch View

    private var launchView: some View {
        VStack(spacing: Spacing.md) {
            Image(systemName: "function")
                .font(.system(size: 44))
                .foregroundStyle(BrandColors.victorianGold)
            Text(AppConstants.siteName)
                .font(.title2.bold())
                .fontDesign(.rounded)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(BrandColors.victorianNavy)
        .foregroundStyle(.white)
    }
}
