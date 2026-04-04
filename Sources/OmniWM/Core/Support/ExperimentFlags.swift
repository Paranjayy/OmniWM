import Foundation

/// Global experiment flags for the OmniWM God Build.
public enum OmniProfile: String, Codable, CaseIterable, Identifiable {
    case official = "Official"
    case godBuild = "Goated"

    public var id: String { rawValue }

    public var displayName: String {
        switch self {
        case .official: return "Official"
        case .godBuild: return "God Build (v47.2)"
        }
    }
}
@MainActor
public final class ExperimentFlags {
    public static let shared = ExperimentFlags()
    
    /// The current active profile. Set this to .godBuild for high-fidelity features.
    public var activeProfile: OmniProfile = .official
    
    /// Convenience getter for the 'God Build' features.
    public var isGodBuildActive: Bool {
        activeProfile == .godBuild
    }
    
    private init() {}
}
