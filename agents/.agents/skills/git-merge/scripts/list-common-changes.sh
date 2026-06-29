#!/usr/bin/env bash
#
# list-common-changes.sh - List files changed on both branches with full context
#
# Identifies the interaction surface between two branches: files modified on
# both sides since their merge base. For each file, shows the status, diff
# stats, and commits from each branch — everything needed to plan a merge
# without running additional git commands.
#
# Also surfaces documentation (*.md, *.mdx, *.rst, *.adr) changed on EITHER
# branch — prose that often explains *why* a side changed, which the code diff
# can't carry — so it doesn't slip past just because it changed on only one
# side and never conflicted. A per-PR decision log a repo keeps (e.g. under
# .worklogs/) rides along here and is especially high-signal.
#
# Usage: list-common-changes.sh <source-branch> <target-branch>
#
# Run from inside the git repository (uses the current working directory's
# repo). Branch names may be local or remote-tracking (e.g. origin/feat/x).
#
# Examples:
#   list-common-changes.sh feat/price-filter feat/faceted-search
#   list-common-changes.sh origin/feat/a origin/feat/b
#

set -euo pipefail

_git() { command git "$@"; }

show_usage() {
    echo "Usage: $0 <source-branch> <target-branch>"
    echo ""
    echo "List files changed on both branches since their merge base, with"
    echo "status, diff stats, and commits from each branch per file."
    echo ""
    echo "Run from inside the git repository."
    echo ""
    echo "Examples:"
    echo "  $0 feat/price-filter feat/faceted-search"
    echo "  $0 origin/feat/a origin/feat/b"
    exit 1
}

