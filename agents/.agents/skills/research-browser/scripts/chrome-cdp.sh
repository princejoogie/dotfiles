#!/usr/bin/env bash
set -euo pipefail

STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"
USER_DATA_DIR="${CHROME_CDP_USER_DATA_DIR:-$STATE_HOME/agent-browser/chrome-cdp-9222}"

open -na "Google Chrome" --args \
  --remote-debugging-port=9222 \
  --user-data-dir="$USER_DATA_DIR"
