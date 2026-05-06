import { showToast, Toast } from "@raycast/api";
import { execSync } from "child_process";

const CTL_BIN = "/Applications/OmniWM.app/Contents/MacOS/omniwmctl";

export default async function main() {
  try {
    execSync(`${CTL_BIN} command toggle-workspace-bar`);
    showToast({ title: "Toggled Workspace Bar" });
  } catch (error) {
    showToast({
      style: Toast.Style.Failure,
      title: "Failed to toggle bar",
      message: String(error),
    });
  }
}
