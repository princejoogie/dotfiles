# agents — agent-agnostic skills + MCP

One git-tracked, agent-agnostic source that deploys skills and MCP config to every
agent (opencode, Codex, Claude Code) from a single `install.sh`.

## Why this exists

There is a de-facto cross-agent standard — the **Agent Skills Open Standard**
(`agentskills.io`, Dec 2025): a skill is a directory with a `SKILL.md`
(`name` + `description` frontmatter). Codex, opencode, Gemini, Cursor, etc. read
these from `.agents/skills/`. **Claude Code is the outlier** — it predates the
standard and only reads `~/.claude/skills/`.

### Skills discovery matrix (user scope)

| Tool        | Reads `~/.agents/skills` | Reads `~/.claude/skills` |
|-------------|:---:|:---:|
| Codex       | ✅ (only this) | ❌ |
| opencode    | ✅ | ✅ |
| Claude Code | ❌ | ✅ (only this) |

So **`~/.agents/skills/` is canonical** (Codex + opencode read it directly), and
**Claude needs a bridge** into `~/.claude/skills/`.

### MCP config: no standard, three formats

The MCP spec standardizes the wire protocol, not the config file (still unratified
as of the 2026-07-28 RC). De-facto shape is `mcpServers` JSON (Claude Desktop
origin). The deviators are — again — opencode (`mcp` / `type:local|remote` /
`environment` / `command[]`) and Codex (TOML `[mcp_servers]`). So a neutral source
must be *rendered* per tool; no single file is read by all.

## Layout

```
~/dotfiles/agents/                 # stow package (target: $HOME)
├── install.sh                     # the one command (stow + bridge + codex flag + mcp)
├── PLAN.md / README.md            # docs (stow-ignored)
├── .stow-local-ignore             # keep non-$HOME files unlinked
├── mcp/servers.json               # neutral MCP source of truth (stow-ignored)
├── .agents/
│   ├── .skill-lock.json
│   └── skills/<name>/SKILL.md      → ~/.agents/skills   (Codex + opencode)
└── .config/opencode/…             → ~/.config/opencode  (opencode.json incl. mcp)
```

`~/.claude/skills/` is **not** in the repo (no Claude mention in the tree);
`install.sh` creates per-skill symlinks there at deploy time.

## What `install.sh` does

1. **prereqs** — `mkdir -p ~/.claude/skills ~/.config/opencode ~/.codex`.
   `~/.claude/skills` as a real dir forces the per-skill child-symlink layout
   (avoids the historical `~/.claude/skills`-is-a-symlink discovery bug).
2. **stow** — `stow -R agents` → `~/.agents/skills` + `~/.config/opencode`.
3. **claude bridge** — symlink each `~/.agents/skills/<name>` into every dir in
   `BRIDGE_DIRS` (currently just `~/.claude/skills`; add future non-`.agents`
   agents here).
4. **codex** — ensure `[features] skills = true` in `~/.codex/config.toml`.
5. **mcp fan-out** — render `mcp/servers.json` into:
   - opencode → `.mcp` in `opencode.json` (jq; `${VAR}`→`{env:VAR}`)
   - claude   → `.mcpServers` in `~/.claude.json` (jq merge, surgical)
   - codex    → `[mcp_servers.*]` managed block in `~/.codex/config.toml`

## Notes / caveats

- opencode reads both `.agents` and `.claude`, so the Claude bridge causes
  harmless duplicate-name log warnings in opencode (dedupes by name).
- `~/.claude.json` and `~/.codex/config.toml` are stateful (auth/session/trust);
  MCP writes are surgical (single jq key / delimited block) and re-runnable.
  Backups are written to `*.agents-bak` on each run.
- Codex remote MCP TOML schema (verified from `codex mcp add`): `url = "…"`,
  optional `bearer_token_env_var = "ENV"`.
- The MCP fan-out rewrites `opencode.json` via jq, which normalizes formatting
  (inline arrays → multiline). Content is unchanged; the reflow is one-time/stable.
