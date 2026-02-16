---
name: worktrees
description: >
  Set up and manage git worktrees for isolated feature work. Use when creating a worktree,
  setting up an isolated branch workspace, working on a feature in a separate directory,
  running parallel branch work, or when .cursor/worktrees.json configuration is involved.
  Handles worktree creation at ~/.worktrees/, dependency installation, and environment file copying.
---

# Git Worktrees

All worktrees go in `~/.worktrees/<repo-name>/<slug>/` — outside the project, no `.gitignore` needed.

## Workflow

### 1. Create the worktree

```bash
MAIN_REPO="$(git rev-parse --show-toplevel)"
REPO_NAME="$(basename "$MAIN_REPO")"
WORKTREE="$HOME/.worktrees/$REPO_NAME/<slug>"

mkdir -p "$(dirname "$WORKTREE")"
git worktree add -b <branch-name> "$WORKTREE" <base-branch>
cd "$WORKTREE"
```

Derive `<slug>` from the branch name (e.g. `fix/IH-694-missing-icon` -> `ih-694`).

### 2. Run setup

Check for `.cursor/worktrees.json` first. If it exists, execute its hooks and skip steps 3–4.

See [references/cursor-worktrees-json.md](references/cursor-worktrees-json.md) for full schema.

```bash
CONFIG="$WORKTREE/.cursor/worktrees.json"
[ ! -f "$CONFIG" ] && CONFIG="$MAIN_REPO/.cursor/worktrees.json"

if [ -f "$CONFIG" ]; then
  export ROOT_WORKTREE_PATH="$MAIN_REPO"
  # Read setup-worktree-unix (preferred) or setup-worktree (fallback)
  # Execute each command sequentially from $WORKTREE; stop on failure
fi
```

If the config handles deps and env files, skip to step 5.

### 3. Copy environment files

Only needed when no `.cursor/worktrees.json` handles this.

Worktrees don't inherit gitignored files. Copy (never symlink) `.env*` files from the main repo:

```bash
cd "$MAIN_REPO"
find . -name '.env*' -type f -not -name '*.sample' -not -path '*/node_modules/*' -not -path '*/.git/*' \
  | while read -r f; do
    if git check-ignore -q "$f" 2>/dev/null; then
      mkdir -p "$WORKTREE/$(dirname "$f")"
      cp "$f" "$WORKTREE/$f"
    fi
  done
```

Never use `ln -s` — glob-based tooling (bundlers, config loaders) silently ignores symlinks.

### 4. Install dependencies

Only needed when no `.cursor/worktrees.json` handles this.

Auto-detect from lockfile and run the matching install command:

| Lockfile | Command |
|---|---|
| `pnpm-lock.yaml` | `pnpm install` |
| `bun.lockb` / `bun.lock` | `bun install` |
| `yarn.lock` | `yarn install` |
| `package-lock.json` | `npm install` |
| `Cargo.toml` | `cargo build` |
| `requirements.txt` | `pip install -r requirements.txt` |
| `pyproject.toml` | `poetry install` or `pip install -e .` |
| `go.mod` | `go mod download` |

### 5. Verify and report

Run project-appropriate tests to confirm a clean baseline. If tests fail, report failures and ask before proceeding.

```text
Worktree ready at ~/.worktrees/<repo>/<slug>
Branch: <branch-name>
Tests: <N> passing
```

## Cleanup

```bash
git worktree remove ~/.worktrees/<repo-name>/<slug>        # normal
git worktree remove --force ~/.worktrees/<repo-name>/<slug> # uncommitted changes
git worktree prune                                          # stale refs
```

## Pitfalls

| Mistake | Why it breaks | Fix |
|---|---|---|
| Ignoring `.cursor/worktrees.json` | Duplicates or misses project-specific setup steps | Always check for config first |
| Symlinking `.env` files | Glob-based tooling silently skips symlinks | Always `cp` |
| Forgetting `.env` files | Missing secrets cause confusing runtime errors | Auto-discover with `find` + `git check-ignore` |
| Worktree inside the project | Risks committing worktree contents | Use `~/.worktrees/` |
| Skipping baseline tests | Can't distinguish new bugs from pre-existing | Run tests, ask if they fail |
