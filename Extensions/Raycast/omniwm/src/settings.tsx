import { Action, ActionPanel, List, showToast, Toast, Icon, Color } from "@raycast/api";
import { execSync } from "child_process";
import { useState, useEffect } from "react";

interface Settings {
  animationsEnabled: boolean;
  workspaceBarEnabled: boolean;
  gapSize: number;
  borderWidth: number;
  bordersEnabled: boolean;
  focusFollowsMouse: boolean;
  appearanceMode: string;
}

const CTL_BIN = "/Applications/OmniWM.app/Contents/MacOS/omniwmctl";

export default function Command() {
  const [settings, setSettings] = useState<Settings | null>(null);
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    fetchSettings();
  }, []);

  const fetchSettings = () => {
    try {
      const output = execSync(`${CTL_BIN} query settings --format json`).toString();
      const parsed = JSON.parse(output);
      if (parsed.result && parsed.result.payload && parsed.result.payload.settings) {
        setSettings(parsed.result.payload.settings);
      }
    } catch (error) {
      showToast({
        style: Toast.Style.Failure,
        title: "Failed to fetch settings",
        message: String(error),
      });
    } finally {
      setIsLoading(false);
    }
  };

  const updateSetting = async (key: string, value: string) => {
    try {
      execSync(`${CTL_BIN} command set-setting ${key} ${value}`);
      showToast({ title: `Updated ${key}` });
      fetchSettings();
    } catch (error) {
      showToast({
        style: Toast.Style.Failure,
        title: `Failed to update ${key}`,
        message: String(error),
      });
    }
  };

  if (!settings && !isLoading) {
    return (
      <List>
        <List.EmptyView title="Could not load settings" description="Make sure OmniWM is running." />
      </List>
    );
  }

  return (
    <List isLoading={isLoading} searchBarPlaceholder="Filter settings...">
      <List.Section title="General">
        <List.Item
          icon={settings?.animationsEnabled ? Icon.Checkmark : Icon.Circle}
          title="Animations"
          subtitle={settings?.animationsEnabled ? "Enabled" : "Disabled"}
          actions={
            <ActionPanel>
              <Action
                title="Toggle Animations"
                onAction={() => updateSetting("animationsEnabled", (!settings?.animationsEnabled).toString())}
              />
            </ActionPanel>
          }
        />
        <List.Item
          icon={settings?.focusFollowsMouse ? Icon.Checkmark : Icon.Circle}
          title="Focus Follows Mouse"
          subtitle={settings?.focusFollowsMouse ? "Enabled" : "Disabled"}
          actions={
            <ActionPanel>
              <Action
                title="Toggle Focus Follows Mouse"
                onAction={() => updateSetting("focusFollowsMouse", (!settings?.focusFollowsMouse).toString())}
              />
            </ActionPanel>
          }
        />
      </List.Section>

      <List.Section title="Appearance">
        <List.Item
          icon={Icon.EyeDropper}
          title="Appearance Mode"
          subtitle={settings?.appearanceMode}
          actions={
            <ActionPanel>
              <Action title="Set to Light" onAction={() => updateSetting("appearanceMode", "light")} />
              <Action title="Set to Dark" onAction={() => updateSetting("appearanceMode", "dark")} />
              <Action title="Set to System" onAction={() => updateSetting("appearanceMode", "system")} />
            </ActionPanel>
          }
        />
        <List.Item
          icon={settings?.bordersEnabled ? Icon.Rectangle : Icon.Circle}
          title="Window Borders"
          subtitle={settings?.bordersEnabled ? "Enabled" : "Disabled"}
          actions={
            <ActionPanel>
              <Action
                title="Toggle Borders"
                onAction={() => updateSetting("bordersEnabled", (!settings?.bordersEnabled).toString())}
              />
            </ActionPanel>
          }
        />
      </List.Section>

      <List.Section title="Layout">
        <List.Item
          icon={Icon.DistributeSpacingHorizontal}
          title="Gap Size"
          subtitle={`${settings?.gapSize}px`}
          actions={
            <ActionPanel>
              <Action title="Increase ( +2 )" onAction={() => updateSetting("gapSize", ((settings?.gapSize || 0) + 2).toString())} />
              <Action title="Decrease ( -2 )" onAction={() => updateSetting("gapSize", Math.max(0, (settings?.gapSize || 0) - 2).toString())} />
            </ActionPanel>
          }
        />
        <List.Item
          icon={Icon.LineHorizontal3}
          title="Border Width"
          subtitle={`${settings?.borderWidth}px`}
          actions={
            <ActionPanel>
              <Action title="Increase ( +1 )" onAction={() => updateSetting("borderWidth", ((settings?.borderWidth || 0) + 1).toString())} />
              <Action title="Decrease ( -1 )" onAction={() => updateSetting("borderWidth", Math.max(0, (settings?.borderWidth || 0) - 1).toString())} />
            </ActionPanel>
          }
        />
      </List.Section>

      <List.Section title="Workspace Bar">
        <List.Item
          icon={settings?.workspaceBarEnabled ? Icon.BarChart : Icon.Circle}
          title="Workspace Bar"
          subtitle={settings?.workspaceBarEnabled ? "Visible" : "Hidden"}
          actions={
            <ActionPanel>
              <Action
                title="Toggle Workspace Bar"
                onAction={() => updateSetting("workspaceBarEnabled", (!settings?.workspaceBarEnabled).toString())}
              />
            </ActionPanel>
          }
        />
      </List.Section>
    </List>
  );
}
