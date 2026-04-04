import Foundation

struct WindowSessionEntry: Codable {
    let bundleId: String
    let workspaceName: String
    let isFloating: Bool
    let title: String?
}

struct SessionSnapshot: Codable {
    var schemaVersion: Int
    var entries: [WindowSessionEntry]

    static let currentSchemaVersion = 1

    init(entries: [WindowSessionEntry]) {
        schemaVersion = Self.currentSchemaVersion
        self.entries = entries
    }
}

/// Mutable helper used during the startup rescan to match and consume session entries.
/// Each entry is consumed at most once so that multiple windows from the same app are
/// each matched to a distinct saved workspace assignment.
final class SessionRestoreLookup {
    private var unmatched: [String: [WindowSessionEntry]]

    init(snapshot: SessionSnapshot) {
        var grouped: [String: [WindowSessionEntry]] = [:]
        for entry in snapshot.entries {
            grouped[entry.bundleId, default: []].append(entry)
        }
        unmatched = grouped
    }

    /// Returns the best-matching workspace ID for the given bundleId/title, consuming
    /// the matched entry so it cannot be used again.
    @MainActor
    func consumeMatch(
        for bundleId: String?,
        title: String?,
        in workspaceManager: WorkspaceManager
    ) -> WorkspaceDescriptor.ID? {
        guard let bundleId,
              var candidates = unmatched[bundleId],
              !candidates.isEmpty
        else { return nil }

        let index: Int
        if let title, !title.isEmpty,
           let titleMatch = candidates.indices.first(where: { candidates[$0].title == title })
        {
            index = titleMatch
        } else {
            index = 0
        }

        let entry = candidates.remove(at: index)
        if candidates.isEmpty {
            unmatched.removeValue(forKey: bundleId)
        } else {
            unmatched[bundleId] = candidates
        }

        return workspaceManager.workspaceId(for: entry.workspaceName, createIfMissing: false)
    }
}
