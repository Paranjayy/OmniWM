import { Action, ActionPanel, List, showToast, Toast, Icon, Color } from "@raycast/api";
import { execSync } from "child_process";
import { useState, useEffect, useMemo } from "react";

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
  const [searchText, setSearchText] = useState("");

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
      showToast({ style: Toast.Style.Failure, title: "Failed to focus" });
    }
  };

  const summonRight = async (id: string) => {
    try {
      execSync(`${CTL_BIN} window summon-right ${id}`);
      showToast({ title: "Summoned window to right" });
    } catch (error) {
      showToast({ style: Toast.Style.Failure, title: "Failed to summon" });
    }
  };

  const sections = useMemo(() => {
    const grouped: Record<string, WindowEntry[]> = {};
    windows.forEach(w => {
      if (!grouped[w.app.name]) grouped[w.app.name] = [];
      grouped[w.app.name].push(w);
    });
    return Object.keys(grouped).sort().map(name => ({
      title: name,
      windows: grouped[name]
    }));
  }, [windows]);

  return (
    <List 
      isLoading={isLoading} 
      searchBarPlaceholder="Search windows by title or app..."
      onSearchTextChange={setSearchText}
      isShowingDetail={windows.length > 0}
    >
      {sections.map((section) => (
        <List.Section key={section.title} title={section.title}>
          {section.windows
            .filter(w => 
              w.title.toLowerCase().includes(searchText.toLowerCase()) ||
              w.app.name.toLowerCase().includes(searchText.toLowerCase())
            )
            .map((win) => (
              <List.Item
                key={win.id}
                icon={{ fileIcon: `/Applications/${win.app.name}.app` }}
                title={win.title || "Untitled"}
                detail={
                  <List.Item.Detail
                    markdown={`# ${win.app.name}\n\n**Title:** ${win.title || "Untitled"}\n\n---\n\n### Context\n- **Workspace:** ${win.workspace.displayName}\n- **Process ID:** ${win.pid}\n- **Bundle ID:** \`${win.app.bundleId}\`\n\n### Status\n- **Visible:** ${win.isVisible ? "Yes" : "No"}\n- **Focused:** ${win.isFocused ? "Yes" : "No"}`}
                    metadata={
                      <List.Item.Detail.Metadata>
                        <List.Item.Detail.Metadata.Label title="App" text={win.app.name} />
                        <List.Item.Detail.Metadata.Label title="PID" text={String(win.pid)} />
                        <List.Item.Detail.Metadata.TagList title="Status">
                          {win.isFocused && <List.Item.Detail.Metadata.TagList.Item text="Focused" color={Color.Green} />}
                          {win.isVisible && <List.Item.Detail.Metadata.TagList.Item text="Visible" color={Color.Blue} />}
                        </List.Item.Detail.Metadata.TagList>
                      </List.Item.Detail.Metadata>
                    }
                  />
                }
                actions={
                  <ActionPanel>
                    <Action title="Focus Window" icon={Icon.Eye} onAction={() => focusWindow(win.id)} />
                    <Action 
                      title="Summon to Right" 
                      icon={Icon.ChevronRight} 
                      onAction={() => summonRight(win.id)}
                      shortcut={{ modifiers: ["cmd", "shift"], key: "s" }}
                    />
                    <Action 
                      title="Navigate to Workspace" 
                      icon={Icon.Grid} 
                      onAction={() => execSync(`${CTL_BIN} window navigate ${win.id}`)} 
                    />
                    <Action title="Refresh" icon={Icon.ArrowClockwise} onAction={refreshWindows} shortcut={{ modifiers: ["cmd"], key: "r" }} />
                  </ActionPanel>
                }
              />
            ))}
        </List.Section>
      ))}
    </List>
  );
}
