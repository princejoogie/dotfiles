#!/bin/bash
set -euo pipefail

# Kojarchy macOS setup — copies shared configs (nvim, opencode, shell, tmux, git)
# Usage: bash ~/dotfiles/mac/setup.sh

DOTFILES_DIR="$(cd "$(dirname "$0")/.." && pwd)"

echo "=== Kojarchy macOS Setup ==="
echo "Dotfiles: $DOTFILES_DIR"
echo ""

# Nvim
echo "Deploying nvim config..."
mkdir -p ~/.config/nvim
cp -R "$DOTFILES_DIR/config/nvim/"* ~/.config/nvim/

# OpenCode
echo "Deploying opencode config..."
mkdir -p ~/.config/opencode
cp -R "$DOTFILES_DIR/config/opencode/"* ~/.config/opencode/

# Kitty
echo "Deploying kitty config..."
mkdir -p ~/.config/kitty
cp -R "$DOTFILES_DIR/config/kitty/"* ~/.config/kitty/

# Starship
echo "Deploying starship config..."
cp "$DOTFILES_DIR/config/starship.toml" ~/.config/starship.toml

# Tmux
echo "Deploying tmux config..."
mkdir -p ~/.config/tmux
cp "$DOTFILES_DIR/config/tmux/tmux.conf" ~/.config/tmux/tmux.conf

# Zsh
echo "Deploying zshrc..."
cp "$DOTFILES_DIR/default/zshrc" ~/.zshrc

# Yazi
echo "Deploying yazi config..."
mkdir -p ~/.config/yazi
cp -R "$DOTFILES_DIR/config/yazi/"* ~/.config/yazi/

echo ""
echo "Done! You may need to:"
echo "  - Restart your shell: source ~/.zshrc"
echo "  - Install dependencies: see mac/deps.sh"
