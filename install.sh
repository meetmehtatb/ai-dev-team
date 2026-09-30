#!/usr/bin/env bash
# Install the AI dev team for Claude Code.
#   ./install.sh                 -> user level (~/.claude), available in every project
#   ./install.sh /path/to/repo   -> one project (<repo>/.claude)
set -euo pipefail
SRC="$(cd "$(dirname "$0")" && pwd)/.claude"
if [ $# -ge 1 ]; then DEST="$1/.claude"; else DEST="$HOME/.claude"; fi
mkdir -p "$DEST/agents" "$DEST/commands"
cp "$SRC"/agents/*.md "$DEST/agents/"
cp "$SRC"/commands/*.md "$DEST/commands/"
if [ -f "$DEST/settings.json" ]; then
  cp "$SRC/settings.json" "$DEST/ai-team.settings.example.json"
  echo "Existing settings.json kept. Merge permissions from: $DEST/ai-team.settings.example.json"
else
  cp "$SRC/settings.json" "$DEST/settings.json"
fi
echo "Installed AI dev team into $DEST"
