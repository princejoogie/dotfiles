#!/bin/bash

install_git() {
  echo ""
  if [[ -x "$(command -v git)" ]]; then
    echo "'git' is already installed"
  else
    echo "Installing 'git'"
    pacman -S --noconfirm git
  fi
}

install_yay() {
  echo ""
  if [[ -x "$(command -v yay)" ]]; then
    echo "'yay' is already installed"
  else
    echo "Installing 'yay'"
    git clone https://aur.archlinux.org/yay-bin.git
    cd yay-bin || exit
    makepkg -si
    cd .. || exit
    rm -rf yay-bin
  fi

  declare -A packages=(
    ["stow"]=stow
    ["tmux"]=tmux
    ["git-delta"]=delta
    ["ripgrep"]=rg
  )

  for pkg in "${!packages[@]}"; do
    bin="${packages[$pkg]}"
    if [[ -x "$(command -v "$bin")" ]]; then
      echo "$pkg (binary: $bin) is already installed"
    else
      echo "Installing $pkg"
      yay -S --noconfirm "$pkg"
    fi
  done
}

install_cargo() {
  echo ""
  if [[ -x "$(command -v cargo)" ]]; then
    echo "'cargo' is already installed"
  else
    echo "Installing cargo"
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
  fi

  declare -A packages=(
    ["bob-nvim"]=bob
    ["tmux-sessionizer"]=tms
    ["fnm"]=fnm
    ["tree-sitter-cli"]=tree-sitter
  )

  for pkg in "${!packages[@]}"; do
    bin="${packages[$pkg]}"
    if [[ -x "$(command -v "$bin")" ]]; then
      echo "$pkg (binary: $bin) is already installed"
    else
      echo "Installing $pkg"
      cargo install "$pkg"
    fi
  done
}

install_git
install_yay
install_cargo
