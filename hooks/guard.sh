#!/usr/bin/env bash
# AI dev team safety guard (PreToolUse hook).
# Only enforces while a /solve-issue run is active: <git-dir>/ai-dev-team.active exists.
# Exit 2 = block the tool call; the message on stderr is shown to Claude.
input="$(cat)"

git_dir="$(git rev-parse --git-dir 2>/dev/null)" || exit 0
[ -f "$git_dir/ai-dev-team.active" ] || exit 0

tool="$(printf '%s' "$input" | sed -n 's/.*"tool_name"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' | head -n1)"

block() { echo "ai-dev-team guard: $1" >&2; exit 2; }

case "$tool" in
  Edit|Write|MultiEdit|NotebookEdit)
    path="$(printf '%s' "$input" | sed -n 's/.*"\(file_path\|notebook_path\)"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\2/p' | head -n1)"
    norm="$(printf '%s' "$path" | tr '\\' '/')"
    case "/$norm" in
      */.github/*) block "editing .github/ is not allowed during an AI run ($path)";;
      */.env|*/.env.*) block "editing .env files is not allowed during an AI run ($path)";;
    esac
    ;;
  Bash)
    cmd="$(printf '%s' "$input" | sed -n 's/.*"command"[[:space:]]*:[[:space:]]*"\(.*\)".*/\1/p' | head -n1)"
    if printf '%s' "$cmd" | grep -Eq 'git[[:space:]]+push'; then
      printf '%s' "$cmd" | grep -Eq -- '(--force|--force-with-lease|[[:space:]]-f([[:space:]]|$)|[[:space:]]\+)' \
        && block "force-push is not allowed during an AI run"
      printf '%s' "$cmd" | grep -Eq '(^|[[:space:]:])(main|master)([[:space:]]|$|\\)' \
        && block "pushing main/master is not allowed during an AI run"
    fi
    printf '%s' "$cmd" | grep -Eq 'gh[[:space:]]+pr[[:space:]]+merge' && block "merging PRs is not allowed during an AI run"
    printf '%s' "$cmd" | grep -Eq 'gh[[:space:]]+pr[[:space:]]+review.*--approve' && block "approving PRs is not allowed during an AI run"
    ;;
esac
exit 0
