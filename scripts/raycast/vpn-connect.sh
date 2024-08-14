#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title VPN Connect
# @raycast.mode compact

# Optional parameters:
# @raycast.icon 🤖

# Documentation:
# @raycast.description connect to tunnelblick vpn

osascript -e 'tell application "Tunnelblick" to connect "new-config"'
echo "🔒 Tunnelblick VPN Connecting..."
