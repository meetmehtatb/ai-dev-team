# Contributing to ai-dev-team

This repo is a Claude Code **plugin** and its own **marketplace**.

- `.claude-plugin/plugin.json`: plugin manifest. Bump `version` on every release and add a CHANGELOG entry.
- `.claude-plugin/marketplace.json`: marketplace listing (source `./`).
- `agents/`: sub-agents (analyst, architect, developer, tester, reviewer, code-quality, security, pr-reviewer).
- `commands/`: `/solve-issue` (orchestrator), `/plan-issue`, `/review-pr`, `/quality-check`, `/security-check`.
- `hooks/`: PreToolUse safety guard, only active while `.git/ai-dev-team.active` exists.
- `settings/permissions.json`: optional permission allowlist for users; also used by the install scripts and Docker.
- `Dockerfile`, `docker-compose.yml`, `docker/entrypoint.sh`: sandboxed runtime.

## Before committing
```
claude plugin validate . --strict
claude plugin validate .claude-plugin/plugin.json --strict
bash -n hooks/guard.sh docker/entrypoint.sh install.sh
```

## Rules for prompt changes
- Agents must keep their output formats: the orchestrator parses `VERDICT:` lines.
- Keep agents project-agnostic: detect package manager, scripts and default branch; never hardcode npm or `main`.
- Never add AI attribution to commits or PRs the team creates.
