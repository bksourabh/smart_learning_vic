import XCTest
import SwiftData
@testable import MathAustralia

final class AuthServiceTests: XCTestCase {

    private func makeModelContext() throws -> ModelContext {
        let schema = Schema([
            ParentAccount.self,
            ChildProfile.self,
            LessonProgressRecord.self,
            PracticeResultRecord.self,
            AchievementRecord.self,
            StreakRecord.self
        ])
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: schema, configurations: [config])
        return ModelContext(container)
    }

    func testRegisterAndLogin() throws {
        let context = try makeModelContext()
        let authService = AuthService(modelContext: context)

        // Register
        let parent = try authService.register(
            email: "test@example.com",
            password: "password123",
            displayName: "Test User"
        )
        XCTAssertEqual(parent.email, "test@example.com")
        XCTAssertEqual(parent.displayName, "Test User")

        // Login
        let loggedIn = try authService.login(email: "test@example.com", password: "password123")
        XCTAssertEqual(loggedIn.email, "test@example.com")
    }

    func testDuplicateRegistration() throws {
        let context = try makeModelContext()
        let authService = AuthService(modelContext: context)

        _ = try authService.register(email: "test@example.com", password: "pass1", displayName: "User 1")

        XCTAssertThrowsError(
            try authService.register(email: "test@example.com", password: "pass2", displayName: "User 2")
        )
    }

    func testInvalidLogin() throws {
        let context = try makeModelContext()
        let authService = AuthService(modelContext: context)

        XCTAssertThrowsError(
            try authService.login(email: "nonexistent@example.com", password: "wrong")
        )
    }

    func testEmailNormalization() throws {
        let context = try makeModelContext()
        let authService = AuthService(modelContext: context)

        _ = try authService.register(email: "Test@Example.COM", password: "password", displayName: "User")
        let loggedIn = try authService.login(email: "test@example.com", password: "password")
        XCTAssertEqual(loggedIn.email, "test@example.com")
    }
}
