import AppKit
import Foundation

@MainActor
final class CommandHandler {
    weak var controller: WMController?
    var nativeFullscreenStateProvider: ((AXWindowRef) -> Bool)?
    var nativeFullscreenSetter: ((AXWindowRef, Bool) -> Bool)?
    var frontmostAppPidProvider: (() -> pid_t?)?
    var frontmostFocusedWindowTokenProvider: (() -> WindowToken?)?

    init(controller: WMController) {
        self.controller = controller
    }

    func handleCommand(_ command: HotkeyCommand) {
        let result = performCommand(command)
        if result == .executed && ExperimentFlags.shared.isGodBuildActive {
            HapticManager.shared.trigger(.sharpClick)
        }
    }

    @discardableResult
    func performCommand(_ command: HotkeyCommand) -> ExternalCommandResult {
        guard let controller else { return .notFound }
        guard controller.isEnabled else { return .ignoredDisabled }
        guard !Self.shouldIgnoreCommand(command, isOverviewOpen: controller.isOverviewOpen()) else {
            return .ignoredOverview
        }

        let layoutType = currentLayoutType()

        switch (command.layoutCompatibility, layoutType) {
        case (.niri, .dwindle), (.dwindle, .niri), (.dwindle, .defaultLayout):
            return .ignoredLayoutMismatch
        default:
            break
        }

        switch command {
        case let .focus(direction):
            layoutHandler(as: LayoutFocusable.self)?.focusNeighbor(direction: direction)
        case .focusPrevious:
            focusPreviousInNiri()
        case let .move(direction):
            moveWindow(direction: direction)
        case let .moveToWorkspace(index):
            controller.workspaceNavigationHandler.moveFocusedWindow(toWorkspaceIndex: index)
        case .moveWindowToWorkspaceUp:
            controller.workspaceNavigationHandler.moveWindowToAdjacentWorkspace(direction: .up)
        case .moveWindowToWorkspaceDown:
            controller.workspaceNavigationHandler.moveWindowToAdjacentWorkspace(direction: .down)
        case let .moveColumnToWorkspace(index):
            controller.workspaceNavigationHandler.moveColumnToWorkspaceByIndex(index: index)
        case .moveColumnToWorkspaceUp:
            controller.workspaceNavigationHandler.moveColumnToAdjacentWorkspace(direction: .up)
        case .moveColumnToWorkspaceDown:
            controller.workspaceNavigationHandler.moveColumnToAdjacentWorkspace(direction: .down)
        case let .switchWorkspace(index):
            controller.workspaceNavigationHandler.switchWorkspace(index: index)
        case .switchWorkspaceNext:
            controller.workspaceNavigationHandler.switchWorkspaceRelative(isNext: true)
        case .switchWorkspacePrevious:
            controller.workspaceNavigationHandler.switchWorkspaceRelative(isNext: false)
        case .focusMonitorPrevious:
            controller.workspaceNavigationHandler.focusMonitorCyclic(previous: true)
        case .focusMonitorNext:
            controller.workspaceNavigationHandler.focusMonitorCyclic(previous: false)
        case .focusMonitorLast:
            controller.workspaceNavigationHandler.focusLastMonitor()
        case .toggleFullscreen:
            toggleFullscreen()
        case .toggleNativeFullscreen:
            toggleNativeFullscreenForFocused()
        case let .moveColumn(direction):
            moveColumnInNiri(direction: direction)
        case .toggleColumnTabbed:
            toggleColumnTabbedInNiri()
        case .focusDownOrLeft:
            focusDownOrLeftInNiri()
        case .focusUpOrRight:
            focusUpOrRightInNiri()
        case .focusColumnFirst:
            focusColumnFirstInNiri()
        case .focusColumnLast:
            focusColumnLastInNiri()
        case let .focusColumn(index):
            focusColumnInNiri(index: index)
        case .cycleColumnWidthForward:
            layoutHandler(as: LayoutSizable.self)?.cycleSize(forward: true)
        case .cycleColumnWidthBackward:
            layoutHandler(as: LayoutSizable.self)?.cycleSize(forward: false)
        case .toggleColumnFullWidth:
            controller.niriLayoutHandler.toggleColumnFullWidth()
        case let .swapWorkspaceWithMonitor(direction):
            controller.workspaceNavigationHandler.swapCurrentWorkspaceWithMonitor(direction: direction)
        case .balanceSizes:
            layoutHandler(as: LayoutSizable.self)?.balanceSizes()
        case let .setColumnWidth(width):
            setColumnWidthInNiri(width)
        case .moveToRoot:
            moveToRootInDwindle()
        case .toggleSplit:
            toggleSplitInDwindle()
        case .swapSplit:
            swapSplitInDwindle()
        case let .resizeInDirection(direction, grow):
            resizeInDirectionInDwindle(direction: direction, grow: grow)
        case let .preselect(direction):
            preselectInDwindle(direction: direction)
        case .preselectClear:
            clearPreselectInDwindle()
        case .workspaceBackAndForth:
            controller.workspaceNavigationHandler.workspaceBackAndForth()
        case let .focusWorkspaceAnywhere(index):
            controller.workspaceNavigationHandler.focusWorkspaceAnywhere(index: index)
        case let .moveWindowToWorkspaceOnMonitor(wsIdx, monDir):
            controller.workspaceNavigationHandler.moveWindowToWorkspaceOnMonitor(
                workspaceIndex: wsIdx,
                monitorDirection: monDir
            )
        case .openCommandPalette:
            controller.openCommandPalette()
        case .raiseAllFloatingWindows:
            controller.raiseAllFloatingWindows()
        case .rescueOffscreenWindows:
            _ = controller.rescueOffscreenWindows()
        case .toggleFocusedWindowFloating:
            controller.toggleFocusedWindowFloating()
        case .assignFocusedWindowToScratchpad:
            controller.assignFocusedWindowToScratchpad()
        case .toggleScratchpadWindow:
            controller.toggleScratchpadWindow()
        case .openMenuAnywhere:
            controller.openMenuAnywhere()
        case .toggleWorkspaceBarVisibility:
            controller.toggleWorkspaceBarVisibility()
        case .showWorkspaceBar:
            controller.showWorkspaceBar()
        case .hideWorkspaceBar:
            controller.hideWorkspaceBar()
            let isHidden = WMController.shared.hiddenWorkspaceBarMonitorIds.contains(WMController.shared.monitorForInteraction()?.id ?? UUID())
            HUDController.shared.showNotification(
                title: "HUD CONTROLLER",
                icon: isHidden ? "eye.slash" : "eye",
                message: isHidden ? "Bar Hidden (5s peek mode)" : "Bar Visible",
                highlightColor: .blue
            )
        case .toggleHiddenBar:
            controller.toggleHiddenBar()
        case .toggleQuakeTerminal:
            controller.toggleQuakeTerminal()
        case .toggleWorkspaceLayout:
            toggleWorkspaceLayout()
        case .toggleOverview:
            controller.toggleOverview()
        case .trashFocusedWindow:
            if ExperimentFlags.shared.isGodBuildActive && controller.settings.windowTrashEnabled {
                controller.trashFocusedWindow()
            }
        case .popLastTrashedWindow:
            if ExperimentFlags.shared.isGodBuildActive && controller.settings.windowTrashEnabled {
                controller.popLastTrashedWindow()
            }
        case .testHaptic:
            if ExperimentFlags.shared.isGodBuildActive {
                HapticManager.shared.trigger(.alignment)
            }
        case .captureWorkspaceSnapshot:
            if ExperimentFlags.shared.isGodBuildActive && controller.settings.sessionSnapshotEnabled,
               let activeWs = controller.activeWorkspace() {
                let snapshot = controller.workspaceManager.reconcileSnapshot()
                if let data = try? JSONEncoder().encode(snapshot),
                   let layoutJSON = String(data: data, encoding: .utf8) {
                    WorkspaceSnapshotManager.shared.capture(
                        workspaceId: "\(activeWs.id)",
                        layoutJSON: layoutJSON
                    )
                    HUDController.shared.showNotification(
                        title: "LAYOUT SNAPSHOT",
                        icon: "camera.viewfinder",
                        message: "State cached for \(activeWs.name)",
                        highlightColor: .orange
                    )
                }
            }
        case .restoreWorkspaceSnapshot:
            if ExperimentFlags.shared.isGodBuildActive && controller.settings.sessionSnapshotEnabled,
               let activeWs = controller.activeWorkspace(),
               let snapshotRecord = WorkspaceSnapshotManager.shared.latestSnapshot(for: "\(activeWs.id)"),
               let data = snapshotRecord.layoutData.data(using: .utf8),
               let snapshot = try? JSONDecoder().decode(ReconcileSnapshot.self, from: data) {
                controller.workspaceManager.restore(snapshot: snapshot)
                HUDController.shared.showNotification(
                    title: "LAYOUT RESTORED",
                    icon: "arrow.clockwise.circle",
                    message: "Restored to \(snapshotRecord.formattedTimestamp)",
                    highlightColor: .green
                )
            }
        case .openWarpSwitcher:
            if ExperimentFlags.shared.isGodBuildActive && controller.settings.warpSwitcherEnabled {
                controller.openWarpSwitcher()
            }
        case .centerFocusedFloatAtSize:
            guard let controller,
                  let token = controller.focusedWindowToken(),
                  let entry = controller.workspaceManager.entry(for: token) else { return .executed }

            if entry.mode != .floating {
                controller.toggleFocusedWindowFloating()
            }

            let targetWidth: CGFloat = 1194
            let targetHeight: CGFloat = 947

            if let monitor = controller.monitorForInteraction() {
                let displayBounds = CGDisplayBounds(monitor.displayId)
                let screenVisibleFrame = monitor.visibleFrame
                
                // Horizontal center
                let centerX = displayBounds.minX + (displayBounds.width - targetWidth) / 2
                
                // Vertical End-Center (bottom of visible screen with 8px pad)
                // Cocoa visibleFrame gives the bottom inset (e.g. from Dock)
                let bottomInset = screenVisibleFrame.origin.y - monitor.frame.minY
                let centerY = displayBounds.maxY - bottomInset - targetHeight - 8
                
                let targetFrame = CGRect(x: centerX, y: centerY, width: targetWidth, height: targetHeight)
                
                var point = targetFrame.origin
                var size = targetFrame.size
                
                let pointValue = AXValueCreate(.cgPoint, &point)
                let sizeValue = AXValueCreate(.cgSize, &size)
                
                if let pointValue, let sizeValue {
                    AXUIElementSetAttributeValue(entry.axRef, kAXPositionAttribute as CFString, pointValue)
                    AXUIElementSetAttributeValue(entry.axRef, kAXSizeAttribute as CFString, sizeValue)
                    
                    // Warp mouse to center of the centered window to ensure focus and usability
                    let targetCenter = CGPoint(x: targetFrame.midX, y: targetFrame.midY)
                    CGWarpMouseCursorPosition(targetCenter)
                    
                    let isGod = ExperimentFlags.shared.isGodBuildActive
                    HapticManager.shared.trigger(.alignment)
                    HUDController.shared.showNotification(
                        title: isGod ? "GOD BUILD ACTION" : "ACTION",
                        icon: "rectangle.center.inset.filled",
                        message: "Centered at \(Int(targetWidth))x\(Int(targetHeight))",
                        highlightColor: isGod ? .purple : .blue
                    )
                }
            }
        }

        return .executed
    }

