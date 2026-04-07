#!/bin/bash
# center_float.sh
# Right Command + Y: Float, Resize (1194×947), and Center focused window
# Focus-Follow-Mouse safe: captures target process BEFORE any key events.

WIN_W=1194
WIN_H=947

# ── Step 1: Capture target process name BEFORE any action ───────────────────
# This is immune to Focus-Follows-Mouse shifting focus mid-script.
TARGET=$(osascript -e \
    'tell application "System Events" to return name of (first application process whose frontmost is true)')

if [ -z "$TARGET" ]; then
    echo "center_float: could not identify frontmost app" >&2
    exit 1
fi

# ── Step 2: Toggle floating via OmniWM (Shift+Ctrl+Cmd+G) ──────────────────
# key code 5 = G
osascript -e \
    'tell application "System Events" to key code 5 using {shift down, control down, command down}'

sleep 0.25

# ── Step 3: Resize & center the CAPTURED process (ignores current focus) ─────
osascript << APPLESCRIPT
set WIN_W to $WIN_W
set WIN_H to $WIN_H
set TARGET_NAME to "$TARGET"

-- Get screen dimensions
tell application "Finder"
    set screenBounds to bounds of window of desktop
    set screenW to item 3 of screenBounds
    set screenH to item 4 of screenBounds
end tell

set winX to (screenW - WIN_W) / 2
set winY to ((screenH - WIN_H) / 2) + 25

-- Target the ORIGINAL process by name, not the currently focused one
tell application "System Events"
    try
        set targetProc to first application process whose name is TARGET_NAME
        set frontWin to first window of targetProc
        set position of frontWin to {winX as integer, winY as integer}
        set size of frontWin to {WIN_W, WIN_H}
    on error errMsg
        -- Fallback: try frontmost if name lookup fails (e.g. Electron apps)
        set frontApp to first application process whose frontmost is true
        set frontWin to first window of frontApp
        set position of frontWin to {winX as integer, winY as integer}
        set size of frontWin to {WIN_W, WIN_H}
    end try
end tell
APPLESCRIPT
