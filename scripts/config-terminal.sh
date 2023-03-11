export INSTALL_DIR=$HOME/.apps

echo "[⌛] - Configuring terminal..."
sudo apt install tmux zsh
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

export CHSH=no
export RUNZSH=no
export KEEP_ZSHRC=yes

sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"/themes/powerlevel10k

cargo install tree-sitter-cli fnm bob-nvim

echo "[✅] - Configuration done."
sudo chsh -s \$(which zsh)
echo "[⌛] - Changin shell..."
echo "   run \`who\`"
echo "   then pkill -KILL -u <user>"
echo "   after logging back in, run ./scripts/post-install.sh"
