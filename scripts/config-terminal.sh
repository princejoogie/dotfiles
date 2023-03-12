export INSTALL_DIR=$HOME/.apps

echo "[⌛] - Configuring terminal..."
sudo apt install tmux zsh -y
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y

export CHSH=no
export RUNZSH=no
export KEEP_ZSHRC=yes

sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"/themes/powerlevel10k

rm -rf ~/.bashrc ~/.zshrc

stow zsh

echo "[✅] - Configuration done."
echo "   Restart your terminal and run"
echo "   $(pwd)/scripts/post-install.sh"
