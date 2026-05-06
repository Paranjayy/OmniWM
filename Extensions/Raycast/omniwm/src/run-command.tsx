import { Action, ActionPanel, List, showToast, Toast, Icon, Form, useNavigation } from "@raycast/api";
import { execSync } from "child_process";
import { useState } from "react";

const CTL_BIN = "/Applications/OmniWM.app/Contents/MacOS/omniwmctl";

const DIRECTIONS = [
  { title: "Left", value: "left", icon: Icon.ArrowLeft },
  { title: "Right", value: "right", icon: Icon.ArrowRight },
  { title: "Up", value: "up", icon: Icon.ArrowUp },
  { title: "Down", value: "down", icon: Icon.ArrowDown },
];

export default function Command() {
  return (
    <List searchBarPlaceholder="Search native OmniWM commands...">
      <List.Section title="Navigation">
        <CommandItem 
          name="focus" 
          title="Focus Window" 
          summary="Focus a neighboring window" 
          icon={Icon.Eye}
          hasDirections 
        />
        <CommandItem 
          name="move" 
          title="Move Window" 
          summary="Swap window in a direction" 
          icon={Icon.ArrowsUpLeftDownRight}
          hasDirections 
        />
        <CommandItem 
          name="move-column" 
          title="Move Column" 
          summary="Move the entire column (Niri)" 
          icon={Icon.ChevronUp}
          hasDirections 
        />
      </List.Section>
      
      <List.Section title="System">
        <List.Item
          title="Toggle Workspace Bar"
          subtitle="Toggle visibility of the bar"
          icon={Icon.Sidebar}
          actions={
            <ActionPanel>
              <Action title="Run Command" onAction={() => runOmniCommand("toggle-workspace-bar")} />
            </ActionPanel>
          }
        />
        <List.Item
          title="Capture Layout Snapshot"
          subtitle="Save current workspace layout"
          icon={Icon.Camera}
          actions={
            <ActionPanel>
              <Action title="Run Command" onAction={() => runOmniCommand("capture-workspace-snapshot")} />
            </ActionPanel>
          }
        />
      </List.Section>
    </List>
  );
}

function CommandItem({ name, title, summary, icon, hasDirections }: { 
  name: string; 
  title: string; 
  summary: string; 
  icon: Icon;
  hasDirections?: boolean 
}) {
  return (
    <List.Item
      title={title}
      subtitle={summary}
      icon={icon}
      actions={
        <ActionPanel>
          {hasDirections ? (
            <Action.Push title="Choose Direction" target={<DirectionPicker name={name} title={title} />} />
          ) : (
            <Action title="Run Command" onAction={() => runOmniCommand(name)} />
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
