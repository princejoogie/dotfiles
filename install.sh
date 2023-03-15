#!/usr/bin/env bash

export INSTALL_DIR=$HOME/.apps

DEPS=("stow" "feh" "dmenu" "curl" "alacritty" "chafa" "lxappearance" "ripgrep" "thunar")

. /etc/os-release

case $ID in
  ubuntu)
    for dep in "${DEPS[@]}"; do
      if ! [ -x "$(command -v "$dep")" ]; then
        sudo apt install "$dep" -y
      fi
    done
  ;;
  arch)
    for dep in "${DEPS[@]}"; do
      if ! [ -x "$(command -v "$dep")" ]; then
        sudo pacman -S "$dep"
      fi
    done
  ;;
  *)
    echo "[❌] - Unsupported OS"
    exit 1
  ;;
esac

echo -n "Install bspwm?   (y/N): "
read -r isBspwm
echo -n "Install polybar? (y/N): "
read -r isPolybar
echo -n "Install picom?   (y/N): "
read -r isPicom
echo -n "Install rofi?    (y/N): "
read -r isRofi

if [[ $isBspwm = "y" || $isBspwm == "Y" ]]; then
  case $ID in
    ubuntu)
      sh "$(pwd)/scripts/install-bspwm.sh"
    ;;
    arch)
      sudo pacman -S bspwm sxhkd
    ;;
    *)
      echo "[❌] - Unsupported OS"
    ;;
  esac
fi

if [[ $isPolybar = "y" || $isPolybar == "Y" ]]; then
  case $ID in
    ubuntu)
      sh "$(pwd)/scripts/install-polybar.sh"
    ;;
    arch)
      sudo pacman -S polybar
    ;;
    *)
      echo "[❌] - Unsupported OS"
    ;;
  esac
fi

if [[ $isPicom = "y" || $isPicom == "Y" ]]; then
  case $ID in
    ubuntu)
      sh "$(pwd)/scripts/install-picom.sh"
    ;;
    arch)
      sudo pacman -S picom
    ;;
    *)
      echo "[❌] - Unsupported OS"
    ;;
  esac
fi

if [[ $isRofi = "y" || $isRofi == "Y" ]]; then
  case $ID in
    ubuntu)
      sh "$(pwd)/scripts/install-rofi.sh"
    ;;
    arch)
      sudo pacman -S rofi
    ;;
    *)
      echo "[❌] - Unsupported OS"
    ;;
  esac
fi

echo ""
echo "Successfully installed the following:"
if [[ $isBspwm = "y" || $isBspwm == "Y" ]]; then
  echo "bspwm: $(which bspwm)"
  echo "sxhkd: $(which sxhkd)"
fi

if [[ $isPolybar = "y" || $isPolybar == "Y" ]]; then
  echo "polybar: $(which polybar)"
fi

if [[ $isPicom = "y" || $isPicom == "Y" ]]; then
  echo "picom: $(which picom)"
fi

if [[ $isRofi = "y" || $isRofi == "Y" ]]; then
  echo "rofi: $(which rofi)"
fi

stow bspwm
stow alacritty
stow nvim
stow tmux

sh "$(pwd)/scripts/install-fonts.sh"

echo "[✅] - Installation done."
echo "   Restart your terminal and run"
echo "   $(pwd)/scripts/config-terminal.sh"

