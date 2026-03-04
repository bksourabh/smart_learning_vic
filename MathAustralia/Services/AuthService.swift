import Foundation
import CryptoKit
import SwiftData

@Observable
final class AuthService {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    // MARK: - Registration

    func register(email: String, password: String, displayName: String) throws -> ParentAccount {
        // Check if account already exists
        let normalizedEmail = email.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        let descriptor = FetchDescriptor<ParentAccount>(
            predicate: #Predicate { $0.email == normalizedEmail }
        )

        let existing = try modelContext.fetch(descriptor)
        if !existing.isEmpty {
            throw AuthError.accountAlreadyExists
        }

        // Hash password with salt
        let hashedPassword = hashPassword(password)
        try KeychainHelper.save(password: hashedPassword, for: normalizedEmail)

        // Create account
        let account = ParentAccount(email: normalizedEmail, displayName: displayName)
        modelContext.insert(account)
        try modelContext.save()

        return account
    }

    // MARK: - Login

    func login(email: String, password: String) throws -> ParentAccount {
        let normalizedEmail = email.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)

        // Verify password
        guard let storedHash = try? KeychainHelper.retrieve(for: normalizedEmail) else {
            throw AuthError.invalidCredentials
        }

        let inputHash = hashPassword(password)
        guard storedHash == inputHash else {
            throw AuthError.invalidCredentials
        }

        // Fetch account
        let descriptor = FetchDescriptor<ParentAccount>(
            predicate: #Predicate { $0.email == normalizedEmail }
        )
        guard let account = try modelContext.fetch(descriptor).first else {
            throw AuthError.invalidCredentials
        }

        return account
    }

    // MARK: - Password Hashing

    private func hashPassword(_ password: String) -> String {
        let data = Data(password.utf8)
        let hash = SHA256.hash(data: data)
        return hash.compactMap { String(format: "%02x", $0) }.joined()
    }

    // MARK: - Errors

    enum AuthError: LocalizedError {
        case accountAlreadyExists
        case invalidCredentials

        var errorDescription: String? {
            switch self {
            case .accountAlreadyExists:
                return "An account with this email already exists."
            case .invalidCredentials:
                return "Invalid email or password."
            }
        }
    }
}
