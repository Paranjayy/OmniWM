# OmniWM God Build — Ideas & Future Roadmap
> Last updated: 2026-04-04. Exams mode — resume after 🎓
> **30+ ideas across 6 tiers. Start with Tier 1.**

---

## 🔴 Tier 1 — Critical Fixes (do first)

### 1. Warp Switcher: Real Focus on Click
- Clicking an entry currently dismisses the HUD but does **not** focus the window.
- **Fix:** Pass `WindowToken` through `WarpSwitcherEntry`, call `controller.focusWindow(token)` on tap.
- Already have the architecture — just threading the token is missing.

### 2. Warp Switcher: Arrow Key Navigation
- `← →` cycles entries, `↑ ↓` cycles if grouped by workspace.
- Focused entry gets a yellow highlight ring.
- `Return` = focus, `Escape` = dismiss.

### 3. Warp Switcher: Real Window Titles
- Currently shows frame size (640×480) instead of window title.
- **Source:** `workspaceManager.entries(in:)` → AX title attribute on `axRef`.
- Subtitle line: "Arc — 3 Spaces, Google — Search" etc.

### 4. Build System Polish
- Fix `swift build` sandboxing issues to allow agent-side compilation.
- Ensure `Scripts/build_app.sh` is the source of truth for release builds.

---

## 🟠 Tier 2 — Power UX (high value, resume here)

### 5. Trash Stack: Status Bar Badge
- Show `🗑 2` badge in the OmniWM menu bar icon when stack is non-empty.
- `TrashStackManager` is already `@Observable` — just needs a status bar observer.

### 6. Warp Switcher: Live Search Filter
- Search bar at top of HUD — typing `arc` filters to Arc windows in realtime.
- Already have the grid architecture — filter the `entries` array by `.appName.contains(query)`.

### 7. Trash Stack: Named Parking Slots
- `⌃⌥⌘T` → prompt for a slot name (e.g. "slack", "docs").
- `⌃⌥⌘P` → quick-pick list of named slots, not just blind LIFO pop.
- Turns the trash into a **reversible parking lot**.

### 8. God Build Onboarding Coach Mark
- First time profile switches to God Build → floating HUD with key combos.
- Lists all 5 Power-3 shortcuts with icons.

---

## 🟡 Tier 3 — Workflow Automation

### 9. App Launcher Layer (`⌃⌥⌘ + letter`)
- Extend the Power-3 layer: `⌃⌥⌘A` → focus/launch Arc, `⌃⌥⌘G` → Ghostty, etc.
- Configurable per-user in God Build settings tab.

### 10. Picture-in-Picture Mode (`⌃⌘P`)
- Macro: float focused window → resize to 30% → snap to bottom-right corner.
- Perfect for video calls / streams while coding.

### 11. Context Profiles
- Named profiles: "Deep Work" (no bar, gaps=0), "Presentation" (big gaps, large bar).
- Switch with `⌃⌥⌘ + number`.

### 12. Focus Mode Timer (`⌃⌘T`)
- 25-min Pomodoro timer in the workspace bar.
- On start: engages Zen Mode (hides non-focused windows).

---

## 🟢 Tier 4 — Visual Polish

### 13. Warp Switcher: Live Window Previews
- `CGWindowListCreateImage` to render thumbnails of each window.
- Show as blurred background behind the app icon.

### 14. Workspace Minimap HUD (`⌃⌥⌘M`)
- Tiny floating panel showing all workspaces as miniature grids.
- Click to teleport focus there.

### 15. Trash Stack: Animated Eject
- Brief "fly to corner" animation when a window is trashed.

---

## 🔵 Tier 5 — System Integration

### 16. Apple Shortcuts Integration
- Register OmniWM actions as `AppIntents`.
- "Trash focused window" as a Shortcut action.

### 17. iCloud Sync for Snapshots
- Sync snapshots across machines using iCloud Drive storage.

### 18. Raycast Extension
- Raycast plugin with commands: Switch Profile, List Trashed Windows, Restore Snapshot.

---

## 🟣 Tier 6 — Moonshots

### 19. AI Layout Suggestions
- Suggest optimal workspace assignments based on usage patterns.
- Runs entirely on-device with CoreML.

### 20. Voice Commands
- "Hey OmniWM, trash this window" / "Warp to Arc".

### 21. Haptic Rhythm Composer
- Settings UI to pick custom haptic patterns per action.

---

## 💠 Tier 7 — Developer Experience (DX)

### 22. OmniWM IPC Playground
- A lightweight web-based interface or Raycast view to send test IPC commands to OmniWM.
- "Try Tiling," "Force Reload Settings," "Ping Layout Manager."

### 23. Configuration Hot-Reload with Visual Feedback
- Brief HUD overlay when `settings.json` is saved: "Config Reloaded (v2.1) ✨".
- Prevents wondering if changes actually applied.

### 24. Live Layout Debugger HUD
- Key combo to show bounding boxes, gap sizes, and "focus priority weight" for all windows.
- Invaluable for debugging کیوں a certain window won't tile.

### 25. Plugin System: Lua or JS Scripts
- Allow the power-user to script their own tiling logic in a simple `.lua` or `.js` file.
- `onWindowCreated(window) { if window.name == "Slack" then window.float() }`.

---

## 🌀 Tier 8 — Experimental Layout Engines

### 26. "Stacked" Cards Layout (`RCmd + L`)
- Like Safari tabs: windows overlap each other at the top, only the active one is fully visible.
- Perfect for laptop screens where tiling many windows is too cramped.

### 27. Floating "Pinned" Windows
- A way to pin a small window (calculator, terminal) always-on-top, and it stays visible even when switching workspaces.

### 28. Logical Workspace Chaining
- Automatically move windows from Workspace 1 to 2 if 1 gets too crowded (e.g., > 4 columns).

### 29. Workspace "Moods"
- Automate wallpapers, focus mode, and gaps based on workspace context (Work/Life/Code).

### 30. Smart Native Tab Integration
- Group windows into native macOS tabs automatically (e.g., pull all Finder windows into one tabbed window).


- [x] Warp Switcher live app list.
- [x] TrashStackManager `@Observable`.
- [x] WorkspaceSnapshotManager on-disk persistence.
- [x] God Build sidebar & profile callouts.
- [x] Custom build script & settings patcher.
- [x] Root cleaned & configs synced.
