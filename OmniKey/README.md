# OmniKey Guide for Paranjay 🔑

## How it works (The "Modifier-Tap" secret)

Karabiner-Elements is like a brain for your keyboard. We're using a technique called **Mod-Tap**:
1. **Tap it** (fast) → It sends the normal key (`Right Option`, `Right Command`).
2. **Hold it** → It activates a **Layer**.

---

## 🛠 Your Fixed Layers (v7)

### 1. The Navigation Layer (`Right Option` held)
> **Fix for Fine-Tuning**: If you hold `Shift` + `Right Option`, Karabiner **skips** the layer. Your volume/brightness fine-tuning works perfectly again.

- **Hold `Right Opt` + `H/J/K/L`** → Word Navigation & Page Scrolling
- **Hold `Right Opt` + `U/O`** → Line Start/End

### 2. The OmniWM Layer (`Right Command` held)
> Use WASD to fly through your windows.

- **`RCmd` + `W/A/S/D`** → Focus window (Directional)
- **`RCmd` + `Shift` + `W/A/S/D`** → **MOVE** window (Directional) — *NEW!*
- **`RCmd` + `F`** → **Toggle Fullscreen** — *NEW!*
- **`RCmd` + `L`** → **Toggle Tiling Layout** — *NEW!*
- **`RCmd` + `1–9`** → Switch Workspace
- **`RCmd` + `Tab`** → Back and Forth

---

## 🚀 The 3 Ideas We're Building

### 1. Context-Aware Layers (Built-in)
Right now, `RCmd + 1/2/3` switches **browser tabs** in Arc, but **workspaces** everywhere else. No conflicting shortcuts ever.

### 2. The OmniKey Editor (GUI)
A visual macOS app where you'll drag keys onto a keyboard map.
- **Status**: Sidebar and Keyboard map are done.
- **Next**: Exporting your changes directly to Karabiner.

### 3. Hyper Sequences (The Leader Key)
Tap `Caps Lock` then `A` then `A` to open Arc.
Tap `Caps Lock` then `W` then `1` to move the window to workspace 1.
It's like having infinite shortcuts on just a few keys.

---

## 💡 OmniWM Specific Ideas

- **Smart Floating**: Hold `RCmd` + `G`. It can "pop" the current window into a centered floating box (great for calculators, notes).
- **Sticky / Always-on-top**: Since OmniWM is your project, we can add a native command for "Stay on Top" and map it to `RCmd + T`.
- **Window Grouping**: Tag windows with `Hyper + T` and pull them all to you with `Hyper + G`.

**Test this now:** Hold `Right Cmd` and press `F` to maximize! Or hold `Right Cmd + Shift + W` to move a window UP.
