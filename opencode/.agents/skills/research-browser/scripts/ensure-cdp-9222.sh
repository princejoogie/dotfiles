#!/usr/bin/env bash
set -euo pipefail

CDP_URL="http://127.0.0.1:9222/json/version"
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
LAUNCHER="$SCRIPT_DIR/chrome-cdp.sh"
TIMEOUT_SECONDS="${1:-20}"

is_ready() {
  curl --silent --fail --max-time 1 "$CDP_URL" >/dev/null
}

if is_ready; then
  printf 'Chrome CDP is already available on port 9222.\n'
  exit 0
fi

if [[ ! -f "$LAUNCHER" ]]; then
  printf 'Chrome CDP launcher was not found: %s\n' "$LAUNCHER" >&2
  exit 1
fi

bash "$LAUNCHER" >/dev/null 2>&1 &

deadline=$((SECONDS + TIMEOUT_SECONDS))
while (( SECONDS < deadline )); do
  if is_ready; then
    printf 'Chrome CDP is available on port 9222.\n'
    exit 0
  fi
  sleep 1
done

printf 'Timed out waiting for Chrome CDP on port 9222.\n' >&2
exit 1
