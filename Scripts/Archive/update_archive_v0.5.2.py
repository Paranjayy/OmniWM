with open("PROMPTS_ARCHIVE.md", "r") as f:
    lines = f.readlines()

new_prompts = [
    "i am not using or we arent building or workin on source code and our additions of new features btw i am only using official version for now",
    "ropt+ space broken it should let me open raycas u can see @[issues & new features or thungs ideas.md] it has all the shortcuts that i need or want",
    "rcmd+1to9 to open workspace",
    "rcmd+shift+1to9 to move active window to those workspace thung",
    "ropt+1to9 open windows from workspace bar",
    "rcmd+wasd to move apps in workspace bar not physically btw",
    "ropt+wasd to focus on apps in workspace bar"
]

history_start_idx = -1
for i, line in enumerate(lines):
    if "## 📜 Full History" in line:
        history_start_idx = i
        break

if history_start_idx != -1:
    old_prompts = []
    for line in lines[history_start_idx+1:]:
        if line.strip().startswith(tuple(str(i) + "." for i in range(1, 100))):
            start = line.find('**"') + 3
            end = line.rfind('"**')
            if start > 2 and end != -1:
                old_prompts.append(line[start:end])
    
    combined = old_prompts + [p for p in new_prompts if p not in old_prompts]
    
    # Rebuild history
    new_history = ["## 📜 Full History\n\n"]
    for i, p in enumerate(combined, 1):
        # Escape asterisks and other things if needed, but here simple
        new_history.append(f"{i}. **\"{p}\"**\n")
    
    # Update Stats
    for i, line in enumerate(lines):
        if "- **Total Prompt Count**:" in line:
            lines[i] = f"- **Total Prompt Count**: {len(combined)}\n"
            break
            
    # Combine everything
    final_lines = lines[:history_start_idx] + new_history + ["\n---\n\n*End of Archive v1.2*\n"]
    
    with open("PROMPTS_ARCHIVE.md", "w") as f:
        f.writelines(final_lines)

print("Archive updated with v0.5.2 prompts.")
