# Kojarchy

Personal Hyprland desktop environment for Arch Linux, automated from a fresh `archinstall` to a fully configured system in one command.

![demo_1](.github/assets/demo_1.png)
![demo_2](.github/assets/demo_2.png)
![demo_3](.github/assets/demo_3.png)

## Install

After a fresh Arch Linux install via `archinstall`, reboot and run:

```bash
curl -fsSL https://raw.githubusercontent.com/princejoogie/dotfiles/refs/heads/main/boot.sh | bash
```

The installer handles everything: packages, configs, services, shell setup, and post-install.

## What's Included

| Component | Tool |
|:----------|:-----|
| Window Manager | [Hyprland](https://hyprland.org/) |
| Status Bar | [Waybar](https://github.com/Alexays/Waybar) with Spotify, Tailscale, Tunnelbear modules |
| Launcher | [Wofi](https://hg.sr.ht/~scoopta/wofi) with custom utility scripts |
| Notifications | [Dunst](https://dunst-project.org/) |
| Wallpaper | [swaybg](https://github.com/swaywm/swaybg) |
| Terminal | [Kitty](https://sw.kovidgoyal.net/kitty/) |
| Shell | Zsh + [oh-my-zsh](https://ohmyz.sh/) + [Starship](https://starship.rs/) |
| Editor | [Neovim](https://neovim.io/) (Lua config, lazy.nvim) |
| File Manager | [yazi](https://github.com/sxyazi/yazi) |
| Multiplexer | [Tmux](https://github.com/tmux/tmux) |
| Version Manager | [mise](https://mise.jdx.dev/) (node, go, python) |
| Display Manager | [SDDM](https://github.com/sddm/sddm) with macOS theme + autologin |
| Theme | Adwaita-dark via gsettings, Catppuccin Mocha accents |

## Project Structure

```
~/dotfiles/
├── boot.sh                  # Bootstrap (curl-pipe-bash entry point)
├── install.sh               # Main orchestrator
├── update.sh                # Interactive updater (re-deploy configs, packages, etc.)
├── lib/                     # Helpers (presentation, logging, errors, packages)
├── install/
│   ├── preflight/           # Guard checks, install log setup
│   ├── packaging/           # AUR helper, base/optional packages, fonts
│   ├── config/              # Config deploy, shell, tmux, cargo, neovim, mise, git, docker, gtk
│   ├── services/            # systemd, SDDM, udev
│   ├── post-install/        # Summary, reboot prompt
│   ├── kojarchy-base.packages
│   ├── kojarchy-optional.packages
│   └── kojarchy-cargo.packages
├── config/                  # Copied to ~/.config/ on install (user-editable)
│   ├── hypr/                # Hyprland (sources defaults, user overrides)
│   ├── waybar/              # Waybar + custom modules
│   ├── wofi/                # Wofi + dmenu scripts
│   ├── dunst/               # Notification config
│   ├── kitty/               # Terminal config
│   ├── nvim/                # Neovim (lazy.nvim, LSP, treesitter)
│   ├── tmux/                # Tmux config
│   ├── yazi/                # File manager theme
│   ├── opencode/            # OpenCode AI config + skills
│   ├── btop/                # System monitor config
│   ├── starship.toml        # Prompt config
│   └── xdg-desktop-portal/  # Portal configs
├── default/                 # Stays in repo, sourced at runtime (updated via git pull)
│   ├── hypr/                # autostart, bindings, envs, looknfeel, input, windows
│   └── zsh/                 # aliases, envs, init, functions, shell, rc
├── bin/                     # CLI utilities -> ~/.local/custom/bin/
├── sddm/macos/             # SDDM macOS theme
├── wallpapers/              # Wallpaper collection
├── system/udev/             # udev rules
└── logo.txt                 # ASCII art for installer TUI
```

## Two-Layer Config System

Configs are split into two layers:

1. **`config/`** -- Copied to `~/.config/` on fresh install. These are your files to customize. They are never overwritten on updates.

2. **`default/`** -- Stays in `~/dotfiles/default/` and is `source`d from the config files at runtime. Updated automatically when you `git pull`.

This means defaults can be improved upstream without overwriting your personal tweaks.

### Example: Hyprland

```conf
# ~/.config/hypr/hyprland.conf

# Source defaults (updated via git pull)
source = ~/dotfiles/default/hypr/autostart.conf
source = ~/dotfiles/default/hypr/bindings.conf
source = ~/dotfiles/default/hypr/envs.conf

# Your overrides below:
monitor=,2560x1440@240,auto,1
```

### Example: Zsh

```bash
# ~/.zshrc sources ~/dotfiles/default/zsh/rc
# which loads: aliases, envs, init, functions, shell

# Add your own customizations at the bottom of ~/.zshrc
```

## Updating

After changing configs or pulling new updates from the repo:

```bash
# Quick: defaults (hypr, zsh) update automatically — just git pull
cd ~/dotfiles && git pull

# Interactive: choose what to re-deploy
~/dotfiles/update.sh
```

`update.sh` lets you pick what to reload:

| Option | What it does |
|:-------|:-------------|
| Packages | Installs new/missing packages from package lists |
| Configs | Re-copies `config/` to `~/.config/` (overwrites local changes) |
| Bin scripts | Re-links `bin/` to `~/.local/custom/bin/` |
| Shell | Re-deploys `~/.zshrc` from `default/zshrc` |
| SDDM theme | Re-copies theme to `/usr/share/sddm/themes/macos/` |
| Cargo packages | Installs any missing cargo tools |
| Neovim plugins | Syncs lazy.nvim plugins |
| Everything | All of the above |

> **Note**: For most day-to-day changes, `git pull` is enough. The two-layer system means `default/` changes (keybindings, autostart, shell aliases, etc.) take effect immediately since they're sourced at runtime. Only use `update.sh` when you need to re-deploy `config/` files or install new packages.

## Customization

1. **Edit configs**: Modify files in `~/.config/` directly. They're yours.
2. **Update defaults**: `cd ~/dotfiles && git pull` -- changes propagate automatically since configs source the defaults.
3. **Add overrides**: Uncomment or create override files referenced in the configs (e.g., `~/.config/hypr/overrides.conf`).
4. **Private config**: Add secrets/tokens to `~/.private.sh` (sourced by `~/.zshrc`, gitignored).

## Key Bindings

All bindings use `ALT` as the main modifier.

| Binding | Action |
|:--------|:-------|
| `ALT + Return` | Open terminal |
| `ALT + Space` | App launcher (wofi drun) |
| `ALT + CTRL + Space` | Dmenu scripts launcher |
| `ALT + Q` | Kill active window |
| `ALT + F` | Fullscreen |
| `ALT + V` | Toggle floating |
| `ALT + H/J/K/L` | Focus left/down/up/right |
| `ALT + CTRL + H/J/K/L` | Move window |
| `ALT + CTRL + SHIFT + H/J/K/L` | Resize window |
| `ALT + 1-0` | Switch workspace |
| `ALT + SHIFT + 1-0` | Move to workspace |
| `ALT + W` | Toggle waybar |
| `ALT + SHIFT + C` | Color picker |
| `Print` | Screenshot region |
| `ALT + Print` | Screenshot window |

## Optional Packages

During install, you're prompted to install optional packages including:

- Gaming (Steam, Prismlauncher, Proton)
- Communication (Discord, Slack, Telegram)
- Productivity (OBS, Blender, Audacity)
- And more

## Credits

Installer architecture inspired by [omarchy](https://github.com/basecamp/omarchy).
