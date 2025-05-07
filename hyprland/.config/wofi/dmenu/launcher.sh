#!/bin/bash

SCRIPT_DIR="$HOME/dotfiles/hyprland/.config/wofi/dmenu/scripts"
SCRIPTS=$(ls "$SCRIPT_DIR")

selected=$(printf "%s\n" "$SCRIPTS" | wofi --dmenu -p "Run script or Search web")

# Exit if user presses Escape (no input at all)
[ -z "$selected" ] && exit

if printf "%s\n" "$SCRIPTS" | grep -Fxq "$selected"; then
  exec "$SCRIPT_DIR/$selected"
else
  printf "%s" "$selected" | jq -sRr @uri | xargs -r -I{} xdg-open "https://www.google.com/search?q={}"
fi
