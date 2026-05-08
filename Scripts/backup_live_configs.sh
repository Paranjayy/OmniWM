#!/bin/bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
BACKUP_DIR="$ROOT_DIR/backups"
TIMESTAMP="$(date +"%Y%m%d_%H%M%S")"

OMNIWM_DIR="$HOME/.config/omniwm"
KARABINER_DIR="$HOME/.config/karabiner"

mkdir -p "$BACKUP_DIR"

copy_if_exists() {
  local src="$1"
  local dest="$2"

  if [[ -f "$src" ]]; then
    cp "$src" "$dest"
    echo "Backed up $src -> $dest"
  else
    echo "Skipped missing file: $src"
  fi
}

copy_if_exists "$OMNIWM_DIR/settings.json" "$BACKUP_DIR/settings_json_backup_${TIMESTAMP}.json"
copy_if_exists "$OMNIWM_DIR/settings.toml" "$BACKUP_DIR/settings_toml_backup_${TIMESTAMP}.toml"
copy_if_exists "$KARABINER_DIR/karabiner.json" "$BACKUP_DIR/karabiner_backup_${TIMESTAMP}.json"

echo "Backup snapshot completed at $TIMESTAMP"
