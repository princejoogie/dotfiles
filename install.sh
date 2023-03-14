#!/usr/bin/env bash

export INSTALL_DIR=$HOME/.apps

echo -n "Install bspwm?   (y/N): "
read -r isBspwm
echo -n "Install polybar? (y/N): "
read -r isPolybar
echo -n "Install picom?   (y/N): "
read -r isPicom
echo -n "Install rofi?    (y/N): "
read -r isRofi

if ! [ -d "/usr/share/fonts/truetype/firacode" ]; then
  sudo mkdir /usr/share/fonts/truetype/firacode
  sudo cp ./fonts/firacode/* /usr/share/fonts/truetype/firacode
  fc-cache -v
fi

if ! [ -d "/usr/share/fonts/truetype/fontawesome" ]; then
  sudo mkdir /usr/share/fonts/truetype/fontawesome
  sudo cp ./fonts/fontawesome/* /usr/share/fonts/truetype/fontawesome
  fc-cache -v
fi

if ! [ -d "/usr/share/fonts/truetype/helvetica" ]; then
  sudo mkdir /usr/share/fonts/truetype/helvetica
  sudo cp ./fonts/helvetica/* /usr/share/fonts/truetype/helvetica
  fc-cache -v
fi

if ! [ -f "/usr/share/fonts/truetype/MaterialDesignIconsDesktop.ttf" ]; then
  sudo cp ./fonts/MaterialDesignIconsDesktop.ttf /usr/share/fonts/truetype
  fc-cache -v
fi

if ! [ -f "/usr/share/fonts/truetype/MesloLGSNF.ttf" ]; then
  sudo cp ./fonts/MesloLGSNF.ttf /usr/share/fonts/truetype
  fc-cache -v
fi

DEPS=("stow" "feh" "dmenu" "curl" "alacritty" "chafa" "lxappearance" "ripgrep")

for dep in "${DEPS[@]}"; do
  if ! [ -x "$(command -v "$dep")" ]; then
    sudo apt install "$dep" -y
  fi
done

if [[ $isBspwm = "y" || $isBspwm == "Y" ]]; then
  sh "$(pwd)/scripts/install-bspwm.sh"
fi

if [[ $isPolybar = "y" || $isPolybar == "Y" ]]; then
  sh "$(pwd)/scripts/install-polybar.sh"
fi

if [[ $isPicom = "y" || $isPicom == "Y" ]]; then
  sh "$(pwd)/scripts/install-picom.sh"
fi

if [[ $isRofi = "y" || $isRofi == "Y" ]]; then
  sh "$(pwd)/scripts/install-rofi.sh"
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

echo "[✅] - Installation done."
echo "   Restart your terminal and run"
echo "   $(pwd)/scripts/config-terminal.sh"

