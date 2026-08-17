---
description: Remove AI code slop
model: openai/gpt-5.6-sol
---

## TARGET BRANCH ARGUMENT

`$ARGUMENTS`

## PULL REQUEST TARGET BRANCH

!`gh pr view "$(git branch --show-current)" --repo "$(git remote get-url origin)" --json baseRefName --jq '.baseRefName' 2>/dev/null || true`

Choose the diff target in this order:

1. The target branch argument, if provided.
2. The pull request target branch shown above, if available.
3. The first branch that exists on `origin` in this order: `develop`, `dev`, `main`, `master`.

Fetch `origin`, check the diff against `origin/<target-branch>`, and remove all AI generated slop introduced in this branch.

This includes:

- Extra comments that a human wouldn't add or is inconsistent with the rest of the file
- Extra defensive checks or try/catch blocks that are abnormal for that area of the codebase (especially if called by trusted / validated codepaths)
- Casts to any to get around type issues
- Any other style that is inconsistent with the file
- Unnecessary emoji usage

Report at the end with only a 1-3 sentence summary of what you changed
