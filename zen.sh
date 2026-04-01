#!/bin/bash

# OmniWM Zen Toggle - Master Control Script

STATE_FILE="/tmp/omniwm_zen_state"
CURRENT_STATE="off"
[ -f "$STATE_FILE" ] && CURRENT_STATE=$(cat "$STATE_FILE")

if [ "$CURRENT_STATE" == "off" ]; then
    # -- ENGAGE ZEN --
    # 1. Hide Workspace Bar (RCmd+B = Shift+Ctrl+Cmd+B)
    osascript -e 'tell application "System Events" to key code 11 using {shift down, control down, command down}'
    # 2. Hide all other applications (Cmd+Opt+H)
    osascript -e 'tell application "System Events" to key code 4 using {command down, option down}'
    echo "on" > "$STATE_FILE"
    echo "🧘 Zen Mode Engaged."
else
    # -- DISENGAGE ZEN (RECOVER) --
    # 1. Show Workspace Bar (Toggle)
    osascript -e 'tell application "System Events" to key code 11 using {shift down, control down, command down}'
    # 2. Show all applications (Recover All)
    osascript -e 'tell application "System Events" to set visible of every process to true'
    echo "off" > "$STATE_FILE"
    echo "☀️ Zen Mode Disengaged."
fi
