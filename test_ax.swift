import AppKit
import ApplicationServices

let apps = NSWorkspace.shared.runningApplications
for app in apps {
    if app.localizedName == "Code" || app.localizedName == "Cursor" || app.localizedName == "Visual Studio Code" {
        let appElement = AXUIElementCreateApplication(app.processIdentifier)
        var windowRef: CFTypeRef?
        if AXUIElementCopyAttributeValue(appElement, kAXFocusedWindowAttribute as CFString, &windowRef) == .success {
            let window = windowRef as! AXUIElement
            var posRef: CFTypeRef?
            if AXUIElementCopyAttributeValue(window, kAXPositionAttribute as CFString, &posRef) == .success {
                let pos = posRef as! AXValue
                var point = CGPoint.zero
                AXValueGetValue(pos, .cgPoint, &point)
                print("VSCode Window AX pos:", point)
            }
        }
    }
}
