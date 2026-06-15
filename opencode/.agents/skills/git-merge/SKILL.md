---
name: git-merge
description: "Merge one git branch into another with context-aware conflict resolution. Use when merging a feature branch into its base, integrating two branches, reconciling a PR's branch with its target, or resolving merge conflicts thoughtfully (understanding why each side changed before resolving). Triggers on 'merge this branch', 'merge develop into…', 'resolve the conflicts on this PR', or merging two branches."
---

# Git Merge

Merge a source branch into a target branch by first understanding *what* changed on each
side and *why*, then using that context to resolve conflicts so both sides' intent is
preserved — rather than blindly picking a side.

Run from inside the repository (or a worktree). For a PR, the head branch is the source and
the base branch is the target.

## Workflow

### 1) Determine branches

Identify the **source** (being merged in) and **target** (being merged into):

- **PR number/URL** — `gh pr view <pr>`: head branch = source, base branch = target.
- **Two branch names** — use directly.
- **Nothing given** — ask the user.

Verify both exist locally or on the remote (fetch first if needed).

### 2) Map the interaction surface

```bash
"${CLAUDE_PLUGIN_ROOT}/skills/git-merge/scripts/list-common-changes.sh" <source-branch> <target-branch>
```

This prints the merge base, commit counts, and a per-file breakdown of every file changed on
**both** branches — status, diff stats, and the commits from each branch that touched it. The
files changed on both sides are the *interaction surface*: where conflicts and subtle
semantic clashes live.

### 3) Gather PR context

For each branch, find the PRs merged into it since the merge base — they explain *why* the
changes were made. Focus on PRs that touched interaction-surface files. Use the commit
history from step 2 to find PR numbers (merge commits reference them), then `gh pr view` for
the title and description.

### 4) Set up a working copy

Do the merge on the target branch in a clean working copy — **not** a throwaway state you
can't recover. If the project uses worktrees (check its CLAUDE.md), create or reuse one for
the target branch; otherwise check the target branch out. Avoid merging in a primary/shared
checkout if the project reserves that.

### 5) Merge and resolve

```bash
git merge --no-commit --no-ff <source-branch>
```

Resolve conflicts using the interaction-surface map and PR context from steps 2–3:

- **State intent first** — before resolving each conflict, say what each side intended.
- Resolve to **preserve both sides' intended changes**, not just to make it compile.
- **Lockfiles** (`pnpm-lock.yaml`, `package-lock.json`, etc.) — regenerate via the package
  manager (`pnpm install`) rather than hand-merging.
- **Non-conflicted interaction-surface files** — sanity-check that the auto-merge is
  consistent with both sides' intent.
- If a resolution is **ambiguous**, flag it to the user rather than silently picking a side.

### 6) Commit

Stage the resolved files and commit, summarizing what was merged (source → target) and any
notable conflict resolutions. If pre-commit hooks fail, fix and re-commit.

## Guardrails

- **Intent before code** — articulate both sides' intent before resolving any conflict.
- **PR descriptions over commit messages** — prefer PR context for the *why*.
- **Flag uncertainty** — surface ambiguous resolutions instead of guessing.
