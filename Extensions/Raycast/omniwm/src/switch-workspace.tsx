import { Action, ActionPanel, List, showToast, Toast, Icon } from "@raycast/api";
import { execSync } from "child_process";
import { useState, useEffect } from "react";

interface WorkspaceEntry {
  id: string;
  name: string;
  displayName?: string;
  monitorId?: string;
  isActive: boolean;
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
      // We don't have a direct 'query workspaces' yet in the manifest, 
      // but we can get them from 'query workspace-bar'
      const output = execSync(`${CTL_BIN} query workspace-bar --format json`).toString();
      const parsed = JSON.parse(output);
      if (parsed.result && parsed.result.payload && parsed.result.payload.monitors) {
        const allWorkspaces: WorkspaceEntry[] = [];
        parsed.result.payload.monitors.forEach((mon: any) => {
          mon.workspaces.forEach((ws: any) => {
            allWorkspaces.push({
              id: ws.id,
              name: ws.name,
              displayName: ws.displayName,
              monitorId: mon.id,
              isActive: ws.isActive
            });
          });
        });
        setWorkspaces(allWorkspaces);
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
      execSync(`${CTL_BIN} command switch-workspace --name ${name}`);
      showToast({ title: `Switched to workspace ${name}` });
    } catch (error) {
      showToast({
        style: Toast.Style.Failure,
        title: "Failed to switch workspace",
        message: String(error),
      });
    }
  };

  return (
    <List isLoading={isLoading} searchBarPlaceholder="Search workspaces...">
      {workspaces.map((ws) => (
        <List.Item
          key={ws.id}
          title={ws.displayName || ws.name}
          subtitle={`Workspace ${ws.name}`}
          accessories={[
            { icon: ws.isActive ? Icon.CheckCircle : undefined },
          ]}
          actions={
            <ActionPanel>
              <Action title="Switch to Workspace" onAction={() => switchWorkspace(ws.name)} />
              <Action title="Refresh" onAction={refreshWorkspaces} shortcut={{ modifiers: ["cmd"], key: "r" }} />
            </ActionPanel>
          }
        />
      ))}
    </List>
  );
}
