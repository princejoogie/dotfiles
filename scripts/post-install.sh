#!/usr/bin/env bash

cargo install tree-sitter-cli fnm bob-nvim git-delta

echo "[⌛] - Configuring fnm..."
fnm install 16.9.1
fnm use 16.9.1

echo "[⌛] - Configuring bob..."
bob install stable
bob use stable

echo "[✅] - Post install done."
echo "   Restart your terminal and you're good to go."
