#!/bin/bash
# High-fidelity 5s bar peek.
# Calls bar_manager.sh to ensure state sync.

./Scripts/bar_manager.sh --hold
sleep 5
./Scripts/bar_manager.sh --release
