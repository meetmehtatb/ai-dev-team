# Changelog

## 1.4.0
- New **triage** agent: sizes each task and picks a pipeline, **quick** (developer, tester, quick-mode reviewer), **standard** (adds baseline, tests, code-quality, security, fresh review) or **full** (adds analyst and architect).
- Safety floor: risk flags (auth, API, input, data, dependencies, secrets, payments, personal data) force at least standard with security; tests always run on code changes; when unsure, the bigger tier wins.
- Escalation: after every developer round the orchestrator compares the real diff with triage's estimate and upgrades the tier if needed; a quick-tier test failure or a reviewer `ESCALATE:` also escalates.
- Reviewer **quick mode** (also checks obvious quality and security issues) and tester quick mode.
- `/solve-issue --quick` / `--full` overrides; `/plan-issue` shows the triage result.
- README: "Right-sized pipelines" section with diagram and comparison table.

## 1.3.0
- Works in cloud sessions (Claude mobile app, claude.ai/code): GitHub operations use `gh` when available and the GitHub MCP tools otherwise.
- Review agents no longer call GitHub; the orchestrator prepares a PR bundle (`ai-runs/pr-P/`) and posts the review.
- Post-PR review falls back to fresh sub-agents in the same session when `claude -p` is unavailable.
- Project install (`install.sh <repo>` / `install.ps1 -Project`) now includes the safety hook and adds `ai-runs/` to `.gitignore`; commit `.claude/` to use the team from your phone.
- README: new "Use it from your phone or the web" section with diagram.

## 1.2.1
- README rewritten for onboarding: contents, 30-second overview, full-flow, run-sequence, agents, Docker and safety diagrams (Mermaid, rendered by GitHub), run outputs, FAQ and repo map. PNG exports in `docs/diagrams/`.
- New `AGENTS.md`: orientation and contracts for AI assistants working on this repo.

## 1.2.0
- New **code-quality** agent: duplication, complexity, naming, dead code, error handling, type safety, conventions, test quality, and the project's lint/format/typecheck. Every finding blocks (Must-fix, Should-fix and nits).
- New **security** agent: injection, XSS, authn/authz, secrets, SSRF, path traversal, deserialization, crypto, data exposure, config, and dependency audit. Every finding blocks, whatever its severity (Critical to Low).
- Review gate in `/solve-issue` now runs reviewer, code-quality and security in parallel each round; a PR only opens when both report zero findings.
- `/review-pr` runs code-quality and security first and posts one combined review.
- New `/quality-check` and `/security-check` commands for the current branch or a PR.

## 1.1.0
- Packaged as a Claude Code plugin with its own marketplace (`/plugin marketplace add meetmehtatb/ai-dev-team`).
- Baseline check before development, so failures that already exist are not blamed on the change.
- Resume a stopped run with `/solve-issue N --resume` (state saved in `ai-runs/issue-N/state.json`).
- Early stop when the same failure repeats in two rounds; reviewer verifies earlier findings instead of adding new nitpicks.
- New `/plan-issue` command: ticket and plan preview, no code.
- Safety hook (active only during a run): only `git push -u origin issue-N` is allowed; blocks force-push, other refspecs, merge/approve (gh and gh api), nested-shell bypasses, and any edit or shell access to `.github/` and `.env*`. Works in linked worktrees.
- Docker image, compose file and `run.sh` / `run.ps1` one-command start, with Docker install steps in the README.
- Commits and PRs are made as the user, with no AI attribution lines.

## 1.0.0
- Orchestrator `/solve-issue` with analyst, architect, developer, tester and reviewer agents.
- Independent post-PR review `/review-pr` in a fresh Claude session.
