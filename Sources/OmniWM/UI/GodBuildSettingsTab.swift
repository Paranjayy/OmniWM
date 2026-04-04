import SwiftUI

struct GodBuildSettingsTab: View {
    @Bindable var settings: SettingsStore
    @Bindable var controller: WMController

    // Observe the trash stack for a live count badge
    private var trashCount: Int { TrashStackManager.shared.count }

    var body: some View {
        Form {
            // ── Profile status header ──────────────────────────────────────
            Section {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "crown.fill")
                            .font(.system(size: 32))
                            .foregroundStyle(settings.activeProfile == .godBuild ? .yellow : .secondary)
                            .shadow(color: settings.activeProfile == .godBuild ? .yellow.opacity(0.5) : .clear, radius: 4)

                        VStack(alignment: .leading, spacing: 4) {
                            Text("God Build v47.2")
                                .font(.title.bold())
                            HStack(spacing: 6) {
                                Circle()
                                    .frame(width: 8, height: 8)
                                    .foregroundStyle(settings.activeProfile == .godBuild ? .green : .red)
                                Text(settings.activeProfile == .godBuild
                                    ? "ACTIVE — ergonomic features enabled"
                                    : "INACTIVE — switch in General › Application Profile")
                                    .font(.caption.bold())
                                    .foregroundStyle(settings.activeProfile == .godBuild ? .green : .red)
                            }
                        }
                    }
                    .padding(.vertical, 8)
                }
            }
            .listRowBackground(Color.clear)

            // ── Ergonomic features ─────────────────────────────────────────
            Section("Ergonomic Power-User Features") {
                Toggle(isOn: $settings.warpSwitcherEnabled) {
                    VStack(alignment: .leading, spacing: 4) {
                        Label("Warp Switcher", systemImage: "rectangle.3.group")
                            .font(.headline)
                        Text("Press ⌃⌥⌘W to open a glassmorphic window grid. Real app icons, keyboard-dismissable.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .disabled(settings.activeProfile != .godBuild)

                Toggle(isOn: $settings.windowTrashEnabled) {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Label("Window Trash Stack", systemImage: "trash.fill")
                                .font(.headline)
                            if trashCount > 0 {
                                Text("\(trashCount)")
                                    .font(.caption2.bold())
                                    .foregroundStyle(.white)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(Color.orange)
                                    .clipShape(Capsule())
                            }
                        }
                        Text("⌃⌥⌘T parks the focused window off‑screen. ⌃⌥⌘P restores the last one.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .disabled(settings.activeProfile != .godBuild)

                if trashCount > 0 {
                    LabeledContent("Trash Stack") {
                        HStack(spacing: 8) {
                            Text("\(trashCount) window\(trashCount == 1 ? "" : "s") parked")
                                .foregroundStyle(.secondary)
                                .font(.caption)
                            Button("Pop One") {
                                controller.popLastTrashedWindow()
                            }
                            .buttonStyle(.bordered)
                            .controlSize(.small)
                        }
                    }
                }
            }

            // ── Session reliability ────────────────────────────────────────
            Section("System Reliability") {
                Toggle(isOn: $settings.sessionSnapshotEnabled) {
                    VStack(alignment: .leading, spacing: 4) {
                        Label("Session Persistence", systemImage: "camera.aperture")
                            .font(.headline)
                        Text("Press ⌃⌥⌘S to snapshot workspace layout. Snapshots persist across restarts.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .disabled(settings.activeProfile != .godBuild)
            }

            // ── Architecture status ────────────────────────────────────────
            Section("Architecture Status") {
                LabeledContent {
                    Text("ACTIVE")
                        .font(.caption.bold())
                        .foregroundStyle(.green)
                } label: {
                    Label("Niri Engine", systemImage: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                }

                LabeledContent {
                    Text("STUBBED")
                        .font(.caption.bold())
                        .foregroundStyle(.orange)
                } label: {
                    Label("Ghostty Terminal", systemImage: "exclamationmark.triangle.fill")
                        .foregroundStyle(.orange)
                }
            }

            // ── Default shortcuts reference ────────────────────────────────
            Section("God Build Shortcuts (Default)") {
                ShortcutRow(keys: "⌃⌥⌘ W", action: "Open Warp Switcher")
                ShortcutRow(keys: "⌃⌥⌘ T", action: "Trash Focused Window")
                ShortcutRow(keys: "⌃⌥⌘ P", action: "Pop Last Trashed Window")
                ShortcutRow(keys: "⌃⌥⌘ S", action: "Capture Workspace Snapshot")
                ShortcutRow(keys: "⌃⌥⌘ H", action: "Test Haptic Feedback")
            }

            // ── Footer ─────────────────────────────────────────────────────
            Section {
                VStack(alignment: .center, spacing: 6) {
                    Text("All shortcuts use the 3-modifier Power Layer (⌃⌥⌘) defined in the God Build Manifesto.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                }
            }
            .listRowBackground(Color.clear)
        }
        .formStyle(.grouped)
    }
}

private struct ShortcutRow: View {
    let keys: String
    let action: String

    var body: some View {
        LabeledContent(action) {
            Text(keys)
                .font(.system(size: 12, weight: .semibold, design: .monospaced))
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(Color.accentColor.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 6))
        }
    }
}
