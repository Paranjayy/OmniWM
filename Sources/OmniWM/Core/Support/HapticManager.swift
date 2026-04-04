import Cocoa

/// Manages haptic feedback for OmniWM interactions.
/// Allows for different physical "rhythms" to represent different actions.
@MainActor
public final class HapticManager {
    public static let shared = HapticManager()
    
    private let performer = NSHapticFeedbackManager.defaultPerformer
    
    private init() {}
    
    public enum FeedbackType {
        case alignment       // Legacy/Central mapping
        case softTick        // Subtle confirmation (e.g. window snap)
        case mediumPulse     // Layer switch (e.g. RCmd held)
        case sharpClick      // Action execution (e.g. Workspace switch)
        case pebble          // Lightweight "click" confirm on ROpt tap
        case ripple          // Success rhythm for window move
        case error           // Failed action
    }
    
    public func trigger(_ type: FeedbackType) {
        switch type {
        case .alignment, .softTick:
            performer.perform(.alignment, performanceTime: .now)
        case .mediumPulse:
            performer.perform(.levelChange, performanceTime: .now)
        case .sharpClick:
            performer.perform(.generic, performanceTime: .now)
        case .pebble:
            // High-speed tick for pebble effect
            performer.perform(.alignment, performanceTime: .now)
        case .ripple:
            // Multi-pulse feedback
            performer.perform(.levelChange, performanceTime: .now)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                self.performer.perform(.alignment, performanceTime: .now)
            }
        case .error:
            performer.perform(.generic, performanceTime: .now)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.performer.perform(.generic, performanceTime: .now)
            }
        }
    }
}
