import json

path = "/Users/paranjay/.config/karabiner/karabiner.json"
with open(path, "r") as f:
    data = json.load(f)

# Define Layers Modifiers (Matching ActionCatalog.v0.5.1)
# RCmd = [left_command, left_control, left_shift]
# ROpt = [left_command, left_control, left_option]
# Hyper (ROpt+Shift) = [left_command, left_control, left_option, left_shift]

for profile in data.get("profiles", []):
    for rule in profile.get("complex_modifications", {}).get("rules", []):
        rule_desc = rule.get("description", "").lower()
        for manipulator in rule.get("manipulators", []):
            if "conditions" in manipulator:
                conds = {c.get("name"): c.get("value") for c in manipulator["conditions"] if c.get("type") == "variable_if"}
                
                # RCMD Layer
                if conds.get("rcmd_layer") == 1:
                    if "to" in manipulator:
                        for t in manipulator["to"]:
                            if "key_code" in t:
                                # Standard RCmd commands
                                t["modifiers"] = ["left_command", "left_control", "left_shift"]
                
                # ROPT Layer (Focus / Move)
                if conds.get("right_opt_layer") == 1:
                    mandatory = manipulator.get("from", {}).get("modifiers", {}).get("mandatory", [])
                    if "to" in manipulator:
                        for t in manipulator["to"]:
                            if "key_code" in t:
                                if "left_shift" in mandatory or "shift" in mandatory:
                                    # Move / Hyper
                                    t["modifiers"] = ["left_command", "left_control", "left_option", "left_shift"]
                                else:
                                    # Focus / Meh
                                    t["modifiers"] = ["left_command", "left_control", "left_option"]

with open(path, "w") as f:
    json.dump(data, f, indent=4)

print("Karabiner layers aligned with ActionCatalog modifiers (RCmd=Cmd+Ctrl+Shift, ROpt=Cmd+Ctrl+Opt).")
