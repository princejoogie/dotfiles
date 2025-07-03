# dotfiles

Personal dotfiles configuration using Nix flakes for reproducible system management.

![sc1](https://github.com/user-attachments/assets/a129c2cb-e0a0-420b-b8bf-aa79c05728eb)
![sc2](https://github.com/user-attachments/assets/af4f3786-5444-464f-b639-ffa916ebbb0c)

## Features

- **Hyprland** - Wayland compositor configuration
- **Neovim** - Complete development environment
- **Terminal tools** - Alacritty, Kitty, Zsh with Starship
- **System utilities** - Waybar, Dunst, Wofi, and more
- **Nix flakes** - Reproducible system configuration

## Installation

### Prerequisites

- Install [Nix](https://nixos.org/download)
- Install [nix-darwin](https://github.com/LnL7/nix-darwin?tab=readme-ov-file#flakes) (flakes)
- Install [home-manager](https://nix-community.github.io/home-manager/index.xhtml#sec-install-nix-darwin-module) (darwin module)

### Setup

1. Clone this repository:
   ```sh
   git clone https://github.com/princejoogie/dotfiles.git ~/dotfiles
   ```

2. Apply the configuration:
   ```sh
   darwin-rebuild switch --flake ~/dotfiles/nix
   ```

## Structure

- `nix/` - Nix flake configuration and home-manager setup
- `hyprland/` - Hyprland and related Wayland tools configuration
- `nvim/` - Neovim configuration with Lua
- `shell/` - Shell configuration (Zsh, Git, Tmux)
- `sddm/` - Display manager themes