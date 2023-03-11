#!/usr/bin/env bash

export INSTALL_DIR=$HOME/.apps

echo -n "Install bspwm?   (y/N): "
read isBspwm
echo -n "Install polybar? (y/N): "
read isPolybar
echo -n "Install picom?   (y/N): "
read isPicom
echo -n "Install rofi?    (y/N): "
read isRofi

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

# STOW_FOLDERS="nvim,tmux,zsh,i3,polybar,alacritty"
#
# for folder in $(echo $STOW_FOLDERS | sed "s/,/ /g"); do
# 	stow -D $folder
# 	stow $folder
# done
#
