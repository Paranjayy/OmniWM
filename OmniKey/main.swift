import Cocoa
import CoreGraphics
import Carbon

// ============================================================
// OmniKey — Hold Right Option to add Ctrl to any keypress
// Result: Right Opt + key → sends Ctrl+Opt+key
// This matches OmniWM's "optionKey | controlKey" bindings
// while keeping Left Option free for word navigation.
// ============================================================

// --- TRIGGER CONFIGURATION ---
// Right Option = keycode 61, flag = .maskAlternate
// To use Fn/Globe instead: change TRIGGER_KEYCODE to 63,
//   TRIGGER_FLAG to .maskSecondaryFn,
//   and INJECTED_MODS to [.maskAlternate, .maskControl]
let TRIGGER_KEYCODE: Int64 = 61          // kVK_RightOption
let TRIGGER_FLAG: CGEventFlags = .maskAlternate
let INJECTED_MODS: CGEventFlags = [.maskControl]  // Ctrl (Option already present from physical key)
let TRIGGER_NAME = "Right Option (⌥)"

class KeyState {
    static let shared = KeyState()
    var isTriggerDown = false
}

extension Notification.Name {
    static let triggerDown = Notification.Name("triggerDown")
    static let triggerUp   = Notification.Name("triggerUp")
    static let keyMorphed  = Notification.Name("keyMorphed")
}

func eventCallback(
    proxy: CGEventTapProxy,
    type: CGEventType,
    event: CGEvent,
    refcon: UnsafeMutableRawPointer?
) -> Unmanaged<CGEvent>? {
    let state = KeyState.shared

    // Detect trigger key (Right Option) via flagsChanged
    if type == .flagsChanged {
        let keyCode = event.getIntegerValueField(.keyboardEventKeycode)
        if keyCode == TRIGGER_KEYCODE {
            let flagActive = event.flags.contains(TRIGGER_FLAG)
            if flagActive && !state.isTriggerDown {
                state.isTriggerDown = true
                NotificationCenter.default.post(name: .triggerDown, object: nil)
            } else if !flagActive && state.isTriggerDown {
                state.isTriggerDown = false
                NotificationCenter.default.post(name: .triggerUp, object: nil)
            }
        }
        return Unmanaged.passRetained(event)
    }

    // When trigger is held, inject extra modifiers into keypresses
    if state.isTriggerDown && (type == .keyDown || type == .keyUp) {
        let keyCode = event.getIntegerValueField(.keyboardEventKeycode)
        event.flags = event.flags.union(INJECTED_MODS)

        if type == .keyDown {
            let info: [String: Any] = [
                "keyCode": keyCode,
                "flags": event.flags.rawValue
            ]
            NotificationCenter.default.post(name: .keyMorphed, object: nil, userInfo: info)
        }
        return Unmanaged.passRetained(event)
    }

    return Unmanaged.passRetained(event)
}

// ============================================================
// App UI
// ============================================================

class AppDelegate: NSObject, NSApplicationDelegate {
    var window: NSWindow!
    var statusLabel: NSTextField!
    var logLabel: NSTextField!

