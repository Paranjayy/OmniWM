import { Action, ActionPanel, List, showToast, Toast, Icon } from "@raycast/api";
import { execSync } from "child_process";
import { useState, useEffect } from "react";

interface WorkspaceEntry {
  id: string;
  rawName: string;
  displayName: string;
  monitorId?: string;
  isFocused: boolean;
  counts?: {
    total: number;
    tiled: number;
    floating: number;
  };
}

const CTL_BIN = "/Applications/OmniWM.app/Contents/MacOS/omniwmctl";

export default function Command() {
  const [workspaces, setWorkspaces] = useState<WorkspaceEntry[]>([]);
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    refreshWorkspaces();
  }, []);

  const refreshWorkspaces = () => {
    try {
      const output = execSync(`${CTL_BIN} query workspaces --format json`).toString();
      const parsed = JSON.parse(output);
      if (parsed.result && parsed.result.payload && parsed.result.payload.workspaces) {
        setWorkspaces(parsed.result.payload.workspaces);
      }
    } catch (error) {
      showToast({
        style: Toast.Style.Failure,
        title: "Failed to query workspaces",
        message: String(error),
      });
    } finally {
      setIsLoading(false);
    }
  };

  const switchWorkspace = async (name: string) => {
    try {
      execSync(`${CTL_BIN} command switch-workspace ${name}`);
      showToast({ title: `Switched to workspace ${name}` });
    } catch (error) {
      showToast({
        style: Toast.Style.Failure,
        title: "Failed to switch workspace",
        message: String(error),
      });
    }
  };

  const activeWorkspaces = workspaces.filter(ws => ws.counts && ws.counts.total > 0);
  const inactiveWorkspaces = workspaces.filter(ws => !ws.counts || ws.counts.total === 0);

  return (
    <List isLoading={isLoading} searchBarPlaceholder="Search workspaces...">
      <List.Section title="Active Workspaces">
        {activeWorkspaces.map((ws) => (
          <WorkspaceItem key={ws.id} ws={ws} onSwitch={switchWorkspace} />
        ))}
      </List.Section>
      <List.Section title="Inactive Workspaces">
        {inactiveWorkspaces.map((ws) => (
          <WorkspaceItem key={ws.id} ws={ws} onSwitch={switchWorkspace} />
        ))}
      </List.Section>
    </List>
  );
}

function WorkspaceItem({ ws, onSwitch }: { ws: WorkspaceEntry; onSwitch: (name: string) => void }) {
  return (
    <List.Item
      title={ws.displayName}
      subtitle={`Workspace ${ws.rawName} (${ws.counts?.total || 0} windows)`}
      accessories={[
        { icon: ws.isFocused ? Icon.CheckCircle : undefined },
      ]}
      actions={
        <ActionPanel>
          <Action title="Switch to Workspace" onAction={() => onSwitch(ws.rawName)} />
          <Action 
            title="Capture Layout Snapshot" 
            icon={Icon.Camera}
            onAction={async () => {
              try {
                execSync(`${CTL_BIN} command capture-workspace-snapshot`);
                showToast({ title: "Snapshot captured" });
              } catch (e) {
                showToast({ style: Toast.Style.Failure, title: "Failed to capture snapshot" });
              }
            }} 
            shortcut={{ modifiers: ["cmd"], key: "s" }}
          />
        </ActionPanel>
      }
    />
  );
}
