#!/bin/bash
set -euo pipefail

# Kojarchy upstream sync checker
# Compares omarchy changes since our last-known commit and uses opencode
# to analyze and optionally apply changes to our repo.

KOJARCHY_DIR="$(cd "$(dirname "$0")" && pwd)"
OMARCHY_REPO="https://github.com/basecamp/omarchy.git"
OMARCHY_LOCAL="/tmp/kojarchy-omarchy-upstream"
ANALYSIS_FILE="/tmp/kojarchy-upstream-analysis.md"
DIFF_FILE="/tmp/kojarchy-omarchy-diff.patch"

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

# Write diff to temp file
echo "$DIFF_FULL" > "$DIFF_FILE"

# ──────────────────────────────────────────
# Phase 1: Analysis
# ──────────────────────────────────────────

ANALYSIS_PROMPT="I need you to analyze upstream changes from omarchy (https://github.com/basecamp/omarchy) and determine what we should sync to our kojarchy dotfiles repo.

## Context
- Our repo is at: $KOJARCHY_DIR
- We are based on omarchy's architecture (install scripts, two-layer config, lib helpers, etc.)
- Our last sync was at omarchy commit: $OMARCHY_BASELINE
- Omarchy is now at: $OMARCHY_LATEST
- The omarchy repo is cloned at: $OMARCHY_LOCAL

## New omarchy commits since our baseline:
$COMMIT_LOG

## Changed files summary:
$DIFF_STAT

## Full diff is at: $DIFF_FILE

## Instructions
1. Read the full diff at $DIFF_FILE
2. Read our current repo files at $KOJARCHY_DIR as needed for comparison
3. For each change, determine if it's relevant to our kojarchy setup
4. Categorize changes as:
   - **SYNC**: We should port this change (explain what and why)
   - **SKIP**: Not relevant to us (explain why — e.g., we don't use that tool, different approach)
   - **REVIEW**: Needs manual review (explain the tradeoff)
5. For SYNC items, describe exactly what files in our repo need changing and what the change should be
6. Do NOT make any changes — this is analysis only
7. Write your full analysis to: $ANALYSIS_FILE

Use this exact format in $ANALYSIS_FILE:

\`\`\`
# Upstream Sync Analysis
Baseline: $OMARCHY_BASELINE
Latest: $OMARCHY_LATEST

## SYNC
### 1. <short title>
- **Omarchy file**: <path>
- **Kojarchy file**: <path>
- **Change**: <description>

## SKIP
### 1. <short title>
- **Reason**: <why>

## REVIEW
### 1. <short title>
- **Tradeoff**: <description>
\`\`\`

Focus on: install scripts, lib helpers, boot.sh/install.sh patterns, config deployment logic, service setup, and any new best practices."

echo "Phase 1: Running analysis..."
echo ""

opencode run "$ANALYSIS_PROMPT"

# ──────────────────────────────────────────
# Phase 2: User review
# ──────────────────────────────────────────

if [[ ! -f "$ANALYSIS_FILE" ]]; then
  echo ""
  echo "Analysis file not found at $ANALYSIS_FILE"
  echo "opencode may have printed the analysis to stdout instead. Re-run or apply manually."
  exit 1
fi

echo ""
echo "=== Analysis Complete ==="
echo ""
cat "$ANALYSIS_FILE"
echo ""

if ! command -v gum &>/dev/null; then
  echo "Install gum to use interactive mode: sudo pacman -S gum"
  echo "Analysis saved to: $ANALYSIS_FILE"
  exit 0
fi

echo ""
CHOICE=$(gum choose \
  "Apply SYNC changes (let opencode make the changes)" \
  "Edit analysis first (open in \$EDITOR)" \
  "Skip for now (analysis saved to $ANALYSIS_FILE)")

case "$CHOICE" in
"Edit analysis first"*)
  ${EDITOR:-nvim} "$ANALYSIS_FILE"
  echo ""
  if ! gum confirm "Apply changes from the edited analysis?"; then
    echo "Skipped. Analysis at: $ANALYSIS_FILE"
    exit 0
  fi
  ;;
"Skip for now"*)
  echo "Analysis saved to: $ANALYSIS_FILE"
  exit 0
  ;;
esac

# ──────────────────────────────────────────
# Phase 3: Apply changes
# ──────────────────────────────────────────

ANALYSIS_CONTENT=$(<"$ANALYSIS_FILE")

APPLY_PROMPT="Apply the following upstream sync changes to our kojarchy repo at $KOJARCHY_DIR.

## Analysis
$ANALYSIS_CONTENT

## Full omarchy diff is at: $DIFF_FILE
## The omarchy repo is cloned at: $OMARCHY_LOCAL (use this to read full file contents if needed)

## Instructions
1. Only apply changes marked as **SYNC** in the analysis above
2. For each SYNC item, make the corresponding change in our repo
3. Adapt the changes to our kojarchy naming/structure (not copy-paste from omarchy)
4. Do NOT commit — just make the file changes
5. After all changes, print a summary of what was modified"

echo ""
echo "Phase 3: Applying SYNC changes..."
echo ""

opencode run "$APPLY_PROMPT"

# ──────────────────────────────────────────
# Phase 4: Review and update baseline
# ──────────────────────────────────────────

echo ""
echo "=== Changes applied. Review with: git diff ==="
echo ""

if gum confirm "Update baseline to $OMARCHY_LATEST?"; then
  sed -i "s/^OMARCHY_BASELINE=.*/OMARCHY_BASELINE=\"$OMARCHY_LATEST\"/" "$KOJARCHY_DIR/check-upstream.sh"
  echo "Baseline updated to: $OMARCHY_LATEST"
  echo ""
  echo "Don't forget to commit when you're happy with the changes:"
  echo "  cd $KOJARCHY_DIR && git add -A && git commit -m 'sync: upstream omarchy changes to $OMARCHY_LATEST'"
else
  echo "Baseline NOT updated. Update manually after reviewing:"
  echo "  OMARCHY_BASELINE in $KOJARCHY_DIR/check-upstream.sh"
fi
