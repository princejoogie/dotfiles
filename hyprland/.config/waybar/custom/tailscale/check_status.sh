#!/bin/bash

STATE=$(tailscale status --json | jq -r '.BackendState')

if [[ "$STATE" == "Running" ]]; then
  echo '{"text": "ON", "class": "running"}'
else
  echo '{"text": "OFF", "class": "stopped"}'
fi
