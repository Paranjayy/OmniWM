#!/usr/bin/env python3
"""
OmniWM God Build — settings.json patcher
Run ONCE after building the app to inject God Build flags into your config.
Usage: python3 Scripts/patch_god_build_settings.py
"""
import json, os, shutil, datetime

SETTINGS_PATH = os.path.expanduser("~/.config/omniwm/settings.json")
BACKUP_PATH = SETTINGS_PATH + f".bak_{datetime.datetime.now().strftime('%Y%m%d_%H%M%S')}"

if not os.path.exists(SETTINGS_PATH):
    print(f"❌ Settings not found at {SETTINGS_PATH}")
    print("   Launch OmniWM once to generate the default settings, then re-run.")
    exit(1)

# Backup first
shutil.copy2(SETTINGS_PATH, BACKUP_PATH)
print(f"✅ Backup saved: {BACKUP_PATH}")

with open(SETTINGS_PATH, "r") as f:
    data = json.load(f)

# Inject God Build feature flags
patched = []
if "activeProfile" not in data:
    data["activeProfile"] = "Official"
    patched.append("activeProfile = Official")
if "warpSwitcherEnabled" not in data:
    data["warpSwitcherEnabled"] = True
    patched.append("warpSwitcherEnabled = true")
if "windowTrashEnabled" not in data:
    data["windowTrashEnabled"] = True
    patched.append("windowTrashEnabled = true")
if "sessionSnapshotEnabled" not in data:
    data["sessionSnapshotEnabled"] = True
    patched.append("sessionSnapshotEnabled = true")

# Inject God Build hotkey bindings (only if not already present)
existing_ids = {b["id"] for b in data.get("hotkeyBindings", [])}
god_bindings = [
    {"id": "trashFocusedWindow",       "binding": "Control+Option+Command+T"},
    {"id": "popLastTrashedWindow",     "binding": "Control+Option+Command+P"},
    {"id": "captureWorkspaceSnapshot", "binding": "Control+Option+Command+S"},
    {"id": "openWarpSwitcher",         "binding": "Control+Option+Command+W"},
    {"id": "testHaptic",               "binding": "Control+Option+Command+H"},
]
for b in god_bindings:
    if b["id"] not in existing_ids:
        data.setdefault("hotkeyBindings", []).append(b)
        patched.append(f"  hotkey: {b['id']} → {b['binding']}")

with open(SETTINGS_PATH, "w") as f:
    json.dump(data, f, indent=2, sort_keys=True)

if patched:
    print(f"✅ Patched {len(patched)} item(s):")
    for item in patched:
        print(f"   + {item}")
else:
    print("✅ All God Build flags already present — nothing to patch.")

print("\n🎮 Next step: Restart OmniWM, then go to Settings > General > Application Profile"
      " and switch to 'God Build (v47.2)'.")
