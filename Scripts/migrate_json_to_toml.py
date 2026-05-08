#!/usr/bin/env python3

import argparse
import json
import pathlib
from typing import Any


ROOT = pathlib.Path(__file__).resolve().parents[1]
DEFAULT_JSON = pathlib.Path.home() / ".config/omniwm/settings.json"
DEFAULT_TOML = pathlib.Path.home() / ".config/omniwm/settings.toml"
REPO_TOML = ROOT / ".config/omniwm/settings.toml"


def toml_scalar(value: Any) -> str:
    if isinstance(value, bool):
        return "true" if value else "false"
    if isinstance(value, int):
        return str(value)
    if isinstance(value, float):
        return repr(value)
    if isinstance(value, str):
        escaped = value.replace("\\", "\\\\").replace('"', '\\"')
        return f'"{escaped}"'
    raise TypeError(f"Unsupported TOML scalar: {value!r}")


def toml_array(values: list[Any]) -> str:
    rendered: list[str] = []
    for value in values:
        if isinstance(value, list):
            rendered.append(toml_array(value))
        else:
            rendered.append(toml_scalar(value))
    return f"[{', '.join(rendered)}]"


def emit_key(lines: list[str], key: str, value: Any) -> None:
    if isinstance(value, list):
        lines.append(f"{key} = {toml_array(value)}")
    else:
        lines.append(f"{key} = {toml_scalar(value)}")


def add_section(lines: list[str], header: str, pairs: list[tuple[str, Any]]) -> None:
    lines.append(f"[{header}]")
    for key, value in pairs:
        emit_key(lines, key, value)
    lines.append("")


