with open("PROMPTS_ARCHIVE.md", "r") as f:
    lines = f.readlines()

new_prompts = [
    "Integrating God Build Settings (v47.2 integration session)",
    "can create ideas lists or thungs mun @[Default-settings.json]",
    "i got default settings from official app btw u sucked prev so",
    "how cani unprotect git from ur side mun",
    "can u also replace settings.json & karabiner.json to config folder mun also have a copy of it here so that in our git commit history or stuffs it stays nicely synced or stuffs mun",
    "is it possible to hide the workspace bar after first 5 seconds of switching and whenever i press rcmd+ropt then show it",
    "rcmd+t for focus/flow mode timer, rcmd+p for PIP mode, rcmd+l for launcher",
    "ropt to finetune volume/brightness not working (prolly ms issue idk mun)",
    "Can we have shortcut to cmd+ y to: Do cmd g(first/float) + particular aspect ratio/px(1194x947pt) first + at last center",
    "once floated it can be unfloated and restored to previous state with pressing rcmd+y again mun",
    "center thing not working or broken rn - Right Command + Y: Float, Resize (1194x947), and Center focused window",
    "- dont use arrows mun rcmd/ropt i told u earlier too dawg"
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
            # Extract content between **" and "**
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
    final_lines = lines[:history_start_idx] + new_history + ["\n---\n\n*End of Archive v1.1*\n"]
    
    with open("PROMPTS_ARCHIVE.md", "w") as f:
        f.writelines(final_lines)

print("Archive updated with missing prompts.")
