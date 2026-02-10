#!/bin/bash
set -euo pipefail

# Kojarchy upstream sync checker
# Compares omarchy changes since our last-known commit and uses opencode
# to analyze what needs syncing to our repo.

KOJARCHY_DIR="$(cd "$(dirname "$0")" && pwd)"
OMARCHY_REPO="https://github.com/basecamp/omarchy.git"
OMARCHY_LOCAL="/tmp/kojarchy-omarchy-upstream"

# Last omarchy commit hash we synced against
OMARCHY_BASELINE="ffafe1727e32c38ba5a291bf3a12d5995a01fda0"

echo "=== Kojarchy Upstream Sync Check ==="
echo "Baseline: $OMARCHY_BASELINE"
echo ""

# Clone or update omarchy
if [[ -d "$OMARCHY_LOCAL/.git" ]]; then
  echo "Updating omarchy clone..."
  git -C "$OMARCHY_LOCAL" fetch origin main
  git -C "$OMARCHY_LOCAL" reset --hard origin/main
else
  echo "Cloning omarchy..."
  git clone --single-branch --branch main "$OMARCHY_REPO" "$OMARCHY_LOCAL"
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

# Get the commit log
echo "=== New commits since baseline ==="
COMMIT_LOG=$(git -C "$OMARCHY_LOCAL" log --oneline "$OMARCHY_BASELINE..$OMARCHY_LATEST")
echo "$COMMIT_LOG"
echo ""

# Get the diff (stat + full)
DIFF_STAT=$(git -C "$OMARCHY_LOCAL" diff --stat "$OMARCHY_BASELINE..$OMARCHY_LATEST")
DIFF_FULL=$(git -C "$OMARCHY_LOCAL" diff "$OMARCHY_BASELINE..$OMARCHY_LATEST")

echo "=== Changed files ==="
echo "$DIFF_STAT"
echo ""

# Write diff to a temp file for opencode to reference
DIFF_FILE="/tmp/kojarchy-omarchy-diff.patch"
echo "$DIFF_FULL" > "$DIFF_FILE"

PROMPT="I need you to analyze upstream changes from omarchy (https://github.com/basecamp/omarchy) and determine what we should sync to our kojarchy dotfiles repo.

## Context
- Our repo is at: $KOJARCHY_DIR
- We are based on omarchy's architecture (install scripts, two-layer config, lib helpers, etc.)
- Our last sync was at omarchy commit: $OMARCHY_BASELINE
- Omarchy is now at: $OMARCHY_LATEST

## New omarchy commits since our baseline:
$COMMIT_LOG

## Changed files summary:
$DIFF_STAT

## Full diff is at: $DIFF_FILE

## Instructions
1. Read the full diff at $DIFF_FILE
2. For each change, determine if it's relevant to our kojarchy setup
3. Categorize changes as:
   - **SYNC**: We should port this change (explain what and why)
   - **SKIP**: Not relevant to us (explain why — e.g., we don't use that tool, different approach)
   - **REVIEW**: Needs manual review (explain the tradeoff)
4. For SYNC items, describe exactly what files in our repo need changing
5. Do NOT make any changes — this is analysis only

Focus on: install scripts, lib helpers, boot.sh/install.sh patterns, config deployment logic, service setup, and any new best practices."

echo "Running opencode analysis..."
echo ""

opencode run "$PROMPT"

# Remind to update baseline after syncing
echo ""
echo "=== After syncing, update OMARCHY_BASELINE in this script to: $OMARCHY_LATEST ==="
