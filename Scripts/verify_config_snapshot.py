#!/usr/bin/env python3

import json
import pathlib
import sys
import tomllib


ROOT = pathlib.Path(__file__).resolve().parents[1]
LIVE_OMNIWM_DIR = pathlib.Path.home() / ".config/omniwm"
LIVE_KARABINER_PATH = pathlib.Path.home() / ".config/karabiner/karabiner.json"
REPO_OMNIWM_TOML = ROOT / ".config/omniwm/settings.toml"
REPO_OMNIWM_JSON = ROOT / ".config/omniwm/settings.json"
REPO_KARABINER_PATH = ROOT / ".config/karabiner.json"


def require(condition: bool, message: str, failures: list[str]) -> None:
    if not condition:
        failures.append(message)


def load_json(path: pathlib.Path) -> dict:
    return json.loads(path.read_text())


def load_toml(path: pathlib.Path) -> dict:
    return tomllib.loads(path.read_text())


def hotkey_binding(hotkeys: list[dict], hotkey_id: str) -> str | None:
    for hotkey in hotkeys:
        if hotkey.get("id") == hotkey_id:
            return hotkey.get("binding")
    return None


def karabiner_combos(path: pathlib.Path) -> set[str]:
    data = load_json(path)
    combos: set[str] = set()
    for rule in data.get("profiles", [{}])[0].get("complex_modifications", {}).get("rules", []):
        for manipulator in rule.get("manipulators", []):
            for action in manipulator.get("to", []):
                key_code = action.get("key_code")
                if not key_code:
                    continue
                modifiers = action.get("modifiers", [])
                combo = "+".join([*modifiers, key_code]) if modifiers else key_code
                combos.add(combo)
    return combos


def main() -> int:
    failures: list[str] = []

    repo_json = load_json(REPO_OMNIWM_JSON)
    repo_toml = load_toml(REPO_OMNIWM_TOML)
    live_toml = load_toml(LIVE_OMNIWM_DIR / "settings.toml")
    repo_karabiner = karabiner_combos(REPO_KARABINER_PATH)
    live_karabiner = karabiner_combos(LIVE_KARABINER_PATH)

    require(repo_toml.get("version") == 4, "repo TOML is missing version = 4", failures)
    require(live_toml.get("version") == 4, "live TOML is missing version = 4", failures)

    json_hotkeys = repo_json.get("hotkeyBindings", [])
    repo_hotkeys = repo_toml.get("hotkeys", [])
    live_hotkeys = live_toml.get("hotkeys", [])

    require(len(repo_hotkeys) == len(json_hotkeys), "repo TOML hotkey count drifted from JSON", failures)
    require(len(live_hotkeys) == len(json_hotkeys), "live TOML hotkey count drifted from JSON", failures)

    json_workspaces = repo_json.get("workspaceConfigurations", [])
    repo_workspaces = repo_toml.get("workspaces", [])
    live_workspaces = live_toml.get("workspaces", [])

    require(len(repo_workspaces) == len(json_workspaces), "repo TOML workspace count drifted from JSON", failures)
    require(len(live_workspaces) == len(json_workspaces), "live TOML workspace count drifted from JSON", failures)

    critical_hotkeys = {
        "switchWorkspace.0": "Control+Shift+Command+1",
        "moveToWorkspace.0": "Control+Option+Shift+Command+1",
        "focus.left": "Control+Option+Shift+Command+Left Arrow",
        "toggleWorkspaceLayout": "Control+Shift+Command+V",
        "openCommandPalette": "Control+Shift+Command+Space",
    }
    for hotkey_id, expected in critical_hotkeys.items():
        require(hotkey_binding(repo_hotkeys, hotkey_id) == expected, f"repo TOML changed {hotkey_id}", failures)
        require(hotkey_binding(live_hotkeys, hotkey_id) == expected, f"live TOML changed {hotkey_id}", failures)

    repo_workspace_names = {workspace["name"] for workspace in repo_workspaces}
    live_workspace_names = {workspace["name"] for workspace in live_workspaces}
    require(repo_workspace_names == {"1", "2", "3", "4", "5", "6", "7", "8", "9"}, "repo TOML workspace names changed", failures)
    require(live_workspace_names == repo_workspace_names, "live TOML workspace names drifted from repo", failures)

    workspace_six = next((workspace for workspace in repo_workspaces if workspace["name"] == "6"), {})
    workspace_eight = next((workspace for workspace in repo_workspaces if workspace["name"] == "8"), {})
    require(workspace_six.get("displayName") == "❤️", "workspace 6 lost its display name", failures)
    require(workspace_eight.get("layoutType") == "dwindle", "workspace 8 lost its dwindle layout", failures)

    expected_karabiner_combos = {
        "left_command+left_control+left_shift+1",
        "left_command+left_control+left_option+left_shift+1",
        "left_command+left_control+left_option+left_shift+left_arrow",
        "left_control+left_shift+left_command+w",
    }
    for combo in expected_karabiner_combos:
        require(combo in repo_karabiner, f"repo Karabiner is missing {combo}", failures)
        require(combo in live_karabiner, f"live Karabiner is missing {combo}", failures)

    if failures:
        print("Config snapshot verification failed:")
        for failure in failures:
            print(f"- {failure}")
        return 1

    print("Config snapshot verification passed.")
    print(f"Repo hotkeys: {len(repo_hotkeys)} | Live hotkeys: {len(live_hotkeys)}")
    print(f"Repo workspaces: {len(repo_workspaces)} | Live workspaces: {len(live_workspaces)}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
