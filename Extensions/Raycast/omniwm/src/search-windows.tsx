import { Action, ActionPanel, List, showToast, Toast, Icon } from "@raycast/api";
import { execSync } from "child_process";
import { useState, useEffect } from "react";

interface WindowEntry {
  id: string;
  pid: number;
  title: string;
  app: {
    bundleId: string;
    name: string;
  };
  workspace: {
    displayName: string;
    id: string;
    number: number;
    rawName: string;
  };
  isFocused: boolean;
  isVisible: boolean;
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

  const focusWindow = async (id: string) => {
    try {
      execSync(`${CTL_BIN} window focus ${id}`);
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
          key={win.id}
          icon={{ fileIcon: `/Applications/${win.app.name}.app` }}
          title={win.title || "Untitled"}
          subtitle={win.app.name}
          accessories={[
            { text: win.workspace.displayName, icon: Icon.Grid },
            { icon: win.isFocused ? Icon.CheckCircle : undefined },
          ]}
          actions={
            <ActionPanel>
              <Action title="Focus Window" onAction={() => focusWindow(win.id)} />
              <Action title="Refresh" onAction={refreshWindows} shortcut={{ modifiers: ["cmd"], key: "r" }} />
            </ActionPanel>
          }
        />
      ))}
    </List>
  );
}
