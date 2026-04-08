import json

with open("/Users/paranjay/.config/karabiner/karabiner.json", "r") as f:
    data = json.load(f)

# We want to find manipulators under "[ROpt Layer]" and others 
# and upgrade the 'to' modifiers to use ["left_command", "left_control", "left_option", "left_shift"]
# UNLESS they are specifically the God Build godLayer keys (t, p, s, w, h).

god_keys = ["t", "p", "s", "w", "h"]

for profile in data.get("profiles", []):
    for rule in profile.get("complex_modifications", {}).get("rules", []):
        for manipulator in rule.get("manipulators", []):
            if "to" in manipulator:
                for t in manipulator["to"]:
                    # Wait, if it has a key_code
                    if "key_code" in t:
                        kc = t["key_code"]
                        # If it previously sent left_option, or some other combination
                        if "modifiers" in t:
                            # It's an output. Replace we only want to touch those mappings 
                            # that were part of Window Management.
                            # The user said "remove the 3/two key stuffs"
                            current_mods = t.get("modifiers", [])
                            if isinstance(current_mods, list):
                                # If it's a window navigation like left_arrow, right_arrow, up, down, tab, 1-9
                                if kc in ["left_arrow", "right_arrow", "up_arrow", "down_arrow", "tab", "1", "2", "3", "4", "5", "6", "7", "8", "9", "delete_or_backspace"]:
                                    t["modifiers"] = ["left_command", "left_control", "left_option", "left_shift"]
                                    
with open("/Users/paranjay/.config/karabiner/karabiner.json", "w") as f:
    json.dump(data, f, indent=4)

print("Karabiner bindings upgraded to 4-keys")
