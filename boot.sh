#!/bin/bash

# Kojarchy bootstrap - curl-pipe-bash entry point
# Usage: curl -fsSL https://raw.githubusercontent.com/princejoogie/dotfiles/refs/heads/automated-installer/boot.sh | bash

sudo pacman -Syu --noconfirm --needed git

KOJARCHY_REPO="${KOJARCHY_REPO:-princejoogie/dotfiles}"
KOJARCHY_DIR="$HOME/dotfiles"

if [[ -d "$KOJARCHY_DIR/.git" ]]; then
  echo "Updating existing dotfiles..."
  git -C "$KOJARCHY_DIR" pull
else
  echo "Cloning dotfiles from: https://github.com/${KOJARCHY_REPO}.git"
  rm -rf "$KOJARCHY_DIR"
  git clone "https://github.com/${KOJARCHY_REPO}.git" "$KOJARCHY_DIR"
fi

KOJARCHY_REF="${KOJARCHY_REF:-automated-installer}"
echo -e "\e[32mUsing branch: $KOJARCHY_REF\e[0m"
cd "$KOJARCHY_DIR"
git fetch origin "$KOJARCHY_REF" && git checkout "$KOJARCHY_REF"
cd -

echo -e "\nInstallation starting..."
source "$KOJARCHY_DIR/install.sh"