if [ $# -ne 2 ]; then
    show_usage
fi

SOURCE="$1"
TARGET="$2"

# Must be run from inside a git work tree
if ! _git rev-parse --is-inside-work-tree &>/dev/null; then
    echo "Error: not inside a git repository. Run this from within the repo (or a worktree)." >&2
    exit 1
fi

# Verify both branches exist
for branch in "$SOURCE" "$TARGET"; do
    if ! _git rev-parse --verify "$branch" &>/dev/null; then
        echo "Error: Branch '$branch' not found. Try fetching or use 'origin/$branch'." >&2
        exit 1
    fi
done

# Find the merge base
MERGE_BASE=$(_git merge-base "$SOURCE" "$TARGET")
if [ -z "$MERGE_BASE" ]; then
    echo "Error: No common ancestor found between '$SOURCE' and '$TARGET'." >&2
    exit 1
fi

# ===========================================================================
# Collect raw git data
# ===========================================================================

# Tip info: hash, subject, date
read -r MB_HASH MB_MSG <<< "$(_git log --format='%h %s' -1 "$MERGE_BASE")"
MB_DATE=$(_git log --format='%ci' -1 "$MERGE_BASE")

read -r SRC_HASH SRC_MSG <<< "$(_git log --format='%h %s' -1 "$SOURCE")"
SRC_DATE=$(_git log --format='%ci' -1 "$SOURCE")

read -r TGT_HASH TGT_MSG <<< "$(_git log --format='%h %s' -1 "$TARGET")"
TGT_DATE=$(_git log --format='%ci' -1 "$TARGET")

# Commit counts
SRC_COUNT=$(_git rev-list --count "$MERGE_BASE".."$SOURCE")
TGT_COUNT=$(_git rev-list --count "$MERGE_BASE".."$TARGET")

# File status + renames (--name-status -M)
SRC_NAME_STATUS=$(_git diff --name-status -M "$MERGE_BASE" "$SOURCE")
TGT_NAME_STATUS=$(_git diff --name-status -M "$MERGE_BASE" "$TARGET")

# Line stats (--numstat -M)
SRC_NUMSTAT=$(_git diff --numstat -M "$MERGE_BASE" "$SOURCE")
TGT_NUMSTAT=$(_git diff --numstat -M "$MERGE_BASE" "$TARGET")

# ===========================================================================
# Parse into lookup tables
# ===========================================================================

declare -A SRC_STATUS SRC_OLD SRC_ADDED SRC_REMOVED
declare -A TGT_STATUS TGT_OLD TGT_ADDED TGT_REMOVED

# Parse --name-status output into STATUS and OLD arrays
# Format: STATUS\tpath (or for renames: R0xx\told-path\tnew-path)
parse_name_status() {
    local -n _status=$1
    local -n _old=$2
    local input="$3"

    while IFS=$'\t' read -r code path1 path2; do
        [ -z "$code" ] && continue
        if [[ "$code" == R* || "$code" == C* ]]; then
            _status["$path2"]="$code"
            _old["$path2"]="$path1"
        else
            _status["$path1"]="$code"
        fi
    done <<< "$input"
}

# Parse --numstat output into ADDED and REMOVED arrays
# Format: added\tremoved\tpath (renames use {old => new} notation)
parse_numstat() {
    local -n _added=$1
    local -n _removed=$2
    local input="$3"

    while IFS=$'\t' read -r added removed path; do
        [ -z "$path" ] && continue
        # Resolve {old => new} rename notation to just the new path
        local resolved
        resolved=$(echo "$path" | sed 's/{[^}]* => \([^}]*\)}/\1/g; s|//|/|g')
        _added["$resolved"]="$added"
        _removed["$resolved"]="$removed"
    done <<< "$input"
}

parse_name_status SRC_STATUS SRC_OLD "$SRC_NAME_STATUS"
parse_name_status TGT_STATUS TGT_OLD "$TGT_NAME_STATUS"
parse_numstat SRC_ADDED SRC_REMOVED "$SRC_NUMSTAT"
parse_numstat TGT_ADDED TGT_REMOVED "$TGT_NUMSTAT"

# ===========================================================================
# Classify files
# ===========================================================================

SRC_PATHS=$(printf '%s\n' "${!SRC_STATUS[@]}" | sort)
TGT_PATHS=$(printf '%s\n' "${!TGT_STATUS[@]}" | sort)

BOTH_FILES=$(comm -12 <(echo "$SRC_PATHS") <(echo "$TGT_PATHS"))
BOTH_COUNT=$(echo "$BOTH_FILES" | grep -c . || true)
SRC_ONLY_COUNT=$(comm -23 <(echo "$SRC_PATHS") <(echo "$TGT_PATHS") | grep -c . || true)
TGT_ONLY_COUNT=$(comm -13 <(echo "$SRC_PATHS") <(echo "$TGT_PATHS") | grep -c . || true)
TOTAL_COUNT=$((BOTH_COUNT + SRC_ONLY_COUNT + TGT_ONLY_COUNT))

# Documentation changed on EITHER branch, regardless of whether it conflicted.
# Prose (READMEs, design notes, ADRs, and any per-PR decision log a repo keeps)
# states *why* a side changed — signal the code diff can't carry. Detected by
# extension from the union of all changed paths.
ALL_FILES=$( { echo "$SRC_PATHS"; echo "$TGT_PATHS"; } | sort -u | grep -v '^$' || true)

is_doc() {
    case "$1" in
        *.md|*.mdx|*.rst|*.adr) return 0 ;;
        *) return 1 ;;
    esac
}

DOC_FILES=""
while IFS= read -r f; do
    [ -z "$f" ] && continue
    if is_doc "$f"; then DOC_FILES+="${f}"$'\n'; fi
done <<< "$ALL_FILES"

DOC_COUNT=$(echo "$DOC_FILES" | grep -c . || true)

# ===========================================================================
# Helpers
# ===========================================================================

format_stats() {
    local added="$1" removed="$2"
    if [[ "$added" == "-" && "$removed" == "-" ]]; then
        echo "(binary)"
    else
        echo "(+${added} -${removed})"
    fi
}

format_file_status() {
    local status="$1" added="$2" removed="$3" old="$4"
    local stats
    stats=$(format_stats "$added" "$removed")
    if [[ -n "$old" ]]; then
        echo "${status} (from ${old})  ${stats}"
    else
        echo "${status}  ${stats}"
    fi
}

print_commits() {
    local branch="$1" label="$2"
    shift 2
    local commits
    commits=$(_git log --oneline "$MERGE_BASE".."$branch" -- "$@")
    echo "  ${label}:"
    if [ -n "$commits" ]; then
        echo "$commits" | sed 's/^/    /'
    else
        echo "    (no direct commits)"
    fi
}

