#!/usr/bin/env python3
"""
OmniKey Deploy Script v2
- Removes ALL previously injected OmniKey rules (by title match)
- Injects fresh rules directly into active Karabiner profile
- No manual clicking required
"""

import json, shutil, os
from datetime import datetime

KARABINER_CONFIG = os.path.expanduser("~/.config/karabiner/karabiner.json")
RULES_FILE = os.path.join(os.path.dirname(__file__), "karabiner_omnikey.json")

def load_json(path):
    with open(path) as f:
        return json.load(f)

def save_json(path, data):
    backup = path + f".bak.{datetime.now().strftime('%Y%m%d_%H%M%S')}"
    shutil.copy(path, backup)
    with open(path, "w") as f:
        json.dump(data, f, indent=4)
    print(f"  ✅ Saved (backup: {os.path.basename(backup)})")

def is_omnikey_rule(rule):
    """Match any rule we've ever injected, using multiple indicators."""
    desc = rule.get("description", "")
    markers = [
        "OmniKey", "[Global]", "[RCmd Layer]", "[Right Opt Layer]",
        "[Context:", "[Sequence]", "space_layer", "right_opt_layer",
        "seq_move_window", "seq_launch_app", "seq_system",
        "Hyper (CapsLock)", "Right Option (held)", "Right Command (held)"
    ]
    return any(m in desc for m in markers)

def deploy():
    print("🚀 OmniKey Deploy v2")
    print(f"   Rules  : {RULES_FILE}")
    print(f"   Config : {KARABINER_CONFIG}")
    print()

    new_rules   = load_json(RULES_FILE)["rules"]
    karabiner   = load_json(KARABINER_CONFIG)
    profiles    = karabiner["profiles"]

    # Target the selected (first) profile
    target = next((p for p in profiles if p.get("selected")), profiles[0])
    print(f"   Profile : {target['name']}")

    cc   = target.setdefault("complex_modifications", {})
    old  = cc.get("rules", [])

    kept    = [r for r in old if not is_omnikey_rule(r)]
    removed = len(old) - len(kept)
    print(f"   Removed : {removed} old OmniKey rules")

    cc["rules"] = new_rules + kept
    print(f"   Injected: {len(new_rules)} fresh rules")

    save_json(KARABINER_CONFIG, karabiner)
    print()
    print("✅ Done! Karabiner auto-reloads in ~2 seconds.")

if __name__ == "__main__":
    deploy()
