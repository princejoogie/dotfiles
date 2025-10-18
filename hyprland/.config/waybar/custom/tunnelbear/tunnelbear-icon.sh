#!/bin/bash

# Check if TunnelBear Japan connection is active
if nmcli connection show --active | grep -q "TunnelBear Japan"; then
  echo "/home/joogie/dotfiles/hyprland/.config/waybar/custom/tunnelbear/tunnelbear-logo.png"
  exit 0
fi

echo "/home/joogie/dotfiles/hyprland/.config/waybar/custom/tunnelbear/tunnelbear-logo-off.png"