import { Action, ActionPanel, List, showToast, Toast, Icon, Color } from "@raycast/api";
import { readFileSync } from "fs";
import { useState, useEffect, useMemo } from "react";

interface Shortcut {
  category: string;
  subCategory: string;
  action: string;
  fullDescription: string;
  from: string;
  to: string;
  condition?: string;
  isTrigger: boolean;
}

const KARABINER_CONFIG = "/Users/paranjay/Developer/OmniWM/.config/karabiner.json";

const KEY_SYMBOLS: Record<string, string> = {
  left_command: "⌘",
  right_command: "⌘",
  command: "⌘",
  left_option: "⌥",
  right_option: "⌥",
  option: "⌥",
  left_control: "⌃",
  right_control: "⌃",
  control: "⌃",
  left_shift: "⇧",
  right_shift: "⇧",
  shift: "⇧",
  return: "⏎",
  enter: "⏎",
  delete_or_backspace: "⌫",
  spacebar: "Space",
  escape: "⎋",
  tab: "⇥",
  up_arrow: "↑",
  down_arrow: "↓",
  left_arrow: "←",
  right_arrow: "→",
};

function prettifyKeys(keys: string): string {
  return keys
    .split("+")
    .map((k) => KEY_SYMBOLS[k.toLowerCase()] || k.replace(/_/g, " "))
    .join("");
}

export default function Command() {
  const [shortcuts, setShortcuts] = useState<Shortcut[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [searchText, setSearchText] = useState("");

  useEffect(() => {
    try {
      const content = readFileSync(KARABINER_CONFIG, "utf-8");
      const config = JSON.parse(content);
      const extracted: Shortcut[] = [];

      config.profiles?.[0]?.complex_modifications?.rules?.forEach((rule: any) => {
        rule.manipulators?.forEach((m: any) => {
          if (m.type === "basic") {
            const fromKey = m.from?.key_code || m.from?.consumer_key_code || "unknown";
            const fromMods = m.from?.modifiers?.mandatory || [];
            
            const to = m.to?.map((t: any) => {
              const toKey = t.key_code || t.consumer_key_code || t.shell_command || "action";
              const toMods = t.modifiers || [];
              const modsStr = toMods.join("+");
              return modsStr ? `${modsStr}+${toKey}` : toKey;
            }).join(", ");

            const condition = m.conditions?.[0]?.name || "";
            const desc = rule.description || "No description";
            const isTrigger = desc.toLowerCase().includes("trigger");

            // Parse description: [Category] Sub | Action
            let category = "General";
            let subCategory = "";
            let action = desc;

            const categoryMatch = desc.match(/^\[(.*?)\]/);
            if (categoryMatch) {
              category = categoryMatch[1];
              const rest = desc.replace(categoryMatch[0], "").trim();
              const parts = rest.split("|").map((p: string) => p.trim());
              if (parts.length > 1) {
                action = parts.pop() || "";
                subCategory = parts.join(" › ");
              } else {
                action = parts[0] || "";
              }
            } else {
              const parts = desc.split("|").map((p: string) => p.trim());
              if (parts.length > 1) {
                category = parts[0];
                action = parts.pop() || "";
                subCategory = parts.slice(1).join(" › ");
              }
            }

            extracted.push({
              category,
              subCategory,
              action,
              fullDescription: desc,
              from: fromMods.length > 0 ? `${fromMods.join("+")}+${fromKey}` : fromKey,
              to: to,
              condition: condition,
              isTrigger
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

  const sections = useMemo(() => {
    const grouped: Record<string, Shortcut[]> = {};
    shortcuts.forEach((s) => {
      if (!grouped[s.category]) grouped[s.category] = [];
      grouped[s.category].push(s);
    });
    return Object.keys(grouped).sort().map(key => ({
      title: key,
      shortcuts: grouped[key]
    }));
  }, [shortcuts]);

  return (
    <List 
      isLoading={isLoading} 
      searchBarPlaceholder="Search shortcuts..."
      onSearchTextChange={setSearchText}
      isShowingDetail={shortcuts.length > 0}
    >
      {sections.map((section) => (
        <List.Section key={section.title} title={section.title}>
          {section.shortcuts
            .filter(s => 
              s.fullDescription.toLowerCase().includes(searchText.toLowerCase()) ||
              s.from.toLowerCase().includes(searchText.toLowerCase())
            )
            .map((s, idx) => (
              <List.Item
                key={`${section.title}-${idx}`}
                title={s.action}
                subtitle={s.subCategory}
                icon={s.isTrigger ? { source: Icon.Bolt, color: Color.Yellow } : Icon.Keyboard}
                detail={
                  <List.Item.Detail
                    markdown={`# ${s.action}\n\n**Category:** ${s.category}\n${s.subCategory ? `**Context:** ${s.subCategory}\n` : ""}\n---\n\n### Shortcut\n\`${prettifyKeys(s.from)}\`\n\n### Action\n\`${s.to}\`\n\n${s.condition ? `### Condition\n\`${s.condition}\`` : ""}`}
                    metadata={
                      <List.Item.Detail.Metadata>
                        <List.Item.Detail.Metadata.Label title="From" text={prettifyKeys(s.from)} />
                        <List.Item.Detail.Metadata.Label title="To" text={s.to} />
                        {s.condition && <List.Item.Detail.Metadata.TagList title="Condition">
                          <List.Item.Detail.Metadata.TagList.Item text={s.condition} color={Color.Blue} />
                        </List.Item.Detail.Metadata.TagList>}
                        <List.Item.Detail.Metadata.Separator />
                        <List.Item.Detail.Metadata.Label title="Type" text={s.isTrigger ? "Trigger" : "Mapping"} />
                      </List.Item.Detail.Metadata>
                    }
                  />
                }
                actions={
                  <ActionPanel>
                    <Action.CopyToClipboard title="Copy Shortcut" content={s.from} />
                    <Action.CopyToClipboard title="Copy Action" content={s.to} />
                  </ActionPanel>
                }
              />
            ))}
        </List.Section>
      ))}
    </List>
  );
}
