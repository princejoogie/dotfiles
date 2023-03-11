export INSTALL_DIR=$HOME/.apps

echo "[⌛] - Configuring terminal..."
sudo apt install tmux zsh
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

export CHSH=no
export RUNZSH=no
export KEEP_ZSHRC=yes

sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"/themes/powerlevel10k

stow zsh nvim tmux
source ~/.zshrc

cargo install tree-sitter-cli fnm bob-nvim

echo "[⌛] - Configuring fnm..."
fnm install 16.9.1
fnm use 16.9.1

echo "[⌛] - Configuring bob..."
bob install stable
bob use stable

echo "[✅] - Configuration done."
echo "  sudo chsh -s \$(which zsh)"
echo "  then logout and login back in to take effect"
