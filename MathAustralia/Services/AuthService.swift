import Foundation
import SwiftData
import AuthenticationServices

@Observable
final class AuthService {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    // MARK: - Sign in with Apple

    func signInWithApple(userID: String, fullName: PersonNameComponents?, email: String?) throws -> ParentAccount {
        let descriptor = FetchDescriptor<ParentAccount>(
            predicate: #Predicate { $0.appleUserID == userID }
        )

        if let existing = try modelContext.fetch(descriptor).first {
            // Returning user — update display name if provided
            if let name = fullName?.givenName {
                existing.displayName = name
                try? modelContext.save()
            }
            return existing
        }

        // New user
        let displayName = [fullName?.givenName, fullName?.familyName]
            .compactMap { $0 }
            .joined(separator: " ")

        let account = ParentAccount(
            appleUserID: userID,
            displayName: displayName.isEmpty ? "Parent" : displayName
        )
        modelContext.insert(account)
        try modelContext.save()

        return account
    }

    // MARK: - Auto-login (check existing credential)

    func restoreSession() throws -> ParentAccount? {
        let descriptor = FetchDescriptor<ParentAccount>()
        let accounts = try modelContext.fetch(descriptor)

        guard let account = accounts.first else { return nil }

        // Verify Apple credential is still valid
        let provider = ASAuthorizationAppleIDProvider()
        var isValid = false
        let semaphore = DispatchSemaphore(value: 0)

        provider.getCredentialState(forUserID: account.appleUserID) { state, _ in
            isValid = (state == .authorized)
            semaphore.signal()
        }
        semaphore.wait()

        return isValid ? account : nil
    }

    // MARK: - Errors

    enum AuthError: LocalizedError {
        case appleSignInFailed
        case credentialRevoked

        var errorDescription: String? {
            switch self {
            case .appleSignInFailed:
                return "Sign in with Apple failed. Please try again."
            case .credentialRevoked:
                return "Your Apple ID credential has been revoked. Please sign in again."
            }
        }
    }
}
