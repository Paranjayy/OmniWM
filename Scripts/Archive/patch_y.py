import json

with open("/Users/paranjay/.config/karabiner/karabiner.json", "r") as f:
    data = json.load(f)

for profile in data.get("profiles", []):
    for rule in profile.get("complex_modifications", {}).get("rules", []):
        for manipulator in rule.get("manipulators", []):
            if manipulator.get("from", {}).get("key_code") == "y":
                # Ensure it only applies to the one that currently calls shell command
                if "to" in manipulator:
                    for idx, t in enumerate(manipulator["to"]):
                        if "shell_command" in t and "center_float.sh" in t["shell_command"]:
                            manipulator["to"][idx] = {
                                "key_code": "y",
                                "modifiers": ["left_command"]
                            }

with open("/Users/paranjay/.config/karabiner/karabiner.json", "w") as f:
    json.dump(data, f, indent=4)

print("Patched Karabiner 'y' mapping to use native Cmd+Y")
