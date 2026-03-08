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

    // MARK: - Session Restoration

    /// Restores a previously authenticated session by checking SwiftData for a stored
    /// ParentAccount and verifying the Apple credential is still valid.
    func restoreSession() async -> ParentAccount? {
        guard let account = fetchStoredAccount() else { return nil }

        let isValid = await verifyAppleCredential(userID: account.appleUserID)
        return isValid ? account : nil
    }

    private func fetchStoredAccount() -> ParentAccount? {
        let descriptor = FetchDescriptor<ParentAccount>()
        return try? modelContext.fetch(descriptor).first
    }

    private func verifyAppleCredential(userID: String) async -> Bool {
        await withCheckedContinuation { continuation in
            ASAuthorizationAppleIDProvider().getCredentialState(forUserID: userID) { state, _ in
                continuation.resume(returning: state == .authorized)
            }
        }
    }

    // MARK: - Delete Account

    /// Deletes the parent account and all associated data (children, progress, achievements, streaks).
    /// The cascade delete rule on ParentAccount handles removing all child data.
    func deleteAccount(parent: ParentAccount) throws {
        modelContext.delete(parent)
        try modelContext.save()
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
