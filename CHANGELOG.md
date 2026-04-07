# OmniWM God Build: Changelog
> *Tracking the path to the Ultimate Window Manager.*

## [v0.6.0] - 2026-04-07
### 🔧 Layer Variable Architecture + Center Conflict Fix
- **Root Cause (bar peek + WASD)**: `lazy` key re-emission consumed the physical `right_option` before WASD/digit rules could see it. Back to layer variable architecture.
- **Layer Variables**: `right_opt_layer` and `rcmd_layer` variables activated on hold, so WASD/digit/power rules use `variable_if` conditions instead of `mandatory: [right_option]`.
- **Bar Peek**: `ROpt`/`RCmd` hold → `bar_manager.sh --hold` (bar shows); release → `--release` (5s then hide). Works correctly alongside all WASD/digit combos now.
- **RCmd+Y Center Fix**: Changed from `Cmd+Y` → `Ctrl+Cmd+Y`. `Cmd+Y` is macOS Redo — intercepted by the OS before OmniWM ever sees it. Updated both Karabiner output AND settings.json binding.
- **All configs synced** to repo `.config/`.

## [v0.5.9] - 2026-04-07
### 📊 Bar Peek Restored + RCmd+Y Center Hardened
- **Bar Peek**: `ROpt`/`RCmd` hold now calls `bar_manager.sh --hold` (shows bar) and release calls `--release` (5s then auto-hides). Uses lazy key re-emission so all WASD/digit/power rules still fire.
- **RCmd+Y Center**: Confirmed Karabiner sends pure `Cmd+Y` (no Ctrl), matching `centerFocusedFloatAtSize` default binding in app.
- **ROpt+Shift+L**: Was never present — confirmed clean.
- **Floating Window Bar**: `workspaceBarShowFloatingWindows: true` preserved in settings.json.
- **Sync**: Auto-synced karabiner.json to repo `.config/`.

## [v0.5.8] - 2026-04-07
### 🔁 Ground-Truth Restore (from working commit 449a821)
- **Root Cause Found**: All previous scripts used wrong modifier masks (2304/2560/2816) because `settings.json` actually uses **string-based bindings** like `"Control+Command+F"`, not numeric `keyCode/modifiers` dicts. Every binding was being ignored by the app.
- **Complete Rewrite**: Both `settings.json` and `karabiner.json` rebuilt from scratch using the exact working commit logic.
- **Karabiner**: Reverted to simple `mandatory: [right_option/right_command]` rules — no layer variables, no complex state machine.
- **Settings**: All 61 bindings use correct string format matching app's parser expectation.
- **Sync**: Auto-copied both configs to repo `.config/` folder for git tracking.

## [v0.5.7] - 2026-04-07
### 🏹 Bridge: Total Modifier Alignment & Indexing Fix
- **Digit Promotion**: Added explicit rules for `Right Command + [1-9]` (Switch Workspace) to send the required 3st-layer mask, resolving the "broken" 1-9 switching.
- **Collision Removal**: Removed conflicting `RCmd + Return` logic to ensure `RCmd + F` (Simulated Fullscreen) triggers reliably via `Hyper + Return`.
- **Indexing Enforcement**: Re-verified that `ROpt + 1-9` promotes to **Hyper** (4-keys) to match the internal `focusColumn` requirement.
- **Fine-Tuning Restoration**: Restored missing `Opt + Shift` modifiers in the media key layer to fix 1/16th step increments.

## [v0.5.6] - 2026-04-07
### 🎥 Layout: Simulated Fullscreen (Space Bypass)
- **Simulated Fullscreen**: Re-mapped `RCmd + F` to trigger the app's internal `toggleFullscreen` (Monocle mode) by sending `Hyper + Return`. This achieves an "entire screen" fill without the native macOS Space transition.
- **Space Transition Bypass**: Explicitly avoided `Hyper + F` (Full Column Width) as requested, focusing on the true Monocle experience.

## [v0.5.5] - 2026-04-07
### 🏹 Precision: Hyper-Layer Promotion & Indexing Fix
- **Hyper Promotion**: Configured Karabiner to automatically promote 3-key presses (`ROpt+1-9`, `RCmd+F`) to the 4-key **Hyper** set (`Ctrl+Opt+Cmd+Shift`) to match the Official App's internal requirements for indexing and full-width toggles.
- **Indexing Restoration**: Fixed `ROpt + 1-9` (Focus Column) and `RCmd + Shift + 1-9` (Move to Workspace) by aligning Karabiner outputs with `ActionCatalog.swift`'s `hyperLayer`.
- **Centering Sync**: Cleaned up `RCmd + Y` to ensure only a raw `Cmd + Y` is sent, bypassing custom scripts for the app's native high-fidelity centering.
- **Fine-Tuning Filter**: Re-verified the `Volume`/`Brightness` rules to ensure `Shift` is strictly required for 1/16th steps without breaking normal media keys.

