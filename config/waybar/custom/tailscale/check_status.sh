#!/bin/bash

status_json=$(tailscale status --json)
state=$(jq -r '.BackendState' <<< "$status_json")
hostname=$(jq -r '.Self.HostName' <<< "$status_json")
tailscale_ips=$(jq -r '.Self.TailscaleIPs[]' <<< "$status_json" | sed 's/^/ - /' | paste -sd '\r' -)
tailnet=$(jq -r '.CurrentTailnet.Name' <<< "$status_json")
online=$(jq -r '.Self.Online' <<< "$status_json")
peer_count=$(jq '.Peer | length' <<< "$status_json")
peers=$(jq -r '.Peer | to_entries[] | " - \((if .value.Online then "󱘖 " else " " end) + .value.DNSName)"' <<< "$status_json" | paste -sd '\r' -)
[[ -z "$peers" ]] && peers="  - No peers found"

tooltip="Tailnet: $tailnet\rDevice: $hostname\rStatus: $( [[ $online == true ]] && echo "Online" || echo "Offline" )\rTailscale IPs:\r$tailscale_ips\rPeers ($peer_count):\r$peers"

if [[ "$state" == "Running" ]]; then
  echo "{\"text\": \"ON\", \"tooltip\": \"$tooltip\"}"
else
  echo "{\"text\": \"OFF\", \"tooltip\": \"VPN is not running\"}"
fi
