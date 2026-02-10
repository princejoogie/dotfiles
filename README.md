# Kojarchy

Personal Hyprland desktop environment for Arch Linux, automated from a fresh `archinstall` to a fully configured system in one command.

![demo_1](.github/assets/demo_1.png)
![demo_2](.github/assets/demo_2.png)
![demo_3](.github/assets/demo_3.png)

## Arch Linux Installation

Boot from the Arch ISO and run `archinstall`. Configure these settings (leave anything not mentioned as-is):

| Section | Option |
|:--------|:-------|
| Mirrors and repositories | Select regions > Your country |
| Disk configuration | Partitioning > Default partitioning layout > Select disk (with space + return) |
| Disk > File system | btrfs (default structure: yes + use compression) |
| Disk > Disk encryption | Encryption type: LUKS + Encryption password + Partitions (select the one) |
| Hostname | Give your computer a name |
| Bootloader | Limine |
| Authentication > Root password | Set yours |
| Authentication > User account | Add a user > Superuser: Yes > Confirm and exit |
| Applications > Audio | pipewire |
| Network configuration | Copy ISO network config |
| Timezone | Set yours |

Once done, let `archinstall` finish and reboot into your new system.

## Install

After rebooting into your fresh Arch Linux install, run:

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
| File Manager | [yazi](https://github.com/sxyazi/yazi) / [Dolphin](https://apps.kde.org/dolphin/) |
| Multiplexer | [Tmux](https://github.com/tmux/tmux) |
| Version Manager | [mise](https://mise.jdx.dev/) (node, go, python) |
| Display Manager | [SDDM](https://github.com/sddm/sddm) with macOS theme + autologin |
| Theme | Adwaita-dark via gsettings, Catppuccin Mocha accents |

## Project Structure

```
~/dotfiles/
├── boot.sh                  # Bootstrap (curl-pipe-bash entry point)
├── install.sh               # Main orchestrator
├── version                  # Version file (semver)
├── lib/                     # Helpers (presentation, logging, errors, packages)
├── install/
│   ├── preflight/           # Guard checks, mkinitcpio disable, install log setup
│   ├── packaging/           # AUR helper, base/optional packages, fonts
│   ├── config/              # Config deploy, shell, tmux, cargo, neovim, mise, git,
│   │   │                    #   docker, gtk, gpg, firewall, dns, hardware detection
│   │   └── hardware/        # Network, bluetooth, Intel GPU, wireless regdom, F-keys,
│   │                        #   touchpad, power profiles
│   ├── services/            # systemd, SDDM, udev
│   ├── post-install/        # Re-enable mkinitcpio, summary, reboot prompt
│   ├── kojarchy-base.packages
│   ├── kojarchy-optional.packages
│   └── kojarchy-cargo.packages
├── config/                  # Copied to ~/.config/ on install (user-editable)
│   ├── hypr/                # hyprland.conf, hypridle.conf, hyprlock.conf, hyprsunset.conf
│   ├── waybar/              # Waybar + custom modules
│   ├── wofi/                # Wofi + dmenu scripts
│   ├── dunst/               # Notification config
│   ├── kitty/               # Terminal config
│   ├── nvim/                # Neovim (lazy.nvim, LSP, treesitter)
│   ├── tmux/                # Tmux config
│   ├── yazi/                # File manager theme
│   ├── opencode/            # OpenCode AI config + skills
│   ├── btop/                # System monitor config
│   ├── fontconfig/          # Font rendering (Liberation Sans, JetBrainsMono NF)
│   ├── kojarchy/hooks/      # User-extensible hooks (post-update, font-set)
│   ├── starship.toml        # Prompt config
│   ├── chromium-flags.conf  # Wayland flags for Chromium
│   ├── brave-flags.conf     # Wayland flags for Brave
│   ├── helium-flags.conf    # Wayland flags for Helium
│   └── xdg-desktop-portal/  # Portal configs
├── default/                 # Stays in repo, sourced at runtime (updated via git pull)
│   ├── hypr/                # autostart, bindings, envs, looknfeel, input, windows
│   │   └── apps/            # App-specific window rules (browser, PiP, Steam, etc.)
│   ├── zsh/                 # aliases, envs, init, functions, shell, rc
│   ├── gpg/                 # GPG keyserver config (multiple fallbacks)
│   └── systemd/             # Faster shutdown timeout
├── bin/                     # CLI utilities -> ~/.local/custom/bin/
│   ├── kojarchy-menu        # Unified gum-based launcher (ALT+SHIFT+SPACE)
│   ├── kojarchy-power-menu  # Power menu (lock/reboot/shutdown)
│   ├── kojarchy-update      # Update system (git pull + packages + migrations)
│   ├── kojarchy-migrate     # Run pending migrations
│   ├── kojarchy-pkg-*       # Package management helpers (add, drop, install TUI)
│   ├── kojarchy-cmd-*       # Commands (screenshot, screenrecord, audio-switch, reboot, shutdown)
│   ├── kojarchy-restart-*   # Restart individual services (waybar, pipewire, bluetooth, etc.)
│   ├── kojarchy-refresh-*   # Reset individual configs to defaults
│   ├── kojarchy-font-*      # Font management (set, list, current)
│   ├── kojarchy-toggle-*    # Toggles (waybar, nightlight, focusmode, RGB)
│   ├── kojarchy-kill-*      # Kill process or port (via wofi)
│   ├── kojarchy-open-file   # Browse and open files (via wofi)
│   ├── kojarchy-calculator  # Wofi calculator
│   ├── kojarchy-camera      # Camera viewer
│   ├── kojarchy-lock-screen # Lock screen via hyprlock
│   ├── kojarchy-debug       # System debug info dump
│   ├── kojarchy-version     # Show version, branch, last package update
│   ├── kojarchy-hook        # Run user hooks
│   ├── kojarchy-state       # Persistent state management for toggles
│   └── kojarchy-menu-keybindings  # Interactive keybinding search (wofi)
├── migrations/              # Timestamped incremental update scripts
├── applications/hidden/     # .desktop files to hide unwanted app launcher entries
├── sddm/macos/              # SDDM macOS theme
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

Kojarchy uses a multi-step update system inspired by omarchy:

```bash
# Full update: pull repo, update packages, run migrations
kojarchy-update

# Skip confirmation prompt
kojarchy-update -y
```

The update process runs these steps in order:

1. **`kojarchy-update-git`** -- Pull latest changes from the repo
2. **`kojarchy-update-time`** -- Sync system clock
3. **`kojarchy-update-system-pkgs`** -- Update official packages (`pacman -Syyu`)
4. **`kojarchy-migrate`** -- Run any pending migrations (incremental system changes)
5. **`kojarchy-update-aur-pkgs`** -- Update AUR packages (via yay)
6. **`kojarchy-update-orphan-pkgs`** -- Remove orphaned packages
7. **`kojarchy-hook post-update`** -- Run user post-update hook
8. **`kojarchy-update-restart`** -- Offer reboot if kernel updated

For most day-to-day changes, `git pull` is enough. The two-layer system means `default/` changes (keybindings, autostart, shell aliases, etc.) take effect immediately since they're sourced at runtime.

### Migrations

Migrations are timestamped shell scripts in `migrations/` that apply one-time system changes during updates. They ensure users who installed earlier get new fixes/features automatically. Each migration runs once and is tracked in `~/.local/state/kojarchy/migrations/`.

### Refreshing Configs

If you break a config, reset it to the Kojarchy default:

```bash
kojarchy-refresh-hyprland   # Reset all Hyprland configs
kojarchy-refresh-waybar     # Reset Waybar config + restart
kojarchy-refresh-hyprlock   # Reset lock screen config
kojarchy-refresh-hypridle   # Reset idle config + restart
kojarchy-refresh-hyprsunset # Reset night light config + restart
kojarchy-refresh-config waybar/style.css  # Reset any specific config file
```

A timestamped backup is created before overwriting.

## Package Management

```bash
kojarchy-pkg-add <package>      # Install if missing (pacman)
kojarchy-pkg-drop <package>     # Remove if installed
kojarchy-pkg-aur-add <package>  # Install from AUR (yay)
kojarchy-pkg-install            # Interactive TUI for browsing/installing packages
kojarchy-pkg-remove             # Interactive TUI for removing packages
kojarchy-pkg-missing <pkg>      # Check: exit 0 if any are missing
kojarchy-pkg-present <pkg>      # Check: exit 0 if all installed
```

## Customization

1. **Edit configs**: Modify files in `~/.config/` directly. They're yours.
2. **Update defaults**: `cd ~/dotfiles && git pull` -- changes propagate automatically since configs source the defaults.
3. **Add overrides**: Uncomment or create override files referenced in the configs (e.g., `~/.config/hypr/overrides.conf`).
4. **Private config**: Add secrets/tokens to `~/.private.sh` (sourced by `~/.zshrc`, gitignored).
5. **Hooks**: Add custom scripts to `~/.config/kojarchy/hooks/` (see `.sample` files).
6. **Font**: Change system-wide monospace font with `kojarchy-font-set <name>` (list available: `kojarchy-font-list`).

## Key Bindings

All bindings use `ALT` as the main modifier. Press `ALT + /` to search all keybindings interactively.

| Binding | Action |
|:--------|:-------|
| `ALT + Return` | Open terminal |
| `ALT + Space` | App launcher (wofi drun) |
| `ALT + SHIFT + Space` | Kojarchy menu (unified launcher) |
| `ALT + CTRL + Space` | Wofi command launcher |
| `ALT + Q` | Kill active window |
| `ALT + F` | Fullscreen |
| `ALT + V` | Toggle floating |
| `ALT + H/J/K/L` | Focus left/down/up/right |
| `ALT + CTRL + H/J/K/L` | Move window |
| `ALT + CTRL + SHIFT + H/J/K/L` | Resize window |
| `ALT + 1-0` | Switch workspace |
| `ALT + SHIFT + 1-0` | Move to workspace |
| `ALT + S` | Toggle scratchpad |
| `ALT + W` | Toggle waybar |
| `ALT + E` | File manager |
| `ALT + SHIFT + C` | Color picker |
| `ALT + CTRL + L` | Lock screen |
| `ALT + ESCAPE` | Power menu (lock/reboot/shutdown) |
| `ALT + /` | Search keybindings |
| `ALT + ,` | Dismiss notification |
| `ALT + SHIFT + ,` | Dismiss all notifications |
| `ALT + SHIFT + N` | Notification history |
| `Print` | Screenshot (region, edit with satty) |
| `SHIFT + Print` | Screenshot to clipboard |
| `ALT + Print` | Screen recording toggle |
| `ALT + SHIFT + D` | Speech-to-text (hyprwhspr) |

## Utility Commands

| Command | Description |
|:--------|:------------|
| `kojarchy-menu` | Unified gum-based launcher for all commands |
| `kojarchy-power-menu` | Power menu (lock/reboot/shutdown) |
| `kojarchy-update` | Full system update |
| `kojarchy-version` | Show version |
| `kojarchy-debug` | System debug info dump |
| `kojarchy-cmd-screenshot` | Take screenshot (region/window/fullscreen) |
| `kojarchy-cmd-screenrecord` | Start/stop screen recording |
| `kojarchy-cmd-audio-switch` | Cycle audio outputs |
| `kojarchy-cmd-reboot` | Graceful reboot (closes windows first) |
| `kojarchy-cmd-shutdown` | Graceful shutdown (closes windows first) |
| `kojarchy-lock-screen` | Lock screen via hyprlock |
| `kojarchy-font-set` | Change system monospace font |
| `kojarchy-menu-keybindings` | Interactive keybinding search |
| `kojarchy-pkg-install` | TUI package browser |
| `kojarchy-toggle-waybar` | Toggle waybar with gaps/rounding |
| `kojarchy-toggle-nightlight` | Toggle hyprsunset nightlight |
| `kojarchy-toggle-focusmode` | Focus mode (black wallpaper, hide UI) |
| `kojarchy-toggle-rgb` | Toggle RGB lights via OpenRGB |
| `kojarchy-kill-process` | Kill a process (via wofi) |
| `kojarchy-kill-port` | Kill a process by port (via wofi) |
| `kojarchy-open-file` | Browse and open files (via wofi) |
| `kojarchy-calculator` | Wofi calculator |
| `kojarchy-camera` | Camera viewer |

## Optional Packages

During install, you're prompted to install optional packages including:

- Gaming (Steam, Prismlauncher, Proton)
- Communication (Discord, Slack, Telegram)
- Productivity (OBS, Blender, Audacity)
- And more

## Credits

Installer architecture inspired by [omarchy](https://github.com/basecamp/omarchy).