# Which side(s) changed a path: "both" | "source" | "target"
side_of() {
    local path="$1" s="" t=""
    [[ -n "${SRC_STATUS[$path]:-}" ]] && s=1
    [[ -n "${TGT_STATUS[$path]:-}" ]] && t=1
    if [[ -n "$s" && -n "$t" ]]; then echo "both"
    elif [[ -n "$s" ]]; then echo "source"
    else echo "target"; fi
}

print_signal_file() {
    local file="$1"
    echo ""
    echo "--- ${file}  [$(side_of "$file")] ---"
    if [[ -n "${SRC_STATUS[$file]:-}" ]]; then
        echo "  Source: $(format_file_status "${SRC_STATUS[$file]}" "${SRC_ADDED[$file]:-0}" "${SRC_REMOVED[$file]:-0}" "${SRC_OLD[$file]:-}")"
    fi
    if [[ -n "${TGT_STATUS[$file]:-}" ]]; then
        echo "  Target: $(format_file_status "${TGT_STATUS[$file]}" "${TGT_ADDED[$file]:-0}" "${TGT_REMOVED[$file]:-0}" "${TGT_OLD[$file]:-}")"
    fi
}

# ===========================================================================
# Output
# ===========================================================================

# Branch Overview
cat <<EOF
================================================================================
BRANCH OVERVIEW
================================================================================

Merge Base
  Commit:  ${MB_HASH} ${MB_MSG}
  Date:    ${MB_DATE}

Source Branch: ${SOURCE}
  Tip:     ${SRC_HASH} ${SRC_MSG}
  Date:    ${SRC_DATE}
  Commits: ${SRC_COUNT}

Target Branch: ${TARGET}
  Tip:     ${TGT_HASH} ${TGT_MSG}
  Date:    ${TGT_DATE}
  Commits: ${TGT_COUNT}

File Summary
  Changed on both branches:  ${BOTH_COUNT} files  (interaction surface, listed below)
  Source-only:               ${SRC_ONLY_COUNT} files
  Target-only:               ${TGT_ONLY_COUNT} files
  Total changed:             ${TOTAL_COUNT} files
  Documentation changed:     ${DOC_COUNT} file(s)  (either branch — listed below)
EOF

# Interaction Surface
echo ""
cat <<EOF
================================================================================
FILES CHANGED ON BOTH BRANCHES (${BOTH_COUNT} files)
================================================================================
EOF

if [[ "$BOTH_COUNT" -gt 0 ]]; then
    while IFS= read -r file; do
        [ -z "$file" ] && continue
        echo ""
        echo "--- ${file} ---"

        src_stat=$(format_file_status "${SRC_STATUS[$file]}" "${SRC_ADDED[$file]:-0}" "${SRC_REMOVED[$file]:-0}" "${SRC_OLD[$file]:-}")
        tgt_stat=$(format_file_status "${TGT_STATUS[$file]}" "${TGT_ADDED[$file]:-0}" "${TGT_REMOVED[$file]:-0}" "${TGT_OLD[$file]:-}")
        echo "  Source: ${src_stat}"
        echo "  Target: ${tgt_stat}"

        # Build path args for commit lookup (include old path for renames)
        src_paths=("$file")
        [[ -n "${SRC_OLD[$file]:-}" ]] && src_paths+=("${SRC_OLD[$file]}")
        tgt_paths=("$file")
        [[ -n "${TGT_OLD[$file]:-}" ]] && tgt_paths+=("${TGT_OLD[$file]}")

        print_commits "$SOURCE" "Source commits" "${src_paths[@]}"
        print_commits "$TARGET" "Target commits" "${tgt_paths[@]}"
    done <<< "$BOTH_FILES"
else
    echo ""
    echo "No files changed on both branches."
fi

# Documentation Changes
echo ""
cat <<EOF

================================================================================
DOCUMENTATION CHANGES (${DOC_COUNT} file(s))
================================================================================

Documentation added or modified on either branch — high-signal context for the
change. Documentation explains the code, so reading it can reveal intent the
code diff doesn't; some kinds (changelogs, worklogs) state outright what changed
and why. Consider reading the documents listed below before you resolve.
Read content with:  git show <branch>:<path>
EOF

if [[ "$DOC_COUNT" -gt 0 ]]; then
    while IFS= read -r file; do
        [ -z "$file" ] && continue
        print_signal_file "$file"
    done <<< "$DOC_FILES"
else
    echo ""
    echo "No documentation changed on either branch."
fi
