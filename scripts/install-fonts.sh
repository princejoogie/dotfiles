#!/usr/bin/env bash

if ! [ -d "/usr/share/fonts/truetype/firacode" ]; then
  sudo mkdir /usr/share/fonts/truetype/firacode
  sudo cp ./fonts/firacode/* /usr/share/fonts/truetype/firacode
  fc-cache -v
  echo "[✅] - firacode installed."
else
  echo "[  ] - firacode already installed, skipping."
fi

if ! [ -d "/usr/share/fonts/truetype/fontawesome" ]; then
  sudo mkdir /usr/share/fonts/truetype/fontawesome
  sudo cp ./fonts/fontawesome/* /usr/share/fonts/truetype/fontawesome
  fc-cache -v
  echo "[✅] - fontawesome installed."
else
  echo "[  ] - fontawesome already installed, skipping."
fi

if ! [ -d "/usr/share/fonts/truetype/helvetica" ]; then
  sudo mkdir /usr/share/fonts/truetype/helvetica
  sudo cp ./fonts/helvetica/* /usr/share/fonts/truetype/helvetica
  fc-cache -v
  echo "[✅] - helvetica installed."
else
  echo "[  ] - helvetica already installed, skipping."
fi

if ! [ -f "/usr/share/fonts/truetype/MaterialDesignIconsDesktop.ttf" ]; then
  sudo cp ./fonts/MaterialDesignIconsDesktop.ttf /usr/share/fonts/truetype
  fc-cache -v
  echo "[✅] - material installed."
else
  echo "[  ] - material already installed, skipping."
fi

if ! [ -f "/usr/share/fonts/truetype/MesloLGSNF.ttf" ]; then
  sudo cp ./fonts/MesloLGSNF.ttf /usr/share/fonts/truetype
  fc-cache -v
  echo "[✅] - meslo installed."
else
  echo "[  ] - meslo already installed, skipping."
fi
