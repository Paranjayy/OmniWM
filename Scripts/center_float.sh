#!/bin/bash
# High-fidelity Atomic Centering (muni Swift Edition v9)

# 1. Toggle (God-Combo) muni
osascript -e 'tell application "System Events" to key code 5 using {shift down, control down, command down}'
sleep 0.6

# 2. Precision Resize & Center via Swift (muni accuracy)
/usr/bin/swift <<EOT
import AppKit

let targetWidth: CGFloat = 1194
let targetHeight: CGFloat = 947

// Get Main Screen Visible Area (Accounting for Menu Bar and Dock muni!)
if let screen = NSScreen.main {
    let screenFrame = screen.frame
    let visibleFrame = screen.visibleFrame
    
    // We want it horizontally centered and vertically at the "end" (bottom) muni
    let centerX = visibleFrame.origin.x + (visibleFrame.width - targetWidth) / 2
    
    // "End center" -> Bottom of visible area with a small 8px gap muni
    let centerY = visibleFrame.origin.y + 8 
    
    // Convert to Carbon/SystemEvents coordinates (Top-Left 0,0) muni
    // System Events uses (0,0) as top-left of the entire screen.
    // NSScreen uses (0,0) as bottom-left of the entire screen.
    
    let carbonX = centerX
    let carbonY = screenFrame.height - (centerY + targetHeight)
    
    // Apply via AppleScript (Called from Swift muni)
    let scriptString = "tell application \"System Events\" to tell first application process whose frontmost is true to set bounds of window 1 to {\\(carbonX), \\(carbonY), \\(carbonX + targetWidth), \\(carbonY + targetHeight)}"
    
    if let script = NSAppleScript(source: scriptString) {
        script.executeAndReturnError(nil)
    }
}
EOT
