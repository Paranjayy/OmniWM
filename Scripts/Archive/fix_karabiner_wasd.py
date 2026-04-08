import json

path = "/Users/paranjay/.config/karabiner/karabiner.json"
with open(path, "r") as f:
    data = json.load(f)

# Mapping from WASD to WASD (logic handled by modifiers now)
wasd_map = {
    "w": "w",
    "a": "a",
    "s": "s",
    "d": "d"
}

for profile in data.get("profiles", []):
    for rule in profile.get("complex_modifications", {}).get("rules", []):
        for manipulator in rule.get("manipulators", []):
            if "from" in manipulator and "key_code" in manipulator["from"]:
                kc = manipulator["from"]["key_code"]
                if kc in wasd_map:
                    # Upgrade 'to' mappings
                    if "to" in manipulator:
                        for item in manipulator["to"]:
                            if "key_code" in item:
                                # If it was previously mapping to an arrow
                                if item["key_code"] in ["up_arrow", "down_arrow", "left_arrow", "right_arrow"]:
                                    item["key_code"] = wasd_map[kc]
                                    
                                    # Ensure modifiers are correct
                                    # If the 'from' has mandatory shift, it's a 'Move' -> hyperLayer (4 keys)
                                    # If not, it's a 'Focus' -> godLayer (3 keys)
                                    mandatory = manipulator["from"].get("modifiers", {}).get("mandatory", [])
                                    if "left_shift" in mandatory or "shift" in mandatory:
                                        item["modifiers"] = ["left_command", "left_control", "left_option", "left_shift"]
                                    else:
                                        item["modifiers"] = ["left_command", "left_control", "left_option"]

with open(path, "w") as f:
    json.dump(data, f, indent=4)

print("Karabiner WASD mappings updated to native WASD + God/Hyper layers.")