    static func shouldIgnoreCommand(_ command: HotkeyCommand, isOverviewOpen: Bool) -> Bool {
        isOverviewOpen && command != .toggleOverview
    }

    private func layoutHandler<T>(as capability: T.Type) -> T? {
        guard let controller else { return nil }
        let layoutType = currentLayoutType()
        let handler: AnyObject = switch layoutType {
        case .dwindle:
            controller.layoutRefreshController.dwindleHandler
        case .niri, .defaultLayout:
            controller.layoutRefreshController.niriHandler
        }
        return handler as? T
    }

    private func focusPreviousInNiri() {
        guard let controller else { return }
        controller.niriLayoutHandler.withNiriWorkspaceContext { engine, wsId, motion, state, _, workingFrame, gaps in
            if let currentId = state.selectedNodeId {
                engine.updateFocusTimestamp(for: currentId)
            }

            if let currentId = state.selectedNodeId {
                engine.activateWindow(currentId)
            }

            guard let previousWindow = engine.focusPrevious(
                currentNodeId: state.selectedNodeId,
                in: wsId,
                motion: motion,
                state: &state,
                workingFrame: workingFrame,
                gaps: gaps,
                limitToWorkspace: true
            ) else {
                return
            }

            controller.niriLayoutHandler.activateNode(
                previousWindow, in: wsId, state: &state,
                options: .init(ensureVisible: false, updateTimestamp: false, startAnimation: false)
            )

            if state.viewOffsetPixels.isAnimating {
                controller.layoutRefreshController.startScrollAnimation(for: wsId)
            }
        }
    }

