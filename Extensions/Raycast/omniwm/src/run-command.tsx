import { Action, ActionPanel, List, showToast, Toast, Icon, Form, useNavigation } from "@raycast/api";
import { execSync } from "child_process";
import { useState } from "react";

const CTL_BIN = "/Applications/OmniWM.app/Contents/MacOS/omniwmctl";

interface CommandDescriptor {
  name: string;
  summary: string;
  args?: { name: string; placeholder: string }[];
}

const COMMANDS: CommandDescriptor[] = [
  { name: "ping", summary: "Check IPC connection" },
  { name: "toggle-workspace-bar", summary: "Toggle the workspace bar" },
  { name: "focus", summary: "Focus a window in a direction", args: [{ name: "direction", placeholder: "left|right|up|down" }] },
  { name: "move", summary: "Move a window in a direction", args: [{ name: "direction", placeholder: "left|right|up|down" }] },
  { name: "switch-workspace", summary: "Switch to a workspace", args: [{ name: "name", placeholder: "workspace name" }] },
  { name: "move-to-workspace", summary: "Move window to a workspace", args: [{ name: "name", placeholder: "workspace name" }] },
  { name: "resize", summary: "Resize focused window", args: [{ name: "operation", placeholder: "grow|shrink" }, { name: "direction", placeholder: "left|right|up|down" }] },
];

export default function Command() {
  return (
    <List searchBarPlaceholder="Search native OmniWM commands...">
      {COMMANDS.map((cmd) => (
        <List.Item
          key={cmd.name}
          title={cmd.name}
          subtitle={cmd.summary}
          actions={
            <ActionPanel>
              {cmd.args ? (
                <Action.Push title="Configure & Run" target={<CommandForm command={cmd} />} />
              ) : (
                <Action title="Run Command" onAction={() => runOmniCommand(cmd.name)} />
              )}
            </ActionPanel>
          }
        />
      ))}
    </List>
  );
}

function CommandForm({ command }: { command: CommandDescriptor }) {
  const { pop } = useNavigation();

  const handleSubmit = (values: Record<string, string>) => {
    let argString = "";
    for (const [key, value] of Object.entries(values)) {
      argString += ` --${key} ${value}`;
    }
    runOmniCommand(`${command.name}${argString}`);
    pop();
  };

  return (
    <Form
      actions={
        <ActionPanel>
          <Action.SubmitForm title="Run Command" onSubmit={handleSubmit} />
        </ActionPanel>
      }
    >
      <Form.Description text={command.summary} />
      {command.args?.map((arg) => (
        <Form.TextField key={arg.name} id={arg.name} title={arg.name} placeholder={arg.placeholder} />
      ))}
    </Form>
  );
}

async function runOmniCommand(cmd: string) {
  try {
    // Note: split cmd by space to handle arguments properly if needed, 
    // but for simple 'command <subcommand>' it works.
    execSync(`${CTL_BIN} command ${cmd}`);
    showToast({ title: "Command executed", message: cmd });
  } catch (error) {
    showToast({
      style: Toast.Style.Failure,
      title: "Command failed",
      message: String(error),
    });
  }
}
