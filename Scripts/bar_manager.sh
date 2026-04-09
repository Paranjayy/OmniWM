#!/bin/bash

# OmniWM Dynamic Bar Manager (Official App Compatibility)
# Implementation: Show while holding, Hide 5s after release.
# This script uses idempotent logic (check-then-toggle) to work 
# flawlessly with the official OmniWM binary.

LOCK_FILE="/tmp/omniwm_bar_hold.lock" # Present while holding

CTL_BIN="/Applications/OmniWM.app/Contents/MacOS/omniwmctl"

is_visible() {
    # Check if ANY monitor has isVisible: true
    $CTL_BIN query workspace-bar --format json | jq '.result.payload.monitors[].isVisible' 2>/dev/null | grep -q true
}

ensure_visible() {
    if ! is_visible; then
        $CTL_BIN command toggle-workspace-bar
    fi
}

ensure_hidden() {
    if is_visible; then
        $CTL_BIN command toggle-workspace-bar
    fi
}

case "$1" in
    --hold)
        touch "$LOCK_FILE"
        ensure_visible
        ;;
    --release)
        rm -f "$LOCK_FILE"
        # The Protector: Wait 5s before force-hiding
        (
            sleep 5
            # ONLY hide if NOT holding again (lock file removed) 
            if [ ! -f "$LOCK_FILE" ]; then
                ensure_hidden
            fi
        ) &
        ;;
    --toggle)
        $CTL_BIN command toggle-workspace-bar
        ;;
    --reset)
        rm -f "$LOCK_FILE"
        ensure_hidden
        ;;
esac