    private func setColumnWidthInNiri(_ width: Double) {
        guard let controller else { return }
        controller.niriLayoutHandler.withNiriOperationContext { ctx, state in
            ctx.engine.setColumnWidth(
                ctx.windowNode.container,
                width: .proportion(width),
                in: ctx.wsId,
                motion: ctx.motion,
                state: &state,
                workingFrame: ctx.workingFrame,
                gaps: ctx.gaps
            )
            return ctx.commitSimple(state: state)
        }
    }

    private func focusDownOrLeftInNiri() {
        executeCombinedNavigation { engine, currentNode, wsId, motion, state, workingFrame, gaps in
            engine.focusDownOrLeft(
                currentSelection: currentNode,
                in: wsId,
                motion: motion,
                state: &state,
                workingFrame: workingFrame,
                gaps: gaps
            )
        }
    }

    private func focusUpOrRightInNiri() {
        executeCombinedNavigation { engine, currentNode, wsId, motion, state, workingFrame, gaps in
            engine.focusUpOrRight(
                currentSelection: currentNode,
                in: wsId,
                motion: motion,
                state: &state,
                workingFrame: workingFrame,
                gaps: gaps
            )
        }
    }

    private func focusColumnFirstInNiri() {
        executeCombinedNavigation { engine, currentNode, wsId, motion, state, workingFrame, gaps in
            engine.focusColumnFirst(
                currentSelection: currentNode,
                in: wsId,
                motion: motion,
                state: &state,
                workingFrame: workingFrame,
                gaps: gaps
            )
        }
    }

