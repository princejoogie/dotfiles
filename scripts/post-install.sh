#!/usr/bin/env bash
#
echo "[⌛] - Configuring fnm..."
fnm install 16.9.1
fnm use 16.9.1

echo "[⌛] - Configuring bob..."
bob install stable
bob use stable
