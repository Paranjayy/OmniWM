import Carbon
import OmniWMIPC

struct ActionSpec: Equatable {
    let id: String
    let command: HotkeyCommand
    let title: String
    let keywords: [String]
    let category: HotkeyCategory
    let layoutCompatibility: LayoutCompatibility
    let defaultBinding: KeyBinding
    let ipcCommandName: IPCCommandName?

    var ipcDescriptor: IPCCommandDescriptor? {
        ipcCommandName.flatMap(IPCAutomationManifest.commandDescriptor(for:))
    }

    var searchTerms: [String] {
        ActionCatalog.uniqueTerms(
            [title, id, layoutCompatibility.rawValue]
                + keywords
                + (ipcDescriptor.map { [$0.path] + $0.commandWords } ?? [])
        )
    }
}

enum ActionCatalog {
    private static let digitCodes: [UInt32] = [
        UInt32(kVK_ANSI_1), UInt32(kVK_ANSI_2), UInt32(kVK_ANSI_3),
        UInt32(kVK_ANSI_4), UInt32(kVK_ANSI_5), UInt32(kVK_ANSI_6),
        UInt32(kVK_ANSI_7), UInt32(kVK_ANSI_8), UInt32(kVK_ANSI_9),
    ]

    private static let specs: [ActionSpec] = buildSpecs()
    private static let specsByID = Dictionary(
        uniqueKeysWithValues: specs.map { ($0.id, $0) }
    )

    static func allSpecs() -> [ActionSpec] {
        specs
    }

    static func spec(for id: String) -> ActionSpec? {
        specsByID[id]
    }

    static func spec(for command: HotkeyCommand) -> ActionSpec? {
        specs.first { $0.command == command }
    }

    static func title(for command: HotkeyCommand) -> String? {
        spec(for: command)?.title
    }

    static func layoutCompatibility(for command: HotkeyCommand) -> LayoutCompatibility? {
        spec(for: command)?.layoutCompatibility
    }

    static func category(for id: String) -> HotkeyCategory? {
        spec(for: id)?.category
    }

    static func defaultHotkeyBindings() -> [HotkeyBinding] {
        specs.map { spec in
            HotkeyBinding(
                id: spec.id,
                command: spec.command,
                binding: spec.defaultBinding
            )
        }
    }

    static func matchesSearch(_ query: String, binding: HotkeyBinding) -> Bool {
        let normalizedQuery = normalize(query)
        guard !normalizedQuery.isEmpty else { return true }

        guard let spec = spec(for: binding.id) else {
            return binding.command.displayName.localizedCaseInsensitiveContains(query)
                || binding.command.layoutCompatibility.rawValue.localizedCaseInsensitiveContains(query)
                || binding.binding.displayString.localizedCaseInsensitiveContains(query)
                || binding.binding.humanReadableString.localizedCaseInsensitiveContains(query)
        }

        return spec.searchTerms.contains { normalize($0).contains(normalizedQuery) }
            || normalize(binding.binding.displayString).contains(normalizedQuery)
            || normalize(binding.binding.humanReadableString).contains(normalizedQuery)
    }

    static func uniqueTerms(_ values: [String]) -> [String] {
        var seen: Set<String> = []
        return values.compactMap { raw in
            let normalized = normalize(raw)
            guard !normalized.isEmpty, seen.insert(normalized).inserted else {
                return nil
            }
            return raw
        }
    }

