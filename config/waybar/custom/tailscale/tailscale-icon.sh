#!/bin/bash

STATE=$(tailscale status --json | jq -r '.BackendState')

if [[ "$STATE" == "Running" ]]; then
  echo "$HOME/.config/waybar/custom/tailscale/inverted-tailscale-icon.png"
  exit 0
fi

echo "$HOME/.config/waybar/custom/tailscale/tailscale-icon.png"
