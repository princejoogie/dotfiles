#!/usr/bin/env bash
set -euo pipefail

if ! command -v jq >/dev/null 2>&1; then
  printf '{"text":"mouse --","tooltip":"Mouse battery unavailable (missing jq)"}\n'
  exit 0
fi

raw=$(/home/joogie/dotfiles/shell/.local/custom/bin/scyrox-battery --device=scyrox --json --no-sudo 2>&1 || true)

if [[ -z "$raw" ]]; then
  printf '{"text":"mouse --","tooltip":"Mouse battery unavailable"}\n'
  exit 0
fi

if ! printf '%s' "$raw" | jq -e '.' >/dev/null 2>&1; then
  msg=$(printf '%s' "$raw" | head -n 1 | tr -d '\r')
  if [[ -z "$msg" ]]; then
    msg="Mouse battery unavailable"
  fi
  printf '{"text":"mouse --","tooltip":"%s"}\n' "$msg"
  exit 0
fi

battery=$(printf '%s' "$raw" | jq -r '.battery // empty')
charging=$(printf '%s' "$raw" | jq -r '.charging // empty')
voltage=$(printf '%s' "$raw" | jq -r '.voltage // empty')
polling=$(printf '%s' "$raw" | jq -r '.pollingRate // empty')

if [[ -z "$battery" ]]; then
  printf '{"text":"mouse --","tooltip":"Mouse battery unavailable"}\n'
  exit 0
fi

icon="󰍽"
text="${icon} ${battery}%"
tooltip="Battery: ${battery}%"

if [[ -n "$charging" ]]; then
  if [[ "$charging" == "true" ]]; then
    tooltip+="\nCharging: yes"
  else
    tooltip+="\nCharging: no"
  fi
fi

if [[ -n "$voltage" ]]; then
  tooltip+="\nVoltage: ${voltage} mV"
fi

if [[ -n "$polling" && "$polling" != "null" ]]; then
  tooltip+="\nPolling rate: ${polling} Hz"
fi

class=""
if [[ "$charging" == "true" ]]; then
  class="charging"
elif [[ "$battery" =~ ^[0-9]+$ && "$battery" -le 20 ]]; then
  class="critical"
fi

if [[ -n "$class" ]]; then
  printf '{"text":"%s","tooltip":"%s","class":"%s"}\n' "$text" "$tooltip" "$class"
else
  printf '{"text":"%s","tooltip":"%s"}\n' "$text" "$tooltip"
fi
