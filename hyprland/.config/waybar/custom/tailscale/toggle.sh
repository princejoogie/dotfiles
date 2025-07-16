#!/bin/bash

STATE=$(tailscale status --json | jq -r '.BackendState')

if [[ "$STATE" == "Running" ]]; then
  tailscale down
else
  tailscale up --accept-routes --advertise-exit-node --advertise-routes=192.168.1.0/24
fi
