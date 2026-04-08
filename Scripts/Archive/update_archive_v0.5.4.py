with open("PROMPTS_ARCHIVE.md", "r") as f:
    lines = f.readlines()

new_prompts = [
    "everythin broken i imported @[../../.config/omniwm/settings.json] & i didnt relaod or thungs in @[../../.config/karabiner/karabiner.json] btw fix it :(",
    "it still doesnt center only it floats - rcmd+y fix that",
    "ropt+wasd still broknen & ropt+1to9 & ropt+shift+1to9 cant u see the shortcuts what they are meant to be and more uk mun @[/Users/paranjay/Developer/OmniWM/issues & new features or thungs ideas.md:L19-L72]",
    "finetune still broken 1/16th thing of vol/briight with ropt+shift+",
    "i dont want u touch rcmd/ropt+arrows because it are navigation thungs i might use them for navigation ro general use so dont u read instructions from issues and thungs btw mun"
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
        new_history.append(f"{i}. **\"{p}\"**\n")
    
    # Update Stats
    for i, line in enumerate(lines):
        if "- **Total Prompt Count**:" in line:
            lines[i] = f"- **Total Prompt Count**: {len(combined)}\n"
            break
            
    # Combine everything
    final_lines = lines[:history_start_idx] + new_history + ["\n---\n\n*End of Archive v1.4*\n"]
    
    with open("PROMPTS_ARCHIVE.md", "w") as f:
        f.writelines(final_lines)

print("Archive updated with v0.5.4 prompts.")
