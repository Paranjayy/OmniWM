import { Action, ActionPanel, List, showToast, Toast, Icon, Color, useNavigation, Keyboard } from "@raycast/api";
import { execSync } from "child_process";

const CTL_BIN = "/Applications/OmniWM.app/Contents/MacOS/omniwmctl";

const DIRECTIONS = [
  { title: "Left", value: "left", icon: Icon.ArrowLeft, shortcut: { modifiers: ["cmd"], key: "left" } as Keyboard.Shortcut },
  { title: "Right", value: "right", icon: Icon.ArrowRight, shortcut: { modifiers: ["cmd"], key: "right" } as Keyboard.Shortcut },
  { title: "Up", value: "up", icon: Icon.ArrowUp, shortcut: { modifiers: ["cmd"], key: "up" } as Keyboard.Shortcut },
  { title: "Down", value: "down", icon: Icon.ArrowDown, shortcut: { modifiers: ["cmd"], key: "down" } as Keyboard.Shortcut },
];

const PRESETS = [
  { title: "Half Screen (50%)", value: "0.5", icon: Icon.Sidebar },
  { title: "Golden Ratio (61%)", value: "0.618", icon: Icon.Stars },
  { title: "Third Screen (33%)", value: "0.333", icon: Icon.DistributeSpacingHorizontal },
  { title: "Quarter Screen (25%)", value: "0.25", icon: Icon.AppWindowSmall },
];

export default function Command() {
  return (
    <List searchBarPlaceholder="Search native OmniWM commands...">
      <List.Section title="Navigation & Movement">
        <CommandItem 
          name="focus" 
          title="Focus Neighbor" 
          summary="Switch focus to adjacent window" 
          icon={Icon.Eye}
          color={Color.Blue}
          hasDirections 
        />
        <CommandItem 
          name="move" 
          title="Move Window" 
          summary="Swap current window with neighbor" 
          icon={Icon.ArrowsUpLeftDownRight}
          color={Color.Orange}
          hasDirections 
        />
        <CommandItem 
          name="move-column" 
          title="Move Column" 
          summary="Move the entire column (Niri layout)" 
          icon={Icon.ChevronUp}
          color={Color.Purple}
          hasDirections 
        />
      </List.Section>

      <List.Section title="Sizing Presets (Niri)">
        {PRESETS.map(preset => (
          <List.Item
            key={preset.value}
            title={preset.title}
            icon={{ source: preset.icon, color: Color.Green }}
            actions={
              <ActionPanel>
                <Action title="Apply Width" onAction={() => runOmniCommand(`set-column-width ${preset.value}`)} />
              </ActionPanel>
            }
          />
        ))}
      </List.Section>

      <List.Section title="Layout Control">
        <List.Item
          title="Toggle Full Width"
          subtitle="Maximized column mode"
          icon={{ source: Icon.DistributeSpacingHorizontal, color: Color.Yellow }}
          actions={
            <ActionPanel>
              <Action title="Run Command" onAction={() => runOmniCommand("toggle-column-full-width")} />
            </ActionPanel>
          }
        />
        <List.Item
          title="Cycle Width (Forward)"
          subtitle="Increase column width preset"
          icon={Icon.Maximize}
          actions={
            <ActionPanel>
              <Action title="Run" onAction={() => runOmniCommand("cycle-column-width forward")} />
            </ActionPanel>
          }
        />
        <List.Item
          title="Balance Sizes"
          subtitle="Equalize window space"
          icon={Icon.CircleGrid3x3}
          actions={
            <ActionPanel>
              <Action title="Run" onAction={() => runOmniCommand("balance-sizes")} />
            </ActionPanel>
          }
        />
      </List.Section>
      
      <List.Section title="System Recovery">
        <List.Item
          title="Rescue Offscreen Windows"
          subtitle="Bring lost windows back to view"
          icon={{ source: Icon.Lifesaver, color: Color.Red }}
          actions={
            <ActionPanel>
              <Action title="Rescue" onAction={() => runOmniCommand("rescue-offscreen-windows")} />
            </ActionPanel>
          }
        />
        <List.Item
          title="Capture Snapshot"
          subtitle="Save layout forensics"
          icon={Icon.Camera}
          actions={
            <ActionPanel>
              <Action title="Capture" onAction={() => runOmniCommand("capture-workspace-snapshot")} />
            </ActionPanel>
          }
        />
      </List.Section>
    </List>
  );
}

function CommandItem({ name, title, summary, icon, color, hasDirections }: { 
  name: string; 
  title: string; 
  summary: string; 
  icon: Icon;
  color?: Color;
  hasDirections?: boolean 
}) {
  const { push } = useNavigation();

  return (
    <List.Item
      title={title}
      subtitle={summary}
      icon={{ source: icon, color }}
      actions={
        <ActionPanel>
          {hasDirections ? (
            <>
              {DIRECTIONS.map(dir => (
                <Action 
                  key={dir.value}
                  title={`${title} ${dir.title}`} 
                  icon={dir.icon}
                  onAction={() => runOmniCommand(`${name} ${dir.value}`)} 
                  shortcut={dir.shortcut}
                />
              ))}
              <Action 
                title="Open Direction Picker" 
                icon={Icon.List}
                onAction={() => push(<DirectionPicker name={name} title={title} />)} 
              />
            </>
          ) : (
            <Action title="Run Command" icon={Icon.Terminal} onAction={() => runOmniCommand(name)} />
          )}
        </ActionPanel>
      }
    />
  );
}

function DirectionPicker({ name, title }: { name: string; title: string }) {
  const { pop } = useNavigation();
  
  return (
    <List title={title} searchBarPlaceholder="Select direction...">
      {DIRECTIONS.map((dir) => (
        <List.Item
          key={dir.value}
          title={dir.title}
          icon={dir.icon}
          actions={
            <ActionPanel>
              <Action 
                title={`Confirm ${dir.title}`} 
                onAction={() => {
                  runOmniCommand(`${name} ${dir.value}`);
                  pop();
                }} 
              />
            </ActionPanel>
          }
        />
      ))}
    </List>
  );
}

async function runOmniCommand(cmd: string) {
  try {
    execSync(`${CTL_BIN} command ${cmd}`);
    showToast({ title: "Executed", message: cmd });
  } catch (error) {
    showToast({
      style: Toast.Style.Failure,
      title: "Failed",
      message: String(error),
    });
  }
}
