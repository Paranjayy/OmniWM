import { Action, ActionPanel, List, showToast, Toast, Icon, Color } from "@raycast/api";
import { execSync } from "child_process";
import { useState, useEffect, useMemo } from "react";

interface WindowInfo {
  appName: string;
  title: string;
  isFocused: boolean;
}

interface WorkspaceEntry {
  id: string;
  rawName: string;
  displayName: string;
  monitorId?: string;
  isFocused: boolean;
  isVisible: boolean;
  counts?: {
    total: number;
    tiled: number;
    floating: number;
    scratchpad: number;
  };
  windows?: WindowInfo[];
}

const CTL_BIN = "/Applications/OmniWM.app/Contents/MacOS/omniwmctl";

export default function Command() {
  const [workspaces, setWorkspaces] = useState<WorkspaceEntry[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [searchText, setSearchText] = useState("");

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
      refreshWorkspaces();
    } catch (error) {
      showToast({
        style: Toast.Style.Failure,
        title: "Failed to switch workspace",
        message: String(error),
      });
    }
  };

  const restoreSnapshot = async () => {
    try {
      execSync(`${CTL_BIN} command restore-workspace-snapshot`);
      showToast({ title: "Workspace snapshot restored" });
      refreshWorkspaces();
    } catch (error) {
      showToast({
        style: Toast.Style.Failure,
        title: "Failed to restore snapshot",
        message: String(error),
      });
    }
  };

  const sections = useMemo(() => {
    const active = workspaces.filter(ws => (ws.counts?.total || 0) > 0);
    const inactive = workspaces.filter(ws => (ws.counts?.total || 0) === 0);
    
    return [
      { title: "Active Workspaces", items: active, icon: Icon.CircleFilled },
      { title: "Empty Workspaces", items: inactive, icon: Icon.Circle }
    ];
  }, [workspaces]);

  return (
    <List 
      isLoading={isLoading} 
      searchBarPlaceholder="Search workspaces (ID or Name)..."
      onSearchTextChange={setSearchText}
      isShowingDetail={workspaces.length > 0}
    >
      {sections.map((section) => (
        <List.Section key={section.title} title={section.title}>
          {section.items
            .filter(ws => 
              ws.displayName.toLowerCase().includes(searchText.toLowerCase()) ||
              ws.rawName.toLowerCase().includes(searchText.toLowerCase())
            )
            .map((ws) => (
              <WorkspaceItem 
                key={ws.id} 
                ws={ws} 
                onSwitch={switchWorkspace} 
                onRefresh={refreshWorkspaces}
                onRestore={restoreSnapshot}
              />
            ))}
        </List.Section>
      ))}
    </List>
  );
}

function WorkspaceItem({ 
  ws, 
  onSwitch, 
  onRefresh,
  onRestore 
}: { 
  ws: WorkspaceEntry; 
  onSwitch: (name: string) => void; 
  onRefresh: () => void;
  onRestore: () => void;
}) {
  const windowListMarkdown = ws.windows && ws.windows.length > 0 
    ? ws.windows.map(w => `- **${w.appName}**: ${w.title || "Untitled"}`).join("\n")
    : "*No active windows*";

  const totalWindows = ws.counts?.total || 0;

  return (
    <List.Item
      title={ws.displayName}
      subtitle={totalWindows > 0 ? `${totalWindows} windows` : "Empty"}
      icon={ws.isFocused ? { source: Icon.Dot, color: Color.Green } : Icon.Circle}
      detail={
        <List.Item.Detail
          markdown={`# ${ws.displayName}\n\n### Current Windows\n${windowListMarkdown}\n\n---\n\n### Stats\n- **Tiled:** ${ws.counts?.tiled || 0}\n- **Floating:** ${ws.counts?.floating || 0}\n- **Scratchpad:** ${ws.counts?.scratchpad || 0}`}
          metadata={
            <List.Item.Detail.Metadata>
              <List.Item.Detail.Metadata.Label title="ID" text={ws.rawName} />
              <List.Item.Detail.Metadata.Label title="Monitor" text={ws.monitorId || "Unknown"} />
              <List.Item.Detail.Metadata.TagList title="Status">
                {ws.isFocused && <List.Item.Detail.Metadata.TagList.Item text="Focused" color={Color.Green} />}
                {ws.isVisible && <List.Item.Detail.Metadata.TagList.Item text="Visible" color={Color.Blue} />}
              </List.Item.Detail.Metadata.TagList>
              <List.Item.Detail.Metadata.Separator />
              <List.Item.Detail.Metadata.Label title="Total Windows" text={String(totalWindows)} />
            </List.Item.Detail.Metadata>
          }
        />
      }
      actions={
        <ActionPanel>
          <Action title="Switch to Workspace" icon={Icon.ChevronRight} onAction={() => onSwitch(ws.rawName)} />
          <Action.RenderInBrowser title="Open Monitor Settings" url="raycast://extensions/barutsrb/omniwm/settings" />
          <ActionPanel.Section title="Forensics & Recovery">
            <Action 
              title="Capture Layout Snapshot" 
              icon={Icon.Camera}
              onAction={async () => {
                try {
                  execSync(`${CTL_BIN} command capture-workspace-snapshot`);
                  showToast({ title: "Snapshot captured" });
                  onRefresh();
                } catch (e) {
                  showToast({ style: Toast.Style.Failure, title: "Failed to capture snapshot" });
                }
              }} 
              shortcut={{ modifiers: ["cmd"], key: "s" }}
            />
            <Action 
              title="Restore Last Snapshot" 
              icon={Icon.ArrowCounterClockwise}
              onAction={onRestore}
              shortcut={{ modifiers: ["cmd", "shift"], key: "r" }}
            />
          </ActionPanel.Section>
          <Action title="Refresh" icon={Icon.ArrowClockwise} onAction={onRefresh} shortcut={{ modifiers: ["cmd"], key: "r" }} />
        </ActionPanel>
      }
    />
  );
}
