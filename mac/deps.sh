#!/bin/bash
set -euo pipefail

# Kojarchy macOS dependencies — installs shared tooling via Homebrew
# Usage: bash ~/dotfiles/mac/deps.sh

if ! command -v brew &>/dev/null; then
  echo "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

echo "Installing packages..."

brew install \
  neovim \
  tmux \
  starship \
  zoxide \
  fzf \
  fd \
  yazi \
  jq \
  git-delta \
  gh \
  direnv \
  mise \
  uv \
  bun \
  btop \
  gum \
  kitty

# Oh-my-zsh
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
  echo "Installing oh-my-zsh..."
  RUNZSH=no KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

# Zsh plugins
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

[[ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]] && \
  git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"

[[ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]] && \
  git clone https://github.com/zsh-users/zsh-syntax-highlighting "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"

[[ ! -d "$ZSH_CUSTOM/plugins/fast-syntax-highlighting" ]] && \
  git clone https://github.com/zdharma-continuum/fast-syntax-highlighting "$ZSH_CUSTOM/plugins/fast-syntax-highlighting"

# TPM
TPM_DIR="$HOME/.tmux/plugins/tpm"
if [[ ! -d "$TPM_DIR" ]]; then
  echo "Installing TPM..."
  git clone https://github.com/tmux-plugins/tpm "$TPM_DIR"
fi

# Rust + cargo tools
if ! command -v cargo &>/dev/null; then
  echo "Installing Rust..."
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
  source "$HOME/.cargo/env"
fi

# Bob (neovim version manager)
if ! command -v bob &>/dev/null; then
  cargo install bob-nvim
fi
bob use stable

# TMS
if ! command -v tms &>/dev/null; then
  cargo install tmux-sessionizer
fi

echo ""
echo "Done! Run 'mac/setup.sh' to deploy configs."
