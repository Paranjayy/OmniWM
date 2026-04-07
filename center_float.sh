#!/bin/bash
# center_float.sh
# Float, Resize (1194×947), Center — fully Focus-Follows-Mouse safe.
# Strategy: WARP mouse to target window center before sending any hotkey,
# so OmniWM's FFM guarantees the right window gets floated.

WIN_W=1194
WIN_H=947

# ── Step 1: Get screen dimensions (JXA, zero app activation) ─────────────────
read SCREEN_W SCREEN_H < <(osascript -l JavaScript -e \
    'ObjC.import("AppKit"); var f=$.NSScreen.mainScreen.frame; f.size.width+" "+f.size.height;')
SCREEN_W=${SCREEN_W:-1680}
SCREEN_H=${SCREEN_H:-1050}

# ── Step 2: Capture target window name + center coordinates ──────────────────
TARGET_INFO=$(osascript << 'EOF'
tell application "System Events"
    set frontApp to first application process whose frontmost is true
    set appName to name of frontApp
    try
        set frontWin to first window of frontApp
        set pos to position of frontWin
        set sz to size of frontWin
        set cx to (item 1 of pos) + (item 1 of sz) / 2
        set cy to (item 2 of pos) + (item 2 of sz) / 2
        return appName & "|" & (cx as integer) & "|" & (cy as integer)
    on error
        return appName & "|500|400"
    end try
end tell
EOF
)

TARGET=$(echo "$TARGET_INFO" | cut -d'|' -f1)
WIN_CX=$(echo "$TARGET_INFO" | cut -d'|' -f2)
WIN_CY=$(echo "$TARGET_INFO" | cut -d'|' -f3)

[ -z "$TARGET" ] && exit 1

# ── Step 3: Warp mouse to center of target window ─────────────────────────────
# Uses CGWarpMouseCursorPosition — no app activation, just raw cursor move.
# OmniWM's FFM will now focus the correct window before receiving the hotkey.
osascript -l JavaScript -e \
    "ObjC.import('CoreGraphics'); \$.CGWarpMouseCursorPosition({x: $WIN_CX, y: $WIN_CY});"

# Brief pause so OmniWM FFM processes the mouse warp
sleep 0.1

# ── Step 4: Toggle floating via OmniWM (Shift+Ctrl+Cmd+G) ────────────────────
osascript -e \
    'tell application "System Events" to key code 5 using {shift down, control down, command down}'

sleep 0.2

# ── Step 5: Calculate center position for resize ──────────────────────────────
WIN_X=$(python3 -c "print(int(($SCREEN_W - $WIN_W) / 2))")
WIN_Y=$(python3 -c "print(int(($SCREEN_H - $WIN_H) / 2) + 25)")

# ── Step 6: Resize & center — target by captured name, immune to FFM ─────────
osascript << APPLESCRIPT
tell application "System Events"
    try
        set targetProc to first application process whose name is "$TARGET"
        set frontWin to first window of targetProc
        set position of frontWin to {$WIN_X, $WIN_Y}
        set size of frontWin to {$WIN_W, $WIN_H}
    on error
        set frontWin to first window of (first application process whose frontmost is true)
        set position of frontWin to {$WIN_X, $WIN_Y}
        set size of frontWin to {$WIN_W, $WIN_H}
    end try
end tell
APPLESCRIPT
