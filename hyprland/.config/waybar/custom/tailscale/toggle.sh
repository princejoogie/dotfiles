#!/bin/bash

STATE=$(tailscale status --json | jq -r '.BackendState')

if [[ "$STATE" == "Running" ]]; then
  tailscale down
else
  tailscale up --accept-routes
fi
