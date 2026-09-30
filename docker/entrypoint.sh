#!/usr/bin/env bash
set -euo pipefail

# Mounted repos are owned by the host user; let git work with them.
git config --global --add safe.directory '*'

# Commits are yours: use your own git identity (GIT_USER_NAME / GIT_USER_EMAIL in .env).
if [ -n "${GIT_USER_NAME:-}" ] && [ -n "${GIT_USER_EMAIL:-}" ]; then
  git config --global user.name  "$GIT_USER_NAME"
  git config --global user.email "$GIT_USER_EMAIL"
else
  echo "warning: set GIT_USER_NAME and GIT_USER_EMAIL in .env so commits are made as you." >&2
fi

# GitHub: a token in GH_TOKEN is used by gh, and by git for push over https.
if [ -n "${GH_TOKEN:-}" ]; then
  gh auth setup-git >/dev/null 2>&1 || echo "warning: gh auth setup-git failed (check GH_TOKEN)" >&2
else
  echo "warning: GH_TOKEN is not set - issues, pushes and PRs will fail. See README > Docker." >&2
fi

# Install / refresh the ai-dev-team plugin in the persistent Claude config volume.
if ! claude plugin list 2>/dev/null | grep -q 'ai-dev-team'; then
  claude plugin marketplace add /opt/ai-dev-team >/dev/null 2>&1 || true
  claude plugin install ai-dev-team@ai-dev-team >/dev/null 2>&1 \
    && echo "ai-dev-team plugin installed." \
    || echo "warning: could not install the ai-dev-team plugin" >&2
else
  claude plugin marketplace update ai-dev-team >/dev/null 2>&1 || true
fi

# Default permissions for the team, unless the user already has settings.
CFG="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
mkdir -p "$CFG"
[ -f "$CFG/settings.json" ] || cp /opt/ai-dev-team/settings/permissions.json "$CFG/settings.json"

if [ ! -d /workspace/.git ]; then
  echo "warning: /workspace is not a git repository. Mount your project: PROJECT_DIR=/path/to/repo docker compose run --rm ai-dev-team" >&2
fi

exec "$@"
