#!/bin/bash

# Kojarchy package install helpers

install_packages() {
  local packages_file="$1"
  mapfile -t packages < <(grep -v '^#' "$packages_file" | grep -v '^$')
  if [ ${#packages[@]} -gt 0 ]; then
    sudo pacman -S --noconfirm --needed "${packages[@]}"
  fi
}

install_aur_packages() {
  local packages_file="$1"
  mapfile -t packages < <(grep -v '^#' "$packages_file" | grep -v '^$')
  if [ ${#packages[@]} -gt 0 ]; then
    yay -S --noconfirm --needed "${packages[@]}"
  fi
}

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
