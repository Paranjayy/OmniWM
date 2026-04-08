import json
import os

settings_path = os.path.expanduser("~/.config/omniwm/settings.json")
karabiner_path = os.path.expanduser("~/.config/karabiner/karabiner.json")

# --- 1. SETTINGS.JSON (Ensure Correct Command Map) ---
with open(settings_path, "r") as f:
    settings = json.load(f)

# Modifiers matching ActionCatalog.swift
RCMD =  2304 # Shift + Ctrl + Cmd
ROPT =  2560 # Ctrl + Opt + Cmd
HYPER = 2816 # Shift + Ctrl + Opt + Cmd

bindings = [
    # Navigation (WASD) - ROpt
    {"id": "focus.left", "command": {"focus": "left"}, "binding": {"keyCode": 0, "modifiers": ROPT}},
    {"id": "focus.right", "command": {"focus": "right"}, "binding": {"keyCode": 2, "modifiers": ROPT}},
    {"id": "focus.up", "command": {"focus": "up"}, "binding": {"keyCode": 13, "modifiers": ROPT}},
    {"id": "focus.down", "command": {"focus": "down"}, "binding": {"keyCode": 1, "modifiers": ROPT}},
    
    # Movement (WASD) - Hyper
    {"id": "move.left", "command": {"move": "left"}, "binding": {"keyCode": 0, "modifiers": HYPER}},
    {"id": "move.right", "command": {"move": "right"}, "binding": {"keyCode": 2, "modifiers": HYPER}},
    {"id": "move.up", "command": {"move": "up"}, "binding": {"keyCode": 13, "modifiers": HYPER}},
    {"id": "move.down", "command": {"move": "down"}, "binding": {"keyCode": 1, "modifiers": HYPER}},

    # Reorder (A, D) - RCmd
    {"id": "moveColumn.left", "command": {"moveColumn": "left"}, "binding": {"keyCode": 0, "modifiers": RCMD}},
    {"id": "moveColumn.right", "command": {"moveColumn": "right"}, "binding": {"keyCode": 2, "modifiers": RCMD}},
    
    # Layout (Management Cluster)
    {"id": "toggleFullscreen", "command": "toggleFullscreen", "binding": {"keyCode": 36, "modifiers": HYPER}}, # Return
    {"id": "toggleFocusedWindowFloating", "command": "toggleFocusedWindowFloating", "binding": {"keyCode": 5, "modifiers": RCMD}}, # G
    {"id": "centerFocusedFloatAtSize", "command": "centerFocusedFloatAtSize", "binding": {"keyCode": 16, "modifiers": 256}}, # Cmd + Y
    {"id": "openCommandPalette", "command": "openCommandPalette", "binding": {"keyCode": 49, "modifiers": RCMD}}, # Space
]

digit_codes = [18, 19, 20, 21, 23, 22, 26, 28, 25] # 1, 2, 3, 4, 5, 6, 7, 8, 9
for idx, code in enumerate(digit_codes):
    bindings.append({"id": f"switchWorkspace.{idx}", "command": {"switchWorkspace": idx}, "binding": {"keyCode": code, "modifiers": RCMD}})
    bindings.append({"id": f"moveToWorkspace.{idx}", "command": {"moveToWorkspace": idx}, "binding": {"keyCode": code, "modifiers": HYPER}})
    bindings.append({"id": f"focusColumn.{idx}", "command": {"focusColumn": idx}, "binding": {"keyCode": code, "modifiers": HYPER}})

settings["hotkeyBindings"] = bindings
with open(settings_path, "w") as f:
    json.dump(settings, f, indent=2)

# --- 2. KARABINER.JSON (Targeted Manipulator Overwrite) ---
with open(karabiner_path, "r") as f:
    k_data = json.load(f)

# Modifiers for "to" blocks
HYPER_TO = ["left_command", "left_control", "left_option", "left_shift"]
RCMD_TO  = ["left_command", "left_control", "left_shift"]
ROPT_TO  = ["left_command", "left_control", "left_option"]

for profile in k_data.get("profiles", []):
    for rule in profile.get("complex_modifications", {}).get("rules", []):
        new_manipulators = []
        for manip in rule.get("manipulators", []):
            conds = {c.get("name"): c.get("value") for c in manip.get("conditions", []) if c.get("type") == "variable_if"}
            fc = manip.get("from", {}).get("key_code")
            fkc = manip.get("from", {}).get("consumer_key_code")
            is_digit = fc in ["1", "2", "3", "4", "5", "6", "7", "8", "9"]
            
            # --- ROPT LAYER FIXES ---
            if conds.get("right_opt_layer") == 1:
                # Digit Promotion (Focus Column)
                if is_digit:
                    manip["to"] = [{"key_code": fc, "modifiers": HYPER_TO}]
                    new_manipulators.append(manip)
                # Fine Tuning (Volume/Brightness)
                elif fkc and any(k in fkc for k in ["volume", "brightness"]):
                    mandatory = manip.get("from", {}).get("modifiers", {}).get("mandatory", [])
                    if "left_shift" in mandatory or "shift" in mandatory:
                        manip["to"] = [{"consumer_key_code": fkc, "modifiers": ["left_option", "left_shift"]}]
                    else:
                        manip["to"] = [{"consumer_key_code": fkc, "modifiers": ["left_option"]}]
                    new_manipulators.append(manip)
                else:
                    new_manipulators.append(manip)

            # --- RCMD LAYER FIXES ---
            elif conds.get("rcmd_layer") == 1:
                # Digit Fix (Switch Workspace)
                if is_digit:
                    mandatory = manip.get("from", {}).get("modifiers", {}).get("mandatory", [])
                    if "left_shift" in mandatory or "shift" in mandatory:
                        # RCmd + Shift + [1-9] -> Hyper (Move Window)
                        manip["to"] = [{"key_code": fc, "modifiers": HYPER_TO}]
                    else:
                        # RCmd + [1-9] -> RCmd (Switch Workspace)
                        manip["to"] = [{"key_code": fc, "modifiers": RCMD_TO}]
                    new_manipulators.append(manip)
                # Fullscreen Fix
                elif fc == "f":
                    manip["to"] = [{"key_code": "return_or_enter", "modifiers": HYPER_TO}]
                    new_manipulators.append(manip)
                # Centering Fix
                elif fc == "y":
                    manip["to"] = [{"key_code": "y", "modifiers": ["left_command"]}]
                    new_manipulators.append(manip)
                else:
                    new_manipulators.append(manip)
            else:
                new_manipulators.append(manip)
        
        # Clean up duplicates that might have been added by previous scripts
        final_manips = []
        seen = set()
        for m in new_manipulators:
            # Create a unique key for the manipulator to avoid duplicates
            m_key = (json.dumps(m.get("conditions", [])), json.dumps(m.get("from", {})))
            if m_key not in seen:
                final_manips.append(m)
                seen.add(m_key)
        rule["manipulators"] = final_manips

with open(karabiner_path, "w") as f:
    json.dump(k_data, f, indent=4)

print("Restoration v0.5.7 complete. Total Layer Alignment enforced. muni mun! 🦾")
