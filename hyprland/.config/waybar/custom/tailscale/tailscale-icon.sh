#!/bin/bash

STATE=$(tailscale status --json | jq -r '.BackendState')

if [[ "$STATE" == "Running" ]]; then
  echo "/home/joogie/dotfiles/hyprland/.config/waybar/custom/tailscale/inverted-tailscale-icon.png"
  exit 0
fi

echo "/home/joogie/dotfiles/hyprland/.config/waybar/custom/tailscale/tailscale-icon.png"
