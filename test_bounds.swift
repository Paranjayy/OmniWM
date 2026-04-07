import AppKit

if let screen = NSScreen.main {
    let bottomInset = screen.visibleFrame.origin.y - screen.frame.minY
    print("Bottom inset:", bottomInset)
    
    if let displayId = screen.displayId {
        let displayBounds = CGDisplayBounds(displayId)
        print("Display Bounds:", displayBounds)
        let carbonY = displayBounds.maxY - bottomInset - 947 - 8
        print("Carbon Y for End-Center:", carbonY)
    }
}
extension NSScreen {
    var displayId: CGDirectDisplayID? {
        guard let screenNumber = deviceDescription[NSDeviceDescriptionKey("NSScreenNumber")] as? NSNumber else {
            return nil
        }
        return CGDirectDisplayID(screenNumber.uint32Value)
    }
}
