# agents

Agent-agnostic skills + MCP, deployed to opencode, Codex, and Claude Code with one
command. See [PLAN.md](./PLAN.md) for the full design and rationale.

## Use

```sh
~/dotfiles/agents/install.sh        # idempotent: stow + claude bridge + codex flag + mcp
```

This also installs the pinned Cua Driver CLI and refreshes the shadcn and
OpenTelemetry MCP packages. Node.js 20.12 or
newer and `uvx` are required. Xcode is required for iOS/tvOS
targets; Android targets require `adb` on `PATH`.

## Add a skill

```sh
mkdir -p ~/dotfiles/agents/.agents/skills/<name>
$EDITOR ~/dotfiles/agents/.agents/skills/<name>/SKILL.md   # name + description frontmatter
~/dotfiles/agents/install.sh                               # redeploy + bridge to Claude
```

`skills-lock.json` records the current upstream skills for project restore and
update commands run from `agents/`. `.agents/.skill-lock.json` retains global
upstream metadata for active skills. Custom skills stay in the repository, and the
Cua Driver skill pack matches the pinned CLI release. Preserve local invocation
rules when refreshing upstream files, including `unslop`'s automatic use.

## Add / change an MCP server

Edit `mcp/servers.json` (neutral `mcpServers` shape), then run `install.sh`. It
renders the per-tool formats:

- opencode → `.mcp` in `.config/opencode/opencode.json`
- Claude   → `.mcpServers` in `~/.claude.json`
- Codex    → `[mcp_servers.*]` block in `~/.codex/config.toml`

Use `clientAliases.<client>.<server>` in `mcp/servers.json` when a client has a
conflicting built-in server name.

To limit a server to specific clients, add a `clients` allowlist. Servers without
one are installed for all clients:

```json
"clients": ["opencode"]
```
