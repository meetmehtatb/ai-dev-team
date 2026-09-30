#!/usr/bin/env bash
# Manual install of the AI dev team (agents + commands + permissions). Prefer the plugin: see README.
#   ./install.sh                 -> user level (~/.claude), available in every project
#   ./install.sh /path/to/repo   -> one project (<repo>/.claude)
set -euo pipefail
ROOT="$(cd "$(dirname "$0")" && pwd)"
if [ $# -ge 1 ]; then DEST="$1/.claude"; else DEST="$HOME/.claude"; fi
mkdir -p "$DEST/agents" "$DEST/commands"
cp "$ROOT"/agents/*.md "$DEST/agents/"
cp "$ROOT"/commands/*.md "$DEST/commands/"
if [ -f "$DEST/settings.json" ]; then
  cp "$ROOT/settings/permissions.json" "$DEST/ai-team.settings.example.json"
  echo "Existing settings.json kept. Merge permissions from: $DEST/ai-team.settings.example.json"
else
  cp "$ROOT/settings/permissions.json" "$DEST/settings.json"
fi
echo "Installed AI dev team into $DEST"
