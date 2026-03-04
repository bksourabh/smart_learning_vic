import Foundation
import Security

enum KeychainHelper {
    enum KeychainError: Error {
        case duplicateEntry
        case unknown(OSStatus)
        case notFound
        case encodingFailed
    }

    static func save(password: String, for account: String) throws {
        guard let data = password.data(using: .utf8) else {
            throw KeychainError.encodingFailed
        }

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: "com.mathaustralia.auth",
            kSecAttrAccount as String: account,
            kSecValueData as String: data
        ]

        // Delete existing entry first
        SecItemDelete(query as CFDictionary)

        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw KeychainError.unknown(status)
        }
    }

    static func retrieve(for account: String) throws -> String {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: "com.mathaustralia.auth",
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess, let data = result as? Data,
              let password = String(data: data, encoding: .utf8) else {
            throw KeychainError.notFound
        }

        return password
    }

    static func delete(for account: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: "com.mathaustralia.auth",
            kSecAttrAccount as String: account
        ]
        SecItemDelete(query as CFDictionary)
    }
}
