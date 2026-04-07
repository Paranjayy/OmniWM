import json

path = "/Users/paranjay/.config/karabiner/karabiner.json"
with open(path, "r") as f:
    data = json.load(f)

# Define Layers Modifiers (Matching Official Masterlist)
# RCmd (rcmd_layer) = [left_command, left_control, left_shift] (3 keys)
# ROpt (right_opt_layer) = [left_command, left_control, left_option] (3 keys)
# Hyper (Shift) = [left_command, left_control, left_option, left_shift] (4 keys)

for profile in data.get("profiles", []):
    for rule in profile.get("complex_modifications", {}).get("rules", []):
        for manipulator in rule.get("manipulators", []):
            if "conditions" in manipulator:
                conds = {c.get("name"): c.get("value") for c in manipulator["conditions"] if c.get("type") == "variable_if"}
                
                # RCMD Layer
                if conds.get("rcmd_layer") == 1:
                    if "to" in manipulator:
                        for t in manipulator["to"]:
                            if "key_code" in t:
                                # Switch Workspace (1-9), Reorder (WASD), Palette (Space)
                                if "modifiers" in manipulator.get("from", {}):
                                    mandatory = manipulator["from"]["modifiers"].get("mandatory", [])
                                    if "left_shift" in mandatory or "shift" in mandatory:
                                        # Move to Workspace (Shift + 1-9) -> Hyper (4rd layer)
                                        t["modifiers"] = ["left_command", "left_control", "left_option", "left_shift"]
                                    else:
                                        t["modifiers"] = ["left_command", "left_control", "left_shift"]
                                else:
                                    t["modifiers"] = ["left_command", "left_control", "left_shift"]
                
                # ROPT Layer (Focus / Move)
                if conds.get("right_opt_layer") == 1:
                    if "from" in manipulator and manipulator["from"].get("key_code") == "spacebar":
                        # Raycast Exception: ROpt + Space -> Only left_option
                        if "to" in manipulator:
                            for t in manipulator["to"]:
                                t["modifiers"] = ["left_option"]
                    elif "to" in manipulator:
                        mandatory = manipulator.get("from", {}).get("modifiers", {}).get("mandatory", [])
                        for t in manipulator["to"]:
                            if "key_code" in t:
                                if "left_shift" in mandatory or "shift" in mandatory:
                                    # Move / Physical -> Hyper (4rd layer)
                                    t["modifiers"] = ["left_command", "left_control", "left_option", "left_shift"]
                                else:
                                    # Focus / Index -> Meh (3rd layer)
                                    t["modifiers"] = ["left_command", "left_control", "left_option"]

with open(path, "w") as f:
    json.dump(data, f, indent=4)

print("Karabiner aligned for Official App Masterlist. Fixed ROpt+Space (Raycast), WASD/1-9 Layers.")
