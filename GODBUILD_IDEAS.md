better touch tool config - '/Users/paranjay/Library/Application Support/BetterTouchTool' 
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
- [x] Cmd+Y: Instant Float + 1194x947pt resize + Center shortcut.

---

## �� Tier 9 — LLM & Agentic Integration
> *The "Beyond Window Management" Spectrum.*

### 21. LLM Context Bridge (muni)
- Script to dump current window metadata (titles, bundleIds, layout) to `/tmp/context.json`.
- Pipe this context to Raycast/BTT agents to perform semantic window management.

### 22. "Intent-Based" Layouts
- "Arrange my screen for React development" → LLM moves IDE to main, Browser to right, DevTools to bottom.
- Uses the IPC Playground (Tier 7) to command OmniWM.

### 23. AI Activity Digest
- HUD that summarizes what you've worked on across all workspaces (using LLM analysis of window titles).

---

## 💎 Tier 10 — The "muni" Specials (Creative Layer)
> *Bespoke UX refinements for the God Build connoisseur.*

### 24. RCmd+Y: The "God Float" Toggle (muni)
- Intelligent toggle: First press floats & centers at 1194x947. Second press unfloats & restores to tiling.
- **Implemented:** Pure script layer for binary compatibility.

### 25. The "Zen Dimmer" (Concept)
- Hold `ROpt + Z` → Use AppleScript to briefly set Gamma or Desktop Brightness to 20% for everything *except* the frontmost window. 
- Creates a "Spotlight" effect for deep focus.

### 26. Intelligent Layer HUD
- Small, vertical pixel-bar on the far right of the screen that changes color based on which RCmd/ROpt layer is active (Purple for God, Blue for Official).

---

## 🔱 Tier 11 — The Karabiner & BTT Nexus
> *High-fidelity automation and visualization layer.*

### 27. Dynamic Shortcut HUD (muni)
- Use BTT's **Floating Webview** to show a "Cheat Sheet" that changes in real-time based on your Karabiner Layer (**RCmd**, **ROpt**).
- **How:** Karabiner `shell_command` calls BTT AppleScript to update the HUD content.

### 28. "Ghostty Whisperer" (muni)
- Hold `RCmd + G` → Use BTT to dim the wallpaper and bring Ghostty to focus in a 90% wide central overlay. 
- Releases focus and restores wallpaper immediately on key release.

### 29. Contextual Tap-Sequences
- **Single Tap RCmd:** Toggle Workspace Bar.
- **Double Tap RCmd:** Open OmniWM Command Palette.
- **Triple Tap RCmd:** Engage Zen Mode (Mute all notifications + Hide tiling gaps).

### 30. Smart Profile Switching
- Use BTT to detect when you open a "Hobby" app (e.g. Spotify, Discord) and automatically tell OmniWM to switch to the **"Relax"** profile (bigger gaps, softer colors).

---

## 🔱 Tier 12 — The Bridge (Karabiner & BetterTouchTool)
> *The unified input and haptic layer.*

### 31. Universal Hyper (Karabiner)
- Map `Caps Lock` to `Cmd + Opt + Ctrl + Shift` (Hyper Key).
- Use this to easily trigger the new 4-key "Hyper-LOpt" shortcuts in OmniWM.
- `Hyper + 1-9` → Workspace Switching.
- `Hyper + Arrows` → Window Navigation (Niri-style).

### 32. Vim Mode Universal (Karabiner)
- `Hyper + H/J/K/L` mapped directly to OmniWM's focus commands for frictionless movement.

### 33. Gesture Control & Haptics (BTT)
- **3-Finger Swipe**: Map 3-finger horizontal swipes to `Hyper + Left/Right` for workspace switching.
- **Trigger Trackpad Haptics**: Kick the trackpad on every OmniWM workspace transition or window resize.

### 34. Notch Integration (BTT)
- Show the current OmniWM workspace index at the notch center (using BTT's Notch functionality).

### 35. Window Snapping Fallback
- Use BTT center-docking as a fallback for the "God-Float" script if native WM state is inconsistent.
