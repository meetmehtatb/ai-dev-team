# AI Dev Team for Claude Code

Give it a rough idea or a GitHub issue. It gives you back a tested, reviewed pull request.

```
/solve-issue "users should be able to mark items as favourite"
```

A team of Claude Code agents does the work: one thinks it through, one plans, one codes, one tests, and three review it (correctness, code quality, security). After the PR is open, a **separate, fresh session** reviews it again with no memory of how it was built.

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

> Prefer not to install anything but Docker? See [Run it in Docker](#run-it-in-docker-optional-safer): `./run.sh /path/to/your-repo`.

> Private repo? Ask the owner to add you as a collaborator first, and run `gh auth login` so the marketplace can be read.

---

## Commands

| Command | What it does |
|---|---|
| `/solve-issue "<idea>"` | Full run from a rough idea: creates the issue, builds, tests, reviews, opens the PR |
| `/solve-issue 42` | Same, for an existing issue (number or full URL) |
| `/solve-issue 42 --resume` | Continue a run that stopped |
| `/plan-issue "<idea>"` | Preview only: ticket + technical plan, no code, no branches |
| `/review-pr 57` | Independent review of any PR (correctness + code quality + security), posted as one PR comment |
| `/quality-check` / `/quality-check 57` | Code quality review of your current branch, or of a PR. Read-only |
| `/security-check` / `/security-check 57` | Security review of your current branch, or of a PR. Read-only |

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
 7. review gate  REVIEW   3 reviewers in parallel ─ any blocking ─┘
      ├─ reviewer      correctness vs the ticket
      ├─ code-quality  duplication, complexity, types, lint/format
      └─ security      injection, XSS, auth, secrets, dependencies
        │           └─────────────────────────────────────────┘
        ▼   (only when tests pass AND all three reviewers pass)
 8. pull request          commit, push issue-N, open PR
 9. NEW SESSION  code-quality + security + pr-reviewer, fresh eyes, one combined review on the PR
                          blocking findings ─▶ asks you before fixing
```

The loop stops early if the same failure comes back twice. If it still fails after 3 rounds, no PR is opened and you get a report of what is broken.

| Agent | Job | Can change code? |
|---|---|---|
| analyst | Turns a rough idea into a ticket | No |
| architect | Turns the ticket into a plan | No |
| developer | Writes the code | Yes |
| tester | Writes tests, runs checks | Test files only |
| reviewer | Checks the change does what the ticket asks | No |
| code-quality | Maintainability: duplication, complexity, naming, dead code, types, lint/format | No |
| security | Vulnerabilities: injection, XSS, auth, secrets, SSRF, risky dependencies | No |
| pr-reviewer | Reviews after the PR, in a new session | No |

### What blocks a PR

| Reviewer | Blocks (sent back to the developer) | Reported in the PR only |
|---|---|---|
| reviewer | Acceptance criteria not met, bugs, regressions | Optional suggestions |
| code-quality | **Every** finding: lint/format/type errors, dead or debug code, duplication, swallowed errors, `any`, weakened tests, unrelated changes, and also should-fix items and nits | Nothing |
| security | **Every** finding, any severity: Critical, High, Medium and Low (e.g. injection, XSS, missing auth, secrets, weak config) | Nothing |

Nothing is left to "fix later": a PR only opens when code quality and security report zero findings. Stricter gates mean more fix rounds; if issues remain after 3 rounds, the run stops without a PR and the report lists what is left.

Every step is logged in `ai-runs/issue-N/` in your project: ticket, plan, and each round's developer, test, review, quality and security reports.

---

## Your name on the work

Commits and PRs are made **as you**, with your own git identity. The team never adds "Co-Authored-By: Claude" or "Generated with" lines. Check your identity once:

```
git config --global user.name "Your Name"
git config --global user.email "you@example.com"
```

---

## Run it in Docker (optional, safer)

The agents run your project's code and tests. Docker keeps that inside a container, away from your machine. Everything you need (Claude Code, the team, git, GitHub CLI, Node, npm, pnpm, yarn) is already in the image.

### Step 1: Install Docker (once)

| OS | How |
|---|---|
| **Windows 10/11** | 1. Install **WSL 2**: open PowerShell as Administrator, run `wsl --install`, restart.<br>2. Download and install **Docker Desktop**: https://www.docker.com/products/docker-desktop/<br>3. Start Docker Desktop and wait until it says "Engine running". |
| **macOS** | Download **Docker Desktop** (Apple chip or Intel): https://www.docker.com/products/docker-desktop/ , open it, wait for "Engine running". Or `brew install --cask docker`. |
| **Linux** | `curl -fsSL https://get.docker.com \| sh`, then `sudo usermod -aG docker $USER` and log out and back in. |

Check it works:
```
docker --version
docker compose version
docker run --rm hello-world
```

### Step 2: Get this repo and fill in `.env` (once)

```bash
git clone https://github.com/meetmehtatb/ai-dev-team
cd ai-dev-team
cp .env.example .env          # Windows PowerShell: copy .env.example .env
```

Open `.env` and fill in:

| Setting | Needed? | What |
|---|---|---|
| `GH_TOKEN` | Yes | GitHub token. Create at https://github.com/settings/personal-access-tokens: **Fine-grained**, select your repo, set Contents, Issues and Pull requests to **Read and write** |
| `GIT_USER_NAME` | Yes | Your name, so commits are yours |
| `GIT_USER_EMAIL` | Yes | The email on your GitHub account |
| `ANTHROPIC_API_KEY` | No | Only if you use an API key. Otherwise you log in with your Claude account (Pro/Max) on first start |

Never commit `.env` (it is already in `.gitignore`).

### Step 3: Start it for your project

```bash
# macOS / Linux
./run.sh /path/to/your-repo

# Windows PowerShell
.\run.ps1 C:\path\to\your-repo
```

The first start builds the image (a few minutes). Claude Code then opens inside the container with the team installed:
1. First time only: log in to Claude when asked. The login is saved in a Docker volume.
2. Run `/solve-issue "your idea"` as usual. Your project folder is mounted, so the branch, commits and PR are the same as running it locally.

Type `/exit` to leave; the container is removed, your project and login stay.

<details>
<summary>Without the run scripts (plain docker compose)</summary>

```bash
docker compose build
PROJECT_DIR=/path/to/your-repo docker compose run --rm ai-dev-team            # macOS / Linux
$env:PROJECT_DIR="C:\path\to\your-repo"; docker compose run --rm ai-dev-team  # Windows PowerShell
```
</details>

### Docker tips

| Problem | Fix |
|---|---|
| "Docker is not running" | Start Docker Desktop and wait for "Engine running" |
| Windows: very slow `npm install` | Keep the project inside WSL (e.g. `\\wsl$\Ubuntu\home\you\project`) instead of `C:\` |
| Update Claude Code or the team | `docker compose build --no-cache` |
| Log in again / reset | `docker volume rm ai-dev-team_claude-home` |
| Python / Go / Java project | Add that toolchain to the `Dockerfile` (e.g. `apt-get install -y python3-pip`) and rebuild |

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
