import Foundation

/// Manages a stack of "trashed" (hidden) windows that can be restored later.
/// Observable so UI components can react to stack changes.
@MainActor
@Observable
public final class TrashStackManager {
    static let shared = TrashStackManager()

    private(set) var stack: [WindowToken] = []

    /// Current number of windows in the trash stack.
    var count: Int { stack.count }

    private init() {}

    func push(_ token: WindowToken) {
        stack.append(token)
        HapticManager.shared.trigger(.ripple)
    }

    func pop() -> WindowToken? {
        guard !stack.isEmpty else {
            HapticManager.shared.trigger(.error)
            return nil
        }
        HapticManager.shared.trigger(.sharpClick)
        return stack.removeLast()
    }

    var isEmpty: Bool { stack.isEmpty }

    /// Purge tokens that are no longer tracked (e.g. app quit while trashed).
    func pruneInvalidTokens(validating isValid: (WindowToken) -> Bool) {
        stack = stack.filter(isValid)
    }
}
