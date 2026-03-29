import Foundation
import CoreGraphics
import Carbon

// KeyMorpher Prototype - Alternate Modifier Generator
// Turns any normal key into a powerful modifier (Mod-Tap).
// Example: Hold 'Caps Lock' to act as 'Cmd+Opt+Ctrl+Shift' (Hyper), Tap for standard behavior.

// --- Configuration ---
let TRIGGER_KEY: CGKeyCode = 57 // Caps Lock
let BASE_MODS: CGEventFlags = [.maskCommand, .maskAlternate, .maskControl]
// ----------------------

class KeyState {
    var isTriggerDown = false
    var otherKeyPressedWhileTriggerDown = false
}

let state = KeyState()

func callback(proxy: CGEventTapProxy, type: CGEventType, event: CGEvent, refcon: UnsafeMutableRawPointer?) -> Unmanaged<CGEvent>? {
    let keyCode = event.getIntegerValueField(.keyboardEventKeycode)
    
    // --- Trigger Key Logic ---
    if keyCode == Int64(TRIGGER_KEY) {
        if type == .keyDown {
            if !state.isTriggerDown {
                state.isTriggerDown = true
                state.otherKeyPressedWhileTriggerDown = false
                print("[DEBUG] Trigger (Caps Lock) DEPRESSED. Listening for other keys...")
            }
            return nil 
        } else if type == .keyUp {
            state.isTriggerDown = false
            print("[DEBUG] Trigger (Caps Lock) RELEASED.")
            if !state.otherKeyPressedWhileTriggerDown {
                print("[DEBUG] TAP detected. Sending original Caps Lock event.")
                let down = CGEvent(keyboardEventSource: nil, virtualKey: TRIGGER_KEY, keyDown: true)
                let up = CGEvent(keyboardEventSource: nil, virtualKey: TRIGGER_KEY, keyDown: false)
                down?.post(tap: .cgAnnotatedSessionEventTap)
                up?.post(tap: .cgAnnotatedSessionEventTap)
            }
            return nil
        }
    }
    
    // --- Transformation Logic ---
    if state.isTriggerDown {
        if type == .keyDown || type == .keyUp {
            state.otherKeyPressedWhileTriggerDown = true
            
            // Add Hyper/Meh modifiers (Cmd + Opt + Ctrl)
            event.flags = event.flags.union(BASE_MODS)
            
            let modString = event.flags.contains(.maskShift) ? "HyperShift (⇧⌃⌥⌘)" : "Hyper (⌃⌥⌘)"
            print("[DEBUG] Key \(keyCode) intercepted. Applying \(modString). Full Flags: \(event.flags.rawValue)")
            
            return Unmanaged.passRetained(event)
        }
    }
    
    return Unmanaged.passRetained(event)
}

let eventMask = (1 << CGEventType.keyDown.rawValue) | (1 << CGEventType.keyUp.rawValue)

guard let eventTap = CGEvent.tapCreate(
    tap: .cgSessionEventTap,
    place: .headInsertEventTap,
    options: .defaultTap,
    eventsOfInterest: CGEventMask(eventMask),
    callback: callback,
    userInfo: nil
) else {
    print("ERROR: Failed to create event tap.")
    print("Please ensure your Terminal/App has 'Accessibility' and 'Input Monitoring' permissions in System Settings.")
    exit(1)
}

let runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, eventTap, 0)
CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)
CGEvent.tapEnable(tap: eventTap, enable: true)

print("KeyMorpher Prototype ACTIVE")
print("Trigger Key (KeyCode \(TRIGGER_KEY)) is now a Hyper Key (Cmd+Opt+Ctrl+Shift) when held.")
print("Tap it normally to send its original keycode.")
print("Press Ctrl+C to stop.")

CFRunLoopRun()