    private func focusColumnLastInNiri() {
        executeCombinedNavigation { engine, currentNode, wsId, motion, state, workingFrame, gaps in
            engine.focusColumnLast(
                currentSelection: currentNode,
                in: wsId,
                motion: motion,
                state: &state,
                workingFrame: workingFrame,
                gaps: gaps
            )
        }
    }

    private func focusColumnInNiri(index: Int) {
        executeCombinedNavigation { engine, currentNode, wsId, motion, state, workingFrame, gaps in
            engine.focusColumn(
                index,
                currentSelection: currentNode,
                in: wsId,
                motion: motion,
                state: &state,
                workingFrame: workingFrame,
                gaps: gaps
            )
        }
    }

    private func executeCombinedNavigation(
        _ navigationAction: (
            NiriLayoutEngine,
            NiriNode,
            WorkspaceDescriptor.ID,
            MotionSnapshot,
            inout ViewportState,
            CGRect,
            CGFloat
        )
            -> NiriNode?
    ) {
        guard let controller else { return }
        guard let engine = controller.niriEngine else { return }
        guard let wsId = controller.activeWorkspace()?.id else { return }
        guard let monitor = controller.workspaceManager.monitor(for: wsId) else { return }

        var state = controller.workspaceManager.niriViewportState(for: wsId)
        guard let currentId = state.selectedNodeId,
              let currentNode = engine.findNode(by: currentId)
        else {
            return
        }

        let gap = CGFloat(controller.workspaceManager.gaps)
        let workingFrame = controller.insetWorkingFrame(for: monitor)
        let motion = controller.motionPolicy.snapshot()
        guard let newNode = navigationAction(engine, currentNode, wsId, motion, &state, workingFrame, gap) else {
            return
        }

        controller.niriLayoutHandler.activateNode(
            newNode, in: wsId, state: &state,
            options: .init(activateWindow: false, ensureVisible: false)
        )
        _ = controller.workspaceManager.applySessionPatch(
            .init(
                workspaceId: wsId,
                viewportState: state,
                rememberedFocusToken: nil
            )
        )
    }

