#!/usr/bin/env bash
# Manual install of the AI dev team (agents, commands, safety hook, permissions).
#   ./install.sh                 -> user level (~/.claude), every project on this machine
#   ./install.sh /path/to/repo   -> one project (<repo>/.claude). Commit it to use the team
#                                   from Claude Code on the web / the mobile app too.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")" && pwd)"
if [ $# -ge 1 ]; then
  PROJECT="$(cd "$1" && pwd)"; DEST="$PROJECT/.claude"; SETTINGS="$ROOT/settings/project-settings.json"
else
  PROJECT=""; DEST="$HOME/.claude"; SETTINGS="$ROOT/settings/user-settings.json"
fi
mkdir -p "$DEST/agents" "$DEST/commands" "$DEST/hooks"
cp "$ROOT"/agents/*.md "$DEST/agents/"
cp "$ROOT"/commands/*.md "$DEST/commands/"
cp "$ROOT/hooks/guard.sh" "$DEST/hooks/guard.sh"
chmod +x "$DEST/hooks/guard.sh"
if [ -f "$DEST/settings.json" ]; then
  cp "$SETTINGS" "$DEST/ai-team.settings.example.json"
  echo "Existing settings.json kept. Merge permissions and the PreToolUse hook from: $DEST/ai-team.settings.example.json"
else
  cp "$SETTINGS" "$DEST/settings.json"
fi
if [ -n "$PROJECT" ]; then
  touch "$PROJECT/.gitignore"
  grep -qx 'ai-runs/' "$PROJECT/.gitignore" || printf '\n# AI dev team run logs\nai-runs/\n' >> "$PROJECT/.gitignore"
  echo "Installed into $DEST. Commit .claude/ and .gitignore so cloud and mobile sessions get the team:"
  echo "  git add .claude .gitignore && git commit -m 'Add AI dev team' && git push"
else
  echo "Installed AI dev team into $DEST"
fi
