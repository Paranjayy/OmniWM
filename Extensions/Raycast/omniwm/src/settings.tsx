import { Action, ActionPanel, List, showToast, Toast, Icon, Color } from "@raycast/api";
import { execSync } from "child_process";
import { useState, useEffect } from "react";

interface Settings {
  activeProfile: string;
  animationsEnabled: boolean;
  workspaceBarEnabled: boolean;
  gapSize: number;
  borderWidth: number;
  bordersEnabled: boolean;
  focusFollowsMouse: boolean;
  appearanceMode: string;
  niriDefaultColumnWidth: number | null;
  niriMaxWindowsPerColumn: number;
  niriInfiniteLoop: boolean;
  dwindleSmartSplit: boolean;
  quakeTerminalOpacity: number;
  warpSwitcherEnabled: boolean;
  hotkeysEnabled: boolean;
  focusFollowsWindowToMonitor: boolean;
  mouseWarpAxis: string;
  niriMaxVisibleColumns: number;
  dwindleDefaultSplitRatio: number;
  workspaceBackJumpEnabled: boolean;
  preventSleepEnabled: boolean;
  quakeTerminalEnabled: boolean;
  quakeTerminalAutoHide: boolean;
  windowTrashEnabled: boolean;
  sessionSnapshotEnabled: boolean;
  moveMouseToFocusedWindow: boolean;
  mouseWarpMargin: number;
  outerGapLeft: number;
  outerGapRight: number;
  outerGapTop: number;
  outerGapBottom: number;
  niriCenterFocusedColumn: string;
  niriAlwaysCenterSingleColumn: boolean;
  dwindleSplitWidthMultiplier: number;
  workspaceBarShowLabels: boolean;
  workspaceBarShowFloatingWindows: boolean;
  workspaceBarNotchAware: boolean;
  workspaceBarReserveLayoutSpace: boolean;
  workspaceBarDeduplicateAppIcons: boolean;
  workspaceBarHideEmptyWorkspaces: boolean;
  workspaceBarHeight: number;
  workspaceBarBackgroundOpacity: number;
  workspaceBarXOffset: number;
  workspaceBarYOffset: number;
  statusBarShowWorkspaceName: boolean;
  statusBarShowAppNames: boolean;
  statusBarUseWorkspaceId: boolean;
  quakeTerminalPosition: string;
  quakeTerminalWidthPercent: number;
  quakeTerminalHeightPercent: number;
  quakeTerminalAnimationDuration: number;
  scrollGestureEnabled: boolean;
  scrollSensitivity: number;
  scrollModifierKey: string;
  gestureFingerCount: number;
  gestureInvertDirection: boolean;
}

const CTL_BIN = "/Applications/OmniWM.app/Contents/MacOS/omniwmctl";
const DOMAIN = "com.barut.OmniWM";

