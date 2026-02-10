#!/bin/bash
set -euo pipefail

KOJARCHY_DIR="$HOME/dotfiles"

if [[ ! -d "$KOJARCHY_DIR/.git" ]]; then
  echo "Error: $KOJARCHY_DIR is not a git repo. Run the installer first."
  exit 1
fi

if ! command -v gum &>/dev/null; then
  sudo pacman -S --needed --noconfirm gum
fi

echo "Pulling latest changes..."
git -C "$KOJARCHY_DIR" pull

ACTIONS=$(gum choose --no-limit --header "What do you want to update?" \
  "Packages (install new/missing packages from package lists)" \
  "Configs (re-deploy config/ to ~/.config/ — overwrites local changes)" \
  "Bin scripts (re-link bin/ to ~/.local/custom/bin/)" \
  "Shell (re-deploy ~/.zshrc from default/zshrc)" \
  "SDDM theme (re-copy sddm/macos/ to system theme dir)" \
  "Cargo packages (install missing cargo tools)" \
  "Neovim plugins (sync lazy.nvim)" \
  "Everything")

if echo "$ACTIONS" | grep -q "Everything"; then
  ACTIONS="Packages
Configs
Bin scripts
Shell
SDDM theme
Cargo packages
Neovim plugins"
fi

while IFS= read -r action; do
  case "$action" in
  "Packages"*)
    echo "Installing packages..."
    mapfile -t packages < <(grep -v '^#' "$KOJARCHY_DIR/install/kojarchy-base.packages" | grep -v '^$')
    yay -S --noconfirm --needed "${packages[@]}"
    echo "Packages: OK"
    ;;
  "Configs"*)
    echo "Deploying configs to ~/.config/..."
    cp -R "$KOJARCHY_DIR/config/"* ~/.config/
    echo "Configs: OK"
    ;;
  "Bin scripts"*)
    echo "Linking bin scripts..."
    mkdir -p ~/.local/custom/bin
    for script in "$KOJARCHY_DIR"/bin/*; do
      ln -sf "$script" "$HOME/.local/custom/bin/$(basename "$script")"
    done
    echo "Bin scripts: OK"
    ;;
  "Shell"*)
    echo "Deploying ~/.zshrc..."
    cp "$KOJARCHY_DIR/default/zshrc" ~/.zshrc
    echo "Shell: OK (restart your shell or run: source ~/.zshrc)"
    ;;
  "SDDM theme"*)
    echo "Deploying SDDM theme..."
    sudo cp -R "$KOJARCHY_DIR/sddm/macos/"* /usr/share/sddm/themes/macos/
    echo "SDDM: OK"
    ;;
  "Cargo packages"*)
    echo "Installing cargo packages..."
    source "$KOJARCHY_DIR/lib/packages.sh"
    install_cargo_packages "$KOJARCHY_DIR/install/kojarchy-cargo.packages"
    echo "Cargo: OK"
    ;;
  "Neovim plugins"*)
    echo "Syncing neovim plugins..."
    nvim --headless "+Lazy! sync" +qa 2>/dev/null || true
    echo "Neovim: OK"
    ;;
  esac
done <<< "$ACTIONS"

echo ""
echo "Update complete!"
