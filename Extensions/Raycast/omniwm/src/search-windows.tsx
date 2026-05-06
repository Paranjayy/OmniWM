import { Action, ActionPanel, List, showToast, Toast, Icon } from "@raycast/api";
import { execSync } from "child_process";
import { useState, useEffect } from "react";

interface WindowEntry {
  windowId: number;
  pid: number;
  title: string;
  bundleId: string;
  workspaceName: string;
  workspaceId: string;
  isFocused: boolean;
  isFloating: boolean;
  frame: { x: number; y: number; width: number; height: number };
}

const CTL_BIN = "/Applications/OmniWM.app/Contents/MacOS/omniwmctl";

export default function Command() {
  const [windows, setWindows] = useState<WindowEntry[]>([]);
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    refreshWindows();
  }, []);

  const refreshWindows = () => {
    try {
      const output = execSync(`${CTL_BIN} query windows --format json`).toString();
      const parsed = JSON.parse(output);
      if (parsed.result && parsed.result.payload && parsed.result.payload.windows) {
        setWindows(parsed.result.payload.windows);
      }
    } catch (error) {
      showToast({
        style: Toast.Style.Failure,
        title: "Failed to query windows",
        message: String(error),
      });
    } finally {
      setIsLoading(false);
    }
  };

  const focusWindow = async (windowId: number) => {
    try {
      execSync(`${CTL_BIN} command focus --window-id ${windowId}`);
      showToast({ title: "Focused window" });
    } catch (error) {
      showToast({
        style: Toast.Style.Failure,
        title: "Failed to focus window",
        message: String(error),
      });
    }
  };

  return (
    <List isLoading={isLoading} searchBarPlaceholder="Search windows by title or app...">
      {windows.map((win) => (
        <List.Item
          key={`${win.pid}-${win.windowId}`}
          title={win.title || "Untitled"}
          subtitle={win.bundleId}
          accessories={[
            { text: win.workspaceName, icon: Icon.Grid },
            { icon: win.isFocused ? Icon.CheckCircle : undefined },
          ]}
          actions={
            <ActionPanel>
              <Action title="Focus Window" onAction={() => focusWindow(win.windowId)} />
              <Action title="Refresh" onAction={refreshWindows} shortcut={{ modifiers: ["cmd"], key: "r" }} />
            </ActionPanel>
          }
        />
      ))}
    </List>
  );
}
