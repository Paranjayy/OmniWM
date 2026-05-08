import Foundation
import OmniWMIPC

enum QuakeTerminalPosition: String, CaseIterable, Codable {
    case top, center, bottom
    var displayName: String { rawValue.capitalized }
}

@MainActor @Observable
final class SettingsStore {
    nonisolated private static let defaultExport = SettingsExport.defaults()

    private let persistence: SettingsFilePersistence
    private let runtimeState: RuntimeStateStore
    private let autosaveEnabled: Bool
    private var isApplyingExport = false

    var onIPCEnabledChanged: (@MainActor (Bool) -> Void)?
<<<<<<< HEAD
    var onFocusFollowsMouseChanged: (@MainActor (Bool) -> Void)?
    var onMoveMouseToFocusedWindowChanged: (@MainActor (Bool) -> Void)?

    var activeProfile: OmniProfile {
        didSet {
            defaults.set(activeProfile.rawValue, forKey: Keys.activeProfile)
            ExperimentFlags.shared.activeProfile = activeProfile
        }
    }
=======
    var onExternalSettingsReloaded: (@MainActor () -> Void)?
>>>>>>> origin/main

    var hotkeysEnabled = SettingsStore.defaultExport.hotkeysEnabled {
        didSet { scheduleSave() }
    }

<<<<<<< HEAD
    var focusFollowsMouse: Bool {
        didSet {
            defaults.set(focusFollowsMouse, forKey: Keys.focusFollowsMouse)
            onFocusFollowsMouseChanged?(focusFollowsMouse)
        }
    }

