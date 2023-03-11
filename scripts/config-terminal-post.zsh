export INSTALL_DIR=$HOME/.apps

curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

cargo install tree-sitter-cli fnm bob-nvim

echo "[⌛] - Configuring fnm..."
fnm install 16.9.1
fnm use 16.9.1

echo "[⌛] - Configuring bob..."
bob install stable
bob use stable

echo "[⌛] - Configuring zsh theme..."
. "$INSTALL_DIR"/znap-zsh/install.zsh
rm -rf ~/.zshrc ~/.gitconfig ~/.p10k.zsh
stow -D zsh
stow zsh
