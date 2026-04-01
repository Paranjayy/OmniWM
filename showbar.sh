#!/bin/bash

# OmniWM 5-Second Bar Peek Script
# Purely sends TWO toggles separated by 5 seconds.
# This assumes the bar is HIDDEN by default.

# 1. Show (Toggle)
osascript -e 'tell application "System Events" to key code 11 using {shift down, control down, command down}'

# 2. Wait
sleep 5

# 3. Hide (Toggle) 
osascript -e 'tell application "System Events" to key code 11 using {shift down, control down, command down}'

echo " Peek completed. mun!"