export default function Command() {
  const [settings, setSettings] = useState<Settings | null>(null);
  const [vitals, setVitals] = useState<{ cpu: string; mem: string } | null>(null);
  const [isLoading, setIsLoading] = useState(true);
  const [isVanilla, setIsVanilla] = useState(false);

  useEffect(() => {
    fetchSettings();
    fetchVitals();
    const interval = setInterval(fetchVitals, 5000);
    return () => clearInterval(interval);
  }, []);

  const fetchVitals = () => {
    try {
      const cpu = execSync("top -l 1 | grep 'CPU usage' | awk '{print $3}'").toString().trim();
      const mem = execSync("top -l 1 | grep 'PhysMem' | awk '{print $2}'").toString().trim();
      setVitals({ cpu, mem });
    } catch (e) {
      // Silence vitals error
    }
  };

  const fetchSettings = () => {
    try {
      // Try IPC first (best for source build)
      const output = execSync(`${CTL_BIN} query settings --format json`).toString();
      const parsed = JSON.parse(output);
      if (parsed.result && parsed.result.payload && parsed.result.payload.settings) {
        setSettings(parsed.result.payload.settings);
        setIsVanilla(false);
        setIsLoading(false);
        return;
      }
    } catch (error) {
      // Fallback to defaults read for vanilla
    }

    try {
      const defaults = execSync(`defaults read ${DOMAIN}`).toString();
      // Simple parser for defaults output (not perfect but works for most)
      const getBool = (key: string) => defaults.includes(`"settings.${key}" = 1`);
      const getString = (key: string) => {
        const match = defaults.match(new RegExp(`"settings.${key}" = (.*?);`));
        return match ? match[1] : "";
      };
      const getNum = (key: string) => {
        const match = defaults.match(new RegExp(`"settings.${key}" = (.*?);`));
        return match ? parseFloat(match[1]) : 0;
      };

      setSettings({
        activeProfile: getString("activeProfile") || "official",
        animationsEnabled: getBool("animationsEnabled"),
        workspaceBarEnabled: getBool("workspaceBar.enabled"),
        gapSize: getNum("gapSize"),
        borderWidth: getNum("borderWidth"),
        bordersEnabled: getBool("bordersEnabled"),
        focusFollowsMouse: getBool("focusFollowsMouse"),
        appearanceMode: getString("appearanceMode") || "dark",
        niriDefaultColumnWidth: getNum("niriDefaultColumnWidth"),
        niriMaxWindowsPerColumn: getNum("niriMaxWindowsPerColumn"),
        niriInfiniteLoop: getBool("niriInfiniteLoop"),
        dwindleSmartSplit: getBool("dwindleSmartSplit"),
        quakeTerminalOpacity: getNum("quakeTerminal.opacity"),
        warpSwitcherEnabled: getBool("warpSwitcherEnabled"),
        hotkeysEnabled: getBool("hotkeysEnabled"),
        focusFollowsWindowToMonitor: getBool("focusFollowsWindowToMonitor"),
        mouseWarpAxis: getString("mouseWarp.axis") || "horizontal",
        niriMaxVisibleColumns: getNum("niriMaxVisibleColumns"),
        dwindleDefaultSplitRatio: getNum("dwindleDefaultSplitRatio"),
        workspaceBackJumpEnabled: getBool("workspaceBackJumpEnabled"),
        preventSleepEnabled: getBool("preventSleepEnabled"),
        quakeTerminalEnabled: getBool("quakeTerminal.enabled"),
        quakeTerminalAutoHide: getBool("quakeTerminal.autoHide"),
        windowTrashEnabled: getBool("windowTrashEnabled"),
        sessionSnapshotEnabled: getBool("sessionSnapshotEnabled"),
        moveMouseToFocusedWindow: getBool("moveMouseToFocusedWindow"),
        mouseWarpMargin: getNum("mouseWarp.margin"),
        outerGapLeft: getNum("outerGapLeft"),
        outerGapRight: getNum("outerGapRight"),
        outerGapTop: getNum("outerGapTop"),
        outerGapBottom: getNum("outerGapBottom"),
        niriCenterFocusedColumn: getString("niriCenterFocusedColumn") || "never",
        niriAlwaysCenterSingleColumn: getBool("niriAlwaysCenterSingleColumn"),
        dwindleSplitWidthMultiplier: getNum("dwindleSplitWidthMultiplier"),
        workspaceBarShowLabels: getBool("workspaceBar.showLabels"),
        workspaceBarShowFloatingWindows: getBool("workspaceBar.showFloatingWindows"),
        workspaceBarNotchAware: getBool("workspaceBar.notchAware"),
        workspaceBarReserveLayoutSpace: getBool("workspaceBar.reserveLayoutSpace"),
        workspaceBarDeduplicateAppIcons: getBool("workspaceBar.deduplicateAppIcons"),
        workspaceBarHideEmptyWorkspaces: getBool("workspaceBar.hideEmptyWorkspaces"),
        workspaceBarHeight: getNum("workspaceBar.height"),
        workspaceBarBackgroundOpacity: getNum("workspaceBar.backgroundOpacity"),
        workspaceBarXOffset: getNum("workspaceBar.xOffset"),
        workspaceBarYOffset: getNum("workspaceBar.yOffset"),
        statusBarShowWorkspaceName: getBool("statusBarShowWorkspaceName"),
        statusBarShowAppNames: getBool("statusBarShowAppNames"),
        statusBarUseWorkspaceId: getBool("statusBarUseWorkspaceId"),
        quakeTerminalPosition: getString("quakeTerminal.position") || "center",
        quakeTerminalWidthPercent: getNum("quakeTerminal.widthPercent"),
        quakeTerminalHeightPercent: getNum("quakeTerminal.heightPercent"),
        quakeTerminalAnimationDuration: getNum("quakeTerminal.animationDuration"),
        scrollGestureEnabled: getBool("scrollGestureEnabled"),
        scrollSensitivity: getNum("scrollSensitivity"),
        scrollModifierKey: getString("scrollModifierKey") || "optionShift",
        gestureFingerCount: getNum("gestureFingerCount"),
        gestureInvertDirection: getBool("gestureInvertDirection"),
      });
      setIsVanilla(true);
    } catch (e) {
      // Fail
    } finally {
      setIsLoading(false);
    }
  };

  const updateSetting = async (key: string, value: string, type: "bool" | "string" | "float" | "int" = "string") => {
    try {
      if (isVanilla) {
        // Vanilla fallback: use defaults write
        let writeVal = value;
        let writeType = "-string";
        if (type === "bool") {
          writeVal = value === "true" ? "YES" : "NO";
          writeType = "-bool";
        } else if (type === "int") {
          writeType = "-int";
        } else if (type === "float") {
          writeType = "-float";
        }
        
        // Map keys back to defaults format
        let defaultsKey = `settings.${key}`;
        if (key.startsWith("workspaceBar")) {
            const part = key.replace("workspaceBar", "");
            defaultsKey = `settings.workspaceBar.${part.charAt(0).toLowerCase() + part.slice(1)}`;
        } else if (key.startsWith("quakeTerminal")) {
            const part = key.replace("quakeTerminal", "");
            defaultsKey = `settings.quakeTerminal.${part.charAt(0).toLowerCase() + part.slice(1)}`;
        }
        
        execSync(`defaults write ${DOMAIN} "${defaultsKey}" ${writeType} ${writeVal}`);
        showToast({ title: `Updated ${key} (Requires App Restart)`, message: "Vanilla app needs a restart to apply some changes." });
      } else {
        execSync(`${CTL_BIN} command set-setting ${key} ${value}`);
        showToast({ title: `Updated ${key}` });
      }
      fetchSettings();
    } catch (error) {
      showToast({
        style: Toast.Style.Failure,
        title: `Failed to update ${key}`,
        message: String(error),
      });
    }
  };

  return (
    <List isLoading={isLoading} searchBarPlaceholder="Filter settings...">
      {isVanilla && (
        <List.Section title="Operational Status">
          <List.Item
            icon={{ source: Icon.Info, color: Color.Blue }}
            title="Vanilla Bridge Active"
            subtitle="Reading directly from System Defaults"
            accessories={[{ text: "Some changes may require app restart" }]}
          />
        </List.Section>
      )}

      <List.Section title="System Status & Profile">
        <List.Item
          icon={Icon.Person}
          title="Active Profile"
          subtitle={settings?.activeProfile}
          accessories={[{ text: "OmniWM Overhead: < 1%", icon: Icon.CheckmarkCircle }]}
          actions={
            <ActionPanel>
              <Action title="Set Official" onAction={() => updateSetting("activeProfile", "official")} />
              <Action title="Set Experimental" onAction={() => updateSetting("activeProfile", "experimental")} />
            </ActionPanel>
          }
        />
        <List.Item
          icon={Icon.CircleFilled}
          title="CPU Usage"
          subtitle={vitals?.cpu || "Calculating..."}
        />
        <List.Item
          icon={Icon.Circle}
          title="Memory Pressure"
          subtitle={vitals?.mem || "Calculating..."}
        />
      </List.Section>

      <List.Section title="Core Interaction">
        <List.Item
          icon={settings?.hotkeysEnabled ? { source: Icon.Checkmark, color: Color.Green } : Icon.Circle}
          title="Global Hotkeys"
          subtitle={settings?.hotkeysEnabled ? "Enabled" : "Disabled"}
          actions={
            <ActionPanel>
              <Action
                title="Toggle Hotkeys"
                onAction={() => updateSetting("hotkeysEnabled", (!settings?.hotkeysEnabled).toString(), "bool")}
              />
            </ActionPanel>
          }
        />
        <List.Item
          icon={settings?.focusFollowsMouse ? { source: Icon.Eye, color: Color.Blue } : Icon.Circle}
          title="Focus Follows Mouse"
          subtitle={settings?.focusFollowsMouse ? "On" : "Off"}
          actions={
            <ActionPanel>
              <Action title="Toggle" onAction={() => updateSetting("focusFollowsMouse", (!settings?.focusFollowsMouse).toString(), "bool")} />
            </ActionPanel>
          }
        />
        <List.Item
          icon={Icon.Appearance}
          title="Appearance Mode"
          subtitle={settings?.appearanceMode}
          actions={
            <ActionPanel>
              <Action title="Set Dark" onAction={() => updateSetting("appearanceMode", "dark")} />
              <Action title="Set Light" onAction={() => updateSetting("appearanceMode", "light")} />
              <Action title="Set System" onAction={() => updateSetting("appearanceMode", "system")} />
            </ActionPanel>
          }
        />
        <List.Item
          icon={settings?.animationsEnabled ? { source: Icon.Star, color: Color.Yellow } : Icon.Circle}
          title="Smooth Animations"
          subtitle={settings?.animationsEnabled ? "On" : "Off"}
          actions={
            <ActionPanel>
              <Action title="Toggle" onAction={() => updateSetting("animationsEnabled", (!settings?.animationsEnabled).toString(), "bool")} />
            </ActionPanel>
          }
        />
      </List.Section>

      <List.Section title="Gaps & Borders (Visuals)">
        <List.Item
          icon={Icon.DistributeSpacingHorizontal}
          title="Inner Gap Size"
          subtitle={`${settings?.gapSize}px`}
          actions={
            <ActionPanel>
              <Action title="Set 8px" onAction={() => updateSetting("gapSize", "8", "float")} />
              <Action title="Set 12px" onAction={() => updateSetting("gapSize", "12", "float")} />
              <Action title="Set 16px" onAction={() => updateSetting("gapSize", "16", "float")} />
            </ActionPanel>
          }
        />
        <List.Item
          icon={Icon.Box}
          title="Window Borders"
          subtitle={settings?.bordersEnabled ? `Enabled (${settings?.borderWidth}px)` : "Disabled"}
          actions={
            <ActionPanel>
              <Action title="Toggle Borders" onAction={() => updateSetting("bordersEnabled", (!settings?.bordersEnabled).toString(), "bool")} />
              <Action title="Increase Width" onAction={() => updateSetting("borderWidth", ((settings?.borderWidth || 1) + 1).toString(), "float")} />
              <Action title="Decrease Width" onAction={() => updateSetting("borderWidth", Math.max(1, (settings?.borderWidth || 1) - 1).toString(), "float")} />
            </ActionPanel>
          }
        />
      </List.Section>

      <List.Section title="Niri Layout Advanced">
        <List.Item
          icon={Icon.Center}
          title="Centering Mode"
          subtitle={settings?.niriCenterFocusedColumn}
          actions={
            <ActionPanel>
              <Action title="Set Always" onAction={() => updateSetting("niriCenterFocusedColumn", "always")} />
              <Action title="Set Never" onAction={() => updateSetting("niriCenterFocusedColumn", "never")} />
            </ActionPanel>
          }
        />
        <List.Item
          icon={Icon.Repeat}
          title="Infinite Loop"
          subtitle={settings?.niriInfiniteLoop ? "Enabled" : "Disabled"}
          actions={
            <ActionPanel>
              <Action title="Toggle" onAction={() => updateSetting("niriInfiniteLoop", (!settings?.niriInfiniteLoop).toString(), "bool")} />
            </ActionPanel>
          }
        />
      </List.Section>

      <List.Section title="Workspace Bar Geometry">
        <List.Item
          icon={Icon.BarChart}
          title="Bar Height"
          subtitle={`${settings?.workspaceBarHeight}px`}
          actions={
            <ActionPanel>
              <Action title="Increase" onAction={() => updateSetting("workspaceBarHeight", ((settings?.workspaceBarHeight || 40) + 2).toString(), "float")} />
              <Action title="Decrease" onAction={() => updateSetting("workspaceBarHeight", Math.max(20, (settings?.workspaceBarHeight || 40) - 2).toString(), "float")} />
            </ActionPanel>
          }
        />
        <List.Item
          icon={Icon.Eye}
          title="Background Opacity"
          subtitle={`${Math.round((settings?.workspaceBarBackgroundOpacity || 0) * 100)}%`}
          actions={
            <ActionPanel>
              <Action title="Increase" onAction={() => updateSetting("workspaceBarBackgroundOpacity", Math.min(1.0, (settings?.workspaceBarBackgroundOpacity || 0) + 0.1).toString(), "float")} />
              <Action title="Decrease" onAction={() => updateSetting("workspaceBarBackgroundOpacity", Math.max(0.0, (settings?.workspaceBarBackgroundOpacity || 0) - 0.1).toString(), "float")} />
            </ActionPanel>
          }
        />
      </List.Section>

      <List.Section title="Gestures & Input">
        <List.Item
          icon={Icon.ChevronUp}
          title="Scroll Gesture"
          subtitle={settings?.scrollGestureEnabled ? `Enabled (Sens: ${settings?.scrollSensitivity})` : "Disabled"}
          actions={
            <ActionPanel>
              <Action title="Toggle" onAction={() => updateSetting("scrollGestureEnabled", (!settings?.scrollGestureEnabled).toString(), "bool")} />
              <Action title="Increase Sensitivity" onAction={() => updateSetting("scrollSensitivity", ((settings?.scrollSensitivity || 1.0) + 0.1).toString(), "float")} />
            </ActionPanel>
          }
        />
        <List.Item
          icon={Icon.Hand}
          title="Finger Count"
          subtitle={`${settings?.gestureFingerCount} Fingers`}
          actions={
            <ActionPanel>
              <Action title="3 Fingers" onAction={() => updateSetting("gestureFingerCount", "3", "int")} />
              <Action title="4 Fingers" onAction={() => updateSetting("gestureFingerCount", "4", "int")} />
            </ActionPanel>
          }
        />
      </List.Section>
    </List>
  );
}
