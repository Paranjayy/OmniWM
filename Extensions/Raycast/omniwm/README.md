# OmniWM Raycast Extension

Control OmniWM window manager directly from Raycast.

## Features

- 🔍 **Search Windows**: Quickly find and focus any managed window across all workspaces.
- 🪟 **Switch Workspace**: Instantly jump to any active or inactive workspace.
- 🛠️ **Toggle Bar**: Show or hide the OmniWM workspace bar with a single command.
- ⌨️ **Visualize Shortcuts**: Display and search your keyboard shortcuts parsed directly from `karabiner.json`.
- 🚀 **Run Command**: Execute any native OmniWM command (ping, focus, move, etc.) without needing a hotkey.

## Setup

1. **Install OmniWM**: Ensure the official OmniWM app is installed in `/Applications/OmniWM.app`.
2. **Build the Extension**:
   ```bash
   cd Extensions/Raycast/omniwm
   npm install
   npm run dev
   ```
3. **CLI Path**: The extension expects `omniwmctl` to be available at `/Applications/OmniWM.app/Contents/MacOS/omniwmctl`. If your path is different, update the `CTL_BIN` constant in the source files.

## Development

This extension uses the NDJSON IPC surface provided by OmniWM. It communicates via the `omniwmctl` CLI bridge.

### Commands

| Command | Description | CLI Equivalent |
|---------|-------------|----------------|
| `search-windows` | List and focus windows | `omniwmctl query windows` |
| `switch-workspace` | Jump to workspace | `omniwmctl command switch-workspace` |
| `toggle-bar` | Toggle workspace bar | `omniwmctl command toggle-workspace-bar` |

---

Developed as part of the OmniWM God Build.
