import SwiftUI
import SwiftData

@main
struct MathAustraliaApp: App {
    let modelContainer: ModelContainer

    @State private var appState = AppState()
    @State private var curriculumService = CurriculumService()

    init() {
        do {
            let schema = Schema([
                ParentAccount.self,
                ChildProfile.self,
                LessonProgressRecord.self,
                PracticeResultRecord.self,
                AchievementRecord.self,
                StreakRecord.self
            ])
            let config = ModelConfiguration(isStoredInMemoryOnly: false)
            modelContainer = try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(appState)
                .environment(curriculumService)
                .modelContainer(modelContainer)
        }
    }
}
