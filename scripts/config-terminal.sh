export INSTALL_DIR=$HOME/.apps

echo "[⌛] - Configuring terminal..."
  stow -D zsh
  rm -rf ~/.zshrc ~/.gitconfig ~/.p10k.zsh ~/.oh-my-zsh
  sudo apt install tmux alacritty zsh curl
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"/themes/powerlevel10k
echo "[✅] - Installed rust."


echo "[✅] - Configuration done."
echo "Open alacritty and run $(pwd)/scripts/post-config.sh"
