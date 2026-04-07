import AppKit

if let screen = NSScreen.main {
    print("NSScreen main frame:", screen.frame)
    print("NSScreen main visibleFrame:", screen.visibleFrame)
}
print("CGMainDisplayBounds:", CGDisplayBounds(CGMainDisplayID()))
