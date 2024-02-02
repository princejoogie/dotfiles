#!/usr/bin/env bash

cargo install tree-sitter-cli fnm bob-nvim git-delta

echo "[⌛] - Configuring fnm..."
fnm install 18.19.0
fnm use 18.19.0

echo "[⌛] - Configuring bob..."
bob install stable
bob use stable

. /etc/os-release

case $ID in
  arch)
    if ! [ -x "$(command -v yay)" ]; then
      YAY_DIR="$HOME"/yay
      git clone https://aur.archlinux.org/yay.git "$YAY_DIR"
      cd "$YAY_DIR" || exit
      makepkg -si
    fi

    yes | yay -S google-chrome --noconfirm
    yes | sudo pacman -S materia-theme papirus-icon-theme
  ;;
  ubuntu)
    # echo that this is a todo
    echo "[❌] - Ubuntu is not supported yet"
  ;;
  *)
    echo "[❌] - Unsupported OS"
    exit 1
  ;;
esac

echo "[✅] - Post install done."
echo "   Restart your terminal and you're good to go."
