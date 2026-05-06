import { Action, ActionPanel, List, showToast, Toast, Icon } from "@raycast/api";
import { readFileSync } from "fs";
import { useState, useEffect } from "react";
import path from "path";

interface Shortcut {
  description: string;
  from: string;
  to: string;
  condition?: string;
}

const KARABINER_CONFIG = "/Users/paranjay/Developer/OmniWM/.config/karabiner.json";

export default function Command() {
  const [shortcuts, setShortcuts] = useState<Shortcut[]>([]);
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    try {
      const content = readFileSync(KARABINER_CONFIG, "utf-8");
      const config = JSON.parse(content);
      const extracted: Shortcut[] = [];

      config.profiles?.[0]?.complex_modifications?.rules?.forEach((rule: any) => {
        rule.manipulators?.forEach((m: any) => {
          if (m.type === "basic") {
            const fromKey = m.from?.key_code || m.from?.consumer_key_code || "unknown";
            const fromMods = m.from?.modifiers?.mandatory?.join("+") || "";
            
            const to = m.to?.map((t: any) => {
              const toKey = t.key_code || t.consumer_key_code || t.shell_command || "action";
              const toMods = t.modifiers?.join("+") || "";
              return toMods ? `${toMods}+${toKey}` : toKey;
            }).join(", ");

            const condition = m.conditions?.[0]?.name || "";

            extracted.push({
              description: rule.description || "No description",
              from: fromMods ? `${fromMods}+${fromKey}` : fromKey,
              to: to,
              condition: condition
            });
          }
        });
      });

      setShortcuts(extracted);
    } catch (error) {
      showToast({
        style: Toast.Style.Failure,
        title: "Failed to parse Karabiner config",
        message: String(error),
      });
    } finally {
      setIsLoading(false);
    }
  }, []);

  return (
    <List isLoading={isLoading} searchBarPlaceholder="Search shortcuts...">
      {shortcuts.map((s, idx) => (
        <List.Item
          key={idx}
          title={s.description}
          subtitle={s.from}
          accessories={[
            { text: s.condition, icon: s.condition ? Icon.Layers : undefined },
            { text: "→", icon: Icon.ArrowRight },
            { text: s.to.length > 30 ? s.to.substring(0, 30) + "..." : s.to }
          ]}
          actions={
            <ActionPanel>
              <Action.CopyToClipboard title="Copy Shortcut" content={s.from} />
              <Action.CopyToClipboard title="Copy Action" content={s.to} />
            </ActionPanel>
          }
        />
      ))}
    </List>
  );
}
