# OmniWM Keyboard Map (God-Build V47)

> **How it works:** Two physical "layer" keys on the right side of your keyboard activate all shortcuts.  
> You never need to touch Left Ctrl, Left Opt, Left Cmd, or Left Shift for any OmniWM action.  
> Karabiner-Elements intercepted `Right Option` and `Right Command` and silently injects the exact modifier combos OmniWM listens for.

---

## 🎹 Layer Keys

| Physical Key | What It Does When Held | What It Does When Tapped |
|---|---|---|
| **Right Option** (`ROpt`) | Activates **Focus / Window Control** layer | Sends normal Right Option |
| **Right Command** (`RCmd`) | Activates **Workspace / Layout** layer | Sends normal Right Command |

---

## 🧭 ROpt Layer — Focus & Precise Control
*The Right Option layer handles window-level actions and fine-tuning.*

| Physical Keys | Action | Control Layer |
|---|---|---|
| **`ROpt + WASD`** | **Focus Window** (Arrows) | `Ctrl+Opt+Arrows` |
| **`ROpt + Shift + WASD`** | **Move Window Physically** | `Ctrl+Opt+Shift+Arrows` |
| **`ROpt + 1–9`** | **Focus Window by Index** | `Ctrl+Opt+1–9` |
| **`ROpt + Tab`** | **Focus Previous Window** | `Ctrl+Opt+Tab` |
| **`ROpt + Q`** | **Toggle Quake Terminal** | `Ctrl+Opt+Grave` |
| **`ROpt + T`** | **Toggle Column Tabbed** | `Hyper + T` |
| **`ROpt + ,` / `.`** | **Cycle Column Width** | `Hyper + , / .` |
| **`ROpt + Backspace`** | **Trash Focused Window** | `Hyper + T` |
| **`ROpt + X`** | **Workspace Snapshot** | `Hyper + S` |
| **`ROpt + H`** | **Test Haptic Feedback** | `Hyper + H` |
| **`ROpt + Space`** | **Raycast** | `Option + Space` |
| **`ROpt + Shift + Vol/Bri`** | **Native 1/16th Fine Tuning** | `Opt+Shift+Media` |

---

## 🚀 RCmd Layer — Workspaces & System
*The Right Command layer handles big-picture management and system tools.*

| Physical Keys | Action | Control Layer |
|---|---|---|
| **`RCmd + 1–9`** | **Switch Workspace** | `Ctrl+Cmd+1–9` |
| **`RCmd + Shift + 1–9`** | **Move Window to Workspace** | `Ctrl+Cmd+Shift+1–9` |
| **`RCmd + WASD`** | **Reorder Columns** (Bar) | `Ctrl+Cmd+Arrows` |
| **`RCmd + F / Enter`** | **Toggle Fullscreen** | `Ctrl+Cmd+F` |
| **`RCmd + O`** | **Workspace Overview** | `Ctrl+Cmd+O` |
| **`RCmd + G`** | **Toggle Focused Float** | `Ctrl+Cmd+G` |
| **`RCmd + R`** | **Raise All Floating** | `Ctrl+Cmd+R` |
| **`RCmd + Space`** | **Command Palette** | `Ctrl+Cmd+Space` |
| **`RCmd + B`** | **Toggle Workspace Bar** | `Ctrl+Cmd+B` |
| **`RCmd + L`** | **Toggle Workspace Layout** | `Hyper + L` |

---

## 🛡️ The "Hyper-Lock" (Security Layer)
Some shortcuts (like `⌥T`) are "annoying" because they clash with common apps. To fix this, the **God Build** moves these to the **Hyper Modifier** (`Control+Option+Shift+Command`). 

1. **OmniWM** is configured to ONLY listen for the Hyper-version of these keys.
2. **Karabiner** ONLY sends the Hyper-version when you use the Right-side layers.
3. **The Result**: You can never trigger these by accident using your Left-side keys.

---

## 🏁 Roadmap (Upcoming Features)
*   **Warp Switcher**: Hold `RCmd` for a visual window grid overview.
*   **Snapshot Gallery**: Navigate your workspace history with visual thumbnails.
*   **Trash Stack**: A glassmorphic tray to recover recently closed windows.
*   **Omniglide**: Smooth haptic feedback for window transitions.

---

## 🛠️ Maintenance
*   **Settings Persistence**: Stored in `~/.config/omniwm/settings.json`.
*   **Modifier Persistence**: Stored in `~/.config/karabiner/karabiner.json`.
*   **Sync Status**: Ensure `ActiveProfile` is set to `official` to use these sanitized paths.
