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

    func testNewAppleSignIn() throws {
        let context = try makeModelContext()
        let authService = AuthService(modelContext: context)

        let parent = try authService.signInWithApple(
            userID: "apple-user-001",
            fullName: {
                var name = PersonNameComponents()
                name.givenName = "Jane"
                name.familyName = "Smith"
                return name
            }(),
            email: "jane@example.com"
        )
        XCTAssertEqual(parent.appleUserID, "apple-user-001")
        XCTAssertEqual(parent.displayName, "Jane Smith")
    }

    func testReturningAppleSignIn() throws {
        let context = try makeModelContext()
        let authService = AuthService(modelContext: context)

        // First sign in
        _ = try authService.signInWithApple(
            userID: "apple-user-002",
            fullName: {
                var name = PersonNameComponents()
                name.givenName = "Tom"
                name.familyName = "Brown"
                return name
            }(),
            email: "tom@example.com"
        )

        // Returning sign in (Apple only sends name on first sign-in)
        let parent = try authService.signInWithApple(
            userID: "apple-user-002",
            fullName: nil,
            email: nil
        )
        XCTAssertEqual(parent.appleUserID, "apple-user-002")
        XCTAssertEqual(parent.displayName, "Tom Brown")
    }

    func testFallbackDisplayName() throws {
        let context = try makeModelContext()
        let authService = AuthService(modelContext: context)

        let parent = try authService.signInWithApple(
            userID: "apple-user-003",
            fullName: nil,
            email: nil
        )
        XCTAssertEqual(parent.displayName, "Parent")
    }

    func testMultipleParents() throws {
        let context = try makeModelContext()
        let authService = AuthService(modelContext: context)

        let p1 = try authService.signInWithApple(userID: "user-a", fullName: nil, email: nil)
        let p2 = try authService.signInWithApple(userID: "user-b", fullName: nil, email: nil)

        XCTAssertNotEqual(p1.appleUserID, p2.appleUserID)
    }
}
