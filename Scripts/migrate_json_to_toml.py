import json
import os

# Paths
json_path = os.path.expanduser("~/Developer/OmniWM/backups/settings.json.bak")
toml_path = os.path.expanduser("~/.config/omniwm/settings.toml")

# Load JSON
with open(json_path, "r") as f:
    data = json.load(f)

def to_toml_val(v):
    if isinstance(v, bool):
        return "true" if v else "false"
    if isinstance(v, str):
        return f'"{v}"'
    if isinstance(v, (int, float)):
        return str(v)
    return str(v)

# Generate TOML
lines = []
lines.append("# OmniWM Settings (Migrated from God Build backup)")
lines.append("")

# Sections from the original TOML structure I saw
sections = {
    "appearance": ["appearanceMode:mode"],
    "borders": ["bordersEnabled:enabled", "borderWidth:width"],
    "dwindle": ["dwindleDefaultSplitRatio:defaultSplitRatio", "dwindleMoveToRootStable:moveToRootStable", "dwindleSingleWindowAspectRatio:singleWindowAspectRatio", "dwindleSmartSplit:smartSplit", "dwindleSplitWidthMultiplier:splitWidthMultiplier", "dwindleUseGlobalGaps:useGlobalGaps"],
    "focus": ["focusFollowsMouse:followsMouse", "focusFollowsWindowToMonitor:followsWindowToMonitor", "moveMouseToFocusedWindow:moveMouseToFocusedWindow"],
    "gaps": ["gapSize:size"],
    "general": ["animationsEnabled:animationsEnabled", "defaultLayoutType:defaultLayoutType", "hotkeysEnabled:hotkeysEnabled", "ipcEnabled:ipcEnabled", "preventSleepEnabled:preventSleepEnabled", "updateChecksEnabled:updateChecksEnabled"],
    "gestures": ["gestureFingerCount:fingerCount", "gestureInvertDirection:invertDirection", "scrollGestureEnabled:scrollEnabled", "scrollModifierKey:scrollModifierKey", "scrollSensitivity:scrollSensitivity"],
    "mouseWarp": ["mouseWarpAxis:axis", "mouseWarpMargin:margin", "mouseWarpMonitorOrder:monitorOrder"],
    "niri": ["niriAlwaysCenterSingleColumn:alwaysCenterSingleColumn", "niriCenterFocusedColumn:centerFocusedColumn", "niriColumnWidthPresets:columnWidthPresets", "niriInfiniteLoop:infiniteLoop", "niriMaxVisibleColumns:maxVisibleColumns", "niriMaxWindowsPerColumn:maxWindowsPerColumn", "niriSingleWindowAspectRatio:singleWindowAspectRatio"],
    "quakeTerminal": ["quakeTerminalAnimationDuration:animationDuration", "quakeTerminalAutoHide:autoHide", "quakeTerminalEnabled:enabled", "quakeTerminalHeightPercent:heightPercent", "quakeTerminalMonitorMode:monitorMode", "quakeTerminalOpacity:opacity", "quakeTerminalPosition:position", "quakeTerminalUseCustomFrame:useCustomFrame", "quakeTerminalWidthPercent:widthPercent"],
    "state": ["commandPaletteLastMode:commandPaletteLastMode", "hiddenBarIsCollapsed:hiddenBarIsCollapsed"],
    "statusBar": ["statusBarShowAppNames:showAppNames", "statusBarShowWorkspaceName:showWorkspaceName", "statusBarUseWorkspaceId:useWorkspaceId"],
    "workspaceBar": ["workspaceBarBackgroundOpacity:backgroundOpacity", "workspaceBarDeduplicateAppIcons:deduplicateAppIcons", "workspaceBarEnabled:enabled", "workspaceBarHeight:height", "workspaceBarHideEmptyWorkspaces:hideEmptyWorkspaces", "workspaceBarNotchAware:notchAware", "workspaceBarPosition:position", "workspaceBarReserveLayoutSpace:reserveLayoutSpace", "workspaceBarShowFloatingWindows:showFloatingWindows", "workspaceBarShowLabels:showLabels", "workspaceBarWindowLevel:windowLevel", "workspaceBarXOffset:xOffset", "workspaceBarYOffset:yOffset"]
}

for section, fields in sections.items():
    lines.append(f"[{section}]")
    for field in fields:
        json_key, toml_key = field.split(":")
        val = data.get(json_key)
        if val is not None:
            lines.append(f"{toml_key} = {to_toml_val(val)}")
    lines.append("")

# Special sections
lines.append("[borders.color]")
lines.append(f"alpha = {to_toml_val(data.get('borderColorAlpha', 1.0))}")
lines.append(f"blue = {to_toml_val(data.get('borderColorBlue', 0.0))}")
lines.append(f"green = {to_toml_val(data.get('borderColorGreen', 0.0))}")
lines.append(f"red = {to_toml_val(data.get('borderColorRed', 0.0))}")
lines.append("")

lines.append("[gaps.outer]")
lines.append(f"bottom = {to_toml_val(data.get('outerGapBottom', 0.0))}")
lines.append(f"left = {to_toml_val(data.get('outerGapLeft', 0.0))}")
lines.append(f"right = {to_toml_val(data.get('outerGapRight', 0.0))}")
lines.append(f"top = {to_toml_val(data.get('outerGapTop', 0.0))}")
lines.append("")

# App Rules
for rule in data.get('appRules', []):
    lines.append("[[appRules]]")
    for k, v in rule.items():
        lines.append(f"{k} = {to_toml_val(v)}")
    lines.append("")

# Hotkeys - This is the critical part
print(f"Migrating {len(data.get('hotkeyBindings', []))} hotkeys...")
for binding in data.get('hotkeyBindings', []):
    b = binding.get('binding', 'Unassigned')
    id = binding.get('id', '')
    lines.append("[[hotkeys]]")
    lines.append(f"binding = {to_toml_val(b)}")
    lines.append(f"id = {to_toml_val(id)}")
    lines.append("")
    if "focus.left" in id:
        print(f"DEBUG: focus.left binding is {b}")

# Workspaces
for ws in data.get('workspaceConfigurations', []):
    lines.append("[[workspaces]]")
    lines.append(f"id = {to_toml_val(ws.get('id', ''))}")
    lines.append(f"layoutType = {to_toml_val(ws.get('layoutType', 'niri'))}")
    lines.append(f"name = {to_toml_val(ws.get('name', ''))}")
    if 'displayName' in ws:
        lines.append(f"displayName = {to_toml_val(ws['displayName'])}")
    
    ma = ws.get('monitorAssignment', {})
    lines.append("[workspaces.monitorAssignment]")
    lines.append(f"type = {to_toml_val(ma.get('type', 'main'))}")
    lines.append("")

with open(toml_path, "w") as f:
    f.write("\n".join(lines))

print("✅ Migrated settings.json.bak to settings.toml")
