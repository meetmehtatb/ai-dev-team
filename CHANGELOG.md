# Changelog

## 1.1.0
- Packaged as a Claude Code plugin with its own marketplace (`/plugin marketplace add meetmehtatb/ai-dev-team`).
- Baseline check before development, so failures that already exist are not blamed on the change.
- Resume a stopped run with `/solve-issue N --resume` (state saved in `ai-runs/issue-N/state.json`).
- Early stop when the same failure repeats in two rounds; reviewer verifies earlier findings instead of adding new nitpicks.
- New `/plan-issue` command: ticket and plan preview, no code.
- Safety hook: blocks edits to `.github/` and `.env*`, pushes to main/master, force-push, merge and approve while a run is active.
- Docker image and compose file for a sandboxed run.
- Commits and PRs are made as the user, with no AI attribution lines.

## 1.0.0
- Orchestrator `/solve-issue` with analyst, architect, developer, tester and reviewer agents.
- Independent post-PR review `/review-pr` in a fresh Claude session.
