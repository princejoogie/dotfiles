# agents

Agent-agnostic skills + MCP, deployed to opencode, Codex, and Claude Code with one
command. See [PLAN.md](./PLAN.md) for the full design and rationale.

## Use

```sh
~/dotfiles/agents/install.sh        # idempotent: stow + claude bridge + codex flag + mcp
```

## Add a skill

```sh
mkdir -p ~/dotfiles/agents/.agents/skills/<name>
$EDITOR ~/dotfiles/agents/.agents/skills/<name>/SKILL.md   # name + description frontmatter
~/dotfiles/agents/install.sh                               # redeploy + bridge to Claude
```

## Add / change an MCP server

Edit `mcp/servers.json` (neutral `mcpServers` shape), then run `install.sh`. It
renders the per-tool formats:

- opencode → `.mcp` in `.config/opencode/opencode.json`
- Claude   → `.mcpServers` in `~/.claude.json`
- Codex    → `[mcp_servers.*]` block in `~/.codex/config.toml`
