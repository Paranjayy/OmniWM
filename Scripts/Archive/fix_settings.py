import json

# Fix settings.json
with open("/Users/paranjay/.config/omniwm/settings.json", "r") as f:
    data = json.load(f)

# Clear old hotkeys from settings to rely on ActionCatalog entirely
data["hotkeyBindings"] = []

with open("/Users/paranjay/.config/omniwm/settings.json", "w") as f:
    json.dump(data, f, indent=2)

print("settings.json updated: hotkeyBindings cleared.")
