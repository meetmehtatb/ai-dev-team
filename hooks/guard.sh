#!/usr/bin/env bash
# AI dev team safety guard (PreToolUse hook).
# Only enforces while a /solve-issue run is active: the marker file
# `git rev-parse --git-path ai-dev-team.active` exists (works in linked worktrees).
# Exit 2 = block the tool call; the message on stderr is shown to Claude.
input="$(cat)"

marker="$(git rev-parse --git-path ai-dev-team.active 2>/dev/null)" || exit 0
[ -f "$marker" ] || exit 0

block() { echo "ai-dev-team guard: $1" >&2; exit 2; }

# Extract a JSON string field (handles escaped quotes), then unescape it.
json_str() {
  printf '%s' "$input" \
    | sed -nE "s/.*\"$1\"[[:space:]]*:[[:space:]]*\"(([^\"\\\\]|\\\\.)*)\".*/\1/p" \
    | head -n1 \
    | sed -e 's/\\n/\n/g' -e 's/\\t/ /g' -e 's/\\"/"/g' -e 's/\\\\/\\/g'
}

tool="$(json_str tool_name)"

# Protected paths: .github/ and .env files (not .env.example-like names inside words such as process.env).
PROTECTED='(^|[[:space:]"'"'"'=/:])(\.github(/|[[:space:]"'"'"']|$)|\.env(\.[A-Za-z0-9_-]+)?([[:space:]"'"'"';|&)>]|$))'

case "$tool" in
  Edit|Write|MultiEdit|NotebookEdit)
    path="$(json_str file_path)"; [ -n "$path" ] || path="$(json_str notebook_path)"
    norm="/$(printf '%s' "$path" | tr '\\' '/')"
    case "$norm" in
      */.github/*) block "editing .github/ is not allowed during an AI run ($path)";;
      */.env|*/.env.*) block "editing .env files is not allowed during an AI run ($path)";;
    esac
    ;;
  Bash)
    cmd="$(json_str command)"
    # Check each shell segment separately (split on newlines, ;, &&, ||, |).
    while IFS= read -r seg; do
      seg="$(printf '%s' "$seg" | sed -E 's/^[[:space:]]+//; s/[[:space:]]+$//')"
      [ -n "$seg" ] || continue
      # Same segment with quoted text removed (so commit messages like "fix push bug" don't count).
      bare="$(printf '%s' "$seg" | sed -E "s/\"([^\"\\\\]|\\\\.)*\"//g; s/'[^']*'//g")"

      # 1. Pushes: only `git [-C dir] push [-u|--set-upstream] origin [HEAD:][refs/heads/]issue-N` is allowed.
      if printf '%s' "$bare" | grep -Eq '(^|[^[:alnum:]_-])git[[:space:]]+(.*[[:space:]])?push([[:space:]]|$)'; then
        printf '%s' "$bare" | grep -Eq '^git([[:space:]]+-C[[:space:]]+[^[:space:]]+)?[[:space:]]+push([[:space:]]+(-u|--set-upstream))?[[:space:]]+origin[[:space:]]+(HEAD:)?(refs/heads/)?issue-[0-9]+$' \
          || block "only 'git push -u origin issue-N' is allowed during an AI run (got: $seg)"
      fi

      # 1b. Commands hidden inside a nested shell (bash -c "...", eval "...") are checked on the full text.
      if printf '%s' "$seg" | grep -Eq '^(sudo[[:space:]]+)?(bash|sh|zsh|dash|eval|xargs|env|pwsh|powershell|cmd)([[:space:]]|$)'; then
        printf '%s' "$seg" | grep -Eq 'git[[:space:]]+(.*[[:space:]])?push([[:space:]]|$)|gh[[:space:]]+(pr[[:space:]]+(merge|review)|api)' \
          && block "git push / gh merge, review or api inside a nested shell is not allowed during an AI run"
      fi

      # 2. Merging / approving through gh.
      printf '%s' "$bare" | grep -Eq 'gh[[:space:]]+pr[[:space:]]+merge' && block "merging PRs is not allowed during an AI run"
      printf '%s' "$bare" | grep -Eq 'gh[[:space:]]+pr[[:space:]]+review.*(--approve|-a([[:space:]]|$))' && block "approving PRs is not allowed during an AI run"
      printf '%s' "$seg" | grep -Eq 'gh[[:space:]]+api' && printf '%s' "$seg" | grep -Eqi '(/merge|APPROVE)' && block "merging/approving via gh api is not allowed during an AI run"

      # 3. Protected files through the shell (read or write), except read-only git inspection.
      if printf '%s' "$seg" | grep -Eq "$PROTECTED"; then
        printf '%s' "$seg" | grep -Eq '^git[[:space:]]+(status|diff|log|show|check-ignore)([[:space:]]|$)' \
          || block ".github/ and .env files can't be accessed from the shell during an AI run (got: $seg)"
      fi
    done <<< "$(printf '%s\n' "$cmd" | sed -E 's/(&&|\|\||;|\|)/\n/g')"
    ;;
esac
exit 0