    private func moveWindow(direction: Direction) {
        switch currentLayoutType() {
        case .dwindle:
            controller?.dwindleLayoutHandler.swapWindow(direction: direction)
        case .niri, .defaultLayout:
            moveWindowInNiri(direction: direction)
        }
    }

    private func toggleFullscreen() {
        switch currentLayoutType() {
        case .dwindle:
            controller?.dwindleLayoutHandler.toggleFullscreen()
        case .niri, .defaultLayout:
            controller?.niriLayoutHandler.toggleFullscreen()
        }
    }

    private func moveWindowInNiri(direction: Direction) {
        guard let controller else { return }
        controller.niriLayoutHandler.withNiriOperationContext { ctx, state in
            let oldFrames = direction == .left || direction == .right
                ? [:]
                : ctx.engine.captureWindowFrames(in: ctx.wsId)
            guard ctx.engine.moveWindow(
                ctx.windowNode, direction: direction, in: ctx.wsId,
                motion: ctx.motion,
                state: &state,
                workingFrame: ctx.workingFrame,
                gaps: ctx.gaps
            ) else { return false }
            if direction == .left || direction == .right {
                return ctx.commitSimple(state: state)
            }
            return ctx.commitWithPredictedAnimation(state: state, oldFrames: oldFrames)
        }
    }

    private func toggleNativeFullscreenForFocused() {
        guard let controller else { return }
        let setFullscreen = nativeFullscreenSetter ?? { axRef, fullscreen in
            AXWindowService.setNativeFullscreen(axRef, fullscreen: fullscreen)
        }
        let isFullscreen = nativeFullscreenStateProvider ?? { axRef in
            AXWindowService.isFullscreen(axRef)
        }

        if let token = controller.workspaceManager.focusedToken,
           let entry = controller.workspaceManager.entry(for: token)
        {
            let currentState = isFullscreen(entry.axRef)
            if currentState {
                _ = controller.workspaceManager.requestNativeFullscreenExit(token, initiatedByCommand: true)
                guard setFullscreen(entry.axRef, false) else {
                    _ = controller.suspendManagedWindowForNativeFullscreen(
                        token,
                        path: .commandExitSetFailure
                    )
                    return
                }
                return
            }

            _ = controller.requestManagedNativeFullscreenEnter(
                token,
                in: entry.workspaceId,
                path: .commandDrivenEnter
            )
            guard setFullscreen(entry.axRef, true) else {
                _ = controller.workspaceManager.restoreNativeFullscreenRecord(for: token)
                return
            }
            return
        }

        guard controller.workspaceManager.isAppFullscreenActive
            || controller.workspaceManager.hasPendingNativeFullscreenTransition
        else {
            return
        }

        let frontmostPid = frontmostAppPidProvider?() ?? NSWorkspace.shared.frontmostApplication?.processIdentifier
        let frontmostToken = frontmostFocusedWindowTokenProvider?()
            ?? frontmostPid.flatMap { controller.axEventHandler.focusedWindowToken(for: $0) }
        guard let token = controller.workspaceManager.nativeFullscreenCommandTarget(frontmostToken: frontmostToken),
              let entry = controller.workspaceManager.entry(for: token)
        else {
            return
        }

        _ = controller.workspaceManager.requestNativeFullscreenExit(token, initiatedByCommand: true)
        guard setFullscreen(entry.axRef, false) else {
            _ = controller.suspendManagedWindowForNativeFullscreen(
                token,
                path: .commandExitSetFailure
            )
            return
        }
    }

