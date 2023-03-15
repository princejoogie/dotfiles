#!/usr/bin/env bash

FONT_DIR="$HOME/.local/share/fonts"

if ! [ -d "$FONT_DIR" ]; then
  mkdir -p "$FONT_DIR"
fi

if ! [ -d "$FONT_DIR"/firacode ]; then
  sudo mkdir "$FONT_DIR"/firacode
  sudo cp ./fonts/firacode/* "$FONT_DIR"/firacode
  fc-cache -v
  echo "[✅] - firacode installed."
else
  echo "[  ] - firacode already installed, skipping."
fi

if ! [ -d "$FONT_DIR"/fontawesome ]; then
  sudo mkdir "$FONT_DIR"/fontawesome
  sudo cp ./fonts/fontawesome/* "$FONT_DIR"/fontawesome
  fc-cache -v
  echo "[✅] - fontawesome installed."
else
  echo "[  ] - fontawesome already installed, skipping."
fi

if ! [ -d "$FONT_DIR"/helvetica ]; then
  sudo mkdir "$FONT_DIR"/helvetica
  sudo cp ./fonts/helvetica/* "$FONT_DIR"/helvetica
  fc-cache -v
  echo "[✅] - helvetica installed."
else
  echo "[  ] - helvetica already installed, skipping."
fi

if ! [ -f "$FONT_DIR"/MaterialDesignIconsDesktop.ttf ]; then
  sudo cp ./fonts/MaterialDesignIconsDesktop.ttf "$FONT_DIR"/
  fc-cache -v
  echo "[✅] - material installed."
else
  echo "[  ] - material already installed, skipping."
fi

if ! [ -f "$FONT_DIR"/MesloLGSNF.ttf ]; then
  sudo cp ./fonts/MesloLGSNF.ttf "$FONT_DIR"/
  fc-cache -v
  echo "[✅] - meslo installed."
else
  echo "[  ] - meslo already installed, skipping."
fi
