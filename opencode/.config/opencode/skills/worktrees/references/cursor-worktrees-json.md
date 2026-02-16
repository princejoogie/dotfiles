# `.cursor/worktrees.json` Reference

## Config File Lookup

Cursor looks for the config in this order:
1. `<worktree-path>/.cursor/worktrees.json`
2. `<project-root>/.cursor/worktrees.json`

When executing outside Cursor, replicate this: check the worktree first, fall back to the main repo.

## Schema

Three keys, each accepting either an **array of command strings** or a **single string** (path to a script file):

| Key | Platform | Precedence |
|---|---|---|
| `setup-worktree-unix` | macOS/Linux | Highest on Unix |
| `setup-worktree-windows` | Windows | Highest on Windows |
| `setup-worktree` | All | Fallback |

On macOS/Linux: use `setup-worktree-unix` if present, else `setup-worktree`.
On Windows: use `setup-worktree-windows` if present, else `setup-worktree`.

## Environment Variables

| Variable | Value |
|---|---|
| `ROOT_WORKTREE_PATH` | Absolute path to the main repo root |

Set this before executing any commands from the config.

## Examples

**Command array** — each string runs sequentially:

```json
{
  "setup-worktree": [
    "pnpm install",
    "cp $ROOT_WORKTREE_PATH/.env .env",
    "pnpm run build:packages"
  ]
}
```

**Script reference** — single string, resolved relative to the worktree root:

```json
{
  "setup-worktree-unix": "scripts/setup-worktree.sh",
  "setup-worktree": ["echo 'Fallback setup'"]
}
```

**Script with args** — `$ROOT_WORKTREE_PATH` is available:

```json
{
  "setup-worktree": [
    "scripts/setup-worktree.sh \"$ROOT_WORKTREE_PATH\""
  ]
}
```

## Execution Rules

1. Run commands **sequentially** from the worktree directory.
2. Export `ROOT_WORKTREE_PATH` pointing to the main repo before running.
3. If the value is a single string (not array), treat it as a script path relative to the worktree root.
4. **Stop on failure** — if a command exits non-zero, halt and report the error.
