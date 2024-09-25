#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title VPN Disconnect
# @raycast.mode compact

# Optional parameters:
# @raycast.icon 🤖

# Documentation:
# @raycast.description disconnect tunnelblick vpn

osascript -e 'tell application "Tunnelblick" to disconnect "new-config"'
echo "🔓 Tunnelblick VPN Disconnecting..."
