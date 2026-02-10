#!/bin/bash
set -euo pipefail

# Kojarchy macOS update — re-deploys configs from repo
# Usage: bash ~/dotfiles/mac/update.sh

DOTFILES_DIR="$(cd "$(dirname "$0")/.." && pwd)"

echo "Pulling latest..."
git -C "$DOTFILES_DIR" pull

echo ""

if command -v gum &>/dev/null; then
  ACTIONS=$(gum choose --no-limit --header "What do you want to update?" \
    "Nvim" \
    "OpenCode" \
    "Kitty" \
    "Shell (zshrc)" \
    "Tmux" \
    "Starship" \
    "Yazi" \
    "Neovim plugins (lazy sync)" \
    "Everything")

  if echo "$ACTIONS" | grep -q "Everything"; then
    ACTIONS="Nvim
OpenCode
Kitty
Shell (zshrc)
Tmux
Starship
Yazi
Neovim plugins (lazy sync)"
  fi
else
  ACTIONS="Everything"
fi

while IFS= read -r action; do
  case "$action" in
  "Nvim"*|"Everything")
    echo "Deploying nvim..."
    cp -R "$DOTFILES_DIR/config/nvim/"* ~/.config/nvim/
    ;;&
  "OpenCode"*|"Everything")
    echo "Deploying opencode..."
    cp -R "$DOTFILES_DIR/config/opencode/"* ~/.config/opencode/
    ;;&
  "Kitty"*|"Everything")
    echo "Deploying kitty..."
    cp -R "$DOTFILES_DIR/config/kitty/"* ~/.config/kitty/
    ;;&
  "Shell"*|"Everything")
    echo "Deploying zshrc..."
    cp "$DOTFILES_DIR/default/zshrc" ~/.zshrc
    ;;&
  "Tmux"*|"Everything")
    echo "Deploying tmux..."
    cp "$DOTFILES_DIR/config/tmux/tmux.conf" ~/.config/tmux/tmux.conf
    ;;&
  "Starship"*|"Everything")
    echo "Deploying starship..."
    cp "$DOTFILES_DIR/config/starship.toml" ~/.config/starship.toml
    ;;&
  "Yazi"*|"Everything")
    echo "Deploying yazi..."
    cp -R "$DOTFILES_DIR/config/yazi/"* ~/.config/yazi/
    ;;&
  "Neovim plugins"*|"Everything")
    echo "Syncing neovim plugins..."
    nvim --headless "+Lazy! sync" +qa 2>/dev/null || true
    ;;&
  esac
  break
done <<< "$ACTIONS"

echo ""
echo "Update complete!"
