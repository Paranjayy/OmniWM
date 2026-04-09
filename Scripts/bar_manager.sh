#!/bin/bash

# OmniWM Dynamic Bar Manager (Stabilized v2)
# Implementation: Show while holding, Hide 5s after release.
# Uses explicit idempotent commands to prevent state-sync bugs.

LOCK_FILE="/tmp/omniwm_bar_hold.lock" # Present while holding

CTL_BIN="/Applications/OmniWM.app/Contents/MacOS/omniwmctl"

show_bar() {
    $CTL_BIN command show-workspace-bar
}

hide_bar() {
    $CTL_BIN command hide-workspace-bar
}

case "$1" in
    --hold)
        touch "$LOCK_FILE"
        show_bar
        ;;
    --release)
        rm -f "$LOCK_FILE"
        # Wait 5s before hiding
        (
            sleep 5
            # ONLY hide if NOT holding again (lock file removed) 
            if [ ! -f "$LOCK_FILE" ]; then
                hide_bar
            fi
        ) &
        ;;
    --toggle)
        $CTL_BIN command toggle-workspace-bar
        ;;
    --reset)
        rm -f "$LOCK_FILE"
        hide_bar
        ;;
esac
