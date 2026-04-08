import json
import os

settings_path = os.path.expanduser("~/.config/omniwm/settings.json")
karabiner_path = os.path.expanduser("~/.config/karabiner/karabiner.json")

# --- 1. SETTINGS.JSON: Populate Hotkey Bindings ---
with open(settings_path, "r") as f:
    settings = json.load(f)

# Definitions matching ActionCatalog.swift (L112-114)
# cmdKey (1 << 8), controlKey (1 << 12), optionKey (1 << 11), shiftKey (1 << 9)
RCMD = 1 << 8 | 1 << 12 | 1 << 9        # Shift + Ctrl + Cmd (2304)
ROPT = 1 << 8 | 1 << 12 | 1 << 11       # Ctrl + Opt + Cmd (2560)
HYPER = 1 << 8 | 1 << 12 | 1 << 11 | 1 << 9 # 4rd Layer (2816)

bindings = [
    # Navigation (WASD) - Muni Accuracy
    {"id": "focus.left", "command": {"focus": "left"}, "binding": {"keyCode": 0, "modifiers": ROPT}}, # "a"
    {"id": "focus.right", "command": {"focus": "right"}, "binding": {"keyCode": 2, "modifiers": ROPT}}, # "d"
    {"id": "focus.up", "command": {"focus": "up"}, "binding": {"keyCode": 13, "modifiers": ROPT}}, # "w"
    {"id": "focus.down", "command": {"focus": "down"}, "binding": {"keyCode": 1, "modifiers": ROPT}}, # "s"
    
    # Movement (WASD) - Hyper
    {"id": "move.left", "command": {"move": "left"}, "binding": {"keyCode": 0, "modifiers": HYPER}},
    {"id": "move.right", "command": {"move": "right"}, "binding": {"keyCode": 2, "modifiers": HYPER}},
    {"id": "move.up", "command": {"move": "up"}, "binding": {"keyCode": 13, "modifiers": HYPER}},
    {"id": "move.down", "command": {"move": "down"}, "binding": {"keyCode": 1, "modifiers": HYPER}},

    # Reorder (A, D) - RCmd
    {"id": "moveColumn.left", "command": {"moveColumn": "left"}, "binding": {"keyCode": 0, "modifiers": RCMD}},
    {"id": "moveColumn.right", "command": {"moveColumn": "right"}, "binding": {"keyCode": 2, "modifiers": RCMD}},
    
    # Core (Space, G, Y)
    {"id": "openCommandPalette", "command": "openCommandPalette", "binding": {"keyCode": 49, "modifiers": RCMD}},
    {"id": "toggleFocusedWindowFloating", "command": "toggleFocusedWindowFloating", "binding": {"keyCode": 5, "modifiers": RCMD}},
    {"id": "centerFocusedFloatAtSize", "command": "centerFocusedFloatAtSize", "binding": {"keyCode": 16, "modifiers": 1 << 8}}, # Cmd + Y

    # Workspaces (1-9)
    {"id": "toggleWorkspaceBarVisibility", "command": "toggleWorkspaceBarVisibility", "binding": {"keyCode": 11, "modifiers": RCMD}} # B
]

# Digit based Workspace and Focus Column
digit_codes = [18, 19, 20, 21, 23, 22, 26, 28, 25] # 1, 2, 3, 4, 5, 6, 7, 8, 9
for idx, code in enumerate(digit_codes):
    bindings.append({"id": f"switchWorkspace.{idx}", "command": {"switchWorkspace": idx}, "binding": {"keyCode": code, "modifiers": RCMD}})
    bindings.append({"id": f"moveToWorkspace.{idx}", "command": {"moveToWorkspace": idx}, "binding": {"keyCode": code, "modifiers": HYPER}})
    bindings.append({"id": f"focusColumn.{idx}", "command": {"focusColumn": idx}, "binding": {"keyCode": code, "modifiers": HYPER}})

settings["hotkeyBindings"] = bindings
with open(settings_path, "w") as f:
    json.dump(settings, f, indent=2)

# --- 2. KARABINER.JSON: Layer Alignment ---
with open(karabiner_path, "r") as f:
    k_data = json.load(f)

for profile in k_data.get("profiles", []):
    for rule in profile.get("complex_modifications", {}).get("rules", []):
        for manipulator in rule.get("manipulators", []):
            if "conditions" in manipulator:
                conds = {c.get("name"): c.get("value") for c in manipulator["conditions"] if c.get("type") == "variable_if"}
                
                # RCMD Layer
                if conds.get("rcmd_layer") == 1:
                    fc = manipulator.get("from", {}).get("key_code")
                    if fc == "y":
                        # Cmd + Y (Native app centering)
                        manipulator["to"] = [{"key_code": "y", "modifiers": ["left_command"]}]
                    elif fc in ["w", "a", "s", "d"]:
                        # Native WASD Characters for Reorder
                        mandatory = manipulator.get("from", {}).get("modifiers", {}).get("mandatory", [])
                        if "left_shift" in mandatory or "shift" in mandatory:
                            manipulator["to"] = [{"key_code": fc, "modifiers": ["left_command", "left_control", "left_option", "left_shift"]}]
                        else:
                            manipulator["to"] = [{"key_code": fc, "modifiers": ["left_command", "left_control", "left_shift"]}]
                    elif fc in ["left_arrow", "right_arrow", "up_arrow", "down_arrow"]:
                        # Arrow Passthrough
                        manipulator["to"] = [{"key_code": fc}]
                
                # ROPT Layer (Focus / Fine Tuning)
                if conds.get("right_opt_layer") == 1:
                    fc = manipulator.get("from", {}).get("key_code")
                    fkc = manipulator.get("from", {}).get("consumer_key_code")
                    
                    if fc in ["w", "a", "s", "d"]:
                        mandatory = manipulator.get("from", {}).get("modifiers", {}).get("mandatory", [])
                        if "left_shift" in mandatory or "shift" in mandatory:
                            manipulator["to"] = [{"key_code": fc, "modifiers": ["left_command", "left_control", "left_option", "left_shift"]}]
                        else:
                            manipulator["to"] = [{"key_code": fc, "modifiers": ["left_command", "left_control", "left_option"]}]
                    elif fc in ["left_arrow", "right_arrow", "up_arrow", "down_arrow"]:
                        manipulator["to"] = [{"key_code": fc}]
                    elif fkc and any(k in fkc for k in ["volume", "brightness", "mute"]):
                        # Fine Tuning: Require Shift
                        mandatory = manipulator.get("from", {}).get("modifiers", {}).get("mandatory", [])
                        if "left_shift" in mandatory or "shift" in mandatory:
                            manipulator["to"] = [{"consumer_key_code": fkc, "modifiers": ["left_option", "left_shift"]}]
                        else:
                            # Pass-through normal volume if shift is not held
                            manipulator["to"] = [{"consumer_key_code": fkc}]

with open(karabiner_path, "w") as f:
    json.dump(k_data, f, indent=4)

print("Restoration finished. settings.json populated, WASD restored to native, Arrows PASSED THROUGH.")
