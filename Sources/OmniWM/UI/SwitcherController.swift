import Cocoa
import SwiftUI

/// High-speed Warp Switcher — live window data, glassmorphic HUD, keyboard-dismissable.
@MainActor
public final class SwitcherController: NSWindowController {
    static let shared = SwitcherController()

    private var hostingView: NSHostingView<WarpSwitcherHUD>?
    private var eventMonitor: Any?

    private init() {
        let window = NSWindow(
            contentRect: NSScreen.main?.frame ?? NSRect(x: 0, y: 0, width: 1440, height: 900),
            styleMask: [.borderless, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )

        window.isOpaque = false
        window.backgroundColor = .clear
        window.level = .statusBar
        window.hasShadow = false
        window.ignoresMouseEvents = false
        window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]

        let hud = WarpSwitcherHUD(entries: [], onDismiss: {})
        let hosting = NSHostingView(rootView: hud)
        hosting.setFrameSize(window.frame.size)
        window.contentView = hosting

        super.init(window: window)

        if let screen = NSScreen.main {
            window.setFrame(screen.frame, display: true)
        }

        self.hostingView = hosting
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func show(using controller: WMController? = nil) {
        // Build live entries from running apps
        let apps = controller?.runningAppsWithWindows() ?? []
        let entries: [WarpSwitcherEntry] = apps.prefix(12).enumerated().map { idx, app in
            WarpSwitcherEntry(
                id: app.id,
                appName: app.appName,
                windowTitle: "\(Int(app.windowSize.width))×\(Int(app.windowSize.height))",
                icon: app.icon,
                isSelected: idx == 0
            )
        }

        // Re‑render with live data
        let hud = WarpSwitcherHUD(entries: entries, onDismiss: { [weak self] in
            self?.dismiss()
        })
        hostingView?.rootView = hud

        HapticManager.shared.trigger(.mediumPulse)
        window?.orderFrontRegardless()
        window?.makeKeyAndOrderFront(nil)

        // Global key monitor — Escape or W dismisses
        eventMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            let esc = event.keyCode == 53   // kVK_Escape
            let wKey = event.keyCode == 13  // kVK_ANSI_W
            if esc || wKey {
                self?.dismiss()
                return nil
            }
            return event
        }
    }

    func dismiss() {
        HapticManager.shared.trigger(.softTick)
        window?.orderOut(nil)
        if let monitor = eventMonitor {
            NSEvent.removeMonitor(monitor)
            eventMonitor = nil
        }
    }
}
