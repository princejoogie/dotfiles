#!/bin/bash
set -euo pipefail

# Kojarchy upstream sync checker
# Compares omarchy changes since our last-known commit and uses opencode
# to interactively walk through each change with the user.

KOJARCHY_DIR="$(cd "$(dirname "$0")" && pwd)"
OMARCHY_REPO="https://github.com/basecamp/omarchy.git"
OMARCHY_LOCAL="/tmp/kojarchy-omarchy-upstream"
DIFF_FILE="/tmp/kojarchy-omarchy-diff.patch"

# Last omarchy commit hash we synced against
OMARCHY_BASELINE="ffafe1727e32c38ba5a291bf3a12d5995a01fda0"

echo "=== Kojarchy Upstream Sync Check ==="
echo "Baseline: $OMARCHY_BASELINE"
echo ""

# Clone or update omarchy
if [[ -d "$OMARCHY_LOCAL/.git" ]]; then
  echo "Updating omarchy clone..."
  git -C "$OMARCHY_LOCAL" fetch origin dev
  git -C "$OMARCHY_LOCAL" reset --hard origin/dev
else
  echo "Cloning omarchy..."
  git clone --single-branch --branch dev "$OMARCHY_REPO" "$OMARCHY_LOCAL"
fi

OMARCHY_LATEST=$(git -C "$OMARCHY_LOCAL" rev-parse HEAD)

if [[ "$OMARCHY_BASELINE" == "$OMARCHY_LATEST" ]]; then
  echo ""
  echo "No new changes in omarchy since baseline."
  echo "Baseline: $OMARCHY_BASELINE"
  exit 0
fi

echo ""
echo "Latest:   $OMARCHY_LATEST"
echo ""

# Get the commit log and diff
COMMIT_LOG=$(git -C "$OMARCHY_LOCAL" log --oneline "$OMARCHY_BASELINE..$OMARCHY_LATEST")
DIFF_STAT=$(git -C "$OMARCHY_LOCAL" diff --stat "$OMARCHY_BASELINE..$OMARCHY_LATEST")
git -C "$OMARCHY_LOCAL" diff "$OMARCHY_BASELINE..$OMARCHY_LATEST" > "$DIFF_FILE"

echo "=== New commits ==="
echo "$COMMIT_LOG"
echo ""
echo "=== Changed files ==="
echo "$DIFF_STAT"
echo ""
echo "Handing off to opencode..."
echo ""

# Single interactive opencode session that analyzes, asks, and applies
opencode run "You are reviewing upstream changes from omarchy to sync into our kojarchy dotfiles repo.

## Context
- Our kojarchy repo: $KOJARCHY_DIR
- Omarchy repo clone: $OMARCHY_LOCAL
- Full diff file: $DIFF_FILE
- Baseline commit: $OMARCHY_BASELINE
- Latest commit: $OMARCHY_LATEST

## Commits since baseline:
$COMMIT_LOG

## Changed files:
$DIFF_STAT

## Your workflow

1. Read the full diff at $DIFF_FILE
2. Read our repo files at $KOJARCHY_DIR as needed for comparison
3. Group related changes together into discrete sync items
4. For each item, **ask me** whether to sync it or skip it. Present each item like this:

   **[1/N] <short title>**
   Omarchy changed: <file(s)>
   What changed: <1-2 sentence summary of what the change does>
   Our equivalent: <kojarchy file(s) that would be affected, or 'new file'>
   Recommendation: SYNC / SKIP / REVIEW (with brief reason)

   Then wait for my response before moving to the next item.

5. After going through all items, apply ONLY the changes I confirmed
6. Adapt all changes to kojarchy naming/structure — do not copy omarchy references verbatim
7. Do NOT commit — just make the file changes
8. After applying, print a summary of what was changed and remind me to review with git diff and commit when ready
9. Then update the OMARCHY_BASELINE variable in $KOJARCHY_DIR/check-upstream.sh from \"$OMARCHY_BASELINE\" to \"$OMARCHY_LATEST\" by editing the file directly"
