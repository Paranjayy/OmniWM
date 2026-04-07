import json

path = "/Users/paranjay/.config/karabiner/karabiner.json"
with open(path, "r") as f:
    data = json.load(f)

# Define Layers Modifiers (Matching Official App Arrow Logic)
# RCmd (rcmd_layer) = [left_command, left_control, left_shift] (3 keys)
# ROpt (right_opt_layer) = [left_command, left_control, left_option] (3 keys)
# Hyper (Shift Modifier) = [left_command, left_control, left_option, left_shift] (4 keys)

wasd_to_arrows = {
    "w": "up_arrow",
    "a": "left_arrow",
    "s": "down_arrow",
    "d": "right_arrow"
}

for profile in data.get("profiles", []):
    for rule in profile.get("complex_modifications", {}).get("rules", []):
        for manipulator in rule.get("manipulators", []):
            if "conditions" in manipulator:
                conds = {c.get("name"): c.get("value") for c in manipulator["conditions"] if c.get("type") == "variable_if"}
                
                # RCMD Layer
                if conds.get("rcmd_layer") == 1:
                    if "from" in manipulator and "key_code" in manipulator["from"]:
                        kc = manipulator["from"]["key_code"]
                        if kc in wasd_to_arrows:
                            # Translate WASD to Arrows for Official App
                            if "to" in manipulator:
                                for t in manipulator["to"]:
                                    t["key_code"] = wasd_to_arrows[kc]
                                    t["modifiers"] = ["left_command", "left_control", "left_shift"]
                        elif kc == "y":
                            # RCmd + Y -> center_float.sh
                            manipulator["to"] = [
                                { "shell_command": "bash /Users/paranjay/Developer/OmniWM/Scripts/center_float.sh" }
                            ]
                
                # ROPT Layer (Focus / Move / Fine Tuning)
                if conds.get("right_opt_layer") == 1:
                    if "from" in manipulator and "key_code" in manipulator["from"]:
                        kc = manipulator["from"]["key_code"]
                        mandatory = manipulator["from"].get("modifiers", {}).get("mandatory", [])
                        is_shift = "left_shift" in mandatory or "shift" in mandatory
                        
                        # 1. WASD to Arrows Focus/Move
                        if kc in wasd_to_arrows:
                            if "to" in manipulator:
                                for t in manipulator["to"]:
                                    t["key_code"] = wasd_to_arrows[kc]
                                    if is_shift:
                                        t["modifiers"] = ["left_command", "left_control", "left_option", "left_shift"]
                                    else:
                                        t["modifiers"] = ["left_command", "left_control", "left_option"]
                        
                        # 2. Fine Tuning (Brightness/Audio)
                        elif any(k in kc for k in ["volume", "brightness", "mute"]):
                            if is_shift:
                                if "to" in manipulator:
                                    for t in manipulator["to"]:
                                        # Map to native macOS 1/16th: Option + Shift
                                        t["modifiers"] = ["left_option", "left_shift"]

with open(path, "w") as f:
    json.dump(data, f, indent=4)

print("Karabiner aligned for Official App v2. WASD->Arrows translation, RCmd+Y, and Fine-Tuning fixed.")