    var moveMouseToFocusedWindow: Bool {
        didSet {
            defaults.set(moveMouseToFocusedWindow, forKey: Keys.moveMouseToFocusedWindow)
            onMoveMouseToFocusedWindowChanged?(moveMouseToFocusedWindow)
        }
=======
    var focusFollowsMouse = SettingsStore.defaultExport.focusFollowsMouse {
        didSet { scheduleSave() }
    }

    var moveMouseToFocusedWindow = SettingsStore.defaultExport.moveMouseToFocusedWindow {
        didSet { scheduleSave() }
>>>>>>> origin/main
    }

    var focusFollowsWindowToMonitor = SettingsStore.defaultExport.focusFollowsWindowToMonitor {
        didSet { scheduleSave() }
    }

    var mouseWarpMonitorOrder = SettingsStore.defaultExport.mouseWarpMonitorOrder {
        didSet { scheduleSave() }
    }

    var mouseWarpAxis = MouseWarpAxis(rawValue: SettingsStore.defaultExport.mouseWarpAxis ?? "") ?? .horizontal {
        didSet { scheduleSave() }
    }

    var niriColumnWidthPresets = SettingsStore.validatedPresets(
        SettingsStore.defaultExport.niriColumnWidthPresets ?? BuiltInSettingsDefaults.niriColumnWidthPresets
    ) {
        didSet { scheduleSave() }
    }

    var niriDefaultColumnWidth = SettingsStore.validatedDefaultColumnWidth(SettingsStore.defaultExport.niriDefaultColumnWidth) {
        didSet {
            let validated = SettingsStore.validatedDefaultColumnWidth(niriDefaultColumnWidth)
            if validated != niriDefaultColumnWidth {
                niriDefaultColumnWidth = validated
                return
            }
            scheduleSave()
        }
    }

    var mouseWarpMargin = SettingsStore.defaultExport.mouseWarpMargin {
        didSet { scheduleSave() }
    }

    var gapSize = SettingsStore.defaultExport.gapSize {
        didSet { scheduleSave() }
    }

    var outerGapLeft = SettingsStore.defaultExport.outerGapLeft {
        didSet { scheduleSave() }
    }

    var outerGapRight = SettingsStore.defaultExport.outerGapRight {
        didSet { scheduleSave() }
    }

    var outerGapTop = SettingsStore.defaultExport.outerGapTop {
        didSet { scheduleSave() }
    }

    var outerGapBottom = SettingsStore.defaultExport.outerGapBottom {
        didSet { scheduleSave() }
    }

    var niriMaxWindowsPerColumn = SettingsStore.defaultExport.niriMaxWindowsPerColumn {
        didSet { scheduleSave() }
    }

    var niriMaxVisibleColumns = SettingsStore.defaultExport.niriMaxVisibleColumns {
        didSet { scheduleSave() }
    }

    var niriInfiniteLoop = SettingsStore.defaultExport.niriInfiniteLoop {
        didSet { scheduleSave() }
    }

    var niriCenterFocusedColumn = CenterFocusedColumn(rawValue: SettingsStore.defaultExport.niriCenterFocusedColumn) ?? .never {
        didSet { scheduleSave() }
    }

    var niriAlwaysCenterSingleColumn = SettingsStore.defaultExport.niriAlwaysCenterSingleColumn {
        didSet { scheduleSave() }
    }

    var niriSingleWindowAspectRatio = SingleWindowAspectRatio(
        rawValue: SettingsStore.defaultExport.niriSingleWindowAspectRatio
    ) ?? .ratio4x3 {
        didSet { scheduleSave() }
    }

    var workspaceConfigurations = SettingsStore.normalizedWorkspaceConfigurations(SettingsStore.defaultExport.workspaceConfigurations) {
        didSet { scheduleSave() }
    }

    var defaultLayoutType = LayoutType(rawValue: SettingsStore.defaultExport.defaultLayoutType) ?? .niri {
        didSet { scheduleSave() }
    }

    var bordersEnabled = SettingsStore.defaultExport.bordersEnabled {
        didSet { scheduleSave() }
    }

    var borderWidth = SettingsStore.defaultExport.borderWidth {
        didSet { scheduleSave() }
    }

    var borderColorRed = SettingsStore.defaultExport.borderColorRed {
        didSet { scheduleSave() }
    }

    var borderColorGreen = SettingsStore.defaultExport.borderColorGreen {
        didSet { scheduleSave() }
    }

    var borderColorBlue = SettingsStore.defaultExport.borderColorBlue {
        didSet { scheduleSave() }
    }

    var borderColorAlpha = SettingsStore.defaultExport.borderColorAlpha {
        didSet { scheduleSave() }
    }

    var hotkeyBindings = SettingsStore.defaultExport.hotkeyBindings {
        didSet { scheduleSave() }
    }

    var workspaceBarEnabled = SettingsStore.defaultExport.workspaceBarEnabled {
        didSet { scheduleSave() }
    }

    var workspaceBarShowLabels = SettingsStore.defaultExport.workspaceBarShowLabels {
        didSet { scheduleSave() }
    }

    var workspaceBarShowFloatingWindows = SettingsStore.defaultExport.workspaceBarShowFloatingWindows {
        didSet { scheduleSave() }
    }

    var workspaceBarWindowLevel = WorkspaceBarWindowLevel(rawValue: SettingsStore.defaultExport.workspaceBarWindowLevel) ?? .popup {
        didSet { scheduleSave() }
    }

    var workspaceBarPosition = WorkspaceBarPosition(rawValue: SettingsStore.defaultExport.workspaceBarPosition)
        ?? .overlappingMenuBar {
        didSet { scheduleSave() }
    }

    var workspaceBarNotchAware = SettingsStore.defaultExport.workspaceBarNotchAware {
        didSet { scheduleSave() }
    }

    var workspaceBarDeduplicateAppIcons = SettingsStore.defaultExport.workspaceBarDeduplicateAppIcons {
        didSet { scheduleSave() }
    }

    var workspaceBarHideEmptyWorkspaces = SettingsStore.defaultExport.workspaceBarHideEmptyWorkspaces {
        didSet { scheduleSave() }
    }

    var workspaceBarReserveLayoutSpace = SettingsStore.defaultExport.workspaceBarReserveLayoutSpace {
        didSet { scheduleSave() }
    }

    var workspaceBarHeight = SettingsStore.defaultExport.workspaceBarHeight {
        didSet { scheduleSave() }
    }

    var workspaceBarBackgroundOpacity = SettingsStore.defaultExport.workspaceBarBackgroundOpacity {
        didSet { scheduleSave() }
    }

    var workspaceBarXOffset = SettingsStore.defaultExport.workspaceBarXOffset {
        didSet { scheduleSave() }
    }

    var workspaceBarYOffset = SettingsStore.defaultExport.workspaceBarYOffset {
        didSet { scheduleSave() }
    }

    var workspaceBarAccentColorRed = SettingsStore.defaultExport.workspaceBarAccentColorRed {
        didSet { scheduleSave() }
    }

    var workspaceBarAccentColorGreen = SettingsStore.defaultExport.workspaceBarAccentColorGreen {
        didSet { scheduleSave() }
    }

    var workspaceBarAccentColorBlue = SettingsStore.defaultExport.workspaceBarAccentColorBlue {
        didSet { scheduleSave() }
    }

    var workspaceBarAccentColorAlpha = SettingsStore.defaultExport.workspaceBarAccentColorAlpha {
        didSet { scheduleSave() }
    }

    var workspaceBarTextColorRed = SettingsStore.defaultExport.workspaceBarTextColorRed {
        didSet { scheduleSave() }
    }

    var workspaceBarTextColorGreen = SettingsStore.defaultExport.workspaceBarTextColorGreen {
        didSet { scheduleSave() }
    }

    var workspaceBarTextColorBlue = SettingsStore.defaultExport.workspaceBarTextColorBlue {
        didSet { scheduleSave() }
    }

    var workspaceBarTextColorAlpha = SettingsStore.defaultExport.workspaceBarTextColorAlpha {
        didSet { scheduleSave() }
    }

<<<<<<< HEAD
    var dwindleUseGlobalGaps: Bool {
        didSet { defaults.set(dwindleUseGlobalGaps, forKey: Keys.dwindleUseGlobalGaps) }
    }

    var dwindleMoveToRootStable: Bool {
        didSet { defaults.set(dwindleMoveToRootStable, forKey: Keys.dwindleMoveToRootStable) }
    }

    var monitorDwindleSettings: [MonitorDwindleSettings] {
        didSet { MonitorSettingsStore.save(monitorDwindleSettings, to: defaults, key: Keys.monitorDwindleSettings) }
    }

    var workspaceBackJumpEnabled: Bool {
        didSet { defaults.set(workspaceBackJumpEnabled, forKey: Keys.workspaceBackJumpEnabled) }
    }

    var preventSleepEnabled: Bool {
        didSet { defaults.set(preventSleepEnabled, forKey: Keys.preventSleepEnabled) }
    }

    var updateChecksEnabled: Bool {
        didSet { defaults.set(updateChecksEnabled, forKey: Keys.updateChecksEnabled) }
    }

    var ipcEnabled: Bool {
=======
    var workspaceBarLabelFontSize = SettingsStore.normalizedWorkspaceBarLabelFontSize(SettingsStore.defaultExport.workspaceBarLabelFontSize) {
>>>>>>> origin/main
        didSet {
            let normalized = SettingsStore.normalizedWorkspaceBarLabelFontSize(workspaceBarLabelFontSize)
            if normalized != workspaceBarLabelFontSize {
                workspaceBarLabelFontSize = normalized
                return
            }
            scheduleSave()
        }
    }

    var monitorBarSettings = SettingsStore.defaultExport.monitorBarSettings {
        didSet { scheduleSave() }
    }

    var appRules = SettingsStore.defaultExport.appRules {
        didSet { scheduleSave() }
    }

    var monitorOrientationSettings = SettingsStore.defaultExport.monitorOrientationSettings {
        didSet { scheduleSave() }
    }

    var monitorNiriSettings = SettingsStore.defaultExport.monitorNiriSettings {
        didSet { scheduleSave() }
    }

    var dwindleSmartSplit = SettingsStore.defaultExport.dwindleSmartSplit {
        didSet { scheduleSave() }
    }

    var dwindleDefaultSplitRatio = SettingsStore.defaultExport.dwindleDefaultSplitRatio {
        didSet { scheduleSave() }
    }

    var dwindleSplitWidthMultiplier = SettingsStore.defaultExport.dwindleSplitWidthMultiplier {
        didSet { scheduleSave() }
    }

    var dwindleSingleWindowAspectRatio = DwindleSingleWindowAspectRatio(
        rawValue: SettingsStore.defaultExport.dwindleSingleWindowAspectRatio
    ) ?? .ratio4x3 {
        didSet { scheduleSave() }
    }

    var dwindleUseGlobalGaps = SettingsStore.defaultExport.dwindleUseGlobalGaps {
        didSet { scheduleSave() }
    }

    var dwindleMoveToRootStable = SettingsStore.defaultExport.dwindleMoveToRootStable {
        didSet { scheduleSave() }
    }

    var monitorDwindleSettings = SettingsStore.defaultExport.monitorDwindleSettings {
        didSet { scheduleSave() }
    }

    var preventSleepEnabled = SettingsStore.defaultExport.preventSleepEnabled {
        didSet { scheduleSave() }
    }

    var updateChecksEnabled = SettingsStore.defaultExport.updateChecksEnabled {
        didSet { scheduleSave() }
    }

    var ipcEnabled = SettingsStore.defaultExport.ipcEnabled {
        didSet {
            scheduleSave()
            guard oldValue != ipcEnabled else { return }
            onIPCEnabledChanged?(ipcEnabled)
        }
    }

    var scrollGestureEnabled = SettingsStore.defaultExport.scrollGestureEnabled {
        didSet { scheduleSave() }
    }

    var scrollSensitivity = SettingsStore.defaultExport.scrollSensitivity {
        didSet { scheduleSave() }
    }

    var scrollModifierKey = ScrollModifierKey(rawValue: SettingsStore.defaultExport.scrollModifierKey) ?? .optionShift {
        didSet { scheduleSave() }
    }

    var gestureFingerCount = GestureFingerCount(rawValue: SettingsStore.defaultExport.gestureFingerCount) ?? .three {
        didSet { scheduleSave() }
    }

    var gestureInvertDirection = SettingsStore.defaultExport.gestureInvertDirection {
        didSet { scheduleSave() }
    }

    var statusBarShowWorkspaceName = SettingsStore.defaultExport.statusBarShowWorkspaceName {
        didSet { scheduleSave() }
    }

    var statusBarShowAppNames = SettingsStore.defaultExport.statusBarShowAppNames {
        didSet { scheduleSave() }
    }

    var statusBarUseWorkspaceId = SettingsStore.defaultExport.statusBarUseWorkspaceId {
        didSet { scheduleSave() }
    }

    var commandPaletteLastMode = CommandPaletteMode(rawValue: SettingsStore.defaultExport.commandPaletteLastMode) ?? .windows {
        didSet { scheduleSave() }
    }

    var animationsEnabled = SettingsStore.defaultExport.animationsEnabled {
        didSet { scheduleSave() }
    }

    var hiddenBarIsCollapsed = SettingsStore.defaultExport.hiddenBarIsCollapsed {
        didSet { scheduleSave() }
    }

    var quakeTerminalEnabled = SettingsStore.defaultExport.quakeTerminalEnabled {
        didSet { scheduleSave() }
    }

    var quakeTerminalPosition = QuakeTerminalPosition(rawValue: SettingsStore.defaultExport.quakeTerminalPosition) ?? .center {
        didSet { scheduleSave() }
    }

    var quakeTerminalWidthPercent = SettingsStore.defaultExport.quakeTerminalWidthPercent {
        didSet { scheduleSave() }
    }

    var quakeTerminalHeightPercent = SettingsStore.defaultExport.quakeTerminalHeightPercent {
        didSet { scheduleSave() }
    }

    var quakeTerminalAnimationDuration = SettingsStore.defaultExport.quakeTerminalAnimationDuration {
        didSet { scheduleSave() }
    }

    var quakeTerminalAutoHide = SettingsStore.defaultExport.quakeTerminalAutoHide {
        didSet { scheduleSave() }
    }

    var quakeTerminalOpacity = SettingsStore.defaultExport.quakeTerminalOpacity ?? 1.0 {
        didSet { scheduleSave() }
    }

    var quakeTerminalMonitorMode = QuakeTerminalMonitorMode(
        rawValue: SettingsStore.defaultExport.quakeTerminalMonitorMode ?? ""
    ) ?? .focusedWindow {
        didSet { scheduleSave() }
    }

    var quakeTerminalUseCustomFrame = SettingsStore.defaultExport.quakeTerminalUseCustomFrame {
        didSet { scheduleSave() }
    }

    private var quakeTerminalCustomFrameX: Double? {
        didSet { scheduleSave() }
    }

    private var quakeTerminalCustomFrameY: Double? {
        didSet { scheduleSave() }
    }

    private var quakeTerminalCustomFrameWidth: Double? {
        didSet { scheduleSave() }
    }

    private var quakeTerminalCustomFrameHeight: Double? {
        didSet { scheduleSave() }
    }

    var quakeTerminalCustomFrame: NSRect? {
        get {
            guard let x = quakeTerminalCustomFrameX,
                  let y = quakeTerminalCustomFrameY,
                  let width = quakeTerminalCustomFrameWidth,
                  let height = quakeTerminalCustomFrameHeight else {
                return nil
            }
            return NSRect(x: x, y: y, width: width, height: height)
        }
        set {
            if let frame = newValue {
                quakeTerminalCustomFrameX = frame.origin.x
                quakeTerminalCustomFrameY = frame.origin.y
                quakeTerminalCustomFrameWidth = frame.size.width
                quakeTerminalCustomFrameHeight = frame.size.height
            } else {
                quakeTerminalCustomFrameX = nil
                quakeTerminalCustomFrameY = nil
                quakeTerminalCustomFrameWidth = nil
                quakeTerminalCustomFrameHeight = nil
            }
        }
    }

    var appearanceMode = AppearanceMode(rawValue: SettingsStore.defaultExport.appearanceMode) ?? .dark {
        didSet { scheduleSave() }
    }

    var settingsFileURL: URL {
        persistence.fileURL
    }

    init(
        persistence: SettingsFilePersistence = SettingsFilePersistence(),
        runtimeState: RuntimeStateStore = RuntimeStateStore(),
        autosaveEnabled: Bool = true
    ) {
        self.persistence = persistence
        self.runtimeState = runtimeState
        self.autosaveEnabled = autosaveEnabled

        applyExport(
            persistence.load(),
            monitors: Monitor.current()
        )
        persistence.setExternalChangeHandler { [weak self] export in
            self?.handleExternalReload(export)
        }
    }

    func flushNow() {
        if autosaveEnabled {
            persistence.flushNow()
        } else {
            persistence.save(toExport())
        }
    }

    var warpSwitcherEnabled: Bool {
        didSet { defaults.set(warpSwitcherEnabled, forKey: Keys.warpSwitcherEnabled) }
    }

    var windowTrashEnabled: Bool {
        didSet { defaults.set(windowTrashEnabled, forKey: Keys.windowTrashEnabled) }
    }

    var sessionSnapshotEnabled: Bool {
        didSet { defaults.set(sessionSnapshotEnabled, forKey: Keys.sessionSnapshotEnabled) }
    }

    func update(key: String, value: String) -> Bool {
        switch key {
        case "animationsEnabled":
            if let b = Bool(value) { animationsEnabled = b; return true }
        case "workspaceBarEnabled":
            if let b = Bool(value) { workspaceBarEnabled = b; return true }
        case "gapSize":
            if let d = Double(value) { gapSize = d; return true }
        case "borderWidth":
            if let d = Double(value) { borderWidth = d; return true }
        case "bordersEnabled":
            if let b = Bool(value) { bordersEnabled = b; return true }
        case "focusFollowsMouse":
            if let b = Bool(value) { focusFollowsMouse = b; return true }
        case "appearanceMode":
            if let mode = AppearanceMode(rawValue: value) { appearanceMode = mode; return true }
        case "niriDefaultColumnWidth":
            if value == "nil" { niriDefaultColumnWidth = nil; return true }
            if let d = Double(value) { niriDefaultColumnWidth = d; return true }
        case "niriMaxWindowsPerColumn":
            if let i = Int(value) { niriMaxWindowsPerColumn = i; return true }
        case "niriInfiniteLoop":
            if let b = Bool(value) { niriInfiniteLoop = b; return true }
        case "dwindleSmartSplit":
            if let b = Bool(value) { dwindleSmartSplit = b; return true }
        case "quakeTerminalOpacity":
            if let d = Double(value) { quakeTerminalOpacity = d; return true }
        case "warpSwitcherEnabled":
            if let b = Bool(value) { warpSwitcherEnabled = b; return true }
        case "hotkeysEnabled":
            if let b = Bool(value) { hotkeysEnabled = b; return true }
        case "focusFollowsWindowToMonitor":
            if let b = Bool(value) { focusFollowsWindowToMonitor = b; return true }
        case "mouseWarpAxis":
            if let axis = MouseWarpAxis(rawValue: value) { mouseWarpAxis = axis; return true }
        case "niriMaxVisibleColumns":
            if let i = Int(value) { niriMaxVisibleColumns = i; return true }
        case "dwindleDefaultSplitRatio":
            if let d = Double(value) { dwindleDefaultSplitRatio = d; return true }
        case "workspaceBackJumpEnabled":
            if let b = Bool(value) { workspaceBackJumpEnabled = b; return true }
        case "preventSleepEnabled":
            if let b = Bool(value) { preventSleepEnabled = b; return true }
        case "quakeTerminalEnabled":
            if let b = Bool(value) { quakeTerminalEnabled = b; return true }
        case "quakeTerminalAutoHide":
            if let b = Bool(value) { quakeTerminalAutoHide = b; return true }
        case "windowTrashEnabled":
            if let b = Bool(value) { windowTrashEnabled = b; return true }
        case "sessionSnapshotEnabled":
            if let b = Bool(value) { sessionSnapshotEnabled = b; return true }
        case "moveMouseToFocusedWindow":
            if let b = Bool(value) { moveMouseToFocusedWindow = b; return true }
        case "mouseWarpMargin":
            if let i = Int(value) { mouseWarpMargin = i; return true }
        case "outerGapLeft":
            if let d = Double(value) { outerGapLeft = d; return true }
        case "outerGapRight":
            if let d = Double(value) { outerGapRight = d; return true }
        case "outerGapTop":
            if let d = Double(value) { outerGapTop = d; return true }
        case "outerGapBottom":
            if let d = Double(value) { outerGapBottom = d; return true }
        case "niriCenterFocusedColumn":
            if let mode = CenterFocusedColumn(rawValue: value) { niriCenterFocusedColumn = mode; return true }
        case "niriAlwaysCenterSingleColumn":
            if let b = Bool(value) { niriAlwaysCenterSingleColumn = b; return true }
        case "dwindleSplitWidthMultiplier":
            if let d = Double(value) { dwindleSplitWidthMultiplier = d; return true }
        case "workspaceBarShowLabels":
            if let b = Bool(value) { workspaceBarShowLabels = b; return true }
        case "workspaceBarShowFloatingWindows":
            if let b = Bool(value) { workspaceBarShowFloatingWindows = b; return true }
        case "workspaceBarNotchAware":
            if let b = Bool(value) { workspaceBarNotchAware = b; return true }
        case "workspaceBarReserveLayoutSpace":
            if let b = Bool(value) { workspaceBarReserveLayoutSpace = b; return true }
        case "workspaceBarDeduplicateAppIcons":
            if let b = Bool(value) { workspaceBarDeduplicateAppIcons = b; return true }
        case "workspaceBarHideEmptyWorkspaces":
            if let b = Bool(value) { workspaceBarHideEmptyWorkspaces = b; return true }
        case "workspaceBarHeight":
            if let d = Double(value) { workspaceBarHeight = d; return true }
        case "workspaceBarBackgroundOpacity":
            if let d = Double(value) { workspaceBarBackgroundOpacity = d; return true }
        case "workspaceBarXOffset":
            if let d = Double(value) { workspaceBarXOffset = d; return true }
        case "workspaceBarYOffset":
            if let d = Double(value) { workspaceBarYOffset = d; return true }
        case "statusBarShowWorkspaceName":
            if let b = Bool(value) { statusBarShowWorkspaceName = b; return true }
        case "statusBarShowAppNames":
            if let b = Bool(value) { statusBarShowAppNames = b; return true }
        case "statusBarUseWorkspaceId":
            if let b = Bool(value) { statusBarUseWorkspaceId = b; return true }
        case "quakeTerminalPosition":
            if let pos = QuakeTerminalPosition(rawValue: value) { quakeTerminalPosition = pos; return true }
        case "quakeTerminalWidthPercent":
            if let d = Double(value) { quakeTerminalWidthPercent = d; return true }
        case "quakeTerminalHeightPercent":
            if let d = Double(value) { quakeTerminalHeightPercent = d; return true }
        case "quakeTerminalAnimationDuration":
            if let d = Double(value) { quakeTerminalAnimationDuration = d; return true }
        case "scrollGestureEnabled":
            if let b = Bool(value) { scrollGestureEnabled = b; return true }
        case "scrollSensitivity":
            if let d = Double(value) { scrollSensitivity = d; return true }
        case "scrollModifierKey":
            if let key = ScrollModifierKey(rawValue: value) { scrollModifierKey = key; return true }
        case "gestureFingerCount":
            if let count = GestureFingerCount(rawValue: value) { gestureFingerCount = count; return true }
        case "gestureInvertDirection":
            if let b = Bool(value) { gestureInvertDirection = b; return true }
        default:
            return false
        }
        return false
    }

    func loadPersistedWindowRestoreCatalog() -> PersistedWindowRestoreCatalog {
        runtimeState.windowRestoreCatalog ?? .empty
    }

    func savePersistedWindowRestoreCatalog(_ catalog: PersistedWindowRestoreCatalog) {
        runtimeState.windowRestoreCatalog = catalog.entries.isEmpty ? nil : catalog
    }

<<<<<<< HEAD
    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        let baseline = SettingsExport.defaults()

        hotkeysEnabled = defaults.object(forKey: Keys.hotkeysEnabled) as? Bool ?? baseline.hotkeysEnabled
        focusFollowsMouse = defaults.object(forKey: Keys.focusFollowsMouse) as? Bool ?? baseline.focusFollowsMouse
        moveMouseToFocusedWindow = defaults.object(forKey: Keys.moveMouseToFocusedWindow) as? Bool ??
            baseline.moveMouseToFocusedWindow
        focusFollowsWindowToMonitor = defaults.object(forKey: Keys.focusFollowsWindowToMonitor) as? Bool ??
            baseline.focusFollowsWindowToMonitor
        mouseWarpMonitorOrder = Self.loadMouseWarpMonitorOrder(from: defaults)
        mouseWarpAxis = MouseWarpAxis(rawValue: defaults.string(forKey: Keys.mouseWarpAxis) ?? "") ??
            MouseWarpAxis(rawValue: baseline.mouseWarpAxis ?? "") ?? .horizontal
        niriColumnWidthPresets = Self.loadNiriColumnWidthPresets(from: defaults)
        niriDefaultColumnWidth = Self.loadNiriDefaultColumnWidth(from: defaults)
        mouseWarpMargin = defaults.object(forKey: Keys.mouseWarpMargin) as? Int ?? baseline.mouseWarpMargin
        gapSize = defaults.object(forKey: Keys.gapSize) as? Double ?? baseline.gapSize

        outerGapLeft = defaults.object(forKey: Keys.outerGapLeft) as? Double ?? baseline.outerGapLeft
        outerGapRight = defaults.object(forKey: Keys.outerGapRight) as? Double ?? baseline.outerGapRight
        outerGapTop = defaults.object(forKey: Keys.outerGapTop) as? Double ?? baseline.outerGapTop
        outerGapBottom = defaults.object(forKey: Keys.outerGapBottom) as? Double ?? baseline.outerGapBottom

        niriMaxWindowsPerColumn = defaults.object(forKey: Keys.niriMaxWindowsPerColumn) as? Int ??
            baseline.niriMaxWindowsPerColumn
        niriMaxVisibleColumns = defaults.object(forKey: Keys.niriMaxVisibleColumns) as? Int ??
            baseline.niriMaxVisibleColumns
        niriInfiniteLoop = defaults.object(forKey: Keys.niriInfiniteLoop) as? Bool ?? baseline.niriInfiniteLoop
        niriCenterFocusedColumn = CenterFocusedColumn(rawValue: defaults
            .string(forKey: Keys.niriCenterFocusedColumn) ?? "") ??
            CenterFocusedColumn(rawValue: baseline.niriCenterFocusedColumn) ?? .never
        niriAlwaysCenterSingleColumn = defaults.object(forKey: Keys.niriAlwaysCenterSingleColumn) as? Bool ??
            baseline.niriAlwaysCenterSingleColumn
        niriSingleWindowAspectRatio = SingleWindowAspectRatio(rawValue: defaults
            .string(forKey: Keys.niriSingleWindowAspectRatio) ?? "") ??
            SingleWindowAspectRatio(rawValue: baseline.niriSingleWindowAspectRatio) ?? .ratio4x3

        workspaceConfigurations = Self.loadWorkspaceConfigurations(from: defaults)
        defaultLayoutType = LayoutType(rawValue: defaults.string(forKey: Keys.defaultLayoutType) ?? "") ??
            LayoutType(rawValue: baseline.defaultLayoutType) ?? .niri

        bordersEnabled = defaults.object(forKey: Keys.bordersEnabled) as? Bool ?? baseline.bordersEnabled
        borderWidth = defaults.object(forKey: Keys.borderWidth) as? Double ?? baseline.borderWidth
        borderColorRed = defaults.object(forKey: Keys.borderColorRed) as? Double ?? baseline.borderColorRed
        borderColorGreen = defaults.object(forKey: Keys.borderColorGreen) as? Double ?? baseline.borderColorGreen
        borderColorBlue = defaults.object(forKey: Keys.borderColorBlue) as? Double ?? baseline.borderColorBlue
        borderColorAlpha = defaults.object(forKey: Keys.borderColorAlpha) as? Double ?? baseline.borderColorAlpha

        hotkeyBindings = Self.loadBindings(from: defaults)

        workspaceBarEnabled = defaults.object(forKey: Keys.workspaceBarEnabled) as? Bool ?? baseline.workspaceBarEnabled
        workspaceBarShowLabels = defaults.object(forKey: Keys.workspaceBarShowLabels) as? Bool ??
            baseline.workspaceBarShowLabels
        workspaceBarShowFloatingWindows = defaults.object(forKey: Keys.workspaceBarShowFloatingWindows) as? Bool ??
            baseline.workspaceBarShowFloatingWindows
        workspaceBarWindowLevel = WorkspaceBarWindowLevel(
            rawValue: defaults.string(forKey: Keys.workspaceBarWindowLevel) ?? ""
        ) ?? WorkspaceBarWindowLevel(rawValue: baseline.workspaceBarWindowLevel) ?? .popup
        workspaceBarPosition = WorkspaceBarPosition(
            rawValue: defaults.string(forKey: Keys.workspaceBarPosition) ?? ""
        ) ?? WorkspaceBarPosition(rawValue: baseline.workspaceBarPosition) ?? .overlappingMenuBar
        workspaceBarNotchAware = defaults.object(forKey: Keys.workspaceBarNotchAware) as? Bool ??
            baseline.workspaceBarNotchAware
        workspaceBarDeduplicateAppIcons = defaults
            .object(forKey: Keys.workspaceBarDeduplicateAppIcons) as? Bool ?? baseline.workspaceBarDeduplicateAppIcons
        workspaceBarHideEmptyWorkspaces = defaults
            .object(forKey: Keys.workspaceBarHideEmptyWorkspaces) as? Bool ?? baseline.workspaceBarHideEmptyWorkspaces
        workspaceBarReserveLayoutSpace = defaults
            .object(forKey: Keys.workspaceBarReserveLayoutSpace) as? Bool ?? baseline.workspaceBarReserveLayoutSpace
        workspaceBarHeight = defaults.object(forKey: Keys.workspaceBarHeight) as? Double ?? baseline.workspaceBarHeight
        workspaceBarBackgroundOpacity = defaults.object(forKey: Keys.workspaceBarBackgroundOpacity) as? Double ??
            baseline.workspaceBarBackgroundOpacity
        workspaceBarXOffset = defaults.object(forKey: Keys.workspaceBarXOffset) as? Double ?? baseline.workspaceBarXOffset
        workspaceBarYOffset = defaults.object(forKey: Keys.workspaceBarYOffset) as? Double ?? baseline.workspaceBarYOffset
        monitorBarSettings = MonitorSettingsStore.load(from: defaults, key: Keys.monitorBarSettings)
        let loadedAppRules = Self.loadAppRules(from: defaults)
        appRules = loadedAppRules
        if defaults.data(forKey: Keys.appRules) != nil,
           let normalizedRulesData = try? JSONEncoder().encode(loadedAppRules),
           normalizedRulesData != defaults.data(forKey: Keys.appRules)
        {
            defaults.set(normalizedRulesData, forKey: Keys.appRules)
        }
        monitorOrientationSettings = MonitorSettingsStore.load(from: defaults, key: Keys.monitorOrientationSettings)
        monitorNiriSettings = MonitorSettingsStore.load(from: defaults, key: Keys.monitorNiriSettings)

        dwindleSmartSplit = defaults.object(forKey: Keys.dwindleSmartSplit) as? Bool ?? baseline.dwindleSmartSplit
        dwindleDefaultSplitRatio = defaults.object(forKey: Keys.dwindleDefaultSplitRatio) as? Double ??
            baseline.dwindleDefaultSplitRatio
        dwindleSplitWidthMultiplier = defaults.object(forKey: Keys.dwindleSplitWidthMultiplier) as? Double ??
            baseline.dwindleSplitWidthMultiplier
        dwindleSingleWindowAspectRatio = DwindleSingleWindowAspectRatio(
            rawValue: defaults.string(forKey: Keys.dwindleSingleWindowAspectRatio) ?? ""
        ) ?? DwindleSingleWindowAspectRatio(rawValue: baseline.dwindleSingleWindowAspectRatio) ?? .ratio4x3
        dwindleUseGlobalGaps = defaults.object(forKey: Keys.dwindleUseGlobalGaps) as? Bool ??
            baseline.dwindleUseGlobalGaps
        dwindleMoveToRootStable = defaults.object(forKey: Keys.dwindleMoveToRootStable) as? Bool ??
            baseline.dwindleMoveToRootStable
        monitorDwindleSettings = MonitorSettingsStore.load(from: defaults, key: Keys.monitorDwindleSettings)

        workspaceBackJumpEnabled = defaults.object(forKey: Keys.workspaceBackJumpEnabled) as? Bool ??
            baseline.workspaceBackJumpEnabled
        preventSleepEnabled = defaults.object(forKey: Keys.preventSleepEnabled) as? Bool ?? baseline.preventSleepEnabled
        updateChecksEnabled = defaults.object(forKey: Keys.updateChecksEnabled) as? Bool ?? baseline.updateChecksEnabled
        ipcEnabled = defaults.object(forKey: Keys.ipcEnabled) as? Bool ?? baseline.ipcEnabled
        scrollGestureEnabled = defaults.object(forKey: Keys.scrollGestureEnabled) as? Bool ??
            baseline.scrollGestureEnabled
        scrollSensitivity = defaults.object(forKey: Keys.scrollSensitivity) as? Double ?? baseline.scrollSensitivity
        scrollModifierKey = ScrollModifierKey(rawValue: defaults.string(forKey: Keys.scrollModifierKey) ?? "") ??
            ScrollModifierKey(rawValue: baseline.scrollModifierKey) ?? .optionShift
        gestureFingerCount = GestureFingerCount(
            rawValue: defaults.object(forKey: Keys.gestureFingerCount) as? Int ?? baseline.gestureFingerCount
        ) ?? .three
        gestureInvertDirection = defaults.object(forKey: Keys.gestureInvertDirection) as? Bool ??
            baseline.gestureInvertDirection
        statusBarShowWorkspaceName = defaults.object(forKey: Keys.statusBarShowWorkspaceName) as? Bool ?? false
        statusBarShowAppNames = defaults.object(forKey: Keys.statusBarShowAppNames) as? Bool ?? false
        statusBarUseWorkspaceId = defaults.object(forKey: Keys.statusBarUseWorkspaceId) as? Bool ?? false

        commandPaletteLastMode = CommandPaletteMode(
            rawValue: defaults.string(forKey: Keys.commandPaletteLastMode) ?? ""
        ) ?? CommandPaletteMode(rawValue: baseline.commandPaletteLastMode) ?? .windows

        animationsEnabled = defaults.object(forKey: Keys.animationsEnabled) as? Bool ?? baseline.animationsEnabled

        hiddenBarIsCollapsed = defaults.object(forKey: Keys.hiddenBarIsCollapsed) as? Bool ??
            baseline.hiddenBarIsCollapsed

        quakeTerminalEnabled = defaults.object(forKey: Keys.quakeTerminalEnabled) as? Bool ?? baseline.quakeTerminalEnabled
        quakeTerminalPosition = QuakeTerminalPosition(
            rawValue: defaults.string(forKey: Keys.quakeTerminalPosition) ?? ""
        ) ?? QuakeTerminalPosition(rawValue: baseline.quakeTerminalPosition) ?? .center
        quakeTerminalWidthPercent = defaults.object(forKey: Keys.quakeTerminalWidthPercent) as? Double ??
            baseline.quakeTerminalWidthPercent
        quakeTerminalHeightPercent = defaults.object(forKey: Keys.quakeTerminalHeightPercent) as? Double ??
            baseline.quakeTerminalHeightPercent
        quakeTerminalAnimationDuration = defaults.object(forKey: Keys.quakeTerminalAnimationDuration) as? Double ??
            baseline.quakeTerminalAnimationDuration
        quakeTerminalAutoHide = defaults.object(forKey: Keys.quakeTerminalAutoHide) as? Bool ??
            baseline.quakeTerminalAutoHide
        quakeTerminalOpacity = defaults.object(forKey: Keys.quakeTerminalOpacity) as? Double ??
            (baseline.quakeTerminalOpacity ?? 1.0)
        quakeTerminalMonitorMode = QuakeTerminalMonitorMode(
            rawValue: defaults.string(forKey: Keys.quakeTerminalMonitorMode) ?? ""
        ) ?? QuakeTerminalMonitorMode(rawValue: baseline.quakeTerminalMonitorMode ?? "") ?? .focusedWindow
        quakeTerminalUseCustomFrame = defaults.object(forKey: Keys.quakeTerminalUseCustomFrame) as? Bool ??
            baseline.quakeTerminalUseCustomFrame
        quakeTerminalCustomFrameX = defaults.object(forKey: Keys.quakeTerminalCustomFrameX) as? Double
        quakeTerminalCustomFrameY = defaults.object(forKey: Keys.quakeTerminalCustomFrameY) as? Double
        quakeTerminalCustomFrameWidth = defaults.object(forKey: Keys.quakeTerminalCustomFrameWidth) as? Double
        quakeTerminalCustomFrameHeight = defaults.object(forKey: Keys.quakeTerminalCustomFrameHeight) as? Double
        appearanceMode = AppearanceMode(rawValue: defaults.string(forKey: Keys.appearanceMode) ?? "") ??
            AppearanceMode(rawValue: baseline.appearanceMode) ?? .dark

        warpSwitcherEnabled = defaults.object(forKey: Keys.warpSwitcherEnabled) as? Bool ?? true
        windowTrashEnabled = defaults.object(forKey: Keys.windowTrashEnabled) as? Bool ?? true
        sessionSnapshotEnabled = defaults.object(forKey: Keys.sessionSnapshotEnabled) as? Bool ?? true

        activeProfile = OmniProfile(rawValue: defaults.string(forKey: Keys.activeProfile) ?? "") ?? .official
        ExperimentFlags.shared.activeProfile = activeProfile
    }

    private static func loadBindings(from defaults: UserDefaults) -> [HotkeyBinding] {
        guard let data = defaults.data(forKey: Keys.hotkeyBindings),
              let bindings = HotkeyBindingRegistry.decodePersistedBindings(from: data)
        else {
            return HotkeyBindingRegistry.defaults()
        }

        if let cleanedData = try? JSONEncoder().encode(bindings) {
            defaults.set(cleanedData, forKey: Keys.hotkeyBindings)
        }

        return bindings
    }

    private func saveBindings() {
        guard let data = try? JSONEncoder().encode(hotkeyBindings) else { return }
        defaults.set(data, forKey: Keys.hotkeyBindings)
=======
    func resetQuakeTerminalCustomFrame() {
        quakeTerminalUseCustomFrame = false
        quakeTerminalCustomFrame = nil
>>>>>>> origin/main
    }

    func resetHotkeysToDefaults() {
        hotkeyBindings = HotkeyBindingRegistry.defaults()
    }

    func updateBinding(for commandId: String, newBinding: KeyBinding) {
        guard let index = hotkeyBindings.firstIndex(where: { $0.id == commandId }) else { return }
        hotkeyBindings[index] = HotkeyBinding(
            id: hotkeyBindings[index].id,
            command: hotkeyBindings[index].command,
            binding: newBinding
        )
    }

    func clearBinding(for commandId: String) {
        updateBinding(for: commandId, newBinding: .unassigned)
    }

    func resetBindings(for commandId: String) {
        guard let defaultBinding = HotkeyBindingRegistry.defaults().first(where: { $0.id == commandId }),
              let index = hotkeyBindings.firstIndex(where: { $0.id == commandId })
        else { return }
        hotkeyBindings[index] = defaultBinding
    }

    func findConflicts(for binding: KeyBinding, excluding commandId: String) -> [HotkeyBinding] {
        hotkeyBindings.filter { hotkeyBinding in
            hotkeyBinding.id != commandId && hotkeyBinding.binding.conflicts(with: binding)
        }
    }

    func configuredWorkspaceNames() -> [String] {
        workspaceConfigurations.map(\.name)
    }

    func workspaceToMonitorAssignments() -> [String: [MonitorDescription]] {
        var result: [String: [MonitorDescription]] = [:]
        for config in workspaceConfigurations {
            result[config.name] = [config.monitorAssignment.toMonitorDescription()]
        }
        return result
    }

    func rebindMonitorReferences(to monitors: [Monitor]) {
        let reboundWorkspaceConfigurations = workspaceConfigurations.map { config in
            guard case let .specificDisplay(output) = config.monitorAssignment,
                  let rebound = output.rebound(in: monitors)
            else {
                return config
            }

            var updated = config
            updated.monitorAssignment = .specificDisplay(rebound)
            return updated
        }
        if reboundWorkspaceConfigurations != workspaceConfigurations {
            workspaceConfigurations = reboundWorkspaceConfigurations
        }

        rebindMonitorSettings(\.monitorBarSettings, to: monitors)
        rebindMonitorSettings(\.monitorOrientationSettings, to: monitors)
        rebindMonitorSettings(\.monitorNiriSettings, to: monitors)
        rebindMonitorSettings(\.monitorDwindleSettings, to: monitors)
    }

    func layoutType(for workspaceName: String) -> LayoutType {
        if let config = workspaceConfigurations.first(where: { $0.name == workspaceName }) {
            if config.layoutType == .defaultLayout {
                return defaultLayoutType
            }
            return config.layoutType
        }
        return defaultLayoutType
    }

    func displayName(for workspaceName: String) -> String {
        workspaceConfigurations.first(where: { $0.name == workspaceName })?.effectiveDisplayName ?? workspaceName
    }

<<<<<<< HEAD
    private static func loadWorkspaceConfigurations(from defaults: UserDefaults) -> [WorkspaceConfiguration] {
        if let data = defaults.data(forKey: Keys.workspaceConfigurations),
           let configs = try? JSONDecoder().decode([WorkspaceConfiguration].self, from: data)
        {
            return normalizedWorkspaceConfigurations(configs)
        }
        return normalizedWorkspaceConfigurations([])
    }

    private func saveWorkspaceConfigurations() {
        guard let data = try? JSONEncoder().encode(workspaceConfigurations) else { return }
        defaults.set(data, forKey: Keys.workspaceConfigurations)
    }

    func saveSessionSnapshot(_ snapshot: SessionSnapshot) {
        guard let data = try? JSONEncoder().encode(snapshot) else { return }
        defaults.set(data, forKey: Keys.sessionSnapshot)
    }

    func loadSessionSnapshot() -> SessionSnapshot? {
        guard let data = defaults.data(forKey: Keys.sessionSnapshot) else { return nil }
        return try? JSONDecoder().decode(SessionSnapshot.self, from: data)
    }

    func clearSessionSnapshot() {
        defaults.removeObject(forKey: Keys.sessionSnapshot)
    }

=======
>>>>>>> origin/main
    func effectiveMouseWarpMonitorOrder(for monitors: [Monitor], axis: MouseWarpAxis? = nil) -> [String] {
        let sortedNames = (axis ?? mouseWarpAxis).sortedMonitors(monitors).map(\.name)
        guard !sortedNames.isEmpty else { return [] }

        var remainingCounts = sortedNames.reduce(into: [String: Int]()) { counts, name in
            counts[name, default: 0] += 1
        }
        var resolved: [String] = []

        for name in mouseWarpMonitorOrder {
            guard let remaining = remainingCounts[name], remaining > 0 else { continue }
            resolved.append(name)
            remainingCounts[name] = remaining - 1
        }

        for name in sortedNames {
            guard let remaining = remainingCounts[name], remaining > 0 else { continue }
            resolved.append(name)
            remainingCounts[name] = remaining - 1
        }

        return resolved
    }

    @discardableResult
    func persistEffectiveMouseWarpMonitorOrder(for monitors: [Monitor], axis: MouseWarpAxis? = nil) -> [String] {
        let warpAxis = axis ?? mouseWarpAxis
        let sortedNames = warpAxis.sortedMonitors(monitors).map(\.name)
        guard !sortedNames.isEmpty else { return [] }

        var persisted = mouseWarpMonitorOrder
        var persistedCounts = persisted.reduce(into: [String: Int]()) { counts, name in
            counts[name, default: 0] += 1
        }
        let currentCounts = sortedNames.reduce(into: [String: Int]()) { counts, name in
            counts[name, default: 0] += 1
        }

        for name in sortedNames {
            let currentCount = currentCounts[name, default: 0]
            let persistedCount = persistedCounts[name, default: 0]
            guard persistedCount < currentCount else { continue }
            for _ in 0..<(currentCount - persistedCount) {
                persisted.append(name)
            }
            persistedCounts[name] = currentCount
        }

        if mouseWarpMonitorOrder != persisted {
            mouseWarpMonitorOrder = persisted
        }

        return effectiveMouseWarpMonitorOrder(for: monitors, axis: warpAxis)
    }

    func barSettings(for monitor: Monitor) -> MonitorBarSettings? {
        MonitorSettingsStore.get(for: monitor, in: monitorBarSettings)
    }

    func barSettings(for monitorName: String) -> MonitorBarSettings? {
        MonitorSettingsStore.get(for: monitorName, in: monitorBarSettings)
    }

    func updateBarSettings(_ settings: MonitorBarSettings) {
        MonitorSettingsStore.update(settings, in: &monitorBarSettings)
    }

    func removeBarSettings(for monitor: Monitor) {
        MonitorSettingsStore.remove(for: monitor, from: &monitorBarSettings)
    }

    func removeBarSettings(for monitorName: String) {
        MonitorSettingsStore.remove(for: monitorName, from: &monitorBarSettings)
    }

    func resolvedBarSettings(for monitor: Monitor) -> ResolvedBarSettings {
        resolvedBarSettings(override: barSettings(for: monitor))
    }

    func resolvedBarSettings(for monitorName: String) -> ResolvedBarSettings {
        resolvedBarSettings(override: barSettings(for: monitorName))
    }

    func appRule(for bundleId: String) -> AppRule? {
        appRules.first { $0.bundleId == bundleId }
    }

    func orientationSettings(for monitor: Monitor) -> MonitorOrientationSettings? {
        MonitorSettingsStore.get(for: monitor, in: monitorOrientationSettings)
    }

    func orientationSettings(for monitorName: String) -> MonitorOrientationSettings? {
        MonitorSettingsStore.get(for: monitorName, in: monitorOrientationSettings)
    }

    func effectiveOrientation(for monitor: Monitor) -> Monitor.Orientation {
        if let override = orientationSettings(for: monitor),
           let orientation = override.orientation {
            return orientation
        }
        return monitor.autoOrientation
    }

    func updateOrientationSettings(_ settings: MonitorOrientationSettings) {
        MonitorSettingsStore.update(settings, in: &monitorOrientationSettings)
    }

    func removeOrientationSettings(for monitor: Monitor) {
        MonitorSettingsStore.remove(for: monitor, from: &monitorOrientationSettings)
    }

    func removeOrientationSettings(for monitorName: String) {
        MonitorSettingsStore.remove(for: monitorName, from: &monitorOrientationSettings)
    }

    func niriSettings(for monitor: Monitor) -> MonitorNiriSettings? {
        MonitorSettingsStore.get(for: monitor, in: monitorNiriSettings)
    }

    func niriSettings(for monitorName: String) -> MonitorNiriSettings? {
        MonitorSettingsStore.get(for: monitorName, in: monitorNiriSettings)
    }

    func updateNiriSettings(_ settings: MonitorNiriSettings) {
        MonitorSettingsStore.update(settings, in: &monitorNiriSettings)
    }

    func removeNiriSettings(for monitor: Monitor) {
        MonitorSettingsStore.remove(for: monitor, from: &monitorNiriSettings)
    }

    func removeNiriSettings(for monitorName: String) {
        MonitorSettingsStore.remove(for: monitorName, from: &monitorNiriSettings)
    }

    func resolvedNiriSettings(for monitor: Monitor) -> ResolvedNiriSettings {
        resolvedNiriSettings(override: niriSettings(for: monitor))
    }

    func resolvedNiriSettings(for monitorName: String) -> ResolvedNiriSettings {
        resolvedNiriSettings(override: niriSettings(for: monitorName))
    }

    func dwindleSettings(for monitor: Monitor) -> MonitorDwindleSettings? {
        MonitorSettingsStore.get(for: monitor, in: monitorDwindleSettings)
    }

    func dwindleSettings(for monitorName: String) -> MonitorDwindleSettings? {
        MonitorSettingsStore.get(for: monitorName, in: monitorDwindleSettings)
    }

    func updateDwindleSettings(_ settings: MonitorDwindleSettings) {
        MonitorSettingsStore.update(settings, in: &monitorDwindleSettings)
    }

    func removeDwindleSettings(for monitor: Monitor) {
        MonitorSettingsStore.remove(for: monitor, from: &monitorDwindleSettings)
    }

    func removeDwindleSettings(for monitorName: String) {
        MonitorSettingsStore.remove(for: monitorName, from: &monitorDwindleSettings)
    }

    func resolvedDwindleSettings(for monitor: Monitor) -> ResolvedDwindleSettings {
        resolvedDwindleSettings(override: dwindleSettings(for: monitor))
    }

    func resolvedDwindleSettings(for monitorName: String) -> ResolvedDwindleSettings {
        resolvedDwindleSettings(override: dwindleSettings(for: monitorName))
    }

    nonisolated static let defaultColumnWidthPresets: [Double] = BuiltInSettingsDefaults.niriColumnWidthPresets
    nonisolated static let workspaceBarLabelFontSizeRange: ClosedRange<Double> = 10 ... 16

    nonisolated static func validatedPresets(_ presets: [Double]) -> [Double] {
        let result = presets.map { min(1.0, max(0.05, $0)) }
        if result.count < 2 {
            return defaultColumnWidthPresets
        }
        return result
    }

    nonisolated static func validatedDefaultColumnWidth(_ width: Double?) -> Double? {
        guard let width else { return nil }
        return min(1.0, max(0.05, width))
    }

    nonisolated static func normalizedWorkspaceBarLabelFontSize(_ size: Double) -> Double {
        min(workspaceBarLabelFontSizeRange.upperBound, max(workspaceBarLabelFontSizeRange.lowerBound, size))
    }

    func toExport() -> SettingsExport {
        SettingsExport(
            version: SettingsFilePersistence.configVersion,
            hotkeysEnabled: hotkeysEnabled,
            focusFollowsMouse: focusFollowsMouse,
            moveMouseToFocusedWindow: moveMouseToFocusedWindow,
            focusFollowsWindowToMonitor: focusFollowsWindowToMonitor,
            mouseWarpMonitorOrder: mouseWarpMonitorOrder,
            mouseWarpAxis: mouseWarpAxis.rawValue,
            mouseWarpMargin: mouseWarpMargin,
            gapSize: gapSize,
            outerGapLeft: outerGapLeft,
            outerGapRight: outerGapRight,
            outerGapTop: outerGapTop,
            outerGapBottom: outerGapBottom,
            niriMaxWindowsPerColumn: niriMaxWindowsPerColumn,
            niriMaxVisibleColumns: niriMaxVisibleColumns,
            niriInfiniteLoop: niriInfiniteLoop,
            niriCenterFocusedColumn: niriCenterFocusedColumn.rawValue,
            niriAlwaysCenterSingleColumn: niriAlwaysCenterSingleColumn,
            niriSingleWindowAspectRatio: niriSingleWindowAspectRatio.rawValue,
            niriColumnWidthPresets: niriColumnWidthPresets,
            niriDefaultColumnWidth: niriDefaultColumnWidth,
            workspaceConfigurations: workspaceConfigurations,
            defaultLayoutType: defaultLayoutType.rawValue,
            bordersEnabled: bordersEnabled,
            borderWidth: borderWidth,
            borderColorRed: borderColorRed,
            borderColorGreen: borderColorGreen,
            borderColorBlue: borderColorBlue,
            borderColorAlpha: borderColorAlpha,
            hotkeyBindings: hotkeyBindings,
            workspaceBarEnabled: workspaceBarEnabled,
            workspaceBarShowLabels: workspaceBarShowLabels,
            workspaceBarShowFloatingWindows: workspaceBarShowFloatingWindows,
            workspaceBarWindowLevel: workspaceBarWindowLevel.rawValue,
            workspaceBarPosition: workspaceBarPosition.rawValue,
            workspaceBarNotchAware: workspaceBarNotchAware,
            workspaceBarDeduplicateAppIcons: workspaceBarDeduplicateAppIcons,
            workspaceBarHideEmptyWorkspaces: workspaceBarHideEmptyWorkspaces,
            workspaceBarReserveLayoutSpace: workspaceBarReserveLayoutSpace,
            workspaceBarHeight: workspaceBarHeight,
            workspaceBarBackgroundOpacity: workspaceBarBackgroundOpacity,
            workspaceBarXOffset: workspaceBarXOffset,
            workspaceBarYOffset: workspaceBarYOffset,
            workspaceBarAccentColorRed: workspaceBarAccentColorRed,
            workspaceBarAccentColorGreen: workspaceBarAccentColorGreen,
            workspaceBarAccentColorBlue: workspaceBarAccentColorBlue,
            workspaceBarAccentColorAlpha: workspaceBarAccentColorAlpha,
            workspaceBarTextColorRed: workspaceBarTextColorRed,
            workspaceBarTextColorGreen: workspaceBarTextColorGreen,
            workspaceBarTextColorBlue: workspaceBarTextColorBlue,
            workspaceBarTextColorAlpha: workspaceBarTextColorAlpha,
            workspaceBarLabelFontSize: workspaceBarLabelFontSize,
            monitorBarSettings: monitorBarSettings,
            appRules: appRules,
            monitorOrientationSettings: monitorOrientationSettings,
            monitorNiriSettings: monitorNiriSettings,
            dwindleSmartSplit: dwindleSmartSplit,
            dwindleDefaultSplitRatio: dwindleDefaultSplitRatio,
            dwindleSplitWidthMultiplier: dwindleSplitWidthMultiplier,
            dwindleSingleWindowAspectRatio: dwindleSingleWindowAspectRatio.rawValue,
            dwindleUseGlobalGaps: dwindleUseGlobalGaps,
            dwindleMoveToRootStable: dwindleMoveToRootStable,
            monitorDwindleSettings: monitorDwindleSettings,
            preventSleepEnabled: preventSleepEnabled,
            updateChecksEnabled: updateChecksEnabled,
            ipcEnabled: ipcEnabled,
            scrollGestureEnabled: scrollGestureEnabled,
            scrollSensitivity: scrollSensitivity,
            scrollModifierKey: scrollModifierKey.rawValue,
            gestureFingerCount: gestureFingerCount.rawValue,
            gestureInvertDirection: gestureInvertDirection,
            statusBarShowWorkspaceName: statusBarShowWorkspaceName,
            statusBarShowAppNames: statusBarShowAppNames,
            statusBarUseWorkspaceId: statusBarUseWorkspaceId,
            commandPaletteLastMode: commandPaletteLastMode.rawValue,
            animationsEnabled: animationsEnabled,
            hiddenBarIsCollapsed: hiddenBarIsCollapsed,
            quakeTerminalEnabled: quakeTerminalEnabled,
            quakeTerminalPosition: quakeTerminalPosition.rawValue,
            quakeTerminalWidthPercent: quakeTerminalWidthPercent,
            quakeTerminalHeightPercent: quakeTerminalHeightPercent,
            quakeTerminalAnimationDuration: quakeTerminalAnimationDuration,
            quakeTerminalAutoHide: quakeTerminalAutoHide,
            quakeTerminalOpacity: quakeTerminalOpacity,
            quakeTerminalMonitorMode: quakeTerminalMonitorMode.rawValue,
            quakeTerminalUseCustomFrame: quakeTerminalUseCustomFrame,
            quakeTerminalCustomFrame: quakeTerminalCustomFrame.map(QuakeTerminalFrameExport.init(frame:)),
            appearanceMode: appearanceMode.rawValue
        )
    }

    func applyExport(_ export: SettingsExport, monitors: [Monitor]) {
        let baseline = SettingsStore.defaultExport

        isApplyingExport = true
        defer { isApplyingExport = false }

        hotkeysEnabled = export.hotkeysEnabled
        focusFollowsMouse = export.focusFollowsMouse
        moveMouseToFocusedWindow = export.moveMouseToFocusedWindow
        focusFollowsWindowToMonitor = export.focusFollowsWindowToMonitor
        mouseWarpMonitorOrder = export.mouseWarpMonitorOrder
        mouseWarpAxis = MouseWarpAxis(rawValue: export.mouseWarpAxis ?? baseline.mouseWarpAxis ?? "") ?? .horizontal
        mouseWarpMargin = export.mouseWarpMargin
        gapSize = export.gapSize
        outerGapLeft = export.outerGapLeft
        outerGapRight = export.outerGapRight
        outerGapTop = export.outerGapTop
        outerGapBottom = export.outerGapBottom

        niriMaxWindowsPerColumn = export.niriMaxWindowsPerColumn
        niriMaxVisibleColumns = export.niriMaxVisibleColumns
        niriInfiniteLoop = export.niriInfiniteLoop
        niriCenterFocusedColumn = CenterFocusedColumn(rawValue: export.niriCenterFocusedColumn) ?? .never
        niriAlwaysCenterSingleColumn = export.niriAlwaysCenterSingleColumn
        niriSingleWindowAspectRatio = SingleWindowAspectRatio(rawValue: export.niriSingleWindowAspectRatio) ?? .ratio4x3
        niriColumnWidthPresets = SettingsStore.validatedPresets(
            export.niriColumnWidthPresets ?? baseline.niriColumnWidthPresets ?? SettingsStore.defaultColumnWidthPresets
        )
        niriDefaultColumnWidth = SettingsStore.validatedDefaultColumnWidth(export.niriDefaultColumnWidth)

        workspaceConfigurations = Self.normalizedImportedWorkspaceConfigurations(
            export.workspaceConfigurations,
            monitors: monitors
        )
        defaultLayoutType = LayoutType(rawValue: export.defaultLayoutType) ?? .niri

        bordersEnabled = export.bordersEnabled
        borderWidth = export.borderWidth
        borderColorRed = export.borderColorRed
        borderColorGreen = export.borderColorGreen
        borderColorBlue = export.borderColorBlue
        borderColorAlpha = export.borderColorAlpha

        hotkeyBindings = export.hotkeyBindings

        workspaceBarEnabled = export.workspaceBarEnabled
        workspaceBarShowLabels = export.workspaceBarShowLabels
        workspaceBarShowFloatingWindows = export.workspaceBarShowFloatingWindows
        workspaceBarWindowLevel = WorkspaceBarWindowLevel(rawValue: export.workspaceBarWindowLevel) ?? .popup
        workspaceBarPosition = WorkspaceBarPosition(rawValue: export.workspaceBarPosition) ?? .overlappingMenuBar
        workspaceBarNotchAware = export.workspaceBarNotchAware
        workspaceBarDeduplicateAppIcons = export.workspaceBarDeduplicateAppIcons
        workspaceBarHideEmptyWorkspaces = export.workspaceBarHideEmptyWorkspaces
        workspaceBarReserveLayoutSpace = export.workspaceBarReserveLayoutSpace
        workspaceBarHeight = export.workspaceBarHeight
        workspaceBarBackgroundOpacity = export.workspaceBarBackgroundOpacity
        workspaceBarXOffset = export.workspaceBarXOffset
        workspaceBarYOffset = export.workspaceBarYOffset
        workspaceBarAccentColorRed = export.workspaceBarAccentColorRed
        workspaceBarAccentColorGreen = export.workspaceBarAccentColorGreen
        workspaceBarAccentColorBlue = export.workspaceBarAccentColorBlue
        workspaceBarAccentColorAlpha = export.workspaceBarAccentColorAlpha
        workspaceBarTextColorRed = export.workspaceBarTextColorRed
        workspaceBarTextColorGreen = export.workspaceBarTextColorGreen
        workspaceBarTextColorBlue = export.workspaceBarTextColorBlue
        workspaceBarTextColorAlpha = export.workspaceBarTextColorAlpha
        workspaceBarLabelFontSize = SettingsStore.normalizedWorkspaceBarLabelFontSize(export.workspaceBarLabelFontSize)
        monitorBarSettings = Self.reboundMonitorBarSettings(export.monitorBarSettings, monitors: monitors)

        appRules = export.appRules
        monitorOrientationSettings = Self.reboundMonitorOrientationSettings(
            export.monitorOrientationSettings,
            monitors: monitors
        )
        monitorNiriSettings = Self.reboundMonitorNiriSettings(export.monitorNiriSettings, monitors: monitors)

        dwindleSmartSplit = export.dwindleSmartSplit
        dwindleDefaultSplitRatio = export.dwindleDefaultSplitRatio
        dwindleSplitWidthMultiplier = export.dwindleSplitWidthMultiplier
        dwindleSingleWindowAspectRatio = DwindleSingleWindowAspectRatio(
            rawValue: export.dwindleSingleWindowAspectRatio
        ) ?? .ratio4x3
        dwindleUseGlobalGaps = export.dwindleUseGlobalGaps
        dwindleMoveToRootStable = export.dwindleMoveToRootStable
        monitorDwindleSettings = Self.reboundMonitorDwindleSettings(export.monitorDwindleSettings, monitors: monitors)

        preventSleepEnabled = export.preventSleepEnabled
        updateChecksEnabled = export.updateChecksEnabled
        ipcEnabled = export.ipcEnabled
        scrollGestureEnabled = export.scrollGestureEnabled
        scrollSensitivity = export.scrollSensitivity
        scrollModifierKey = ScrollModifierKey(rawValue: export.scrollModifierKey) ?? .optionShift
        gestureFingerCount = GestureFingerCount(rawValue: export.gestureFingerCount) ?? .three
        gestureInvertDirection = export.gestureInvertDirection
        statusBarShowWorkspaceName = export.statusBarShowWorkspaceName
        statusBarShowAppNames = export.statusBarShowAppNames
        statusBarUseWorkspaceId = export.statusBarUseWorkspaceId
        commandPaletteLastMode = CommandPaletteMode(rawValue: export.commandPaletteLastMode) ?? .windows
        animationsEnabled = export.animationsEnabled

        hiddenBarIsCollapsed = export.hiddenBarIsCollapsed

        quakeTerminalEnabled = export.quakeTerminalEnabled
        quakeTerminalPosition = QuakeTerminalPosition(rawValue: export.quakeTerminalPosition) ?? .center
        quakeTerminalWidthPercent = export.quakeTerminalWidthPercent
        quakeTerminalHeightPercent = export.quakeTerminalHeightPercent
        quakeTerminalAnimationDuration = export.quakeTerminalAnimationDuration
        quakeTerminalAutoHide = export.quakeTerminalAutoHide
        quakeTerminalOpacity = export.quakeTerminalOpacity ?? baseline.quakeTerminalOpacity ?? 1.0
        quakeTerminalMonitorMode = QuakeTerminalMonitorMode(
            rawValue: export.quakeTerminalMonitorMode ?? baseline.quakeTerminalMonitorMode ?? ""
        ) ?? .focusedWindow
        quakeTerminalUseCustomFrame = export.quakeTerminalUseCustomFrame
        quakeTerminalCustomFrame = export.quakeTerminalCustomFrame?.frame

        appearanceMode = AppearanceMode(rawValue: export.appearanceMode) ?? .automatic
    }

    private func handleExternalReload(_ export: SettingsExport) {
        applyExport(export, monitors: Monitor.current())
        onExternalSettingsReloaded?()
    }

    private func scheduleSave() {
        guard autosaveEnabled, !isApplyingExport else { return }
        persistence.scheduleSave(toExport())
    }

    private func rebindMonitorSettings<T: MonitorSettingsType>(
        _ keyPath: ReferenceWritableKeyPath<SettingsStore, [T]>,
        to monitors: [Monitor]
    ) {
        let currentSettings = self[keyPath: keyPath]
        let reboundSettings = MonitorSettingsStore.rebound(currentSettings, to: monitors)
        if reboundSettings != currentSettings {
            self[keyPath: keyPath] = reboundSettings
        }
    }

    nonisolated private static func normalizedWorkspaceConfigurations(_ configs: [WorkspaceConfiguration]) -> [WorkspaceConfiguration] {
        var seen: Set<String> = []
        let normalized = configs
            .filter { WorkspaceIDPolicy.normalizeRawID($0.name) != nil }
            .filter { seen.insert($0.name).inserted }
            .sorted { WorkspaceIDPolicy.sortsBefore($0.name, $1.name) }

        if normalized.isEmpty {
            return BuiltInSettingsDefaults.workspaceConfigurations
        }

        return normalized
    }

    private func resolvedBarSettings(override: MonitorBarSettings?) -> ResolvedBarSettings {
        ResolvedBarSettings(
            enabled: override?.enabled ?? workspaceBarEnabled,
            showLabels: override?.showLabels ?? workspaceBarShowLabels,
            showFloatingWindows: override?.showFloatingWindows ?? workspaceBarShowFloatingWindows,
            deduplicateAppIcons: override?.deduplicateAppIcons ?? workspaceBarDeduplicateAppIcons,
            hideEmptyWorkspaces: override?.hideEmptyWorkspaces ?? workspaceBarHideEmptyWorkspaces,
            reserveLayoutSpace: override?.reserveLayoutSpace ?? workspaceBarReserveLayoutSpace,
            notchAware: override?.notchAware ?? workspaceBarNotchAware,
            position: override?.position ?? workspaceBarPosition,
            windowLevel: override?.windowLevel ?? workspaceBarWindowLevel,
            height: override?.height ?? workspaceBarHeight,
            backgroundOpacity: override?.backgroundOpacity ?? workspaceBarBackgroundOpacity,
            xOffset: override?.xOffset ?? workspaceBarXOffset,
            yOffset: override?.yOffset ?? workspaceBarYOffset,
            accentColorRed: workspaceBarAccentColorRed,
            accentColorGreen: workspaceBarAccentColorGreen,
            accentColorBlue: workspaceBarAccentColorBlue,
            accentColorAlpha: workspaceBarAccentColorAlpha,
            textColorRed: workspaceBarTextColorRed,
            textColorGreen: workspaceBarTextColorGreen,
            textColorBlue: workspaceBarTextColorBlue,
            textColorAlpha: workspaceBarTextColorAlpha,
            labelFontSize: workspaceBarLabelFontSize
        )
    }

    private func resolvedNiriSettings(override: MonitorNiriSettings?) -> ResolvedNiriSettings {
        ResolvedNiriSettings(
            maxVisibleColumns: override?.maxVisibleColumns ?? niriMaxVisibleColumns,
            maxWindowsPerColumn: override?.maxWindowsPerColumn ?? niriMaxWindowsPerColumn,
            centerFocusedColumn: override?.centerFocusedColumn ?? niriCenterFocusedColumn,
            alwaysCenterSingleColumn: override?.alwaysCenterSingleColumn ?? niriAlwaysCenterSingleColumn,
            singleWindowAspectRatio: override?.singleWindowAspectRatio ?? niriSingleWindowAspectRatio,
            infiniteLoop: override?.infiniteLoop ?? niriInfiniteLoop
        )
    }

    private func resolvedDwindleSettings(override: MonitorDwindleSettings?) -> ResolvedDwindleSettings {
        let useGlobalGaps = override?.useGlobalGaps ?? dwindleUseGlobalGaps
        return ResolvedDwindleSettings(
            smartSplit: override?.smartSplit ?? dwindleSmartSplit,
            defaultSplitRatio: CGFloat(override?.defaultSplitRatio ?? dwindleDefaultSplitRatio),
            splitWidthMultiplier: CGFloat(override?.splitWidthMultiplier ?? dwindleSplitWidthMultiplier),
            singleWindowAspectRatio: override?.singleWindowAspectRatio ?? dwindleSingleWindowAspectRatio,
            useGlobalGaps: useGlobalGaps,
            innerGap: useGlobalGaps ? CGFloat(gapSize) : CGFloat(override?.innerGap ?? gapSize),
            outerGapTop: useGlobalGaps ? CGFloat(outerGapTop) : CGFloat(override?.outerGapTop ?? outerGapTop),
            outerGapBottom: useGlobalGaps ? CGFloat(outerGapBottom) : CGFloat(override?.outerGapBottom ?? outerGapBottom),
            outerGapLeft: useGlobalGaps ? CGFloat(outerGapLeft) : CGFloat(override?.outerGapLeft ?? outerGapLeft),
            outerGapRight: useGlobalGaps ? CGFloat(outerGapRight) : CGFloat(override?.outerGapRight ?? outerGapRight)
        )
    }

    private static func normalizedImportedWorkspaceConfigurations(
        _ configs: [WorkspaceConfiguration],
        monitors: [Monitor]
    ) -> [WorkspaceConfiguration] {
        var seen: Set<String> = []
        let rebound = configs.map { config in
            guard case let .specificDisplay(output) = config.monitorAssignment,
                  let reboundOutput = output.rebound(in: monitors)
            else {
                return config
            }

            var updated = config
            updated.monitorAssignment = .specificDisplay(reboundOutput)
            return updated
        }

        let normalized = rebound
            .filter { WorkspaceIDPolicy.normalizeRawID($0.name) != nil }
            .filter { seen.insert($0.name).inserted }
            .sorted { WorkspaceIDPolicy.sortsBefore($0.name, $1.name) }

        if normalized.isEmpty {
            return BuiltInSettingsDefaults.workspaceConfigurations
        }

        return normalized
    }

    private static func reboundMonitorBarSettings(
        _ settings: [MonitorBarSettings],
        monitors: [Monitor]
    ) -> [MonitorBarSettings] {
        settings.map { setting in
            var rebound = setting
            rebound.monitorDisplayId = reboundMonitorDisplayId(
                rebound.monitorDisplayId,
                monitorName: rebound.monitorName,
                monitors: monitors
            )
            return rebound
        }
    }

    private static func reboundMonitorOrientationSettings(
        _ settings: [MonitorOrientationSettings],
        monitors: [Monitor]
    ) -> [MonitorOrientationSettings] {
        settings.map { setting in
            var rebound = setting
            rebound.monitorDisplayId = reboundMonitorDisplayId(
                rebound.monitorDisplayId,
                monitorName: rebound.monitorName,
                monitors: monitors
            )
            return rebound
        }
    }

    private static func reboundMonitorNiriSettings(
        _ settings: [MonitorNiriSettings],
        monitors: [Monitor]
    ) -> [MonitorNiriSettings] {
        settings.map { setting in
            var rebound = setting
            rebound.monitorDisplayId = reboundMonitorDisplayId(
                rebound.monitorDisplayId,
                monitorName: rebound.monitorName,
                monitors: monitors
            )
            return rebound
        }
    }

    private static func reboundMonitorDwindleSettings(
        _ settings: [MonitorDwindleSettings],
        monitors: [Monitor]
    ) -> [MonitorDwindleSettings] {
        settings.map { setting in
            var rebound = setting
            rebound.monitorDisplayId = reboundMonitorDisplayId(
                rebound.monitorDisplayId,
                monitorName: rebound.monitorName,
                monitors: monitors
            )
            return rebound
        }
    }

    private static func reboundMonitorDisplayId(
        _ displayId: CGDirectDisplayID?,
        monitorName: String,
        monitors: [Monitor]
    ) -> CGDirectDisplayID? {
        if let displayId,
           monitors.contains(where: { $0.displayId == displayId }) {
            return displayId
        }

        let matches = monitors.filter { $0.name.caseInsensitiveCompare(monitorName) == .orderedSame }
        guard matches.count == 1 else { return nil }
        return matches[0].displayId
    }
}
<<<<<<< HEAD

private enum Keys {
    static let hotkeysEnabled = "settings.hotkeysEnabled"
    static let focusFollowsMouse = "settings.focusFollowsMouse"
    static let moveMouseToFocusedWindow = "settings.moveMouseToFocusedWindow"
    static let focusFollowsWindowToMonitor = "settings.focusFollowsWindowToMonitor"
    static let mouseWarpMonitorOrder = "settings.mouseWarp.monitorOrder"
    static let mouseWarpAxis = "settings.mouseWarp.axis"
    static let niriColumnWidthPresets = "settings.niriColumnWidthPresets"
    static let niriDefaultColumnWidth = "settings.niriDefaultColumnWidth"
    static let mouseWarpMargin = "settings.mouseWarp.margin"
    static let gapSize = "settings.gapSize"

    static let outerGapLeft = "settings.outerGapLeft"
    static let outerGapRight = "settings.outerGapRight"
    static let outerGapTop = "settings.outerGapTop"
    static let outerGapBottom = "settings.outerGapBottom"

    static let niriMaxWindowsPerColumn = "settings.niriMaxWindowsPerColumn"
    static let niriMaxVisibleColumns = "settings.niriMaxVisibleColumns"
    static let niriInfiniteLoop = "settings.niriInfiniteLoop"
    static let niriCenterFocusedColumn = "settings.niriCenterFocusedColumn"
    static let niriAlwaysCenterSingleColumn = "settings.niriAlwaysCenterSingleColumn"
    static let niriSingleWindowAspectRatio = "settings.niriSingleWindowAspectRatio"
    static let monitorNiriSettings = "settings.monitorNiriSettings"

    static let dwindleSmartSplit = "settings.dwindleSmartSplit"
    static let dwindleDefaultSplitRatio = "settings.dwindleDefaultSplitRatio"
    static let dwindleSplitWidthMultiplier = "settings.dwindleSplitWidthMultiplier"
    static let dwindleSingleWindowAspectRatio = "settings.dwindleSingleWindowAspectRatio"
    static let dwindleUseGlobalGaps = "settings.dwindleUseGlobalGaps"
    static let dwindleMoveToRootStable = "settings.dwindleMoveToRootStable"
    static let monitorDwindleSettings = "settings.monitorDwindleSettings"

    static let workspaceConfigurations = "settings.workspaceConfigurations"
    static let defaultLayoutType = "settings.defaultLayoutType"

    static let bordersEnabled = "settings.bordersEnabled"
    static let borderWidth = "settings.borderWidth"
    static let borderColorRed = "settings.borderColorRed"
    static let borderColorGreen = "settings.borderColorGreen"
    static let borderColorBlue = "settings.borderColorBlue"
    static let borderColorAlpha = "settings.borderColorAlpha"

    static let hotkeyBindings = "settings.hotkeyBindings"

    static let workspaceBarEnabled = "settings.workspaceBar.enabled"
    static let workspaceBarShowLabels = "settings.workspaceBar.showLabels"
    static let workspaceBarShowFloatingWindows = "settings.workspaceBar.showFloatingWindows"
    static let workspaceBarWindowLevel = "settings.workspaceBar.windowLevel"
    static let workspaceBarPosition = "settings.workspaceBar.position"
    static let workspaceBarNotchAware = "settings.workspaceBar.notchAware"
    static let workspaceBarDeduplicateAppIcons = "settings.workspaceBar.deduplicateAppIcons"
    static let workspaceBarHideEmptyWorkspaces = "settings.workspaceBar.hideEmptyWorkspaces"
    static let workspaceBarReserveLayoutSpace = "settings.workspaceBar.reserveLayoutSpace"
    static let workspaceBarHeight = "settings.workspaceBar.height"
    static let workspaceBarBackgroundOpacity = "settings.workspaceBar.backgroundOpacity"
    static let workspaceBarXOffset = "settings.workspaceBar.xOffset"
    static let workspaceBarYOffset = "settings.workspaceBar.yOffset"
    static let monitorBarSettings = "settings.workspaceBar.monitorSettings"

    static let appRules = "settings.appRules"
    static let monitorOrientationSettings = "settings.monitorOrientationSettings"
    static let workspaceBackJumpEnabled = "settings.workspace.backJumpEnabled"
    static let preventSleepEnabled = "settings.preventSleepEnabled"
    static let updateChecksEnabled = "settings.updateChecksEnabled"
    static let ipcEnabled = "settings.ipcEnabled"
    static let scrollGestureEnabled = "settings.scrollGestureEnabled"
    static let scrollSensitivity = "settings.scrollSensitivity"
    static let scrollModifierKey = "settings.scrollModifierKey"
    static let gestureFingerCount = "settings.gestureFingerCount"
    static let gestureInvertDirection = "settings.gestureInvertDirection"
    static let statusBarShowWorkspaceName = "settings.statusBarShowWorkspaceName"
    static let statusBarShowAppNames = "settings.statusBarShowAppNames"
    static let statusBarUseWorkspaceId = "settings.statusBarUseWorkspaceId"

    static let commandPaletteLastMode = "settings.commandPalette.lastMode"
    static let animationsEnabled = "settings.animationsEnabled"

    static let hiddenBarIsCollapsed = "settings.hiddenBar.isCollapsed"

    static let quakeTerminalEnabled = "settings.quakeTerminal.enabled"
    static let quakeTerminalPosition = "settings.quakeTerminal.position"
    static let quakeTerminalWidthPercent = "settings.quakeTerminal.widthPercent"
    static let quakeTerminalHeightPercent = "settings.quakeTerminal.heightPercent"
    static let quakeTerminalAnimationDuration = "settings.quakeTerminal.animationDuration"
    static let quakeTerminalAutoHide = "settings.quakeTerminal.autoHide"
    static let quakeTerminalOpacity = "settings.quakeTerminal.opacity"
    static let quakeTerminalMonitorMode = "settings.quakeTerminal.monitorMode"
    static let quakeTerminalUseCustomFrame = "settings.quakeTerminal.useCustomFrame"
    static let quakeTerminalCustomFrameX = "settings.quakeTerminal.customFrameX"
    static let quakeTerminalCustomFrameY = "settings.quakeTerminal.customFrameY"
    static let quakeTerminalCustomFrameWidth = "settings.quakeTerminal.customFrameWidth"
    static let quakeTerminalCustomFrameHeight = "settings.quakeTerminal.customFrameHeight"

    static let appearanceMode = "settings.appearanceMode"
    static let sessionSnapshot = "session.windowSnapshot"
    static let activeProfile = "settings.activeProfile"

    static let warpSwitcherEnabled = "settings.godBuild.warpSwitcherEnabled"
    static let windowTrashEnabled = "settings.godBuild.windowTrashEnabled"
    static let sessionSnapshotEnabled = "settings.godBuild.sessionSnapshotEnabled"
    static let persistedWindowRestoreCatalog = "settings.restoreCatalog"
}
=======
>>>>>>> origin/main
