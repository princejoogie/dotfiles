---
name: git-merge
description: "Merge one git branch into another with context-aware conflict resolution. Use when merging a feature branch into its base, integrating two branches, reconciling a PR's branch with its target, or resolving merge conflicts thoughtfully (understanding why each side changed before resolving). Triggers on 'merge this branch', 'merge develop into…', 'resolve the conflicts on this PR', or merging two branches."
---

# Git Merge

Merge a source branch into a target branch by first building a picture of *what* changed on
each side and *why* — drawing on every signal the branches carry, not just the raw file diff —
then using that understanding to resolve conflicts so both sides' intent is preserved, rather
than blindly picking a side.

Run from inside the repository (or a worktree). For a PR, the head branch is the source and
the base branch is the target.

## Workflow

### 1) Determine branches

Identify the **source** (being merged in) and **target** (being merged into):

- **PR number/URL** — `gh pr view <pr>`: head branch = source, base branch = target.
- **Two branch names** — use directly.
- **Nothing given** — ask the user.

Verify both exist locally or on the remote (fetch first if needed).

### 2) Read the change — surface *and* intent

A merge is only as good as your understanding of what each side did and why. The file diff
tells you *what* moved; it rarely tells you *why* — and the *why* is what lets you resolve a
conflict without quietly dropping someone's intent. So read the change through two
complementary lenses before touching a conflict.

**a. Map the interaction surface** — where the two sides mechanically collide:

```bash
"${CLAUDE_SKILL_DIR}/scripts/list-common-changes.sh" <source-branch> <target-branch>
```

`${CLAUDE_SKILL_DIR}` is Claude Code's path to this skill's own directory, so the helper runs
regardless of your working directory. If it comes through unexpanded, you're not on Claude Code —
treat it as an indicator that `scripts/list-common-changes.sh` lives in *this skill's* directory
(not your project), and run it from the skill base directory your harness gives you when it loads
the skill.

This prints the merge base, commit counts, and a per-file breakdown of every file changed on
**both** branches — status, diff stats, and the commits from each branch that touched it. Those
files are the *interaction surface*: where conflicts and subtle semantic clashes live. The
helper also lists **documentation changed on *either* branch** — prose that often carries the
intent behind a change — so it doesn't slip past just because it changed on only one side and
never conflicted.

**b. Read the intent signals** — the records the branches carry that state *why* the code
changed. Don't reverse-engineer intent from the diff when a branch tells you directly:

- **Documentation changes** — a branch that touches prose (`*.md`, `*.mdx`, `*.rst`, ADRs —
  READMEs, design notes, changelogs, decision logs) is telling you something about the change:
  documentation explains the code, so it carries context the code diff can't. Take it in two
  steps. First, **read the document** — the whole relevant section, not just the lines that
  changed — because it was touched and is therefore part of this change; it gives you the context
  the code alone doesn't. Then **compare the two branches' versions** of it: what the prose added
  or revised is itself a signal of what each side intended. The helper lists documentation changed
  on either branch so none slips past. Some repos keep a per-PR *decision log* — a "worklog",
  usually under `.worklogs/` — that states the *why this and not that* outright; it's especially
  high-signal where one rides along, though not every repo keeps them.
- **PR descriptions and review comments** — for each branch, find the PRs merged into it since
  the merge base; they explain the *why* at a coarser grain, and the review thread often holds the
  reasoning behind a contested change. Use the commit history from step 2a to find PR numbers
  (merge commits reference them), then `gh pr view <pr> --comments`. Focus on PRs that touched
  interaction-surface files.

Carry what you learn here into every resolution in step 4. Where the signals are thin or absent,
say so rather than inventing a rationale — and lean harder on flagging ambiguity.

### 3) Set up a working copy

Do the merge on the target branch in a clean working copy — **not** a throwaway state you
can't recover. If the project uses worktrees (check its CLAUDE.md), create or reuse one for
the target branch; otherwise check the target branch out. Avoid merging in a primary/shared
checkout if the project reserves that.

### 4) Merge and resolve

```bash
git merge --no-commit --no-ff <source-branch>
```

Resolve conflicts using the surface map and the intent signals from step 2:

- **State intent first** — before resolving each conflict, say what each side intended, citing
  the signal it came from (worklog, PR/comment, doc) when you have one.
- Resolve to **preserve both sides' intended changes**, not just to make it compile.
- **Lockfiles** (`pnpm-lock.yaml`, `package-lock.json`, etc.) — regenerate via the package
  manager (`pnpm install`) rather than hand-merging.
- **Non-conflicted interaction-surface files** — sanity-check that the auto-merge is
  consistent with both sides' intent.
- If a resolution is **ambiguous** and no signal settles it, flag it to the user rather than
  silently picking a side.

### 5) Commit

Stage the resolved files and commit, summarizing what was merged (source → target) and any
notable conflict resolutions. If pre-commit hooks fail, fix and re-commit.

## Guardrails

- **Intent before code** — articulate both sides' intent, and the signal it came from, before
  resolving any conflict.
- **Read the record, don't infer it** — when a branch carries documentation or a PR/review comment
  that explains the *why*, read it rather than reverse-engineering intent from the diff.
- **Don't invent a rationale** — if the signals don't explain a change, treat the intent as
  unknown and flag it; a guessed "why" is worse than an acknowledged gap.
- **Flag uncertainty** — surface ambiguous resolutions instead of guessing.
