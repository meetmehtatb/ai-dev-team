# AI Dev Team for Claude Code

Give it a rough idea or a GitHub issue. It gives you back a tested, reviewed pull request.

```
/solve-issue "users should be able to mark items as favourite"
```

A team of Claude Code agents does the work: one thinks it through, one plans, one codes, one tests, one reviews. After the PR is open, a **separate, fresh session** reviews it again with no memory of how it was built.

---

## Quick start (2 minutes)

**1. Install the tools you need** (once)

| Tool | Install | Check |
|---|---|---|
| Claude Code | https://claude.com/claude-code | `claude --version` |
| GitHub CLI | Windows: `winget install GitHub.cli` · Mac: `brew install gh` | `gh auth login`, then `gh auth status` |
| git | https://git-scm.com | `git config user.name` shows **your** name |

**2. Install the team** (in Claude Code, once)

```
/plugin marketplace add meetmehtatb/ai-dev-team
/plugin install ai-dev-team@ai-dev-team
```

Restart Claude Code. It now works in every project.

**3. Use it** (inside any GitHub repo)

```
cd your-project
claude
> /solve-issue "add a dark mode toggle to the settings page"
```

That's it. You get a GitHub issue, a branch `issue-N`, and a pull request with a test and review summary.

> Private repo? Ask the owner to add you as a collaborator first, and run `gh auth login` so the marketplace can be read.

---

## Commands

| Command | What it does |
|---|---|
| `/solve-issue "<idea>"` | Full run from a rough idea: creates the issue, builds, tests, reviews, opens the PR |
| `/solve-issue 42` | Same, for an existing issue (number or full URL) |
| `/solve-issue 42 --resume` | Continue a run that stopped |
| `/plan-issue "<idea>"` | Preview only: ticket + technical plan, no code, no branches |
| `/review-pr 57` | Independent review of any PR, posted as a PR comment |

If a command name clashes with another plugin, use the full name, e.g. `/ai-dev-team:solve-issue`.

---

## How it works

```
 your idea / issue
        │
        ▼
 1. analyst      THINK    idea ─▶ clear ticket (user story, acceptance criteria)
 2. setup                 branch issue-N from the default branch
 3. tester       BASELINE run the existing checks first (so old failures aren't blamed on the change)
 4. architect    PLAN     ticket ─▶ technical plan
        │
        ▼   ┌──────────── loop, max 3 rounds ────────────┐
 5. developer    BUILD    writes / fixes the code        ◀────────┐
 6. tester       TEST     writes tests, lint, types, build ─ FAIL ┤
 7. reviewer     REVIEW   checks the diff against the ticket ─ CHANGES ┘
        │           └─────────────────────────────────────────┘
        ▼   (only when tests pass AND the reviewer approves)
 8. pull request          commit, push issue-N, open PR
 9. pr-reviewer  NEW SESSION  fresh eyes, posts a review on the PR
                          blocking findings ─▶ asks you before fixing
```

The loop stops early if the same failure comes back twice. If it still fails after 3 rounds, no PR is opened and you get a report of what is broken.

| Agent | Job | Can change code? |
|---|---|---|
| analyst | Turns a rough idea into a ticket | No |
| architect | Turns the ticket into a plan | No |
| developer | Writes the code | Yes |
| tester | Writes tests, runs checks | Test files only |
| reviewer | Reviews before the PR | No |
| pr-reviewer | Reviews after the PR, in a new session | No |

Every step is logged in `ai-runs/issue-N/` in your project: ticket, plan, and each round's developer, test and review reports.

---

## Your name on the work

Commits and PRs are made **as you**, with your own git identity. The team never adds "Co-Authored-By: Claude" or "Generated with" lines. Check your identity once:

```
git config --global user.name "Your Name"
git config --global user.email "you@example.com"
```

---

## Run it in Docker (optional, safer)

The agents run your project's code and tests. To keep that off your machine, run everything in a container.

```bash
git clone https://github.com/meetmehtatb/ai-dev-team
cd ai-dev-team
cp .env.example .env        # then fill in GH_TOKEN, GIT_USER_NAME, GIT_USER_EMAIL
docker compose build
```

Start it for a project:

```bash
# macOS / Linux
PROJECT_DIR=/path/to/your-repo docker compose run --rm ai-dev-team

# Windows PowerShell
$env:PROJECT_DIR="C:\path\to\your-repo"; docker compose run --rm ai-dev-team
```

Claude Code opens inside the container with the team installed. The first time, log in with your Claude account (or set `ANTHROPIC_API_KEY` in `.env`); the login is kept in a Docker volume. Then run `/solve-issue ...` as usual.

| `.env` setting | Needed? | What |
|---|---|---|
| `GH_TOKEN` | Yes | GitHub fine-grained token for the repo: Contents, Issues, Pull requests = Read and write |
| `GIT_USER_NAME`, `GIT_USER_EMAIL` | Yes | So commits are made as you |
| `ANTHROPIC_API_KEY` | No | Only if you use an API key instead of logging in |

The image has Node 22, npm, pnpm, yarn, git and the GitHub CLI. For other stacks (Python, Go, Java...), add their toolchain to the `Dockerfile`.

---

## Safety

- **Never** pushes your default branch, force-pushes, merges or deploys. Reviewers only comment, they never approve.
- `.github/` and `.env*` can't be changed. While a run is active, a safety hook enforces this, so it doesn't rely only on the prompts.
- Text in issues and PRs is treated as data. Commands written inside them are never run.
- Needs a clean working tree. Everything happens on the `issue-N` branch.
- AI-written code and tests run where Claude Code runs. Use Docker for untrusted repos.

---

## Skills

Every agent can use your installed Claude Code skills when they fit (frontend design, testing, code review, security review...). Add more from a marketplace:

```
/plugin marketplace add <owner/repo>
/plugin install <plugin>@<marketplace>
```

---

## Fewer permission prompts (optional)

Claude Code asks before running commands. To pre-approve the team's commands, merge [`settings/permissions.json`](settings/permissions.json) into your `~/.claude/settings.json` (or the project's `.claude/settings.json`).

---

## Manual install (without the plugin)

```bash
git clone https://github.com/meetmehtatb/ai-dev-team && cd ai-dev-team
./install.sh                     # all projects (macOS / Linux / Git Bash)
./install.sh /path/to/repo       # one project
.\install.ps1                    # all projects (Windows)
.\install.ps1 -Project C:\repo   # one project (Windows)
```

The manual install doesn't include the safety hook; the plugin does.

---

## Troubleshooting

| Problem | Fix |
|---|---|
| `/solve-issue` not found | Restart Claude Code after installing, or use `/ai-dev-team:solve-issue` |
| "working tree not clean" | Commit or stash your changes first |
| "branch issue-N already exists" | `git branch -D issue-N` and `git push origin --delete issue-N` |
| `gh: command not found` / auth errors | Install the GitHub CLI and run `gh auth login` |
| Run stopped halfway | `/solve-issue N --resume` |
| Independent review didn't run | Make sure `claude` works in your terminal, then run `/review-pr <PR>` |
| Commits show the wrong author | Set `git config user.name` and `user.email` |

## Update

```
/plugin marketplace update ai-dev-team
```
