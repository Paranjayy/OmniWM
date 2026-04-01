# OmniWM Keyboard Map

> **How it works:** Two physical "layer" keys on the right side of your keyboard activate all shortcuts.  
> You never need to touch Left Ctrl, Left Opt, Left Cmd, or Left Shift for any OmniWM action.  
> Karabiner-Elements intercepts `Right Option` and `Right Command` and silently injects the exact modifier combos OmniWM listens for.

---

## Layer Keys

| Physical Key | What It Does When Held | What It Does When Tapped |
|---|---|---|
| **Right Option** (`ROpt`) | Activates **Focus / Navigation** layer | Sends normal Right Option |
| **Right Command** (`RCmd`) | Activates **Workspace / WM** layer | Sends normal Right Command |

---

## RCmd Layer — Workspace & Window Management

| Physical Keys | Action | OmniWM Binding (injected) |
|---|---|---|
| `RCmd + 1–9` | Switch to workspace 1–9 | `Ctrl+Cmd+1–9` |
| `RCmd + Shift + 1–9` | Move window to workspace 1–9 | `Ctrl+Cmd+Shift+1–9` |
| `RCmd + W` | Move window/column **up** in bar | `Ctrl+Cmd+Up Arrow` |
| `RCmd + A` | Move column **left** in bar | `Ctrl+Cmd+Left Arrow` |
| `RCmd + S` | Move window/column **down** in bar | `Ctrl+Cmd+Down Arrow` |
| `RCmd + D` | Move column **right** in bar | `Ctrl+Cmd+Right Arrow` |
| `RCmd + F` | Toggle fullscreen | `Ctrl+Cmd+F` |
| `RCmd + Enter` | Toggle fullscreen (alias) | `Ctrl+Cmd+F` |
| `RCmd + O` | Toggle overview | `Ctrl+Cmd+O` |
| `RCmd + G` | Toggle focused window floating | `Ctrl+Cmd+G` |
| `RCmd + R` | Raise all floating windows | `Ctrl+Cmd+R` |
| `RCmd + Space` | Open command palette | `Ctrl+Cmd+Space` |
| `RCmd + Tab` | Workspace back and forth | `Ctrl+Cmd+Tab` |

---

## ROpt Layer — Focus & Navigation

| Physical Keys | Action | OmniWM Binding (injected) |
|---|---|---|
| `ROpt + W` | Focus window **up** | `Ctrl+Opt+Up Arrow` |
| `ROpt + A` | Focus window **left** | `Ctrl+Opt+Left Arrow` |
| `ROpt + S` | Focus window **down** | `Ctrl+Opt+Down Arrow` |
| `ROpt + D` | Focus window **right** | `Ctrl+Opt+Right Arrow` |
| `ROpt + Shift + W` | Move window **up** physically | `Ctrl+Opt+Shift+Up Arrow` |
| `ROpt + Shift + A` | Move window **left** physically | `Ctrl+Opt+Shift+Left Arrow` |
| `ROpt + Shift + S` | Move window **down** physically | `Ctrl+Opt+Shift+Down Arrow` |
| `ROpt + Shift + D` | Move window **right** physically | `Ctrl+Opt+Shift+Right Arrow` |
| `ROpt + 1–9` | Focus column/window by index in bar | `Ctrl+Opt+1–9` |
| `ROpt + Tab` | Focus previous window | `Ctrl+Opt+Tab` |
| `ROpt + Q` | Toggle Quake terminal | `Ctrl+Opt+\`` |
| `ROpt + Space` | Open **Raycast** | `Opt+Space` |
| `ROpt + Brightness ↑/↓` | Regular brightness step | `Brightness ↑/↓` |
| `ROpt + Shift + Brightness ↑/↓` | Fine-tune brightness (+1/16th) | `Opt+Shift+Brightness ↑/↓` |
| `ROpt + Volume ↑/↓` | Regular volume step | `Volume ↑/↓` |
| `ROpt + Shift + Volume ↑/↓` | Fine-tune volume (+1/16th) | `Opt+Shift+Volume ↑/↓` |

---

## Config Files

| File | Purpose |
|---|---|
| `~/.config/karabiner/karabiner.json` | Intercepts ROpt/RCmd, injects modifier combos |
| `~/.config/omniwm/settings.json` | Tells OmniWM which modifier combos trigger which action |

> **The two files must always be in sync.** Karabiner injects the exact modifier strings that `settings.json` listens for.

---

## Why Triple Modifiers?

OmniWM's bindings use `Control+Command+...` and `Control+Option+...` (triple modifier combos).  
Single/double modifier combos like `Option+1` or `Ctrl+Arrow` clash with browsers, editors, and other apps.  
Triple combos are effectively unused by any other app, so there's **zero shortcut conflict**.

You never physically press these — Karabiner injects them when you hold ROpt or RCmd.

---

## Updating Shortcuts

1. Edit `~/.config/karabiner/karabiner.json` — change what Karabiner injects
2. Edit `~/.config/omniwm/settings.json` — change what OmniWM listens for  
3. **Both must match** — the binding string in `settings.json` must equal what Karabiner sends
4. After editing `settings.json`: **OmniWM → Settings → Import Settings** → select the file
5. Karabiner picks up changes automatically (no restart needed)

---

## Known Quirks

- **ROpt tap**: Sends a raw Right Option. Avoid mapping `Option+letter` shortcuts to things you'd use while the ROpt layer is active.
- **Unhandled keys while ROpt is held**: Since ROpt physically holds `left_option`, any key NOT handled by a Karabiner rule will fire as `Option+that_key`. This is intentional — handled keys (WASD, 1-9, Space, etc.) all have explicit rules.
- **ROpt+Shift+1-9**: Not mapped (OmniWM has no "reorder windows in workspace by index" command natively).
