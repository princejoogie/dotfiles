---
description: Rebase onto the pull request target branch
model: openai/gpt-5.6-sol
subtask: true
---

## TARGET BRANCH ARGUMENT

`$ARGUMENTS`

## PULL REQUEST TARGET BRANCH

!`gh pr view "$(git branch --show-current)" --repo "$(git remote get-url origin)" --json baseRefName --jq '.baseRefName' 2>/dev/null || true`

Choose the rebase target in this order:

1. The target branch argument, if provided.
2. The pull request target branch shown above, if available.
3. The first branch that exists on `origin` in this order: `develop`, `dev`, `main`, `master`.

Fetch `origin` and rebase the current branch onto `origin/<target-branch>`.

If there are conflicts, use my `git-merge` skill to resolve them and continue the rebase until it completes.

Do not force push unless I explicitly ask.