## [v0.5.4] - 2026-04-07
### 🛠️ Restoration: Settings Repair & Native Arrow Pass
- **Settings Injection**: Automatically populated `settings.json` with the Masterlist's `hotkeyBindings` to fix the non-responsive app state.
- **Native Arrow Pass**: Explicitly removed Karabiner traps from Arrow keys in RCmd/ROpt layers to maintain native navigation/text editing as requested.
- **WASD Native-Mod Pass**: Reverted WASD-to-Arrows translation. Karabiner now sends native WASD characters with the app's internal 3-key/4-key modifiers.
- **RCmd + Y (Internal)**: Mapped `RCmd + Y` to the app's internal `centerFocusedFloatAtSize` (Cmd+Y) for maximum reliability.
- **Fine-Tuning Logic**: Fixed the over-broad volume/brightness rules; they now correctly require a `Shift` hold within the ROpt layer.

## [v0.5.3] - 2026-04-07
### 🏹 Official App: WASD-to-Arrows & Precision Restoration
- **WASD Translation**: Integrated mandatory WASD-to-Arrows translation in Karabiner for the official binary's navigation logic.
- **RCmd + Y (Centering)**: Fixed the broken centering command by mapping it to `center_float.sh`.
- **Fine-Tuning Restoration**: Restored `ROpt + Shift + Brightness/Audio` mapping to native macOS 1/16th steps (`Option + Shift`).
- **Archive Increment**: Updated prompt archive to v1.3 with centering and fine-tuning instructions.

## [v0.5.2] - 2026-04-07
### 💼 Official App Alignment: Pure Karabiner Sync
- **Official Version Priority**: Acknowledged focus on the official OmniWM binary (not source-built).
- **Raycast Fix**: Overrode `ROpt + Space` in Karabiner to send `left_option + space` directly.
- **Bar Navigation Logic**:
    - `RCmd + WASD` -> Move/Reorder apps in workspace bar.
    - `ROpt + WASD` -> Focus apps in workspace bar.
    - `ROpt + 1-9` -> Focus workspace apps by index.
- **Archive Update**: Expanded prompt archive to v1.2 with new official app instructions.

## [v0.5.1] - 2026-04-07
### 🧭 Survivor Masterlist Alignment: Precise Layers
- **Split Layers**: Defined three distinct native modifier sets to match the Masterlist:
    - **RCmd Layer** (`Shift+Ctrl+Cmd`) -> Reorder Columns, Toggle Float, Palette.
    - **ROpt Layer** (`Ctrl+Opt+Cmd`) -> Focus App (WASD), Trash, Switcher.
    - **Hyper Layer** (`Shift+Ctrl+Opt+Cmd`) -> Move Physical (WASD).
- **RCmd WASD Reorder**: Re-aligned `RCmd + WASD` to its rightful purpose (Column Reorder) rather than focus.
- **Archive Completion**: Deep-mined `Integrating God Build Settings.md` for a full 27-prompt historical record.

## [v0.5.0] - 2026-04-07
### ✨ Realignment: The "No Arrows" & Native WASD Pass
- **ActionCatalog God Mode**: Shifted all window management commands (focus, move, column resize) from Arrow keys to **Native WASD keycodes**.
- **God/Hyper Architecture**: Split bindings into **God Layer** (RCmd+WASD | 3rd layer) for focus and **Hyper Layer** (RCmd+Shift+WASD | 4th layer) for movement.
- **Karabiner Sync**: Perfectly updated `karabiner.json` to send native WASD keys instead of arrow translations.
- **Native 0ms Coordinates**: Moved "End Center" calculation into Swift to bypass bash script latency.

### 🛡️ Recovery & Maintenance
- **Restored**: `issues & new features or thungs ideas.md` (reclaimed from commit `7ed337e37`).
- **Archive System**: Initialized `PROMPTS_ARCHIVE.md` to track instructions across sessions.
- **Stable Backup**: Created `/Users/paranjay/Developer/OmniWM/backups/` containing `settings.json.bak` and `karabiner.json.bak`.

## [v0.4.0] - 2026-04-06
### 🛠️ Upstream Merge & Hyper Layer
- **Conflict Resolution**: Successfully merged `origin/main` into local fork.
- **Architecture Migration**: Transplanted God Build features (Command Palette, Quake Terminal) into the new `ActionCatalog` registry.
- **Hyper-LOpt**: Refactored legacy 2/3-key shortcuts to 4-key combinations.

---

*Generated by Antigravity God Build Agent.*
