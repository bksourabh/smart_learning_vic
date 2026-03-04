import Foundation
import SwiftData

@Model
final class ParentAccount {
    @Attribute(.unique) var email: String
    var displayName: String
    var createdAt: Date
    @Relationship(deleteRule: .cascade, inverse: \ChildProfile.parent)
    var children: [ChildProfile]

    init(email: String, displayName: String) {
        self.email = email
        self.displayName = displayName
        self.createdAt = Date()
        self.children = []
    }
}