    private static func normalize(_ value: String) -> String {
        value
            .lowercased()
            .replacingOccurrences(of: ".", with: " ")
            .replacingOccurrences(of: "-", with: " ")
            .replacingOccurrences(of: "_", with: " ")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private static func buildSpecs() -> [ActionSpec] {
        var specs: [ActionSpec] = []

        let rcmdLayer = UInt32(cmdKey | controlKey | shiftKey)      // Shift + Ctrl + Cmd
        let roptLayer = UInt32(cmdKey | controlKey | optionKey)     // Ctrl + Opt + Cmd (Meh)
        let hyperLayer = UInt32(cmdKey | controlKey | optionKey | shiftKey) // 4-keys (Hyper)

        for (idx, code) in digitCodes.enumerated() {
            specs.append(
                action(
                    id: "switchWorkspace.\(idx)",
                    command: .switchWorkspace(idx),
                    category: .workspace,
                    binding: KeyBinding(keyCode: code, modifiers: rcmdLayer)
                )
            )
            specs.append(
                action(
                    id: "moveToWorkspace.\(idx)",
                    command: .moveToWorkspace(idx),
                    category: .workspace,
                    binding: KeyBinding(keyCode: code, modifiers: hyperLayer)
                )
            )
        }

        specs.append(
            action(
                id: "workspaceBackAndForth",
                command: .workspaceBackAndForth,
                category: .workspace,
                binding: KeyBinding(keyCode: UInt32(kVK_Tab), modifiers: roptLayer),
                keywords: ["back and forth", "previous workspace"]
            )
        )

        specs.append(contentsOf: [
            action(id: "switchWorkspace.next", command: .switchWorkspaceNext, category: .workspace, binding: .unassigned),
            action(id: "switchWorkspace.previous", command: .switchWorkspacePrevious, category: .workspace, binding: .unassigned),
        ])

        specs.append(contentsOf: [
            action(id: "focus.left", command: .focus(.left), category: .focus, binding: KeyBinding(keyCode: UInt32(kVK_ANSI_A), modifiers: roptLayer)),
            action(id: "focus.down", command: .focus(.down), category: .focus, binding: KeyBinding(keyCode: UInt32(kVK_ANSI_S), modifiers: roptLayer)),
            action(id: "focus.up", command: .focus(.up), category: .focus, binding: KeyBinding(keyCode: UInt32(kVK_ANSI_W), modifiers: roptLayer)),
            action(id: "focus.right", command: .focus(.right), category: .focus, binding: KeyBinding(keyCode: UInt32(kVK_ANSI_D), modifiers: roptLayer)),
        ])

        specs.append(
            action(
                id: "focusPrevious",
                command: .focusPrevious,
                category: .focus,
                binding: KeyBinding(keyCode: UInt32(kVK_Tab), modifiers: hyperLayer),
                keywords: ["last focused", "recent window"]
            )
        )

        specs.append(contentsOf: [
            action(id: "focusDownOrLeft", command: .focusDownOrLeft, category: .focus, binding: .unassigned),
            action(id: "focusUpOrRight", command: .focusUpOrRight, category: .focus, binding: .unassigned),
        ])

        specs.append(contentsOf: [
            action(id: "moveWindowToWorkspaceUp", command: .moveWindowToWorkspaceUp, category: .workspace, binding: KeyBinding(keyCode: UInt32(kVK_ANSI_W), modifiers: hyperLayer)),
            action(id: "moveWindowToWorkspaceDown", command: .moveWindowToWorkspaceDown, category: .workspace, binding: KeyBinding(keyCode: UInt32(kVK_ANSI_S), modifiers: hyperLayer)),
            action(id: "moveColumnToWorkspaceUp", command: .moveColumnToWorkspaceUp, category: .workspace, binding: KeyBinding(keyCode: UInt32(kVK_PageUp), modifiers: hyperLayer)),
            action(id: "moveColumnToWorkspaceDown", command: .moveColumnToWorkspaceDown, category: .workspace, binding: KeyBinding(keyCode: UInt32(kVK_PageDown), modifiers: hyperLayer)),
        ])

        for idx in 0 ..< 9 {
            specs.append(
                action(
                    id: "moveColumnToWorkspace.\(idx)",
                    command: .moveColumnToWorkspace(idx),
                    category: .workspace,
                    binding: .unassigned
                )
            )
        }

        specs.append(contentsOf: [
            action(id: "move.left", command: .move(.left), category: .move, binding: KeyBinding(keyCode: UInt32(kVK_ANSI_A), modifiers: hyperLayer)),
            action(id: "move.down", command: .move(.down), category: .move, binding: KeyBinding(keyCode: UInt32(kVK_ANSI_S), modifiers: hyperLayer)),
            action(id: "move.up", command: .move(.up), category: .move, binding: KeyBinding(keyCode: UInt32(kVK_ANSI_W), modifiers: hyperLayer)),
            action(id: "move.right", command: .move(.right), category: .move, binding: KeyBinding(keyCode: UInt32(kVK_ANSI_D), modifiers: hyperLayer)),
        ])

        specs.append(contentsOf: [
            action(id: "focusMonitorNext", command: .focusMonitorNext, category: .monitor, binding: KeyBinding(keyCode: UInt32(kVK_Tab), modifiers: UInt32(controlKey | cmdKey))),
            action(id: "focusMonitorPrevious", command: .focusMonitorPrevious, category: .monitor, binding: .unassigned),
            action(id: "focusMonitorLast", command: .focusMonitorLast, category: .monitor, binding: KeyBinding(keyCode: UInt32(kVK_ANSI_Grave), modifiers: UInt32(controlKey | cmdKey))),
        ])

        specs.append(contentsOf: [
            action(id: "toggleFullscreen", command: .toggleFullscreen, category: .layout, binding: KeyBinding(keyCode: UInt32(kVK_Return), modifiers: hyperLayer)),
            action(id: "toggleNativeFullscreen", command: .toggleNativeFullscreen, category: .layout, binding: .unassigned),
            action(id: "moveColumn.left", command: .moveColumn(.left), category: .column, binding: KeyBinding(keyCode: UInt32(kVK_ANSI_A), modifiers: rcmdLayer)),
            action(id: "moveColumn.right", command: .moveColumn(.right), category: .column, binding: KeyBinding(keyCode: UInt32(kVK_ANSI_D), modifiers: rcmdLayer)),
            action(id: "toggleColumnTabbed", command: .toggleColumnTabbed, category: .column, binding: KeyBinding(keyCode: UInt32(kVK_ANSI_T), modifiers: rcmdLayer)),
            action(id: "focusColumnFirst", command: .focusColumnFirst, category: .focus, binding: KeyBinding(keyCode: UInt32(kVK_Home), modifiers: rcmdLayer)),
            action(id: "focusColumnLast", command: .focusColumnLast, category: .focus, binding: KeyBinding(keyCode: UInt32(kVK_End), modifiers: rcmdLayer)),
        ])

        for (idx, code) in digitCodes.enumerated() {
            specs.append(
                action(
                    id: "focusColumn.\(idx)",
                    command: .focusColumn(idx),
                    category: .focus,
                    binding: KeyBinding(keyCode: code, modifiers: hyperLayer)
                )
            )
        }

        specs.append(contentsOf: [
            action(id: "cycleColumnWidthForward", command: .cycleColumnWidthForward, category: .column, binding: KeyBinding(keyCode: UInt32(kVK_ANSI_Period), modifiers: hyperLayer)),
            action(id: "cycleColumnWidthBackward", command: .cycleColumnWidthBackward, category: .column, binding: KeyBinding(keyCode: UInt32(kVK_ANSI_Comma), modifiers: hyperLayer)),
            action(id: "toggleColumnFullWidth", command: .toggleColumnFullWidth, category: .column, binding: KeyBinding(keyCode: UInt32(kVK_ANSI_F), modifiers: hyperLayer)),
            action(id: "balanceSizes", command: .balanceSizes, category: .layout, binding: KeyBinding(keyCode: UInt32(kVK_ANSI_B), modifiers: hyperLayer)),
            action(id: "moveToRoot", command: .moveToRoot, category: .layout, binding: .unassigned),
            action(id: "toggleSplit", command: .toggleSplit, category: .layout, binding: .unassigned),
            action(id: "swapSplit", command: .swapSplit, category: .layout, binding: .unassigned),
        ])

        specs.append(contentsOf: [
            action(id: "resizeGrow.left", command: .resizeInDirection(.left, true), category: .layout, binding: .unassigned, keywords: ["resize", "grow"]),
            action(id: "resizeGrow.right", command: .resizeInDirection(.right, true), category: .layout, binding: .unassigned, keywords: ["resize", "grow"]),
            action(id: "resizeGrow.up", command: .resizeInDirection(.up, true), category: .layout, binding: .unassigned, keywords: ["resize", "grow"]),
            action(id: "resizeGrow.down", command: .resizeInDirection(.down, true), category: .layout, binding: .unassigned, keywords: ["resize", "grow"]),
            action(id: "resizeShrink.left", command: .resizeInDirection(.left, false), category: .layout, binding: .unassigned, keywords: ["resize", "shrink"]),
            action(id: "resizeShrink.right", command: .resizeInDirection(.right, false), category: .layout, binding: .unassigned, keywords: ["resize", "shrink"]),
            action(id: "resizeShrink.up", command: .resizeInDirection(.up, false), category: .layout, binding: .unassigned, keywords: ["resize", "shrink"]),
            action(id: "resizeShrink.down", command: .resizeInDirection(.down, false), category: .layout, binding: .unassigned, keywords: ["resize", "shrink"]),
            action(id: "preselect.left", command: .preselect(.left), category: .layout, binding: .unassigned),
            action(id: "preselect.right", command: .preselect(.right), category: .layout, binding: .unassigned),
            action(id: "preselect.up", command: .preselect(.up), category: .layout, binding: .unassigned),
            action(id: "preselect.down", command: .preselect(.down), category: .layout, binding: .unassigned),
            action(id: "preselectClear", command: .preselectClear, category: .layout, binding: .unassigned),
        ])

        specs.append(contentsOf: [
            action(id: "openCommandPalette", command: .openCommandPalette, category: .layout, binding: KeyBinding(keyCode: UInt32(kVK_Space), modifiers: rcmdLayer), keywords: ["launcher", "spotlight"]),
            action(id: "raiseAllFloatingWindows", command: .raiseAllFloatingWindows, category: .layout, binding: KeyBinding(keyCode: UInt32(kVK_ANSI_R), modifiers: rcmdLayer), keywords: ["float", "floating", "raise"]),
            action(id: "rescueOffscreenWindows", command: .rescueOffscreenWindows, category: .layout, binding: .unassigned, keywords: ["rescue", "offscreen", "off-screen"]),
            action(id: "toggleFocusedWindowFloating", command: .toggleFocusedWindowFloating, category: .layout, binding: KeyBinding(keyCode: UInt32(kVK_ANSI_G), modifiers: rcmdLayer), keywords: ["float", "floating"]),
            action(id: "assignFocusedWindowToScratchpad", command: .assignFocusedWindowToScratchpad, category: .layout, binding: .unassigned, keywords: ["scratchpad"]),
            action(id: "toggleScratchpadWindow", command: .toggleScratchpadWindow, category: .layout, binding: .unassigned, keywords: ["scratchpad"]),
            action(id: "openMenuAnywhere", command: .openMenuAnywhere, category: .focus, binding: KeyBinding(keyCode: UInt32(kVK_ANSI_M), modifiers: hyperLayer), keywords: ["menu", "anywhere"]),
            action(id: "toggleWorkspaceBarVisibility", command: .toggleWorkspaceBarVisibility, category: .focus, binding: .unassigned, keywords: ["workspace bar", "bar"]),
            action(id: "toggleHiddenBar", command: .toggleHiddenBar, category: .focus, binding: .unassigned, keywords: ["hidden bar", "bar"]),
            action(id: "toggleQuakeTerminal", command: .toggleQuakeTerminal, category: .focus, binding: KeyBinding(keyCode: UInt32(kVK_ANSI_Grave), modifiers: hyperLayer), keywords: ["quake", "terminal"]),
            action(id: "toggleWorkspaceLayout", command: .toggleWorkspaceLayout, category: .layout, binding: KeyBinding(keyCode: UInt32(kVK_ANSI_L), modifiers: hyperLayer), keywords: ["layout", "niri", "dwindle"]),
            action(id: "toggleOverview", command: .toggleOverview, category: .focus, binding: KeyBinding(keyCode: UInt32(kVK_ANSI_O), modifiers: hyperLayer), keywords: ["overview"]),
        ])

        let godLayer = UInt32(cmdKey | controlKey | optionKey)

        specs.append(contentsOf: [
            action(id: "trashFocusedWindow", command: .trashFocusedWindow, category: .layout, binding: KeyBinding(keyCode: UInt32(kVK_ANSI_T), modifiers: godLayer), keywords: ["trash", "kill", "close"]),
            action(id: "popLastTrashedWindow", command: .popLastTrashedWindow, category: .layout, binding: KeyBinding(keyCode: UInt32(kVK_ANSI_P), modifiers: godLayer), keywords: ["restore", "undo", "trash"]),
            action(id: "testHaptic", command: .testHaptic, category: .layout, binding: KeyBinding(keyCode: UInt32(kVK_ANSI_H), modifiers: godLayer), keywords: ["haptic", "test"]),
            action(id: "captureWorkspaceSnapshot", command: .captureWorkspaceSnapshot, category: .layout, binding: KeyBinding(keyCode: UInt32(kVK_ANSI_S), modifiers: godLayer), keywords: ["snapshot", "save"]),
            action(id: "openWarpSwitcher", command: .openWarpSwitcher, category: .layout, binding: KeyBinding(keyCode: UInt32(kVK_ANSI_W), modifiers: godLayer), keywords: ["warp", "switcher"]),
            action(id: "centerFocusedFloatAtSize", command: .centerFocusedFloatAtSize, category: .layout, binding: KeyBinding(keyCode: UInt32(kVK_ANSI_Y), modifiers: UInt32(cmdKey)), keywords: ["center", "float", "god"]),
            action(id: "toggleZenMode", command: .toggleZenMode, category: .layout, binding: KeyBinding(keyCode: UInt32(kVK_ANSI_Z), modifiers: godLayer), keywords: ["zen", "gaps", "focus", "distraction-free"]),
            action(id: "cycleFloatingOpacity", command: .cycleFloatingOpacity, category: .layout, binding: KeyBinding(keyCode: UInt32(kVK_ANSI_O), modifiers: godLayer), keywords: ["opacity", "transparent", "float"]),
        ])

        return specs
    }

    private static func action(
        id: String,
        command: HotkeyCommand,
        category: HotkeyCategory,
        binding: KeyBinding,
        keywords: [String] = []
    ) -> ActionSpec {
        let title = displayName(for: command)
        return ActionSpec(
            id: id,
            command: command,
            title: title,
            keywords: uniqueTerms(keywords + [title, id]),
            category: category,
            layoutCompatibility: compatibility(for: command),
            defaultBinding: binding,
            ipcCommandName: ipcCommandName(for: command)
        )
    }

    private static func compatibility(for command: HotkeyCommand) -> LayoutCompatibility {
        switch command {
        case .moveToRoot, .toggleSplit, .swapSplit, .preselect, .preselectClear, .resizeInDirection:
            .dwindle

        case .moveColumn, .moveColumnToWorkspace, .moveColumnToWorkspaceUp, .moveColumnToWorkspaceDown,
             .toggleColumnFullWidth, .toggleColumnTabbed,
             .focusPrevious, .focusDownOrLeft, .focusUpOrRight,
             .focusColumnFirst, .focusColumnLast, .focusColumn:
            .niri

        case .focus, .toggleFullscreen, .cycleColumnWidthForward, .cycleColumnWidthBackward,
             .balanceSizes,
             .move,
             .moveToWorkspace, .moveWindowToWorkspaceUp, .moveWindowToWorkspaceDown,
             .switchWorkspace, .switchWorkspaceNext, .switchWorkspacePrevious,
             .focusMonitorPrevious, .focusMonitorNext, .focusMonitorLast,
             .toggleNativeFullscreen,
             .swapWorkspaceWithMonitor,
             .workspaceBackAndForth, .focusWorkspaceAnywhere,
             .moveWindowToWorkspaceOnMonitor,
             .openCommandPalette, .raiseAllFloatingWindows, .rescueOffscreenWindows, .toggleFocusedWindowFloating,
             .assignFocusedWindowToScratchpad, .toggleScratchpadWindow,
             .openMenuAnywhere,
             .toggleWorkspaceBarVisibility, .toggleHiddenBar, .toggleQuakeTerminal,
             .toggleWorkspaceLayout, .toggleOverview,
             .trashFocusedWindow, .popLastTrashedWindow, .testHaptic, .captureWorkspaceSnapshot,
             .openWarpSwitcher, .centerFocusedFloatAtSize:
            .shared
        }
    }

    private static func displayName(for command: HotkeyCommand) -> String {
        switch command {
        case let .focus(dir): "Focus \(dir.displayName)"
        case .focusPrevious: "Focus Previous Window"
        case let .move(dir): "Move \(dir.displayName)"
        case let .moveToWorkspace(idx): "Move to Workspace \(idx + 1)"
        case .moveWindowToWorkspaceUp: "Move Window to Workspace Up"
        case .moveWindowToWorkspaceDown: "Move Window to Workspace Down"
        case let .moveColumnToWorkspace(idx): "Move Column to Workspace \(idx + 1)"
        case .moveColumnToWorkspaceUp: "Move Column to Workspace Up"
        case .moveColumnToWorkspaceDown: "Move Column to Workspace Down"
        case let .switchWorkspace(idx): "Switch to Workspace \(idx + 1)"
        case .switchWorkspaceNext: "Switch to Next Workspace"
        case .switchWorkspacePrevious: "Switch to Previous Workspace"
        case .focusMonitorPrevious: "Focus Previous Monitor"
        case .focusMonitorNext: "Focus Next Monitor"
        case .focusMonitorLast: "Focus Last Monitor"
        case .toggleFullscreen: "Toggle Fullscreen"
        case .toggleNativeFullscreen: "Toggle Native Fullscreen"
        case let .moveColumn(dir): "Move Column \(dir.displayName)"
        case .toggleColumnTabbed: "Toggle Column Tabbed"
        case .focusDownOrLeft: "Traverse Backward"
        case .focusUpOrRight: "Traverse Forward"
        case .focusColumnFirst: "Focus First Column"
        case .focusColumnLast: "Focus Last Column"
        case let .focusColumn(idx): "Focus Column \(idx + 1)"
        case .cycleColumnWidthForward: "Cycle Column Width Forward"
        case .cycleColumnWidthBackward: "Cycle Column Width Backward"
        case .toggleColumnFullWidth: "Toggle Column Full Width"
        case let .swapWorkspaceWithMonitor(dir): "Swap Workspace with \(dir.displayName) Monitor"
        case .balanceSizes: "Balance Sizes"
        case .moveToRoot: "Move to Root"
        case .toggleSplit: "Toggle Split"
        case .swapSplit: "Swap Split"
        case let .resizeInDirection(dir, grow): "\(grow ? "Grow" : "Shrink") \(dir.displayName)"
        case let .preselect(dir): "Preselect \(dir.displayName)"
        case .preselectClear: "Clear Preselection"
        case .workspaceBackAndForth: "Switch to Previous Workspace"
        case let .focusWorkspaceAnywhere(idx): "Focus Workspace \(idx + 1) Anywhere"
        case let .moveWindowToWorkspaceOnMonitor(wsIdx, monDir): "Move Window to Workspace \(wsIdx + 1) on \(monDir.displayName) Monitor"
        case .openCommandPalette: "Toggle Command Palette"
        case .raiseAllFloatingWindows: "Raise All Floating Windows"
        case .rescueOffscreenWindows: "Rescue Off-Screen Floating Windows"
        case .toggleFocusedWindowFloating: "Toggle Focused Window Floating"
        case .assignFocusedWindowToScratchpad: "Assign Focused Window to Scratchpad"
        case .toggleScratchpadWindow: "Toggle Scratchpad Window"
        case .openMenuAnywhere: "Open Menu Anywhere"
        case .toggleWorkspaceBarVisibility: "Toggle Workspace Bar"
        case .toggleHiddenBar: "Toggle Hidden Bar"
        case .toggleQuakeTerminal: "Toggle Quake Terminal"
        case .toggleWorkspaceLayout: "Toggle Workspace Layout"
        case .toggleOverview: "Toggle Overview"
        case .trashFocusedWindow: "Trash Focused Window"
        case .popLastTrashedWindow: "Pop Last Trashed Window"
        case .testHaptic: "Test Haptic Feedback"
        case .captureWorkspaceSnapshot: "Capture Workspace Layout Snapshot"
        case .openWarpSwitcher: "Open Warp Switcher"
        case .centerFocusedFloatAtSize: "Center Focused Float (1194x947)"
        case .toggleZenMode: "Toggle Zen Mode (Zero Gaps)"
        case .cycleFloatingOpacity: "Cycle Floating Window Opacity"
        }
    }

    private static func ipcCommandName(for command: HotkeyCommand) -> IPCCommandName? {
        switch command {
        case .focus:
            .focus
        case .focusPrevious:
            .focusPrevious
        case .focusDownOrLeft:
            .focusDownOrLeft
        case .focusUpOrRight:
            .focusUpOrRight
        case .focusColumn:
            .focusColumn
        case .focusColumnFirst:
            .focusColumnFirst
        case .focusColumnLast:
            .focusColumnLast
        case .move:
            .move
        case .switchWorkspace:
            .switchWorkspace
        case .switchWorkspaceNext:
            .switchWorkspaceNext
        case .switchWorkspacePrevious:
            .switchWorkspacePrevious
        case .workspaceBackAndForth:
            .switchWorkspaceBackAndForth
        case .focusWorkspaceAnywhere:
            .switchWorkspaceAnywhere
        case .moveToWorkspace:
            .moveToWorkspace
        case .moveWindowToWorkspaceUp:
            .moveToWorkspaceUp
        case .moveWindowToWorkspaceDown:
            .moveToWorkspaceDown
        case .moveWindowToWorkspaceOnMonitor:
            .moveToWorkspaceOnMonitor
        case .focusMonitorPrevious:
            .focusMonitorPrevious
        case .focusMonitorNext:
            .focusMonitorNext
        case .focusMonitorLast:
            .focusMonitorLast
        case .moveColumn:
            .moveColumn
        case .moveColumnToWorkspace:
            .moveColumnToWorkspace
        case .moveColumnToWorkspaceUp:
            .moveColumnToWorkspaceUp
        case .moveColumnToWorkspaceDown:
            .moveColumnToWorkspaceDown
        case .toggleColumnTabbed:
            .toggleColumnTabbed
        case .cycleColumnWidthForward:
            .cycleColumnWidthForward
        case .cycleColumnWidthBackward:
            .cycleColumnWidthBackward
        case .toggleColumnFullWidth:
            .toggleColumnFullWidth
        case .swapWorkspaceWithMonitor:
            .swapWorkspaceWithMonitor
        case .balanceSizes:
            .balanceSizes
        case .moveToRoot:
            .moveToRoot
        case .toggleSplit:
            .toggleSplit
        case .swapSplit:
            .swapSplit
        case .resizeInDirection:
            .resize
        case .preselect:
            .preselect
        case .preselectClear:
            .preselectClear
        case .openCommandPalette:
            .openCommandPalette
        case .raiseAllFloatingWindows:
            .raiseAllFloatingWindows
        case .rescueOffscreenWindows:
            .rescueOffscreenWindows
        case .toggleWorkspaceLayout:
            .toggleWorkspaceLayout
        case .toggleFullscreen:
            .toggleFullscreen
        case .toggleNativeFullscreen:
            .toggleNativeFullscreen
        case .toggleOverview:
            .toggleOverview
        case .toggleQuakeTerminal:
            .toggleQuakeTerminal
        case .toggleWorkspaceBarVisibility:
            .toggleWorkspaceBar
        case .toggleHiddenBar:
            .toggleHiddenBar
        case .toggleFocusedWindowFloating:
            .toggleFocusedWindowFloating
        case .assignFocusedWindowToScratchpad:
            .scratchpadAssign
        case .toggleScratchpadWindow:
            .scratchpadToggle
        case .openMenuAnywhere:
            .openMenuAnywhere
        case .toggleZenMode, .cycleFloatingOpacity,
             .trashFocusedWindow, .popLastTrashedWindow,
             .testHaptic, .captureWorkspaceSnapshot,
             .openWarpSwitcher, .centerFocusedFloatAtSize:
            nil
        }
    }
}
