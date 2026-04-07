import json
import os

settings_path = os.path.expanduser("~/.config/omniwm/settings.json")
karabiner_path = os.path.expanduser("~/.config/karabiner/karabiner.json")

# --- 1. SETTINGS.JSON (The Internal Map) ---
with open(settings_path, "r") as f:
    settings = json.load(f)

# Modifiers matching ActionCatalog.swift
HYPER = 2816 # Shift + Ctrl + Opt + Cmd

# Re-verify Fullscreen binding
bindings = settings.get("hotkeyBindings", [])
found = False
for b in bindings:
    if b["id"] == "toggleFullscreen":
        b["binding"] = {"keyCode": 36, "modifiers": HYPER} # kVK_Return = 36
        found = True
        break
if not found:
    bindings.append({"id": "toggleFullscreen", "command": "toggleFullscreen", "binding": {"keyCode": 36, "modifiers": HYPER}})

settings["hotkeyBindings"] = bindings
with open(settings_path, "w") as f:
    json.dump(settings, f, indent=2)

# --- 2. KARABINER.JSON (The Bridge) ---
with open(karabiner_path, "r") as f:
    k_data = json.load(f)

for profile in k_data.get("profiles", []):
    for rule in profile.get("complex_modifications", {}).get("rules", []):
        for manipulator in rule.get("manipulators", []):
            if "conditions" in manipulator:
                conds = {c.get("name"): c.get("value") for c in manipulator["conditions"] if c.get("type") == "variable_if"}
                fc = manipulator.get("from", {}).get("key_code")
                
                # RCmd + F -> Hyper + Return (Simulated Fullscreen)
                if conds.get("rcmd_layer") == 1:
                    if fc == "f":
                        manipulator["to"] = [{"key_code": "return_or_enter", "modifiers": ["left_command", "left_control", "left_option", "left_shift"]}]

with open(karabiner_path, "w") as f:
    json.dump(k_data, f, indent=4)

print("Restoration v0.5.6 complete. RCmd+F -> Hyper+Return (Simulated Fullscreen). muni mun! 🎥")
