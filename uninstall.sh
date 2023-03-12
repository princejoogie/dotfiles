#!/usr/bin/env bash

export INSTALL_DIR=$HOME/.apps

if [ -d "$INSTALL_DIR"/bspwm ]; then
  echo -n "Uninstall bspwm?   (y/N): "
  read -r isBspwm

  if [[ $isBspwm = "y" || $isBspwm == "Y" ]]; then
    cd "$INSTALL_DIR"/bspwm || exit
    sudo make uninstall
    rm -rf "$INSTALL_DIR"/bspwm
    echo "[✅] - Uninstalled bspwm."
  fi
else
  echo "[  ] - No bspwm found, skipping.."
fi

if [ -d "$INSTALL_DIR"/sxhkd ]; then
  echo -n "Uninstall sxhkd?   (y/N): "
  read -r isSxhkd

  if [[ $isSxhkd = "y" || $isSxhkd == "Y" ]]; then
    cd "$INSTALL_DIR"/sxhkd || exit
    sudo make uninstall
    rm -rf "$INSTALL_DIR"/sxhkd
    echo "[✅] - Uninstalled sxhkd."
  fi
else
  echo "[  ] - No sxhkd found, skipping.."
fi

if [ -d "$INSTALL_DIR"/polybar ]; then
  echo -n "Uninstall polybar? (y/N): "
  read -r isPolybar

  if [[ $isPolybar = "y" || $isPolybar == "Y" ]]; then
    cd "$INSTALL_DIR"/polybar/build || exit
    sudo make uninstall
    rm -rf "$INSTALL_DIR"/polybar
    echo "[✅] - Uninstalled polybar."
  fi
else
  echo "[  ] - No polybar found, skipping.."
fi

if [ -d "$INSTALL_DIR"/picom ]; then
  echo -n "Uninstall picom?   (y/N): "
  read -r isPicom

  if [[ $isPicom = "y" || $isPicom == "Y" ]]; then
    cd "$INSTALL_DIR"/picom || exit
    sudo ninja -C build uninstall
    rm -rf "$INSTALL_DIR"/picom
    echo "[✅] - Uninstalled picom."
  fi
else
  echo "[  ] - No picom found, skipping.."
fi

if [ -x "$(command -v rofi)" ]; then
  echo -n "Uninstall rofi?    (y/N): "
  read -r isRofi

  if [[ $isRofi = "y" || $isRofi == "Y" ]]; then
    sudo apt remove rofi -y
    echo "[✅] - Uninstalled rofi."
  fi
else
  echo "[  ] - No rofi found, skipping.."
fi

