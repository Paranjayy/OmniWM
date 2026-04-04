# 🛡️ THE OMNIWM GOD-BUILD MANIFESTO

> **Mission**: Create the ultimate ergonomic power-user layout for macOS while preserving 100% of standard application shortcuts.

## 🏛️ Architecture & Philosophy

### 1. The "Forbidden" Left Side
All **Left-hand modifiers** (`LOpt`, `L⌃`, `L⌘`, `L⇧`) are strictly reserved for native macOS and third-party application usage.  
**DO NOT** map any OmniWM-specific actions to these modifiers directly unless they are the "official" un-sanitized defaults.

### 2. The Power-3 Level (Isolation)
To avoid clashing with common app hotkeys (like `⌥T` for Tabbed), we use the **Power-3 Modifiers** (`Control + Option + Command`).
*   Historically called "Hyper", this term is discouraged in this build as it traditionally implies 4 modifiers (`⌃⌥⌘⇧`).
*   The **3-modifier combo** (`⌃⌥⌘`) is effectively unused by almost all macOS apps and provides perfect isolation.
*   The **God Build** MUST map "annoying" defaults to this combo in `settings.json`.

### 3. Right-Side Layering (Karabiner)
The user should only ever press **Right Option (`ROpt`)** or **Right Command (`RCmd`)** to trigger OmniWM actions.
*   **ROpt Layer**: Focus, navigation, and window-level controls.
*   **RCmd Layer**: Workspaces, layout switching, and system-level actions.
*   Karabiner handles the "secret" injection of the Power-3 combos.

### 4. Haptic Feedback (Tactile Pacing)
This build prioritizes **Tactile Orchestration**. Every major action should trigger a specific haptic rhythm:
*   **Alignment/Snap**: `softTick`
*   **Reorder/Move**: `ripple`
*   **Success/Switch**: `sharpClick`
*   **Error/Conflict**: `doubleSharp`

---

## 🏗️ Future Builder Guidelines
- **No placeholders**: Every new HUD or feature MUST use modern glassmorphism (`.hudWindow` material).
- **No 4-modifier "Hyper"**: Stick to the 3-modifier `Power Layer` to reduce hand strain on standard keyboards.
- **Sync Everything**: If you change a command in the source (`DefaultHotkeyBindings.swift`), you MUST also update the user's `settings.json` and `karabiner.json` to match.
- **Document the "God Mode"**: Add all new features to the `SHORTCUTS.md` master guide.

*Created by Antigravity for the God-Build V47.2 Iteration.*

---

## 🛠️ GhosttyKit (Missing Binary) Recovery
The Quake Terminal dependency (`GhosttyKit.xcframework`) is typically NOT committed to git because it's a platform-specific binary. If your build fails with "target 'GhosttyKit' does not contain a binary artifact":

1.  **Build libghostty.a**: 
    Clone `github.com/ghostty-org/ghostty` and follow the build steps (Zig) to generate a universal or arm64 library. 
2.  **Restore the Framework**: 
    Place the static library into:
    `Frameworks/GhosttyKit.xcframework/macos-arm64_x86_64/libghostty.a`
3.  **Restore the Code**: 
    Un-comment the Quake and Ghostty references in `Package.swift` and `WMController.swift` to re-enable the terminal. 