def migrate(data: dict[str, Any]) -> str:
    lines: list[str] = []

    emit_key(lines, "version", data.get("version", 4))
    emit_key(lines, "monitorBarOverrides", data.get("monitorBarSettings", []))
    emit_key(lines, "monitorDwindleOverrides", data.get("monitorDwindleSettings", []))
    emit_key(lines, "monitorNiriOverrides", data.get("monitorNiriSettings", []))
    emit_key(lines, "monitorOrientationOverrides", data.get("monitorOrientationSettings", []))
    lines.append("")

    add_section(lines, "appearance", [
        ("mode", data.get("appearanceMode", "dark")),
    ])

    add_section(lines, "borders", [
        ("enabled", data.get("bordersEnabled", True)),
        ("width", float(data.get("borderWidth", 5))),
    ])
    add_section(lines, "borders.color", [
        ("red", float(data.get("borderColorRed", 1.0))),
        ("green", float(data.get("borderColorGreen", 1.0))),
        ("blue", float(data.get("borderColorBlue", 1.0))),
        ("alpha", float(data.get("borderColorAlpha", 1.0))),
    ])

    add_section(lines, "dwindle", [
        ("defaultSplitRatio", float(data.get("dwindleDefaultSplitRatio", 1.0))),
        ("moveToRootStable", data.get("dwindleMoveToRootStable", True)),
        ("singleWindowAspectRatio", data.get("dwindleSingleWindowAspectRatio", "16:9")),
        ("smartSplit", data.get("dwindleSmartSplit", True)),
        ("splitWidthMultiplier", float(data.get("dwindleSplitWidthMultiplier", 1.0))),
        ("useGlobalGaps", data.get("dwindleUseGlobalGaps", True)),
    ])

    add_section(lines, "focus", [
        ("followsMouse", data.get("focusFollowsMouse", False)),
        ("followsWindowToMonitor", data.get("focusFollowsWindowToMonitor", False)),
        ("moveMouseToFocusedWindow", data.get("moveMouseToFocusedWindow", False)),
    ])

    add_section(lines, "gaps", [
        ("size", float(data.get("gapSize", 0.0))),
    ])
    add_section(lines, "gaps.outer", [
        ("left", float(data.get("outerGapLeft", 0.0))),
        ("right", float(data.get("outerGapRight", 0.0))),
        ("top", float(data.get("outerGapTop", 0.0))),
        ("bottom", float(data.get("outerGapBottom", 0.0))),
    ])

    add_section(lines, "general", [
        ("animationsEnabled", data.get("animationsEnabled", True)),
        ("defaultLayoutType", data.get("defaultLayoutType", "niri")),
        ("hotkeysEnabled", data.get("hotkeysEnabled", True)),
        ("ipcEnabled", data.get("ipcEnabled", True)),
        ("preventSleepEnabled", data.get("preventSleepEnabled", False)),
        ("updateChecksEnabled", data.get("updateChecksEnabled", True)),
    ])

    add_section(lines, "gestures", [
        ("fingerCount", int(data.get("gestureFingerCount", 3))),
        ("invertDirection", data.get("gestureInvertDirection", True)),
        ("scrollEnabled", data.get("scrollGestureEnabled", True)),
        ("scrollModifierKey", data.get("scrollModifierKey", "optionShift")),
        ("scrollSensitivity", float(data.get("scrollSensitivity", 5.0))),
    ])

    add_section(lines, "mouseWarp", [
        ("axis", data.get("mouseWarpAxis", "vertical")),
        ("margin", int(data.get("mouseWarpMargin", 1))),
        ("monitorOrder", data.get("mouseWarpMonitorOrder", [])),
    ])

    add_section(lines, "niri", [
        ("alwaysCenterSingleColumn", data.get("niriAlwaysCenterSingleColumn", True)),
        ("centerFocusedColumn", data.get("niriCenterFocusedColumn", "onOverflow")),
        ("columnWidthPresets", data.get("niriColumnWidthPresets", [0.3333333333333333, 0.5, 0.66])),
        ("infiniteLoop", data.get("niriInfiniteLoop", True)),
        ("maxVisibleColumns", int(data.get("niriMaxVisibleColumns", 2))),
        ("maxWindowsPerColumn", int(data.get("niriMaxWindowsPerColumn", 3))),
        ("singleWindowAspectRatio", data.get("niriSingleWindowAspectRatio", "16:9")),
    ])

    add_section(lines, "quakeTerminal", [
        ("animationDuration", float(data.get("quakeTerminalAnimationDuration", 0.2))),
        ("autoHide", data.get("quakeTerminalAutoHide", True)),
        ("enabled", data.get("quakeTerminalEnabled", True)),
        ("heightPercent", float(data.get("quakeTerminalHeightPercent", 50.0))),
        ("monitorMode", data.get("quakeTerminalMonitorMode", "focusedWindow")),
        ("opacity", float(data.get("quakeTerminalOpacity", 1.0))),
        ("position", data.get("quakeTerminalPosition", "center")),
        ("useCustomFrame", data.get("quakeTerminalUseCustomFrame", False)),
        ("widthPercent", float(data.get("quakeTerminalWidthPercent", 50.0))),
    ])

    add_section(lines, "state", [
        ("commandPaletteLastMode", data.get("commandPaletteLastMode", "windows")),
        ("hiddenBarIsCollapsed", data.get("hiddenBarIsCollapsed", False)),
    ])

    add_section(lines, "statusBar", [
        ("showAppNames", data.get("statusBarShowAppNames", True)),
        ("showWorkspaceName", data.get("statusBarShowWorkspaceName", True)),
        ("useWorkspaceId", data.get("statusBarUseWorkspaceId", True)),
    ])

    add_section(lines, "workspaceBar", [
        ("backgroundOpacity", float(data.get("workspaceBarBackgroundOpacity", 0.0))),
        ("deduplicateAppIcons", data.get("workspaceBarDeduplicateAppIcons", False)),
        ("enabled", data.get("workspaceBarEnabled", True)),
        ("height", float(data.get("workspaceBarHeight", 20.0))),
        ("hideEmptyWorkspaces", data.get("workspaceBarHideEmptyWorkspaces", True)),
        ("labelFontSize", float(data.get("workspaceBarLabelFontSize", 12.0))),
        ("notchAware", data.get("workspaceBarNotchAware", True)),
        ("position", data.get("workspaceBarPosition", "belowMenuBar")),
        ("reserveLayoutSpace", data.get("workspaceBarReserveLayoutSpace", False)),
        ("showFloatingWindows", data.get("workspaceBarShowFloatingWindows", True)),
        ("showLabels", data.get("workspaceBarShowLabels", True)),
        ("windowLevel", data.get("workspaceBarWindowLevel", "floating")),
        ("xOffset", float(data.get("workspaceBarXOffset", 0.0))),
        ("yOffset", float(data.get("workspaceBarYOffset", 0.0))),
    ])
    add_section(lines, "workspaceBar.accentColor", [
        ("red", float(data.get("workspaceBarAccentColorRed", -1.0))),
        ("green", float(data.get("workspaceBarAccentColorGreen", -1.0))),
        ("blue", float(data.get("workspaceBarAccentColorBlue", -1.0))),
        ("alpha", float(data.get("workspaceBarAccentColorAlpha", 1.0))),
    ])
    add_section(lines, "workspaceBar.textColor", [
        ("red", float(data.get("workspaceBarTextColorRed", -1.0))),
        ("green", float(data.get("workspaceBarTextColorGreen", -1.0))),
        ("blue", float(data.get("workspaceBarTextColorBlue", -1.0))),
        ("alpha", float(data.get("workspaceBarTextColorAlpha", 1.0))),
    ])

    for rule in data.get("appRules", []):
        lines.append("[[appRules]]")
        for key in ("bundleId", "id", "layout", "workspace", "minWidth", "minHeight"):
            if key not in rule:
                continue
            value = rule[key]
            if key in {"minWidth", "minHeight"}:
                value = float(value)
            emit_key(lines, key, value)
        lines.append("")

    for hotkey in data.get("hotkeyBindings", []):
        lines.append("[[hotkeys]]")
        emit_key(lines, "binding", hotkey["binding"])
        emit_key(lines, "id", hotkey["id"])
        lines.append("")

    for workspace in data.get("workspaceConfigurations", []):
        lines.append("[[workspaces]]")
        emit_key(lines, "id", workspace["id"])
        emit_key(lines, "layoutType", workspace.get("layoutType", "niri"))
        emit_key(lines, "name", workspace["name"])
        if workspace.get("displayName"):
            emit_key(lines, "displayName", workspace["displayName"])
        lines.append("")

        assignment = workspace.get("monitorAssignment", {"type": "main"})
        lines.append("[workspaces.monitorAssignment]")
        emit_key(lines, "type", assignment.get("type", "main"))
        if "output" in assignment:
            output = assignment["output"]
            lines.append("")
            lines.append("[workspaces.monitorAssignment.output]")
            if "name" in output:
                emit_key(lines, "name", output["name"])
            if "displayId" in output:
                emit_key(lines, "displayId", output["displayId"])
        lines.append("")

    return "\n".join(lines).rstrip() + "\n"


def main() -> None:
    parser = argparse.ArgumentParser(description="Migrate OmniWM settings.json to settings.toml")
    parser.add_argument("--input", type=pathlib.Path, default=DEFAULT_JSON)
    parser.add_argument("--output", type=pathlib.Path, default=DEFAULT_TOML)
    parser.add_argument("--repo-output", type=pathlib.Path, default=REPO_TOML)
    parser.add_argument("--no-repo-sync", action="store_true")
    args = parser.parse_args()

    data = json.loads(args.input.read_text())
    rendered = migrate(data)

    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(rendered)

    if not args.no_repo_sync:
        args.repo_output.parent.mkdir(parents=True, exist_ok=True)
        args.repo_output.write_text(rendered)

    print(f"Wrote {args.output}")
    if not args.no_repo_sync:
        print(f"Wrote {args.repo_output}")


if __name__ == "__main__":
    main()
