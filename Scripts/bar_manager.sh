#!/bin/bash

# OmniWM Dynamic Bar Manager
# Implementation: Show while holding, Hide 5s after release.
# Uses a lock file to ensure the hide timer respects the hold duration.

STATE_FILE="/tmp/omniwm_bar_state"   # 1=Visible, 0=Hidden
LOCK_FILE="/tmp/omniwm_bar_hold.lock" # Present while holding

[ ! -f "$STATE_FILE" ] && echo "0" > "$STATE_FILE"

is_visible() { [ "$(cat "$STATE_FILE")" == "1" ]; }

send_toggle() {
    osascript -e 'tell application "System Events" to key code 11 using {shift down, control down, command down}'
}

case "$1" in
    --hold)
        touch "$LOCK_FILE"
        if ! is_visible; then
            send_toggle
            echo "1" > "$STATE_FILE"
        fi
        ;;
    --release)
        rm -f "$LOCK_FILE"
        # Wait 5s before hiding
        (
            sleep 5
            # ONLY hide if NOT holding again (lock file removed) 
            # and it's still visible
            if [ ! -f "$LOCK_FILE" ] && is_visible; then
                send_toggle
                echo "0" > "$STATE_FILE"
            fi
        ) &
        ;;
    --toggle)
        send_toggle
        if is_visible; then echo "0" > "$STATE_FILE"; else echo "1" > "$STATE_FILE"; fi
        ;;
    --reset)
        echo "0" > "$STATE_FILE"
        rm -f "$LOCK_FILE"
        ;;
esac
