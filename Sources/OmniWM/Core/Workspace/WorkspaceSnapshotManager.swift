import Foundation
import CoreGraphics

/// Manages workspace snapshots for instant layout retrieval.
/// Observable — UI updates automatically when snapshots are captured.
@MainActor
@Observable
public final class WorkspaceSnapshotManager {
    static let shared = WorkspaceSnapshotManager()

    public struct Snapshot: Codable, Identifiable {
        public let id: UUID
        public let timestamp: Date
        public let workspaceId: String
        public let layoutData: String // JSON representation of window tokens and frames

        public var formattedTimestamp: String {
            let formatter = DateFormatter()
            formatter.dateStyle = .none
            formatter.timeStyle = .medium
            return formatter.string(from: timestamp)
        }
    }

    private(set) var snapshots: [String: [Snapshot]] = [:]   // workspaceId -> [Snapshots]
    /// Total count across all workspaces
    var totalCount: Int { snapshots.values.reduce(0) { $0 + $1.count } }

    private let storageURL: URL? = {
        guard let dir = FileManager.default.urls(
            for: .applicationSupportDirectory, in: .userDomainMask
        ).first else { return nil }
        let folder = dir.appendingPathComponent("OmniWM/Snapshots", isDirectory: true)
        try? FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        return folder.appendingPathComponent("workspace_snapshots.json")
    }()

    private init() {
        loadFromDisk()
    }

    // MARK: - Capture

    public func capture(workspaceId: String, layoutJSON: String = "{}") {
        captureInternal(workspaceId: workspaceId, layoutJSON: layoutJSON, silent: false)
    }

    /// Capture a snapshot without triggering haptics — used for background auto-snapshots.
    public func captureAuto(workspaceId: String, layoutJSON: String = "{}") {
        captureInternal(workspaceId: workspaceId, layoutJSON: layoutJSON, silent: true)
    }

    private func captureInternal(workspaceId: String, layoutJSON: String, silent: Bool) {
        let snapshot = Snapshot(
            id: UUID(),
            timestamp: Date(),
            workspaceId: workspaceId,
            layoutData: layoutJSON
        )
        var current = snapshots[workspaceId, default: []]
        current.append(snapshot)
        // Keep max 20 snapshots per workspace to avoid unbounded growth
        if current.count > 20 { current.removeFirst(current.count - 20) }
        snapshots[workspaceId] = current
        saveToDisk()
        if !silent {
            HapticManager.shared.trigger(.sharpClick)
        }
    }

    // MARK: - Query

    public func snapshots(for workspaceId: String) -> [Snapshot] {
        snapshots[workspaceId] ?? []
    }

    public func latestSnapshot(for workspaceId: String) -> Snapshot? {
        snapshots[workspaceId]?.last
    }

    // MARK: - Delete

    public func deleteSnapshot(id: UUID, in workspaceId: String) {
        snapshots[workspaceId]?.removeAll { $0.id == id }
        if snapshots[workspaceId]?.isEmpty == true {
            snapshots.removeValue(forKey: workspaceId)
        }
        saveToDisk()
    }

    public func deleteAll(for workspaceId: String) {
        snapshots.removeValue(forKey: workspaceId)
        saveToDisk()
    }

    // MARK: - Persistence

    private func saveToDisk() {
        guard let url = storageURL else { return }
        let allSnapshots = snapshots.values.flatMap { $0 }
        if let data = try? JSONEncoder().encode(allSnapshots) {
            try? data.write(to: url, options: .atomic)
        }
    }

    private func loadFromDisk() {
        guard let url = storageURL,
              let data = try? Data(contentsOf: url),
              let loaded = try? JSONDecoder().decode([Snapshot].self, from: data)
        else { return }
        for snapshot in loaded {
            snapshots[snapshot.workspaceId, default: []].append(snapshot)
        }
    }
}
