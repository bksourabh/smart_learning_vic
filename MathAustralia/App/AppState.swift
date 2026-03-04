import Foundation
import SwiftData

@Observable
final class AppState {
    var currentParent: ParentAccount?
    var activeChild: ChildProfile?
    var isAuthenticated: Bool { currentParent != nil }
    var hasActiveChild: Bool { activeChild != nil }

    func login(parent: ParentAccount) {
        currentParent = parent
        // Auto-select first child if only one
        if parent.children.count == 1 {
            activeChild = parent.children.first
        }
    }

    func selectChild(_ child: ChildProfile) {
        activeChild = child
    }

    func switchToParentMode() {
        activeChild = nil
    }

    func logout() {
        currentParent = nil
        activeChild = nil
    }
}