    private func moveColumnInNiri(direction: Direction) {
        guard let controller else { return }
        controller.niriLayoutHandler.withNiriOperationContext { ctx, state in
            guard let column = ctx.engine.findColumn(containing: ctx.windowNode, in: ctx.wsId) else { return false }
            let oldFrames = ctx.engine.captureWindowFrames(in: ctx.wsId)
            guard ctx.engine.moveColumn(
                column, direction: direction, in: ctx.wsId,
                motion: ctx.motion,
                state: &state,
                workingFrame: ctx.workingFrame,
                gaps: ctx.gaps
            ) else { return false }
            return ctx.commitWithCapturedAnimation(state: state, oldFrames: oldFrames)
        }
    }

    private func toggleColumnTabbedInNiri() {
        guard let controller else { return }
        controller.niriLayoutHandler.withNiriWorkspaceContext { engine, wsId, motion, state, _, _, _ in
            if engine.toggleColumnTabbed(in: wsId, state: state, motion: motion) {
                controller.layoutRefreshController.requestImmediateRelayout(reason: .layoutCommand)
                if engine.hasAnyWindowAnimationsRunning(in: wsId) {
                    controller.layoutRefreshController.startScrollAnimation(for: wsId)
                }
            }
        }
    }

    private func currentLayoutType() -> LayoutType {
        guard let controller else { return .niri }
        guard let ws = controller.activeWorkspace() else { return .niri }
        return controller.settings.layoutType(for: ws.name)
    }

    private func moveToRootInDwindle() {
        guard let controller else { return }
        controller.dwindleLayoutHandler.moveSelectionToRoot(stable: controller.settings.dwindleMoveToRootStable)
    }

    private func toggleSplitInDwindle() {
        guard let controller else { return }
        controller.dwindleLayoutHandler.toggleSplit()
    }

    private func swapSplitInDwindle() {
        guard let controller else { return }
        controller.dwindleLayoutHandler.swapSplit()
    }

    private func resizeInDirectionInDwindle(direction: Direction, grow: Bool) {
        guard let controller else { return }
        controller.dwindleLayoutHandler.resize(direction: direction, grow: grow)
    }

    private func preselectInDwindle(direction: Direction) {
        guard let controller else { return }
        controller.dwindleLayoutHandler.withDwindleContext { engine, wsId in
            engine.setPreselection(direction, in: wsId)
        }
    }

    private func clearPreselectInDwindle() {
        guard let controller else { return }
        controller.dwindleLayoutHandler.withDwindleContext { engine, wsId in
            engine.setPreselection(nil, in: wsId)
        }
    }

    private func toggleWorkspaceLayout() {
        guard let controller else { return }
        guard let workspace = controller.activeWorkspace() else { return }
        let workspaceName = workspace.name

        let currentLayout = controller.settings.layoutType(for: workspaceName)

        let newLayout: LayoutType = switch currentLayout {
        case .niri, .defaultLayout: .dwindle
        case .dwindle: .niri
        }

        _ = setWorkspaceLayout(newLayout, forWorkspaceNamed: workspaceName)
    }

    @discardableResult
    func setWorkspaceLayout(_ newLayout: LayoutType, forWorkspaceNamed workspaceName: String? = nil) -> Bool {
        guard let controller else { return false }
        let resolvedWorkspaceName = workspaceName ?? controller.activeWorkspace()?.name
        guard let resolvedWorkspaceName else { return false }

        var configs = controller.settings.workspaceConfigurations
        guard let index = configs.firstIndex(where: { $0.name == resolvedWorkspaceName }) else { return false }

        guard configs[index].layoutType != newLayout else { return false }

        configs[index] = configs[index].with(layoutType: newLayout)
        controller.settings.workspaceConfigurations = configs
        controller.layoutRefreshController.requestRelayout(reason: .workspaceLayoutToggled)
        if let ipcApplicationBridge = controller.ipcApplicationBridge {
            Task {
                await ipcApplicationBridge.publishEvent(.layoutChanged)
            }
        }
        return true
    }
}
