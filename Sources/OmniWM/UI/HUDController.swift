import Cocoa
import SwiftUI

/// A glassmorphic overlay that displays current layer shortcuts.
public final class HUDController: NSWindowController {
    public static let shared = HUDController()
    
    private init() {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 600, height: 120),
            styleMask: [.borderless, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        
        window.isOpaque = false
        window.backgroundColor = .clear
        window.level = .statusBar
        window.hasShadow = true
        window.ignoresMouseEvents = true
        
        let contentView = HUDView()
        window.contentView = NSHostingView(rootView: contentView)
        
        super.init(window: window)
        
        // Center on screen
        if let screen = NSScreen.main {
            let x = (screen.frame.width - window.frame.width) / 2
            let y = screen.frame.height * 0.15 // Bottom area
            window.setFrameOrigin(NSPoint(x: x, y: y))
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func show(layerName: String, shortcuts: [(String, String)]) {
        // Implementation for dynamic shortcut updates
        window?.orderFrontRegardless()
    }
}

private struct HUDView: View {
    var body: some View {
        ZStack {
            VisualEffectView(material: .hudWindow, blendingMode: .withinWindow)
                .cornerRadius(25)
                .overlay(
                    RoundedRectangle(cornerRadius: 25)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
            
            HStack(spacing: 30) {
                VStack(alignment: .leading) {
                    Text("OMNI LAYER")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.white.opacity(0.4))
                    Text("Right Command")
                        .font(.system(size: 18, weight: .heavy))
                        .foregroundColor(.white)
                }
                
                Divider().frame(height: 40).background(Color.white.opacity(0.1))
                
                HStack(spacing: 15) {
                    ShortcutItem(key: "1-9", desc: "Workspaces")
                    ShortcutItem(key: "WASD", desc: "Reorder")
                    ShortcutItem(key: "Z", desc: "Zen")
                }
            }
            .padding(.horizontal, 40)
        }
    }
}

private struct ShortcutItem: View {
    let key: String
    let desc: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(key)
                .font(.system(size: 14, weight: .bold, design: .monospaced))
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.white.opacity(0.1))
                .cornerRadius(6)
            Text(desc)
                .font(.system(size: 10))
                .foregroundColor(.white.opacity(0.6))
        }
    }
}

