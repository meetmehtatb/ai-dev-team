---
description: Independent review of an open PR in a fresh context; posts a review comment on GitHub
argument-hint: <pr-number>
---

Review pull request **#$ARGUMENTS** of this repository. Stop if `$ARGUMENTS` is not a plain number.

Delegate the whole review to the `pr-reviewer` sub-agent (Agent/Task tool, `subagent_type: pr-reviewer`) with `PR = $ARGUMENTS` and output file `ai-runs/pr-$ARGUMENTS-review.md` (create `ai-runs/` if needed). Do not edit any code, do not push, do not merge. When it returns, print the verdict, the number of blocking findings, and the PR URL.
