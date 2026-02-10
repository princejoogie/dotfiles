#!/bin/bash

# Kojarchy package install helpers

install_cargo_packages() {
  local packages_file="$1"

  while IFS= read -r line; do
    [[ -z "$line" || "$line" =~ ^# ]] && continue

    local crate="${line%%=*}"
    local binary="${line##*=}"

    if ! command -v "$binary" &>/dev/null; then
      cargo install "$crate"
    fi
  done <"$packages_file"
}
