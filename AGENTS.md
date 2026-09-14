# Dotfiles

## Deployment

- Run ordinary Stow operations from the repository root. `stow hyprland nvim shell` deploys the home-directory packages; `stow -D <package>` removes one.
- Treat `agents/install.sh` as the only install, restore, or redeploy path for `agents/`. Besides Stow, it installs the pinned Argent CLI and OpenCode dependencies, rebuilds Claude skill links, enables Codex skills, and fans out MCP configuration.
- `agents/install.sh` defaults `DOTFILES` to `$HOME/dotfiles`; from another clone or worktree use `DOTFILES="$PWD" ./agents/install.sh` or it will deploy the wrong checkout.
- `stow -D agents` removes only Stow-managed links. It does not undo the installer's global npm package, Claude skill bridge, or edits to `~/.claude.json` and `~/.codex/config.toml`.
- Do not Stow `sddm/` or `system/`. Run `./sddm/install-dependencies.sh` and `./sddm/link.sh` from the repository root; `link.sh` uses root-relative paths and writes system files with `sudo`. Install `system/udev/99-scyrox-hidraw.rules` using the commands in `README.md`.

## Agent configuration

- Shared skill sources live in `agents/.agents/skills/`. `~/.claude/skills/` is a generated per-skill link farm; change the source and rerun `agents/install.sh` instead of editing deployed links.
- `agents/mcp/servers.json` is the MCP source of truth. The installer replaces `.mcp` in the tracked OpenCode config, replaces `.mcpServers` in `~/.claude.json`, and rewrites only the marked `agents-mcp` block in `~/.codex/config.toml`.
- `agents/.config/opencode/package.json` intentionally has dependencies but no scripts. Dependency installation is `npm ci --ignore-scripts --prefix agents/.config/opencode`, already performed by `agents/install.sh`.

## Verification and publishing

- There is no repository-wide build or test task. Lua formatting is defined by `.stylua.toml`; check Neovim changes with `stylua --check nvim/.config/nvim`.
- Changes under `agents/.config/opencode/plugins/pull-request/` or `usage/` are force-published from `main` by subtree split to their respective `opencode-plugin-*` branches.
