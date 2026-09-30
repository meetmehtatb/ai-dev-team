# AI Dev Team for Claude Code

A team of Claude Code sub-agents that turns a rough requirement or a GitHub issue into a tested, reviewed pull request. It runs on your own machine, in your own repository.

```
/solve-issue "users should be able to mark items as favourite"
/solve-issue 42
/solve-issue https://github.com/<owner>/<repo>/issues/42
/review-pr 57
```

## Flow
```
requirement / issue
   │
   ├─ 1. analyst      THINK   rough idea -> Jira-style ticket (creates the GitHub issue)   read-only
   ├─ 2. setup                branch issue-N from the default branch, in your checkout
   ├─ 3. architect    PLAN    ticket -> technical plan                                     read-only
   │  ╔═══════════════ loop, max 3 rounds ═══════════════╗
   ├─ ║ 4. developer  BUILD   implements / fixes          ║◀─┬─┐
   ├─ ║ 5. tester     TEST    tests, lint, typecheck, build ── FAIL ──┘ │
   ├─ ║ 6. reviewer   REVIEW  diff vs ticket   ── CHANGES_REQUESTED ────┘
   │  ╚══════════════════════════════════════════════════╝
   ├─ 7. PR                   commit, push issue-N, open PR   (only if tests PASS and review APPROVE)
   └─ 8. pr-reviewer  NEW SESSION  `claude -p "/review-pr P"`: fresh context, posts a review on the PR
                              blocking findings -> asks you before one more fix round
```

| Agent | Role | Edits code? |
|---|---|---|
| Orchestrator (`/solve-issue`) | Runs all stages, loop limit, PR, launches the fresh review | No |
| `analyst` | Rough requirement -> ticket | No |
| `architect` | Ticket -> plan | No |
| `developer` | Implementation | Yes |
| `tester` | Tests + checks | Test files only |
| `reviewer` | Internal review before the PR | No |
| `pr-reviewer` (`/review-pr`) | Independent review after the PR, separate session | No |

Works with npm, pnpm, yarn and bun projects out of the box (commands are detected from the lockfile and scripts); other stacks work if their standard test tooling is set up. The default branch is detected automatically.

## Requirements
- [Claude Code](https://claude.com/claude-code), logged in, with the `claude` command on your PATH
- [GitHub CLI](https://cli.github.com/) logged in: `gh auth login` (Windows: `winget install GitHub.cli`)
- git with push access to the target repository
- Your project's toolchain (e.g. Node.js)

## Install
Clone this repo, then:

**All projects (user level)**
```bash
./install.sh            # macOS / Linux / Git Bash
.\install.ps1           # Windows PowerShell
```

**One project only**
```bash
./install.sh /path/to/your-repo
.\install.ps1 -Project C:\path\to\your-repo
```

This copies `agents/` and `commands/` into `.claude/`. If a `settings.json` already exists it is kept, and the team's permission rules are written next to it as `ai-team.settings.example.json` for you to merge.

Then open your project with `claude` and run `/solve-issue ...`.

## Skills
Every agent may use installed skills (Skill tool) when they fit, e.g. frontend design, testing, code review, security review. Add marketplace skills in Claude Code:
```
/plugin marketplace add <owner/repo>
/plugin install <plugin>@<marketplace>
```

## Safety
- Requirement and issue text are treated as data; commands inside them are never run.
- Never pushes the default branch, never force-pushes, never merges or deploys. Reviewers only comment, never approve.
- `.github/` and `.env*` can't be edited; `.env*` can't be read.
- Needs a clean working tree. Max 3 developer rounds, then it stops without a PR.
- AI-written code and tests run on your machine: use it on repositories you trust, or inside a container.

## Run logs
Every stage writes to `ai-runs/issue-N/` in your project (ticket, plan, per-round developer/test/review reports, final report). Add `ai-runs/` to your `.gitignore` (the orchestrator also excludes it locally).

## Re-running an issue
```bash
git switch <default-branch>
git branch -D issue-N
git push origin --delete issue-N
```
