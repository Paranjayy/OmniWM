import AppKit
import Foundation

enum QuakeTerminalPosition: String, CaseIterable, Codable {
    case top, bottom, left, right, center
    var displayName: String { rawValue.capitalized }
}

enum QuakeTerminalMonitorMode: String, CaseIterable, Codable {
    case active, cursor, fixed
    var displayName: String { rawValue.capitalized }
}

enum QuakeTerminalRestoreTarget: Equatable {
    case managed(WindowToken)
    case external(KeyboardFocusTarget)
}

@MainActor
final class QuakeTerminalController: NSObject {
    var visible: Bool = false
    var window: NSWindow? = nil
    var isTransitioningForTests: Bool = false

    init(
        settings: SettingsStore,
        motionPolicy: WorkspaceMotionPolicy,
        captureRestoreTarget: @escaping () -> QuakeTerminalRestoreTarget?,
        restoreFocusTarget: @escaping (QuakeTerminalRestoreTarget) -> Void
    ) {}

    func setup() {}
    func cleanup() {}
    func toggle() {}
    func reloadOpacityConfig() {}
    func applyGeometryToVisibleWindow() {}
    func configureTransitionStateForTests(isTransitioning: Bool) {}
}

protocol QuakeTerminalTabBarDelegate: AnyObject {}
