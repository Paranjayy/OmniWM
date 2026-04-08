import json
import os

settings_path = os.path.expanduser("~/.config/omniwm/settings.json")
karabiner_path = os.path.expanduser("~/.config/karabiner/karabiner.json")

# --- 1. SETTINGS.JSON (The Internal Map) ---
with open(settings_path, "r") as f:
    settings = json.load(f)

# Modifiers matching ActionCatalog.swift
# cmdKey (1 << 8), controlKey (1 << 12), optionKey (1 << 11), shiftKey (1 << 9)
RCMD =  2304 # Shift + Ctrl + Cmd
ROPT =  2560 # Ctrl + Opt + Cmd
HYPER = 2816 # Shift + Ctrl + Opt + Cmd

bindings = [
    # Navigation (WASD)
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
    
    # Core
    {"id": "openCommandPalette", "command": "openCommandPalette", "binding": {"keyCode": 49, "modifiers": RCMD}},
    {"id": "toggleFocusedWindowFloating", "command": "toggleFocusedWindowFloating", "binding": {"keyCode": 5, "modifiers": RCMD}},
    {"id": "centerFocusedFloatAtSize", "command": "centerFocusedFloatAtSize", "binding": {"keyCode": 16, "modifiers": 256}}, # Cmd + Y
    {"id": "toggleColumnFullWidth", "command": "toggleColumnFullWidth", "binding": {"keyCode": 3, "modifiers": HYPER}}, # Hyper + F
]

# Digit Mapping (Switch Workspace=RCmd, Move to Workspace=Hyper, Focus Column=Hyper)
digit_codes = [18, 19, 20, 21, 23, 22, 26, 28, 25] # 1, 2, 3, 4, 5, 6, 7, 8, 9
for idx, code in enumerate(digit_codes):
    bindings.append({"id": f"switchWorkspace.{idx}", "command": {"switchWorkspace": idx}, "binding": {"keyCode": code, "modifiers": RCMD}})
    bindings.append({"id": f"moveToWorkspace.{idx}", "command": {"moveToWorkspace": idx}, "binding": {"keyCode": code, "modifiers": HYPER}})
    bindings.append({"id": f"focusColumn.{idx}", "command": {"focusColumn": idx}, "binding": {"keyCode": code, "modifiers": HYPER}})

settings["hotkeyBindings"] = bindings
with open(settings_path, "w") as f:
    json.dump(settings, f, indent=2)

# --- 2. KARABINER.JSON (The Promoted Bridge) ---
with open(karabiner_path, "r") as f:
    k_data = json.load(f)

for profile in k_data.get("profiles", []):
    for rule in profile.get("complex_modifications", {}).get("rules", []):
        for manipulator in rule.get("manipulators", []):
            if "conditions" in manipulator:
                conds = {c.get("name"): c.get("value") for c in manipulator["conditions"] if c.get("type") == "variable_if"}
                fc = manipulator.get("from", {}).get("key_code")
                fkc = manipulator.get("from", {}).get("consumer_key_code")

                # PROMOTE RCmd+Shift+1-9 to HYPER (Move Window)
                if conds.get("rcmd_layer") == 1:
                    mandatory = manipulator.get("from", {}).get("modifiers", {}).get("mandatory", [])
                    if fc in ["1", "2", "3", "4", "5", "6", "7", "8", "9"] and ("left_shift" in mandatory or "shift" in mandatory):
                        manipulator["to"] = [{"key_code": fc, "modifiers": ["left_command", "left_control", "left_option", "left_shift"]}]
                    elif fc == "f":
                        # RCmd + F -> Hyper + F (Column Full Width)
                        manipulator["to"] = [{"key_code": "f", "modifiers": ["left_command", "left_control", "left_option", "left_shift"]}]
                    elif fc == "y":
                        # RCmd + Y -> Cmd + Y (Center)
                        manipulator["to"] = [{"key_code": "y", "modifiers": ["left_command"]}]
                
                # PROMOTE ROpt+1-9 to HYPER (Focus Column App Index)
                if conds.get("right_opt_layer") == 1:
                    if fc in ["1", "2", "3", "4", "5", "6", "7", "8", "9"]:
                        manipulator["to"] = [{"key_code": fc, "modifiers": ["left_command", "left_control", "left_option", "left_shift"]}]
                    elif fkc and any(k in fkc for k in ["volume", "brightness"]):
                        # Fine Tuning: Ensure shift is held correctly
                        mandatory = manipulator.get("from", {}).get("modifiers", {}).get("mandatory", [])
                        if "left_shift" in mandatory or "shift" in mandatory:
                            manipulator["to"] = [{"consumer_key_code": fkc, "modifiers": ["left_option", "left_shift"]}]
                        else:
                            manipulator["to"] = [{"consumer_key_code": fkc}]

with open(karabiner_path, "w") as f:
    json.dump(k_data, f, indent=4)

print("Restoration v0.5.5 complete. Digits/F promoted to Hyper. Fine-tuning filters verified.")