    func applicationDidFinishLaunching(_ notification: Notification) {
        setupWindow()
        let tapOK = startEventTap()

        NotificationCenter.default.addObserver(self, selector: #selector(onDown),    name: .triggerDown, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onUp),      name: .triggerUp,   object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onMorphed), name: .keyMorphed,  object: nil)

        if tapOK {
            checkPermissionsUI()
        }
    }

    func setupWindow() {
        let screen = NSScreen.main?.visibleFrame ?? NSRect(x: 0, y: 0, width: 600, height: 400)
        let rect = NSRect(x: screen.midX - 200, y: screen.midY - 140, width: 400, height: 280)

        window = NSWindow(contentRect: rect,
                          styleMask: [.titled, .closable, .miniaturizable],
                          backing: .buffered, defer: false)
        window.title = "OmniKey"
        window.makeKeyAndOrderFront(nil)

        let cv = window.contentView!

        // Title
        let title = NSTextField(labelWithString: "OmniKey")
        title.font = .boldSystemFont(ofSize: 28)
        title.alignment = .center
        title.frame = NSRect(x: 0, y: 220, width: 400, height: 40)
        cv.addSubview(title)

        // Status
        statusLabel = NSTextField(labelWithString: "🔴 READY — hold \(TRIGGER_NAME)")
        statusLabel.font = .boldSystemFont(ofSize: 18)
        statusLabel.alignment = .center
        statusLabel.frame = NSRect(x: 0, y: 175, width: 400, height: 30)
        cv.addSubview(statusLabel)

        // How it works
        let hint = NSTextField(labelWithString:
            "Hold \(TRIGGER_NAME) + any key → Ctrl+Opt+key\n" +
            "Left Option still works normally for word nav\n" +
            "Release \(TRIGGER_NAME) to stop transforming")
        hint.font = .systemFont(ofSize: 12)
        hint.alignment = .center
        hint.frame = NSRect(x: 10, y: 110, width: 380, height: 55)
        cv.addSubview(hint)

        // Log area
        logLabel = NSTextField(labelWithString: "Waiting for keypresses...")
        logLabel.font = .monospacedSystemFont(ofSize: 11, weight: .regular)
        logLabel.textColor = .secondaryLabelColor
        logLabel.alignment = .center
        logLabel.frame = NSRect(x: 10, y: 20, width: 380, height: 80)
        logLabel.maximumNumberOfLines = 4
        cv.addSubview(logLabel)
    }

    @objc func onDown() {
        DispatchQueue.main.async {
            self.statusLabel.stringValue = "🟢 ACTIVE — keys are being transformed!"
            self.statusLabel.textColor = .systemGreen
            self.logLabel.stringValue = "Now press any key — Ctrl will be added.\nResult: Ctrl+Opt+key → triggers OmniWM shortcuts"
        }
    }

    @objc func onUp() {
        DispatchQueue.main.async {
            self.statusLabel.stringValue = "🔴 READY — hold \(TRIGGER_NAME)"
            self.statusLabel.textColor = .labelColor
            self.logLabel.stringValue = "Waiting for keypresses..."
        }
    }

    @objc func onMorphed(_ notification: Notification) {
        guard let info = notification.userInfo,
              let keyCode = info["keyCode"] as? Int64,
              let flags = info["flags"] as? UInt64 else { return }

        let hasCmd   = CGEventFlags(rawValue: flags).contains(.maskCommand)   ? "⌘" : " "
        let hasOpt   = CGEventFlags(rawValue: flags).contains(.maskAlternate) ? "⌥" : " "
        let hasCtrl  = CGEventFlags(rawValue: flags).contains(.maskControl)   ? "⌃" : " "
        let hasShift = CGEventFlags(rawValue: flags).contains(.maskShift)     ? "⇧" : " "

        DispatchQueue.main.async {
            self.logLabel.stringValue = "Key \(keyCode) → [\(hasCmd)\(hasOpt)\(hasCtrl)\(hasShift)] sent to system\nCtrl+Opt modifier injected ✅"
            self.logLabel.textColor = .systemGreen
        }

        // Reset color after a moment
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.logLabel.textColor = .secondaryLabelColor
        }
    }

    func startEventTap() -> Bool {
        let mask: CGEventMask = (1 << CGEventType.keyDown.rawValue)
                              | (1 << CGEventType.keyUp.rawValue)
                              | (1 << CGEventType.flagsChanged.rawValue)

        guard let tap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: mask,
            callback: eventCallback,
            userInfo: nil
        ) else {
            DispatchQueue.main.async {
                self.statusLabel.stringValue = "🚫 EVENT TAP FAILED"
                self.statusLabel.textColor = .systemRed
                self.logLabel.stringValue = "Could not create event tap.\nAdd OmniKey to Accessibility in System Settings."
            }
            return false
        }

        let src = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, tap, 0)
        CFRunLoopAddSource(CFRunLoopGetCurrent(), src, .commonModes)
        CGEvent.tapEnable(tap: tap, enable: true)
        return true
    }

    func checkPermissionsUI() {
        let opts = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true]
        if !AXIsProcessTrustedWithOptions(opts as CFDictionary) {
            statusLabel.stringValue = "🚫 NO ACCESS"
            statusLabel.textColor = .systemRed
            logLabel.stringValue = "Add OmniKey to:\nSystem Settings → Privacy → Accessibility"
        }
    }
}

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.run()
