import Foundation
import SwiftData

@Model
final class ParentAccount {
    @Attribute(.unique) var appleUserID: String
    var displayName: String
    var createdAt: Date
    @Relationship(deleteRule: .cascade, inverse: \ChildProfile.parent)
    var children: [ChildProfile]

    init(appleUserID: String, displayName: String) {
        self.appleUserID = appleUserID
        self.displayName = displayName
        self.createdAt = Date()
        self.children = []
    }
}
